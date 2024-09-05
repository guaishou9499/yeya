------------------------------------------------------------------------------------
-- game/entities/transfer_ent.lua
--
-- 实体示例
--
-- @module      transfer_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local transfer_ent = import('game/entities/transfer_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class transfer_ent
local transfer_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME = 'transfer_ent module',
    -- 只读模式
    READ_ONLY = false,

    PATH1 = '夜鸦:内置数据(不可随意设置):服务器:' .. main_ctx:c_server_name() .. ':转金:仓库:', --仓库记录路径
    PATH2 = '夜鸦:内置数据(不可随意设置):服务器:' .. main_ctx:c_server_name() .. ':转金:转移:', --转移记录路径
    SALE_RECORD_PATH = '夜鸦:内置数据(不可随意设置):服务器:' .. main_ctx:c_server_name() .. ':出售信息:',
    use_time = 0,
    jiesuan_time = 0,
    -- 出售记录最大批次
    SALE_MAX_LOT = 30,
    -- 出售记录每批最大记录
    SALE_MAX_DATA_EVERY_LOT = 50,
}

-- 实例对象
local this = transfer_ent
-- 日志模块
local trace = trace
-- 决策模块
local decider = decider
local pairs = pairs
local table = table
local rawset = rawset
local setmetatable = setmetatable
local import = import
local func = import('base/func')
---@type redis_ent
local redis_ent = import('game/entities/redis_ent')
---@type common
local common = import('game/entities/common')
---@type item_ent
local item_ent = import('game/entities/item_ent')
---@type exchange_ent
local exchange_ent = import('game/entities/exchange_ent')
---@type item_res
local item_res = import('game/resources/item_res')
---@type equip_ent
local equip_ent = import('game/entities/equip_ent')
---@type map_ent
local map_ent = import('game/entities/map_ent')
---@type user_set_ent
local user_set_ent = import('game/entities/user_set_ent')

------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function transfer_ent.super_preload()
    this.wi_refresh_upload_warehouse_in_redis = decider.run_interval_wrapper('收金号刷新仓库记录', this.refresh_upload_warehouse_in_redis, 1000 * 30)
end

-------------------------------------------------------------------------------------
-- 转移功能整合
transfer_ent.do_transfer_ent_for_warehouse = function()
    ---未开启转金 退出
    ---
    local open_transfer_ent = user_set_ent['开启交易转金'] or 0
    if open_transfer_ent == 0 then
        --   xxmsg('退出1')
        return
    end
    if actor_unit.local_player_level() < 35 then
        --  xxmsg('退出2')
        return
    end
    local main_map_id = actor_unit.main_map_id()
    if main_map_id ~= 201 or main_map_id ~= 101 or main_map_id ~= 301 then
        map_ent.execute_transfer_map(101)
    end
    while decider.is_working() do
        -- 关闭睡眠模式
        common.set_sleep(0)
        ---判断是否为收金号
        if transfer_ent.is_warehouse_player() then
            -- 获取铜钱数量
            local sale_money = item_unit.get_money_byid(3)
            if sale_money >= 10000 then
                trace.output('收金号操作')
                -- 刷新活跃记录
                this.wi_refresh_upload_warehouse_in_redis()
                if common.is_sleep_any('buy_equip_from_small', 15) then
                    -- 检测回购物品
                    transfer_ent.buy_item_in_redis()
                end
                -- 检测上架物品
                if not transfer_ent.do_exchanges_shelves_item(open_transfer_ent) then
                    -- 下架不需要的物品
                    transfer_ent.do_up_down_exchanges_item()
                end
                -- 刷新已出售
                transfer_ent.refresh_sale_record_by_warehouse(open_transfer_ent)
                decider.sleep(2000)
                -- 金币结算
                exchange_ent.wi_settlement()
            else
                trace.output('收金号铜钱过低[' .. sale_money .. ']')
            end
        else
            trace.output('转金号')
            -- 金币结算[120秒检测一次]
            exchange_ent.wi_settlement()
            -- 检测购买,上架好的物品
            transfer_ent.do_exchanges_buy_item_for_transfer()

            transfer_ent.transfer_item_to_return()
            decider.sleep(3 * 1000)
        end
        decider.sleep(2 * 1000)
    end
end

-------------------------------------------------------------------------------------
-- [条件]判断是否为收金号
-- 返回：bool
transfer_ent.is_warehouse_player = function()
    local my_name = local_player:name()
    local warehouse = user_set_ent['收金号']
    warehouse = func.split(warehouse, '|')
    for k, v in pairs(warehouse) do
        --角色名与用户设置收金号名相同判断为收金号
        if v == my_name then
            return true
        end
        --ip与设置ip相同判断为收金号
        if v == main_ctx:get_local_ip() then
            return true
        end
    end
    return false
end

--收金号操作-----------------------------------收金号操作----------------------------------------------------收金号操作

