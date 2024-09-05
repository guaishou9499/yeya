------------------------------------------------------------------------------------
-- game/entities/exchange_ent.lua
--
-- 关闭UI单元
--
-- @module      exchange_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local exchange_ent = import('game/entities/exchange_ent')
------------------------------------------------------------------------------------
local main_ctx  = main_ctx
-- 模块定义
---@class exchange_ent
local exchange_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME = 'exchange_ent module',
    -- 只读模式
    READ_ONLY = false,
    -- 临时物价
    TEMPORARY_PRICE_PATH       = '夜鸦:数据记录:服务器:' .. main_ctx:c_server_name() .. ':共享:临时物价:',
    -- 临时物价超时
    TEMPORARY_PRICE_TIME_OUT   = 6 * 3600,
}

-- 实例对象
local this = exchange_ent
-- 日志模块
local trace = trace
-- 决策模块
local decider = decider
local common = common
local pairs = pairs
local os    = os
local setmetatable = setmetatable
local ui_unit = ui_unit
local import = import
---@type item_ent
local item_ent = import('game/entities/item_ent')
---@type item_res
local item_res = import('game/resources/item_res')
---@type redis_ent
local redis_ent = import('game/entities/redis_ent')

------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function exchange_ent.super_preload()
    exchange_ent.wi_exchange = decider.run_interval_wrapper('交易行模块', this.exchange, 3600 * 1000)
    exchange_ent.wi_settlement = decider.run_interval_wrapper('结算', this.settlement, 120 * 1000)
    exchange_ent.wa_get_item_info_up_item = decider.run_action_wrapper('上架物品', this.get_item_info_up_item)
    exchange_ent.wa_down_item = decider.run_action_wrapper('下架物品', this.down_item)
    exchange_ent.wa_calcul_gold = decider.run_action_wrapper('交易行结算', this.calcul_gold)
end

--------------------------------------------------------------------------------
-- [行为] 交易行通用功能(外部使用)
--
-- @tparam      table       res_id      购买物品res_id(不购买物品不用设置参数)
-- @tparam      integer     level       物品等级(不购买物品不用设置参数)
-- @treturn
-- @usage
-- exchange_ent.exchange(res_id,物品等级)
--------------------------------------------------------------------------------
exchange_ent.exchange = function()
    if actor_unit.local_player_level() < 35 then
        return false
    end
    if common.is_sleep_any('exchange',3600 * 1) then
        local exchange_func = {
            { func_name = '下架物品', func = function()
                exchange_ent.take_down()
            end },
            { func_name = '上架物品', func = function()
                exchange_ent.up_item()
            end },
            { func_name = '交易行结算', func = function()
                exchange_ent.settlement()
            end },
        }
        --执行对应方法
        for i = 1, #exchange_func do
            exchange_func[i].func()
        end
        exchange_ent.close_exchange_ui()
    end
end

-- 打开交易行窗口
exchange_ent.open_exchange_ui = function()
    while decider.is_working() do
        if exchange_unit.exchange_is_open() then
            return true
        end
        common.set_sleep(0)
        exchange_unit.open_exchange()
        decider.sleep(2000)
        for i = 1, 30 do
            if exchange_unit.exchange_is_open() then
                return true
            end
            decider.sleep(500)
        end
        decider.sleep(2000)
    end
    return false
end

-- 关闭交易行窗口
exchange_ent.close_exchange_ui = function()
    while decider.is_working() do
        if not exchange_unit.exchange_is_open() then
            return true
        end
        common.set_sleep(0)
        ui_unit.exit_widget()
        decider.sleep(2000)
        for i = 1, 30 do
            if not exchange_unit.exchange_is_open() then
                return true
            end
            decider.sleep(500)
        end
        decider.sleep(2000)
    end
    return false
end

