------------------------------------------------------------------------------------
-- game/entities/fight_mon_ent.lua
--
-- 打怪单元
--
-- @module      fight_mon_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local fight_mon_ent = import('game/entities/fight_mon_ent')
------------------------------------------------------------------------------------
local main_ctx      = main_ctx
-- 模块定义
---@class fight_mon_ent
local fight_mon_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION         = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE     = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME     = 'fight_mon_ent module',
    -- 只读模式
    READ_ONLY       = false,
    -- 坐标设置生成路径
    POS_PATH        = '夜鸦:机器[%s]:坐标设置',
    -- 坐标排序设置个人
    SELF_PATH       = '夜鸦:数据记录:服务器:' .. main_ctx:c_server_name() .. ':机器[%s]:坐标排位:个人占位',
    -- 坐标排序设置队伍
    TEAM_PATH       = '夜鸦:数据记录:服务器:' .. main_ctx:c_server_name() .. ':机器[%s]:坐标排位:队伍占位',
    -- 死亡次数切换[大于此次数时切换坐标]
    DEAD_CHANGE_NUM = 6,
    -- 坐标排序个人自动最大批次
    SELF_MAX_T      = 10,
    -- 坐标排序个人单表可记最大数
    SELF_MAX_D      = 30,
    -- 坐标排序队伍自动最大批次
    TEAM_MAX_T      = 10,
    -- 坐标排序队伍单表可记最大数
    TEAM_MAX_D      = 30,
    -- 占位数据保存时间
    TIME_OUT        = 12 * 3600,
    -- 连接服务器
    CONNECT_OBJ     = nil,
    -- 是否跨大陆挂机
    SPAN_MAIN_MAP   = true
    
}

-- 实例对象
local this          = fight_mon_ent
-- 日志模块
local trace         = trace
-- 决策模块
local decider       = decider
local import        = import
local common        = common
local actor_unit    = actor_unit
local local_player  = local_player
local item_unit     = item_unit
local os            = os
local tonumber      = tonumber
local setmetatable  = setmetatable
local rawset        = rawset
local pairs         = pairs
local table         = table
local string        = string
local math          = math
---@type redis_ent
local redis_ent     = import('game/entities/redis_ent')
local utils         = import('base/utils')
---@type actor_ent
local actor_ent     = import('game/entities/actor_ent')
local map_res       = import('game/resources/map_res')
---@type map_ent
local map_ent       = import('game/entities/map_ent')
---@type user_set_ent
local user_set_ent  = import('game/entities/user_set_ent')
---@type quest_ent
local quest_ent     = import('game/entities/quest_ent')
---@type dungeon_ent
local dungeon_ent   = import('game/entities/dungeon_ent')
---@type ui_ent
local ui_ent        = import('game/entities/ui_ent')
---@type item_ent
local item_ent      = import('game/entities/item_ent')
local fight_mon_res = import('game/resources/fight_mon_res')
local login_res     = import('game/resources/login_res')
------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function fight_mon_ent.super_preload()

end

------------------------------------------------------------------------------------
-- 设置redis连接对象
fight_mon_ent.set_connect_obj = function(set_obj)
    this.CONNECT_OBJ = set_obj
end

------------------------------------------------------------------------------------
-- 生成坐标资源
fight_mon_ent.create_pos = function()
    user_set_ent.load_user_info()
    -- 生成每个地图资源
    local crete_list = fight_mon_res.CREATE_POS_LIST
    local line_path  = string.format(this.POS_PATH,redis_ent.computer_id)
    -- 生成每个地图
    for k,v in pairs(crete_list) do
        for i = 1,#v do
            local value = redis_ent.get_string_redis_ini(line_path,k,i,this.CONNECT_OBJ)
            if value == '' then
                redis_ent.set_string_redis_ini(line_path,k,i,v[i],this.CONNECT_OBJ)
            end
        end
    end
end

------------------------------------------------------------------------------------
-- 获取挂机坐标,延迟刷新[默认3600 * 12 秒]
fight_mon_ent.get_cache_kill_monster_pos = function(team_idx,key,time_out,need_play)
    time_out = time_out or 3600 * 12
    return common.get_cache_result_ex(team_idx..key,this.get_kill_monster_pos,time_out,team_idx,key,need_play)
end

