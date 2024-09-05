------------------------------------------------------------------------------------
-- game/entities/quick_ent.lua
--
-- 快捷设置单元
--
-- @module      quick_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local quick_ent = import('game/entities/quick_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class quick_ent
local quick_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION        = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE    = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME    = 'quick_ent module',
    -- 只读模式
    READ_ONLY      = false,
}

-- 实例对象
local this         = quick_ent
-- 日志模块
local trace        = trace
-- 决策模块
local decider      = decider
local quick_unit   = quick_unit
local rawset       = rawset
local table        = table
local pairs        = pairs
local setmetatable = setmetatable
local import       = import
local common       = common
---@type item_ent
local item_ent     = import('game/entities/item_ent')
---@type skill_ent
local skill_ent    = import('game/entities/skill_ent')
---@type skill_res
local skill_res    = import('game/resources/skill_res')
---@type quick_res
local quick_res    = import('game/resources/quick_res')

------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function quick_ent.super_preload()
    -- [行为] 取消/激活
    this.wa_active_quick_skill = decider.run_action_wrapper('取消/激活',quick_unit.active_quick_skill)
    -- [行为] 设置快捷
    this.wa_set_quick_item     = decider.run_action_wrapper('设置物品快捷',quick_unit.set_quick_item)
    -- [行为] 取消/激活
    this.wa_set_quick_skill    = decider.run_action_wrapper('设置技能快捷',quick_unit.set_quick_skill)
end

-------------------------------------------------------------------------------------
-- 检测指定目标是否可设置快捷
-------------------------------------------------------------------------------------
quick_ent.auto_set_quick_ex = function(set_special)
    -- 可设置快捷的技能/物品
    local can_set_list = quick_res.CAN_SET_LIST
    if set_special == 1 then
        can_set_list[5] = { {'필승의 영약(귀속)',2} }--白色必胜的灵药
        can_set_list[6] = { {'돌격의 영약(귀속)',2} }--蓝色攻速灵药
        can_set_list[7] = { { '크림 스튜(귀속)',2 },{ '파수의 영약(귀속)',2 } }--绿色防御灵药
    elseif set_special == 2 then
        for _,v in pairs( { 5,6,7 } ) do
            can_set_list[v] = nil
            if quick_unit.quick_is_active(v) then
                this.active_quick(v,false)
            end
        end
    elseif set_special == '副本' then
        can_set_list[5] = { {'필승의 영약(귀속)',2} }--白色必胜的灵药
        can_set_list[6] = { {'돌격의 영약(귀속)',2} }--蓝色攻速灵药
        can_set_list[7] = { { '[이벤트] 밤까마귀 성장 비약(귀속)',2 },{ '밤까마귀 성장 비약(귀속)',2 } }--经验药水
    elseif set_special == '挂机' then
        for _,v in pairs( { 6,7 } ) do
            can_set_list[v] = nil
            if quick_unit.quick_is_active(v) then
                this.active_quick(v,false)
            end
        end
        can_set_list[5] = { { '[이벤트] 밤까마귀 성장 비약(귀속)',2 },{ '밤까마귀 성장 비약(귀속)',2 } }
    end
    -- 目标是否已设置
    for i = 0, 7 do
        local set_list        = can_set_list[i]
        if set_list then
            local is_clear_active = true
            -- 检测当前位置是否清除激活
            if quick_unit.get_quick_item_type(i) ~= 0 then
                local res_id   = quick_unit.get_quick_item_id(i)
                for _,v in pairs(set_list) do
                    local name     = v[1]
                    local set_type = v[2]
                    if set_type == 2 then
                        local num = item_ent.get_item_num_by_res_id(res_id)
                        if num > 0 then
                            is_clear_active = false
                            break
                        end
                    elseif set_type == 1 then
                        local skill_info = skill_ent.get_skill_info_by_group_id(res_id)
                        if not table.is_empty(skill_info) then
                            is_clear_active = false
                            break
                        end
                    end
                end
                -- 如果需要清除激活目标
                if is_clear_active and quick_unit.quick_is_active(i) then
                    this.active_quick(i,false)
                end
            end
            -- 设置快捷
            if is_clear_active then
                for _,v in pairs(set_list) do
                    local name     = v[1]
                    local set_type = v[2]
                    if set_type == 2 then
                        local item_info = item_ent.get_item_info_by_name(name)
                        if not table.is_empty(item_info) then
                            trace.output('设置物品快捷',i,name)
                            common.set_sleep(0)
                            common.execute_pass_dialog()
                            decider.sleep(1000)
                            this.wa_set_quick_item(i, item_info.id)
                            decider.sleep(2000)
                            is_clear_active = false
                            break
                        end
                    elseif set_type == 1 then
                        local skill_info = skill_ent.get_skill_info_by_name(name)
                        if not table.is_empty(skill_info) and skill_info.is_study then -- and skill_info.level == 1
                            trace.output('设置技能快捷',i,name,'['..skill_info.h_name..']')
                            trace.log_debug('设置技能快捷',i,name,'['..skill_info.h_name..']')
                            common.set_sleep(0)
                            common.execute_pass_dialog()
                            decider.sleep(1000)
                            this.wa_set_quick_skill(i, skill_info.id)
                            decider.sleep(2000)
                            is_clear_active = false
                            break
                        end
                    end
                end
            end
            -- 激活快捷
            if not is_clear_active and not quick_unit.quick_is_active(i) then
                this.active_quick(i,true)
            end
        end
    end
end

-------------------------------------------------------------------------------------
-- 激活/取消激活>物品/技能
-------------------------------------------------------------------------------------
quick_ent.active_quick = function(idx,active_hand)
    local item_type = quick_unit.get_quick_item_type(idx)
    local active_str = active_hand and '激活' or '取消激活'
    local str       = item_type == 2 and active_str..'物品快捷' or item_type == 1 and active_str..'技能快捷' or ''
    if str ~= '' then
        trace.output(str,idx)
        common.set_sleep(0)
        common.execute_pass_dialog()
        decider.sleep(1000)
        this.wa_active_quick_skill(idx, active_hand)
        decider.sleep(2000)
    end
end

-------------------------------------------------------------------------------------
--[行为] 设置技能
-------------------------------------------------------------------------------------
quick_ent.auto_set_quick = function()
    -- 获取所有技能信息
    local skill_info = skill_ent.skill_info()
    for i = 0, 7 do
        -- 技能是否设置
        if quick_unit.get_quick_item_type(i) == 0 then
            for m = 1, #skill_info do
                if skill_res.can_quick_by_name(skill_info[m].name) then
                    local set_skill = true
                    for n = 0, 7 do
                        if skill_info[m].group_id == quick_unit.get_quick_item_id(n) then
                            set_skill = false
                        end
                    end
                    if set_skill then
                        xxmsg('快捷栏位'..i..'|技能id'..string.format('0x%X',skill_info[m].id))
                        quick_unit.set_quick_skill(i, skill_info[m].id)
                        xxmsg('设置' .. skill_info[m].name .. '在第' .. i .. '栏')
                        sleep(2000)
                        if not quick_unit.quick_is_active(i) then
                            quick_unit.active_quick_skill(i, true) -- 激活技能
                        end
                        break
                    end
                end
            end
        -- 技能是否激活
        elseif not quick_unit.quick_is_active(i) then
            quick_unit.active_quick_skill(i, true)
        end
    end
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function quick_ent.__tostring()
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
function quick_ent.__newindex(t, k, v)
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
quick_ent.__index = quick_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function quick_ent:new(args)
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
    return setmetatable(new, quick_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return quick_ent:new()

-------------------------------------------------------------------------------------
