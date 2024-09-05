------------------------------------------------------------------------------------
-- game/entities/equip_ent.lua
--
-- 实体示例
--
-- @module      equip_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local equip_ent = import('game/entities/equip_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class equip_ent
local equip_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME = 'equip_ent module',
    -- 只读模式
    READ_ONLY = false,
}

-- 实例对象
local this = equip_ent
-- 日志模块
local trace = trace
-- 决策模块
local decider = decider
local table = table
local item_unit = item_unit
local import = import
local common = common
---@type item_ent
local item_ent = import('game/entities/item_ent')

---@type item_res
local item_res = import('game/resources/item_res')
-- 装备列表
--local equip_list = { '武器', '箭筒', '披风', '头盔', '盔甲', '手套', '皮裤', '靴子', '耳环', '戒指', '爪符', '胸针', '腰带', '项链', '圣物A','圣物B' }
local equip_list = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 }
------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function equip_ent.super_preload()
    -- 修理装备
    this.wa_execute_repair_equip      = decider.run_action_wrapper('[行为]修理装备', this.execute_repair_equip, this.is_need_repair)
    -- 佩戴装备
    this.wa_execute_use_equipe = decider.run_action_wrapper('[行为]佩戴装备', this.execute_use_equipe, this.is_can_use_equipe)
    -- 强化装备
    this.wa_execute_enhancement_equip = decider.run_action_wrapper('[行为]强化装备', this.execute_enhancement_equip, this.is_can_enhancement)
    -- 等待装备佩戴
    local action_func = function(id, c_name)
        trace.output('正在使用装备[' .. c_name .. '].')
        decider.sleep(2000)
    end
    -- 等待装备强化
    local action_enhancement_func = function(last_item_num, need_item, c_name, max)
        trace.output('强化' .. c_name .. '到' .. max)
        decider.sleep(2000)
    end
    -- 判断装备是否可强化
    local condition = function(equip_info)
        return not equip_ent.is_can_enhancement(equip_info)
    end
    -- 等待装备佩戴
    this.wu_wait_use_equipe = decider.run_until_wrapper(action_func, this.equip_is_ues, 20)
    -- 等待装备强化
    this.wu_wait_enhancement_equip = decider.run_until_wrapper(action_enhancement_func, this.wait_enhancement_equip, 20)
    -- 等待修理完成
    this.wu_wait_repair_equip  = decider.run_until_wrapper(
            function(equip_info)
                trace.output('修理:',equip_info.name)
                decider.sleep(3000)
            end,
            function(equip_info)
                return not this.is_need_repair(equip_info)
            end,
            10
    )
end

------------------------------------------------------------------------------------
-- [行为] 执行修理指定目标
equip_ent.execute_repair_equip = function(equip_info)
    if not this.is_need_repair(equip_info) then return true end
    common.set_sleep(0)
    common.execute_pass_dialog()
    item_unit.repair_equip(equip_info.id)
    this.wu_wait_repair_equip(equip_info)
end

------------------------------------------------------------------------------------
-- [行为]自动佩戴装备
function equip_ent.ues_equip()
    for i = 1, #equip_list do
        local bast_equip, bast_equip2 = equip_ent.get_bast_equip_by_part(equip_list[i])
        this.wa_execute_use_equipe(bast_equip)
        if equip_list[i] == 11 or equip_list[i] == 10 then
            this.wa_execute_use_equipe(bast_equip2)
        end
    end
    this.enhancement_equip()
end

------------------------------------------------------------------------------------
-- [行为]自动强化装备
function equip_ent.enhancement_equip()
    if actor_unit.local_player_level() < 15 then
        return false, '等级未达到15级'
    end
    local body_equip_info = item_ent.get_item_info(1)
    for i = 1, #body_equip_info do
        local equip_info = body_equip_info[i]
        this.wa_execute_enhancement_equip(equip_info)
        this.wa_execute_repair_equip(equip_info)
    end
    -- common.handle_bag(0)
end

------------------------------------------------------------------------------------
-- [行为]佩戴指定装备
function equip_ent.execute_use_equipe(bast_equip)
    local bool,msg = this.is_can_use_equipe(bast_equip)
    if not bool then
        return false,msg
    end
    common.set_sleep(0)
    common.execute_pass_dialog()
    common.handle_bag(1)
    item_unit.use_item(bast_equip.id, 1)
    decider.sleep(2000)
    this.wu_wait_use_equipe(bast_equip.id, bast_equip.name)

    return true
