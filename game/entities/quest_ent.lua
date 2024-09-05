------------------------------------------------------------------------------------
-- game/entities/quest_ent.lua
--
-- 执行主线的单元
--
-- @module      quest_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local quest_ent = import('game/entities/quest_ent')
------------------------------------------------------------------------------------

-- 模块定义
---@class quest_ent
local quest_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION           = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE       = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME       = 'quest module',
    -- 只读模式
    READ_ONLY         = false,
    -- 主线读取类型[ -1, 0, 1]
    MAIN_TASK_TYPE    = -1

}

-- 实例对象
local this            = quest_ent
-- 日志模块
---@type trace
local trace           = trace
-- 公共模块
local common          = common
-- 决策模块
local decider         = decider
local table           = table
local type            = type
local ipairs          = ipairs
local math            = math
local quest_unit      = quest_unit
local quest_ctx       = quest_ctx
local actor_unit      = actor_unit
local import          = import
local quest_res       = import('game/resources/quest_res')
---@type map_res
local map_res         = import('game/resources/map_res')
local user_set_ent    = import('game/entities/user_set_ent')
---@type actor_ent
local actor_ent       = import('game/entities/actor_ent')
local map_ent         = import('game/entities/map_ent')
-- 保存任务ID，传送时使用
local quest_tran_info = {}
------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function quest_ent.super_preload()
    -- [行为]接受任务
    this.wa_accept_task         = decider.run_action_wrapper('[行为]接受任务', this.accept_task)
    -- [行为]提交任务
    this.wa_complate_task       = decider.run_action_wrapper('[行为]提交任务', this.complate_task)
    -- 等待任务变化
    local action_func = function(q_status)
        common.execute_pass_dialog()
        local str = q_status == 0 and '正在接任务' or q_status == 1 and '正在做任务' or q_status == 2 and '正在交任务' or '等待任务状态变化'
        trace.output(str)
        decider.sleep(2000)
    end
    -- 终止条件
    local cond_func = function(q_status,t)
        local task_info = {}
        if type(t) == 'table' then
            if t.func and t.param then
                task_info = t.func(t.param)
            end
        else
            task_info = this.get_main_task_info()
        end
        if t then
            return table.is_empty(task_info) or task_info.name ~= t.name
        end
        return not table.is_empty(task_info) and task_info.status ~= q_status or table.is_empty(task_info) and true or false
    end
    -- 等待任务状态改变
    this.wait_change_task_status = decider.run_until_wrapper(action_func, cond_func, 20)
end

--------------------------------------------------------------------------------
-- [行为] 执行主线任务
--------------------------------------------------------------------------------
quest_ent.auto_main_task = function(quick_func,t)
    -- 对话关闭
    common.execute_pass_dialog()
    local task_list = {
        [0] = function(task_info,t)
            trace.output('接（' .. task_info.name .. '）')
            this.wa_accept_task(task_info,t)
        end,
        [1] = function(task_info,t)
            local str = task_info.max_tar_num ~= 0 and '[' .. math.floor(task_info.cur_tar_num) .. '/' .. math.floor(task_info.max_tar_num) .. ']' or ''
            trace.output('做（' .. task_info.name .. '）' .. str)
            local special_t = quest_res.SPECIAL_TASK[task_info.name]
            local is_auto   = quest_unit.quest_is_auto(task_info.id)
            -- xxmsg(is_auto)
            if quest_unit.get_cur_auto_quest_id() == 0 then
                common.handle_bag(0)
                quest_unit.auto_quest(task_info.id)
                decider.sleep(3000)
            end
            if quest_unit.get_cur_auto_quest_id() == 0 then
                if type(special_t) == 'function' then
                    special_t()
                end
            else
                if task_info.max_tar_num > 10 and actor_unit.local_player_level() >= 30 then
                ---    this.execute_daily_task_ex()
                end
            end
        end,
        [2] = function(task_info,t)
            trace.output('交（' .. task_info.name .. '）')
            this.wa_complate_task(task_info,t)
        end
    }

    -- 获取主线信息
    local task_info = {}
    if not t then
        task_info = this.get_main_task_info()
    else
        task_info = t.func and t.param and t.func(t.param) or {}
    end
    if not table.is_empty(task_info) then
        common.set_sleep(0)
        if task_info.status == 0 or task_info.status == 2 then
            common.handle_bag(0)
        end
        --  trace.log_debug(string.format('任务名:%s id:%s step_id:%s type:%s cur_tar_num:%s max_tar_num:%s',task_info.name,task_info.id,task_info.step_id,task_info.type,task_info.cur_tar_num,task_info.max_tar_num))
        local func = task_list[task_info.status]
         this.quest_teleport_popup(task_info)
        -- 检测是否切换频道
         actor_ent.auto_change_line(task_info.status)
        if type(quick_func) == 'function' then
            if common.is_sleep_any('check_quick',2) then
                local set_v = map_res.is_in_scene_map() and task_info.max_tar_num == 1 and 1 or 2
                quick_func(set_v)
            end
        end
        local result = type(func) == 'function' and func(task_info,t) or type(func) ~= 'function' and '没有可执行的任务-' .. task_info.status or ''
        if result ~= '' then
            trace.log_warn(result)
        end
    end
