-------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @author:   core
-- @email:    88888@qq.com 
-- @date:     2021-07-05
-- @module:   example
-- @describe: 示例代码模块
-- @version:  v1.0
--

local VERSION = '20210705' -- version history at end of file
local AUTHOR_NOTE = "-[20210705]-"

local example = {  
	VERSION      = VERSION,
	AUTHOR_NOTE  = AUTHOR_NOTE,
}

local this = example

local config_client = import('base/config')


--  ui_unit.exit_widget()

-------------------------------------------------------------------------------------
-- test_mastery_unit
function example:test_mastery_unit()
   local list = mastery_unit.list()
   xxmsg('数量：'..#list)
   for i = 1, #list do
      local obj = list[i]
      if mastery_ctx:init(obj) then
         xxmsg(string.format('%X   %X   %02d  %02d   %-6s',
                 obj,
                 mastery_ctx:id(),
                 mastery_ctx:level(),
                 mastery_ctx:class_id(),
                 mastery_ctx:is_study()

         ))

      end
   end

   -- 学习
   --mastery_unit.study(id)
   -- 打开学习窗
   --mastery_unit.open_mastery_popup()
   -- 检测学习窗
   -- mastery_unit.is_open_mastery_popup()
   -- 关闭学习窗
   -- mastery_unit.close_mastery_popup()
   -- 检测熟练度场景
   -- mastery_unit.is_open_mastery_scene()
   -- 打开熟练度场景
   -- mastery_unit.open_mastery_scene()
   -- 检测是否已学
   -- mastery_unit.mastery_is_study(id)
   -- 取熟练等级
   -- mastery_unit.get_mastery_level()


end

-------------------------------------------------------------------------------------
-- test_game_unit
example.test_game_unit = function()
   -- 游戏状态
   -- game_unit.get_game_status_ex()
   -- 检测是否有对话框（任务中对话）
   -- game_unit.has_dialog()
   -- 过对话框
   -- game_unit.pass_dialog()
   -- 过接受登陆协议
   -- game_unit.pass_terms_agreement()
   -- 取当前大陆ID
   -- actor_unit.cur_main_map_id()
   -- 频道
   -- 取当前频道
   -- actor_unit.get_cur_channel()
   -- 取当前大陆频道数
   -- actor_unit.get_cur_map_channel_num()
   -- 取频道状态（0绿，1黄，2红） - 1频道不存在
   -- actor_unit.get_channel_status(id)
   -- 打开频道切换窗（刷新频道做用。换频道必须打开）
   -- actor_unit.open_channle_shift_widget()
   -- 判断频道窗口是否打开
   -- actor_unit.is_open_channle_shift_widget()
   -- 切换频道
   -- actor_unit.change_channel(id)
end

-------------------------------------------------------------------------------------
-- test_login_unit
example.test_login_unit = function()
   -- 增加小退游戏
   game_unit.leave_game()
   -- 增加进入创建角色页
   login_unit.enter_create_page()
   -- 服务器名称取服务器ID
   --login_unit.get_server_id_byname("名称")
   -- 检查服务器是否限制
   -- login_unit.check_server_limit(server_id)
   -- 点击进游戏时的启动页
   --login_unit.auth()     
   -- 登陆服务器
   --login_unit.enter_realm(server_id)
   -- 创建角色（目前只支持猎人）
   --login_unit.create_character('','')  -- 自动生成名称，自动创猎人
   --login_unit.create_character('名称','猎人')
   -- 进入游戏(角色序号 0 or 1)
   --login_unit.enter_game(role_idx)
   -- 是否排队
  -- login_unit.is_wating_enter_realm()
   -- 取排队数
   --login_unit.get_wating_enter_realm_num()
   

   -- 角色遍历
   local list = login_unit.role_list()
   xxmsg('角色数量'..#list)
   for i = 1, #list do 
      local obj = list[i]
      if login_ctx:init(obj) then 
         xxmsg(string.format('obj:%16X    idx:%02d    id:%16X    job:%08X   level:%04d    name:%s',
           obj, 
           i-1,
           login_ctx:id(),
           login_ctx:job(),
           login_ctx:level(),
           login_ctx:name()
      
      ))
      end
   end
end

-------------------------------------------------------------------------------------
-- test_item_unit
example.test_item_unit = function(type)
 
   local list = item_unit.list(type)
   xxmsg('物品数量：'..#list)
   for i = 1, #list do 
      local obj = list[i]
      if item_ctx:init(obj) then 
        -- xxmsg(item_ctx:id())
         xxmsg(string.format('obj:%16X   res_ptr:%16X   id:%16X    res_id:%04X    type:%02d    num:%06d   quality:%02d  weight:%06d  equip_type:%03d   equip_job:%03d    enhanced_level:%02d   name:%s  is_damage:%s',
            obj,
            item_ctx:res_ptr(),
            item_ctx:id(),
            item_ctx:res_id(),
            item_ctx:type(),
            item_ctx:num(),
            item_ctx:quality(),
            item_ctx:weight(),
            item_ctx:equip_type(),           
            item_ctx:equip_job(),            -- 副武器好像不一样 
            item_ctx:enhanced_level(),                   --强化等级
            item_ctx:name(),
                             item_ctx:is_damage()
         ))
      end
   end

   -- 使用物品  相当背包双击
   --item_unit.use_item(item_id, 1)
   -- id 取金钱（0钻 1铜 ）
   -- item_unit.get_money_byid(1)
   -- 检测任务中使用装备的窗口
   --item_unit.has_auto_equip_widget() 
   -- 使用自动装备（弹窗）
   --item_unit.auto_equip()
   -- 强化装备
   -- item_unit.enhancement_equip(equip_id, item_id)
 
end


-------------------------------------------------------------------------------------
-- test_daily_quest --1 所有， 0 可接， 1 已接，2 可提交
example.test_daily_quest = function(ntype)
   local str = ntype == 0 and '可接[0]' or ntype == 1 and '已接[1]' or ntype == 2 and '可提交[2]' or '所有'
   ntype = ntype or -1
   local list = quest_unit.daily_list(ntype)
   xxmsg(str..'-任务数量：'..#list)
   for i = 1, #list do
      local obj = list[i]
      if quest_ctx:init(obj) then
         
         xxmsg(string.format('obj:%16X   res_ptr:%16X   id:%X   step_id:%X   type:%03d    status:%03d  level:%03d   cur_num:%04d   max_mun:%04d   name:%s',
                             obj,
                             quest_ctx:res_ptr(),
                             quest_ctx:id(),
                             quest_ctx:step_id(),
                             quest_ctx:type(),
                             quest_ctx:status(),
                             quest_ctx:daily_quest_level(),   -- 日常任务等级
                             quest_ctx:cur_tar_num(),
                             quest_ctx:max_tar_num(),
                             quest_ctx:name()
         ))
      end
   end
   -- 接受任务
   --quest_unit.accept_dayly(id)
   -- 完成任务
   -- quest_unit.complate_daily(id)

end

-------------------------------------------------------------------------------------
-- test_actor_unit

example.test_actor_unit = function(nType)
      -- 0 当前角色 1玩家 2 npc 3 怪物
      local list = actor_unit.list(nType)
      xxmsg('对象数量：'..#list)
      for i = 1, #list do 
         local obj = list[i]
         if actor_ctx:init(obj) then 
            xxmsg(string.format('obj:%16X   class_id:%8X   class_name:%-16s   id:%16X    pos:[%0.2f - %0.2f - %0.2f]  job:%02d   is_dead:%-6s    is_combat:%-6s   name%s',
            obj,
            actor_ctx:name_id(),
            actor_ctx:class_name(),
            actor_ctx:id(),
            actor_ctx:cx(),
            actor_ctx:cy(),
            actor_ctx:cz(),
            actor_ctx:job(),
            actor_ctx:is_dead(),
            actor_ctx:is_combat(),
            actor_ctx:name()
         ))
         end
      end
      -- 寻路
      -- actor_unit.auto_move(x, y, z)
      -- 开关自动打怪
      -- actor_unit.auto_play() 
      -- 复活
      -- actor_unit.rise_man()
      -- 自动类型（任务 反回任务ID  0未工作）
      -- actor_unit.get_auto_type()

      -- 打开换职业窗口
      --actor_unit.open_class_widget()
      -- 判断换职业窗口是否打开
      --actor_unit.pcclass_widget_is_open();
      -- 选择职业（目前只支持换该职业 弓手第一个职业）
      -- xxmsg(actor_unit.select_class("阿彻"))

      -- 角色血
		----actor_unit.local_player_hp()
      -- 角色蓝
		--actor_unit.local_player_mp()
      -- 最大血
		--actor_unit.local_player_max_hp()
      -- 最大蓝
		--actor_unit.local_player_max_mp()
      -- 角色等级
		-- actor_unit.local_player_level()

end

-------------------------------------------------------------------------------------
-- test_quest_unit
example.test_quest_unit = function(ntype)
   local list = quest_unit.list(ntype)
   xxmsg('任务数量：'..#list)
   for i = 1, #list do 
      local obj = list[i]
      if quest_ctx:init(obj) then 
	  
         xxmsg(string.format('obj:%16X   res_ptr:%16X   id:%X   step_id:%X   type:%03d    status:%03d    cur_num:%04d   max_mun:%04d   name:%s',
               obj,
               quest_ctx:res_ptr(),
               quest_ctx:id(),
               quest_ctx:step_id(),
               quest_ctx:type(),
               quest_ctx:status(),
               quest_ctx:cur_tar_num(),
               quest_ctx:max_tar_num(),
               quest_ctx:name()
         ))
      end
   end
   -- 接受任务
   --quest_unit.accept(id)
   -- 完成任务
   -- quest_unit.complate(id)
   -- 自动任务
   -- quest_unit.auto_quest(id)
   -- 是否有任务传送挂件
   -- qeust_unit.has_quest_teleport_popup()
   -- 确认任务传送（只任务可用）
   -- qeust_unit.confirm_quest_teleport()
   -- 指针任务是否在自动
   -- quest_unit.quest_is_auto(id)
   -- 取当前自动任务ID
   -- quest_unit.get_cur_auto_quest_id()

end

-------------------------------------------------------------------------------------
-- test_skill_unit
example.test_skill_unit = function()
   local list = skill_unit.list()
   xxmsg('技能数：'..#list)
   for i = 1, #list do 
      local obj = list[i]
      if skill_ctx:init(obj) then 
         xxmsg(string.format('obj:%16X  res_ptr:%16X   id:%16X  group_id:%16X  cooling_time:%08d  mp:%03d  is_study:%-6s  name:%s level:%s',
         obj,
         skill_ctx:res_ptr(),
         skill_ctx:id(),
         skill_ctx:group_id(),
         skill_ctx:cooling_time(),
         skill_ctx:mp(),
         skill_ctx:is_study(),
         skill_ctx:name(),
                             skill_ctx:level()
       ))
      end
   end
end

-------------------------------------------------------------------------------------
-- test_creature_unit(0 坐骑，1翅膀，2武器图)
example.test_creature_unit = function(ntype)
   local list = creature_unit.list(ntype)
   xxmsg('图数量：'..#list)
   for i = 1, #list do 
      local obj = list[i]
      if creature_ctx:init(obj) then 
         xxmsg(string.format('obj:%16X   res_ptr:%16X  id:%16X   type:%02d   num:%04d   quality:%02d   weapon_class_is:%02d  is_used:%-6s  name:%s',
         obj,
         creature_ctx:res_ptr(),
         creature_ctx:id(),
         creature_ctx:type(),
         creature_ctx:num(),
         creature_ctx:quality(),
         creature_ctx:weapon_class_id(),
         creature_ctx:is_used(),
         creature_ctx:name()
      ))
      end
   end

   -- 使用 坐骑，翅膀， 武器图（id）
   --creature_unit.use_creature(0x50012F0E2 )
   -- 当前使用图ID
      xxmsg(creature_unit.get_cur_use_id(ntype))

      -- 召唤 页面（等过悼动画才能关）
      -- if creature_unit.has_gacha_scene() then 
      --    xxmsg("关闭")
      --    creature_unit.close_gacha_scene()
      -- end
   



end

--************************************************************
--2023-05-24
--************************************************************
-------------------------------------------------------------------------------------
-- 增加签至
-- test_sign_unit
function example.test_sign_unit()
   -- 检测签到窗
   --sign_unit.is_open_event_popup()
   -- 打开窗到窗
   --sign_unit.open_event_popup()
   -- 关闭签到窗
   --sign_unit.close_event_popup()
   
   -- 注数据读取可以不用打开。。领取最好还是打开请求一次
   xxmsg('-------------------------完成目标类----------------------------')
   -- 取有可领奖励ID列表
   local event_list = sign_unit.get_tar_event_list()
   xxmsg('有奖励数'..#event_list)
   for i = 1, #event_list do
      local id = event_list[i]
      xxmsg(string.format('Id:%16X', id))
      -- id取有奖励序号列表
      local reward_idx_list = sign_unit.get_reward_idx_list(id, i)
      xxmsg('共有奖励：'..#reward_idx_list)
      for j = 1, #reward_idx_list do
         local reward_idx = reward_idx_list[j]
         xxmsg(string.format('    id:%16X   idx:%03d', id, reward_idx))
         -- 领取
         --- sign_unit.get_event_reward(id, reward_idx)
         ---sleep(2000)
      end
   
   end
   
   xxmsg('-------------------------签到类----------------------------')
   -- 取得可签到ID列表
   local can_receive_list = sign_unit.get_can_receive_list()
   xxmsg('可签到数：'..#can_receive_list)
   for i = 1, #can_receive_list do
      local id = can_receive_list[i]
      xxmsg(string.format('id:%16X', can_receive_list[i]))
      --领取签到物品
      ---sign_unit.get_attendance_reward(id)
      ---sleep(2000)
   end

end

-------------------------------------------------------------------------------------
-- test_collection_unit
function example:test_collection_unit()
   
   local list = collection_unit.list();
   xxmsg('宝鉴数：'..#list)
   for i = 1, #list do
      local obj = list[i]
      if collection_ctx:init(obj) then
         local stt = true
         local max = 0
         local sub_num = collection_ctx:num()
         if stt then
            xxmsg(string.format('obj:%16X  id:%16X  num:%03d  finish_num:%03d  is_fihish:%-6s  name:%s',
                                obj,
                                collection_ctx:id(),
                                collection_ctx:num(),
                                collection_ctx:finish_num(),
                                collection_ctx:is_finish(),
                                collection_ctx:name()
            ))
   
         end
         -- 分支物品序号从0开始
         for j = 0, sub_num - 1 do
            if collection_ctx:sub_bag_item_id(j) >= max then
               stt = true
               xxmsg(string.format('     idx:%03d   sub_obj:%16X  status:%02d  item_nux:[%03d - %03d]  bag_item_id:%16X  item_res_id:%16X  item_type:%02d  equip_enhanced_lv:%02d  is_finish:%-6s  item_name:%s',
                                   j,
                                   collection_ctx:sub_obj(j),
                                   collection_ctx:sub_status(j),
                                   collection_ctx:sub_item_num(j),
                                   collection_ctx:sub_item_max_num(j),
                                   collection_ctx:sub_bag_item_id(j),    -- 背包物品ID 有可以收集时才有没有可收集时为0（不清楚和装备强化对不对应）
                                   collection_ctx:sub_item_res_id(j),
                                   collection_ctx:sub_item_type(j),
                                   collection_ctx:sub_item_enhanced_level(j),
                                   collection_ctx:sub_item_is_finish(j),        -- 如果这个不稳定。。观察下状态
                                   collection_ctx:sub_item_name(j)
      
               ))
               
            end
         end

      end
   end
   -- 收集（id, 序号）
   --collection_unit.collection(id, idx)
   -- 检测收集窗口
   -- collection_unit.is_open_collection_scene()
   -- 打开收集窗口
   -- collection_unit.open_collection_scene()
end

-------------------------------------------------------------------------------------
-- test_dungeon_unit
-------------------------------------------------------------------------------------
-- test_dungeon_unit
function example:test_dungeon_unit()
   
   local list = dungeon_unit.dungeon_list()
   xxmsg("主副本数："..#list)
   for i = 1, #list do
      local main_obj = list[i]
      if dungeon_ctx:init(main_obj) then
         xxmsg(string.format("main_obj:%16X    id:%16X   name:%s", main_obj, dungeon_ctx:id(), dungeon_ctx:name()))
         local stage_list = dungeon_unit.dungeon_stage_list(dungeon_ctx:id())
         xxmsg("子副本数："..#stage_list)
         for j = 1, #stage_list do
            local stage_obj = stage_list[j]
            if dungeon_ctx:init(stage_obj) then
               xxmsg(string.format("      stage_obj:%16X    id:%16X   main_dungeon:%16x    name:%s enter:%s", main_obj, dungeon_ctx:id(),dungeon_ctx:main_dungeon_id(), dungeon_ctx:name(),dungeon_ctx:can_enter()))
            end
         end
      
      end
   end
   
   -- 请求副本行为（action 1 请求数剧 = 选择， 2 请求进入副本出zone_popup）
   --dungeon_unit.req_dungeon_action(main_id, stage_id, action )
   -- 检测副本窗口
   --dungeon_unit.is_open_dungeon_widget()
   -- 打开副本窗口
   --dungeon_unit.open_dungeon_widget()
   -- 是否有传送窗口
   --dungeon_unit.has_enter_zone_popup()
   -- 进入副本
   --dungeon_unit.enter_dungeon()

end


example.test_exchange_unit = function()
  

end

-------------------------------------------------------------------------------------
-- test_map_unit
function example.test_map_unit()
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

-------------------------------------------------------------------------------------
-- test_quick_unit
example.test_quick_unit = function()
   
   -- 遍历快捷建( 1 - 8 ID 对应为0-7)
   for i = 0, 7 do 
      xxmsg(string.format('ID:%02d    set_obj_id:%16X   set_type:%02d    is_active:%-6s',
         i,
         quick_unit.get_quick_item_id(i),       -- 设置的物品为物品资源ID，设置的技能为技能group id
         quick_unit.get_quick_item_type(i),     -- 类型 0 未设  1已设置技能，2 已设置物品
         quick_unit.quick_is_active(i)          -- 设置的技能是否激活使用
      ))
   end
   -- 设置物品
   -- quick_unit.set_quick_item(slot_id, item_id)  -- 该ID不资源ID。。
   -- 设置技能
   -- quick_unit.set_quick_skill(slot_id, skill_id) -- 该ID不是group_id
   -- 激活技能
   -- quick_unit.active_quick_skill(slot_id, true) -- 激活技能
end

-------------------------------------------------------------------------------------
-- test_sign_unit
example.test_sign_unit = function()
  

end

-------------------------------------------------------------------------------------
-- test_npc_shop_unit
function example:test_npc_shop_unit()
   local list = npc_shop_unit.list()
   xxmsg("商品总数:"..#list)
   for i = 1, #list do 
      local obj = list[i]
      if npc_shop_ctx:init(obj) then 
         xxmsg(string.format('obj:%16X   res_ptr%16X   id:%16X    res_id:%16X   type:%02d   price:%10d   can_buy:%-6s   name:%s',
            obj,
            npc_shop_ctx:res_ptr(),
            npc_shop_ctx:id(),
            npc_shop_ctx:res_id(),
            npc_shop_ctx:type(),
            npc_shop_ctx:price(),
            npc_shop_ctx:can_buy(),
            npc_shop_ctx:name()
       ))
      end
   end
  -- 购买商品
  -- npc_shop_unit.buy_item(npc_id, item_id, num)

end

-------------------------------------------------------------------------------------
-- test_cash_unit
example.test_cash_unit = function()
   local list = cash_unit.list()
   xxmsg("商品总数:"..#list)
   for i = 1, #list do
      local obj = list[i]
      if cash_ctx:init(obj) then
         xxmsg(string.format('obj:%16X   res_ptr:%16X    id:%16X   money_type:%02d    price:%08d    buy_num:[%04d - %04d]   name:%s',
                             obj,
                             cash_ctx:res_ptr(),
                             cash_ctx:id(),
                             cash_ctx:money_type(),
                             cash_ctx:price(),
                             cash_ctx:cur_buy_num(),
                             cash_ctx:max_buy_num(),
                             cash_ctx:name()
         ))
      
      end
   end
   
   -- 购买物品
   --cash_unit.buy(id, num )
end
-------------------------------------------------------------------------------------
-- test_all
function example:test_all()
	
end




-------------------------------------------------------------------------------------
-- 实例化新对象

function example.__tostring()
    return "mir4 example package"
 end

example.__index = example

function example:new(args)
   local new = { }

   if args then
      for key, val in pairs(args) do
         new[key] = val
      end
   end

   -- 设置元表
   return setmetatable(new, example)
end

-------------------------------------------------------------------------------------
-- 返回对象
return example:new()

-------------------------------------------------------------------------------------