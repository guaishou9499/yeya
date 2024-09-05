------------------------------------------------------------------------------------
-- game/entities/item_ent.lua
--
-- 这个模块主要是项目内物品相关功能操作。
--
-- @module      item_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-03-22
-- @copyright   2023
-- @usage
-- local item_ent = import('game/entities/item_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class item_ent
local item_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION        = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE    = '2023-03-22 - Initial release',
    -- 模块名称
    MODULE_NAME    = 'item_ent module',
    -- 只读模式
    READ_ONLY      = false,
}

-- 自身单元
local this         = item_ent
-- 日志模块
local trace        = trace
-- 决策模块
local decider      = decider
local common       = common
local pairs        = pairs
local table        = table
local ipairs       = ipairs
local setmetatable = setmetatable
local item_unit    = item_unit
local item_ctx     = item_ctx
local creature_unit= creature_unit
local dungeon_unit = dungeon_unit
local actor_unit   = actor_unit
local import       = import
local item_res     = import('game/resources/item_res')
---@type skill_ent
local skill_ent    = import('game/entities/skill_ent')
---@type ui_ent
local ui_ent       = import('game/entities/ui_ent')
local dungeon_res  = import('game/resources/dungeon_res')
------------------------------------------------------------------------------------
-- [事件]预载函数(重载脚本时)
------------------------------------------------------------------------------------
item_ent.super_preload = function()
    -- [行为] 使用选择箱子
    this.wa_use_box_by_item_info  = decider.run_action_wrapper('[行为]使用选择箱子', this.use_box_by_item_info)
    -- [行为] 使用物品
    this.wa_use_item_by_item_info = decider.run_action_wrapper('[行为]使用物品', this.use_item_by_item_info)
    -- [行为] 删除物品
    this.wa_del_item_by_item_info = decider.run_action_wrapper('[行为]删除物品', this.del_item_by_item_info)
    -- [行为] 分解物品
    this.wa_deco_item_by_id_list  = decider.run_action_wrapper('[行为]分解物品', this.deco_item_by_id_list)
    -- 等待物品使用发生变化
    local action_name = function(item_info,deco)
        local str = ''
        if deco then
            str = '分解数['..#item_info..'].'
        else
            str = '使用(' .. item_info.name .. ')中.'
        end
        trace.output(str)
        trace.log_debug(str)
        decider.sleep(3000)
        if not deco then
            ui_ent.close_use_fb_stuff_win()
        end
    end
    local cond_func  = function(item_info,deco)
        -- 获取当前物品对应数量
        local res_id = deco and item_info or item_info.res_id
        local num    = this.get_item_num_by_res_id(res_id)
        return table.is_empty(item_info) or not table.is_empty(item_info) and num ~= item_info.num
    end
    this.wr_wait_change_item = decider.run_until_wrapper(action_name, cond_func, 15)
end

