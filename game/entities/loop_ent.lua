------------------------------------------------------------------------------------
-- game/entities/loop_ent.lua
--
-- 轮巡功能的整合
--
-- @module      loop_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local loop_ent = import('game/entities/loop_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class loop_ent
local loop_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION          = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE      = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME      = 'loop_ent module',
    -- 只读模式
    READ_ONLY        = false,
}

-- 实例对象
local this           = loop_ent
-- 日志模块
local trace          = trace
-- 决策模块
local decider        = decider
local common         = common
local setmetatable   = setmetatable
local rawset         = rawset
local pairs          = pairs
local import         = import
local login_res      = import('game/resources/login_res')
-- 地图资源
local map_res        = import('game/resources/map_res')
---@type creature_ent
local creature_ent   = import('game/entities/creature_ent')
---@type item_ent
local item_ent       = import('game/entities/item_ent')
---@type actor_ent
local actor_ent      = import('game/entities/actor_ent')
---@type ui_ent
local ui_ent         = import('game/entities/ui_ent')
---@type quick_ent
local quick_ent      = import('game/entities/quick_ent')
---@type equip_ent
local equip_ent      = import('game/entities/equip_ent')
---@type shop_ent
local shop_ent       = import('game/entities/shop_ent')
---@type cash_ent
local cash_ent       = import('game/entities/cash_ent')
---@type mail_ent
local mail_ent       = import('game/entities/mail_ent')
---@type exchange_ent
local exchange_ent   = import('game/entities/exchange_ent')
---@type achieve_ent
local achieve_ent    = import('game/entities/achieve_ent')
---@type collection_ent
local collection_ent = import('game/entities/collection_ent')
---@type sign_ent
local sign_ent       = import('game/entities/sign_ent')
---@type transfer_ent
local transfer_ent   = import('game/entities/transfer_ent')
---@type mastery_ent
local mastery_ent    = import('game/entities/mastery_ent')

------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function loop_ent.super_preload()

end

------------------------------------------------------------------------------------
-- 执行功能整合
function loop_ent.looping(execute_type)
    -- 在过图状态 退出
    if login_res.is_loading_map() then return end
    -- 前置关闭武器熟练UI
    mastery_ent.close_ui()
    -- 检测复活
    actor_ent.rise_man()
    -- 对话关闭
    common.execute_pass_dialog()
    -- 关闭UI
    ui_ent.close_window_list()
    -- 检测剧情地图
    if not map_res.is_in_scene_map() or execute_type == '副本' then
        -- 买药.技能书
        shop_ent.auto_buy_item()
        -- 商城购买
        cash_ent.buy_item()
        --邮件检测
        mail_ent.auto_get_mail_ex()
        -- 转金
        transfer_ent.do_transfer_ent_for_warehouse()
    end
    -- 快捷栏
    quick_ent.auto_set_quick_ex(execute_type)
    -- 检测坐骑 滑翔机 武器图
    creature_ent.auto_used_creature()
    -- 装备佩戴
    equip_ent.ues_equip()
    -- 装备强化
    equip_ent.enhancement_equip()
    -- 添加信念点
    actor_ent.set_stat()
    -- 交易行
    exchange_ent.exchange()
    -- 装备佩戴
    equip_ent.ues_equip()
    -- 收集
    collection_ent.execute_collection()
    -- 检测物品使用
    item_ent.auto_use_item()
    -- 成就领取
    achieve_ent.auto_get_achieve_ex()
    -- 执行签到
    sign_ent.execute_sign()
    -- 学习武器熟练
    mastery_ent.wa_execute_mastery()
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function loop_ent.__tostring()
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
function loop_ent.__newindex(t, k, v)
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
loop_ent.__index = loop_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function loop_ent:new(args)
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
    return setmetatable(new, loop_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return loop_ent:new()

-------------------------------------------------------------------------------------
