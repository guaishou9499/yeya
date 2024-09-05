-------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @author:   admin
-- @email:    88888@qq.com
-- @date:     2023-2-10
-- @module:   login
-- @describe: 登陆单元
-- @version:  v1.0
--

-------------------------------------------------------------------------------------
--
local login_ent = {
    VERSION        = '20230301',
    AUTHOR_NOTE    = '-[login ent - 20230301]-',
    MODULE_NAME    = '登陆单元',
}

-- 自身模块
local this         = login_ent
-- 日志模块
local trace        = trace
-- 决策模块
local decider      = decider
-- 优化列表
local game_unit    = game_unit
local main_ctx     = main_ctx
local login_unit   = login_unit
local login_ctx    = login_ctx
local common       = common
local string       = string
local os           = os
local setmetatable = setmetatable
local table        = table
local pairs        = pairs
local type         = type
local import       = import
local configer     = import('base/configer')
local login_res    = import('game/resources/login_res')
---@type user_set_ent
local user_set_ent = import('game/entities/user_set_ent')
------------------------------------------------------------------------------------
-- 预载函数(重载脚本时)
login_ent.super_preload = function()
    --------------------------------------------------------------------------------------------------------------------
    -- 接受服务条款行为返回[脚本调用中引用此功能函数]
    this.wa_accept_user_agreement          = decider.run_action_wrapper('[行为]服务条款', this.accept_user_agreement)
    --------------------------------------------------------------------------------------------------------------------
    -- 选择大区进入游戏行为返回[脚本调用中引用此功能函数]
    this.wa_enter_select_character         = decider.run_action_wrapper('[行为]选择大区进入游戏', this.enter_select_character)
    --------------------------------------------------------------------------------------------------------------------
    --  包装创建角色行为
    this.wa_do_create_character            = decider.run_action_wrapper('[行为]创建角色行为',this.do_create_character)
    --  包装创建角色间隔10秒执行功能
    this.wi_do_create_character            = decider.run_interval_wrapper('[间隔]创建角色10秒',this.wa_do_create_character,10 * 1000)
    --  执行创建角色功能[脚本调用中引用此功能函数]
    this.wu_create_character               = decider.run_until_wrapper(this.wi_do_create_character,this.stop_create_character)
    --------------------------------------------------------------------------------------------------------------------
    --  进入游戏行为返回[脚本调用中引用此功能函数]
    -- this.wa_enter_game                     = decider.run_action_wrapper('[行为]进入游戏', this.enter_game)
    --------------------------------------------------------------------------------------------------------------------
    -- 包装执行间隔点击启动页
    this.wi_click_auth                     = decider.run_interval_wrapper('[间隔]点击启动页',login_unit.auth,8 * 1000)
    -- 包装执行间隔登录服务器
    this.wi_enter_realm                    = decider.run_interval_wrapper('[间隔]登录服务器',login_unit.enter_realm,8 * 1000)
    -- 包装执行间隔进入游戏
    this.wi_enter_game                     = decider.run_interval_wrapper('[间隔]进入游戏',login_unit.enter_game,8 * 1000)
end

------------------------------------------------------------------------------------
-- [状态] 启动游戏
------------------------------------------------------------------------------------
login_ent.start_game = function()
    while decider.is_working() do
        -- 检测当前游戏状态
        local status = game_unit.get_game_status_ex()
        -- 状态 ~= 0x00【启动页面】 时 【退出】
        if status ~= login_res.STATUS_INTRO_PAGE then
            return true
        end
        local str  = string.format('正在启动游戏(0x%X).',status)
        trace.output(str)
        trace.log_debug(str)
        decider.sleep(2000)
    end
    return false,'启动游戏失败'
end

