-------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @author:   core
-- @email:    88888@qq.com
-- @date:     2021-11-03
-- @module:   common
-- @describe: 公共功能
-- @version:  v1.0
--

local VERSION = '20211103' -- version history at end of file
local AUTHOR_NOTE = "-[20211103]-"
---@class common
local common = {
	VERSION      = VERSION,
	AUTHOR_NOTE  = AUTHOR_NOTE,
	MODULE_NAME  = '公共功能',
	-- 金币ID[非钻]
	GOLD_COIN    = 3
}
local this 			   = common
local decider  		   = decider
local trace            = trace
-- 优化列表
local table            = table
local string           = string
local os               = os
local setmetatable     = setmetatable
local math			   = math
local tonumber		   = tonumber
local pairs			   = pairs
local ipairs		   = ipairs
local type			   = type
local actor_unit       = actor_unit
local item_unit		   = item_unit
local game_unit        = game_unit
local creature_unit    = creature_unit
local quest_unit       = quest_unit
local local_player     = local_player
local import           = import
local ui_unit          = ui_unit
local main_ctx         = main_ctx
local common_res       = import('game/resources/common_res')
-- 保存延时读取
local is_sleep_any_t   = {}
-- 保存延迟启动指定函数列表
local cache_read       = {}
-- 保存数值在间隔时间内的变化
local interval_change  = {}
-- 保存切换数据
local handle_list      = {}
-- 保存移动数据
local move_list        = {}
------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function common.super_preload()

end

-------------------------------------------------------------------------------------
-- 清除所有表数据
------------------------------------------------------------------------------------
common.clear_table = function()
	is_sleep_any_t  = {}
	cache_read      = {}
	interval_change = {}
end

-------------------------------------------------------------------------------------
-- 指定任务 在指定时间间隔内是否可执行
------------------------------------------------------------------------------------
common.is_sleep_any = function(arg,time)
	local args = arg or '全局'
	time = time or 1
	if is_sleep_any_t[args] ~= nil then
		if os.time() - is_sleep_any_t[args] < time then
			return false
		end
	end
	is_sleep_any_t[args] = os.time()
	return true
end

------------------------------------------------------------------------------------
-- 延迟读取指定函数的返回值[单参返回]
------------------------------------------------------------------------------------
common.get_cache_result = function(name,func,time,...)
	if cache_read[name] then
		if os.time() - cache_read[name].time < time then
			return cache_read[name].result
		end
	end
	local result = func(...)
	cache_read[name] = { result = result,time = os.time() }
	return result
end

------------------------------------------------------------------------------------
-- 延迟读取指定函数的返回值[多参返回]
------------------------------------------------------------------------------------
common.get_cache_result_ex = function(name,func,time,...)
	if cache_read[name] then
		if os.time() - cache_read[name].time < time then
			return table.unpack(cache_read[name].result)
		end
	end
	local result = { func(...) }
	cache_read[name] = { result = result,time = os.time() }
	return table.unpack(result)
end

------------------------------------------------------------------------------------
-- 获取指定时间间隔的变化,value 为true时清空列表
------------------------------------------------------------------------------------
common.get_interval_change = function(name,value,time)
	local data = interval_change[name]
	if data then
		if value == true then
			interval_change[name] = { time = os.time(),value = value,count = 0}
			return 0,0
		end
		if os.time() - data.time > time then
			if value ~= data.value then
				interval_change[name] = { time = os.time(),value = value,count = 0 }
				return 3,0
			end
			local count = data.count + 1
			interval_change[name] = { time = os.time(),value = value,count = count}
			return 2,count
		end
		return 1,0
	end
	interval_change[name] = { time = os.time(),value = value,count = 0}
	return 0,0
end

------------------------------------------------------------------------------------
-- 保存指定操作在时间内次数[inter_time = 0 时 清空次数 is_get = true 时只读取 不写入]
------------------------------------------------------------------------------------
common.get_handle_count = function(do_name,inter_time,is_get)
	local count 					= 1
	local data 					    = handle_list[do_name]
	local time  					= os.time()
	if data then
		if data.time and os.time() - data.time < inter_time then
			count = count + data.count
			time  = data.time
		end
	end
	if not is_get then
		handle_list[do_name] = { time = time,count = count }
	end
	return count