-------------------------------------------------------------------------------------
-- 收金号 刷新仓库记录(如果是收金号 则调用)[收金号]
transfer_ent.refresh_upload_warehouse_in_redis = function()
    --收金号 清除在转金的记录
    transfer_ent.warehouse_clear_transfer_gold_in_redis()
    local id = local_player:id()                    -- 角色id
    local name = local_player:name()                -- 角色名称
    local ret = {}                                  -- 保存从redis读取到的数据
    local can_idx = 0                               -- 记录所在位置
    local out_time = 900                            -- 活跃超时时间  记录仓库名 是否在活跃超时  默认15分钟
    local is_my_cord = false                        -- 记录是否已存在
    local count = user_set_ent['最大收金号数'] or 40     -- 转金号数
    --向redis读取仓库记录
    for i = 1, count do
        local ret_client = redis_ent.get_json_redis_by_path(transfer_ent.PATH1 .. i)
        table.insert(ret, ret_client)
    end
    --查询是否存在记录
    for i = 1, #ret do
        local ret_client = ret[i]
        if table_is_empty(ret_client) then
            if can_idx == 0 then
                can_idx = i
            end
        else
            if ret_client['收金号'] == name or ret_client['收金ID'] == tostring(id) then
                can_idx = i
                is_my_cord = true
                break
            end
        end
    end
    --查询是否存在超时记录
    if not is_my_cord and can_idx == 0 then
        for i = 1, #ret do
            local ret_client = ret[i]
            if not table_is_empty(ret_client) then
                local brisk_time = ret_client['活跃时间']
                if type(brisk_time) == 'number' then
                    if os.time() - brisk_time > out_time then
                        can_idx = i
                        break
                    end
                end
            end
        end
    end
    --设置收金默认记录
    if can_idx > 0 then
        local PATH = transfer_ent.PATH1 .. can_idx
        local data = {}
        data['活跃时间'] = os.time()
        data['收金号'] = name
        data['收金ID'] = tostring(id)
        redis_ent.set_json_redis_by_path_and_data(PATH, data)
    end
end

-------------------------------------------------------------------------------------
-- 收金号 清除在转金的记录
transfer_ent.warehouse_clear_transfer_gold_in_redis = function()
    local can_idx_name, can_idx2, data_r, is_my_cord = transfer_ent.refresh_upload_transfer_gold_in_redis(true)
    if is_my_cord then
        redis_ent.set_json_redis_by_path_and_data(transfer_ent.PATH2 .. can_idx_name .. ':' .. can_idx2, '')
    end
end

-------------------------------------------------------------------------------------
-- 获取需要转金的记录 data (收金号上架时使用)
transfer_ent.get_need_transfer_gold_data_in_redis = function(is_only_status)
    local ret = transfer_ent.get_transfer_data_by_warehouse_name_in_redis()
    local return_ret = {} --保存需要上架的数据
    for i = 1, #ret do
        local ret_client = ret[i]
        local t_gold_id = ret_client['转金号ID']
        local n_transfer_gold = ret_client['可转金币']
        local e_res_id = ret_client['交易行资源ID']
        if t_gold_id and t_gold_id ~= 0 then
            if n_transfer_gold ~= 0 then
                if n_transfer_gold >= 10 then
                    if e_res_id == 0 and not is_only_status or (ret_client['交易行上架时'] and os.time() > tonumber(ret_client['交易行上架时']) and ret_client['交易行上架时'] > 0) then
                        table.insert(return_ret, ret_client)
                    end
                end
            end
        end
    end
    return return_ret
end

-------------------------------------------------------------------------------------
-- 刷新出售信息到redis[收金号]
-- 返回：交易行正出售的列表
transfer_ent.refresh_exchanges_shelves_item_to_redis = function()
    -- 获取存在需要转金的记录(不包括审核状态)
    local data = transfer_ent.get_need_transfer_gold_data_in_redis()
    local ret_sale = {}
    if not table_is_empty(data) then
        ret_sale = exchange_ent.get_sell_list()
        for i = 1, #ret_sale do
            local ret = ret_sale[i]
            local data_r1 = transfer_ent.get_need_transfer_gold_data_in_redis()
            -- 检测当前交易出售 是否已记录  如果没有记录 则上传
            local idx1, idx2 = transfer_ent.has_can_set_in_transfer_redis(data_r1, ret.id, ret.sale_price)
            local idx = 0
            if idx2 > 0 then
                -- 未记录出售所有信息  需要记录所有数据
                idx = idx2
            elseif idx1 > 0 then
                -- 已记录出售ID  需要刷新下出售状态。。
                idx = idx1
            end
            if idx > 0 then
                local data_1 = data_r1[idx]
                if data_1 ~= nil then
                    local can_idx2 = data_1['can_idx2']
                    local can_idx_name = data_1['warehouse_name']
                    if os.time() < ret.up_time / 1000 + 24 * 2 * 60 * 60 then
                        if idx2 > 0 then
                            data_1['交易行上架时'] = tostring(ret.up_time)
                        end
                        data_1['交易行物品ID'] = tostring(ret.id)
                    else
                        ---下架物品  删除数据
                        trace.output('1.下架物品..')
                        exchange_unit.down_item(ret.id)
                        if idx1 > 0 then
                            redis_ent.set_json_redis_by_path_and_data(transfer_ent.PATH2 .. can_idx_name .. ':' .. can_idx2, '')
                        end
                        sleep(2000)
                    end
                end
            end
        end
    end
    return ret_sale
end