------------------------------------------------------------------------------------
-- [行为] 自动使用物品
------------------------------------------------------------------------------------
item_ent.auto_use_item = function()
    if item_unit.has_auto_equip_widget() then
        -- 对话关闭
        common.execute_pass_dialog()
        common.set_sleep(0)
        item_unit.auto_equip()
        decider.sleep(2000)
    end
    -- 保存分解列表
    local deco_list = {}
    -- 保存分解物品名称，输出信息用
    local deco_name = {}
    -- 标记是否关闭背包
    local close_bag = false
    local item_info = this.get_item_info(0)
    for i = 1, #item_info do
        if item_info[i].res_data then
            if item_info[i].res_data.equip_pos == '灵药' then
                --      xxmsg('使用' .. item_info[i].res_data.c_name)
                --this.wa_use_item_by_item_info(item_info[i])
                --decider.sleep(1000)
            elseif item_info[i].res_data.equip_pos == '滑翔机' then
                -- xxmsg('使用' .. item_info[i].res_data.c_name)
                this.wa_use_item_by_item_info(item_info[i])
                close_bag = true
                decider.sleep(2000)
            elseif item_info[i].res_data.equip_pos == '技能书' then
                if item_info[i].res_data.job == '弓箭' then
                    -- 配对技能等级
                    if skill_ent.can_use_skill_book(item_info[i].name) then
                        this.wa_use_item_by_item_info(item_info[i])
                        decider.sleep(2000)
                        close_bag = true
                    end
                end
            elseif item_info[i].res_data.equip_pos == '夜鸦箱子' then
                -- xxmsg('使用' .. item_info[i].res_data.c_name)
                this.wa_use_item_by_item_info(item_info[i])
                close_bag = true
                decider.sleep(2000)
            elseif item_info[i].res_data.equip_pos == '箱子' then
                -- xxmsg('使用' .. item_info[i].res_data.c_name)
                this.wa_use_item_by_item_info(item_info[i])
                close_bag = true
                decider.sleep(2000)
            elseif item_info[i].res_data.equip_pos == '选择箱' then

                local sel_idx = item_info[i].res_data.sel_idx
                if sel_idx and sel_idx >= 0 and item_info[i].type == 3 then
                    this.wa_use_box_by_item_info(item_info[i],sel_idx)
                    close_bag = true
                    decider.sleep(2000)
                end

            elseif item_info[i].res_data.equip_pos == '召唤券' then
                -- xxmsg('使用' .. item_info[i].res_data.c_name)
                if this.wa_use_item_by_item_info(item_info[i]) then
                    close_bag = true
                    if creature_unit.has_gacha_scene() then
                        decider.sleep(2000)
                        creature_unit.close_gacha_scene()
                        decider.sleep(3000)
                    end
                end
            elseif item_info[i].res_data.equip_pos == '补充石' then
                if item_info[i].res_data.supplement and this.can_use_supplement(item_info[i].res_data.supplement) then
                    this.wa_use_item_by_item_info(item_info[i],true)
                    close_bag = true
                    decider.sleep(2000)
                end
            else
                -- 未装备使用
                if not this.equip_is_ues(item_info[i].id) then
                    if item_res.is_can_del_by_name(item_info[i].res_data.h_name) or item_res.is_can_del_by_name(item_info[i].res_data.c_name) then
                        -- 删除物品
                        this.wa_del_item_by_item_info(item_info[i])
                        close_bag = true
                        decider.sleep(2000) --item_info[i].num == 1 and
                    elseif  (item_res.is_can_deco_by_name(item_info[i].res_data.h_name) or item_res.is_can_deco_by_name(item_info[i].res_data.c_name)) then
                        -- 记录分解物品
                        table.insert(deco_list,item_info[i].id)
                        table.insert(deco_name,item_info[i].name)
                    end
                else
                
                end
            end
        end
        -- 白色装备分解
        if item_info[i].type == 0 and item_info[i].quality == 1 then
            if not this.equip_is_ues(item_info[i].id) then
                table.insert(deco_list,item_info[i].id)
                table.insert(deco_name,item_info[i].name)
            end
        end
    end
    -- 分解物品
    if not table.is_empty(deco_list) then
        -- 剔除重复
        deco_list = common.filter_duplicatedata(deco_list)
        --local str = '分解：'
        --for _,v in pairs(deco_name) do
        --    str = str..','..v
        --end
        --xxmsg(str)
        this.wa_deco_item_by_id_list(deco_list)
        close_bag = true
    end
    -- 是否关闭背包
    if close_bag then
        common.handle_bag(0)
    end
end

------------------------------------------------------------------------------------
-- [条件] 是否打开背包界面
------------------------------------------------------------------------------------
item_ent.is_open_bag = function()
    local ret      = false
    local open_num = 0
    while decider.is_working() do
        if item_unit.is_open_inventory() then
            ret = true
            break
        end
        if open_num > 2 then break end
        common.set_sleep(0)
        ui_ent.close_window_list()
        common.execute_pass_dialog()
        item_unit.open_inventory()
        open_num = open_num + 1
        decider.sleep(3000)
    end
    return ret,not ret and '打开背包失败' or ''
end

------------------------------------------------------------------------------------
-- [条件] 是否打开分解界面
------------------------------------------------------------------------------------
item_ent.is_open_deco = function()
    local ret      = false
    local open_num = 0
    while decider.is_working() do
        if not this.is_open_bag() then
            break
        end
        if item_unit.is_open_decompose() then
            ret = true
            break
        end
        if open_num > 2 then break end
        common.set_sleep(0)
        common.execute_pass_dialog()
        item_unit.open_decompose()
        open_num = open_num + 1
        decider.sleep(3000)
    end
    return ret,not ret and '打开背包失败' or ''
end