end

------------------------------------------------------------------------------------
-- 根据坐标,朝向 计算 前后左右的坐标[v = 0（前） 1（后）2（左）3（右） ]
------------------------------------------------------------------------------------
common.get_pos_by_mon_pos_and_dir = function(x,y,dist,dir,v)
	local data    = {}
	-- 将朝向方向转换为弧度制
	local angle   = dir * math.pi / 4
	
	-- 计算左边的坐标
	local left_x  = x + dist * math.cos(angle - math.pi / 2)
	local left_y  = y + dist * math.sin(angle - math.pi / 2)
	
	-- 计算右边的坐标
	local right_x = x + dist * math.cos(angle + math.pi / 2)
	local right_y = y + dist * math.sin(angle + math.pi / 2)
	
	-- 计算前面的坐标
	local front_x = x + dist * math.cos(angle - 2 * math.pi)
	local front_y = y + dist * math.sin(angle - 2 * math.pi)
	
	-- 计算后背的坐标
	local back_x  = x + dist * math.cos(angle + math.pi)
	local back_y  = y + dist * math.sin(angle + math.pi)
	
	data['前']    = {x = front_x,y = front_y}
	data['后']    = {x = back_x, y = back_y}
	data['右']    = {x = right_x,y = right_y}
	data['左']    = {x = left_x, y = left_y}
	return (v and data and data[v] or {}) or data
end

-------------------------------------------------------------------------------------
-- 根据角度，距离，坐标 获取坐标
------------------------------------------------------------------------------------
common.get_circle_pos = function(x,y,n_angle,dis)
	if not n_angle then
		return x,y
	end
	local n_sin = math.sin(math.rad(n_angle))
	local n_cos = math.cos(math.rad(n_angle))
	local fx = x + n_cos * dis
	local fy = y + n_sin * dis
	return tonumber(string.format('%0.1f',fx)),tonumber(string.format('%0.1f',fy))
end

-------------------------------------------------------------------------------------
-- 当前地图寻路
------------------------------------------------------------------------------------
common.auto_move = function(x1,y1,z,...)
	math.randomseed(os.clock())
	local min_r,max_r = ...
	min_r         	  = min_r or 30
	max_r 		 	  = max_r and (min_r > max_r and min_r or max_r) or 100
	-- 取随机角度
	local n_angle 	  = math.random(0,360)
	-- 取随机半径
	local dis     	  = math.random(min_r,max_r) + this.get_rand_value( 1,10,100,1000,10000,100000 )
	-- 获取计算后的坐标
	local x,y 		  = this.get_circle_pos(x1,y1,n_angle,dis)
	-- 随机z
	z 				  = z + math.random(1,50) + this.get_rand_value( 1,10,100,1000,10000,100000 )
	this.set_sleep(0)
	-- 执行移动到新坐标
	this.set_auto(0)
	actor_unit.auto_move(x,y,z)
	return true
end

-------------------------------------------------------------------------------------
-- 是否在移动
common.is_move = function()
	local self_x = local_player:cx()
	local self_y = local_player:cy()
	if table.is_empty(move_list) then
		move_list = { last_self_x = self_x,last_self_y = self_y,last_update_time = os.time() }
		return false
	end
	-- 计算距离上一次更新坐标经过了多长时间
	local dt = os.time() - move_list.last_update_time
	if dt > 10 then
		move_list = { last_self_x = self_x,last_self_y = self_y,last_update_time = os.time() }
		return false
	end
	-- 计算自上一次检查以来移动的距离
	local dx = self_x - move_list.last_self_x
	local dy = self_y - move_list.last_self_y
	local distance = math.sqrt(dx * dx + dy * dy)
	move_list = { last_self_x = self_x,last_self_y = self_y,last_update_time = os.time() }
	return distance / dt > 5
