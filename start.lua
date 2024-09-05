-------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @author:   admin
-- @email:    88888@qq.com
-- @date:     2023-02-14
-- @module:   start
-- @describe: 入口文件
-- @version:  v1.0
--

-------------------------------------------------------------------------------------
local main_ctx      = main_ctx
local is_exit       = is_exit
local sleep         = sleep
local import        = import
local math          = math
local local_player  = local_player
-- 引入管理对象
local core          = import('base/core')
-- 导入公用库
local example       = import('example/example')

-------------------------------------------------------------------------------------
-- LUA入口函数(正式 CTRL+F5)
function main()
	-- 预载处理
	core.preload()
	-- 主循环
	while not is_exit()
	do
		core.entry() -- 入口调用
		sleep(1000)
	end
	-- 卸载处理
	core.unload()
	main_ctx:set_action('脚本停止')
end

-------------------------------------------------------------------------------------
-- 定时器入口
function on_timer(timer_id)
	-- 分发到脚本管理
	-- core.on_timer(timer_id)
end

function read_class_name(addr, count, start_of)
	for i = 0, count-1 do 
		local  obj = mem_unit.rm_dword64(addr + i * 8)
		xxmsg(string.format('%16X   %04X    %s    ', obj, start_of+ i*8  ,game_unit.get_obj_class_name(obj)))	
	end
end

function main_test()
	local common = common
	-- example:test_dungeon_unit()
	--xxmsg(item_unit.has_acquire_popup())
	-- example.test_item_unit(0)
	-- 学习
	--mastery_unit.study(id)
	-- 打开学习窗

	-- 检测学习窗
	--mastery_unit.is_open_mastery_popup()
	-- 关闭学习窗
	-- mastery_unit.close_mastery_popup()
	-- 检测熟练度场景
	--mastery_unit.is_open_mastery_scene()
	-- 打开熟练度场景
	-- mastery_unit.open_mastery_scene()
	-- 检测是否已学
	-- mastery_unit.mastery_is_study(id)
	--
	--example:test_mastery_unit()
	--example.test_daily_quest(0)
	--example.test_daily_quest(1)
	--example.test_daily_quest(2)
	--example.test_daily_quest(-1)
	-- xxmsg( main_ctx:c_fz_path() )
	-- example.test_item_unit(1)
	-- example.test_actor_unit(0)
	-- example:test_dungeon_unit()
	-- xxmsg(item_unit.has_acquire_popup() )
	local func = import('base/func')
	local actor_ent = import('game/entities/actor_ent')
	local configer = import('base/configer')

	-- [000002BE408793A0] [/Script/Mad.MButton] [/Engine/Transient.GameEngine.MPlatformGameInstance.PopupStoreGoodsPopupWidget_C.WidgetTree.CancelBtn]
	xxxmsg(2,'idx = MID：'..math.floor(actor_unit.map_id())..',X：'..math.floor(local_player:cx())..',Y：'..math.floor(local_player:cy())..',Z：'..math.floor(local_player:cz())..',NLV：1,MLV：100,R：20,M：3,L：1,MOD：0,PK模式：0')
	local top_window_id = ui_unit.get_top_window('/Engine/Transient.GameEngine.MPlatformGameInstance.PopupStoreGoodsPopupWidget_C', true)
	local child_control_id = ui_unit.get_child_control('/Engine/Transient.GameEngine.MPlatformGameInstance.PopupStoreGoodsPopupWidget_C.WidgetTree.CancelBtn')
	xxmsg(top_window_id..' '..child_control_id..' '..actor_unit.main_map_id()..' '..actor_unit.map_id())
	--xxmsg(ui_unit.btn_click(child_control_id))
	-- example.test_item_unit(0)
	
	local login_res = import('game/resources/login_res')
	local equip_ent = import('game/entities/equip_ent')
	local helper = import('base/helper')
	local ui_ent = import('game/entities/ui_ent')
	local item_res  = import('game/resources/item_res')

	local module_list = {
		import('game/modules/test'),
	}
	-- xxmsg(game_unit.is_connected_server())
	-- example.test_item_unit(0)


	--obj:     15680E16AF0   res_ptr     156D7795B00   id:          2FB23E    res_id:          1B1BDA   type:01   price:     90000   can_buy:true     name:기술서 부록 - 집중 공격 II(귀속)
	--obj:     15680E1CDB8   res_ptr     156D7795B00   id:          2FBB24    res_id:          1B1BDA   type:01   price:     90000   can_buy:true     name:기술서 부록 - 집중 공격 II(귀속)

