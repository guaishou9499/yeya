------------------------------------------------------------------------------------
-- game/entities/ui_ent.lua
--
-- 关闭UI单元
--
-- @module      ui_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local ui_ent = import('game/entities/ui_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class ui_ent
local ui_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION        = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE    = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME    = 'ui_ent module',
    -- 只读模式
    READ_ONLY      = false,
}

-- 实例对象
local this         = ui_ent
-- 日志模块
local trace        = trace
-- 决策模块
local decider      = decider
local common       = common
local pairs        = pairs
local setmetatable = setmetatable
local ui_unit      = ui_unit
local item_unit    = item_unit
local import       = import
local login_unit   = login_unit
local dungeon_unit = dungeon_unit
local ui_res       = import('game/resources/ui_res')
------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function ui_ent.super_preload()
    -- [行为] 只执行一次关闭展示页面
    this.wo_close_show_ui        = decider.run_once_wrapper('关闭展示页', this.close_show_ui)
    -- [行为] 关闭UI、原命令
    this.wa_btn_click_ui_unit    = decider.run_action_wrapper('[行为]ui_unit,关闭UI',ui_unit.btn_click)
    -- [行为] 关闭UI的行为
    this.wa_btn_click            = decider.run_action_wrapper('[行为]关闭UI',this.btn_click)
    -- 等待窗体按钮变化
    local action_name = function(ui_name)
        trace.output('正在关闭(' .. ui_name .. ')中.')
        trace.log_debug('正在关闭(' .. ui_name .. ')中.')
        decider.sleep(2000)
    end
    local cond_func = function(ui_name,btn_id,control_name)
        return  btn_id ~= ui_unit.get_child_control(control_name)
    end
    this.wr_wait_change_ui = decider.run_until_wrapper(action_name, cond_func, 10)
end

------------------------------------------------------------------------------------
-- 关闭窗体UI
ui_ent.close_window_list = function(set_list,exit_action)
    -- this.close_use_fb_stuff_win(true)
    local ui_list = set_list or ui_res.UI_LIST
    for k,v in pairs(ui_list) do
        if type(v.func) == 'function' then
            local close_n = 0
            while decider.is_working() do
                if not v.func() or close_n > 5 then
                    break
                end
                -- 关闭副本窗口
                this.close_dungeon_win()
                trace.output('1.正在关闭UI:',k,'-',close_n)
                close_n = close_n + 1
                decider.sleep(2000)
                if item_unit.has_acquire_popup() then
                    local child_control_id = ui_unit.get_child_control('/Engine/Transient.GameEngine.MPlatformGameInstance.AssetAcquirePopUp_C.WidgetTree.BgBtn')
                    if child_control_id ~= 0 then
                        this.wa_btn_click_ui_unit(child_control_id)
                        decider.sleep(2000)
                    end
                end
            end
        else
            local top_window    = v.TOP_WINDOW
            local child_control = top_window..v.CHILD_CONTROL
            local top_window_id = ui_unit.get_top_window(top_window, true)
            local sel           = v.SEL
            if top_window_id ~= 0 or sel == true then
                local child_control_id = ui_unit.get_child_control(child_control)
                local is_close = true
                if child_control_id ~= 0 and not common.is_sleep_any(k,90) then
                    is_close = false
                end
                if child_control_id ~= 0 and is_close then
                    common.set_sleep(0)
                    trace.output('2.正在关闭UI:',k)
                    if not exit_action then
                        this.wa_btn_click(k,child_control_id,child_control)
                    else
                        ui_unit.btn_click(child_control_id)
                        decider.sleep(2000)
                    end
                end
            end
        end
    end
end

------------------------------------------------------------------------------------
-- 关闭指定UI
ui_ent.close_window_by_name = function(name)
    local close_ui = ui_res.UI_OTHER[name]
    if close_ui then
        local top_window    = close_ui.TOP_WINDOW
        local child_control = top_window..close_ui.CHILD_CONTROL
        local top_window_id = ui_unit.get_top_window(top_window, true)
        local sel           = close_ui.SEL
        if top_window_id ~= 0 or sel == true and common.is_sleep_any(name,90) then
            local child_control_id = ui_unit.get_child_control(child_control)
            if child_control_id ~= 0 then
                -- 关闭副本窗口
                this.close_dungeon_win()
                trace.output('关闭UI:',name)
                this.wa_btn_click_ui_unit(child_control_id)
                decider.sleep(2000)
            end
        end
    end
end

------------------------------------------------------------------------------------
-- 关闭按钮的行为
ui_ent.btn_click = function(ui_name,btn_id,control_name)
    -- 关闭副本窗口
    this.close_dungeon_win()
    ui_unit.btn_click(btn_id)
    decider.sleep(2000)
    if this.wr_wait_change_ui(ui_name,btn_id,control_name) then
        return true
    end
    return false,'关闭('..control_name..')失败'
