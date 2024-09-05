------------------------------------------------------------------------------------
-- game/entities/collection_ent.lua
--
-- 收集单元
--
-- @module      collection_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local collection_ent = import('game/entities/collection_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class collection_ent
local collection_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION                 = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE        = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME        = 'collection_ent module',
    -- 只读模式
    READ_ONLY          = false,
}

-- 实例对象
local this             = collection_ent
-- 日志模块
local trace            = trace
-- 决策模块
local decider          = decider
local common           = common
local collection_unit  = collection_unit
local collection_ctx   = collection_ctx
local ui_unit          = ui_unit
local import           = import
local setmetatable     = setmetatable
local pairs            = pairs
local rawset           = rawset
local table            = table
---@type item_ent
local item_ent         = import('game/entities/item_ent')

-- 无法根据可读ID的 收集名
local special_collect  = { '','','','' } -- '나이트 크로우의 여정 I',
------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function collection_ent.super_preload()
    -- [间隔]执行收集
    -- this.wi_execute_collection = decider.run_interval_wrapper('[行为]打开收集窗口',this.execute_collection)
    -- [行为]打开收集窗口
    this.wa_open_collection = decider.run_action_wrapper('[行为]打开收集窗口',this.open_collection)
    -- [行为]收集
    this.wa_collection      = decider.run_action_wrapper('[行为]收集',collection_unit.collection)
end

------------------------------------------------------------------------------------
-- [行为] 打开收集窗口
------------------------------------------------------------------------------------
collection_ent.open_collection = function()
    local open_num = 0
    while decider.is_working() do
        if collection_unit.is_open_collection_scene() then
            return true
        end
        if open_num > 2 then break end
        decider.sleep(2000)
        if common.is_sleep_any('open_collection',10) then
            common.set_sleep(0)
            -- 对话关闭
            common.execute_pass_dialog()
            trace.output('打开收集窗口')
            collection_unit.open_collection_scene()
            open_num = open_num + 1
            decider.sleep(2000)
        end
    end
    return false,'打开收集窗口-异常'
end

------------------------------------------------------------------------------------
-- [行为] 执行收集
------------------------------------------------------------------------------------
collection_ent.execute_collection = function()
    local list     = collection_unit.list()
    local is_exist = false
    for _,obj in pairs(list) do
        if collection_ctx:init(obj) then
            local id = collection_ctx:id()
            if not collection_ctx:is_finish() then
                local sub_num           = collection_ctx:num()
                for j = 0, sub_num - 1 do
                    -- local status        = collection_ctx:sub_status(j)
                    local num           = collection_ctx:sub_item_max_num(j) - collection_ctx:sub_item_num(j)
                    if num > 0 and (collection_ctx:sub_bag_item_id(j) > 0 or this.is_read_collect(collection_ctx:name())) then
                       
                        local name      = collection_ctx:sub_item_name(j)
                        local item_info = item_ent.get_item_info_by_name(name,0,false)
                        local level     = collection_ctx:sub_item_enhanced_level(j)
                        if not table.is_empty(item_info) then
                            local is_set = true
                            -- 数量小于指定数量 不设置
                            if item_info.num  < num then is_set = false end
                            if item_info.type == 0 then
                                if item_info.quality > 2 then -- 装备类型  品质大于2 不设置
                                    is_set = false
                                elseif item_info.enhanced_level < level then -- 强化等级不足 不设置
                                    is_set = false
                                end
                            end
                            -- 执行收集
                            if is_set then
                                -- xxmsg(j..' '..num..' '..name..' //item_info.name:'..item_info.name..' '..tostring(is_set)..' '..collection_ctx:name())
                                if this.wa_open_collection() then
                                    trace.output('收集',collection_ctx:name())
                                    -- 对话关闭
                                    common.execute_pass_dialog()
                                    -- xxmsg(collection_ctx:name())
                                    this.wa_collection(id, j)
                                    decider.sleep(2000)
                                    item_ent.wr_wait_change_item(item_info)
                                    is_exist = true
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if is_exist then
        ui_unit.exit_widget()
        decider.sleep(2000)
    end
end

------------------------------------------------------------------------------------
-- [条件] 是否可读取
collection_ent.is_read_collect = function(name)
    for _,v in pairs(special_collect) do
        if v == name then
            return true
        end
    end
    return false
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function collection_ent.__tostring()
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
function collection_ent.__newindex(t, k, v)
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
collection_ent.__index = collection_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function collection_ent:new(args)
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
    return setmetatable(new, collection_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return collection_ent:new()

-------------------------------------------------------------------------------------