end

--------------------------------------------------------------------------------
-- [行为] 执行日常
--------------------------------------------------------------------------------
quest_ent.execute_daily_task = function(quick_func)
    local g_task_info = {}
    local n_type      = 2
    -- 获取可提交
    g_task_info = this.get_daily_quest_info(2)
    -- 获取已接任务
    if table.is_empty(g_task_info) then
        g_task_info = this.get_daily_quest_info(1)
        n_type      = 1
    end
    -- 获取可接任务
    if table.is_empty(g_task_info) then
        g_task_info = this.get_daily_quest_info(0)
        n_type      = 0
    end
    if not table.is_empty(g_task_info) then
        local t = { func = this.get_daily_quest_info,param = n_type,name = g_task_info.name }
        this.auto_main_task(quick_func,t)
    end
    if not table.is_empty(g_task_info) then
        return true
    end
    return false
end

--------------------------------------------------------------------------------
-- [行为] 接受任务
--------------------------------------------------------------------------------
quest_ent.accept_task = function(task_info,t)
    common.set_sleep(0)
    common.handle_bag(0)
    if t then
        return this.accept_daily_task(task_info,t)
    end
    quest_unit.accept(task_info.id)
    if this.wait_change_task_status(task_info.status) then
        return true
    end
    return false, '接取任务失败'
end

--------------------------------------------------------------------------------
-- [行为] 提交任务
--------------------------------------------------------------------------------
quest_ent.complate_task = function(task_info,t)
    common.set_sleep(0)
    common.handle_bag(0)
    if t then
        return this.complate_daily_task(task_info,t)
    end
    quest_unit.complate(task_info.id)
    if this.wait_change_task_status(task_info.status) then
        return true
    end
    return false, '提交任务失败'
end

--------------------------------------------------------------------------------
-- [行为] 接受日常任务
--------------------------------------------------------------------------------
quest_ent.accept_daily_task = function(task_info,t)
    quest_unit.accept_daily(task_info.id)
    if this.wait_change_task_status(task_info.status,t) then
        return true
    end
    return false, '接取日常任务失败'
end

--------------------------------------------------------------------------------
-- [行为] 提交日常任务
--------------------------------------------------------------------------------
quest_ent.complate_daily_task = function(task_info,t)

    quest_unit.complate_daily(task_info.id)
    if this.wait_change_task_status(task_info.status,t) then
        return true
    end
    return false, '提交日常任务失败'
end

--------------------------------------------------------------------------------
-- 任务传送
--------------------------------------------------------------------------------
quest_ent.quest_teleport_popup = function(task_info)
    local key = task_info.id .. '-' .. task_info.status
    -- xxmsg(quest_unit.has_quest_teleport_popup()) -- not quest_tran_info[key] and
    if quest_unit.has_quest_teleport_popup() then
        quest_unit.confirm_quest_teleport()
        quest_tran_info[key] = true
        decider.sleep(15 * 1000)
        map_ent.waiting_to_map()
    end
end

--------------------------------------------------------------------------------
-- 是否终止主线
--------------------------------------------------------------------------------
quest_ent.is_stop_main_task = function()
    -- 无连接 重启游戏
    common.check_connect()
    local stop_lv = user_set_ent['终止等级'] or 35
    local result = false
    if actor_unit.local_player_level() >= stop_lv then
        result = true
    end
    if stop_lv == 35 then
        local task_info = this.get_main_task_info()
        if task_info.name == '죽음의 기사' then
            result = true
        end
    end
    if result then
     --   common.set_auto(0)
    end
    return result
end

