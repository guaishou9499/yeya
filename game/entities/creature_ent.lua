------------------------------------------------------------------------------------
-- game/entities/creature_ent.lua
--
-- 坐骑 滑翔机  武器图的 选择
--
-- @module      creature_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local creature_ent = import('game/entities/creature_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class creature_ent
local creature_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION                 = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE             = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME             = 'creature_ent module',
    -- 只读模式
    READ_ONLY               = false,
    -- 坐骑
    CREATURE_HORSE          = 0,
    -- 翅膀
    CREATURE_WING           = 1,
    -- 武器图
    CREATURE_WEAPON         = 2,
}

-- 实例对象
local this                  = creature_ent
-- 日志模块
local trace                 = trace
-- 决策模块
local decider               = decider

local table                 = table
local ipairs                = ipairs
local pairs                 = pairs
local game_unit             = game_unit
local creature_ctx          = creature_ctx
local creature_unit         = creature_unit
local common                = common
local import                = import
local creature_res          = import('game/resources/creature_res')
------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function creature_ent.super_preload()
    -- 使用 坐骑，翅膀， 武器图（id）
    --creature_unit.use_creature(0x50012F0E2 )
    -- 当前使用图ID 0 坐骑，1翅膀，2武器图
    -- xxmsg(creature_unit.get_cur_use_id(ntype))
    -- [行为] 使用指定类型的行为
    this.wa_used_creature_by_type = decider.run_action_wrapper('[行为]使用类型',this.execute_creature,this.is_can_use_creature)
    
    -- 等待任务变化
    local action_func     = function(str)
        common.execute_pass_dialog()
        trace.output('正在使用最高品质['..str..'].')
        decider.sleep(2000)
    end
    -- 终止条件
    local cond_func       = function(str, c_type )
        return not this.is_can_use_creature( c_type )
    end
    -- 等待任务状态改变
    this.wu_wait_change_creature_used = decider.run_until_wrapper(action_func,cond_func,20)
end

--------------------------------------------------------------------------------
-- [行为] 自动使用坐骑 翅膀  武器图
creature_ent.auto_used_creature = function()
    this.wa_used_creature_by_type(this.CREATURE_HORSE)
    this.wa_used_creature_by_type(this.CREATURE_WING)
    this.wa_used_creature_by_type(this.CREATURE_WEAPON)
end

--------------------------------------------------------------------------------
-- [行为] 使用指定类型最高品质
--------------------------------------------------------------------------------
creature_ent.execute_creature = function( c_type )
    -- 获取当前类型下的 所有信息
    local c_info_list = this.get_creature_info_list_by_type( c_type )
    local str         = this.get_creature_name_by_type( c_type )
    if table.is_empty( c_info_list ) then
        return false,'没有可用的类型('..str..')'
    end
    -- 获取最高品质的信息
    local c_info = c_info_list[1]
    if c_info.is_used then
        return false,'当前('..str..')最高类型已使用'
    end
    common.set_sleep(0)
    -- 执行使用
    creature_unit.use_creature( c_info.id )
    decider.sleep(2000)
    -- 等待类型切换变化
    if this.wu_wait_change_creature_used( str,c_type ) then
        return true
    end
    return false,'使用('..str..')-失败'
end

--------------------------------------------------------------------------------
-- [条件] 是否可使用指定类型
--------------------------------------------------------------------------------
creature_ent.is_can_use_creature = function( c_type )
    -- 获取当前类型下的 所有信息
    local c_info_list = this.get_creature_info_list_by_type( c_type )
    local str         = this.get_creature_name_by_type( c_type )
    if table.is_empty( c_info_list ) then
        return false,'没有可用的类型('..str..')'
    end
    -- 配对职业类型
    
    -- 获取最高品质的信息
    local c_info = c_info_list[1]
    if c_info.is_used then
        return false,'当前('..str..')最高类型已使用'
    end
    return true
end

--------------------------------------------------------------------------------
-- 获取传入类型对应名
--
-- @tparam       integer   c_type           类型 【0 坐骑，1翅膀，2武器图】
-- @treturn      string                     坐骑，翅膀，武器图
--------------------------------------------------------------------------------
creature_ent.get_creature_name_by_type = function(c_type)
    return c_type == this.CREATURE_HORSE and '坐骑' or c_type == this.CREATURE_WING and '翅膀' or c_type == this.CREATURE_WEAPON and '武器图' or '不存在的类型'
end

--------------------------------------------------------------------------------
-- [读取] 获取指定类型,指定字段 的类型信息
-- @tparam       integer   c_type           类型 【0 坐骑，1翅膀，2武器图】
-- @tparam       string    any_key          字段名称
-- @tparam       string    args             传入需要配对的参数值
-- @treturn      t                          包含类型信息的 table，包括：
-- @tfield[t]    integer   obj              类型实例对象
-- @tfield[t]    string    name             当前类型下的名称
-- @tfield[t]    integer   res_ptr          类型资源指针
-- @tfield[t]    integer   id               类型ID
-- @tfield[t]    integer   type             类型的类型
-- @tfield[t]    integer   num              当前类型数量
-- @tfield[t]    integer   quality          当前类型品质
-- @tfield[t]    integer   weapon_class_id  当前类型类ID
-- @tfield[t]    integer   is_used          是否在使用
--------------------------------------------------------------------------------
creature_ent.get_creature_info_by_type_and_any_key = function(c_type,any_key,args)
    local r_tab = {}
    local list = creature_unit.list(c_type)
    for _, obj in ipairs(list) do
        if creature_ctx:init(obj) then
            -- 获取指定属性的值
            local _any = creature_ctx[any_key](creature_ctx)
            local num  = creature_ctx:num()
            -- 配对目标值
            if args == _any and num > 0 then
                -- 类型实例对象
                r_tab.obj             = obj
                -- 当前类型下的名称
                r_tab.name            = creature_ctx:name()
                -- 是否在使用
                r_tab.is_used         = creature_ctx:is_used()
                -- 类型资源ID
                r_tab.res_ptr         = creature_ctx:res_ptr()
                -- 类型ID
                r_tab.id              = creature_ctx:id()
                -- 类型的类型
                r_tab.type            = creature_ctx:type()
                -- 当前类型数量
                r_tab.num             = num
                -- 当前类型品质
                r_tab.quality         = creature_ctx:quality()
                -- 武器图类型ID
                r_tab.weapon_class_id = creature_ctx:weapon_class_id()
                break
            end
        end
    end
    return r_tab