------------------------------------------------------------------------------------
-- [行为] 选择服务器
------------------------------------------------------------------------------------
login_ent.enter_select_character = function(close_ui)
    -- 获取控制台登录服务器设置
    local login_server_name  = main_ctx:c_server_name()
    -- 标记是否已点击进入
    local click_auth_num     = 0
    -- 标记首次点击
    local check_server_limit = false
    while decider.is_working() do
        -- 获取游戏状态
        local status         = game_unit.get_game_status_ex()
        -- 不等于 0x20【登录页面】【退出】
        if  status ~= login_res.STATUS_LOGIN_PAGE then
            return true
        end
        if click_auth_num > 3 then
            trace.output(string.format('无法点击启动页进入-重启游戏'))
            main_ctx:end_game()
        end
        -- 根据控制台服务器名转换成游戏服务器名称
        local server_name    = login_res.translate_server(login_server_name)
        if server_name then
            -- 获取服务器ID
            local server_id      = login_unit.get_server_id_byname(server_name)
            -- 读取服务器ID 如果ID 不等于0 则已在可选服务器页面
            if server_id ~= 0 then
                if login_ent.can_login_server(server_id) or not check_server_limit then
                    -- 非排队状态下 选择进入服务器
                    if not this.is_waiting_game() then
                        if type(close_ui) == 'function'  then
                            decider.sleep(8000)
                            close_ui()
                        end
                        trace.output(string.format('登录:%s-（0x%X）[0x%X]',login_server_name,server_id,status))
                        -- 登录指定服务器
                        this.wi_enter_realm(server_id)
                        -- 适当延迟
                        decider.sleep(5000)
                        check_server_limit = true
                    end
                    -- 检测是否触发排队
                    this.wait_for_login_queue()
                else
                    local str = login_unit.check_server_limit(server_id) and '[创建角色限制]' or '[登录服务器失败]'
                    trace.output(string.format('%s %s',login_server_name,str))
                end
            else
                trace.output(string.format('等待加载登录大区[0x%X]',status))
                if common.is_sleep_any('click_auth',9) then
                    -- 点击启动页面
                    this.wi_click_auth()
                    click_auth_num = click_auth_num + 1
                end
            end
        else
            trace.output(login_server_name,'-登录资源需添加韩文的服务器名称')
        end
        decider.sleep(2000)
    end
    return false,this.is_waiting_game() and '排队中无需选择服务器' or '选择服务器失败'
end

------------------------------------------------------------------------------------
-- [行为] Google账号登陆页面【挂内置自动输入】
------------------------------------------------------------------------------------
login_ent.login_google_account = function()
    while decider.is_working() do
        -- 获取当前游戏状态
        local status = game_unit.get_game_status_ex()
        -- 检测当前状态 是否为0xA0 [Google账号登陆页面]
        if status ~= (login_res.STATUS_LOGIN_PAGE | login_res.STATUS_GOOGLE_LOGIN_PAGE) then
            -- 非Google账号登陆页面【退出】
            return true
        end
        trace.output(string.format('等待谷歌登录完成.[0x%X]',status))
        decider.sleep(2000)
    end
    return false,'谷歌登录失败'
end

------------------------------------------------------------------------------------
-- [行为] 服务条款同意页面
------------------------------------------------------------------------------------
login_ent.accept_user_agreement = function()
    local ret        = false
    while decider.is_working() do
        local status = game_unit.get_game_status_ex()
        -- 检测当前状态是否为0x420 【服务条款同意页面】
        if status ~= (login_res.STATUS_LOGIN_PAGE | login_res.STATUS_TERMS_AGREEMENT_PAGE) then
            -- 非服务条款同意页面【退出】
            ret = true
            break
        end
        local str = string.format('服务条款同意.[0x%X]',status)
        trace.output(str)
        trace.log_debug(str)
        -- 过接受登陆协议
        game_unit.pass_terms_agreement()
        decider.sleep(5000)
    end
    -- 设置账号首次注册时间
    main_ctx:set_reg_time(os.time())
    return ret, ret and '成功' or '接受登录协议失败'
end

------------------------------------------------------------------------------------
-- [行为] 执行创建角色
------------------------------------------------------------------------------------
login_ent.do_create_character = function()
    -- 获取控制台设置的职业名称
    local job_name = main_ctx:c_job()
    -- 当前职业是否可创建【资源中配置】
    if login_res.can_create_job(job_name) then
        -- 获取游戏状态
        local status = game_unit.get_game_status_ex()
        local str    = string.format('正在创建角色.[0x%X]',status)
        trace.output(str)
        trace.log_debug(str)
        -- 执行创建 ''时名字随机
        login_unit.create_character('', job_name)
        decider.sleep(10000)
        if game_unit.get_game_status_ex() ~= login_res.STATUS_CREATE_CHARACTER then
            return true
        end
        return false,'创建角色失败'
    else
        return false,'当前设置的职业暂不支持创建'
    end
end