end

------------------------------------------------------------------------------------
-- [行为]强化指定装备
function equip_ent.execute_enhancement_equip(equip_info)
    -- 获取需要的强化卷轴名和最大强化等级
    local need_item, max = equip_ent.max_enhancement_level(equip_info.equip_type)
    -- 通过名字获取强化卷id
    local item_id = item_ent.get_item_id_by_name(need_item, 0) ~= 0 and item_ent.get_item_id_by_name(need_item, 0) or item_ent.get_item_id_by_name('[이벤트] ' .. need_item, 0)
    -- 强化卷轴数量
    local item_num = item_ent.get_item_num_by_name({ '[이벤트] ' .. need_item, need_item }, 0)
    -- 执行强化装备
    common.set_sleep(0)
    common.execute_pass_dialog()
    common.handle_bag(1)
    item_unit.enhancement_equip(equip_info.id, item_id)
    decider.sleep(2000)
    this.wu_wait_enhancement_equip(item_num, need_item, equip_info.name, max)
    local now_item_num = item_ent.get_item_num_by_name({ '[이벤트] ' .. need_item, need_item }, 0)
    -- 通过强化卷数量判断是否强化完成
    if now_item_num == item_num then
        return false, '强化超时'
    end
    return true
end

------------------------------------------------------------------------------------
-- [行为] 等待装备强化完成
function equip_ent.wait_enhancement_equip(last_item_num, need_item, c_name, max)
    local item_num = item_ent.get_item_num_by_name({ '[이벤트] ' .. need_item, need_item }, 0)
    -- 通过强化卷数量判断是否强化完成
    if item_num < last_item_num then
        return true
    end
    return false
end

------------------------------------------------------------------------------------
-- [判断]装备是否可强化
--
-- @tparam              table                   equip_info           装备信息
-- @treturn             boolean
-- @usage
-- if equip_ent.is_can_enhancement(equip_info) then
--      xxmsg('装备可强化')
-- end
------------------------------------------------------------------------------------
function equip_ent.is_can_enhancement(equip_info)
    if table.is_empty(equip_info) then
        -- trace.log_debug('不存在装备信息')
        return false, '不存在装备信息'
    end

    if equip_info.quality < 2 then
        -- trace.log_debug(equip_info.equip_type..'装备品质低于绿色')
        if equip_info.name ~= '밤까마귀 발톱 부적(귀속)' and equip_info.name ~= '밤까마귀 깃털 브로치(귀속)' then
            return false, '装备品质低于绿色'
        end

    end
    local need_item, max = equip_ent.max_enhancement_level(equip_info.equip_type)
    if need_item == 0 then
        -- trace.log_debug(equip_info.equip_type..'装备对应未知的强化卷轴')
        return false, '装备对应未知的强化卷轴'
    end

    local enhancement_level = equip_ent.get_equip_enhancement_level(equip_info.name)
    if enhancement_level == -1 then
        -- trace.log_debug(equip_info.equip_type..'获取强化等级失败')
        return false, '获取强化等级失败'
    end
    if enhancement_level >= max then
        -- trace.log_debug(equip_info.equip_type..'大于等级最大强化等级')
        return false, '强化等级' .. enhancement_level .. '大于等级最大强化等级' .. max
    end
    local item_num = item_ent.get_item_num_by_name({ '[이벤트] ' .. need_item, need_item }, 0)
    if item_num <= 0 then
        -- trace.log_debug(equip_info.equip_type..'强化卷轴数量不足1个')
        return false, '强化卷轴数量不足1个'
    end
    return true
end

------------------------------------------------------------------------------------
-- [条件] 是否需要修理
equip_ent.is_need_repair = function(equip_info)
    if table.is_empty(equip_info) then
        return false,'传入装备不存在'
    end
    local info = item_ent.get_item_info_by_id(equip_info.id,1)
    if table.is_empty(info) then
        return false,'装备不存在'
    end
    if not info.is_damage then
        return false,'装备('..info.name..')无需修理'
    end
    local money = item_unit.get_money_byid(3)
    if money < 50000 then
        return false,'金币低于5万不修理'
    end
    return true
end

