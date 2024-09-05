------------------------------------------------------------------------------------
-- game/entities/actor_ent.lua
--
-- 这个模块主要是项目内周围环境相关功能操作。
--
-- @module      actor_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-03-22
-- @copyright   2023
-- @usage
-- local actor_ent = import('game/entities/actor_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class actor_ent
local actor_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION      = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE  = '2023-03-22 - Initial release',
    -- 模块名称
    MODULE_NAME  = 'actor_ent module',
    -- 只读模式
    READ_ONLY    = false,
    -- 当前角色
    LOCAL_PLAYER = 0,
    -- 玩家
    OTHER_PLAYER = 1,
    -- npc
    GAME_NPC     = 2,
    -- 怪物
    GAME_MONSTER = 3
}

-- 实例对象
local this = actor_ent
-- 日志模块
local trace        = trace
-- 决策模块
local decider      = decider
local common       = common
local pairs        = pairs
local table        = table
local ipairs       = ipairs
local math         = math
local main_ctx     = main_ctx
local actor_unit   = actor_unit
local actor_ctx    = actor_ctx
local import       = import
local ui_unit      = ui_unit
local local_player = local_player
local rawset       = rawset
local setmetatable = setmetatable
local utils        = import('base/utils')
local actor_res    = import('game/resources/actor_res')
local map_res      = import('game/resources/map_res')
---@type item_ent
local item_ent    = import('game/entities/item_ent')
------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
actor_ent.super_preload = function()
    -- [行为] 打开频道切换
    this.wa_open_channle      = decider.run_action_wrapper('[行为]打开频道切换',this.open_channle)
    -- [行为] 打开信念窗口
    this.wa_open_stat_win     = decider.run_action_wrapper('[行为]打开信念窗口',this.open_stat_win)
    -- [行为] 确定加信念点
    this.wa_set_stat_decision = decider.run_action_wrapper('[行为]确定加信念点',this.set_stat_decision)
    -- [行为] 间隔执行切换频道
    this.wi_change_line       = decider.run_interval_wrapper('[间隔]切换频道',actor_unit.change_channel,10 * 1000)
    -- [行为] 间隔执行复活
    this.wi_rise_man          = decider.run_interval_wrapper('[间隔]执行复活',function() decider.sleep(5000) actor_unit.rise_man() end,8 * 1000)
    -- [行为] 执行复活
    local action_name = function()
        trace.output('执行复活.')
        common.set_sleep(0)
        this.wi_rise_man()
        decider.sleep(2000)
    end
    -- [条件] 终止复活
    local cond_func = function()
        return not this.get_local_player_is_dead() and this.wait_recover_hp()
    end
    -- [行为] 执行复活到完成
    this.wr_wait_change_item = decider.run_until_wrapper(action_name, cond_func, 20)
    -- [行为] 切换到指定频道
    this.wu_change_line = decider.run_until_wrapper(
            function(line) trace.output('正切换到频道[',line,']') this.wi_change_line(line) end,
            function(line) return not this.is_need_change_line(line) end,
            10
    )
    -- [行为] 切换频道的信息
    this.wa_change_line = decider.run_action_wrapper('[行为]切换消息输出',this.do_change_line)
end

------------------------------------------------------------------------------------
-- [行为] 复活角色[使用时调用此命令]
------------------------------------------------------------------------------------
actor_ent.rise_man = function()
    return not this.get_local_player_is_dead() and 0 or this.wr_wait_change_item()
end

------------------------------------------------------------------------------------
-- [行为] 等待血量恢复
------------------------------------------------------------------------------------
actor_ent.wait_recover_hp = function()
    while decider.is_working() do
        local hp_proc  = (actor_unit.local_player_hp()/actor_unit.local_player_max_hp()) * 100
        if hp_proc >= 70 then
            return
        end
        -- 追加是否存在需要的药品
        local item_num = item_ent.get_item_num_by_name('생명력 물약(귀속)', 0)
        if item_num == 0 then
            return
        end
        trace.output('正在恢复血量['..math.floor(hp_proc)..']')
        decider.sleep(2000)
    end
end

------------------------------------------------------------------------------------
-- 设置信念[传承点]
------------------------------------------------------------------------------------
actor_ent.set_stat = function()
    -- 等级需大于30级
    if actor_unit.local_player_level() < 31 then return end
    local stat_info  = actor_res.get_set_stat_info()
    local close_stat = false
    if not table.is_empty(stat_info) then
        for _,v in pairs(stat_info) do
            local name  = v.name
            local id    = v.id
            local point = v.point
            if point > 0 then
                if this.wa_open_stat_win() then
                    trace.output('添加'..name..':'..point..'点')
                    close_stat = true
                    common.set_sleep(0)
                    actor_unit.add_stat_primary(id, point)
                    decider.sleep(2000)
                end
            end
        end
    end
    if close_stat then
        trace.output('确定设置信念点')
        common.set_sleep(0)
        this.wa_set_stat_decision()
        ui_unit.exit_widget()
    end