-------------------------------------------------------------------------------------
-- 指定的已出售ID 是否已记录到转金redis
-- 参数1：当前转金记录数据
-- 参数2：出售ID
-- 参数3：出售价格
-- 返回：第一个参数大于0 则 当前记录已存在 无需上传，第二个参数大于0 则当前记录不存在 需要记录,当前记录data
-------------------------------------------------------------------------------------
transfer_ent.has_can_set_in_transfer_redis = function(data, sell_id, sell_price)
    for i = 1, #data do
        local data_r = data[i]
        if data_r['交易行物品ID'] == tostring(sell_id) then
            return i, 0, data_r
        end
    end
    for i = 1, #data do
        local data_r = data[i]
        if data_r['可转金币'] == sell_price then
            return 0, i, data_r
        end
    end
    return 0, 0, {}
end

-------------------------------------------------------------------------------------
-- 交易行上架物品[收金号]
transfer_ent.do_exchanges_shelves_item = function(open_transfer)
    -- 获取存在需要转金的记录( 不存在出售ID的数据  和存在 出售状态为0的数据)
    local data = transfer_ent.get_need_transfer_gold_data_in_redis()

    if table_is_empty(data) then
        return false
    end
    local ret_sale = exchange_ent.get_sell_list()
    local can_put_away = 30 - #ret_sale --可上架的物品数
    if can_put_away == 0 then
        return false
    end
    local is_up_num = 0 --保存已上架次数
    for i = 1, #data do
        if is_up_num >= can_put_away then
            break
        end
        local data_r = data[i]
        local c_gold = data_r['可转金币']
        local is_has_up = true -- 是否上架
        --检测当前金币对应的交易行 是否存在上架未使用的物品
        for j = 1, #ret_sale do
            if ret_sale[j].sale_price == c_gold then
                if tostring(ret_sale[j].id) == data_r['交易行物品ID'] then
                    is_has_up = false
                    break
                end
            end
        end
        if is_has_up then
            transfer_ent.do_exchanges_shelves_item_3(c_gold, data_r, data)
            break
        end
    end
    if is_up_num > 0 then
        return true
    end
    return false
end

-------------------------------------------------------------------------------------
-- 执行上架装备[收金号]
-- @tparam     number               c_gold              上架的金币数
-- @tparam     table                data_r              当前需上架目标
-- @tparam     table                data                所有需上架目标记录
-------------------------------------------------------------------------------------
transfer_ent.do_exchanges_shelves_item_3 = function(c_gold, data_r, data)
    local need_monney = c_gold * 10
    if item_unit.get_money_byid(3) < need_monney or (data_r['交易行上架时'] and os.time() > tonumber(data_r['交易行上架时']) and data_r['交易行上架时'] > 0) then
        return false
    end
    -- 获取可上架的装备
    local item_info = transfer_ent.get_shelves_item_info()
    -- 存在可上架的物品
    if not table_is_empty(item_info) then
        local money = item_unit.get_money_byid(3)
        local str = '上架[' .. item_info.name .. ']' .. item_info.num .. '个,' .. c_gold .. '金'
        exchange_unit.up_item(item_info.id, c_gold, item_info.num)
        if common.wait_change_money(money, str, 60) then
            -- 上架成功 直接刷新上架信息
            decider.sleep(2000)
            transfer_ent.write_shelves_data(data, data_r, c_gold, 1, item_info.enhanced_level, item_info.res_id)
            return true
        end
    else
        trace.output('没有可上架的装备')
        sleep(3000)
    end
    return false
end

-------------------------------------------------------------------------------------
-- 筛选最佳的上架物品
transfer_ent.get_shelves_item_info = function(transfer_gold)
    local can_shelves = {}
    local item_info = item_ent.get_item_info(0)
    for i = 1, #item_info do
        local sell_item = true
        -- 非装备不行
        if item_info[i].type ~= 0 then
            sell_item = false
        end
        -- 佩戴中的装备不行
        if sell_item and item_ent.equip_is_ues(item_info[i].id) then
            sell_item = false
        end

        -- 蓝色装备不行
        if sell_item and item_info[i].quality == 0 or item_info[i].quality >= 3 then
            sell_item = false
        end
        -- 绑定装备不行
        if sell_item and item_res.is_bind_by_name(item_info[i].name) then
            sell_item = false
        end
        -- 强化低于1的不行
        if sell_item and item_info[i].enhanced_level < 1 then
            this.execute_enhancement_equip(item_info[i])
            local enhancement_level = equip_ent.get_equip_enhancement_level(item_info[i].name)
            if enhancement_level < 1 then
                sell_item = false
            end
        end
        if sell_item then
            can_shelves = item_info[i]
            break
        end
    end
    -- 返回可出售信息
    return can_shelves
end

