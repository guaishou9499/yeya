------------------------------------------------------------------------------------
-- game/entities/mail_ent.lua
--
-- 快捷设置单元
--
-- @module      mail_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local mail_ent = import('game/entities/mail_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class mail_ent
local mail_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME = 'mail_ent module',
    -- 只读模式
    READ_ONLY = false,
}

-- 实例对象
local this = mail_ent
-- 日志模块
local trace = trace
local common = common
-- 决策模块
local decider = decider
local quick_unit = quick_unit
local rawset = rawset
local table = table
local pairs = pairs
local setmetatable = setmetatable
local import = import
---@type item_ent
local item_ent = import('game/entities/item_ent')
---@type skill_ent
local skill_ent = import('game/entities/skill_ent')
---@type skill_res
local skill_res = import('game/resources/skill_res')
---@type quick_res
local quick_res = import('game/resources/quick_res')
---@type ui_ent
local ui_ent = import('game/entities/ui_ent')
------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function mail_ent.super_preload()

    -- 每4个小时运行一次
    this.wi_auto_get_mail = decider.run_interval_wrapper('领取邮件', this.auto_get_mail, 1000 * 3600 * 2)
    this.wc_wi_auto_get_mail = decider.run_condition_wrapper('领取邮件', this.wi_auto_get_mail, function()
        return actor_unit.local_player_level() >= 8
    end)
    -- [行为]领取邮箱物品
    this.wa_get_mail_item = decider.run_action_wrapper('[行为]领取邮箱物品', this.get_mail_item)
end

------------------------------------------------------------------------------------
-- 领取邮箱[前置限制]
mail_ent.auto_get_mail_ex = function()
    if actor_unit.local_player_level() < 8 then
        return
    end
    this.wi_auto_get_mail()
end

------------------------------------------------------------------------------------
-- 领取邮箱
mail_ent.auto_get_mail = function()
    if mail_ent.open_mail_ui() then
        trace.output('检测邮件.')
        common.set_sleep(0)
        decider.sleep(2000)
        local mail_num = mail_unit.get_sys_mail_num()  -- 取数量
        local get_id_list = {}                         -- 领取邮件列表
        for i = 0, mail_num - 1 do
            local sys_mail_id = mail_unit.get_sys_mail_id_byidx(i)
            local get_mail = true
            -- 判断是否领取过
            for j = 1, #get_id_list do
                if sys_mail_id == get_id_list[j] then
                    get_mail = false
                end
            end
            if get_mail then
                get_id_list[#get_id_list + 1] = sys_mail_id
                -- 对话关闭
                common.execute_pass_dialog()
    
                this.wa_get_mail_item(sys_mail_id)
            end
        end
        if mail_unit.has_server_mail(1) then
            -- 对话关闭
            common.execute_pass_dialog()
    
            mail_unit.get_all_server_maill(1)
            decider.sleep(3000)
        end
        ui_ent.close_window_list()
        mail_ent.close_mail_ui()
    end
end

------------------------------------------------------------------------------------
-- [行为] 领取邮箱物品
mail_ent.get_mail_item = function(mail_id)
    if mail_id == 0 then
        return false, '邮箱id为0'
    end
    local list = item_unit.list(0)
    mail_unit.get_sys_mail(mail_id)   -- 这里每次领后 要重新读取 领后里面列表就刷新了
    for j = 1, 5 do
        decider.sleep(3000)
        ui_ent.close_window_list()
        if list ~= item_unit.list(0) then
            return true
        end
    end
    return false, '领取超时'
end

-- 打开邮件窗口
mail_ent.open_mail_ui = function()
    while decider.is_working() do
        if mail_unit.mail_scene_is_open() then
            return true
        end
        common.set_sleep(0)
        decider.sleep(2000)
        mail_unit.open_mail_scene()
        for i = 1, 10 do
            decider.sleep(2000)
            if mail_unit.mail_scene_is_open() then
                return true
            end
        end
    end
    return false
end

-- 关闭邮箱
mail_ent.close_mail_ui = function()
    while decider.is_working() do
        if not mail_unit.mail_scene_is_open() then
            return true
        end
        ui_unit.exit_widget()
        decider.sleep(2000)
        for i = 1, 10 do
            decider.sleep(1000)
            if not mail_unit.mail_scene_is_open() then
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
function mail_ent.__tostring()
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
function mail_ent.__newindex(t, k, v)
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
mail_ent.__index = mail_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function mail_ent:new(args)
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
    return setmetatable(new, mail_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return mail_ent:new()

-------------------------------------------------------------------------------------