------------------------------------------------------------------------------------
-- [判断]装备是否可佩戴
--
-- @tparam              table                   bast_equip           装备信息
-- @treturn             boolean
-- @usage
-- if equip_ent.is_can_use_equipe(bast_equip) then
--      xxmsg('装备可佩戴')
-- end
------------------------------------------------------------------------------------
function equip_ent.is_can_use_equipe(bast_equip)
    if table.is_empty(bast_equip) then
        return false, '装备信息不存在'
    end
    if equip_ent.equip_is_ues(bast_equip.id) then
        return false, '装备已佩戴'
    end
    local part_info1, part_info2 = this.get_tar_part_info(bast_equip.equip_type)
    local do_equip = false
    if table.is_empty(part_info1) or table.is_empty(part_info2) then
        do_equip = true
    elseif part_info1.quality < bast_equip.quality or part_info2.quality < bast_equip.quality then
        do_equip = true
    end
    if not do_equip then
        return false, '已佩戴的装备与同类型相同'
    end
    return true
end

------------------------------------------------------------------------------------
-- [判断] 判断装备是否已经装备上
--
-- @tparam              number                   equip_id           装备id
-- @treturn             boolean
-- @usage
-- if equip_ent.equip_is_ues(equip_id) then
--      xxmsg('该装备已佩戴')
-- end
------------------------------------------------------------------------------------
function equip_ent.equip_is_ues(equip_id)
    -- 获取所有已装备的装备信息
    local body_equip_info = item_ent.get_item_info(1)
    -- 通过id判断装备是否使用
    for j = 1, #body_equip_info do
        if equip_id == body_equip_info[j].id then
            return true
        end
    end
    return false
end

------------------------------------------------------------------------------------
-- [读取] 判断装备是否匹配
-- @tparam              table                                    装备信息 包括
-- @tparam[table]       number                   obj            物品实例对象
-- @tparam[table]       string                   name           物品名称
-- @tparam[table]       number                   res_ptr        物品资源指针
-- @tparam[table]       number                   id             物品ID
-- @tparam[table]       number                   type           物品类型
-- @tparam[table]       number                   num            物品数量
-- @tparam[table]       number                   level          物品等级
-- @tparam[table]       number                   quality        物品品质
-- @tparam[table]       number                   res_id         物品资源ID
-- @usage
-- local item_list = equip_ent.is_can_set_equipe(装备信息)
------------------------------------------------------------------------------------
function equip_ent.is_can_set_equipe(equip_info)
    local ret_b = true
    if equip_info.equip_type == 0 then
        if equip_info.equip_job ~= 5 then
            ret_b = false
        end
    end
    if equip_info.equip_type == 1  then
        if not string.find(equip_info.name,'화살통') then
            ret_b = false
        end
    end
    if equip_info.quality >= 3 and not item_res.is_bind_by_name(equip_info.name) then
        ret_b = false
    end
    return ret_b
end
------------------------------------------------------------------------------------
-- [读取] 指定部位最高品质的装备
--
-- @tparam              string                   part           部位
-- @treturn             table                                   返回装备信息 包括
-- @tfield[table]       number                   obj            物品实例对象
-- @tfield[table]       string                   name           物品名称
-- @tfield[table]       number                   res_ptr        物品资源指针
-- @tfield[table]       number                   id             物品ID
-- @tfield[table]       number                   type           物品类型
-- @tfield[table]       number                   num            物品数量
-- @tfield[table]       number                   level          物品等级
-- @tfield[table]       number                   quality        物品品质
-- @tfield[table]       number                   res_id         物品资源ID
-- @usage
-- local item_list = equip_ent.get_bast_equip_by_part('武器')
------------------------------------------------------------------------------------
function equip_ent.get_bast_equip_by_part(part)
    local bag_equip_info = item_ent.get_item_info(0)
    local bast_equip = {}
    local bast_equip2 = {}
    for i = 1, #bag_equip_info do
        local equip_type = bag_equip_info[i].equip_type
        if bag_equip_info[i].type == 0 then
            if equip_type == part and equip_ent.is_can_set_equipe(bag_equip_info[i]) then
                if table.is_empty(bast_equip) then
                    bast_equip = bag_equip_info[i]
                elseif bag_equip_info[i].quality > bast_equip.quality then
                    bast_equip = bag_equip_info[i]
                elseif bag_equip_info[i].quality == bast_equip.quality then
                    if bag_equip_info[i].enhanced_level > bast_equip.enhanced_level then
                        bast_equip = bag_equip_info[i]
                    end
                end
            end
        end
    end
    if part == 11 or part == 10 then
        for i = 1, #bag_equip_info do
            local equip_type = bag_equip_info[i].equip_type
            if bag_equip_info[i].type == 0 then
                if equip_type == part and equip_ent.is_can_set_equipe(bag_equip_info[i]) then
                    if bag_equip_info[i].id ~= bast_equip.id then
                        if table.is_empty(bast_equip2) then
                            bast_equip2 = bag_equip_info[i]
                        elseif bag_equip_info[i].quality > bast_equip2.quality then
                            bast_equip2 = bag_equip_info[i]
                        elseif bag_equip_info[i].quality == bast_equip2.quality then
                            if bag_equip_info[i].enhanced_level > bast_equip2.enhanced_level then
                                bast_equip2 = bag_equip_info[i]
                            end
                        end
                    end
                end
            end
        end
    end
    return bast_equip, bast_equip2