------------------------------------------------------------------------------------
-- [行为] 上架物品
--
-- @tparam      table       item_info       物品信息
-- @tparam      integer     level           物品等级
-- @treturn     boolean
-- @usage
-- exchange_ent.up_item(物品信息,物品等级)
------------------------------------------------------------------------------------
exchange_ent.up_item = function()
    --获取背包物品
    local bag_item_info = item_ent.get_item_info()
    for i = 1, #bag_item_info do
        --通过是否非绑定物品，出售数量大于指定数量判断是否出售
        if item_res.ITEM_LIST[bag_item_info[i].name] and not item_res.is_bind_by_name(bag_item_info[i].name) then
            exchange_ent.wa_get_item_info_up_item(bag_item_info[i], item_res.ITEM_LIST[bag_item_info[i].name].enhancement_type, 0)
        end
    end
end

------------------------------------------------------------------------------------
-- [行为] 物品下架
--
-- @tparam      integer     id              物品ID
-- @treturn     boolean
-- @usage
-- exchange_ent.down_item(物品ID)
------------------------------------------------------------------------------------
exchange_ent.down_item = function(id)
    exchange_unit.down_item(id)
    for i = 1, 8 do
        decider.sleep(2000)
        local now_item_info = item_ent.get_item_info_by_id(id)
        if not table_is_empty(now_item_info) then
            return true
        end
    end
    return false, '下架超时'
end

------------------------------------------------------------------------------------
-- [行为] 通过物品信息上架物品
--
-- @tparam      table       item_info       物品信息
-- @tparam      boolean     is_equip        是否装备
-- @tparam      integer     level           物品等级
-- @treturn     boolean
-- @usage
-- exchange_ent.get_item_info_up_item(物品信息,是否装备,物品等级)
------------------------------------------------------------------------------------
function exchange_ent.get_item_info_up_item(item_info, is_equip, level)
    --获取物品交易行信息
    local sell_price = exchange_ent.get_temporary_price(item_info.res_data.c_name)
    if sell_price == 0 then
        local exchange_item_info = exchange_ent.get_item_min_price(item_info.res_id, is_equip, level)
        if table_is_empty(exchange_item_info) then
            return false, '交易行没有' .. item_info.name .. '交易信息'
        end
        sell_price = exchange_item_info[1].price
        --交易行出售价格第一个与第三个相差过30%选择均价出售
        if exchange_item_info[5] and exchange_item_info[5].price / sell_price > 1.3 then
            sell_price = (exchange_item_info[1].price + exchange_item_info[5].price) / 2
        end
        exchange_ent.set_temporary_price(item_info.res_data.c_name,item_info.res_data.h_name,sell_price)
    end
    local up_gold = sell_price * item_info.num
    if up_gold < 10 then
        return false, item_info.res_data.c_name .. '上架金额小于10'
    end
    if up_gold * 10 > item_unit.get_money_byid(3) then
        return false, item_info.res_data.c_name .. '铜钱不够上架所需金额' .. up_gold * 10
    end
    up_gold = tonumber(string.format('%0.0f', up_gold + 0.5))
    exchange_unit.up_item(item_info.id, up_gold, item_info.num)
    for i = 1, 8 do
        decider.sleep(2000)
        local now_item_info = item_ent.get_item_info_by_id(item_info.id)
        if table_is_empty(now_item_info) then
            return true, '上架' .. item_info.name .. '成功'
        end
    end
    return false, '上架' .. item_info.name .. '超时'
end

------------------------------------------------------------------------------------
-- [行为] 结算交易行
--
-- @treturn     boolean
-- @usage
-- exchange_ent.calcul_gold()
------------------------------------------------------------------------------------
function exchange_ent.calcul_gold()
    --通过交易金币判断是否结算成功
    local my_money = item_unit.get_money_byid(1)
    exchange_unit.batch_collect()
    for i = 1, 8 do
        decider.sleep(2000)
        if my_money ~= item_unit.get_money_byid(1) then
            return true, '结算成功'
        end
    end
    return false, '结算超时'
end