end

--------------------------------------------------------------------------------
-- [读取] 根据类型获取指定的类型信息[0 坐骑，1 翅膀 2 武器图],品质高到低排序
--
-- @static
-- @tparam       integer    c_type          读取类型
-- @treturn      t                          包含类型信息的 table，包括：
-- @tfield[t]    integer   obj              类型实例对象
-- @tfield[t]    string    name             当前类型下的名称
-- @tfield[t]    integer   res_ptr          类型资源指针
-- @tfield[t]    integer   id               类型ID
-- @tfield[t]    integer   type             类型的类型
-- @tfield[t]    integer   num              当前类型数量
-- @tfield[t]    integer   quality          当前类型品质
-- @tfield[t]    integer   weapon_class_id  当前类型类ID
-- @tfield[t]    integer   is_used          是否在使用
-- @usage
-- local info = creature_ent.get_creature_info_by_type(0)
-- print_r(info)
--------------------------------------------------------------------------------
creature_ent.get_creature_info_list_by_type = function(c_type)
    local list = creature_unit.list(c_type)
    local result_list = {}
    for _, obj in pairs(list) do
        if creature_ctx:init(obj) then
            local weapon_class_id = creature_ctx:weapon_class_id()
            if creature_res.is_weapon_jop_by_id(weapon_class_id) then
                local result = {
                    -- 类型实例对象
                    obj             = obj,
                    -- 类型资源ID
                    res_ptr         = creature_ctx:res_ptr(),
                    -- 类型ID
                    id              = creature_ctx:id(),
                    -- 类型的类型
                    type            = creature_ctx:type(),
                    -- 当前类型数量
                    num             = creature_ctx:num(),
                    -- 当前类型品质
                    quality         = creature_ctx:quality(),
                    -- 当前类型类ID
                    weapon_class_id = weapon_class_id,
                    -- 是否在使用
                    is_used         = creature_ctx:is_used(),
                    -- 当前类型下的名称
                    name            = creature_ctx:name(),
                }
                table.insert(result_list,result)
            end
        end
    end
    -- 按品质排序
    if not table.is_empty(result_list) then
        table.sort(result_list,function(a, b) return a.quality > b.quality end)
    end
    return result_list
end

------------------------------------------------------------------------------------
-- [读取] 根据类型任意字段或多个字段值返回包含类型信息的所有类型表
--
-- @tparam       any       args             类型任意字段:名字，资源 或{名字,名字,..},{id1,id2,..}..等
-- @tparam       string    any_key          类型属性值(字段)
-- @tparam       number    c_type           类型【0 坐骑，1翅膀，2武器图】
-- @treturn      list                       返回包含类型信息的所有类型表 包括
-- @tfield[t]    integer   obj              类型实例对象
-- @tfield[t]    string    name             当前类型下的名称
-- @tfield[t]    integer   res_ptr          类型资源指针
-- @tfield[t]    integer   id               类型ID
-- @tfield[t]    integer   type             类型的类型
-- @tfield[t]    integer   num              当前类型数量
-- @tfield[t]    integer   quality          当前类型品质
-- @tfield[t]    integer   weapon_class_id  当前类型类ID
-- @tfield[t]    integer   is_used          是否在使用
------------------------------------------------------------------------------------
creature_ent.get_creature_info_list_by_list_any = function(args, any_key, c_type)
    local r_tab = {}
    local list  = creature_unit.list(c_type)
    for _, obj in ipairs(list) do
        if creature_ctx:init(obj) then
            -- 获取指定属性的值
            local _any = creature_ctx[any_key](creature_ctx)
            if creature_ctx:num() > 0 then
                -- 当前对象 是否需获取的目标
                if common.is_exist_list_arg(args, _any) then
                    local result = {
                        -- 类型实例对象
                        obj             = obj,
                        -- 类型资源ID
                        res_ptr         = creature_ctx:res_ptr(),
                        -- 类型ID
                        id              = creature_ctx:id(),
                        -- 类型的类型
                        type            = creature_ctx:type(),
                        -- 当前类型数量
                        num             = creature_ctx:num(),
                        -- 当前类型品质
                        quality         = creature_ctx:quality(),
                        -- 当前类型类ID
                        weapon_class_id = creature_ctx:weapon_class_id(),
                        -- 是否在使用
                        is_used         = creature_ctx:is_used(),
                        -- 当前类型下的名称
                        name            = creature_ctx:name(),
                    }
                    table.insert(r_tab, result)
                end
            end
        end
    end
    -- 按品质排序
    if not table.is_empty(r_tab) then
        table.sort(r_tab,function(a, b) return a.quality > b.quality end)
    end
    return r_tab
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function creature_ent.__tostring()
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
function creature_ent.__newindex(t, k, v)
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
creature_ent.__index = creature_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function creature_ent:new(args)
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
    return setmetatable(new, creature_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return creature_ent:new()

-------------------------------------------------------------------------------------