------------------------------------------------------------------------------------
-- [行为] 分解指定物品列表
------------------------------------------------------------------------------------
item_ent.deco_item_by_id_list = function(id_list)
    if table.is_empty(id_list) then
        return false, '传入的物品信息不存在'
    end
    if item_ent.is_open_deco() then
        -- 对话关闭
        common.execute_pass_dialog()
        item_unit.decomopse(id_list)
        decider.sleep(3000)
        ui_ent.close_window_list()
        if this.wr_wait_change_item(id_list,true) then
            common.handle_bag(0)
            return true
        end
        return false, '分解物品失败'
    end
    return false, '分解窗口未打开'
end

------------------------------------------------------------------------------------
-- [行为] 删除指定物品
------------------------------------------------------------------------------------
item_ent.del_item_by_item_info = function(item_info)
    if table.is_empty(item_info) then
        return false, '传入的物品信息不存在'
    end
    local info = this.get_item_info_by_id(item_info.id)
    if table.is_empty(info) then
        return false, '['..item_info.name..']已不存在'
    end
    if this.is_open_bag() then
        common.set_sleep(0)
        -- 对话关闭
        common.execute_pass_dialog()
        item_unit.del_item(item_info.id)
        decider.sleep(2000)
        ui_ent.close_window_list()
        if this.wr_wait_change_item(item_info) then
            return true
        end
        return false, '删除['..item_info.name..']失败'
    end
    return false,'删除['..item_info.name..']背包未打开'
end

------------------------------------------------------------------------------------
-- [行为] 使用指定物品
------------------------------------------------------------------------------------
item_ent.use_item_by_name = function(args, key)
    local item_info = this.get_item_info_by_any(args, key)
    if not table.is_empty(item_info) then
        this.wa_use_item_by_item_info(item_info)
    end
end

------------------------------------------------------------------------------------
-- [行为] 使用物品根据物品传入的物品信息
------------------------------------------------------------------------------------
item_ent.use_item_by_item_info = function(item_info,is_fb)
    if table.is_empty(item_info) then
        return false, '传入的物品信息不存在'
    end
    local info = this.get_item_info_by_id(item_info.id)
    if table.is_empty(info) then
        return false, '['..item_info.name..']已不存在'
    end
    common.set_sleep(0)
    if this.is_open_bag() then
        -- 对话关闭
        common.execute_pass_dialog()
        if is_fb then
            -- xxmsg(item_info.id..'----'..item_info.num)
            dungeon_unit.add_dungeon_time(item_info.id,1)
        else
            item_unit.use_item(item_info.id, 1)
        end
        decider.sleep(3000)
        ui_ent.close_window_list()
        if this.wr_wait_change_item(item_info) then
            return true
        end
        return false, '使用['..item_info.name..']失败'
    end
    return false,'使用['..item_info.name..']背包未打开'
end

------------------------------------------------------------------------------------
-- [行为] 使用物品根据物品传入的物品信息
item_ent.use_box_by_item_info = function(item_info,sel_idx)
    if table.is_empty(item_info) then
        return false, '传入的物品信息不存在'
    end
    local info = this.get_item_info_by_id(item_info.id)
    if table.is_empty(info) then
        return false, '['..item_info.name..']已不存在'
    end
    common.set_sleep(0)
    if this.is_open_bag() then
        -- 对话关闭
        common.execute_pass_dialog()
        item_unit.use_box( item_info.id, item_info.num,sel_idx )
        decider.sleep(2000)
        ui_ent.close_window_list()
        if this.wr_wait_change_item(item_info) then
            return true
        end
        return false, '打开箱子['..item_info.name..']失败'
    end
    return false,'打开箱子['..item_info.name..']背包未打开'
end

------------------------------------------------------------------------------------
-- [条件] 是否使用补充物品
------------------------------------------------------------------------------------
item_ent.can_use_supplement = function(supplement)
    local is_use = false
    local dungeon_info = dungeon_res.DUNGEON_INFO[supplement]
    local my_map_id    = actor_unit.map_id()
    for i = 1, #dungeon_info do
        local dungeon_map_id = dungeon_info[i].map_id
        if dungeon_map_id == my_map_id then
            is_use = true
            break
        end
    end
    return is_use
end

