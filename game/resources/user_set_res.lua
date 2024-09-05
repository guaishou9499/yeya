------------------------------------------------------------------------------------
-- game/resources/user_set_res.lua
--
--
--
-- @module      user_set_res
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-03-22
-- @copyright   2023
-- @usage
-- local user_set_res = import('game/resources/user_set_res')
------------------------------------------------------------------------------------
-- 用户设置资源
local user_set_res = {
    GLOBAL_SET = {
        { session = '登录设置', key = '登录排队', value = 5 },
        { session = '登录设置', key = '建角下线', value = 0 },
        { session = '主线设置', key = '开启主线', value = 1 },
        { session = '主线设置', key = '终止等级', value = 35 },
        { session = '日常设置', key = '开启日常', value = 0 },
        { session = '挂机设置', key = '野外挂机', value = 1 },
        { session = '挂机设置', key = '最低等级', value = 35 },
        { session = '副本设置', key = '繁荣的土', value = 0 },
        { session = '副本设置', key = '修炼之林', value = 0 },
        { session = '副本设置', key = '伊莱殿神殿', value = 0 },
        { session = '副本设置', key = '圣科拿遗迹', value = 0 },
        { session = '副本设置', key = '马萨塔冰窟', value = 0 },
        { session = '交易行设置', key = '开启交易转金', value = 0 },
        { session = '交易行设置', key = '收金号', value = '角色名' },
        { session = '交易行设置', key = '转金保留金币', value = 10 },
    }
}

-- 自身模块
local this = user_set_res

-------------------------------------------------------------------------------------
-- 返回实例对象
-- 
-- @export
return user_set_res

-------------------------------------------------------------------------------------