-------------------------------------------------------------------------------------
-- 记录上架的数据[收金号]
-- @tparam     table                data                所有需上架目标记录
-- @tparam     table                data_1              当前需上架目标
-- @tparam     number               sell_price          出售价格
-- @tparam     number               item_type           物品类型[0非装备 1装备]
-- @tparam     number               item_level          装备等级
-------------------------------------------------------------------------------------
transfer_ent.write_shelves_data = function(data, data_1, sell_price, item_type, item_level, item_res_id)
    local ret_sale = exchange_ent.get_sell_list()
    for i = 1, #ret_sale do
        local is_exist = false
        for _, data_r in pairs(data) do
            if tostring(ret_sale[i].id) == data_r['交易行物品ID'] then
                is_exist = true
                break
            end
        end
        if not is_exist and sell_price == ret_sale[i].sale_price then
            local can_idx2 = data_1['can_idx2']
            local can_idx_name = data_1['warehouse_name']
            if os.time() < ret_sale[i].up_time / 1000 + 24 * 2 * 60 * 60 then
                data_1['交易行上架时'] = tostring(ret_sale[i].up_time)
                data_1['交易行物品ID'] = tostring(ret_sale[i].id)
                data_1['交易上架状态'] = ret_sale[i].status
                data_1['交易行物品资源ID'] = item_res_id
                data_1['装备等级'] = item_level
                data_1['是否装备'] = item_type
                data_1['装备名字'] = ret_sale[i].name
                redis_ent.set_json_redis_by_path_and_data(this.PATH2 .. can_idx_name .. ':' .. can_idx2, data_1)
                break
            else
                ---下架物品  删除数据
                trace.output('1.下架物品..')
                exchange_unit.down_item(ret_sale[i].id)
                decider.sleep(2000)
            end
        end
    end


end

-------------------------------------------------------------------------------------
-- 交易行下架物品[收金号]
transfer_ent.do_up_down_exchanges_item = function()
    -- 获取存在需要转金的记录( 不存在出售ID的数据  和存在 出售状态为0的数据)
    local data = transfer_ent.get_need_transfer_gold_data_in_redis()
    if table_is_empty(data) then
        return false
    end
    local ret_sale = exchange_ent.get_sell_list()
    local ret = {}
    for j = 1, #ret_sale do
        local is_up_down = true
        for i = 1, #data do
            if data[i]['交易行物品ID'] == tostring(ret_sale[j].id) then
                is_up_down = false
                break
            end
        end
        if is_up_down then
            table.insert(ret, ret_sale[j].id)
        end
    end
    for i = 1, #ret do
        exchange_unit.down_item(ret[i])
        decider.sleep(2000)
    end
end


-------------------------------------------------------------------------------------
-- 刷新已出售[收金号]
transfer_ent.refresh_sale_record_by_warehouse = function(open_transfer)
    local ret_sale = exchange_ent.get_sell_list()
    for _, sale in pairs(ret_sale) do
        -- 获取已上架的记录
        local data = transfer_ent.get_need_transfer_gold_data_in_redis(true)
        local data_1 = {}
        for _, data_r in pairs(data) do
            if tostring(sale.id) == data_r['交易行物品ID'] then
                data_1 = data_r
                break
            end
        end
        if not table_is_empty(data_1) then
            local can_idx2 = data_1['can_idx2']
            local can_idx_name = data_1['warehouse_name']
            if os.time() > sale.up_time / 1000 + 24 * 2 * 60 * 60 then
                ---下架物品  删除数据
                trace.output('1.下架物品..')
                exchange_unit.down_item(sale.id)
                decider.sleep(2000)
                data_1 = ''
            end
            local path = transfer_ent.PATH2 .. can_idx_name .. ':' .. can_idx2
            redis_ent.set_json_redis_by_path_and_data(path, data_1)
        end
    end
end

--转金号操作-----------------------------------转金号操作----------------------------------------------------转金号操作
-------------------------------------------------------------------------------------
-- 交易行购买物品[转金号]
transfer_ent.do_exchanges_buy_item_for_transfer = function()
    --当前上架仓库名,上架记录位置,当前位置所有数据,是否存在记录
    local can_idx_name, can_idx2, data_r, is_my_cord = transfer_ent.refresh_upload_transfer_gold_in_redis()
    local gold = transfer_ent.get_can_transfer_gold()
    local is_clear = false
    if gold < transfer_ent.get_trigger_min_gold() then
        if can_idx2 > 0 and can_idx_name ~= '' then
            --清空转金记录
            is_clear = true
            trace.output('没有可转的金币.')
        end
    end
    if not table_is_empty(data_r) and not is_clear then
        local buy_id = tonumber(data_r['交易行物品ID'])
        local res_id = 0
        if data_r['装备名字'] then
            res_id = exchange_unit.get_item_res_id_byname(data_r['装备名字'])
        end
        local level = tonumber(data_r['装备等级'])
        local can_gold = tonumber(data_r['可转金币'])
        local up_time = data_r['交易行上架时']
        if up_time then
            up_time = tonumber(up_time)
        end
        if buy_id ~= 0 then
            if up_time and os.time() > up_time / 1000 and up_time > 0 then
                trace.output('已上架物品,执行购买')
                -- 没有查询到交易物品  也删除上架的数据
                if transfer_ent.do_exchanges_buy_goods_by_resid_and_sale_player_id(res_id, level, can_gold) then
                    is_clear = true
                end
            else
                trace.output('已上架,等待交易行' .. (math.floor(up_time / 1000 - os.time())) .. '秒后显示')
            end
        else
            trace.output('仓库暂未上架物品')
        end
    end
    if is_clear and is_my_cord then
        redis_ent.set_json_redis_by_path_and_data(transfer_ent.PATH2 .. can_idx_name .. ':' .. can_idx2, '')
    end
    if gold < transfer_ent.get_trigger_min_gold() then
        if user_set_ent['交易后下线'] == 1 and not is_terminated() then
            main_ctx:set_ex_state(1)
            sleep(3000)
            main_ctx:end_game()
        end
    end