------------------------------------------------------------------------------------
-- [条件] 判断装备是否已经装备上
--
-- @tparam              number                   equip_id           装备id
-- @treturn             boolean
-- @usage
-- if item_ent.equip_is_ues(equip_id) then
--      xxmsg('该装备已佩戴')
-- end
------------------------------------------------------------------------------------
item_ent.equip_is_ues = function(equip_id)
    -- 获取所有已装备的装备信息
    local body_equip_info = this.get_item_info(1)
    -- 通过id判断装备是否使用
    for j = 1, #body_equip_info do
        if equip_id == body_equip_info[j].id then
            return true
        end
    end
    return false
end

------------------------------------------------------------------------------------
-- [读取] 根据物品名或多个物品名取物品所有数量
--
-- @tparam          any                                name                  物品名/{物品名1,物品名2,...}
-- @tparam          any                                pos_type              读取物品源[ 0 背包  1 身上 ] 默认背包
-- @treturn         number                                                   物品所有数量
-- @usage
-- local item_num = item_ent.get_item_num_by_name('A')
-- local item_num = item_ent.get_item_num_by_name({A,B})
------------------------------------------------------------------------------------
item_ent.get_item_num_by_name = function(name, pos_type)
    local item_list = this.get_item_list_by_list_name(name, pos_type)
    local num = 0
    for _, v in pairs(item_list) do
        num = num + v.num
    end
    return num
end

------------------------------------------------------------------------------------
-- [读取] 根据资源ID或多个资源ID取物品所有数量
--
-- @tparam          any                                res_id                物品资源ID/{物品资源ID1,物品资源ID2,...}
-- @tparam          any                                pos_type              读取物品源[ 0 背包  1 身上 ] 默认背包
-- @treturn         number                                                   物品所有数量
-- @usage
-- local item_num = item_ent.get_item_num_by_res_id(0x123)
-- local item_num = item_ent.get_item_num_by_res_id({0x123,0x124})
------------------------------------------------------------------------------------
item_ent.get_item_num_by_res_id = function(res_id, pos_type)
    local item_list = this.get_item_list_by_list_res_id(res_id, pos_type)
    local num = 0
    for _, v in pairs(item_list) do
        num = num + v.num
    end
    return num
end

------------------------------------------------------------------------------------
-- [读取] 根据资源ID取物品ID
--
-- @tparam          number                     res_id                物品资源ID
-- @tparam          any                        pos_type              读取物品源[ 0 背包  1 身上 ] 默认背包
-- @treturn         number                                           物品ID
-- @usage
-- local item_id = item_ent.get_item_id_by_res_id(0x123)
------------------------------------------------------------------------------------
item_ent.get_item_id_by_res_id = function(res_id, pos_type)
    local item_info = this.get_item_info_by_res_id(res_id, pos_type)
    return not table.is_empty(item_info) and item_info.id or 0
end

------------------------------------------------------------------------------------
-- [读取] 根据物品名取物品ID
--
-- @tparam          string                     name                物品名称
-- @tparam          any                        pos_type            读取物品源[ 0 背包  1 身上 ] 默认背包
-- @treturn         number                                         物品ID
-- @usage
-- local item_id = item_ent.get_item_id_by_name('物品名称')
------------------------------------------------------------------------------------
item_ent.get_item_id_by_name = function(name, pos_type)
    local item_info = this.get_item_info_by_name(name, pos_type)
    return not table.is_empty(item_info) and item_info.id or 0
end

------------------------------------------------------------------------------------
-- [读取] 根据物品名取资源ID
--
-- @tparam          string                     name                物品名称
-- @tparam          any                        pos_type            读取物品源[ 0 背包  1 身上 ] 默认背包
-- @treturn         number                                         物品资源ID
-- @usage
-- local res_id = item_ent.get_item_res_id_by_name('物品名称')
------------------------------------------------------------------------------------
item_ent.get_item_res_id_by_name = function(name, pos_type)
    local item_info = this.get_item_info_by_name(name, pos_type)
    return not table.is_empty(item_info) and item_info.res_id or 0
end

------------------------------------------------------------------------------------
-- [读取] 根据物品名取物品信息
--
-- @tparam          string                     name                物品名称
-- @tparam          any                        pos_type            读取物品源[ 0 背包  1 身上 ] 默认背包
-- @tparam          bool                       is_use                是否被使用 默认全部
-- @treturn         table                                          返回包含物品信息表
-- @usage
-- local item_info = item_ent.get_item_info_by_name('物品名称')
------------------------------------------------------------------------------------
item_ent.get_item_info_by_name = function(name, pos_type, is_use)
    return this.get_item_info_by_any(name, 'name', pos_type,is_use)
