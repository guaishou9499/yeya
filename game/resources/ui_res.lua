------------------------------------------------------------------------------------
-- game/resources/ui_res.lua
--
--
--
-- @module      ui_res
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-03-22
-- @copyright   2023
-- @usage
-- local ui_res = import('game/resources/ui_res')
------------------------------------------------------------------------------------
local item_unit = item_unit
local ui_unit   = ui_unit
local ui_res = {
    -- 调用关闭所有存在的UI
    UI_LIST = {
        ['使用箱子'] = { TOP_WINDOW = '/Engine/Transient.GameEngine.MPlatformGameInstance.AssetAcquirePopUp_C',CHILD_CONTROL = '.WidgetTree.BgBtn',func =
        function()
            if item_unit.has_acquire_popup() then
                item_unit.close_acquire_popup()
                return true
            end
            return false
        end },
        ['弹窗确认'] = { TOP_WINDOW = '/Engine/Transient.GameEngine.MPlatformGameInstance.SimplePopUp_C',CHILD_CONTROL = '.WidgetTree.ConfirmBtn' },
        ['30级购买UI'] = { TOP_WINDOW = '/Engine/Transient.GameEngine.MPlatformGameInstance.PopupStoreGoodsPopupWidget_C',CHILD_CONTROL = '.WidgetTree.CancelBtn',SEL = true },
    },
    -- 调用关闭
    UI_OTHER = {
        ['展示页'] = { TOP_WINDOW = '/Engine/Transient.GameEngine.MPlatformGameInstance.RootWidget_C',CHILD_CONTROL = '.WidgetTree.MFrontBanner.WidgetTree.CloseBtn' },
        ['连接失败'] = { TOP_WINDOW = '/Engine/Transient.GameEngine.MPlatformGameInstance.SimplePopUp_C',CHILD_CONTROL = '.WidgetTree.ConfirmBtn' },
        ['地图'] = { TOP_WINDOW = '/Engine/Transient.GameEngine.MPlatformGameInstance.RootWidget_C',CHILD_CONTROL = '.WidgetTree.TopWidget.WidgetTree.ExitBtn' },
    }
}

-- 自身模块
local this = ui_res

-------------------------------------------------------------------------------------
-- 返回实例对象
-- 
-- @export
return ui_res

-------------------------------------------------------------------------------------