--------------------------------------------------------------------------------
-- [读取] 根据主线信息
--
-- @treturn      t                          包含主线信息的 table，包括：
-- @tfield[t]    integer   obj              任务实例对象
-- @tfield[t]    string    name             任务名称
-- @tfield[t]    integer   res_ptr          任务资源指针
-- @tfield[t]    integer   id               任务ID
-- @tfield[t]    integer   step_id          当前任务步ID
-- @tfield[t]    integer   type             当前任务类型
-- @tfield[t]    integer   status           当前任务状态
-- @tfield[t]    integer   cur_tar_num      当前分支完成数
-- @tfield[t]    integer   max_tar_num      需要完成的数量
-- @usage
-- local info = quest_ent.get_main_task_info()
-- print_r(info)
--------------------------------------------------------------------------------
quest_ent.get_main_task_info = function()
    local task_type = this.MAIN_TASK_TYPE
    local list = quest_unit.list(task_type)
    local result = {}
    for _, obj in ipairs(list) do
        if obj and quest_ctx:init(obj) then
            local main_type = quest_ctx:type()
            if main_type == 0 then
                result = {
                    -- 主线实例对象
                    obj         = obj,
                    -- 主线名称
                    name        = quest_ctx:name(),
                    -- 任务资源指针
                    res_ptr     = quest_ctx:res_ptr(),
                    -- 任务ID
                    id          = quest_ctx:id(),
                    -- 当前任务步ID
                    step_id     = quest_ctx:step_id(),
                    -- 当前任务类型
                    type        = main_type,
                    -- 当前任务状态
                    status      = quest_ctx:status(),
                    -- 当前分支完成数
                    cur_tar_num = quest_ctx:cur_tar_num(),
                    -- 需要完成的数量
                    max_tar_num = quest_ctx:max_tar_num(),
                }
                break
            end
        end
    end
    return result
end

-------------------------------------------------------------------------------------
-- [行为] 执行日常
-------------------------------------------------------------------------------------
quest_ent.execute_daily_task_ex = function()
    if common.is_sleep_any('execute_daily_task_ex',10) then
        if not this.complate_daily_quest() then
            this.accept_daily_quest_in_map()
        end
    end
end

-------------------------------------------------------------------------------------
-- [行为] 交日常任务
-------------------------------------------------------------------------------------
quest_ent.complate_daily_quest = function()
    -- 获取可提交
    local task = this.get_daily_quest_info(2)
    -- 获取可交任务
    if table.is_empty(task) then
        return false,'没有可交任务'
    end
    local t = { func = this.get_daily_quest_info_in_this_map,param = 0,name = task.name }
    this.wa_complate_task(task,t)
    -- 对话关闭
    common.execute_pass_dialog()
    return true
end

-------------------------------------------------------------------------------------
-- [行为] 接当前地图日常任务
-------------------------------------------------------------------------------------
quest_ent.accept_daily_quest_in_map = function()
    local task_num = #quest_unit.daily_list(1) + #quest_unit.daily_list(2)
    if task_num >= 10 then return end
    local task = this.get_can_accept_daily_quest_in_this_map()
    if not table.is_empty(task) then
        local t = { func = this.get_daily_quest_info_in_this_map,param = 0,name = task.name }
        this.wa_accept_task(task,t)
    end
end

-------------------------------------------------------------------------------------
-- [读取] 读取当前地图可接日常任务
-------------------------------------------------------------------------------------
quest_ent.get_can_accept_daily_quest_in_this_map = function()
    local can_accept = {}
    local now_task   = this.get_daily_quest_info_in_this_map(1)
    if table.is_empty(now_task) then
        can_accept   = this.get_daily_quest_info_in_this_map(0)
    end
    return can_accept
end

-------------------------------------------------------------------------------------
-- [读取] 读取当前地图日常任务
-------------------------------------------------------------------------------------
quest_ent.get_daily_quest_info_in_this_map = function(n_type)
    n_type           = n_type or -1
    local quest_list = {}
    local level      = actor_unit.local_player_level()
    local list = quest_unit.daily_list(n_type)
    local quest_l    = quest_res.SIDE_TASk
    local map_id     = actor_unit.map_id()
    for _,obj in pairs(list) do
        if quest_ctx:init(obj) then
            local quest_level         = quest_ctx:daily_quest_level()
            local name                = quest_ctx:name()
            if quest_level <= level and quest_l[name] and map_id == quest_l[name].map_id then
                local result = {
                    -- 主线实例对象
                    obj               = obj,
                    -- 主线名称
                    name              = quest_ctx:name(),
                    -- 任务资源指针
                    res_ptr           = quest_ctx:res_ptr(),
                    -- 任务ID
                    id                = quest_ctx:id(),
                    -- 当前任务步ID
                    step_id           = quest_ctx:step_id(),
                    -- 当前任务类型
                    type              = quest_ctx:type(),
                    -- 当前任务状态
                    status            = quest_ctx:status(),
                    -- 当前分支完成数
                    cur_tar_num       = quest_ctx:cur_tar_num(),
                    -- 需要完成的数量
                    max_tar_num       = quest_ctx:max_tar_num(),
                    -- 日常任务等级
                    daily_quest_level = quest_level,
                }
                table.insert( quest_list,result )
            end
        end
    end
    if not table.is_empty( quest_list ) then
        -- 按等级小到大排序
        table.sort( quest_list,function(a, b) return a.daily_quest_level < b.daily_quest_level end)
    end
    if not table.is_empty( quest_list ) then
        return quest_list[1]
    end
    return {}