end


-------------------------------------------------------------------------------------
-- 出金号 刷新转金位置 记录[转金号]
-- 返回：当前上架仓库名,上架记录位置,当前位置所有数据,是否存在记录
transfer_ent.refresh_upload_transfer_gold_in_redis = function(is_clear)
    local id = local_player:id()                    --角色id
    local name = local_player:name()                --角色名称
    local ret = {}                                  --保存从redis读取到的数据
    local ret2 = {}                                 --保存所有活跃仓库  所有上架记录数
    local can_idx_name = ''                         --记录 仓库
    local can_idx2 = 0                              --记录指定仓库名下所在位置
    local out_time = 1800                           --活跃超时时间 当前仓库名 转金记录 最大超时时间  默认 半小时
    local is_my_cord = false                        --记录是否已存在
    local count = user_set_ent['最大收金号数'] or 30     --收金号数
    local gold = transfer_ent.get_can_transfer_gold() --读取当前可转金币数
    --保存所有 的仓库数据 到ret
    for i = 1, count do
        local ret_client = redis_ent.get_json_redis_by_path(transfer_ent.PATH1 .. i)
        table.insert(ret, ret_client)
    end
    --保存 所有活跃的仓库  仓库 名下对应 转金记录 数据 到 ret2
    for i = 1, #ret do
        local ret_client = ret[i]
        if not table_is_empty(ret_client) then
            local brisk_time = ret_client['活跃时间']
            if brisk_time ~= nil then
                if os.time() - brisk_time < out_time then
                    local warehouse_name = ret_client['收金号']
                    local ret_client1 = transfer_ent.get_transfer_data_by_warehouse_name_in_redis(warehouse_name)
                    for j = 1, #ret_client1 do
                        ret_client1[j].can_idx_name = warehouse_name
                        table.insert(ret2, ret_client1[j])
                    end
                end
            end
        end
    end
    --读取 本角色  可刷新的位置
    for i = 1, #ret2 do
        local ret_client1 = ret2[i]
        if ret_client1['转金号ID'] == nil then
            if can_idx2 == 0 then
                can_idx_name = ret_client1.can_idx_name
                can_idx2 = ret_client1.can_idx2 --can_idx2
            end
        else
            if ret_client1['转金号'] == name or ret_client1['转金号ID'] == tostring(id) then
                can_idx_name = ret_client1.can_idx_name
                can_idx2 = ret_client1.can_idx2
                is_my_cord = true
                break
            end
        end
    end
    --读取本角色可刷新的位置
    if not is_my_cord and can_idx2 == 0 then
        for i = 1, #ret2 do
            local ret_client1 = ret2[i]
            if ret_client1['转金号ID'] ~= nil then
                local brisk_time = ret_client1['活跃时间']
                if type(brisk_time) == 'number' then
                    if os.time() - brisk_time > out_time then
                        can_idx_name = ret_client1.can_idx_name
                        can_idx2 = ret_client1.can_idx2
                        break
                    end
                end
            end
        end
    end
    local data_r = {} --当前位置所有key 数据
    if can_idx2 > 0 and can_idx_name ~= '' and gold >= transfer_ent.get_trigger_min_gold() and not is_clear then
        local data = {}
        if is_my_cord then
            data = redis_ent.get_json_redis_by_path(transfer_ent.PATH2 .. can_idx_name .. ':' .. can_idx2)
            if data['交易行物品ID'] == '0' or data['可转金币'] == 0 then
                data['可转金币'] = gold
            end
        else
            data['转金号'] = name
            data['转金号ID'] = tostring(id)
            data['交易行物品ID'] = '0'
            data['交易行资源ID'] = 0
            data['交易行上架时'] = 0
            data['可转金币'] = gold
            data['是否装备'] = 0
            data['装备等级'] = 0
            data['装备名字'] = '无'
        end
        data['活跃时间'] = os.time()
        data_r = data
        redis_ent.set_json_redis_by_path_and_data(transfer_ent.PATH2 .. can_idx_name .. ':' .. can_idx2, data)
    end
    return can_idx_name, can_idx2, data_r, is_my_cord
end

-------------------------------------------------------------------------------------
-- 获取可转金币[转金号]
transfer_ent.get_can_transfer_gold = function()
    return item_unit.get_money_byid(1) - (user_set_ent['转金保留金币'] or 30)
end

-------------------------------------------------------------------------------------
-- 获取最低转移金币[转金号]
transfer_ent.get_trigger_min_gold = function()
    return user_set_ent['开启交易转金'] == 2 and 30 or 10
end

