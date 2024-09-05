------------------------------------------------------------------------------------
-- game/entities/user_set_ent.lua
--
-- 用户设置单元
--
-- @module      user_set_ent
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-05-09
-- @copyright   2023
-- @usage
-- local user_set_ent = import('game/entities/user_set_ent')
------------------------------------------------------------------------------------
-- 日志模块
local trace        = user_set_ent
-- 决策模块
local decider      = user_set_ent
local main_ctx     = main_ctx
local ini_ctx      = ini_ctx
local import       = import
local tonumber     = tonumber
local rawset       = rawset
local type         = type
local pairs        = pairs
local string       = string
local setmetatable = setmetatable
-- 模块定义
---@class user_set_ent
local user_set_ent = {
    -- 模块版本 (主版本.次版本.修订版本)
    VERSION        = '1.0.0',
    -- 作者备注 (更新日期 - 更新内容简述)
    AUTHOR_NOTE    = '2023-05-09 - Initial release',
    -- 模块名称
    MODULE_NAME    = 'user_set_ent module',
    -- 只读模式
    READ_ONLY      = false,
    -- 用户设置路径
    REDIS_PATH     = '夜鸦:机器[%s]:'.. main_ctx:c_server_name() .. '设置',
    -- 连接服务器
    CONNECT_OBJ    = nil,
}

-- 实例对象
local this         = user_set_ent
---@type redis_ent
local redis_ent    = import('game/entities/redis_ent')
local user_set_res = import('game/resources/user_set_res')
------------------------------------------------------------------------------------
-- [事件] 预载函数(重载脚本)
------------------------------------------------------------------------------------
function user_set_ent.super_preload()

end

--------------------------------------------------------------------------------
-- 载入用户设置信息到全局
--
-- @usage
-- redis_ent.load_user_info()
--------------------------------------------------------------------------------
user_set_ent.load_user_info = function()
    redis_ent.connect_redis()
    --    GLOBAL_SET = {
    --        { session = '登录设置', key = '登录排队', value = 5 },
    --        { session = '登录设置', key = '建角下线', value = 0 },
    --        { session = '主线设置', key = '开启主线', value = 1 },
    --        { session = '主线设置', key = '终止等级', value = 35 },
    --        { session = '日常设置', key = '开启日常', value = 0 },
    --        { session = '挂机设置', key = '野外挂机', value = 1 },
    --        { session = '挂机设置', key = '最低等级', value = 35 },
    --        { session = '副本设置', key = '繁荣的土', value = 0 },
    --        { session = '副本设置', key = '修炼之林', value = 0 },
    --        { session = '副本设置', key = '伊莱殿神殿', value = 0 },
    --        { session = '副本设置', key = '圣科拿遗迹', value = 0 },
    --        { session = '副本设置', key = '马萨塔冰窟', value = 0 },
    --        { session = '交易行设置', key = '开启交易转金', value = 0 },
    --        { session = '交易行设置', key = '收金号', value = '角色名' },
    --        { session = '交易行设置', key = '转金保留金币', value = 10 },
    --    }

    local global_set = user_set_res.GLOBAL_SET
    local path = string.format(this.REDIS_PATH,redis_ent.computer_id)
    for _, v in pairs(global_set) do
        local value = redis_ent.get_string_redis_ini(path, v.session, v.key,this.CONNECT_OBJ)
        if value == '' then
            redis_ent.set_string_redis_ini(path, v.session, v.key, v.value ,this.CONNECT_OBJ)
            value = v.value
        end
        if type(v.value) == "number" then
            value = tonumber(value)
        end
        this[v.key] = value
    end
    ini_ctx:parse(main_ctx:redis_get_string(path))
end

------------------------------------------------------------------------------------
-- [内部] 将对象转换为字符串
--
-- @local
-- @treturn      string                     模块名称
------------------------------------------------------------------------------------
function user_set_ent.__tostring()
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
function user_set_ent.__newindex(t, k, v)
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
user_set_ent.__index = user_set_ent

------------------------------------------------------------------------------------
-- [构造] 创建一个新的实例
--
-- @local 
-- @tparam       table     args             可选参数，用于初始化新实例
-- @treturn      table                      新创建的实例
------------------------------------------------------------------------------------
function user_set_ent:new(args)
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
    return setmetatable(new, user_set_ent)
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-------------------------------------------------------------------------------------
return user_set_ent:new()

-------------------------------------------------------------------------------------