end

------------------------------------------------------------------------------------
-- [读取] 根据物品资源ID取物品信息
--
-- @tparam          number                     res_id                物品资源ID
-- @tparam          any                        pos_type              读取物品源[ 0 背包  1 身上 ] 默认背包
-- @tparam          bool                       is_use                是否被使用 默认全部
-- @treturn         table                                            返回包含物品信息表
-- @usage
-- local item_info = item_ent.get_item_info_by_res_id(0x123)
--
------------------------------------------------------------------------------------
item_ent.get_item_info_by_res_id = function(res_id, pos_type,is_use)
    return item_ent.get_item_info_by_any(res_id, 'res_id', pos_type,is_use)
end

------------------------------------------------------------------------------------
-- [读取] 根据物品ID取物品信息
--
-- @tparam          number                     id                    物品ID
-- @tparam          any                        pos_type              读取物品源[ 0 背包  1 身上 ] 默认背包
-- @treturn         table                                            返回包含物品信息表
-- @usage
-- local item_info = item_ent.get_item_info_by_id(0x123)
------------------------------------------------------------------------------------
item_ent.get_item_info_by_id = function(id, pos_type)
    return item_ent.get_item_info_by_any(id, 'id', pos_type)
end

------------------------------------------------------------------------------------
-- [读取] 根据物品名或者物品名表-返回多个物品信息的表
--
-- @tparam          any                        item_list_name          需要配对的物品名或物品名表
-- @tparam          number                     pos_type                读取位置【0背包 1身上】默认0
-- @treturn         table                                              返回多个物品信息的表
-- @usage
-- local item_list = item_ent.get_item_list_by_list_name(item_list_name, pos_type)
-- 字段属性从item_ent.get_item_list_by_list_any 通用函数中取出
------------------------------------------------------------------------------------
item_ent.get_item_list_by_list_name = function(item_list_name, pos_type)
    return this.get_item_list_by_list_any(item_list_name, 'name', pos_type)
end

------------------------------------------------------------------------------------
-- [读取] 根据物品ID或物品ID表-返回多个物品信息的表
--
-- @tparam          any                        item_list_id            需要配对的物品ID或物品ID表
-- @tparam          number                     pos_type                读取位置【0背包 1身上】默认0
-- @treturn         table                                              返回多个物品信息的表
-- @usage
-- local item_list = item_ent.get_item_list_by_list_id(item_list_id, pos_type)
-- 字段属性从item_ent.get_item_list_by_list_any 通用函数中取出
------------------------------------------------------------------------------------
item_ent.get_item_list_by_list_id = function(item_list_id, pos_type)
    return this.get_item_list_by_list_any(item_list_id, 'id', pos_type)
end

------------------------------------------------------------------------------------
-- [读取] 根据物品资源ID或者资源ID表-返回多个物品信息的表
--
-- @tparam          any                        item_list_res_id        需要配对的物品资源ID或者资源ID表
-- @tparam          number                     pos_type                读取位置【0背包 1身上】默认0
-- @treturn         table                                              返回多个物品信息的表
-- @usage
-- local item_list = item_ent.get_item_list_by_list_res_id(item_list_res_id, pos_type)
-- 字段属性从item_ent.get_item_list_by_list_any 通用函数中取出
------------------------------------------------------------------------------------
item_ent.get_item_list_by_list_res_id = function(item_list_res_id, pos_type)
    return this.get_item_list_by_list_any(item_list_res_id, 'res_id', pos_type)
end