-------------------------------------------------------------------------------------
-- 获取指定仓库名 转金记录数据(此命令 可供收金号读取)
-- 参数1：仓库收金名
transfer_ent.get_transfer_data_by_warehouse_name_in_redis = function(warehouse_name)
    local ret = {} --保存redis读取的数据
    warehouse_name = warehouse_name or local_player:name() --读取指定名 或本身 名下 转金总记录
    for i = 1, 30 do
        local ret_client = redis_ent.get_json_redis_by_path(transfer_ent.PATH2 .. warehouse_name .. ':' .. i)
        ret_client.can_idx2 = i --当前存在记录
        ret_client.warehouse_name = warehouse_name
        table.insert(ret, ret_client)
    end

    return ret
end

---------------------------------------------------------------------------------------------------------
--购买指定res_id,buy_id 的物品
--参数1：物品资源ID
--参数2：出售ID
--返回：是否存在指定出售ID
transfer_ent.do_exchanges_buy_goods_by_resid_and_sale_player_id = function(res_id, level, can_gold)
    local ret = false
    -- 判断是否获取到资源id
    if not res_id or res_id == 0 then
        xxmsg('无法获取res_id')
        return ret
    end
    -- 打开拍卖行窗口
    if exchange_ent.open_exchange_ui() then
        decider.sleep(1000)
        local exchange_item_info = {}
        decider.sleep(2000)
        -- 切换到拍卖行购买窗口
        exchange_unit.change_exchange_page(0)
        decider.sleep(5000)
        -- 搜索装备
        exchange_unit.search_equip(res_id)
        decider.sleep(2000)
        -- 获取装备数量数量
        local num = exchange_unit.get_equip_num_by_resid(res_id, level)
        decider.sleep(2000)
        if num > 0 then
            -- 搜索指定强化等级装备
            exchange_unit.search_item(res_id, level)
            decider.sleep(2000)
            -- 获取装备上架信息
            exchange_item_info = exchange_ent.exchange_item_info()
            for i = 1, #exchange_item_info do
                -- 匹配价格
                if exchange_item_info[i].total_price == can_gold and item_unit.get_money_byid(1) >= can_gold then
                    decider.sleep(2000)
                    -- 打开购买窗口
                    exchange_unit.set_buy_item(exchange_item_info[i].id)
                    decider.sleep(2000)
                    -- 判断窗口是否打开
                    if exchange_unit.is_open_buy_popup() then
                        trace.output('转金购买' .. exchange_item_info[i].id)
                        decider.sleep(2000)
                        -- 判断设置的购买ID是否正确     -- 这ID主要是在里面进行二次效验
                        if exchange_unit.get_cur_set_item_id() == exchange_item_info[i].id then
                            -- 通过钻石变化判断是否购买成功
                            local gold = item_unit.get_money_byid(1)
                            decider.sleep(2000)
                            -- 执行购买操作
                            exchange_unit.buy_item(exchange_item_info[i].id)
                            decider.sleep(5000)
                            -- 通过钻石变化判断是否购买成功
                            for ii = 1, 300 do
                                if item_unit.get_money_byid(1) ~= gold then
                                    ret = true
                                    break
                                end
                                trace.output('[' .. ii .. ']正在购买' .. exchange_item_info[i].id)
                                decider.sleep(100)
                            end
                        else
                            -- 关闭购买窗
                            transfer_ent.close_buy_popup()
                        end
                    else
                        xxmsg('窗口未打开')
                    end
                    break
                end
            end
        end
    end
    exchange_ent.close_exchange_ui()
    return ret
end

-- 关闭购买窗口
function transfer_ent.close_buy_popup()
    local ret_b = false
    while decider.is_working() do
        if not exchange_unit.is_open_buy_popup() then
            ret_b = true
            break
        end
        xxmsg('关闭购买窗口')
        exchange_unit.close_buy_popup()
        decider.sleep(2000)
    end
    return ret_b
end

------------------------------------------------------------------------------------
-- 购买上架的物品【redis记录】[收金号]
transfer_ent.buy_item_in_redis = function()
    -- 获取上架记录路径
    local v_path = this.SALE_RECORD_PATH .. '上架:上架数据'
    -- 保存可购买列表
    local can_buy_data = {}
    -- 保存需要装备的金币
    local need_good = 0
    -- 保存累计加入购买的数
    local buy_count = 0
    -- 自身名称
    local my_name = local_player:name()
    for i = 1, this.SALE_MAX_LOT do
        -- 需要装备大于身上金币数时退出
        if need_good > item_unit.get_money_byid(1) then
            break
        end
        -- 每次购买量不超过30个
        if buy_count > 30 then
            break
        end
        local path = v_path .. i
        local data = redis_ent.get_json_redis_by_path(path)
        if not table_is_empty(data) then
            for k, v in pairs(data) do
                if v.up_time then
                    v.up_time = tonumber(v.up_time)
                else
                    v.up_time = 0
                end
                if v.up_time and os.time() > v.up_time / 1000 and v.up_time > 0 then
                    if v.sale_name ~= my_name then
                        local q_gold = item_unit.get_money_byid(1)
                        need_good = need_good + v.gold
                        if q_gold >= need_good then
                            can_buy_data[v.sale_id] = can_buy_data[v.sale_id] or v
                            -- 购买此物品
                            --  table.insert(can_buy_data[data.sale_id], { sale_id = tonumber(data.sale_id), gold = data.gold, level = data.level, item_type = data.item_type })
                            buy_count = buy_count + 1
                        end
                        break
                    end
                end
            end
        end
    end
    -- 获取可购买的数据
    for k, v in pairs(can_buy_data) do
        local res_id = 0
        if v.equip_name then
            res_id = exchange_unit.get_item_res_id_byname(v.equip_name)
        end

        transfer_ent.do_exchanges_buy_goods_by_resid_and_sale_player_id(res_id, v.level, v.gold)
        decider.sleep(2000)
    end
