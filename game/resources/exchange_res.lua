------------------------------------------------------------------------------------
-- game/resources/exchange_res.lua
--
--
--
-- @module      exchange_res
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-03-22
-- @copyright   2023
-- @usage
-- local exchange_res = import('game/resources/exchange_res')
------------------------------------------------------------------------------------

local exchange_res = {
    SELL_ITEM = {
        ['토끼 고기'] = { num = 1 ,c_name = '兔子肉', h_name = '토끼 고기', is_equip = false },
    },
}

-- 自身模块
local this = exchange_res

-------------------------------------------------------------------------------------
-- 返回实例对象
-- 
-- @export
return exchange_res

-------------------------------------------------------------------------------------