end

------------------------------------------------------------------------------------
-- 打开信念窗口
------------------------------------------------------------------------------------
actor_ent.open_stat_win = function()
    local ret      = false
    local open_num = 0
    while decider.is_working() do
        if actor_unit.is_open_stat_scene() then
            ret = true
            break
        end
        if open_num > 3 then break end
        open_num = open_num + 1
        trace.output('打开传承窗口-',open_num)
        actor_unit.open_stat_scene()
        decider.sleep(3000)
    end
    return ret,not ret and '打开信念窗体失败' or '成功'
end

------------------------------------------------------------------------------------
-- 确定加点
------------------------------------------------------------------------------------
actor_ent.set_stat_decision = function()
    local stat_point = actor_unit.get_stat_point()
    actor_unit.stat_decision()
    decider.sleep(2000)
    for i = 1,15 do
        if stat_point ~= actor_unit.get_stat_point() then
            return true
        end
        decider.sleep(1000)
    end
    return false,'设置信念点失败'
end

------------------------------------------------------------------------------------
-- 自动切换频道
------------------------------------------------------------------------------------
actor_ent.auto_change_line = function(status)
    local is_move        = common.is_move()
    local line           = actor_unit.get_cur_channel()
    local x              = local_player:cx()
    local y              = local_player:cy()
    local key            = math.floor(line)..math.floor(x)..math.floor(y)
    local bool_val,count = common.get_interval_change(key,is_move,10)
    -- xxmsg('bool_val:'..bool_val..' count:'..count..' '..key..' '..tostring(is_move))
    if not is_move and ( bool_val == 2 and count > 15 or status and ( status == 0 or status == 1 or status == 2 )
            and actor_unit.local_player_level() > 2 and common.is_sleep_any(line..x..y,60) and this.get_actor_info_by_pos() > 5 )  then
        if not map_res.is_in_scene_map() then
            local c_line = line + 1 > 3 and 1 or line + 1
            this.execute_change_line(c_line)
        else
            common.auto_move(x + 100,y + 100,local_player:cz())
        end
        common.get_interval_change(line..x..y,true)
    end
end

------------------------------------------------------------------------------------
-- [行为] 自动切频道[如果当前频道红 则切换]
------------------------------------------------------------------------------------
actor_ent.auto_change_line_ex = function()
    local line           = actor_unit.get_cur_channel()
    local status         = actor_unit.get_channel_status(line)
    
    if status == 2 or status == -1 then
        -- 取频道状态（0绿，1黄，2红） - 1频道不存在
        -- 获取可切换的频道
        local map_id = actor_unit.map_id()
        if common.is_sleep_any(map_id..'_line',3 * 3600) then
            this.wa_open_channle()
        end
        local best_line = -1
        for i = 1,actor_unit.get_cur_map_channel_num() do
            local line_status = actor_unit.get_channel_status(i)
            if best_line == -1 or best_line > line_status then
                best_line = line_status
            end
        end
        
        if best_line ~= -1 and best_line ~= 2 then
            this.execute_change_line(best_line)
        end
    end
end

------------------------------------------------------------------------------------
-- [行为] 切换到指定频道
--
-- @tparam      number          line        目标频道
------------------------------------------------------------------------------------
actor_ent.execute_change_line = function(line)
    local ret = false
    local change_num = 0
    while decider.is_working() do
        -- 检测是否需要切换频道
        if not this.is_need_change_line(line) then
            ret = true
            break
        end
        -- 切换超时
        if change_num > 1 then
            trace.log_warn(local_player:name(),'-切换频道异常-重启')
            main_ctx:end_game()
            break
        end
        -- 检测打开切换频道页
        if not this.wa_open_channle() then break end
        decider.sleep(5000)
        common.set_sleep(0)
        -- 执行切换
        local result = this.wa_change_line(line)
        change_num   = change_num + 1
        decider.sleep(2000)
    end
    return ret
end

------------------------------------------------------------------------------------
-- [行为] 切换到指定频道,封装行为输出
actor_ent.do_change_line = function(line)
    if this.wu_change_line(line) then
        return true
    end
    return false,'切换频道['..line..']异常'
end