end

-------------------------------------------------------------------------------------
-- 转移装备[转金号]
transfer_ent.transfer_item_to_return = function()
    math.randomseed(os.clock())

    local info = transfer_ent.get_sell_equip_info()
    local c_gold = math.random(10, 12)
    if not table_is_empty(info) then
        if transfer_ent.get_item_info_up_item(info, c_gold) then
            transfer_ent.set_sale_record_in_redis_by_sale_info(info.name, c_gold, info.num, 1, info.enhanced_level, info.res_id)
        end
    end

    this.refresh_sale_record()
end

------------------------------------------------------------------------------------
-- 刷新上架记录[转金号]
------------------------------------------------------------------------------------
transfer_ent.refresh_sale_record = function()
    -- 获取上架类别记录路径
    local path = transfer_ent.SALE_RECORD_PATH .. '上架:上架数据'
    -- 获取已上架数据
    local my_sell_list = exchange_ent.get_sell_list()
    -- 遍历上架数据
    for i = 1, #my_sell_list do
        local idx, idx2, data, is_exist = redis_ent.get_idx_in_redis_table_list_path(tostring(my_sell_list[i].id), 'sale_id', path, 24 * 3600, this.SALE_MAX_LOT, this.SALE_MAX_DATA_EVERY_LOT)
        if is_exist then
            if data[idx2] and data[idx2].up_time ~= tostring(my_sell_list[i].up_time) then
                data[idx2].up_time = tostring(my_sell_list[i].up_time)
                redis_ent.set_data_in_redis_table_list_path(data[idx2], tostring(my_sell_list[i].id), 'sale_id', path, 24 * 3600, this.SALE_MAX_LOT, this.SALE_MAX_DATA_EVERY_LOT)
            end
        end
    end
    this.clear_sale_record_in_redis(my_sell_list)
end


------------------------------------------------------------------------------------
-- 清除出售的记录[转金号]
transfer_ent.clear_sale_record_in_redis = function(my_sell_list)
    local name = local_player:name()
    local path_list = {
        this.SALE_RECORD_PATH .. '上架:上架数据',
    }
    -- 保存标记是否结算
    local is_account = false
    for _, v_path in pairs(path_list) do
        -- 移除数据
        for i = 1, this.SALE_MAX_LOT do
            local path = v_path .. i
            local data = redis_ent.get_json_redis_by_path(path)
            local is_update = false
            for j = #data, 1, -1 do
                if data[j].sale_name == name then
                    is_account = true
                    local is_del = true
                    -- 对比出售ID 是否不存在
                    for _, v in pairs(my_sell_list) do
                        if v.id == tonumber(data[j].sale_id) then
                            is_del = false
                            break
                        end
                    end
                    -- 需要移除记录
                    if is_del then
                        is_update = true
                        table.remove(data, j)
                    end
                end
            end
            if is_update then
                redis_ent.set_json_redis_by_path_and_data(path, data)
            end
        end
    end
    -- 结算
    if is_account then
        exchange_ent.wi_settlement()
    end
end

------------------------------------------------------------------------------------
-- 刷新指定物品已记录上架记录[转金号]
--
transfer_ent.set_sale_record_in_redis_by_sale_info = function(name, price, num, item_type, enhanced_level, res_id)
    local my_name = local_player:name()
    -- 获取上架类别记录路径
    local path = this.SALE_RECORD_PATH .. '上架:上架数据'
    -- 获取已上架数据
    local my_sell_list = exchange_ent.get_sell_list()
    -- 遍历上架数据
    for i = 1, #my_sell_list do
        if my_sell_list[i].sale_price == price and my_sell_list[i].num == num and my_sell_list[i].name == name then
            local idx, idx2, data, is_exist = redis_ent.get_idx_in_redis_table_list_path(tostring(my_sell_list[i].id), 'sale_id', path, 24 * 3600, this.SALE_MAX_LOT, this.SALE_MAX_DATA_EVERY_LOT)
            if not is_exist then
                -- 需要记录的数据
                local data_w = {
                    -- 出售ID
                    sale_id = tostring(my_sell_list[i].id),
                    -- 出售金币
                    gold = my_sell_list[i].sale_price,
                    -- 物品强化等级
                    level = enhanced_level or 0,
                    -- 是否装备
                    item_type = item_type or 0,
                    -- 出售人
                    sale_name = local_player:name(),
                    -- 记录时间
                    up_time = tostring(my_sell_list[i].up_time),
                    -- 物品资源id
                    res_id = res_id,
                    -- 物品名字
                    equip_name = my_sell_list[i].name,
                }
                redis_ent.set_data_in_redis_table_list_path(data_w, tostring(my_sell_list[i].id), 'sale_id', path, 24 * 3600, this.SALE_MAX_LOT, this.SALE_MAX_DATA_EVERY_LOT)
                break
            end
        end
    end
