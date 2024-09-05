------------------------------------------------------------------------------------
-- game/entities/shop_ent.lua
--
-- 实体示例
--
-- @module      shop_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local shop_ent = import('game/entities/shop_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class shop_ent
local shop_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME = 'shop_ent module',
    -- 只读模式
    READ_ONLY = false,
}

-- 实例对象
local this = shop_ent
-- 日志模块
local trace = trace
-- 决策模块
local decider = decider
local pairs = pairs
local table = table
local rawset = rawset
local setmetatable = setmetatable
local import = import
---@type actor_ent
local actor_ent = import('game/entities/actor_ent')
---@type shop_res
local shop_res = import('game/resources/shop_res')
---@type item_res
local item_res = import('game/resources/item_res')
---@type item_ent
local item_ent = import('game/entities/item_ent')
---@type skill_ent
local skill_ent = import('game/entities/skill_ent')
---@type equip_ent
local equip_ent = import('game/entities/equip_ent')
local map_ent = import('game/entities/map_ent')

---@type common
local common = import('game/entities/common')
local map_res = import('game/resources/map_res')
local ui_ent = import('game/entities/ui_ent')

------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function shop_ent.super_preload()
    this.wa_execute_buy_item = decider.run_action_wrapper('[行为]购买物品', this.execute_buy_item)
    -- [行为判断]
    --  this.can_buy_sunyi = decider.run_action_wrapper('是否能瞬移', this.can_buy_sunyi)

    --   this.buy_item = decider.run_action_wrapper('是否能买', this.buy_item)
    --  this.can_buy_skill_book = decider.run_action_wrapper('是否能买技能书', this.can_buy_skill_book)

end

shop_ent.not_buy_id = {}

--------------------------------------------------------------------------------
-- 购买
function shop_ent.auto_buy_item()
    local buy_item_list = shop_res.BUY_ITEM_LIST
    local my_level = actor_unit.local_player_level()
    for i = 1, #buy_item_list do
        local item_name = buy_item_list[i].item_name
        local need_level = buy_item_list[i].need_level
        if need_level and my_level > need_level then
            shop_ent.buy_item(item_name)
        elseif not need_level then
            shop_ent.buy_item(item_name)
        end
    end
end

--------------------------------------------------------------------------------
-- [行为] 获取购买物品方法和npc信息并移动去购买
--
-- @tparam       table          item_name           购买物品名（汉）
-- @usage
-- shop_ent.buy_item(购买物品名（汉）)
--------------------------------------------------------------------------------
function shop_ent.buy_item(item_name)
    -- 获取购买物品方法
    local bug_item_func = shop_ent.get_bug_item_func(item_name)
    if table.is_empty(bug_item_func) then
        return false, '无购买方式'
    end
    local map_name = map_res.get_stronghold_name(actor_unit.map_name())
    -- 获取商店信息
    local npc_info = shop_res[map_name] and shop_res[map_name][bug_item_func.npc_type] or {}
    if table.is_empty(npc_info) then
        return false, '该地图不存在' .. bug_item_func.npc_type
    end
    local item_data = npc_info.sell_item[item_name]
    if table.is_empty(item_data) then
        return false, item_name .. '未上架可购买列表'
    end
    if not bug_item_func.can_buy_func(item_data.h_name, item_data.price) then
        return false, '该物品不可购买'
    end
    -- 执行去购买物品
    trace.output('购买物品:', item_name)
    shop_ent.go_to_buy_item(item_name, npc_info, bug_item_func)
end