end

-------------------------------------------------------------------------------------
-- [读取] 获取所有指定类型的日常任务信息
-- @tparam      number       n_type         n_type:[-1 所有， 0 可接， 1 已接，2 可提交]
-- @treturn     table                       返回所有日常任务的表
-------------------------------------------------------------------------------------
quest_ent.get_daily_quest_info = function(n_type)
    local quest_list = {}
    n_type           = n_type or -1
    local level      = (n_type == 0 or n_type == 1) and actor_unit.local_player_level() or 999
    local list = quest_unit.daily_list(n_type)
    for _,obj in pairs(list) do
        if quest_ctx:init(obj) then
            local quest_level         = quest_ctx:daily_quest_level()
            if quest_level <= level then
                local result = {
                    -- 主线实例对象
                    obj               = obj,
                    -- 主线名称
                    name              = quest_ctx:name(),
                    -- 任务资源指针
                    res_ptr           = quest_ctx:res_ptr(),
                    -- 任务ID
                    id                = quest_ctx:id(),
                    -- 当前任务步ID
                    step_id           = quest_ctx:step_id(),
                    -- 当前任务类型
                    type              = quest_ctx:type(),
                    -- 当前任务状态
                    status            = quest_ctx:status(),
                    -- 当前分支完成数
                    cur_tar_num       = quest_ctx:cur_tar_num(),
                    -- 需要完成的数量
                    max_tar_num       = quest_ctx:max_tar_num(),
                    -- 日常任务等级
                    daily_quest_level = quest_level,
                }
                table.insert( quest_list,result )
            end
        end
    end
    if not table.is_empty( quest_list ) then
        -- 按等级小到大排序
        table.sort( quest_list,function(a, b) return a.daily_quest_level < b.daily_quest_level end)
    end
    if not table.is_empty( quest_list ) then
        return quest_list[1]
    end
    return {}
end

-------------------------------------------------------------------------------------
-- [读取] 获取所有指定类型的日常任务信息
-- @tparam      number       n_type         n_type:[-1 所有， 0 可接， 1 已接，2 可提交]
-- @treturn     table                       返回所有日常任务的表
-------------------------------------------------------------------------------------
quest_ent.get_daily_quest_list = function(n_type)
    local quest_list = {}
    n_type = n_type or -1
    local list = quest_unit.daily_list(n_type)
    for _,obj in pairs(list) do
        if quest_ctx:init(obj) then
            local result = {
                -- 主线实例对象
                obj               = obj,
                -- 主线名称
                name              = quest_ctx:name(),
                -- 任务资源指针
                res_ptr           = quest_ctx:res_ptr(),
                -- 任务ID
                id                = quest_ctx:id(),
                -- 当前任务步ID
                step_id           = quest_ctx:step_id(),
                -- 当前任务类型
                type              = quest_ctx:type(),
                -- 当前任务状态
                status            = quest_ctx:status(),
                -- 当前分支完成数
                cur_tar_num       = quest_ctx:cur_tar_num(),
                -- 需要完成的数量
                max_tar_num       = quest_ctx:max_tar_num(),
                -- 日常任务等级
                daily_quest_level = quest_ctx:daily_quest_level(),
            }
            table.insert( quest_list,result )
        end
    end
    if not table.is_empty( quest_list ) then
        -- 按等级小到大排序
        table.sort( quest_list,function(a, b) return a.daily_quest_level < b.daily_quest_level end)
    end
    return quest_list
end