------------------------------------------------------------------------------------
-- [条件] 判断是否可结算
--
-- @treturn     boolean
-- @usage
-- exchange_ent.settlement()
------------------------------------------------------------------------------------
exchange_ent.settlement = function()
    local ret_b = false
    exchange_ent.open_exchange_ui()
    --是否可结算
    exchange_unit.change_exchange_page(1)
    decider.sleep(2000)
    if exchange_unit.has_batch_collect() then
        ret_b = exchange_ent.wa_calcul_gold()
    end
    return ret_b
end

------------------------------------------------------------------------------------
-- [条件] 判断物品是否需要下架
--
-- @treturn     boolean
-- @usage
-- exchange_ent.take_down()
------------------------------------------------------------------------------------
exchange_ent.take_down = function()
    local ret_b = false
    exchange_ent.open_exchange_ui()
    --获取上架物品信息
    exchange_unit.change_exchange_page(1)
    decider.sleep(2000)
    local sell_list = exchange_ent.get_sell_list()
    for i = 1, #sell_list do
        local down_item = false
        local ret1 = sell_list[i]
        if ret1.status == 0 then
            --通过上架时间判断是否下架
            if os.time() >= ret1.up_time / 1000 + 24 * 2 * 60 * 60 then
                down_item = true
            end
        end
        if down_item then
            ret_b = exchange_ent.wa_down_item(ret1.id)
        end
    end
    return ret_b
end

------------------------------------------------------------------------------------
-- [读取] 获取物品价格信息表
--
-- @tparam      integer     res_id              物品信息
-- @tparam      integer     level               物品等级
-- @treturn     t
-- @tfield[t]   integer     obj                 物品实例对象
-- @tfield[t]   integer     id                  物品ID
-- @tfield[t]   integer     sale_player_id      卖家Id
-- @tfield[t]   integer     res_ptr             物品资源指针
-- @tfield[t]   integer     total_price         总价
-- @tfield[t]   integer     num                 物品数量
-- @tfield[t]   integer     price               单价
-- @tfield[t]   integer     expire_time         到期时间
-- @usage
-- local info = exchange_ent.get_item_min_price(物品信息,物品等级)
-- print_r(info)
------------------------------------------------------------------------------------
exchange_ent.get_item_min_price = function(res_id, is_equip, level)
    local exchange_item_info = {}
    exchange_ent.open_exchange_ui()
    decider.sleep(1000)
    level = level or 0
    exchange_unit.change_exchange_page(0)
    decider.sleep(2000)
    if is_equip then
        --搜索物品
        exchange_unit.search_equip(res_id)
        decider.sleep(2000)
        --打开物品详情
        local num = exchange_unit.get_equip_num_by_resid(res_id, level)
        decider.sleep(2000)
        if num > 0 then
            exchange_item_info = exchange_ent.exchange_item_info()
        end
    else
        exchange_unit.search_item(res_id, 0)
        decider.sleep(2000)
        exchange_item_info = exchange_ent.exchange_item_info()
    end
    return exchange_item_info
end

