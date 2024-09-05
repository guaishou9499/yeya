------------------------------------------------------------------------------------
-- game/entities/cash_ent.lua
--
-- 实体示例
--
-- @module      cash_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local cash_ent = import('game/entities/cash_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class cash_ent
local cash_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME = 'cash_ent module',
    -- 只读模式
    READ_ONLY = false,
}

-- 实例对象
local this = cash_ent
-- 日志模块
local trace = trace
-- 决策模块
local decider = decider
local pairs = pairs
local table = table
local rawset = rawset
local setmetatable = setmetatable
local import       = import
---@type ui_ent
local ui_ent = import('game/entities/ui_ent')
---@type shop_res
local shop_res = import('game/resources/shop_res')
---@type item_ent
local item_ent = import('game/entities/item_ent')
---@type common
local common = import('game/entities/common')

------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function cash_ent.super_preload()
    -- [行为] 执行购买商城物品
    this.wa_execute_buy_cash_item = decider.run_action_wrapper('[行为]购买商城物品', this.execute_buy_cash_item)
    -- [条件] 判断物品是否能够购买
    --this.can_buy_item = decider.run_action_wrapper('是否能买商城物品', this.can_buy_item)
end

---------------------------------------------------------------------
-- [行为] 购买商城物品
function cash_ent.buy_item()
    local buy_item = shop_res.BUY_CASH_LIST
    local close_ui = false
    for name, v in pairs(buy_item) do
        if cash_ent.can_buy_item(name) then
            local item_info = cash_ent.get_cash_item_info_by_name(v.h_name)
            local max_buy_num = item_info.max_buy_num - item_info.cur_buy_num
            local num = common.calc_num(max_buy_num, item_info.price)
            if num > 0 then
                trace.output('商城买:',name,num,'个')
                common.set_sleep(0)
                -- 对话关闭
                common.execute_pass_dialog()
                close_ui = true
                cash_ent.wa_execute_buy_cash_item(item_info.id, num)
                if creature_unit.has_gacha_scene() then
                    decider.sleep(2000)
                    creature_unit.close_gacha_scene()
                    decider.sleep(3000)
                end
                ui_ent.close_window_list()
            end
        end
    end
    if close_ui then
        decider.sleep(2000)
        ui_unit.exit_widget()
    end
end

---------------------------------------------------------------------
-- [行为] 执行购买商城物品
--
-- @tparam       number      id             物品ID
-- @tparam       number      num            购买数量
-- @usage
-- cash_ent.execute_buy_cash_item(物品ID, 购买数量)
---------------------------------------------------------------------
function cash_ent.execute_buy_cash_item(id, num)
    local money = item_unit.get_money_byid(3)
    if num <= 0 then
        return false, '购买数量为0'
    end
    if not id then
        return false, '购买物品id不存在'
    end
    cash_unit.buy(id, num)
    decider.sleep(1000)
    for i = 1, 30 do
        decider.sleep(1000)
        if money ~= item_unit.get_money_byid(3) then
            return true
        end
    end
    return false, '购买超时'
end

---------------------------------------------------------------------
-- [条件] 判断物品是否能够购买
--
-- @tparam       string      item_name           物品名（汉）
-- @treturn      boolean
-- @usage
-- local bool = cash_ent.can_buy_item(物品名（汉）)
---------------------------------------------------------------------
function cash_ent.can_buy_item(name)
    local item_data = shop_res.BUY_CASH_LIST[name]
    if table.is_empty(item_data) then
        return false, '资源内不存在物品信息'
    end
    if actor_unit.local_player_level() < item_data.level then
        return false, '角色等级小于购买等级'
    end
    -- 获取当前背包数量
    local bag_num  = item_ent.get_item_num_by_name(item_data.h_name,0)
    if bag_num > 90 then
        return false,'数量大于90,不再购买'
    end
    local item_info = cash_ent.get_cash_item_info_by_name(item_data.h_name)
    if table.is_empty(item_info) then
        return false, '商城不存在物品信息'
    end
    local money = item_unit.get_money_byid(3)
    if money < item_info.price then
        return false, '铜钱不足最低购买数量'
    end
    if item_info.cur_buy_num >= item_info.max_buy_num then
        return false, '超过今日可购买量'
    end
    return true
end

------------------------------------------------------------------------------------
-- [读取] 通过名字获取商城物品信息
--
-- @tparam                string                    name            购买物品名
-- @treturn               list                                      返回包含购买物品的所有信息表 包括
-- @tfield[list]          number                    obj             物品实例对象
-- @tfield[list]          number                    res_ptr         物品资源指针
-- @tfield[list]          number                    id              物品ID
-- @tfield[list]          number                    money_type      价格类型
-- @tfield[list]          number                    price           物品单价
-- @tfield[list]          number                    cur_buy_num     已购买数量
-- @tfield[list]          number                    max_buy_num     最大购买数量
-- @tfield[list]          string                    name            物品名称
-- @usage
-- local item_list = cash_ent.get_cash_item_info_by_name('购买物品名')
------------------------------------------------------------------------------------
cash_ent.get_cash_item_info_by_name = function(name)
    local ret_t = {}
    local list = cash_unit.list()
    for i = 1, #list do
        local obj = list[i]
        if cash_ctx:init(obj) then
            if cash_ctx:name() == name then
                ret_t = {
                    -- 物品指针
                    obj = obj,
                    -- 物品资源指针
                    res_ptr = cash_ctx:res_ptr(),
                    -- 物品ID
                    id = cash_ctx:id(),
                    -- 价格类型
                    money_type = cash_ctx:money_type(),
                    -- 单价
                    price = cash_ctx:price(),
                    -- 当前购买量
                    cur_buy_num = cash_ctx:cur_buy_num(),
                    -- 最大购买量
                    max_buy_num = cash_ctx:max_buy_num(),
                    -- 物品名
                    name = name
                }
                break
            end
        end
    end
    return ret_t
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function cash_ent.__tostring()
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
function cash_ent.__newindex(t, k, v)
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
cash_ent.__index = cash_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function cash_ent:new(args)
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
    return setmetatable(new, cash_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return cash_ent:new()

-------------------------------------------------------------------------------------
