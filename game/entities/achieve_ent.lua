------------------------------------------------------------------------------------
-- game/entities/achieve_ent.lua
--
-- 实体示例
--
-- @module      achieve_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local achieve_ent = import('game/entities/achieve_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class achieve_ent
local achieve_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION                 = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE             = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME             = 'achieve_ent module',
    -- 只读模式
    READ_ONLY               = false,
}

-- 实例对象
local this         = achieve_ent
-- 日志模块
local trace        = trace
-- 决策模块
local decider      = decider
local dungeon_unit = dungeon_unit
local dungeon_ctx  = dungeon_ctx
local setmetatable = setmetatable
local pairs        = pairs
local common       = common
---@type ui_ent
local ui_ent       = import('game/entities/ui_ent')
------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function achieve_ent.super_preload()
    -- 每4个小时运行一次
    this.wi_auto_get_achieve = decider.run_interval_wrapper('领取成就', this.auto_get_achieve, 1000 * 3600 * 2)
end

------------------------------------------------------------------------------------
-- 领取邮箱[前置限制]
achieve_ent.auto_get_achieve_ex = function()
    if actor_unit.local_player_level() < 20 then
        return
    end
    this.wi_auto_get_achieve()
end

------------------------------------------------------------------------------------
-- 领取邮箱
achieve_ent.auto_get_achieve = function()
    if achieve_ent.open_achieve_ui() then
        trace.output('检测成就.')
        common.set_sleep(0)
        decider.sleep(2000)
        local list = achieve_unit.get_can_receive_id_list()
        for i = 1, #list do
            -- 对话关闭
            common.execute_pass_dialog()
            achieve_unit.get_reward(list[i])
            decider.sleep(2000)
            ui_ent.close_window_list()
        end
        ui_ent.close_window_list()
        achieve_ent.close_achieve_ui()
    end
end

------------------------------------------------------------------------------------
-- 打开成就窗口
achieve_ent.open_achieve_ui = function()
    while decider.is_working() do
        if achieve_unit.is_open_achieve_scene() then
            return true
        end
        common.set_sleep(0)
        -- 对话关闭
        common.execute_pass_dialog()
        achieve_unit.open_achieve_scene()
        for i = 1, 30 do
            if achieve_unit.is_open_achieve_scene() then
                return true
            end
            decider.sleep(500)
        end
        decider.sleep(2000)
    end
    return false
end

------------------------------------------------------------------------------------
-- 关闭成就窗口
achieve_ent.close_achieve_ui = function()
    while decider.is_working() do
        if not achieve_unit.is_open_achieve_scene() then
            return true
        end
        ui_unit.exit_widget()
        decider.sleep(2000)
        for i = 1, 30 do
            decider.sleep(1000)
            if not achieve_unit.is_open_achieve_scene() then
                return true
            end
        end
    end
    return false
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function achieve_ent.__tostring()
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
function achieve_ent.__newindex(t, k, v)
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
achieve_ent.__index = achieve_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function achieve_ent:new(args)
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
    return setmetatable(new, achieve_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return achieve_ent:new()

-------------------------------------------------------------------------------------
