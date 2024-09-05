-------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @author:   admin
-- @email:    88888@qq.com
-- @date:     2022-06-30
-- @module:   quest
-- @describe: 主线任务处理
-- @version:  v1.0
--

-------------------------------------------------------------------------------------
local quest = {
	VERSION        = '20211016.28',
	AUTHOR_NOTE    = "-[quest module - 20211016.28]-",
	MODULE_NAME    = '主线模块',
}

-- 自身模块
local this 		   = quest
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
	yes_config     = { '主线设置:开启主线' },
	-- [禁用] 配置开关列表
	not_config     = {},
	-- [时间] 模块超时设置(可选)
	time_out 	   = 0,
	-- [其它] 特殊情况才用(可选)
	is_working     = function() return not quest_ent.is_stop_main_task() end,
	-- [其它] 功能函数条件(可选)
	is_execute     = function() return true	end,
}

------------------------------------------------------------------------------------
-- 预载函数(重载脚本时)
quest.super_preload = function()

end

-------------------------------------------------------------------------------------
-- 预载处理
quest.preload = function()
	settings.log_level        = 2
	settings.log_type_channel = 3
end

-- 卸载处理
this.unload = function()
	xxmsg('quest.unload')

end

-------------------------------------------------------------------------------------
-- 轮循功能入口
quest.looping = function()
	loop_ent.looping()
end

-------------------------------------------------------------------------------------
-- 入口函数
quest.entry = function()
	decider.sleep(5000)
	while decider.is_working()
	do
		-- 非过图中
		if not login_res.is_loading_map() then
			-- 执行轮循任务
			decider.looping()
			quest_ent.auto_main_task(quick_ent.auto_set_quick_ex)
		else
			trace.output('正在过图中.')
		end
		-- 适当延时处理
		decider.sleep(2000)
	end		
end

-------------------------------------------------------------------------------------
-- 模块超时处理
quest.on_timeout = function()
	xxmsg('。。。。。主线模块处理超时。。。。。')
end

-------------------------------------------------------------------------------------
-- 实例化新对象

function quest.__tostring()
	return this.MODULE_NAME
end

quest.__index = quest

function quest:new(args)
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
	return setmetatable(new, quest)
end

-------------------------------------------------------------------------------------
-- 返回对象
return quest:new()

-------------------------------------------------------------------------------------