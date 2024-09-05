-------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @author:   admin
-- @email:    88888@qq.com
-- @date:     2022-06-30
-- @module:   daily_quest
-- @describe: 日常任务处理
-- @version:  v1.0
--

-------------------------------------------------------------------------------------
local daily_quest = {
	VERSION        = '20211016.28',
	AUTHOR_NOTE    = "-[daily_quest module - 20211016.28]-",
	MODULE_NAME    = '日常任务模块',
}

-- 自身模块
local this         = daily_quest
local import       = import
local common       = common
-- 配置模块
local settings     = settings
-- 日志模块
local trace        = trace
-- 决策模块
local decider      = decider
local item_unit    = item_unit
local pairs        = pairs
local setmetatable = setmetatable
-------------------------------------------------------------------------------------
-- 登陆资源
local login_res    = import('game/resources/login_res')
-- 任务单元
---@type quest_ent
local quest_ent    = import('game/entities/quest_ent')
---@type quick_ent
local quick_ent    = import('game/entities/quick_ent')
---@type loop_ent
local loop_ent     = import('game/entities/loop_ent')
-------------------------------------------------------------------------------------
-- 运行前置条件
this.eval_ifs = {
	-- [启用] 游戏状态列表
	yes_game_state = { login_res.STATUS_IN_GAME | login_res.STATUS_LOADING_MAP },
	-- [禁用] 游戏状态列表
	not_game_state = {},
	-- [启用] 配置开关列表
	yes_config     = { '日常设置:开启日常' },
	-- [禁用] 配置开关列表
	not_config     = {},
	-- [时间] 模块超时设置(可选)
	time_out 	   = 0,
	-- [其它] 特殊情况才用(可选)
	is_working     = function() return true end,
	-- [其它] 功能函数条件(可选)
	is_execute     = function() return true	end,
}

------------------------------------------------------------------------------------
-- 预载函数(重载脚本时)
daily_quest.super_preload = function()

end

-------------------------------------------------------------------------------------
-- 预载处理
daily_quest.preload = function()
	settings.log_level        = 2
	settings.log_type_channel = 3
end

-- 卸载处理
this.unload = function()
	xxmsg('daily_quest.unload')

end

-------------------------------------------------------------------------------------
-- 轮循功能入口
daily_quest.looping = function()
	loop_ent.looping()
end

-------------------------------------------------------------------------------------
-- 入口函数
daily_quest.entry = function()
	while decider.is_working()
	do
		-- 非过图中
		if not login_res.is_loading_map() then
			if not quest_ent.execute_daily_task(quick_ent.auto_set_quick_ex) then
				break
			end
			-- 执行轮循任务
			decider.looping()
		else
			trace.output('正在过图中.')
		end
		-- 适当延时处理
		decider.sleep(2000)
	end		
end

-------------------------------------------------------------------------------------
-- 模块超时处理
daily_quest.on_timeout = function()
	xxmsg('。。。。。日常模块处理超时。。。。。')
end

-------------------------------------------------------------------------------------
-- 实例化新对象

function daily_quest.__tostring()
	return this.MODULE_NAME
end

daily_quest.__index = daily_quest

function daily_quest:new(args)
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
	return setmetatable(new, daily_quest)
end

-------------------------------------------------------------------------------------
-- 返回对象
return daily_quest:new()

-------------------------------------------------------------------------------------