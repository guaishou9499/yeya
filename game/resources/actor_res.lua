------------------------------------------------------------------------------------
-- game/resources/actor_res.lua
--
--
--
-- @module      actor_res
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-03-22
-- @copyright   2023
-- @usage
-- local actor_res = import('game/resources/actor_res')
local pairs      = pairs
local table      = table
local math       = math
local actor_unit = actor_unit
------------------------------------------------------------------------------------
-- 环境对象资源
local actor_res = {
    -- 信念对应位置[游戏不改动,无需修改]
    STAT_POS = {
        ['力量'] = 0,
        ['敏捷'] = 1,
        ['智慧'] = 2,
        ['体质'] = 3,
        ['精神'] = 4,
        ['忍耐'] = 5,
    },
    -- 职业对应信念设置
    STAT_SET = {
        [1] = { },-- 大剑
        [2] = { },-- 法杖
        [3] = { },-- 剑盾
        [4] = { },-- 双剑
        [5] = { ['敏捷'] = { pro = 1,max_lv = 99 } },-- 猎人
        [6] = { ['敏捷'] = { pro = 1,max_lv = 99 } },-- 匕首
        [7] = { },-- 魔杖
        [8] = { },-- 魔法棒
    },
}

-- 自身模块
local this = actor_res

-------------------------------------------------------------------------------------
-- 获取可加信念属性信息
-------------------------------------------------------------------------------------
actor_res.get_set_stat_info = function()
    -- 可设信念总数
    local stat_point = actor_unit.get_stat_point()
    -- 后续直接调用读取职业替换[默认职业]
    local job        = 5
    local stat_set   = this.STAT_SET[job]
    -- 保存可设信念数据
    local can_stat   = {}
    -- 标记需要的点数
    local need_set   = 0
    if stat_set then
        for k,v in pairs(stat_set) do
            need_set = need_set + 1
            if not table.is_empty(v) then
                -- 全部加成
                local id = this.STAT_POS[k] or -1
                if id >= 0 and actor_unit.get_stat_primary_level(id) < v.max_lv then
                    if v.pro == 1  then
                        table.insert(can_stat,{ id = id,point = stat_point or 0,name = k })
                    else
                        local now_point = math.floor(v * stat_point)
                        if now_point >= 1 then
                            table.insert(can_stat,{ id = id,point = now_point,name = k })
                            stat_point = stat_point - now_point
                        end
                    end
                end
            end
        end
    end
    return can_stat
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-- 
-- @export
return actor_res

-------------------------------------------------------------------------------------