------------------------------------------------------------------------------------
-- 获取挂机坐标
fight_mon_ent.get_kill_monster_pos = function(team_idx,key,need_play)
    -- 保存坐标数据
    local data       = {}
    -- 可从坐标数据中选择的序号
    local idx        = 0
    -- 占位在数据表中的序号
    local g_idx      = 0
    if team_idx and team_idx ~= 0 then
        -- 设置队伍编号占位序号
        this.set_team_pos_idx(team_idx)
        -- 读取队伍占位序号
        g_idx        = this.get_team_pos_idx(team_idx)
        -- 获取队伍最低等级
        local min_lv = 20
        -- 取可选坐标数据
        data         = this.get_can_use_pos_data(key,min_lv)
    else
        -- 设置个人占位序号
        this.set_self_pos_idx()
        -- 读取单人占位
        g_idx        = this.get_self_pos_idx()
        -- 读取可选坐标数据
        data         = this.get_can_use_pos_data(key)
    end
    local pos_num    = #data
    if g_idx <= pos_num then
        idx = g_idx
    else
        local idx1, idx2 = math.modf(g_idx / pos_num)
        idx = ( idx2 == 0 and pos_num ) or ( g_idx - pos_num * idx1 )
    end
    -- 取表中pos.坐标
    if not table.is_empty(data[idx]) then-- PK模式：%d+
        local map_id,x,y,z,min_lv,max_lv,r,m,line,mod,pk_mode = table.unpack(data[idx].pos)
        -- 获取地图ID
        map_id  = map_id  and tonumber(map_id)   or 0
        -- 获取坐标x
        x       = x       and tonumber(x)        or 0
        -- 获取坐标y
        y       = y       and tonumber(y)        or 0
        -- 获取坐标z
        z       = z       and tonumber(z)        or 0
        -- 获取坐标序号
        idx     = data[idx].idx                  or idx
        -- 获取打怪范围
        r       = r       and tonumber(r)        or 20
        -- 获取文明模式
        m       = m       and tonumber(m)        or 3
        -- 获取线路
        line    = line    and tonumber(line)     or 0
        -- 获取打怪模式 0内置 1 脚本
        mod     = mod     and tonumber(mod)      or 0
        -- 获取pk模式
        pk_mode = pk_mode and tonumber(pk_mode)  or 0
        return map_id,x,y,z,idx,line,r,m,mod,pk_mode
    end
    return 0,0,0,0,0,0,0,0,0,0
end

------------------------------------------------------------------------------------
-- 去挂机点挂机
-- @tparam         number        team_idx            标记个人或队伍序号
-- @tparam         string        kill_type           标记执行任务的类型
-- @tparam         function      enter_fb            进入副本的方法
-- @tparam         function      looping             轮巡功能
-- @tparam         table         dungeon_info        进入副本副本信息
------------------------------------------------------------------------------------
fight_mon_ent.go_to_pos_kill_mon = function(team_idx,kill_type,enter_fb,looping,dungeon_info)
    -- 等待过图
    map_ent.waiting_to_map()
    local first_move = true
    common.set_kill_range(40)
    while decider.is_working() do
        -- 获取挂机坐标信息
        local map_id,x,y,z,idx,line,r,m,mod,pk_mode = this.get_cache_kill_monster_pos(team_idx,kill_type)
        local my_x,my_y = local_player:cx(),local_player:cy()
        if map_id == 0 then
            trace.output('未获取到地图[',kill_type,']')
            return
        end
        -- 执行功能块
        if looping then
            looping()
        end
        -- 执行进入指定地图
        if not enter_fb then
            map_ent.execute_transfer_map(map_id)
        else
            -- 执行副本进入地图
            enter_fb(dungeon_info)
        end
        if dungeon_info and dungeon_info.main_map_id and dungeon_info.main_map_id ~= actor_unit.main_map_id() then
            trace.output('不在副本地图[',kill_type,']')
            return
        end
        -- 不在指定地图停止挂机
        if ( dungeon_info and not dungeon_info.main_map_id or not dungeon_info) and map_id ~= actor_unit.map_id() then --and map_res.get_main_id_by_map_id(map_id) ~= map_id and this.SPAN_MAIN_MAP
            trace.output('不在挂机地图[',kill_type,']')
            return
        end
        if login_res.is_loading_map() then
            trace.output('正在过图中[',kill_type,']')
            return
        end
        -- 关闭副本窗口
        ui_ent.close_dungeon_win()
        -- 对话关闭
        common.execute_pass_dialog()
        -- 检测设置-设置线路    line
        if line > 0 then
            actor_ent.execute_change_line(line)
        else
            actor_ent.auto_change_line_ex()
        end
        -- 如果非在范围内打怪 重置
        if not utils.is_inside_radius(my_x,my_y,x,y, r * 100 * 1.5) and not this.is_in_pvp_dungeon() then
            first_move = true
        end
        -- 首次移动
        if first_move then
            -- 移动到挂机点挂机
            local dist = local_player:dist_xy(x,y)
            if dist < 600 then
                first_move = false
            else
                if not common.is_move() then
                    trace.output('到:',map_id,'-',idx,'-挂机')
                    common.auto_move(x,y,z,100,200)
                else
                    trace.output('到:',map_id,'-',idx,'-挂机,移动中')
                end
                decider.sleep(2000)
            end
        end
        -- 已在挂机点范围
        if not first_move then
            -- 接/交日常任务
            quest_ent.execute_daily_task_ex()
            -- 检查血量使用瞬移
            this.use_shunyi()
            -- 检测设置-设置文明模式 m
            
            -- 检测设置-设置打怪范围 r
            common.set_kill_range(r)

            -- 检测设置-设置PK模式  pk_mode
            
            -- 内置打怪模式
            if mod == 0 then
                -- 开启打怪
                common.set_auto(1)
                if actor_unit.get_auto_type() ~= 0 then
                    trace.output('[P:',idx,']正[',kill_type,']中.')
                end
            else
                -- 技能打怪模式
                
            end
        end
        decider.sleep(1000)
    end