------------------------------------------------------------------------------------
-- [读取] 获取交易行当前页面的物品信息
--
-- @treturn     t
-- @tfield[t]    integer    obj                 物品实例对象
-- @tfield[t]    integer    id                  物品ID
-- @tfield[t]    integer    sale_player_id      卖家Id
-- @tfield[t]    integer    res_ptr             物品资源指针
-- @tfield[t]    integer    total_price         总价
-- @tfield[t]    integer    num                 物品数量
-- @tfield[t]    integer    price               单价
-- @tfield[t]    integer    expire_time         到期时间
-- @usage
-- local info = exchange_ent.exchange_item_info()
-- print_r(info)
------------------------------------------------------------------------------------
function exchange_ent.exchange_item_info()
    local exchange_item_info = {}

    --local list = exchange_unit.list(0)
    --xxmsg('搜索物品数量:'..#list)
    --for i = 1, #list do
    --    local obj = list[i]
    --    if exchange_ctx:init(obj) then
    --        xxmsg(string.format('obj:%16X   id:%16X    total_price:%08d    num:%08d   type:%02d, name:%s',
    --                obj,
    --                exchange_ctx:id(),
    --                exchange_ctx:total_price(),
    --                exchange_ctx:num(),
    --                exchange_ctx:type(),
    --                exchange_ctx:name()
    --        ))
    --    end
    --end

    -- 0 搜索购买列表
    local list = exchange_unit.list(0)
    for i = 1, #list do
        local obj = list[i]
        if exchange_ctx:init(obj) then
            local tem_t = {
                obj = obj,
                id = exchange_ctx:id(),
                total_price = exchange_ctx:total_price(),
                num = exchange_ctx:num(),
                type = exchange_ctx:type(),
                name = exchange_ctx:name(),
            }
            tem_t.price = tem_t.total_price / tem_t.num
            table.insert(exchange_item_info, tem_t)
        end
    end
    --排序价格
    table.sort(exchange_item_info, function(a, b)
        return a.price < b.price
    end)
    return exchange_item_info
end

------------------------------------------------------------------------------------
-- [读取] 获取正在出售的信息
--
-- @treturn     t
-- @tfield[t]    integer    obj                 物品实例对象
-- @tfield[t]    integer    id                  物品ID
-- @tfield[t]    integer    sale_player_id      卖家Id
-- @tfield[t]    integer    res_ptr             物品资源指针
-- @tfield[t]    integer    total_price         总价
-- @tfield[t]    integer    num                 物品数量
-- @tfield[t]    integer    price               单价
-- @tfield[t]    integer    expire_time         到期时间
-- @usage
-- local info = exchange_ent.get_sell_list()
-- print_r(info)
------------------------------------------------------------------------------------
exchange_ent.get_sell_list = function()
    local ret = {}
    -- 自己出售列表
    local list = exchange_unit.list(1)
    for i = 1, #list do
        local obj = list[i]
        if exchange_ctx:init(obj) then
            local tmp_t = {
                obj = obj,
                id = exchange_ctx:id(),
                sale_price = exchange_ctx:sale_price(),
                num = exchange_ctx:num(),
                type = exchange_ctx:type(),
                status = exchange_ctx:status(), -- 0 出售中，1已出售未结算
                up_time = exchange_ctx:up_time(), -- 该时间为毫秒 要除1000才对应系统时间
                name = exchange_ctx:name()
            }
            table.insert(ret, tmp_t)
        end
    end
    return ret
end
--
------------------------------------------------------------------------------------
-- 读取临时物价_redis
------------------------------------------------------------------------------------
exchange_ent.get_temporary_price = function(c_name)
    local path                   = this.TEMPORARY_PRICE_PATH
    local idx,idx2,data,is_exist = redis_ent.get_idx_in_redis_table_list_path(c_name,'c_name',path,this.TEMPORARY_PRICE_TIME_OUT,5,50)
    if is_exist and data and data[idx2] then
        return data[idx2].price
    end
    return 0
end

------------------------------------------------------------------------------------
-- 写入临时物价_redis
------------------------------------------------------------------------------------
exchange_ent.set_temporary_price = function(c_name, h_name, price)
    local path     = this.TEMPORARY_PRICE_PATH
    local data_w   = {
        ['c_name'] = c_name,
        ['price']  = price,
        ['h_name'] = h_name,
        ['time']   = os.time(),
        ['data']   = os.date("%Y-%m-%d %H:%M:%S",os.time())
    }
    redis_ent.set_data_in_redis_table_list_path(data_w,c_name,'c_name',path,this.TEMPORARY_PRICE_TIME_OUT,5,50)
end
------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function exchange_ent.__tostring()
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
function exchange_ent.__newindex(t, k, v)
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
exchange_ent.__index = exchange_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function exchange_ent:new(args)
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
    return setmetatable(new, exchange_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return exchange_ent:new()

-------------------------------------------------------------------------------------