end

------------------------------------------------------------------------------------
-- 关闭展示页
ui_ent.close_show_ui = function()
    while decider.is_working() do
        if not login_unit.has_front_banner() then
           break
        end
        trace.output('关闭登录广告')
        login_unit.close_front_banner()
        decider.sleep(2000)
    end
    this.close_connect_win()
    -- this.close_window_by_name('展示页')
end

------------------------------------------------------------------------------------
-- 关闭连接失败UI
ui_ent.close_connect_win = function()
    this.close_window_by_name('连接失败')
end

------------------------------------------------------------------------------------
-- 设置转职职业
ui_ent.set_job = function(job_name)
    if job_name == '阿彻' then
        local ui_list  = {
            ['阿彻'] = { TOP_WINDOW = '/Engine/Transient.GameEngine.MPlatformGameInstance.PcClassSceneBp_C',CHILD_CONTROL = '.WidgetTree.PcClassTreeViewWidget.WidgetTree.PcClassWidget16.WidgetTree.Btn' },
        }
        local ui_list1 = {
            ['阿彻1'] = { TOP_WINDOW = '/Engine/Transient.GameEngine.MPlatformGameInstance.PcClassSceneBp_C',CHILD_CONTROL = '.WidgetTree.PcClassTreeViewWidget.WidgetTree.ClassUpgradeBtn' },
        }
        local ui_list2 = {
            ['阿彻2'] = { TOP_WINDOW = '/Engine/Transient.GameEngine.MPlatformGameInstance.SimplePopUp_C',CHILD_CONTROL = '.WidgetTree.ConfirmBtn' },
        }
        local ui_list3 = {
            ['阿彻3'] = { TOP_WINDOW = '/Engine/Transient.GameEngine.MPlatformGameInstance.RootWidget_C',CHILD_CONTROL = '.WidgetTree.TopWidget.WidgetTree.ExitBtn' },
        }
        this.close_window_list(ui_list,true)
        this.close_window_list(ui_list1,true)
        this.close_window_list(ui_list2,true)
        this.close_window_list(ui_list3,true)
    end
end

------------------------------------------------------------------------------------
-- 首次进入游戏跳过动画
ui_ent.exit_first_mov = function()
    local ui_list  = {
        ['首次进入1'] = { TOP_WINDOW = '/Engine/Transient.GameEngine.MPlatformGameInstance.IntroBgMovieBp_C',CHILD_CONTROL = '.WidgetTree.SkipBtn' },
    }
    local ui_list1 = {
        ['首次进入2'] = { TOP_WINDOW = '/Engine/Transient.GameEngine.MPlatformGameInstance.SimpleSubContentPopup_C',CHILD_CONTROL = '.WidgetTree.ConfirmBtn' },
    }
    -- 关闭展示页
    this.close_show_ui()
    this.close_window_list(ui_list,true)
    this.close_window_list(ui_list1,true)
end

------------------------------------------------------------------------------------
-- 关闭使用补充石
ui_ent.close_use_fb_stuff_win = function(is_CancelBtn)
    if is_CancelBtn then
        local child_control_id = ui_unit.get_child_control('/Engine/Transient.GameEngine.MPlatformGameInstance.DungeonTimeChargePopUp_C.WidgetTree.CancelBtn')
        if child_control_id ~= 0 then
            decider.sleep(2000)
            this.wa_btn_click_ui_unit(child_control_id)
            decider.sleep(2000)
        end
        return
    end
    local child_control_id = ui_unit.get_child_control('/Engine/Transient.GameEngine.MPlatformGameInstance.DungeonTimeChargePopUp_C.WidgetTree.ConfirmBtn')

    if child_control_id ~= 0 then
        decider.sleep(2000)
        this.wa_btn_click_ui_unit(child_control_id)
        decider.sleep(2000)
    end
end


------------------------------------------------------------------------------------
-- [行为] 关闭副本窗口
------------------------------------------------------------------------------------
ui_ent.close_dungeon_win = function()
    local ret       = false
    local close_num = 0
    while decider.is_working() do
        if not dungeon_unit.is_open_dungeon_widget() then
            ret = true
            break
        end
        if close_num > 3 then break end
        close_num = close_num + 1
        trace.output('关闭副本窗口-',close_num)
        common.set_sleep(0)
        decider.sleep(2000)
        ui_unit.exit_widget()
        decider.sleep(3000)
    end
    return ret,not ret and '关闭副本窗口失败' or '成功'
end


-- 关闭物品
------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function ui_ent.__tostring()
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
function ui_ent.__newindex(t, k, v)
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
ui_ent.__index = ui_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function ui_ent:new(args)
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
    return setmetatable(new, ui_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return ui_ent:new()

-------------------------------------------------------------------------------------
