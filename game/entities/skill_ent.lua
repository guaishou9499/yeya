------------------------------------------------------------------------------------
-- game/entities/skill_ent.lua
--
-- 实体示例
--
-- @module      skill_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local skill_ent = import('game/entities/skill_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class skill_ent
local skill_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION        = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE    = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME    = 'skill_ent module',
    -- 只读模式
    READ_ONLY      = false,
}

-- 实例对象
local this         = skill_ent
-- 日志模块
local trace        = trace
-- 决策模块
local decider      = decider
local pairs        = pairs
local table        = table
local rawset       = rawset
local skill_ctx    = skill_ctx
local skill_unit   = skill_unit
local setmetatable = setmetatable
local import       = import
---@type skill_res
local skill_res    = import('game/resources/skill_res')
------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function skill_ent.super_preload()

end

-------------------------------------------------------------------------------------
-- [读取] 指定技能书是否可使用
--
-- @tparam              string                   book_name          技能书名称
-- @treturn                                                         返回 true[可使用] false[不可使用]
------------------------------------------------------------------------------------
skill_ent.can_use_skill_book = function(book_name)
    -- 保存可用技能书
    local set_can_use    = {}
    -- xxmsg('1------------------------------') --使用(기술서 - 위기 감지 I(귀속))中.
    local skill_info_res = skill_res.SKILL_INFO
    for skill_name,skill_info in pairs( skill_info_res ) do
        local need_book  = skill_info.need_book
        if not table.is_empty(need_book) then
            local skill_level = this.get_skill_level_by_name(skill_name,true)
           --  xxmsg(skill_name..' '..skill_level)
            local _book_name = need_book[ skill_level + 1 ]
            if _book_name then
                table.insert(set_can_use,_book_name)
            end
        end
    end
    -- xxmsg('2------------------------------')
    for _,_book_name in pairs(set_can_use) do
        -- xxmsg(_book_name..' '..book_name)
        if book_name == _book_name then
            return true
        end
    end
   -- xxmsg('3------------------------------')
    return false
end

------------------------------------------------------------------------------------
-- [读取] 根据技能分组ID获取技能信息
--
-- @tparam              number                   group_id          技能分组ID
-- @treturn                                                        技能信息表
-- @usage
-- local skill_info = skill_ent.get_skill_info_by_group_id(0x123456)
------------------------------------------------------------------------------------
skill_ent.get_skill_info_by_group_id = function(group_id)
    return this.get_skill_info_by_any(group_id, 'group_id')
end

------------------------------------------------------------------------------------
-- [读取] 根据技能名获取技能等级
--
-- @tparam              string                   name          技能名称
-- @tparam              any                      is_get_h      为nil或者false时配对资源的名称
-- @treturn                                                    技能信息表
-- @usage
-- local skill_level = skill_ent.get_skill_level_by_name('普通攻击')
------------------------------------------------------------------------------------
skill_ent.get_skill_level_by_name = function(name,is_get_h)
    return this.get_skill_info_by_any(name, 'name',is_get_h).level or 0
end

------------------------------------------------------------------------------------
-- [读取] 根据技能名获取技能信息
--
-- @tparam              string                   name          技能名称
-- @treturn                                                    技能信息表
-- @usage
-- local skill_info = skill_ent.get_skill_info_by_name('普通攻击')
------------------------------------------------------------------------------------
skill_ent.get_skill_info_by_name = function(name)
    return this.get_skill_info_by_any(name, 'name')
end

------------------------------------------------------------------------------------
-- [读取] 获取指定技能信息
--
-- @tparam              any                      args           任意的数值
-- @tparam              string                   any_key        技能中存在的字段名
-- @tparam              any                      is_get_h       为nil或者false时配对资源的名称
-- @treturn             table                                   返回指定技能信息
-- @tfield[table]       number                   obj            技能实例对象
-- @tfield[table]       string                   name           技能自定义名称
-- @tfield[table]       string                   h_name         技能原名称
-- @tfield[table]       number                   res_ptr        技能资源指针
-- @tfield[table]       number                   id             技能ID
-- @tfield[table]       number                   group_id       技能分组ID
-- @tfield[table]       number                   cooling_time   技能冷却时间
-- @tfield[table]       number                   mp             技能耗蓝量
-- @tfield[table]       number                   is_study       技能是否学习
-- @tfield[table]       number                   level          技能等级
-- @usage
-- local info = skill_ent.get_skill_info_by_any(name, 'name')
------------------------------------------------------------------------------------
skill_ent.get_skill_info_by_any = function(args, any_key,is_get_h)
    local r_tab = {}
    local list = skill_unit.list()
    for _, obj in pairs(list) do
        if skill_ctx:init(obj) then
            -- 获取指定属性的值
            local _any = skill_ctx[any_key](skill_ctx)
            -- 配对目标值
            if args == skill_res.get_skill_name(_any,is_get_h) then
                local name           = skill_ctx:name()
                local level          = skill_ctx:level()
                -- 物品实例对象
                r_tab.obj            = obj
                -- 技能名称
                r_tab.name           = skill_res.get_skill_name(name)
                -- 技能资源指针
                r_tab.res_ptr        = skill_ctx:res_ptr()
                -- 技能ID
                r_tab.id             = skill_ctx:id()
                -- 技能分组ID
                r_tab.group_id       = skill_ctx:group_id()
                -- 技能冷却时间
                r_tab.cooling_time   = skill_ctx:cooling_time()
                -- 技能耗蓝量
                r_tab.mp             = skill_ctx:mp()
                -- 技能是否学习
                r_tab.is_study       = skill_ctx:is_study()
                -- 技能等级
                r_tab.level          = level >= 0 and level or 0
                -- 技能原名称
                r_tab.h_name         = name
                break
            end
        end
    end
    return r_tab
end

------------------------------------------------------------------------------------
-- [读取] 获取所有已学技能信息
--
-- @treturn             table                                   返回包含所有已学信息的table
-- @tfield[table]       number                   obj            技能实例对象
-- @tfield[table]       string                   name           技能自定义名称
-- @tfield[table]       string                   h_name         技能原名称
-- @tfield[table]       number                   res_ptr        技能资源指针
-- @tfield[table]       number                   id             技能ID
-- @tfield[table]       number                   group_id       技能分组ID
-- @tfield[table]       number                   cooling_time   技能冷却时间
-- @tfield[table]       number                   mp             技能耗蓝量
-- @tfield[table]       number                   is_study       技能是否学习
-- @tfield[table]       number                   level          技能等级
-- @usage
-- local skill_info = skill_ent.skill_info()
------------------------------------------------------------------------------------
skill_ent.skill_info = function()
    local ret_t = {}
    local list = skill_unit.list()
    for i = 1, #list do
        local obj = list[i]
        if skill_ctx:init(obj) and skill_ctx:is_study() then
            local name       = skill_ctx:name()
            local level      = skill_ctx:level()
            local tmp_t = {
                obj          = obj,
                res_ptr      = skill_ctx:res_ptr(),
                id           = skill_ctx:id(),
                group_id     = skill_ctx:group_id(),
                cooling_time = skill_ctx:cooling_time(),
                mp           = skill_ctx:mp(),
                is_study     = true,
                name         = skill_res.get_skill_name(name),
                h_name       = name,
                level        = level >= 0 and level or 0
            }
            table.insert(ret_t, tmp_t)
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
function skill_ent.__tostring()
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
function skill_ent.__newindex(t, k, v)
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
skill_ent.__index = skill_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function skill_ent:new(args)
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
    return setmetatable(new, skill_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return skill_ent:new()

-------------------------------------------------------------------------------------
