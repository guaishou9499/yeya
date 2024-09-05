------------------------------------------------------------------------------------
-- game/resources/quest_res.lua
--
--
--
-- @module      quest_res
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-03-22
-- @copyright   2023
-- @usage
-- local quest_res = import('game/resources/quest_res')
local actor_unit = actor_unit
local decider    = decider
local ui_ent     = import('game/entities/ui_ent')
------------------------------------------------------------------------------------
-- 任务资源
local quest_res = {
    SPECIAL_TASK = {
        --任务名:전직하기 id:2580273 step_id:2932980 type:0.0 cur_tar_num:0.0 max_tar_num:0.0
        --选择职业
        ['전직하기'] = function()
            if not actor_unit.open_class_widget() then
                actor_unit.open_class_widget()
                decider.sleep(3000)
            end
            if actor_unit.open_class_widget() then
                decider.sleep(3000)
                ui_ent.set_job('阿彻')
            end
        end,
    },
    SIDE_TASk = {
        --第二大陆
        ['바위절벽 길목 토벌'] = { level = 30, task_name = '바위절벽 길목 토벌', map_name = '바위절벽 길목', map_id = 202.0,X = -53673,Y = -46017,Z = 718 },
        ['콜리아 기슭 토벌'] = { level = 30, task_name = '콜리아 기슭 토벌', map_name = '콜리아 기슭', map_id = 203.0,X = -23906,Y = -36146,Z = -1002 },
        ['쇠락한 공터 토벌'] = { level = 31, task_name = '쇠락한 공터 토벌', map_name = '쇠락한 공터', map_id = 203.0,X = -23906,Y = -36146,Z = -1002 },
        ['키큰숲 목초지 토벌'] = { level = 31, task_name = '키큰숲 목초지 토벌', map_name = '키큰숲 목초지', map_id = 205.0,X = 28099,Y = -54736,Z = 2933 },
        ['콜리아 삼거리 토벌'] = { level = 32, task_name = '콜리아 삼거리 토벌', map_name = '콜리아 삼거리', map_id = 206.0,X = 12830,Y = -17420,Z = 1761 },
        ['마른땅 벌목지 토벌'] = { level = 32, task_name = '마른땅 벌목지 토벌',  map_name = '마른땅 벌목지', map_id = 207.0,X = -27910,Y = -14145,Z = 1120},
        ['실바인 진흙탕 토벌'] = { level = 34, task_name = '실바인 진흙탕 토벌', map_name = '실바인 진흙탕', map_id = 208.0,X = 17007,Y = -5695,Z = 2182 },
        ['실바인 저수지 토벌'] = { level = 34, task_name = '실바인 저수지 토벌', map_name = '실바인 저수지', map_id = 209.0,X = -8338,Y = 33527,Z = -45 },
        ['뙤약볕 벌목지 토벌'] = { level = 45, task_name = '뙤약볕 벌목지 토벌', map_name = '뙤약볕 벌목지', map_id = 210.0,X = -36781,Y = 12820,Z = 4726 },
        ['젖은발 숲길 토벌'] = { level = 45, task_name = '젖은발 숲길 토벌',  map_name = '젖은발 숲길', map_id = 211.0,X = -48395,Y = 40057,Z = 277},
        -- 第三大陆
        ['경외의 바윗길 토벌'] = { level = 36, task_name = '경외의 바윗길 토벌',  map_name = '경외의 바윗길', map_id = 302.0,X = 144829,Y = 73113,Z = 13070},
        ['청빈의 경사로 토벌'] = { level = 36, task_name = '청빈의 경사로 토벌',  map_name = '청빈의 경사로', map_id = 303.0,X = 93658,Y = 58423,Z = 13324},
        ['알레인 고지대 토벌'] = { level = 39, task_name = '알레인 고지대 토벌',  map_name = '알레인 고지대', map_id = 304.0,X = 68644,Y = 60435,Z = 7745},
        ['회색이끼 군락 토벌'] = { level = 39, task_name = '회색이끼 군락 토벌',  map_name = '회색이끼 군락', map_id = 305.0,X = 45407,Y = 95093,Z = 4719},
        ['순례자 협곡 토벌'] = { level = 41, task_name = '순례자 협곡 토벌',   map_name = '순례자 협곡', map_id = 306.0,X = 121075,Y = 154772,Z = 4753},
        ['성긴뿌리 언덕 토벌'] = { level = 41, task_name = '성긴뿌리 언덕 토벌',  map_name = '성긴뿌리 언덕', map_id = 307.0,X = 155561,Y = 153858,Z = 4573},
        ['쓸쓸한 무덤가 토벌'] = { level = 43, task_name = '쓸쓸한 무덤가 토벌', map_name = '쓸쓸한 무덤가', map_id = 308.0,X = 147220,Y = 25629,Z = 7932 },
        ['앙상가지 벌판 토벌'] = { level = 43, task_name = '앙상가지 벌판 토벌', map_name = '앙상가지 벌판', map_id = 309.0,X = 111669,Y = 26180,Z = 8179 },
        -- 副本修炼森林
        ['수련의 숲 1구역 토벌 I'] = { level = 30, task_name = '수련의 숲 1구역 토벌 I', map_name = '수련의 숲 1구역', map_id = 10020101.0,X = 43470,Y = -44281,Z = 466 },
        ['수련의 숲 1구역 토벌 II'] = { level = 30, task_name = '수련의 숲 1구역 토벌 II' ,map_name = '수련의 숲 1구역', map_id = 10020101.0,X = 43470,Y = -44281,Z = 466},
        ['수련의 숲 1구역 토벌 III'] = { level = 30, task_name = '수련의 숲 1구역 토벌 III' ,map_name = '수련의 숲 1구역', map_id = 10020101.0,X = 43470,Y = -44281,Z = 466},
        ['수련의 숲 2구역 토벌 I'] = { level = 35, task_name = '수련의 숲 2구역 토벌 I' ,map_name = '수련의 숲 2구역', map_id = 10020201.0,X = 11205,Y = -41310,Z = 756},
        ['수련의 숲 2구역 토벌 II'] = { level = 35, task_name = '수련의 숲 2구역 토벌 II' ,map_name = '수련의 숲 2구역', map_id = 10020201.0,X = 11205,Y = -41310,Z = 756},
        ['수련의 숲 2구역 토벌 III'] = { level = 35, task_name = '수련의 숲 2구역 토벌 III' ,map_name = '수련의 숲 2구역', map_id = 10020201.0,X = 11205,Y = -41310,Z = 756},
        ['수련의 숲 3구역 토벌 I'] = { level = 40, task_name = '수련의 숲 3구역 토벌 I',map_name = '수련의 숲 3구역', map_id = 10020301.0,X = -46440,Y = 3915,Z = 2858 },
        ['수련의 숲 3구역 토벌 II'] = { level = 40, task_name = '수련의 숲 3구역 토벌 II',map_name = '수련의 숲 3구역', map_id = 10020301.0,X = -46440,Y = 3915,Z = 2858 },
        ['수련의 숲 3구역 토벌 III'] = { level = 40, task_name = '수련의 숲 3구역 토벌 III' ,map_name = '수련의 숲 3구역', map_id = 10020301.0,X = -46440,Y = 3915,Z = 2858},
        ['수련의 숲 4구역 토벌 I'] = { level = 45, task_name = '수련의 숲 4구역 토벌 I', map_name = '수련의 숲 4구역', map_id = 10020401.0,X = 36855,Y = -17956,Z = 168 },
        ['수련의 숲 4구역 토벌 II'] = { level = 45, task_name = '수련의 숲 4구역 토벌 II',map_name = '수련의 숲 4구역', map_id = 10020401.0,X = 36855,Y = -17956,Z = 168 },
        ['수련의 숲 4구역 토벌 III'] = { level = 45, task_name = '수련의 숲 4구역 토벌 III',map_name = '수련의 숲 4구역', map_id = 10020401.0,X = 36855,Y = -17956,Z = 168 },
        ['수련의 숲 5구역 토벌 I'] = { level = 50, task_name = '수련의 숲 5구역 토벌 I',map_name = '수련의 숲 5구역', map_id = 10020501.0,X = 31860,Y = -60210,Z = 4145 },
        ['수련의 숲 5구역 토벌 II'] = { level = 50, task_name = '수련의 숲 5구역 토벌 II',map_name = '수련의 숲 5구역', map_id = 10020501.0,X = 31860,Y = -60210,Z = 4145 },
        ['수련의 숲 5구역 토벌 III'] = { level = 50, task_name = '수련의 숲 5구역 토벌 III',map_name = '수련의 숲 5구역', map_id = 10020501.0,X = 31860,Y = -60210,Z = 4145 },
        ['수련의 숲 6구역 토벌 I'] = { level = 55, task_name = '수련의 숲 6구역 토벌 I',map_name = '수련의 숲 6구역', map_id = 10020601.0,X = -48600,Y = -18360,Z = 2480 },
        ['수련의 숲 6구역 토벌 II'] = { level = 55, task_name = '수련의 숲 6구역 토벌 II',map_name = '수련의 숲 6구역', map_id = 10020601.0,X = -48600,Y = -18360,Z = 2480 },
        ['수련의 숲 6구역 토벌 III'] = { level = 55, task_name = '수련의 숲 6구역 토벌 III',map_name = '수련의 숲 6구역', map_id = 10020601.0,X = -48600,Y = -18360,Z = 2480 },
    },
}

-- 自身模块
local this = quest_res

-------------------------------------------------------------------------------------
-- [读取] 获取指定任务 资源记录
quest_res.get_daily_info_in_res_by_task_name = function(task_name)

end

-------------------------------------------------------------------------------------
-- 返回实例对象
-- 
-- @export
return quest_res

-------------------------------------------------------------------------------------