end

-------------------------------------------------------------------------------------
-- 筛选最佳的上架物品
transfer_ent.get_sell_equip_info = function()
    local can_shelves = {}
    local item_info = item_ent.get_item_info(0)
    for i = 1, #item_info do
        local sell_item = true
        -- 非装备不行
        if item_info[i].type ~= 0 then
            sell_item = false
        end
        -- 佩戴中的装备不行
        if sell_item and item_ent.equip_is_ues(item_info[i].id) then
            sell_item = false
        end
        -- 蓝色装备不行
        if sell_item and item_info[i].quality == 0 or item_info[i].quality >= 3 then
            sell_item = false
        end
        -- 绑定装备不行
        if sell_item and item_res.is_bind_by_name(item_info[i].name) then
            sell_item = false
        end
        if sell_item and item_info[i].enhanced_level < 1 then
            this.execute_enhancement_equip(item_info[i])
            local enhancement_level = equip_ent.get_equip_enhancement_level(item_info[i].name)
            if enhancement_level < 1 then
                sell_item = false
            end
        end
        if sell_item then
            can_shelves = item_info[i]
            break
        end
    end
    -- 返回可出售信息
    return can_shelves
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
function transfer_ent.get_item_info_up_item(item_info, money)
    local ret_b = false
    if exchange_ent.open_exchange_ui() then
        exchange_unit.up_item(item_info.id, money, item_info.num)
        for i = 1, 8 do
            decider.sleep(2000)
            local now_item_info = item_ent.get_item_info_by_id(item_info.id)
            if table_is_empty(now_item_info) then
                ret_b = true
                break
            end
        end
    end
    exchange_ent.close_exchange_ui()
    return ret_b
end

------------------------------------------------------------------------------------
-- [行为]强化指定装备
function transfer_ent.execute_enhancement_equip(equip_info)
    -- 获取需要的强化卷轴名和最大强化等级
    local need_item = transfer_ent.max_enhancement_level(equip_info.equip_type)
    -- 通过名字获取强化卷id
    local item_id = item_ent.get_item_id_by_name(need_item, 0) ~= 0 and item_ent.get_item_id_by_name(need_item, 0) or item_ent.get_item_id_by_name('[이벤트] ' .. need_item, 0)
    -- 强化卷轴数量
    local item_num = item_ent.get_item_num_by_name({ '[이벤트] ' .. need_item, need_item }, 0)
    if item_num == 0 then
        return false, '强化卷轴不足'
    end
    -- 执行强化装备
    common.set_sleep(0)
    common.execute_pass_dialog()
    common.handle_bag(1)
    item_unit.enhancement_equip(equip_info.id, item_id)
    decider.sleep(2000)
    equip_ent.wu_wait_enhancement_equip(item_num, need_item, equip_info.name, 1)
    local now_item_num = item_ent.get_item_num_by_name({ '[이벤트] ' .. need_item, need_item }, 0)
    -- 通过强化卷数量判断是否强化完成
    if now_item_num == item_num then
        return false, '强化超时'
    end
    return true
end

--------------------------------------------------------------------------------------
-- [读取] 通过装备名获取强化等级
--
-- @tparam              string          enhancement_type            装备类型
-- @treturn             number          res_id                      强化物res_is
-- @treturn             number          max_level                   安全强化等级
-- @usage
-- local need_item, max = equip_ent.get_equip_enhancement_level('装备名称')
--------------------------------------------------------------------------------------
function transfer_ent.max_enhancement_level(equip_type)
    local enhancement_info = {
        [0] = { need_item = '무기 강화 주문서(귀속)' },
        [1] = { need_item = '무기 강화 주문서(귀속)' },
        [2] = { need_item = '방어구 강화 주문서(귀속)' },
        [3] = { need_item = '방어구 강화 주문서(귀속)' },
        [4] = { need_item = '방어구 강화 주문서(귀속)' },
        [5] = { need_item = '방어구 강화 주문서(귀속)' },
        [6] = { need_item = '방어구 강화 주문서(귀속)' },
        [7] = { need_item = '방어구 강화 주문서(귀속)' },
        [8] = { need_item = '장신구 강화 주문서(귀속)' },
        [9] = { need_item = '장신구 강화 주문서(귀속)' },
        [10] = { need_item = '장신구 강화 주문서(귀속)' },
        [11] = { need_item = '장신구 강화 주문서(귀속)' },
        [12] = { need_item = '밤까마귀 강화 주문서(귀속)' },
        [13] = { need_item = '밤까마귀 강화 주문서(귀속)' },
        [14] = { need_item = '아티팩트 강화 주문서(귀속)' },
        [15] = { need_item = '아티팩트 강화 주문서(귀속)' },
    }
    local need_item = enhancement_info[equip_type].need_item or 0
    return need_item
end





------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function transfer_ent.__tostring()
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
function transfer_ent.__newindex(t, k, v)
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
transfer_ent.__index = transfer_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function transfer_ent:new(args)
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
    return setmetatable(new, transfer_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return transfer_ent:new()

-------------------------------------------------------------------------------------