------------------------------------------------------------------------------------
-- [行为] 选择角色进入游戏
------------------------------------------------------------------------------------
login_ent.enter_game = function(close_ui)
    -- 标记执行是否成功
    local ret        = false
    -- 标记默认选择角色序号
    local enter_idx  = 1
    while decider.is_working() do
        -- 获取游戏当前状态
        local status = game_unit.get_game_status_ex()
        -- 检测当前状态是否为 0x4000【角色选择页面】
        if status ~= login_res.STATUS_CHARACTER_SELECT then
            -- 不在角色选择页面【退出】
            local str   = string.format('成功进入游戏(0x%X)',status)
            trace.output(str)
            ret = true
            break
        end
        -- 获取当前角色页面 可进入角色
        local enter_role = this.get_role_info_by_idx(enter_idx)
        if not table.is_empty(enter_role) then
            main_ctx:update_role_job(main_ctx:c_job(), enter_idx)
            -- 执行创建后下线
            if login_res.END_GAME_OFTER_CREATE == 1 or user_set_ent['建角下线'] == 1 then
                trace.output('创建角色完成-下线')
                main_ctx:set_ex_state(1)
                decider.sleep(5000)
                main_ctx:end_game()
            end
            -- 设置已剔除进入限制
            configer.set_user_profile('登录限制', main_ctx:c_server_name()..'创建角色',1)
            local str    = string.format('选择角色（%s）.[0x%X]',enter_role.name,status)
            trace.output(str)
            trace.log_debug(str)
            if type(close_ui) == 'function' then
                close_ui()
            end
            -- 执行进入游戏
            this.wi_enter_game(enter_idx - 1)
            decider.sleep(5000)
        else
            trace.log_error('进入游戏登陆角色异常')
        end
        decider.sleep(2000)
    end
    return ret
end

------------------------------------------------------------------------------------
-- [行为] 等待登陆排队
------------------------------------------------------------------------------------
login_ent.wait_for_login_queue = function()
    local set_login_finish = false
    while decider.is_working() do
        if not this.is_waiting_game() then
            if set_login_finish then
                decider.clear_time_out(180)
            end
            return true
        end
        decider.clear_time_out(0)
        local status  = game_unit.get_game_status_ex()
        local w_num   = login_unit.get_wating_enter_realm_num()
        local str     = string.format('正在排队,队列（%s）.[0x%X]',w_num,status)
        trace.output(str)
        trace.log_debug(str)
        decider.sleep(2000)
        local set_num = user_set_ent['登录排队'] or 5
        if not set_login_finish and main_ctx:get_loging_num() < set_num then
            main_ctx:notify_login_finsh()
            set_login_finish = true
        end
    end
    return false
end

------------------------------------------------------------------------------------
-- [条件] 是否可登录服务器
------------------------------------------------------------------------------------
login_ent.can_login_server = function(server_id)
    local server_limit = login_unit.check_server_limit(server_id)
    local server_name  = main_ctx:c_server_name()
    return ( not server_limit and true or configer.get_user_profile('登录限制', server_name..'创建角色') ~= '' and true ) or false
end

------------------------------------------------------------------------------------
-- [条件] 是否在排队
------------------------------------------------------------------------------------
login_ent.is_waiting_game = function()
    return login_unit.is_wating_enter_realm()
end

------------------------------------------------------------------------------------
-- [条件] 是否终止创建角色
------------------------------------------------------------------------------------
login_ent.stop_create_character = function()
    -- 获取游戏状态
    local status = game_unit.get_game_status_ex()
    -- 检测当前状态是否为0x20000【创建角色页面】
    if status ~= login_res.STATUS_CREATE_CHARACTER then
        return true
    end
    return false
end

------------------------------------------------------------------------------------
-- [读取] 获取指定角色序号的角色名称与ID
-- @tparam          number   idx   角色序号
-- @treturn         table          包含角色信息的表
-- @tfield[table]   number   id    角色序号
-- @tfield[table]   string   name  角色名称
-- @usage
-- local role_info = login_ent.get_role_info_by_idx(1)
------------------------------------------------------------------------------------
login_ent.get_role_info_by_idx = function(idx)
    local ret  = {}
    local list = login_unit.role_list()
    if idx <= #list then
        if login_ctx:init(list[idx]) then
            ret.id    = login_ctx:id()
            ret.name  = login_ctx:name()
            ret.job   = login_ctx:job()
            ret.level = login_ctx:level()
        end
    end
    return ret
end

------------------------------------------------------------------------------------
-- 实例化新对象

function login_ent.__tostring()
    return this.MODULE_NAME
end

login_ent.__index = login_ent

function login_ent:new(args)
    local new = { }

    -- 预载函数(重载脚本时)
    if this.super_preload then
        this.super_preload()
    end

    if args then
        for key, val in pairs(args) do
            new[key] = val
        end
    end

    -- 设置元表
    return setmetatable(new, login_ent)
end

-------------------------------------------------------------------------------------
-- 返回对象
return login_ent:new()

-------------------------------------------------------------------------------------