--	npc_shop_unit.buy_item(0x11B3100011B3, 0x2FBB24, 1)
--obj:     1570CF02410   class_id:  1626BB   class_name:Role_SkillStore_C   id:    11B3100011B3    pos:[-24651.63 - -53500.00 - 2121.56]  job:-1   is_dead:false     is_combat:false    name레딘
	--example.test_actor_unit(2)
	--core.set_module_list(module_list)
	-- core.entry() -- 入口调用
	
	-- example:test_collection_unit()
	--game_unit.debug(0)
	--game_unit.debug(1)
	--game_unit.debug(2)
   -- actor_unit.debug(0)
	-- game_unit.debug(0)
	-- game_unit.debug(1)
	-- game_unit.debug(2)
	-- 检测弹窗
	--[000001D4AA55D360] [/Script/Mad.MButton] [/Engine/Transient.GameEngine.MPlatformGameInstance.EventPopupWidget_C.WidgetTree.CloseBtn]
--[/Engine/Transient.GameEngine.MPlatformGameInstance.PcClassSceneBp_C.WidgetTree.PcClassTreeViewWidget.WidgetTree.ClassUpgradeBtn]
	--[000001FE3555CD00] [/Script/Mad.MButton] [/Engine/Transient.GameEngine.MPlatformGameInstance.RootWidget_C.WidgetTree.MFrontBanner.WidgetTree.CloseBtn]
	
	--example.test_quick_unit()
	-- example.test_skill_unit()
	-- example.test_cash_unit()
	-- quick_unit.active_quick_skill(1, false)

	-- login_unit.enter_realm(login_id)
	-- xxmsg(login_unit.auth())
	-- xxmsg(login_unit.enter_game(0))
	-- common.test_show_unit()
	-- example.test_skill_unit()
	
	-- example.test_quest_unit(-1)
	-- example.test_item_unit(0)

   --xxmsg(game_unit.get_res_name_byid(0x1eb4c8))
   --xxmsg(game_unit.get_res_name_byid(0x1e23d7))
   -- xxmsg(game_unit.get_class_name_byid(0x1e23d7))
   --xxmsg(game_unit.get_class_name_byid(0x2fab7))
   -- xxmsg(game_unit.get_obj_class_name(game_unit.get_object_byid(0x0000641600012FEC)))
	--xxmsg(string.format('%16X', game_unit.get_object_byid(0x0000381C00011667)))
	

	 local configs = {
	     {
	         module = 'creature',
	         type = 1,
	         brief = '资源示例',
	         author = 'admin',
	         license = 'GPL',
	         version = '2.0.0',
	     },
	     {
	         module = 'creature',
	         type = 2,
	         brief = '实体示例',
	         author = 'admin',
	         --copyright = '2023',
	         --date = '2023-03-26',
	     },
	     --{
	     --    module = 'example',
	     --    type = 4,
	     --    brief = '模块示例',
	     --    author = 'admin',
	     --    copyright = '2023',
	     --    date = '2023-03-26',
	     --},
	 }
	 --local results = helper.build_scripts(configs, true) -- 设置 overwrite 为 true
	 --for _, result in ipairs(results) do
	 --    if result.success then
	 --        print('成功生成脚本：' .. result.result)
	 --    else
	 --        print('生成脚本失败：' .. result.result)
	 --    end
	 --end
	-- game_unit.debug(1)
end