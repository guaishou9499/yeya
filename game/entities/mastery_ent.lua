------------------------------------------------------------------------------------
-- game/entities/mastery_ent.lua
--
-- 实体示例
--
-- @module      mastery_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local mastery_ent = import('game/entities/mastery_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class mastery_ent
local mastery_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION                 = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE             = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME             = 'mastery_ent module',
    -- 只读模式
    READ_ONLY               = false,
}

-- 实例对象
local this         = mastery_ent
-- 日志模块
local trace        = trace
-- 决策模块
local decider      = decider
local setmetatable = setmetatable
local pairs        = pairs
local rawset       = rawset
local table        = table
local import       = import
local item_unit    = item_unit
local mastery_unit = mastery_unit
local mastery_ctx  = mastery_ctx
local common       = common
local ui_ent       = import('game/entities/ui_ent')
local ui_unit      = ui_unit
local actor_unit   = actor_unit
------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function mastery_ent.super_preload()
    local cond_func = function()
        local info  = this.get_can_study_mastery_info()
        if table.is_empty(info) then
            return false
        end
        if actor_unit.local_player_level() < 31 then return false end
        return true
    end
    -- [行为] 执行学习武器熟练
    this.wa_execute_mastery  = decider.run_action_wrapper('[行为]执行学习武器熟练', this.execute_mastery,cond_func)
    this.wa_study            = decider.run_action_wrapper('[行为]正学习武器熟练',mastery_unit.study)
end

------------------------------------------------------------------------------------
-- [行为] 执行学习武器熟练
------------------------------------------------------------------------------------
mastery_ent.execute_mastery = function()
    local info = this.get_can_study_mastery_info()
    if table.is_empty(info) then
        return false,'没有可学数据'
    end
    if not this.is_open_mastery_popup() then
        return false,'学习窗未打开'
    end
    for _,id in pairs(info) do
        if not mastery_unit.mastery_is_study(id) then
            trace.output('学习武器熟练')
            this.wa_study(id)
            decider.sleep(3000)
        end
    end
    this.close_ui()
    info = this.get_can_study_mastery_info()
    if table.is_empty(info) then
        return true
    end
    return false,'学习熟练失败'
end

------------------------------------------------------------------------------------
-- [行为] 关闭学习/熟练窗口
------------------------------------------------------------------------------------
mastery_ent.close_ui = function()
    if mastery_unit.is_open_mastery_popup() then
        trace.output('关闭学习武器窗口')
        decider.sleep(3000)
        mastery_unit.close_mastery_popup()
        decider.sleep(3000)
    end
    if mastery_unit.is_open_mastery_scene() then
        trace.output('关闭学习武器熟练窗口')
        decider.sleep(3000)
        ui_unit.exit_widget()
        decider.sleep(3000)
    end
end

------------------------------------------------------------------------------------
-- [条件] 是否打开熟练
------------------------------------------------------------------------------------
mastery_ent.is_open_mastery_scene = function()
    local ret      = false
    local open_num = 0
    while decider.is_working() do
        if mastery_unit.is_open_mastery_scene() then
            ret = true
            break
        end
        if open_num > 2 then break end
        common.set_sleep(0)
        ui_ent.close_window_list()
        common.execute_pass_dialog()
        -- 打开UI
        mastery_unit.open_mastery_scene()
        open_num = open_num + 1
        decider.sleep(3000)
    end
    return ret,not ret and '打开熟练UI失败' or ''
end

------------------------------------------------------------------------------------
-- [条件] 是否打开学习窗
------------------------------------------------------------------------------------
mastery_ent.is_open_mastery_popup = function()
    local ret      = false
    local open_num = 0
    while decider.is_working() do
        if not this.is_open_mastery_scene() then
            -- 未在熟练UI打开学习窗
            if mastery_unit.is_open_mastery_popup() then
                -- 关闭
                mastery_unit.close_mastery_popup()
            end
            break
        end
        if mastery_unit.is_open_mastery_popup() then
            ret = true
            break
        end
        if open_num > 2 then break end
        common.set_sleep(0)
        common.execute_pass_dialog()
        mastery_unit.open_mastery_popup()
        open_num = open_num + 1
        decider.sleep(3000)
    end
    return ret,not ret and '打开学习窗失败' or ''
end

------------------------------------------------------------------------------------
-- [读取] 获取可学熟练ID 列表
------------------------------------------------------------------------------------
mastery_ent.get_can_study_mastery_info = function()
    -- 保存返回结果
    local ret           = {}
    -- 当前熟练登记
    local mastery_level = mastery_unit.get_mastery_level()
    local list          = mastery_unit.list()
    -- 统计需要消耗的铜钱量
    local total_money   = 0
    for _,obj in pairs(list) do
        if mastery_ctx:init(obj) then
            if not mastery_ctx:is_study() then
                local now_level      =  mastery_ctx:level()
                if now_level <= mastery_level then
                    local money      = item_unit.get_money_byid(3)
                    local need_money = 50000 + ( now_level - 1 ) * 10000
                    if need_money <= money - total_money then
                        table.insert(ret, mastery_ctx:id())
                        total_money  = total_money + need_money
                    end
                end
            end
        end
    end
    return ret
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function mastery_ent.__tostring()
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
function mastery_ent.__newindex(t, k, v)
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
mastery_ent.__index = mastery_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function mastery_ent:new(args)
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
    return setmetatable(new, mastery_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return mastery_ent:new()

-------------------------------------------------------------------------------------