end

--------------------------------------------------------------------------------
-- 判断是否在pvp副本
--------------------------------------------------------------------------------
fight_mon_ent.is_in_pvp_dungeon = function()
    local my_map_id = actor_unit.map_id()
    if my_map_id == 50000101 or my_map_id == 50000201 or my_map_id == 50000401 or my_map_id == 50000301 then
        return true
    end
    return false
end

--------------------------------------------------------------------------------
-- 使用瞬移卷轴
--------------------------------------------------------------------------------
fight_mon_ent.use_shunyi = function()
    if not fight_mon_ent.is_in_pvp_dungeon() then
        return false, '不在pvp副本不适用'
    end
    if actor_unit.local_player_hp() * 100 / actor_unit.local_player_max_hp() > 60 then
        return false, '角色血量大于60%'
    end
    if item_ent.get_item_num_by_name('생명력 물약(귀속)', 0) > 0 then
        return false, '角色药品数量为0'
    end
    if not common.is_sleep_any('use_sunyi', 60) then
        return false, '使用瞬移冷却时间60秒'
    end
    local item_info = item_ent.get_item_info_by_name('순간 이동 주문서(귀속)')
    if table.is_empty(item_info) then
        return false, '背包没有瞬移卷轴'
    end
    common.set_sleep(0)
    item_unit.use_item(item_info.id, 1)
    decider.sleep(2000)
end

--------------------------------------------------------------------------------
-- 是否终止挂机
--------------------------------------------------------------------------------
fight_mon_ent.is_stop_afk_farming = function(do_type)
    -- 无连接 重启游戏
    common.check_connect()

    local result  = false
    local stop_lv = user_set_ent['最低等级'] or 35

    if actor_unit.local_player_level() < stop_lv then
        result = true
        local task_info = quest_ent.get_main_task_info()
        if task_info.name == '죽음의 기사' then
            result = false
        end
    end
    
    if not result and do_type == '副本' then
        local dungeon_info = common.get_cache_result_ex('get_can_do_dungeon_info',dungeon_ent.get_can_do_dungeon_info,10)
        if not table.is_empty(dungeon_info) then
            result = true
        end
    end
    
    return result
end

------------------------------------------------------------------------------------
-- 读取所有坐标
fight_mon_ent.get_pos_all = function(key)
    local num       = 20
    local data      = {}
    local line_path = string.format(this.POS_PATH,redis_ent.computer_id)
    for i = 1,num do
        local value = redis_ent.get_string_redis_ini(line_path,key,i,this.CONNECT_OBJ)


        if value ~= '' then
            local data1 = {}
            data1.idx = i
            data1.pos = this.get_split_pos(value)
            -- 将分割后的坐标保存到DATA
            table.insert(data,data1)
        end
    end
    return data
end

------------------------------------------------------------------------------------
-- 读取可选坐标列表[根据等级段]
fight_mon_ent.get_can_use_pos_data = function(key,level)
    level          = level or actor_unit.local_player_level()
    local data     = this.get_pos_all(key)
    local can_data = {}
    for i = 1,#data do
        -- MID:205,X:35939,Y:-48904,Z:2138,NLV:1,MLV:100,R:20,M:3,L:1,MOD:0,PK模式:0
        local map_id,x,y,z,min_lv,max_lv = table.unpack(data[i].pos)
        local dead_key = map_id..data[i].idx
        local maid_id  = map_res.get_main_id_by_map_id(map_id)
        local is_read  = not this.SPAN_MAIN_MAP or ( this.SPAN_MAIN_MAP and (maid_id == 0 or maid_id == actor_unit.main_map_id()) or false )
        -- 获取 3600 * 6秒内死亡记录
        local dead_num = common.get_handle_count(dead_key,3600 * 6,true)
        if level >= tonumber(min_lv) and level < tonumber(max_lv) and dead_num <= this.DEAD_CHANGE_NUM and is_read then
            table.insert(can_data,data[i])
        end
    end
    if not table.is_empty(can_data) then
        table.sort(can_data,function(a, b) return a.idx < b.idx end)
    end
    return can_data
