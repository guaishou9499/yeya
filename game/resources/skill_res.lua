-------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @author:   admin
-- @email:    88888@qq.com
-- @date:     2022-06-30
-- @module:   skill_res
-- @describe: 物品资源
-- @version:  v1.0
--
local pairs = pairs
local string = string
-------------------------------------------------------------------------------------
-- 物品资源
---@class skill_res
local skill_res = {
    -- 技能类型
    SKILL_TYPE = {
        [0] = '主动技能',
        [1] = '被动技能',
        [2] = '滑翔机技能',
    },
    SKILL_INFO = {
        ['일반 공격']   = { c_name = '普通攻击', skill_type = 0, need_book = {}, },
        ['집중 공격']   = { c_name = '集中攻击', skill_type = 0, need_book = { [1] = '기술서 - 집중 공격 I(귀속)', [2] = '기술서 부록 - 집중 공격 II(귀속)', }, },
        ['속결']       = { c_name = '速决', skill_type = 0, need_book = { [1] = '기술서 - 속결 I(귀속)', [2] = '기술서 부록 - 속결 II(귀속)', }, },
        ['궤도 폭격']   = { c_name = '轨道轰炸', skill_type = 0, need_book = { [1] = '기술서 - 궤도 폭격 I(귀속)', [2] = '기술서 부록 - 궤도 폭격 II(귀속)', [3] = '기술서 부록 - 궤도 폭격 III(귀속)' }, },
        ['교란 화살']   = { c_name = '干扰箭', skill_type = 0, need_book = {}, },
        ['폭풍의 시']   = { c_name = '风暴的诗', skill_type = 0, need_book = {[1] = '기술서 - 폭풍의 시 I(귀속)'}, },
        ['침식']       = { c_name = '侵蚀', skill_type = 0, need_book = {}, },
        ['선고']       = { c_name = '宣告', skill_type = 0, need_book = {}, },
        ['마음 가짐']   = { c_name = '情态', skill_type = 0, need_book = { [1] = '기술서 - 마음 가짐 I(귀속)', [2] = '기술서 부록 - 마음 가짐 II(귀속)', }, },
        ['정밀 사격']   = { c_name = '精准射击', skill_type = 0, need_book = { [1] = '기술서 - 정밀 사격 I(귀속)', [2] = '기술서 부록 - 정밀 사격 II(귀속)', }, },
        ['사냥 개시']   = { c_name = '狩猎开始', skill_type = 0, need_book = { [1] = '기술서 - 사냥 개시 I(귀속)', [2] = '기술서 부록 - 사냥 개시 II(귀속)', }, },
        ['집중 포화']   = { c_name = '集中炮火', skill_type = 0, need_book = {}, },
        ['맹공']       = { c_name = '猛攻', skill_type = 0, need_book = {}, },
        ['서풍의 나루'] = { c_name = '西风的渡口', skill_type = 0, need_book = {}, },
        ['신체 강화']   = { c_name = '身体强化', skill_type = 1, need_book = {[1] = '기술서 - 신체 강화 I(귀속)'}, },
        ['정밀']       = { c_name = '精密', skill_type = 1, need_book = {[1] = '기술서 - 정밀 I(귀속)'}, },
        ['표적 노리기'] = { c_name = '瞄准目标', skill_type = 1, need_book = { [1] = '기술서 - 표적 노리기 I(귀속)', [2] = '기술서 부록 - 표적 노리기 II(귀속)', [3] = '기술서 부록 - 표적 노리기 III(귀속)' }, },
        ['위기 감지']   = { c_name = '危机感知', skill_type = 1, need_book = { [1] = '기술서 - 위기 감지 I(귀속)', [2] = '기술서 부록 - 위기 감지 II(귀속)', [3] = '기술서 부록 - 위기 감지 III(귀속)' }, },
        ['신궁의 가호'] = { c_name = '神宫的保佑', skill_type = 1, need_book = {[1] = '기술서 - 신궁의 가호 I(귀속)', [2] = '기술서 부록 - 신궁의 가호 II(귀속)'}, },
        ['바람의 부름'] = { c_name = '风的召唤', skill_type = 1, need_book = { [1] = '기술서 - 바람의 부름 I(귀속)', [2] = '기술서 부록 - 바람의 부름 II(귀속)', }, },
        ['치명적 한방'] = { c_name = '致命一击', skill_type = 1, need_book = { [1] = '기술서 - 치명적 한방 I(귀속)',},},
        ['냉정']       = { c_name = '冷静', skill_type = 1, need_book = {}, },
        ['격풍']       = { c_name = '格风', skill_type = 1, need_book = {}, },
        ['공중 공격']   = { c_name = '空中攻击', skill_type = 2, need_book = {}, },

    },

    --['격풍']       = { c_name = '格风', skill_type = 1, need_book = {}, },
    --['서풍의 나루'] = { c_name = '西风的渡口', skill_type = 0, need_book = {}, },
}
local this = skill_res

-------------------------------------------------------------------------------------
-- 判断技能是否可加入快捷栏
skill_res.can_quick_by_name = function(name)
    for _, v in pairs(this.CAN_QUICK_SKILL) do
        if string.find(name, v) then
            return true
        end
    end
    return false
end

-------------------------------------------------------------------------------------
-- 读取技能转换名称
skill_res.get_skill_name = function(skill_name,is_get_h)
    return (not is_get_h and this.SKILL_INFO[skill_name] and this.SKILL_INFO[skill_name].c_name) or skill_name
end

-------------------------------------------------------------------------------------
-- 返回对象
return skill_res

-------------------------------------------------------------------------------------