------------------------------------------------------------------------------------
-- [读取] 根据日常任务任意字段值返回日常信息表
-- @tparam              string                   args           日常任务需要配对的参数
-- @tparam              string                   any_key        日常任务任意(字段)
-- @tparam              number                   n_type         日常任务的类型[（-1 所有， 0 可接， 1 已接，2 可提交）默认所有]
-- @treturn             table                                   返回日常信息的table
------------------------------------------------------------------------------------
quest_ent.get_daily_quest_info_by_any = function(args, any_key, n_type)
    n_type = n_type or -1
    local quest_info = {}
    local list       = quest_unit.daily_list(n_type)
    for _, obj in pairs(list) do
        if quest_ctx:init(obj) then
            -- 获取指定属性的值
            local _any = quest_ctx[any_key](quest_ctx)
            -- 配对目标值
            if args == _any then
                quest_info = {
                    -- 主线实例对象
                    obj               = obj,
                    -- 主线名称
                    name              = quest_ctx:name(),
                    -- 任务资源指针
                    res_ptr           = quest_ctx:res_ptr(),
                    -- 任务ID
                    id                = quest_ctx:id(),
                    -- 当前任务步ID
                    step_id           = quest_ctx:step_id(),
                    -- 当前任务类型
                    type              = quest_ctx:type(),
                    -- 当前任务状态
                    status            = quest_ctx:status(),
                    -- 当前分支完成数
                    cur_tar_num       = quest_ctx:cur_tar_num(),
                    -- 需要完成的数量
                    max_tar_num       = quest_ctx:max_tar_num(),
                    -- 日常任务等级
                    daily_quest_level = quest_ctx:daily_quest_level(),
                }
                break
            end
        end
    end
    return quest_info
end

------------------------------------------------------------------------------------
-- [读取] 根据日常任务任意字段或多个字段值返回包含日常任务信息的所有日常任务表
--
-- @tparam                string                   args               日常任务需要配对的参数
-- @tparam                string                   any_key            日常任务任意(字段)
-- @tparam                number                   n_type             日常任务的类型[（-1 所有， 0 可接， 1 已接，2 可提交）默认所有]
-- @treturn               list                                        返回包含日常任务信息的所有日常任务表 包括
-- @tfield[list]          number                   obj                日常任务实例对象
-- @tfield[list]          string                   name               日常任务名称
-- @tfield[list]          number                   res_ptr            日常任务资源指针
-- @tfield[list]          number                   id                 日常任务ID
-- @tfield[list]          number                   type               日常任务类型
-- @tfield[list]          number                   step_id            当前日常任务步ID
-- @tfield[list]          number                   status             当前日常任务状态
-- @tfield[list]          number                   cur_tar_num        当前分支完成数
-- @tfield[list]          number                   max_tar_num        需要完成的数量
-- @tfield[list]          number                   daily_quest_level  日常任务等级
-- @usage
-- local quest_list = quest_ent.get_daily_quest_list_by_list_any('生命药水（小）', 'name', 0)
-- local quest_list = quest_ent.get_daily_quest_list_by_list_any({'生命药水（小）','生命药水（大）'}, 'name', 0)
-- local quest_list = quest_ent.get_daily_quest_list_by_list_any(0x123, 'id', 0)
-- local quest_list = quest_ent.get_daily_quest_list_by_list_any({0x123,0x1234}, 'id', 0)
------------------------------------------------------------------------------------
quest_ent.get_daily_quest_list_by_list_any = function(args, any_key, n_type)
    n_type             = n_type or -1
    local r_tab        = {}
    local list         = quest_unit.daily_list(n_type)
    for _, obj in pairs(list) do
        if quest_ctx:init(obj) then
            -- 获取指定属性的值
            local _any = quest_ctx[any_key](quest_ctx)
            -- 当前对象 是否需获取的目标
            if common.is_exist_list_arg(args, _any) then
                local result = {
                    -- 日常实例对象
                    obj               = obj,
                    -- 日常名称
                    name              = quest_ctx:name(),
                    -- 日常任务资源指针
                    res_ptr           = quest_ctx:res_ptr(),
                    -- 日常任务ID
                    id                = quest_ctx:id(),
                    -- 当前日常任务步ID
                    step_id           = quest_ctx:step_id(),
                    -- 当前日常任务类型
                    type              = quest_ctx:type(),
                    -- 当前日常任务状态
                    status            = quest_ctx:status(),
                    -- 当前分支完成数
                    cur_tar_num       = quest_ctx:cur_tar_num(),
                    -- 需要完成的数量
                    max_tar_num       = quest_ctx:max_tar_num(),
                    -- 日常任务等级
                    daily_quest_level = quest_ctx:daily_quest_level(),
                }
                table.insert(r_tab, result)
            end
        end
    end
    return r_tab
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function quest_ent.__tostring()
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
function quest_ent.__newindex(t, k, v)
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
quest_ent.__index = quest_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function quest_ent:new(args)
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
    return setmetatable(new, quest_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return quest_ent:new()

-------------------------------------------------------------------------------------
