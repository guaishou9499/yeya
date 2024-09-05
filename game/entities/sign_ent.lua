------------------------------------------------------------------------------------
-- game/entities/sign_ent.lua
--
-- 签到单元
--
-- @module      sign_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local sign_ent = import('game/entities/sign_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class sign_ent
local sign_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION                 = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE             = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME             = 'sign_ent module',
    -- 只读模式
    READ_ONLY               = false,
}

-- 实例对象
local this         = sign_ent
-- 日志模块
local trace        = trace
-- 决策模块
local decider      = decider
local common       = common
local sign_unit    = sign_unit
local actor_unit   = actor_unit
local setmetatable = setmetatable
local pairs        = pairs
local rawset       = rawset
local table        = table
local import       = import

local ui_ent       = import('game/entities/ui_ent')
------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function sign_ent.super_preload()
    -- [行为]打开签到窗口
    -- this.wa_open_win = decider.run_action_wrapper('[行为]打开签到窗口',this.open_win)
end

------------------------------------------------------------------------------------
-- [行为] 打开签到窗口
sign_ent.open_win = function()
    local open_num = 0
    while decider.is_working() do
        if sign_unit.is_open_event_popup() then
            return true
        end
        if open_num > 2 then break end
        decider.sleep(2000)
        if common.is_sleep_any('open_win_sign',10) then
            common.set_sleep(0)
            -- 对话关闭
            common.execute_pass_dialog()
    
            sign_unit.open_event_popup()
            open_num = open_num + 1
            decider.sleep(2000)
        end
    end
    return false,'打开签到窗口-异常'
end

------------------------------------------------------------------------------------
-- [行为] 关闭签到窗口
sign_ent.close_win = function()
    local open_num = 0
    while decider.is_working() do
        if not sign_unit.is_open_event_popup() then
            return true
        end
        if open_num > 2 then break end
        decider.sleep(2000)
        if common.is_sleep_any('close_win_sign',10) then
            common.set_sleep(0)
            sign_unit.close_event_popup()
            open_num = open_num + 1
            decider.sleep(2000)
        end
    end
    return false,'关闭签到窗口-异常'
end

------------------------------------------------------------------------------------
-- [行为] 执行签到
sign_ent.execute_sign = function()
    if actor_unit.local_player_level() < 15 then return end
    
    if not common.is_sleep_any('execute_sign',3600) then
        return
    end
    local sign_list = this.get_sign_info_list()
    if not table.is_empty(sign_list) then
        for _,v in pairs(sign_list) do
            if this.open_win() then
                trace.output('领取',v.str)
                -- 对话关闭
                common.execute_pass_dialog()
    
                local id         = v.id
                local reward_idx = v.reward_idx
                local func       = v.func
                if reward_idx then
                    func(id,reward_idx)
                else
                    func(id)
                end
                decider.sleep(2000)
                ui_ent.close_window_list()
            end
        end
        this.close_win()
    end
end

------------------------------------------------------------------------------------
-- [读取] 获取可签到的数据
sign_ent.get_sign_info_list = function()
    local sign_list  = {}
    -- 取有可领奖励ID列表
    local event_list = sign_unit.get_tar_event_list()
    for i,id in pairs(event_list) do
        -- id取有奖励序号列表
        local reward_idx_list = sign_unit.get_reward_idx_list(id, i)
        for _,reward_idx in pairs(reward_idx_list) do
            table.insert(sign_list,{ id = id,reward_idx = reward_idx,func = sign_unit.get_event_reward,str = '奖励' })
        end
    end
    -- 取得可签到ID列表
    local can_receive_list = sign_unit.get_can_receive_list()
    for _,id in pairs(can_receive_list) do
        table.insert(sign_list,{ id = id,func = sign_unit.get_attendance_reward,str = '签到' })
    end
    return sign_list
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function sign_ent.__tostring()
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
function sign_ent.__newindex(t, k, v)
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
sign_ent.__index = sign_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function sign_ent:new(args)
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
    return setmetatable(new, sign_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return sign_ent:new()

-------------------------------------------------------------------------------------