end

------------------------------------------------------------------------------------
-- 分割坐标,返回坐标数据表{ MID:0,X:0,Y:0,Z:0,NLV:1,MLV:100,R:20,M:3,L:1,MOD:0,PK模式:0}
fight_mon_ent.get_split_pos = function(pos_str)
    local data = {}
    for k in string.gmatch(pos_str,'-?%d+') do
        table.insert(data,k)
    end
    return data
end

------------------------------------------------------------------------------------
-- 写入个人占位[time 设置数值低时可清空操作]
fight_mon_ent.set_self_pos_idx = function(idx,time)
    local data_w = {
        name     = local_player:name(),
        time     = time or os.time(),
    }
    if idx then
        data_w.pos_idx = idx
    end
    local path   = string.format(this.SELF_PATH,redis_ent.computer_id)
    redis_ent.set_data_in_redis_table_list_path(data_w,local_player:name(),'name',path,this.TIME_OUT,this.SELF_MAX_T,this.SELF_MAX_D,this.CONNECT_OBJ)
end

------------------------------------------------------------------------------------
-- 读取个人占位序号
fight_mon_ent.get_self_pos_idx = function(read)
    local path          = string.format(this.SELF_PATH,redis_ent.computer_id)
    local idx,idx2,data = redis_ent.get_idx_in_redis_table_list_path(local_player:name(),'name',path,this.TIME_OUT,this.SELF_MAX_T,this.SELF_MAX_D,this.CONNECT_OBJ)
    if read then
        return data[idx2] and data[idx2].pos_idx or 0
    end
    return idx * idx2
end

------------------------------------------------------------------------------------
-- 写入队伍占位[time 设置数值低时可清空操作]
fight_mon_ent.set_team_pos_idx = function(team_idx,idx,time)
    team_idx     = '机器'..redis_ent.computer_id..'-'..team_idx
    local path   = string.format(this.TEAM_PATH,redis_ent.computer_id)
    local data_w = {
        name     = team_idx,
        time     = time or os.time(),
    }
    if idx then
        data_w.pos_idx = idx
    end
    redis_ent.set_data_in_redis_table_list_path(data_w,team_idx,'name',path,this.TIME_OUT,this.TEAM_MAX_T,this.TEAM_MAX_D,this.CONNECT_OBJ)
end

------------------------------------------------------------------------------------
-- 读取队伍占位序号
fight_mon_ent.get_team_pos_idx = function(team_idx,read)
    team_idx            = '机器'..redis_ent.computer_id..'-'..team_idx
    local path          = string.format(this.TEAM_PATH,redis_ent.computer_id)
    local idx,idx2,data = redis_ent.get_idx_in_redis_table_list_path(team_idx,'name',path,this.TIME_OUT,this.TEAM_MAX_T,this.TEAM_MAX_D,this.CONNECT_OBJ)
    if read then
        return data[idx2] and data[idx2].pos_idx or 0
    end
    return idx * idx2
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function fight_mon_ent.__tostring()
    return this.MODULE_NAME
end

------------------------------------------------------------------------------------
-- [内部] 防止动态修改(this.READ_ONLY值控制)
--
-- @local
-- @tparam       table     t                被修改的表
-- @tparam       any       k                要修改的键
-- @tparam       any       v                要修改的值
------------------------------------------------------------------------------------
function fight_mon_ent.__newindex(t, k, v)
    if this.READ_ONLY then
        error('attempt to modify read-only table')
        return
    end
    rawset(t, k, v)
end

------------------------------------------------------------------------------------
-- [内部] 设置item的__index元方法指向自身
--
-- @local
------------------------------------------------------------------------------------
fight_mon_ent.__index = fight_mon_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function fight_mon_ent:new(args)
    local new = {}
    -- 预载函数(重载脚本时)
    if this.super_preload then
        this.super_preload()
    end
    -- 将args中的键值对复制到新实例中
    if args then
        for key, val in pairs(args) do
            new[key] = val
        end
    end
    -- 设置元表
    return setmetatable(new, fight_mon_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return fight_mon_ent:new()

-------------------------------------------------------------------------------------