--------------------------------------------------------------------------------
-- [行为] 移动到购买信息对应的npc处执行交易动作(内部调用)
--
-- @tparam       string         item_name           购买物品名（汉）
-- @tparam       table          npc_info            npc信息
-- @tparam       table          bug_item_func       购买方法
-- @usage
-- shop_ent.go_to_buy_item(购买物品名（汉, npc信息, 购买方法)
--------------------------------------------------------------------------------
function shop_ent.go_to_buy_item(item_name, npc_info, bug_item_func)
    local npc_pos = npc_info.npc_pos
    -- npc坐标
    local npc_x, npc_y, npc_z, map_id = npc_pos.x, npc_pos.y, npc_pos.z, npc_pos.map_id
    -- 物品名字（韩）及价格
    local h_name = npc_info.sell_item[item_name].h_name
    local price = npc_info.sell_item[item_name].price
    while decider.is_working() do
        -- 判断是否可购买
        if not bug_item_func.can_buy_func(h_name, price) then
            break
        end
        common.set_sleep(0)
        if local_player:dist_xy(npc_x, npc_y) < 800 then
            -- 获取npcid
            local npc_id = actor_ent.get_npc_id(npc_info.name)
            -- 获取物品信息
            local item_info = shop_ent.get_item_info_by_name(h_name)
            -- 执行购买
            shop_ent.wa_execute_buy_item(npc_id, item_info.id, bug_item_func.can_buy_num)
        else
            map_ent.execute_transfer_map(map_id)
            actor_unit.auto_move(npc_x, npc_y, npc_z)
            --购买移动116492.0|73440.0|19232.49
            -- xxmsg('购买移动' .. npc_x .. '|' .. npc_y .. '|' .. npc_z)
        end
        decider.sleep(2000)
    end
end

---------------------------------------------------------------------
-- [行为] 执行购买操作
--
-- @tparam       number      npc_id             npc_id
-- @tparam       number      item_id            物品id
-- @tparam       number      can_buy_num        购买数量
-- @usage
-- shop_ent.execute_buy_item(npc_id, 物品id, 购买数量)
---------------------------------------------------------------------
function shop_ent.execute_buy_item(npc_id, item_id, can_buy_num)
    if npc_id == 0 then
        return false, '获取npcid失败'
    end
    if not item_id then
        return false, '获取购买物id失败'
    end
    if type(can_buy_num) ~= 'number' then
        return false, '获取购买物品数量非number类型'
    end
    if can_buy_num <= 0 then
        return false, '获取购买物品数量低于0'
    end
    local my_money = item_unit.get_money_byid(3)
    npc_shop_unit.buy_item(npc_id, item_id, can_buy_num)
    for i = 1, 8 do
        decider.sleep(2000)
        if my_money ~= item_unit.get_money_byid(3) then
            ui_ent.close_window_list()
            return true, '购买成功'
        end
    end
    if shop_ent.not_buy_id[item_id] then
        shop_ent.not_buy_id[item_id].num = shop_ent.not_buy_id[item_id].num + 1
    else
        shop_ent.not_buy_id[item_id] = {num = 1}
    end
    return false, '购买超时'
end

---------------------------------------------------------------------
-- [条件] 判断是否能购买技能书
--
-- @tparam       string      item_name           物品名（韩）
-- @tparam       number      price               物品单价
-- @treturn      boolean
-- @usage
-- local bool = shop_ent.can_buy_skill_book(物品名（韩）, 物品单价)
---------------------------------------------------------------------
function shop_ent.can_buy_skill_book(item_name, price)
    local my_money = item_unit.get_money_byid(3)
    if my_money < price then
        return false, '铜钱不足'
    end
    local item_num = item_ent.get_item_num_by_name(item_name, 0)
    if item_num > 0 then
        return false, '背包存在该技能书'
    end
    local item_res_data = item_res.ITEM_LIST[item_name]
    if table.is_empty(item_res_data) then
        return false, '不存在物品资源信息'
    end
    local skill_c_name = item_res_data.skill_c_name
    local level = item_res_data.level
    local skill_level = skill_ent.get_skill_level_by_name(skill_c_name)
    if skill_level >= level then
        return false, '技能已学习'
    end
    return true
end

---------------------------------------------------------------------
-- [条件] 判断是否购买红药水
--
-- @tparam       string      item_name           物品名（韩）
-- @treturn      boolean
-- @usage
-- local bool = shop_ent.can_buy_hp(物品名（韩）)
---------------------------------------------------------------------
function shop_ent.can_buy_hp(item_name)
    local item_num = item_ent.get_item_num_by_name(item_name, 0)
    if item_num >= 100 then
        return false, '背包药品数量大于等于100瓶'
    end
    local buy_num = 1500 - item_num
    local can_buy_num = common.calc_num(buy_num, 15, 20000)
    if can_buy_num < 100 then
        return false, '可购买数量低于100瓶药水'
    end
    return true
end

