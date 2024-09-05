-------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @author:   admin
-- @email:    88888@qq.com
-- @date:     2022-06-30
-- @module:   dungeon
-- @describe: 副本自动打怪
-- @version:  v1.0
--

-------------------------------------------------------------------------------------
--
local dungeon = {
    VERSION          = '20211016.28',
    AUTHOR_NOTE      = "-[dungeon module - 20211016.28]-",
    MODULE_NAME      = '副本模块',
}

-- 自身模块
local this            = dungeon
-- 配置模块
local settings        = settings
-- 日志模块
local trace           = trace
-- 决策模块
local decider         = decider
-- 优化列表
local game_unit       = game_unit
local setmetatable    = setmetatable
local pairs           = pairs
local table           = table
local import          = import
-------------------------------------------------------------------------------------
-- 登陆资源
local login_res       = import('game/resources/login_res')
---@type fight_mon_ent
local fight_mon_ent   = import('game/entities/fight_mon_ent')
---@type loop_ent
local loop_ent        = import('game/entities/loop_ent')
---@type dungeon_ent
local dungeon_ent     = import('game/entities/dungeon_ent')
-------------------------------------------------------------------------------------
-- 运行前置条件
this.eval_ifs = {
    -- [启用] 游戏状态列表
    yes_game_state = { login_res.STATUS_IN_GAME | login_res.STATUS_LOADING_MAP },
    -- [禁用] 游戏状态列表
    not_game_state = {},
    -- [启用] 配置开关列表
    yes_config     = {},
    -- [禁用] 配置开关列表
    not_config     = {},
    -- [时间] 模块超时设置(可选)
    time_out       = 0,
    -- [其它] 特殊情况才用(可选)
    is_working     = function()
        return not fight_mon_ent.is_stop_afk_farming()
    end,
    -- [其它] 功能函数条件(可选)
    is_execute     = function()
        return true
    end,
}

-- 轮循函数列表
dungeon.poll_functions = {}

------------------------------------------------------------------------------------
-- 预载函数(重载脚本时)
dungeon.super_preload = function()

end

-------------------------------------------------------------------------------------
-- 预载处理
dungeon.preload = function()
    settings.log_level        = 2
    settings.log_type_channel = 3
    fight_mon_ent.create_pos()
    
end

-------------------------------------------------------------------------------------
-- 轮循功能入口
dungeon.looping = function()
    loop_ent.looping('副本')
end

-------------------------------------------------------------------------------------
-- 功能入口函数
dungeon.entry = function()
    while decider.is_working()
    do
        local dungeon_info = dungeon_ent.get_can_do_dungeon_info()
        if table.is_empty(dungeon_info) then
            break
        end
        -- 执行轮循任务
        decider.looping()
        fight_mon_ent.go_to_pos_kill_mon(0,dungeon_info.dun_key,dungeon_ent.enter_dungeon,decider.looping,dungeon_info)
        -- 适当延时(切片)
        decider.sleep(2000)
    end
end

-------------------------------------------------------------------------------------
-- 模块超时处理
dungeon.on_timeout = function()
    local status = game_unit.get_game_status_ex()
    -- 非排队状态时超时-重启
end

-------------------------------------------------------------------------------------
-- 定时调用入口
dungeon.on_timer = function(timer_id)
    xxmsg('dungeon.on_timer -> '..timer_id)
end

-------------------------------------------------------------------------------------
-- 卸载处理
dungeon.unload = function()
    --xxmsg('login.unload')
end

-------------------------------------------------------------------------------------
-- 实例化新对象

function dungeon.__tostring()
    return this.MODULE_NAME
end

dungeon.__index = dungeon

function dungeon:new(args)
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
    return setmetatable(new, dungeon)
end

-------------------------------------------------------------------------------------
-- 返回对象
return dungeon:new()

-------------------------------------------------------------------------------------