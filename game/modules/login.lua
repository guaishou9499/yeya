-------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @author:   admin
-- @email:    88888@qq.com
-- @date:     2022-06-30
-- @module:   login
-- @describe: 登陆处理
-- @version:  v1.0
--

-------------------------------------------------------------------------------------
--
local login = {
    VERSION         = '20211016.28',
    AUTHOR_NOTE     = "-[login module - 20211016.28]-",
    MODULE_NAME     = '登陆模块',
    -- 设置脚本版本
    SCRIPT_UPDATE   = 'v1.06.08A',
}

-- 自身模块
local this          = login
-- 配置模块
local settings      = settings
-- 日志模块
local trace         = trace
-- 决策模块
local decider       = decider
-- 优化列表
local game_unit     = game_unit
local main_ctx      = main_ctx
local login_unit    = login_unit
local setmetatable  = setmetatable
local pairs         = pairs
local import        = import
-------------------------------------------------------------------------------------
--
local login_res     = import('game/resources/login_res')
local login_ent     = import('game/entities/login_ent')
---@type ui_ent
local ui_ent        = import('game/entities/ui_ent')
---@type user_set_ent
local user_set_ent  = import('game/entities/user_set_ent')
-------------------------------------------------------------------------------------
-- 运行前置条件
this.eval_ifs = {
    -- [启用] 游戏状态列表
    yes_game_state = {},
    -- [禁用] 游戏状态列表
    not_game_state = { login_res.STATUS_IN_GAME },
    -- [启用] 配置开关列表
    yes_config     = {  },
    -- [禁用] 配置开关列表
    not_config     = {},
    -- [时间] 模块超时设置(可选)
    time_out       = 180,
    -- [其它] 特殊情况才用(可选)
    is_working     = function()
        return true
    end,
    -- [其它] 功能函数条件(可选)
    is_execute     = function()
        return true
    end,
}

-- 轮循函数列表
login.poll_functions = {}

------------------------------------------------------------------------------------
-- 预载函数(重载脚本时)
login.super_preload = function()

end

-------------------------------------------------------------------------------------
-- 预载处理
login.preload = function()
    -- 载入用户设置
    user_set_ent.load_user_info()
    main_ctx:set_script_version(this.SCRIPT_UPDATE)
    xxxmsg(2,'【SCRIPT:'..this.SCRIPT_UPDATE..'】')
    settings.log_level        = 2
    settings.log_type_channel = 3
end

-------------------------------------------------------------------------------------
-- 轮循功能入口
login.looping = function()
    -- ui_ent.close_window_list()
    -- ui_ent.exit_first_mov()

end

-------------------------------------------------------------------------------------
-- 功能入口函数
login.entry = function()
    local action_list = {
        -- 开始游戏
        [login_res.STATUS_INTRO_PAGE]                                          = login_ent.start_game,
        -- Google账号登陆页面【挂内置自动输入账号密码】
        [login_res.STATUS_LOGIN_PAGE | login_res.STATUS_GOOGLE_LOGIN_PAGE]     = login_ent.login_google_account,
        -- 服务条款同意页
        [login_res.STATUS_LOGIN_PAGE | login_res.STATUS_TERMS_AGREEMENT_PAGE]  = login_ent.wa_accept_user_agreement,
        -- 选择大区进入游戏
        [login_res.STATUS_LOGIN_PAGE]                                          = login_ent.wa_enter_select_character,
        -- 创建角色
        [login_res.STATUS_CREATE_CHARACTER]                                    = login_ent.wu_create_character,
        -- 进入游戏
        [login_res.STATUS_CHARACTER_SELECT]                                    = login_ent.enter_game,
    }
    -- 加载前延迟
    decider.sleep(3000)
    while decider.is_working()
    do
        -- 执行轮循任务
        decider.looping()
        -- 读取游戏状态
        local status = game_unit.get_game_status_ex()
        -- 根据状态执行相应功能
        local action = action_list[status]
        -- xxmsg(string.format('%X',status))
        if action ~= nil then
            -- 执行函数
            action(	ui_ent.exit_first_mov )
        end
        -- 适当延时(切片)
        decider.sleep(2000)
    end
    
end

-------------------------------------------------------------------------------------
-- 模块超时处理
login.on_timeout = function()
    local status = game_unit.get_game_status_ex()
    -- 非排队状态时超时-重启
    if not login_ent.is_waiting_game() and status ~= login_res.STATUS_IN_GAME and status ~= login_res.STATUS_LOADING_MAP then
        trace.log_info('[登陆模块>处理超时-结束进程]')
        main_ctx:end_game()
    end
end

-------------------------------------------------------------------------------------
-- 定时调用入口
login.on_timer = function(timer_id)
    xxmsg('login.on_timer -> '..timer_id)
end

-------------------------------------------------------------------------------------
-- 卸载处理
login.unload = function()
    --xxmsg('login.unload')
end

-------------------------------------------------------------------------------------
-- 效验登陆异常
login.check_login_error = function()

end

-------------------------------------------------------------------------------------
-- 实例化新对象

function login.__tostring()
    return this.MODULE_NAME
end

login.__index = login

function login:new(args)
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
    return setmetatable(new, login)
end

-------------------------------------------------------------------------------------
-- 返回对象
return login:new()

-------------------------------------------------------------------------------------