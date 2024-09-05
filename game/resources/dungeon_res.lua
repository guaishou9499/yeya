------------------------------------------------------------------------------------
-- game/resources/dungeon_res.lua
--
--
--
-- @module      副本资源
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-03-22
-- @copyright   2023
-- @usage
-- local dungeon_res = import('game/resources/dungeon_res')
------------------------------------------------------------------------------------

local dungeon_res = {
    -- 选择副本层
    DUNGEON_SEL  = 1,
    -- 进入副本
    DUNGEON_ENT  = 2,
    -- 副本顺序
    DUNGEON_IDX  = {
        [1] = '繁荣的土',
        [2] = '修炼之林',
        [3] = '伊莱殿神殿',
        [4] = '圣科拿遗迹',
        [5] = '马萨塔冰窟',

    },
    -- 副本资源信息
    DUNGEON_INFO = {
        ['繁荣的土'] = {
            [1] = { need_gold = 3000 ,need_level = 30,map_id = 10010101,dungeon_name = '번영의 땅',area_name = '1구역',dun_key = '繁荣的土1层' },
            [2] = { need_gold = 4000 ,need_level = 35,map_id = 10010201,dungeon_name = '번영의 땅',area_name = '2구역',dun_key = '繁荣的土2层' },
            [3] = { need_gold = 5000 ,need_level = 40,map_id = 10010301,dungeon_name = '번영의 땅',area_name = '3구역',dun_key = '繁荣的土3层' },
            [4] = { need_gold = 7000 ,need_level = 45,map_id = 10010401,dungeon_name = '번영의 땅',area_name = '4구역',dun_key = '繁荣的土4层' },
            [5] = { need_gold = 9000 ,need_level = 50,map_id = 10010501,dungeon_name = '번영의 땅',area_name = '5구역',dun_key = '繁荣的土5层' },
            [6] = { need_gold = 12000,need_level = 55,map_id = 10010601,dungeon_name = '번영의 땅',area_name = '6구역',dun_key = '繁荣的土6层' },
        },
        ['修炼之林'] = {
            [1] = { need_gold = 3000 ,need_level = 30,map_id = 10020101,dungeon_name = '수련의 숲',area_name = '1구역',dun_key = '修炼之林1层' },
            [2] = { need_gold = 4000 ,need_level = 35,map_id = 10020201,dungeon_name = '수련의 숲',area_name = '2구역',dun_key = '修炼之林2层' },
            [3] = { need_gold = 5000 ,need_level = 40,map_id = 10020301,dungeon_name = '수련의 숲',area_name = '3구역',dun_key = '修炼之林3层' },
            [4] = { need_gold = 7000 ,need_level = 45,map_id = 10020401,dungeon_name = '수련의 숲',area_name = '4구역',dun_key = '修炼之林4层' },
            [5] = { need_gold = 9000 ,need_level = 50,map_id = 10020501,dungeon_name = '수련의 숲',area_name = '5구역',dun_key = '修炼之林5层' },
            [6] = { need_gold = 12000,need_level = 55,map_id = 10020601,dungeon_name = '수련의 숲',area_name = '6구역',dun_key = '修炼之林6层' },
        },
        ['伊莱殿神殿'] = {
            [1] = { need_gold = 9000  ,need_level = 30,map_id = 2002101,dungeon_name = '이를레타 신전',area_name = '1전당',dun_key = '伊莱殿神殿1层' },
            [2] = { need_gold = 13000 ,need_level = 35,map_id = 2002201,dungeon_name = '이를레타 신전',area_name = '2전당',dun_key = '伊莱殿神殿2层' },
            [3] = { need_gold = 16000 ,need_level = 40,map_id = 2002301,dungeon_name = '이를레타 신전',area_name = '3전당',dun_key = '伊莱殿神殿3层' },
            [4] = { need_gold = 20000 ,need_level = 45,map_id = 2002401,dungeon_name = '이를레타 신전',area_name = '4전당',dun_key = '伊莱殿神殿4层' },
            [5] = { need_gold = 26000 ,need_level = 50,map_id = 2002501,dungeon_name = '이를레타 신전',area_name = '5전당',dun_key = '伊莱殿神殿5层' },
        },
        ['圣科拿遗迹'] = {
            [1] = { need_gold = 18000 ,need_level = 35,map_id = 3002101,dungeon_name = '산코나 유적',area_name = '1발굴터',dun_key = '圣科拿遗迹1层' },
            [2] = { need_gold = 22000 ,need_level = 40,map_id = 3002201,dungeon_name = '산코나 유적',area_name = '2발굴터',dun_key = '圣科拿遗迹2层' },
            [3] = { need_gold = 27000 ,need_level = 45,map_id = 3002301,dungeon_name = '산코나 유적',area_name = '3발굴터',dun_key = '圣科拿遗迹3层' },
            [4] = { need_gold = 35000 ,need_level = 50,map_id = 3002401,dungeon_name = '산코나 유적',area_name = '4발굴터',dun_key = '圣科拿遗迹4层' },
            [5] = { need_gold = 50000 ,need_level = 55,map_id = 3002501,dungeon_name = '산코나 유적',area_name = '5발굴터',dun_key = '圣科拿遗迹5层' },
            [6] = { need_gold = 60000 ,need_level = 60,map_id = 3002601,dungeon_name = '산코나 유적',area_name = '6발굴터',dun_key = '圣科拿遗迹6层' },
        },
        ['马萨塔冰窟'] = {
            [1] = { need_gold = 18000 ,need_level = 30,map_id = 50000101,main_map_id = 500001,dungeon_name = '마사르타 얼음 동굴',area_name = '1공동',dun_key = '马萨塔冰窟1层' },
            [2] = { need_gold = 26000 ,need_level = 35,map_id = 50000201,main_map_id = 500002,dungeon_name = '마사르타 얼음 동굴',area_name = '2공동',dun_key = '马萨塔冰窟2层' },
            [3] = { need_gold = 32000 ,need_level = 40,map_id = 50000301,main_map_id = 500003,dungeon_name = '마사르타 얼음 동굴',area_name = '3공동',dun_key = '马萨塔冰窟3层' },
            [4] = { need_gold = 41000 ,need_level = 45,map_id = 50000401,main_map_id = 500004,dungeon_name = '마사르타 얼음 동굴',area_name = '4공동',dun_key = '马萨塔冰窟4层' },
            [5] = { need_gold = 0     ,need_level = 50,map_id = 50000501,main_map_id = 500005,dungeon_name = '마사르타 얼음 동굴',area_name = '5공동',dun_key = '马萨塔冰窟5层' },
            [6] = { need_gold = 0     ,need_level = 55,map_id = 50000601,main_map_id = 500006,dungeon_name = '마사르타 얼음 동굴',area_name = '6공동',dun_key = '马萨塔冰窟6层' },
            [7] = { need_gold = 0     ,need_level = 60,map_id = 50000701,main_map_id = 500007,dungeon_name = '마사르타 얼음 동굴',area_name = '7공동',dun_key = '马萨塔冰窟7层' },
        },
    }
}

-- 自身模块
local this = dungeon_res


-------------------------------------------------------------------------------------
-- 返回实例对象
-- 
-- @export
return dungeon_res

-------------------------------------------------------------------------------------