end

-------------------------------------------------------------------------------------
-- 获取随机值1-n
------------------------------------------------------------------------------------
common.get_rand_value = function(...)
	local num = 0
	for _,v in pairs( { ... } ) do
		local v_num = v * 100
		num         = num + math.random(1,v_num)/v_num
	end
	return num
end

-------------------------------------------------------------------------------------
-- 等待铜钱变化
------------------------------------------------------------------------------------
common.wait_change_money = function(c_money,set_name,wait_time)
	return this.wait_change_type(c_money,set_name,wait_time,item_unit.get_money_byid,1)
end

-------------------------------------------------------------------------------------
-- 等待钻的变化
------------------------------------------------------------------------------------
common.wait_change_gold = function(c_gold,set_name,wait_time)
	return this.wait_change_type(c_gold,set_name,wait_time,item_unit.get_money_byid,0)
end

-------------------------------------------------------------------------------------
-- 等待类型值变化
------------------------------------------------------------------------------------
common.wait_change_type = function(c_money,set_name,wait_time,func,...)
	local v_time = os.time()
	wait_time = wait_time or 60
	while decider.is_working() do
		if func(...) ~= c_money then return true end
		if os.time() - v_time > wait_time then break end
		trace.output('正在'..set_name..'['..(wait_time + v_time - os.time())..']')
		decider.sleep(1000)
	end
	return false
end

------------------------------------------------------------------------------------
-- [条件] 判断指定名字是否在列表存在
--
-- @tparam          any                                  list              物品列表，物品名或其他字段如{'A','B','C'},{1,2,3}
-- @tparam          any                                  name              需要在list中配对的目标参数[可string/number]
-- @treturn         bool                                                   返回 true (name 在 list 存在)
-- @usage
-- local is_exist = item_ent.is_exist_list_arg('A',A)
-- local is_exist = item_ent.is_exist_list_arg({'A','B'},A)
-- local is_exist = item_ent.is_exist_list_arg(12,1)
-- local is_exist = item_ent.is_exist_list_arg({12,13},1)
------------------------------------------------------------------------------------
common.is_exist_list_arg = function(list, name)
	local t = type(list)
	if t ~= 'nil' and t ~= 'table' then
		list = { list }
	end
	if type(list) == 'table' then
		for _, v in pairs(list) do
			if v == name then return true end
		end
	end
	
	return false
end

------------------------------------------------------------------------------------
-- 检测掉线
common.check_connect = function()
	local connect        = game_unit.is_connected_server()
	local bool_val,count = this.get_interval_change('connected_server',connect,10)
	if bool_val == 2 and count > 3 and not connect then
		trace.log_warn('连接已断开-重启游戏')
		main_ctx:end_game()
		return true
	end
	return false
end

------------------------------------------------------------------------------------
-- 是否对话中
common.is_has_dialog = function()
	local top_window_id = ui_unit.get_top_window('/Engine/Transient.GameEngine.MPlatformGameInstance.DialogSceneBp_C', true)
	return top_window_id ~= 0 or game_unit.has_dialog()
end

------------------------------------------------------------------------------------
-- 对话关闭
------------------------------------------------------------------------------------
common.execute_pass_dialog = function()
	while decider.is_working() do
		if not this.is_has_dialog() then
			return
		end
		common.set_sleep(0)
		decider.sleep(2000)
		-- 检测获取物品后窗口
		if item_unit.has_acquire_popup() then
			trace.output('关闭物品获取窗口.')
			item_unit.close_acquire_popup()
		else
			if creature_unit.has_gacha_scene() then
				trace.output('关闭召唤页.')
				decider.sleep(1000)
				creature_unit.close_gacha_scene()
			else
				trace.output('正在对话.')
				game_unit.pass_dialog()
			end
		end
		decider.sleep(3000)
	end
end

