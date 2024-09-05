------------------------------------------------------------------------------------
-- game/entities/map_ent.lua
--
-- 地图单元
--
-- @module      map_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local map_ent = import('game/entities/map_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class map_ent
local map_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION        = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE    = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME    = 'map_ent module',
    -- 只读模式
    READ_ONLY      = false,
}

-- 实例对象
local this         = map_ent
-- 日志模块
local trace        = trace
-- 决策模块
local decider      = decider
local common       = common
local map_unit     = map_unit
local map_ctx      = map_ctx
local main_ctx     = main_ctx
local actor_unit   = actor_unit
local import       = import
local setmetatable = setmetatable
local pairs        = pairs
local rawset       = rawset
local type         = type
local map_res      = import('game/resources/map_res')
local login_res    = import('game/resources/login_res')
------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function map_ent.super_preload()

end

-------------------------------------------------------------------------------------
-- 传送到指定地图
map_ent.execute_transfer_map = function(map_arg)
    while decider.is_working() do
        if actor_unit.map_id() == map_arg or actor_unit.map_name() == map_arg then
            break
        end
        local transfer_id,map_name = this.get_transfer_id(map_arg)
        if transfer_id ~= 0 then
            trace.output('传送到:',map_name)
            common.set_sleep(0)
            -- 对话关闭
            common.execute_pass_dialog()
            map_unit.transfer_to_map(transfer_id)
            decider.sleep(15 * 1000)
            this.waiting_to_map()
        end
        decider.sleep(2000)
    end
end

-------------------------------------------------------------------------------------
-- 等待过图
map_ent.waiting_to_map = function()
    local loading_num = 0
    while decider.is_working() do
        if not login_res.is_loading_map() then
            return true
        end
        if loading_num > 20 then
            trace.log_warn('过图超时-重启游戏')
            main_ctx:end_game()
            break
        end
        loading_num = loading_num + 1
        trace.output('正在过图中-',loading_num)
        decider.sleep(3000)
    end
    return false
end

-------------------------------------------------------------------------------------
-- 获取指定地图ID或者地图名的 传送ID
map_ent.get_transfer_id = function(map_arg)
    local main_id,map_name = 0,0
    if type(map_arg) == 'string' then
        map_name = map_arg
    else
        main_id,map_name = map_res.get_main_id_by_map_id(map_arg)
    end
    if map_name and map_name ~= 0 then
        local list = map_unit.list()
        for i = 1, #list do
            local obj = list[i]
            if map_ctx:init(obj) then
                if map_ctx:name() == map_name then
                    return map_ctx:id(),map_name
                end
            end
        end
    end
    return 0,map_name
end

-------------------------------------------------------------------------------------
-- test_map_unit
function map_ent.test_map_unit()
    local list = map_unit.list()
    xxmsg("地图数："..#list)
    for i = 1, #list do
        local obj = list[i]
        if map_ctx:init(obj) then
            xxmsg(string.format('obj:%16X   id:%16X   name:%s', obj, map_ctx:id(), map_ctx:name()))
        end
    end
    
    --map_unit.transfer_to_map(地图ID)
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function map_ent.__tostring()
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
function map_ent.__newindex(t, k, v)
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
map_ent.__index = map_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function map_ent:new(args)
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
    return setmetatable(new, map_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return map_ent:new()

-------------------------------------------------------------------------------------
