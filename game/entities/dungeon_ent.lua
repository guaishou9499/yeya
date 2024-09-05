------------------------------------------------------------------------------------
-- game/entities/dungeon_ent.lua
--
-- 副本单元
--
-- @module      dungeon_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local dungeon_ent = import('game/entities/dungeon_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class dungeon_ent
local dungeon_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION        = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE    = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME    = '副本单元',
    -- 只读模式
    READ_ONLY      = false,
}

-- 实例对象
local this         = dungeon_ent
-- 日志模块
local trace        = trace
-- 决策模块
local decider      = decider
local common       = common
local dungeon_unit = dungeon_unit
local dungeon_ctx  = dungeon_ctx
local actor_unit   = actor_unit
local item_unit    = item_unit
local ui_unit      = ui_unit
local import       = import
local setmetatable = setmetatable
local pairs        = pairs
local table        = table
local dungeon_res  = import('game/resources/dungeon_res')
local user_set_ent = import('game/entities/user_set_ent')
local map_ent      = import('game/entities/map_ent')
------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function dungeon_ent.super_preload()
    -- [行为] 打开副本窗口
    this.wa_open_dungeon_win  = decider.run_action_wrapper('[行为]打开副本窗口',this.open_dungeon_win)
    -- [行为] 打开一次副本
    this.wo_open_dungeon_win  = decider.run_once_wrapper('[行为]打开副本窗口1',this.wa_open_dungeon_win)
end

------------------------------------------------------------------------------------
-- [行为] 进入副本
------------------------------------------------------------------------------------
dungeon_ent.enter_dungeon = function(dungeon_info)
    if  actor_unit.map_id() == dungeon_info.map_id or dungeon_info.main_map_id == actor_unit.main_map_id() then
        return true
    end
    if dungeon_info.is_enter then
        if this.wa_open_dungeon_win() then
            decider.sleep(3000)
            local game_info = this.get_game_dungeon_info(dungeon_info.dungeon_name,dungeon_info.area_name,true)
            if not table.is_empty(game_info) then
                common.set_sleep(0)
                if not dungeon_unit.has_enter_zone_popup() then
                    -- 对话关闭
                    common.execute_pass_dialog()
                    dungeon_unit.req_dungeon_action( game_info.main_id, game_info.stag_id, dungeon_res.DUNGEON_SEL )
                    decider.sleep(3000)
                    dungeon_unit.req_dungeon_action( game_info.main_id, game_info.stag_id, dungeon_res.DUNGEON_ENT )
                    decider.sleep(3000)
                end
                if dungeon_unit.has_enter_zone_popup() then
                    trace.output('进入副本[',dungeon_info.dun_key,']')
                    dungeon_unit.enter_dungeon()
                end
                decider.sleep(20 * 1000)
                map_ent.waiting_to_map()
            else
                trace.output('没有获取到当前副本的游戏数据或时间已耗完')
            end
        end
    end
end

------------------------------------------------------------------------------------
-- [读取] 获取可做副本信息
------------------------------------------------------------------------------------
dungeon_ent.get_can_do_dungeon_info = function()
    -- 没有副本时间 返回 {},false
    local map_id       = actor_unit.map_id()
    local main_map_id  = actor_unit.main_map_id()
    local dungeon_info = {}
    -- 在副本中 直接执行当前地图副本
    for fb_name,area_l in pairs(dungeon_res.DUNGEON_INFO) do
        for _,area in pairs(area_l) do
            -- 检测当前地图 是否在副本
            if map_id == area.map_id or area.main_map_id and main_map_id == area.main_map_id then
                area.c_dungeon_name = fb_name
                area.is_enter       = false
                area.game_info      = {}
                return area
            end
        end
    end
    -- this.wo_open_dungeon_win()
    -- 遍历开启的副本
    for i = 1, #dungeon_res.DUNGEON_IDX do
        local fb_name = dungeon_res.DUNGEON_IDX[i]
        local area_l  = dungeon_res.DUNGEON_INFO[fb_name]
        local value   = user_set_ent[fb_name]
        -- 用户设置开启副本
        if value and value > 0 then
            if area_l[value] and not table.is_empty(area_l[value]) then
                local game_info = this.get_game_dungeon_info(area_l[value].dungeon_name,area_l[value].area_name,true)
                if not table.is_empty(game_info) and item_unit.get_money_byid(3) >= area_l[value].need_gold and actor_unit.local_player_level() >= area_l[value].need_level then
                    dungeon_info                = area_l[value]
                    dungeon_info.c_dungeon_name = fb_name
                    dungeon_info.is_enter       = true
                    dungeon_info.game_info      = game_info
                    break
                end
            end
        end

    end
    return dungeon_info
end

------------------------------------------------------------------------------------
-- [行为] 打开副本窗口
------------------------------------------------------------------------------------
dungeon_ent.open_dungeon_win = function()
    local ret      = false
    local open_num = 0
    while decider.is_working() do
        if dungeon_unit.is_open_dungeon_widget() then
            ret = true
            break
        end
        
        if open_num > 3 then break end
        -- 对话关闭
        common.execute_pass_dialog()
        open_num = open_num + 1
        trace.output('打开副本窗口-',open_num)
        common.set_sleep(0)
        decider.sleep(2000)
        dungeon_unit.open_dungeon_widget()
        decider.sleep(3000)
    end
    return ret,not ret and '打开副本窗口失败' or '成功'
end

------------------------------------------------------------------------------------
-- [读取] 取游戏中副本信息,根据副本名,副本层
------------------------------------------------------------------------------------
dungeon_ent.get_game_dungeon_info = function(dungeon_name,area_name,can_enter)
    local list   = dungeon_unit.dungeon_list()
    local result = {}
    for _,main_obj in pairs(list) do
        if dungeon_ctx:init(main_obj) then
            if dungeon_name == dungeon_ctx:name() then
                local stage_list = dungeon_unit.dungeon_stage_list(dungeon_ctx:id())
                for _,stage_obj in pairs(stage_list) do
                    if dungeon_ctx:init(stage_obj) then
                        if area_name == dungeon_ctx:name() then
                            local is_result   = true
                            local g_can_enter = dungeon_ctx:can_enter()
                            if can_enter ~= nil then
                                if g_can_enter ~= can_enter then
                                    is_result = false
                                end
                            end
                            if is_result then
                                result.main_id   = dungeon_ctx:main_dungeon_id()
                                result.stag_id   = dungeon_ctx:id()
                                result.can_enter = g_can_enter
                                break
                            end
                        end
                    end
                end
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
function dungeon_ent.__tostring()
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
function dungeon_ent.__newindex(t, k, v)
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
dungeon_ent.__index = dungeon_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function dungeon_ent:new(args)
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
    return setmetatable(new, dungeon_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return dungeon_ent:new()

-------------------------------------------------------------------------------------