------------------------------------------------------------------------------------
-- [读取] 根据物品任意字段或多个字段值返回包含物品信息的所有物品表
--
-- @tparam                any                      args           物品任意字段:名字，资源 或{名字,名字,..},{id1,id2,..}..等
-- @tparam                string                   any_key        物品属性值(字段)
-- @tparam                number                   pos_type       读取位置【0背包 1身上】默认0
-- @treturn               list                                    返回包含物品信息的所有物品表 包括
-- @tfield[list]          number                   obj            物品实例对象
-- @tfield[list]          string                   name           物品名称
-- @tfield[list]          number                   res_ptr        物品资源指针
-- @tfield[list]          number                   id             物品ID
-- @tfield[list]          number                   type           物品类型
-- @tfield[list]          number                   num            物品数量
-- @tfield[list]          number                   weight         物品负重
-- @tfield[list]          number                   equip_type     装备类型
-- @tfield[list]          number                   equip_job      装备职业
-- @tfield[list]          number                   enhanced_level 强化等级
-- @tfield[list]          number                   quality        物品品质
-- @tfield[list]          number                   res_id         物品资源ID
-- @usage
-- local item_list = item_ent.get_item_list_by_list_any('生命药水（小）', 'name', 0)
-- local item_list = item_ent.get_item_list_by_list_any({'生命药水（小）','生命药水（大）'}, 'name', 0)
-- local item_list = item_ent.get_item_list_by_list_any(0x123, 'id', 0)
-- local item_list = item_ent.get_item_list_by_list_any({0x123,0x1234}, 'id', 0)
------------------------------------------------------------------------------------
item_ent.get_item_list_by_list_any = function(args, any_key, pos_type)
    pos_type = pos_type or 0
    local r_tab = {}
    local list = item_unit.list(pos_type)
    for _, obj in ipairs(list) do
        if item_ctx:init(obj, pos_type) then
            -- 获取指定属性的值
            local _any = item_ctx[any_key](item_ctx)
            local num  = item_ctx:num()
            if num > 0 then
                -- 当前对象 是否需获取的目标
                if common.is_exist_list_arg(args, _any) then
                    local name         = item_ctx:name()
                    local result = {
                        -- 物品实例对象
                        obj            = obj,
                        -- 物品名称
                        name           = name,
                        -- 物品资源指针
                        res_ptr        = item_ctx:res_ptr(),
                        -- 物品ID
                        id             = item_ctx:id(),
                        -- 物品类型
                        type           = item_ctx:type(),
                        -- 物品数量
                        num            = num,
                        -- 物品负重
                        weight         = item_ctx:weight(),
                        -- 装备类型
                        equip_type     = item_ctx:equip_type(),
                        -- 装备职业
                        equip_job      = item_ctx:equip_job(),         -- 副武器好像不一样
                        -- 强化等级
                        enhanced_level = item_ctx:enhanced_level(),
                        -- 物品品质
                        quality        = item_ctx:quality(),
                        -- 物品资源ID
                        res_id         = item_ctx:res_id(),
                        -- 物品是否绑定
                        is_bind        = item_res.is_bind_by_name(name),
                        --是否损坏
                        is_damage      = item_ctx:is_damage()
                    }
                    table.insert(r_tab, result)
                end
            end
        end
    end
    return r_tab
end

------------------------------------------------------------------------------------
-- [读取] 根据物品任意字段值返回物品信息表
--
-- @tparam              any                      args           物品任意字段:名字，资源 或{名字,名字,..},{id1,id2,..}..等
-- @tparam              string                   any_key        物品属性值(字段)
-- @tparam              number                   pos_type       读取位置【0背包 1身上】默认0
-- @tparam              boolean                  is_use         是否已使用
-- @treturn             table                                   返回包含所有物品信息的table
-- @tfield[table]       number                   obj            物品实例对象
-- @tfield[table]       string                   name           物品名称
-- @tfield[table]       number                   res_ptr        物品资源指针
-- @tfield[table]       number                   id             物品ID
-- @tfield[table]       number                   type           物品类型
-- @tfield[table]       number                   num            物品数量
-- @tfield[table]       number                   weight         物品负重
-- @tfield[table]       number                   equip_type     装备类型
-- @tfield[table]       number                   equip_job      装备职业
-- @tfield[table]       number                   enhanced_level 强化等级
-- @tfield[table]       number                   quality        物品品质
-- @tfield[table]       number                   res_id         物品资源ID
-- @usage
-- local item_info = item_ent.get_item_info_by_any('生命药水', 'name', 0)
-- local item_info = item_ent.get_item_info_by_any(0x123, 'id', 0)
------------------------------------------------------------------------------------
item_ent.get_item_info_by_any = function(args, any_key, pos_type,is_use)
    pos_type = pos_type or 0
    local r_tab = {}
 
    local item_obj = item_unit:new()
    local list     = item_unit.list(pos_type)
    for _, obj in ipairs(list) do
        if item_obj:init(obj) then
            -- 获取指定属性的值
            local _any = item_obj[any_key](item_obj)
            local num  = item_obj:num()
            local id   = item_obj:id()
            local is_r = true
            if is_use ~= nil then
                if this.equip_is_ues(id) ~= is_use then
                    is_r = false
                end
            end
            -- 配对目标值
            if args == _any and num > 0 and is_r then
                -- 用CTX貌似容易出现错乱 比如传入的key为name  _any = args  那理论上 item_obj:name() = _any  ,结果却不是  用 new方式 正常
                local name           = item_obj:name()
                -- 物品实例对象
                r_tab.obj            = obj
                -- 物品名称
                r_tab.name           = name
                -- 物品资源指针
                r_tab.res_ptr        = item_obj:res_ptr()
                -- 物品ID
                r_tab.id             = id
                -- 物品资源ID
                r_tab.res_id         = item_obj:res_id()
                -- 物品类型
                r_tab.type           = item_obj:type()
                -- 物品数量
                r_tab.num            = num
                -- 物品负重
                r_tab.weight         = item_obj:weight()
                -- 装备类型
                r_tab.equip_type     = item_obj:equip_type()
                -- 装备职业
                r_tab.equip_job      = item_obj:equip_job()          -- 副武器好像不一样
                -- 强化等级
                r_tab.enhanced_level = item_obj:enhanced_level()
                -- 物品品质
                r_tab.quality        = item_obj:quality()
                -- 判断是否绑定
                r_tab.is_bind        = item_res.is_bind_by_name(name)
                --是否损坏
                r_tab.is_damage      = item_obj:is_damage()
                break
            end
        end
    end
    item_obj:delete()
    return r_tab