---------------------------------------------------------------------
-- [条件] 判断是否购买瞬移
--
-- @tparam       string      item_name           物品名（韩）
-- @treturn      boolean
-- @usage
-- local bool = shop_ent.can_buy_sunyi(物品名（韩）)
---------------------------------------------------------------------
function shop_ent.can_buy_sunyi(item_name)
    local item_num = item_ent.get_item_num_by_name(item_name, 0)
    if actor_unit.local_player_level() < 35 then
        return false, '角色等级小于35'
    end
    if item_num >= 50 then
        return false, '背包瞬移卷轴数量大于等于50张'
    end
    local buy_num = 100 - item_num
    local can_buy_num = common.calc_num(buy_num, 800, 20000)
    if can_buy_num < 10 then
        return false, '可购买数量低于10张'
    end
    return true
end

---------------------------------------------------------------------
-- [条件] 判断是否购买瞬移
--
-- @tparam       string      item_name           物品名（韩）
-- @treturn      boolean
-- @usage
-- local bool = shop_ent.can_buy_sunyi(物品名（韩）)
---------------------------------------------------------------------
function shop_ent.can_buy_gongsu(item_name)
    local item_num = item_ent.get_item_num_by_name(item_name, 0)
    if actor_unit.local_player_level() < 35 then
        return false, '角色等级小于35'
    end
    if item_num >= 30 then
        return false, '背包药品数量大于等于10'
    end
    local buy_num = 100 - item_num
    local can_buy_num = common.calc_num(buy_num, 800, 20000)
    if can_buy_num < 10 then
        return false, '可购买数量低于10张'
    end
    return true
end


---------------------------------------------------------------------
-- [条件] 判断是否购买生命护身符
--
-- @treturn      boolean
-- @usage
-- local bool = shop_ent.can_buy_hp(物品名（韩）)
---------------------------------------------------------------------
function shop_ent.can_buy_smhf()
    if actor_unit.local_player_level() < 35 then
        return false, '35级以下无法购买'
    end
    local bast_equip = equip_ent.get_bast_equip_by_part(15)
    if not table.is_empty(bast_equip) and bast_equip.quality >= 2 then
        return false, '背包存在绿色以上圣物B'
    end
    return true
end

--------------------------------------------------------------------------------
-- [读取] 获取购买物品方法
--
-- @tparam              string          item_name           购买物品名（汉）
-- @treturn             table           buy_data            返回物品购买方法表 包括
-- @tfield[t]           func            can_buy_func        判断是否可以购买
-- @tfield[t]           string          npc_type            购买商人名
-- @tfield[t]           number          can_buy_num         购买数量
-- @usage
-- shop_ent.get_bug_item_func(购买物品名（汉）)
--------------------------------------------------------------------------------
function shop_ent.get_bug_item_func(item_name)
    local buy_data = {}
    for _, v in pairs(shop_ent.buy_item_func()) do
        if string.find(item_name, _) then
            buy_data = v
            break
        end
    end
    return buy_data
end

---------------------------------------------------------------------
-- [功能] 计算红药水购买量
--
-- @tparam       string      item_name           物品名（韩）
-- @treturn      boolean
-- @usage
-- local bool = shop_ent.can_buy_hp(物品名（韩）)
---------------------------------------------------------------------
function shop_ent.can_buy_hp_num()
    local buy_num = 1500 - item_ent.get_item_num_by_name('생명력 물약(귀속)', 0)
    local can_buy_num = common.calc_num(buy_num, 15, 20000)
    return can_buy_num
end

---------------------------------------------------------------------
-- [功能] 计算瞬移卷轴购买量
--
-- @tparam       string      item_name           物品名（韩）
-- @treturn      boolean
-- @usage
-- local bool = shop_ent.can_buy_sunyi_num(物品名（韩）)
---------------------------------------------------------------------
function shop_ent.can_buy_sunyi_num()
    local buy_num = 100 - item_ent.get_item_num_by_name('순간 이동 주문서(귀속)', 0)
    local can_buy_num = common.calc_num(buy_num, 800, 20000)
    return can_buy_num
end

