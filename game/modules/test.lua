-------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @author:   admin
-- @email:    88888@qq.com
-- @date:     2022-06-30
-- @module:   test
-- @describe: 测试模块
-- @version:  v1.0
--

-------------------------------------------------------------------------------------
---@class test
local test = {
    VERSION = '20211016.28',
    AUTHOR_NOTE = "-[test module - 20211016.28]-",
    MODULE_NAME = '测试模块',
}

-- 自身模块
local this      = test
-- 配置模块
local settings  = settings
-- 日志模块
local trace     = trace
-- 决策模块
local decider   = decider
local common    = common
local dungeon_res = import('game/resources/dungeon_res')
local login_res   = import('game/resources/login_res')
---@type equip_ent
local equip_ent = import('game/entities/equip_ent')
local actor_ent =  import('game/entities/actor_ent')
local helper    = import('base/helper')
---@type ui_ent
local ui_ent    = import('game/entities/ui_ent')
local item_res  = import('game/resources/item_res')
-- 任务单元
---@type quest_ent
local quest_ent    = import('game/entities/quest_ent')
---@type creature_ent
local creature_ent = import('game/entities/creature_ent')
---@type item_ent
local item_ent     = import('game/entities/item_ent')
---@type quick_ent
local quick_ent    = import('game/entities/quick_ent')
---@type shop_ent
local shop_ent     = import('game/entities/shop_ent')

---@type mail_ent
local mail_ent     = import('game/entities/mail_ent')
---@type map_ent
local map_ent      = import('game/entities/map_ent')
---@type sign_ent
local sign_ent     = import('game/entities/sign_ent')
---@type collection_ent
local collection_ent = import('game/entities/collection_ent')
---@type mastery_ent
local mastery_ent  = import('game/entities/mastery_ent')
-------------------------------------------------------------------------------------
---@type fight_mon_ent
local fight_mon_ent = import('game/entities/fight_mon_ent')

-- 运行前置条件
this.eval_ifs = {
    -- [启用] 游戏状态列表
    yes_game_state = {login_res.STATUS_IN_GAME | login_res.STATUS_LOADING_MAP},
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
        return true
    end,
    -- [其它] 功能函数条件(可选)
    is_execute     = function()
        return true
    end,
}

-- 轮循函数列表
test.poll_functions = {}

------------------------------------------------------------------------------------
-- 预载函数(重载脚本时)
test.super_preload = function()
    settings.log_level        = 0
    settings.log_type_channel = 3
end

-------------------------------------------------------------------------------------
-- 功能入口函数
test.entry = function()
    local mail_list = {
        ['角色'] = 0,
        ['服务'] = 1,
        ['系统'] = function()  end,
    }
    --while not is_exit() do
    --
    --	xxmsg(string.format('%X',game_unit.get_game_status_ex()))
    --	sleep(1000)
    --end
    -- item_ent.auto_use_item()
    -- actor_ent.execute_change_line(2)
    --fight_mon_ent.go_to_pos_kill_mon(0,'野外挂机')
    --mastery_ent.wa_execute_mastery()
    --local info = quest_ent.get_can_accept_daily_quest_in_this_map()
    --quest_ent.execute_daily_task_ex()
    --
    ---- actor_ent.execute_change_line(2)
    --ui_ent.close_connect_win()
    --ui_ent.close_window_list()
    --item_ent.auto_use_item()
    --sign_ent.execute_sign()
    --collection_ent.execute_collection()
    --ui_ent.close_use_fb_stuff_win()
    --local body_equip_info = item_ent.get_item_info(1)
    --for i = 1, #body_equip_info do
    --    local equip_info = body_equip_info[i]
    --    -- xxmsg(equip_ent.is_need_repair(equip_info))
    --    equip_ent.wa_execute_repair_equip(equip_info)
    --end
    while not is_exit() do
        xxmsg('开始')
        shop_ent.buy_item('主动技能书-集中攻击II')
        xxmsg('结束')
        sleep(2000)
    end
    -- map_ent.execute_transfer_map(107)
    ---- 对话关闭
    --common.execute_pass_dialog()
    ---- 关闭UI
    --ui_ent.close_window_list()
    ---- 买药.技能书
    --shop_ent.auto_buy_item()
    ---- 商城购买
    --cash_ent.buy_item()
    ----邮件检测
    --mail_ent.auto_get_mail_ex()
    ---- 快捷栏
    --quick_ent.auto_set_quick_ex()
    ---- 检测坐骑 滑翔机 武器图
    --creature_ent.auto_used_creature()
    ---- 检测物品使用
    --item_ent.auto_use_item()
    ---- 装备佩戴
    --equip_ent.ues_equip()
    ---- 装备强化
    --equip_ent.enhancement_equip()
    ---- 添加信念点
    --actor_ent.set_stat()
   -- -- 打开邮件
   -- if not mail_unit.mail_scene_is_open() then
   --     mail_unit.open_mail_scene()
   --     -- 等待邮件打开
   --     sleep(3000)
   -- end
   -- -- 领取邮件
   -- xxmsg(mail_unit.mail_scene_is_open())
   -- if mail_unit.mail_scene_is_open() then
   --     -- 系统邮件
   --      local mail_num  = mail_unit.get_sys_mail_num()  -- 取数量
   --     for i = 0, mail_num-1 do
   --         local mail_id = mail_unit.get_sys_mail_id_byidx(i)  -- 取系统邮件ID
   --         if mail_id ~= 0 then
   --             mail_unit.get_sys_mail(mail_id)   -- 这里每次领后 要重新读取 领后里面列表就刷新了
   --             sleep(3000)
   --         end
   --     end
   --     xxmsg(mail_unit.has_server_mail(0))
   --     if mail_unit.has_server_mail(0) then
   --         mail_unit.get_all_server_maill(0)
   --         sleep(3000)
   --     end
   --     xxmsg(mail_unit.has_server_mail(1))
   --     mail_unit.get_all_server_maill(1)
   --     if mail_unit.has_server_mail(1) then
   --         mail_unit.get_all_server_maill(1)
   --         sleep(3000)
   --     end
   --     -- 服务邮件和角色邮件
   --     --mail_unit.has_server_mail(1 服务 0 角色)
   --     -- 一建领 取服务邮件
   --     -- mail_unit.get_all_server_maill(1 服务 0 角色)
   -- end
   -- -- 退出邮件窗口
   ---- ui_unit.exit_widget()
end

-------------------------------------------------------------------------------------
-- 模块超时处理
test.on_timeout = function()
    -- 非排队状态时超时-重启
    if not login_unit.is_waiting_game() then
        xxmsg('。。。。。登陆模块处理超时。。。。。')
        main_ctx:end_game()
    end
end

-------------------------------------------------------------------------------------
-- 定时调用入口
test.on_timer = function(timer_id)
    --xxmsg('login.on_timer -> '..timer_id)
end

-------------------------------------------------------------------------------------
-- 卸载处理
test.unload = function()
    --xxmsg('login.unload')
end

-------------------------------------------------------------------------------------
-- 实例化新对象

function test.__tostring()
    return this.MODULE_NAME
end

test.__index = test

function test:new(args)
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
    return setmetatable(new, test)
end

-------------------------------------------------------------------------------------
-- 返回对象
return test:new()

-------------------------------------------------------------------------------------