end

------------------------------------------------------------------------------------
-- [读取] 获取背包所有物品
--
-- @tparam              number                   bag_type       读取位置【0背包 1身上】默认0
-- @treturn             table                                   返回包含所有物品信息的table
-- @tfield[table]       number                   obj            物品实例对象
-- @tfield[table]       string                   name           物品名称
-- @tfield[table]       number                   res_ptr        物品资源指针
-- @tfield[table]       number                   id             物品ID
-- @tfield[table]       number                   type           物品类型
-- @tfield[table]       number                   num            物品数量
-- @tfield[table]       number                   weight         物品负重
-- @tfield[table]       number                   equip_type     装备类型
-- @tfield[table]       number                   equip_job      装备职业
-- @tfield[table]       number                   enhanced_level 强化等级
-- @tfield[table]       number                   quality        物品品质
-- @tfield[table]       number                   res_id         物品资源ID
-- @usage
-- local item_info = item_ent.get_item_info(bag_type)
------------------------------------------------------------------------------------
function item_ent.get_item_info(bag_type)
    local ret_t    = {}
    bag_type       = bag_type or 0
    local list     = item_unit.list(bag_type)
    local item_obj = item_unit:new()
    for _,obj in pairs(list) do
        if item_obj:init(obj) then
            local name  = item_obj:name()
            local num   = item_obj:num()
            if num > 0 then
                local tmp_t = {
                    obj            = obj,
                    res_ptr        = item_obj:res_ptr(),
                    id             = item_obj:id(),
                    res_id         = item_obj:res_id(),
                    type           = item_obj:type(),
                    num            = item_obj:num(),
                    weight         = item_obj:weight(),
                    equip_type     = item_obj:equip_type(),
                    equip_job      = item_obj:equip_job(),            -- 副武器好像不一样
                    enhanced_level = item_obj:enhanced_level(),       --强化等级
                    quality        = item_obj:quality(),
                    name           = name,
                    -- 判断是否绑定
                    is_bind        = item_res.is_bind_by_name(name),
                    --是否损坏
                    is_damage      = item_obj:is_damage()
                }
                if item_res.ITEM_LIST[tmp_t.name] then
                    tmp_t.res_data = item_res.ITEM_LIST[tmp_t.name]
                else
                    --    xxmsg(string.format('[0x%X] = \'123456\',      -- %s', tmp_t.res_id, tmp_t.name))
                end
                table.insert(ret_t, tmp_t)
            end
        end
    end
    item_obj:delete()
    return ret_t
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function item_ent.__tostring()
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
item_ent.__newindex = function(t, k, v)
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
item_ent.__index = item_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function item_ent:new(args)
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
    return setmetatable(new, item_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return item_ent:new()

-------------------------------------------------------------------------------------