-------------------------------------------------------------------------------------
-- 背包操作[0 关闭  1打开]
common.handle_bag = function(v_handle)
	if v_handle == 0 then
		if item_unit.is_open_inventory() then
			item_unit.close_inventory()
			decider.sleep(2000)
		end
	else
		if not item_unit.is_open_inventory() then
			item_unit.open_inventory()
			decider.sleep(2000)
		end
	end
end

-------------------------------------------------------------------------------------
-- 设置打怪范围
-- @tparam  number   value     打怪的范围[0 - 100米]
-------------------------------------------------------------------------------------
common.set_kill_range = function(value)
	if this.is_sleep_any('set_kill_range',60) then
		for k,v in pairs(common_res.KILL_RANGE) do
			if value <= v then
				if game_unit.get_kill_range() ~= k then
					game_unit.set_kill_range(k)
				end
				break
			end
		end
	end
end

-------------------------------------------------------------------------------------
-- 设置打怪[0 关闭 1 开启]
-------------------------------------------------------------------------------------
common.set_auto = function(set_type)
	if set_type == 1 then
		if actor_unit.get_auto_type() ~= 4 then
			this.set_sleep(0)
			actor_unit.auto_play()
			decider.sleep(1000)
		end
	else
		if actor_unit.get_auto_type() ~= 0 or quest_unit.get_cur_auto_quest_id() ~= 0 then
			this.set_sleep(0)
			actor_unit.auto_play()
			decider.sleep(1000)
		end
	end
end

-------------------------------------------------------------------------------------
-- 设置省电模式
-------------------------------------------------------------------------------------
common.set_sleep = function(mod,wait_time)
	wait_time = wait_time or 30
	if game_unit.is_in_sleep_mode() then
		if mod == 0 then
			decider.sleep(3000)
			game_unit.set_sleep_mode(0)
			decider.sleep(3000)
		end
	else
		if mod == 1 then
			if this.is_sleep_any('set_sleep1',wait_time) then
				decider.sleep(3000)
				game_unit.set_sleep_mode(1)
			end
		end
	end
end

-------------------------------------------------------------------------------------
-- 检测省电
------------------------------------------------------------------------------------
common.check_sleep = function(ret_read)

end

------------------------------------------------------------------------------------
-- 小退游戏
------------------------------------------------------------------------------------
common.change_character = function(str)

end

-------------------------------------------------------------------------------------
-- [读取] 读取指定单元数据-根据字段配对
-- @tparam	table  		unit_list  	单元的_unit.list()函数，如：item_unit.list(0)
-- @tparam	userdata  	ctx   		数据ctx，如：item_ctx
-- @tparam  any         init_pos	读取单元数据的类型，如果没有类型则传入nil,如item_unit 读取背包则传入0
-- @tparam  any         ...			可变参数传入需要读取的字段
-- @treturn list					需要读取的数据表集合
-- @tfield[list]	any		...		传入的字段
-- @usage
-- local info = common.get_unit_info_any(item_unit.list(0),item_ctx,0,{params = 0x123,field = 'id'},'id','name','res_id')
-------------------------------------------------------------------------------------
common.get_unit_info_any = function(unit_list,ctx,init_pos,read_cond,...)
	local params = read_cond.params
	local field = read_cond.field
	local result = {}
	local init_pos_y = type(init_pos)
	for _,obj in pairs(unit_list) do
		-- 条件模式
		if init_pos_y == 'number' and ctx:init(obj, init_pos) or ctx:init(obj) then
			if this.is_exist_list_arg(ctx[field](ctx),params) then
				for _,v in pairs({...} ) do
					-- 获取指定属性的值
					local value = ctx[v](ctx)
					-- xxmsg(v..'----'..value)
					result[v] = value
				end
				break
			end
		end
	end
	return result
end