end

-- 读取指定部位信息
function equip_ent.get_tar_part_info(part)
    local bag_equip_info = item_ent.get_item_info(1)
    local bast_equip = {}
    local bast_equip2 = {}
    for i = 1, #bag_equip_info do
        local equip_type = bag_equip_info[i].equip_type
        if equip_type == part then
            if table.is_empty(bast_equip) then
                bast_equip = bag_equip_info[i]
            else
                bast_equip2 = bag_equip_info[i]
            end
        end
    end
    return bast_equip, bast_equip2
end

------------------------------------------------------------------------------------
-- [读取] 通过装备名获取强化等级
--
-- @tparam              string          name            装备名称
-- @treturn             number                          强化等级
-- @usage
-- local enhancement_level = equip_ent.get_equip_enhancement_level('装备名称')
------------------------------------------------------------------------------------
function equip_ent.get_equip_enhancement_level(name)
    local equip_info = item_ent.get_item_info_by_name(name, 1)
    return not table.is_empty(equip_info) and equip_info.enhanced_level or -1
end

------------------------------------------------------------------------------------
-- [读取] 通过装备名获取强化等级
--
-- @tparam              string          enhancement_type            装备类型
-- @treturn             number          res_id                      强化物res_is
-- @treturn             number          max_level                   安全强化等级
-- @usage
-- local need_item, max = equip_ent.get_equip_enhancement_level('装备名称')
------------------------------------------------------------------------------------
function equip_ent.max_enhancement_level(equip_type)
    local enhancement_info = {
        [0] = { need_item = '무기 강화 주문서(귀속)', max = 7 },
        [1] = { need_item = '무기 강화 주문서(귀속)', max = 7 },
        [2] = { need_item = '방어구 강화 주문서(귀속)', max = 5 },
        [3] = { need_item = '방어구 강화 주문서(귀속)', max = 5 },
        [4] = { need_item = '방어구 강화 주문서(귀속)', max = 5 },
        [5] = { need_item = '방어구 강화 주문서(귀속)', max = 5 },
        [6] = { need_item = '방어구 강화 주문서(귀속)', max = 5 },
        [7] = { need_item = '방어구 강화 주문서(귀속)', max = 5 },
        [8] = { need_item = '장신구 강화 주문서(귀속)', max = 3 },
        [9] = { need_item = '장신구 강화 주문서(귀속)', max = 3 },
        [10] = { need_item = '장신구 강화 주문서(귀속)', max = 3 },
        [11] = { need_item = '장신구 강화 주문서(귀속)', max = 3 },
        [12] = { need_item = '밤까마귀 강화 주문서(귀속)', max = 1 },
        [13] = { need_item = '밤까마귀 강화 주문서(귀속)', max = 1 },
        [14] = { need_item = '아티팩트 강화 주문서(귀속)', max = 1 },
        [15] = { need_item = '아티팩트 강화 주문서(귀속)', max = 1 },
    }
    local need_item = enhancement_info[equip_type].need_item or 0
    local max = enhancement_info[equip_type].max or 0
    return need_item, max
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function equip_ent.__tostring()
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
function equip_ent.__newindex(t, k, v)
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
equip_ent.__index = equip_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function equip_ent:new(args)
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
    return setmetatable(new, equip_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return equip_ent:new()

-------------------------------------------------------------------------------------