------------------------------------------------------------------------------------
-- [条件] 是否切换频道
--
-- @tparam      number          line        目标频道
-- @treturn     bool                        返回 true[需要切换] false[不需要切换]
------------------------------------------------------------------------------------
actor_ent.is_need_change_line = function(line)
    if actor_unit.get_cur_channel() == line then
        return false,'当前频道已在指定频道['..line..']'
    end
    local map_id = actor_unit.map_id()
    if common.is_sleep_any(map_id..'_line',3 * 3600) then
        this.wa_open_channle()
    end
    if actor_unit.get_cur_map_channel_num() < line then
        return false,'当前最大频道小于'..line
    end
    if actor_unit.get_channel_status(line) == -1 then
        return false,'当前频道['..line..']不存在'
    end
    return true
end

------------------------------------------------------------------------------------
-- [行为] 打开频道切换
------------------------------------------------------------------------------------
actor_ent.open_channle = function()
    local open_num = 0
    while decider.is_working() do
        if actor_unit.is_open_channle_shift_widget() then
            return true
        end
        if open_num > 2 then break end
        decider.sleep(2000)
        if common.is_sleep_any('open_channle',10) then
            common.set_sleep(0)
            actor_unit.open_channle_shift_widget()
            open_num = open_num + 1
            decider.sleep(3000)
        end
    end
    return false,'打开频道切换页-异常'
end

------------------------------------------------------------------------------------
-- [读取] 根据NPC名称获取指定NPC ID
--
-- @tparam      string      name        NPC名称
-- @treturn     number                  返回NPC ID
------------------------------------------------------------------------------------
actor_ent.get_npc_id = function(name)
    local info = this.get_actor_info_by_any(name, 'name', this.GAME_NPC)
    return not table.is_empty(info) and info.id or 0
end

------------------------------------------------------------------------------------
-- [读取] 根据NPC名称获取指定NPC信息
--
-- @tparam      string      name        NPC名称
-- @treturn     table                   返回NPC信息表
------------------------------------------------------------------------------------
actor_ent.get_npc_info = function(name)
    local info = this.get_actor_info_by_any(name, 'name', this.GAME_NPC)
    return info
end

------------------------------------------------------------------------------------
-- [读取] 范围内人数
------------------------------------------------------------------------------------
actor_ent.get_actor_info_by_pos = function(x,y,r)
    local num       = 0
    local x         = x or local_player:cx()
    local y         = y or local_player:cy()
    local r         = r or 800
    local name      = local_player:name()
    local info_list = this.get_actor_info_list(1,'name','cx','cy')
    if not table.is_empty(info_list) then
        for _,v in pairs(info_list) do
            if name ~= v.name and utils.is_inside_radius(v.cx, v.cy, x, y, r) then
                num = num + 1
            end
        end
    end
    return num
end

------------------------------------------------------------------------------------
-- [读取] 获取当前角色ID
------------------------------------------------------------------------------------
actor_ent.get_local_player_id = function()
    local info = this.get_actor_info_list(this.LOCAL_PLAYER,'id')
    return not table.is_empty(info) and info[1].id or 0
end

------------------------------------------------------------------------------------
-- [读取] 获取当前角色职业
------------------------------------------------------------------------------------
actor_ent.get_local_player_job = function()
    local info = this.get_actor_info_list(this.LOCAL_PLAYER,'job')
    return not table.is_empty(info) and info[1].job or -1
end

------------------------------------------------------------------------------------
-- [读取] 获取当前角色名称
------------------------------------------------------------------------------------
actor_ent.get_local_player_name = function()
    local info = this.get_actor_info_list(this.LOCAL_PLAYER,'name')
    return not table.is_empty(info) and info[1].name or ''
end

------------------------------------------------------------------------------------
-- [读取] 获取当前角色坐标
------------------------------------------------------------------------------------
actor_ent.get_local_player_pos = function()
    local info = this.get_actor_info_list(this.LOCAL_PLAYER,'cx','cy','cz')
    return not table.is_empty(info) and table.unpack({ info[1].cx,info[1].cy,info[1].cz }) or table.unpack({ 0,0,0 })
end

------------------------------------------------------------------------------------
-- [读取] 获取当前角色死亡标记
------------------------------------------------------------------------------------
actor_ent.get_local_player_is_dead = function()
    local info = this.get_actor_info_list(this.LOCAL_PLAYER,'is_dead')
    return not table.is_empty(info) and info[1].is_dead or false
end

------------------------------------------------------------------------------------
-- [读取] 获取当前角色战斗状态
------------------------------------------------------------------------------------
actor_ent.get_local_player_is_combat = function()
    local info = this.get_actor_info_list(this.LOCAL_PLAYER,'is_combat')
    return not table.is_empty(info) and info[1].is_combat or false