------------------------------------------------------------------------------------
-- 过滤表中重复数据
------------------------------------------------------------------------------------
common.filter_duplicatedata = function(tbl)
	local hash = {}
	local res = {}
	for _,v in ipairs(tbl) do
		if not hash[v] then
			res[#res+1] = v
			hash[v] = true
		end
	end
	return res
end

-------------------------------------------------------------------------------------
-- [读取] 读取指定单元所有数据
-- @tparam	table  		unit_list  	单元的_unit.list()函数，如：item_unit.list(0)
-- @tparam	userdata  	ctx   		数据ctx，如：item_ctx
-- @tparam  any         init_pos	读取单元数据的类型，如果没有类型则传入nil,如item_unit 读取背包则传入0
-- @tparam  any         ...			可变参数传入需要读取的字段
-- @treturn list					需要读取的数据表集合
-- @tfield[list]	any		...		传入的字段
-- @usage
-- local list = common.get_unit_info_list(item_unit.list(0),item_ctx,0,'id','name','res_id')
-------------------------------------------------------------------------------------
common.get_unit_info_list = function(unit_list,ctx,init_pos,...)
	local ret = {}
	local init_pos_y = type(init_pos)
	for _,obj in pairs(unit_list) do
		if init_pos_y == 'number' and ctx:init(obj, init_pos) or ctx:init(obj) then
			local result = {}
			for _,v in pairs({...} ) do
				-- 获取指定属性的值
				local value = ctx[v](ctx)
				-- xxmsg(v..'----'..value)
				result[v] = value
			end
			table.insert(ret,result)
		end
	end
	return ret
end

-------------------------------------------------------------------------------------
-- [读取] 读取指定单元所有数据
-- @tparam	table  		unit_list  	单元的_unit.list()函数，如：item_unit.list(0)
-- @tparam	userdata  	ctx   		数据ctx，如：item_ctx
-- @tparam  any         init_pos	读取单元数据的类型，如果没有类型则传入nil,如item_unit 读取背包则传入0
-- @tparam  any         ...			可变参数传入需要读取的字段
-- @treturn list					需要读取的数据表集合
-- @tfield[list]	any		...		传入的字段
-- @usage
-- local info_list = common.get_unit_info_list_by_any = function(item_unit.list(0),item_ctx,0,{params = {'普通饲料','铜钱箱子'},field = 'name'},...)
-------------------------------------------------------------------------------------
common.get_unit_info_list_by_any = function(unit_list,ctx,init_pos,read_cond,...)
	local ret = {}
	local params = read_cond.params
	local field = read_cond.field
	local init_pos_y = type(init_pos)
	for _,obj in pairs(unit_list) do
		if init_pos_y == 'number' and ctx:init(obj, init_pos) or ctx:init(obj) then
			if this.is_exist_list_arg(params,ctx[field](ctx)) then
				local result = {}
				for _,v in pairs({...} ) do
					-- 获取指定属性的值
					local value = ctx[v](ctx)
					-- xxmsg(v..'----'..value)
					result[v] = value
				end
				table.insert(ret,result)
			end
		end
	end
	return ret
end

-------------------------------------------------------------------------------------
-- [读取] 读取指定单元数据-根据字段配对
-- @tparam	table  		unit_list  	单元的_unit.list()函数，如：item_unit.list(0)
-- @tparam	userdata  	ctx   		数据ctx，如：item_ctx
-- @tparam  any         init_pos	读取单元数据的类型，如果没有类型则传入nil,如item_unit 读取背包则传入0
-- @tparam  any         ...			可变参数传入需要读取的字段
-- @treturn list					需要读取的数据表集合
-- @tfield[list]	any		...		传入的字段
-- @usage
-- local info = common.get_unit_info_any(item_unit.list(0),item_ctx,0,{params = 0x123,field = 'id'},'id','name','res_id')
-------------------------------------------------------------------------------------
common.get_unit_info_any = function(unit_list,ctx,init_pos,read_cond,...)
	local params = read_cond.params
	local field = read_cond.field
	local result = {}
	local init_pos_y = type(init_pos)
	for _,obj in pairs(unit_list) do
		-- 条件模式
		if init_pos_y == 'number' and ctx:init(obj, init_pos) or ctx:init(obj) then
			if this.is_exist_list_arg(params,ctx[field](ctx)) then
				for _,v in pairs({...} ) do
					-- 获取指定属性的值
					local value = ctx[v](ctx)
					-- xxmsg(v..'----'..value)
					result[v] = value
				end
				break
			end
		end
	end
	return result
end

------------------------------------------------------------------------------------
-- [功能] 计算最大购买数
--
-- @tparam      int		max_num		最大值
-- @tparam      int		price		单价
-- @tparam      int		save        保留金额
-- @return      int		num   		最大购买数
-- @usage
-- local num = common.calc_num(最大值,单价,最大购买数)
--------------------------------------------------------------------------------
common.calc_num = function(max_num, price, save)
	if max_num <= 0 then
		return 0
	end
	save = save or 50000
	local money = item_unit.get_money_byid(this.GOLD_COIN) - save
	if money <= price then
		return 0
	end
	if money < (max_num * price) then
		max_num = money / price
	end
	return math.floor(max_num)
end

-------------------------------------------------------------------------------------
-- [测试] 测试单元输出
-- @tparam	table  		list  		单元的_unit.list()函数，如：item_unit.list(0)
-- @tparam	userdata  	ctx   		数据ctx，如：item_ctx
-- @tparam  any         init_pos	读取单元数据的类型，如果没有类型则传入nil,如item_unit 读取背包则传入0
-- @tparam  any         ...			可变参数传入需要读取的字段
-- @usage
-- common.test_unit(item_unit.list(0),item_ctx,0,'id','name','res_id')
-------------------------------------------------------------------------------------
common.test_unit = function(list,ctx,init_pos,...)
	--xxmsg('--------------------------------------------------------------------------------')
	--while not is_terminated() do
	--	local list = this.get_unit_info_list(list,ctx,init_pos,...)
	--	sleep(100)
	--end
	local list = this.get_unit_info_list(list,ctx,init_pos,...)
	xxmsg('--------------------------------------------------------------------------------')
	xxmsg('读取到总数【'..#list..'】')
	for k,v in pairs(list) do
		local str = ''
		for key,val in pairs(v) do
			if str == '' then
				str = string.format('【%s】%s',key,val)
			else
				str = str..string.format(',【%s】%s',key,val)
			end
		end
		xxmsg(k..'-'..str)
	end
end

---------------------------------------------------------------------------------------
-- [测试] 测试各单元输出
common.test_show_unit = function()
	-- 0 当前角色 1玩家 2 npc 3 怪物
	--xxmsg('--------------------------------------------------------')
	local actor_l = {
		{ '当前角色',0 },
		{ '玩家',1 },
		{ 'npc',2 },
		{ '怪物',3 },
	}
	for _,v in pairs(actor_l) do
		local info_list = this.get_unit_info_list(actor_unit.list(v[2]),actor_ctx,v[2],'id','name','cx','cy','cz','is_dead','is_combat')
		xxmsg('------------'..v[1]..'------------')
		for k,info in pairs(info_list) do
			xxmsg(info.id..' name:'..info.name..' cx:'..info.cx..' cy:'..info.cy..' cz:'..info.cz..' is_dead:'..tostring(info.is_dead)..' is_combat:'..tostring(info.is_combat))
		end
	end
	local info_list = this.get_unit_info_list(skill_unit.list(),skill_ctx,v[2],'name','id','group_id','cy','cz','is_dead','is_combat')
	xxmsg('------------'..v[1]..'------------')
	for k,info in pairs(info_list) do
		xxmsg(info.id..' name:'..info.name..' cx:'..info.cx..' cy:'..info.cy..' cz:'..info.cz..' is_dead:'..tostring(info.is_dead)..' is_combat:'..tostring(info.is_combat))
	end
	xxmsg('--------------------------------------------------------')
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function common.__tostring()
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
function common.__newindex(t, k, v)
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
common.__index = common

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function common:new(args)
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
	return setmetatable(new, common)
end

-------------------------------------------------------------------------------------
-- 返回对象
return common:new()

-------------------------------------------------------------------------------------