---------------------------------------------------------------------
-- [功能] 计算瞬移卷轴购买量
--
-- @tparam       string      item_name           物品名（韩）
-- @treturn      boolean
-- @usage
-- local bool = shop_ent.can_buy_sunyi_num(物品名（韩）)
---------------------------------------------------------------------
function shop_ent.can_buy_gongsu_num()
    local buy_num = 100 - item_ent.get_item_num_by_name('돌격의 영약(귀속)', 0)
    local can_buy_num = common.calc_num(buy_num, 800, 20000)
    return can_buy_num
end


------------------------------------------------------------------------------------
-- [读取] 根据物品名获取购买物品信息
--
-- @tparam                string                    item_name       购买物品名
-- @treturn               list                                      返回包含购买物品的所有信息表 包括
-- @tfield[list]          number                    obj             物品实例对象
-- @tfield[list]          string                    name            物品名称
-- @tfield[list]          number                    res_ptr         物品资源指针
-- @tfield[list]          number                    id              物品ID
-- @tfield[list]          number                    res_id          物品资源ID
-- @tfield[list]          number                    type            物品类型
-- @tfield[list]          number                    price           物品单价
-- @tfield[list]          boolean                   can_buy         是否可购买
-- @usage
-- local item_list = shop_ent.get_item_info_by_name('购买物品名')
------------------------------------------------------------------------------------
function shop_ent.get_item_info_by_name(item_name)
    local item_info = {}
    local npc_shop_ctx = npc_shop_unit:new()
    local list = npc_shop_unit.list()
    for i = 1, #list do
        local obj = list[i]
        if npc_shop_ctx:init(obj) and npc_shop_ctx:name() == item_name then
            -- 生命药水同名价格判断
            if item_name ~= '생명력 물약(귀속)' or npc_shop_ctx:price() == 15 then
                if not shop_ent.is_not_buy_id(npc_shop_ctx:id()) then
                    item_info = {
                        -- 物品指针
                        obj = obj,
                        -- 物品资源指针
                        res_ptr = npc_shop_ctx:res_ptr(),
                        -- 物品ID
                        id = npc_shop_ctx:id(),
                        -- 物品资源ID
                        res_id = npc_shop_ctx:res_id(),
                        -- 物品类型
                        type = npc_shop_ctx:type(),
                        -- 物品价格
                        price = npc_shop_ctx:price(),
                        -- 物品是否可购买
                        can_buy = true,
                        -- 物品名
                        name = item_name
                    }
                    break
                end
            end
        end
    end
    npc_shop_ctx:delete()
    return item_info
end

function shop_ent.is_not_buy_id(id)
    if shop_ent.not_buy_id[id] and shop_ent.not_buy_id[id].num >= 2 then
        return true
    end
    return false
end

--------------------------------------------------------------------------------
-- [读取] 购买物品信息表
--
-- @treturn             table           buy_data            返回物品购买方法表 包括
-- @tfield[t]           func            can_buy_func        判断是否可以购买
-- @tfield[t]           string          npc_type            购买商人名
-- @tfield[t]           number          can_buy_num         购买数量
-- @usage
-- shop_ent.buy_item_func()
--------------------------------------------------------------------------------
function shop_ent.buy_item_func()
    local buy_item = {
        ['技能书'] = { can_buy_func = shop_ent.can_buy_skill_book, npc_type = '技能书商人', can_buy_num = 1 },
        ['药水'] = { can_buy_func = shop_ent.can_buy_hp, npc_type = '杂货商人', can_buy_num = shop_ent.can_buy_hp_num() },
        ['生命护身符（绿）'] = { can_buy_func = shop_ent.can_buy_smhf, npc_type = '遗物商人', can_buy_num = 1 },
        ['瞬移卷轴'] = { can_buy_func = shop_ent.can_buy_sunyi, npc_type = '杂货商人', can_buy_num = shop_ent.can_buy_sunyi_num() },

        ['蓝色攻速灵药'] = { can_buy_func = shop_ent.can_buy_gongsu, npc_type = '杂货商人', can_buy_num = shop_ent.can_buy_gongsu_num() },

    }
    return buy_item
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function shop_ent.__tostring()
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
function shop_ent.__newindex(t, k, v)
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
shop_ent.__index = shop_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function shop_ent:new(args)
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
    return setmetatable(new, shop_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return shop_ent:new()

-------------------------------------------------------------------------------------