end

------------------------------------------------------------------------------------
-- [读取] 获取当前角色所有可读信息
------------------------------------------------------------------------------------
actor_ent.get_local_player_info = function()
    return this.get_actor_info_list(this.LOCAL_PLAYER,'obj','id','name','job','class_name','name_id','cx','cy','cz','is_dead','is_combat')
end

------------------------------------------------------------------------------------
-- [读取] 根据环境对象任意字段或多个字段值返回包含对象信息的所有对象表
------------------------------------------------------------------------------------
actor_ent.get_actor_list_by_list_any = function(args, any_key, actor_type)
    actor_type      = actor_type or 0
    local r_tab     = {}
    local list      = actor_unit.list(actor_type)
    for _, obj in ipairs(list) do
        if actor_ctx:init(obj) then
            -- 获取指定属性的值
            local _any = actor_ctx[any_key](actor_ctx)
            
            -- 当前对象 是否需获取的目标
            if common.is_exist_list_arg( args,_any ) then
                local result = {
                    -- 对象指针
                    obj            = obj,
                    -- 对象ID
                    id             = actor_ctx:id(),
                    -- 对象名称
                    name           = actor_ctx:name(),
                    -- 对象职业
                    job            = actor_ctx:job(),
                    -- 对象类型名称
                    class_name     = actor_ctx:class_name(),
                    -- 对象类型ID
                    name_id        = actor_ctx:name_id(),
                    -- 对象坐标x
                    cx             = actor_ctx:cx(),
                    -- 对象坐标y
                    cy             = actor_ctx:cy(),
                    -- 对象坐标z
                    cz             = actor_ctx:cz(),
                    -- 对象是否死亡
                    is_dead        = actor_ctx:is_dead(),
                    -- 是否在战斗
                    is_combat      = actor_ctx:is_combat()
                }
                table.insert( r_tab, result )
            end
        end
    end
    return r_tab
end

------------------------------------------------------------------------------------
-- [读取] 获取所有actor数据 【0 当前角色 1 玩家 2 npc 3 怪物】
--
-- @tparam   number     actor_type        读取类型【0 当前角色 1 玩家 2 npc 3 怪物】
-- @tparam：可变参数 读取的字段
-- @treturn  table                        包含指定目标属性的表
------------------------------------------------------------------------------------
actor_ent.get_actor_info_list = function(actor_type,...)
    actor_type       = actor_type or 0
    local ret        = {}
    local unit_list  = actor_unit.list(actor_type)
    for _,obj in pairs(unit_list) do
        if actor_ctx:init(obj) then
            local result  = {}
            for _,v in pairs({...} ) do
                -- 获取指定属性的值
                result[v] = actor_ctx[v](actor_ctx)
            end
            table.insert(ret,result)
        end
    end
    return ret
end

------------------------------------------------------------------------------------
-- [读取] 根据对象任意字段值返回对象信息表
------------------------------------------------------------------------------------
actor_ent.get_actor_info_by_any = function(args, any_key, actor_type)
    actor_type = actor_type or 0
    local result = {}
    local list   = actor_unit.list(actor_type)
    for _, obj in ipairs(list) do
        if actor_ctx:init(obj) then
            -- 获取指定属性的值
            local _any = actor_ctx[any_key](actor_ctx)
            -- 配对目标值
            if args == _any then
                result = {
                    -- 对象指针
                    obj            = obj,
                    -- 对象ID
                    id             = actor_ctx:id(),
                    -- 对象名称
                    name           = actor_ctx:name(),
                    -- 对象职业
                    job            = actor_ctx:job(),
                    -- 对象类型名称
                    class_name     = actor_ctx:class_name(),
                    -- 对象类型ID
                    name_id        = actor_ctx:name_id(),
                    -- 对象坐标x
                    cx             = actor_ctx:cx(),
                    -- 对象坐标y
                    cy             = actor_ctx:cy(),
                    -- 对象坐标z
                    cz             = actor_ctx:cz(),
                    -- 对象是否死亡
                    is_dead        = actor_ctx:is_dead(),
                    -- 是否在战斗
                    is_combat      = actor_ctx:is_combat()
                }
                break
            end
        end
    end
    return result
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function actor_ent.__tostring()
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
actor_ent.__newindex = function(t, k, v)
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
actor_ent.__index = actor_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function actor_ent:new(args)
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
    return setmetatable(new, actor_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return actor_ent:new()

-------------------------------------------------------------------------------------