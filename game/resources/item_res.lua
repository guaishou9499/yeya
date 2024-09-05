-------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @author:   admin
-- @email:    88888@qq.com
-- @date:     2022-06-30
-- @module:   item_res
-- @describe: 物品资源
-- @version:  v1.0
--
local pairs = pairs
local string = string
-------------------------------------------------------------------------------------
-- 物品资源
---@class item_res
local item_res = {
    -- 绑定物品的标记
    BIND_STAMP     = { '(귀속)' },
    -- 需要分解的物品[中文名 配对所有物品]
    NEED_DECO_ITEM = {
        '结实的肉',
        '浓密的动物毛',
        '破碎的翅膀',
        '哥布林的皮头巾',
        '陈旧的背包',
        --'兔子肉',
        --'破碎的蜗牛壳',
        --'破碎的盔甲',
        --'陈旧的哥布林包',
        --'野生山草莓',
        --'半兽人的骷髅头首饰',
        --'破碎的五色翅膀',
        --'粗糙的半兽人刀',
        --'螳螂钩爪',
        --'坚硬的外壳',
        --'老旧的胡须',
        --'坚硬的龟壳',
        --'食用蘑菇',
        --'动物血',
        --'新鲜水果',
        --'药材粉末',
        --'厚重的肉',
    },
    -- 需要删除的物品[中文名 配对所有物品]
    NEED_DEL_ITEM  = {
        '新手圣物A'
    },
    -- 绑定资源
    ITEM_LIST      = {
        -- 装备类
        ['나이트 크로우 활(귀속)'] = { c_name = '夜叉弓', h_name = '나이트 크로우 활(귀속)', equip_pos = '武器', quality = 3, enhancement_type = '武器' },
        ['섬세한 십자궁(귀속)'] = { c_name = '十字弓箭（绿）', h_name = '섬세한 십자궁(귀속)', equip_pos = '武器', quality = 2, enhancement_type = '武器' },
        ['매끈한 화살통(귀속)'] = { c_name = '绿装箭筒', h_name = '매끈한 화살통(귀속)', equip_pos = '箭筒', quality = 2, enhancement_type = '武器' },
        ['은제 장식 바지(귀속)'] = { c_name = '绿装皮裤', h_name = '은제 장식 바지(귀속)', equip_pos = '皮裤', quality = 2, enhancement_type = '防具' },
        ['은제 장식 갑옷(귀속)'] = { c_name = '绿装盔甲', h_name = '은제 장식 갑옷(귀속)', equip_pos = '盔甲', quality = 2, enhancement_type = '防具' },
        ['철갑 투구(귀속)'] = { c_name = '绿装头盔', h_name = '철갑 투구(귀속)', equip_pos = '头盔', quality = 2, enhancement_type = '防具' },
        ['은제 장식 장갑(귀속)'] = { c_name = '绿装手套', h_name = '은제 장식 장갑(귀속)', equip_pos = '手套', quality = 2, enhancement_type = '防具' },
        ['은제 장식 장화(귀속)'] = { c_name = '绿装靴子', h_name = '은제 장식 장화(귀속)', equip_pos = '靴子', quality = 2, enhancement_type = '防具' },
        ['쿤자이트 반지(귀속)'] = { c_name = '绿色戒指', h_name = '쿤자이트 반지(귀속)', equip_pos = '戒指', quality = 2, enhancement_type = '饰品' },
        ['쿤자이트 귀걸이(귀속)'] = { c_name = '绿色耳环', h_name = '쿤자이트 귀걸이(귀속)', equip_pos = '耳环', quality = 2, enhancement_type = '饰品' },
        ['루벨라이트 목걸이(귀속)'] = { c_name = '绿色项链', h_name = '루벨라이트 목걸이(귀속)', equip_pos = '项链', quality = 2, enhancement_type = '饰品' },
        ['쿤자이트 장식 허리띠(귀속)'] = { c_name = '绿色腰带', h_name = '쿤자이트 장식 허리띠(귀속)', equip_pos = '腰带', quality = 2, enhancement_type = '饰品' },
        ['밤까마귀 발톱 부적(귀속)'] = { c_name = '夜鸦爪符', h_name = '밤까마귀 발톱 부적(귀속)', equip_pos = '爪符', quality = 4, enhancement_type = '夜鸦饰品' },
        ['밤까마귀 깃털 브로치(귀속)'] = { c_name = '夜鸦羽毛胸针', h_name = '밤까마귀 깃털 브로치(귀속)', equip_pos = '胸针', quality = 4, enhancement_type = '夜鸦饰品' },
        ['가벼운 화살통(귀속)'] = { c_name = '新手箭筒', h_name = '가벼운 화살통(귀속)', equip_pos = '箭筒', quality = 1, enhancement_type = '武器' },
        ['조잡한 나무 활(귀속)'] = { c_name = '新手弓箭', h_name = '조잡한 나무 활(귀속)', equip_pos = '武器', quality = 1, enhancement_type = '武器' },
        ['가죽 바지(귀속)'] = { c_name = '新手皮裤', h_name = '가죽 바지(귀속)', equip_pos = '皮裤', quality = 1, enhancement_type = '防具' },
        ['누비 갑옷(귀속)'] = { c_name = '新手盔甲', h_name = '누비 갑옷(귀속)', equip_pos = '盔甲', quality = 1, enhancement_type = '防具' },
        ['사슬 투구(귀속)'] = { c_name = '新手头盔', h_name = '사슬 투구(귀속)', equip_pos = '头盔', quality = 1, enhancement_type = '防具' },
        ['사슬 장갑(귀속)'] = { c_name = '新手手套', h_name = '사슬 장갑(귀속)', equip_pos = '手套', quality = 1, enhancement_type = '防具' },
        ['철 장화(귀속)'] = { c_name = '新手靴子', h_name = '철 장화(귀속)', equip_pos = '靴子', quality = 1, enhancement_type = '防具' },
        ['무명 망토(귀속)'] = { c_name = '新手披风', h_name = '무명 망토(귀속)', equip_pos = '披风', quality = 1, enhancement_type = '防具' },
        ['수리된 반지(귀속)'] = { c_name = '新手戒指', h_name = '수리된 반지(귀속)', equip_pos = '戒指', quality = 1, enhancement_type = '饰品' },
        ['수리된 죔쇠 허리띠(귀속)'] = { c_name = '新手腰带', h_name = '수리된 죔쇠 허리띠(귀속)', equip_pos = '腰带', quality = 1, enhancement_type = '饰品' },
        ['녹슨 목걸이(귀속)'] = { c_name = '新手项链', h_name = '녹슨 목걸이(귀속)', equip_pos = '项链', quality = 1, enhancement_type = '饰品' },
        ['수리된 귀걸이(귀속)'] = { c_name = '新手耳环', h_name = '수리된 귀걸이(귀속)', equip_pos = '耳环', quality = 1, enhancement_type = '饰品' },
        ['신성한 유물(귀속)'] = { c_name = '新手圣物A', h_name = '신성한 유물(귀속)', equip_pos = '圣物A', quality = 1, enhancement_type = '遗物' },
        ['생명의 호신부(귀속)'] = { c_name = '生命护身符（绿）', h_name = '생명의 호신부(귀속)', equip_pos = '圣物B', quality = 2, enhancement_type = '遗物' },
        -- 装备强化卷
        ['방어구 강화 주문서(귀속)'] = { c_name = '防具强化卷', h_name = '방어구 강화 주문서(귀속)', equip_pos = '防具', quality = 1 },
        ['아티팩트 강화 주문서(귀속)'] = { c_name = '遗物强化卷', h_name = '아티팩트 강화 주문서(귀속)', equip_pos = '遗物', quality = 1 },
        ['장신구 강화 주문서(귀속)'] = { c_name = '饰品强化卷', h_name = '장신구 강화 주문서(귀속)', equip_pos = '饰品', quality = 1 },
        ['밤까마귀 강화 주문서(귀속)'] = { c_name = '夜鸦饰品强化卷', h_name = '밤까마귀 강화 주문서(귀속)', equip_pos = '夜鸦饰品', quality = 1 },
        ['무기 강화 주문서(귀속)'] = { c_name = '武器强化卷', h_name = '무기 강화 주문서(귀속)', equip_pos = '武器', quality = 1 },
        ['[이벤트] 무기 강화 주문서(귀속)'] = { c_name = '[活动]武器强化卷', h_name = '[이벤트] 무기 강화 주문서(귀속)', equip_pos = '武器', quality = 1 },
        -- 滑翔机
        ['실험형 날개(귀속)'] = { c_name = '白色滑翔机', h_name = '실험형 날개(귀속)', quality = 1, equip_pos = '滑翔机' },
        ['[론칭 기념] 자유의 검은 날개(귀속)'] = { c_name = '[纪念]自由的黑翅膀滑翔机', h_name = '[론칭 기념] 자유의 검은 날개(귀속)', quality = 2, equip_pos = '滑翔机' },
        -- 药水
        ['생명력 물약(귀속)'] = { c_name = '生命药水（小）', h_name = '생명력 물약(귀속)', equip_pos = '恢复药水' },
        ['필승의 영약(귀속)'] = { c_name = '白色必胜的灵药', h_name = '필승의 영약(귀속)', equip_pos = '灵药' },
        ['파수의 영약(귀속)'] = { c_name = '绿色防御灵药', h_name = '파수의 영약(귀속)', equip_pos = '灵药' },
        ['돌격의 영약(귀속)'] = { c_name = '蓝色攻速灵药', h_name = '돌격의 영약(귀속)', equip_pos = '灵药' },
        ['밤까마귀 성장 비약(귀속)'] = { c_name = '30%经验灵药', h_name = '밤까마귀 성장 비약(귀속)', equip_pos = '灵药' },
        ['[이벤트] 밤까마귀 성장 비약(귀속)'] = { c_name = '[活动]30%经验灵药', h_name = '[이벤트] 밤까마귀 성장 비약(귀속)', equip_pos = '灵药' },
        ['[이벤트] 파수의 영약(귀속)'] = { c_name = '[活动]绿色防御灵药', h_name = '[이벤트] 파수의 영약(귀속)', equip_pos = '灵药' },
        ['크림 스튜(귀속)'] = { c_name = '奶油炖饭', h_name = '크림 스튜(귀속)', equip_pos = '灵药' },
        --
        --
        -- 技能书
        ['기술서 - 집중 공격 I(귀속)'] = { c_name = '主动技能书-集中攻击I', h_name = '기술서 - 집중 공격 I(귀속)', equip_pos = '技能书', job = '弓箭', skill_c_name = '集中攻击', skill_h_name = '집중 공격', level = 1 },
        ['기술서 부록 - 집중 공격 II(귀속)'] = { c_name = '主动技能书-集中攻击II', h_name = '기술서 부록 - 집중 공격 II(귀속)', equip_pos = '技能书', job = '弓箭', skill_c_name = '集中攻击', skill_h_name = '집중 공격', level = 2 },
        ['기술서 - 속결 I(귀속)'] = { c_name = '主动技能书-速决I', h_name = '기술서 - 속결 I(귀속)', equip_pos = '技能书', job = '弓箭', skill_c_name = '速决', skill_h_name = '속결', level = 1 },
        ['기술서 부록 - 속결 II(귀속)'] = { c_name = '主动技能书-速决II', h_name = '기술서 부록 - 속결 II(귀속)', equip_pos = '技能书', job = '弓箭', skill_c_name = '速决', skill_h_name = '속결', level = 2 },
        ['기술서 - 궤도 폭격 I(귀속)'] = { c_name = '主动技能书-轨道轰炸I', h_name = '기술서 - 궤도 폭격 I(귀속)', equip_pos = '技能书', job = '弓箭', skill_c_name = '轨道轰炸', skill_h_name = '궤도 폭격', level = 1 },
        ['기술서 부록 - 궤도 폭격 II(귀속)'] = { c_name = '主动技能书-轨道轰炸II', h_name = '기술서 부록 - 궤도 폭격 II(귀속)', equip_pos = '技能书', job = '弓箭', skill_c_name = '轨道轰炸', skill_h_name = '궤도 폭격', level = 2 },
        ['기술서 부록 - 궤도 폭격 III(귀속)'] = { c_name = '主动技能书-轨道轰炸III', h_name = '기술서 부록 - 궤도 폭격 III(귀속)', equip_pos = '技能书', job = '弓箭', skill_c_name = '轨道轰炸', skill_h_name = '궤도 폭격', level = 3 },
        ['기술서 - 신체 강화 I(귀속)'] = { c_name = '被动技能书-身体强化I', h_name = '기술서 - 신체 강화 I(귀속)', equip_pos = '技能书', job = '弓箭', skill_c_name = '身体强化', skill_h_name = '신체 강화', level = 1 },
        ['기술서 - 폭풍의 시 I(귀속)'] = { c_name = '主动技能书-风暴的诗I', h_name = '기술서 - 폭풍의 시 I(귀속)', equip_pos = '技能书', job = '弓箭', skill_c_name = '风暴的诗', skill_h_name = '폭풍의 시', level = 1 },
        ['기술서 - 마음 가짐 I(귀속)'] = { c_name = '主动技能书-情态I', h_name = '기술서 - 마음 가짐 I(귀속)', equip_pos = '技能书', job = '弓箭', skill_c_name = '情态', skill_h_name = '마음 가짐', level = 1 },
        ['기술서 부록 - 마음 가짐 II(귀속)'] = { c_name = '主动技能书-情态II', h_name = '기술서 부록 - 마음 가짐 II(귀속)', equip_pos = '技能书', job = '弓箭', skill_c_name = '情态', skill_h_name = '마음 가짐', level = 2 },
        ['기술서 - 정밀 사격 I(귀속)'] = { c_name = '主动技能书-精准射击I', h_name = '기술서 - 정밀 사격 I(귀속)', equip_pos = '技能书', job = '弓箭', skill_c_name = '精准射击', skill_h_name = '정밀 사격', level = 1 },
        ['기술서 - 정밀 I(귀속)'] = { c_name = '主动技能书-精密I', h_name = '기술서 - 정밀 I(귀속)', equip_pos = '技能书', job = '弓箭', skill_c_name = '精密', skill_h_name = '정밀', level = 1 },
        ['기술서 부록 - 정밀 사격 II(귀속)'] = { c_name = '主动技能书-精准射击II', h_name = '기술서 부록 - 정밀 사격 II(귀속)', equip_pos = '技能书', job = '弓箭', skill_c_name = '精准射击', skill_h_name = '정밀 사격', level = 2 },
        ['기술서 - 사냥 개시 I(귀속)'] = { c_name = '主动技能书-狩猎开始I', h_name = '기술서 - 사냥 개시 I(귀속)', equip_pos = '技能书', job = '弓箭', skill_c_name = '狩猎开始', skill_h_name = '사냥 개시', level = 1 },
        ['기술서 부록 - 사냥 개시 II(귀속)'] = { c_name = '主动技能书-狩猎开始II', h_name = '기술서 부록 - 사냥 개시 II(귀속)', equip_pos = '技能书', job = '弓箭', skill_c_name = '狩猎开始', skill_h_name = '사냥 개시', level = 2 },
        ['기술서 - 표적 노리기 I(귀속)'] = { c_name = '被动技能书-瞄准目标I', h_name = '기술서 - 표적 노리기 I(귀속)', equip_pos = '技能书', job = '弓箭', skill_c_name = '瞄准目标', skill_h_name = '표적 노리기', level = 1 },
        ['기술서 부록 - 표적 노리기 II(귀속)'] = { c_name = '被动技能书-瞄准目标II', h_name = '기술서 부록 - 표적 노리기 II(귀속)', equip_pos = '技能书', job = '弓箭', skill_c_name = '瞄准目标', skill_h_name = '표적 노리기', level = 2 },
        ['기술서 부록 - 표적 노리기 III(귀속)'] = { c_name = '被动技能书-瞄准目标III', h_name = '기술서 부록 - 표적 노리기 III(귀속)', equip_pos = '技能书', job = '弓箭', skill_c_name = '瞄准目标', skill_h_name = '표적 노리기', level = 3 },
        ['기술서 - 위기 감지 I(귀속)'] = { c_name = '被动技能书-危机感知I', h_name = '기술서 - 위기 감지 I(귀속)', equip_pos = '技能书', job = '弓箭', skill_c_name = '危机感知', skill_h_name = '표적 노리기', level = 1 },
        ['기술서 부록 - 위기 감지 II(귀속)'] = { c_name = '被动技能书-危机感知II', h_name = '기술서 부록 - 위기 감지 II(귀속)', equip_pos = '技能书', job = '弓箭', skill_c_name = '危机感知', skill_h_name = '표적 노리기', level = 2 },
        ['기술서 부록 - 위기 감지 III(귀속)'] = { c_name = '被动技能书-危机感知III', h_name = '기술서 부록 - 위기 감지 III(귀속)', equip_pos = '技能书', job = '弓箭', skill_c_name = '危机感知', skill_h_name = '표적 노리기', level = 3 },
        ['기술서 - 바람의 부름 I(귀속)'] = { c_name = '被动技能书-风的召唤I', h_name = '기술서 - 바람의 부름 I(귀속)', equip_pos = '技能书', job = '弓箭', skill_c_name = '风的召唤', skill_h_name = '위기 감지', level = 1 },
        ['기술서 부록 - 바람의 부름 II(귀속)'] = { c_name = '被动技能书-风的召唤Ii', h_name = '기술서 부록 - 바람의 부름 II(귀속)', equip_pos = '技能书', job = '弓箭', skill_c_name = '风的召唤', skill_h_name = '위기 감지', level = 2 },
        ['기술서 - 치명적 한방 I(귀속)'] = { c_name = '被动技能书-致命一击I', h_name = '기술서 - 치명적 한방 I(귀속)', equip_pos = '技能书', job = '弓箭', skill_c_name = '致命一击', skill_h_name = '치명적 한방', level = 1 },
        ['기술서 - 신궁의 가호 I(귀속)'] = { c_name = '被动技能书-神宫的保佑I', h_name = '기술서 - 신궁의 가호 I(귀속)', equip_pos = '技能书', job = '弓箭', skill_c_name = '神宫的保佑', skill_h_name = '신궁의 가호', level = 1 },
        ['기술서 부록 - 신궁의 가호 II(귀속)'] = { c_name = '被动技能书-神宫的保佑II', h_name = '기술서 부록 - 신궁의 가호 II(귀속)', equip_pos = '技能书', job = '弓箭', skill_c_name = '神宫的保佑', skill_h_name = '신궁의 가호', level = 2 },
        -- 其他
        ['거점 귀환 주문서(귀속)'] = { c_name = '据点传送轴', h_name = '거점 귀환 주문서(귀속)', equip_pos = '传送轴' },
        ['순간 이동 주문서(귀속)'] = { c_name = '瞬移卷轴', h_name = '순간 이동 주문서(귀속)', equip_pos = '瞬移卷轴' },
        -- 补充石
        ['시간 충전 장치 - 번영의 땅(귀속)'] = { c_name = '繁荣的土补充石（绿）', h_name = '시간 충전 장치 - 번영의 땅(귀속)',equip_pos = '补充石',supplement = '繁荣的土' },
        ['[이벤트] 시간 충전 장치 - 번영의 땅(귀속)'] = { c_name = '[活动]繁荣的土补充石（绿）', h_name = '[이벤트] 시간 충전 장치 - 번영의 땅(귀속)',equip_pos = '补充石',supplement = '繁荣的土' },
        ['시간 충전 장치 - 수련의 숲(귀속)'] = { c_name = '修炼之林补充石（蓝）', h_name = '시간 충전 장치 - 수련의 숲(귀속)',equip_pos = '补充石',supplement = '修炼之林' },
        ['[이벤트] 시간 충전 장치 - 수련의 숲(귀속)'] = { c_name = '[活动]修炼之林补充石（蓝）', h_name = '[이벤트] 시간 충전 장치 - 수련의 숲(귀속)',equip_pos = '补充石',supplement = '修炼之林' },
        ['시간 충전 장치 - 이를레타 신전(귀속)'] = { c_name = '伊莱殿神殿补充石（紫）', h_name = '시간 충전 장치 - 이를레타 신전(귀속)',equip_pos = '补充石',supplement = '伊莱殿神殿' },
        ['[이벤트] 시간 충전 장치 - 이를레타 신전(귀속)'] = { c_name = '[活动]伊莱殿神殿补充石（紫）', h_name = '[이벤트] 시간 충전 장치 - 이를레타 신전(귀속)',equip_pos = '补充石',supplement = '伊莱殿神殿' },
        ['시간 충전 장치 - 산코나 유적(귀속)'] = { c_name = '圣科拿遗迹补充石（黄）', h_name = '시간 충전 장치 - 산코나 유적(귀속)',equip_pos = '补充石',supplement = '圣科拿遗迹' },
        ['[이벤트] 시간 충전 장치 - 산코나 유적(귀속)'] = { c_name = '[活动]圣科拿遗迹补充石（黄）', h_name = '[이벤트] 시간 충전 장치 - 산코나 유적(귀속)',equip_pos = '补充石',supplement = '圣科拿遗迹' },
        ['시간 충전 장치 - 마사르타 얼음 동굴(귀속)'] = { c_name = '马萨塔冰窟补充石（橙）', h_name = '시간 충전 장치 - 마사르타 얼음 동굴(귀속)',equip_pos = '补充石' ,supplement = '马萨塔冰窟'},
        ['[이벤트] 시간 충전 장치 - 마사르타 얼음 동굴(귀속)'] = { c_name = '[活动]马萨塔冰窟补充石（橙）', h_name = '[이벤트] 시간 충전 장치 - 마사르타 얼음 동굴(귀속)',equip_pos = '补充石',supplement = '马萨塔冰窟' },
        -- 材料
        ['털뭉치(귀속)'] = { c_name = '毛球', h_name = '털뭉치(귀속)', equip_pos = '材料' },
        ['철광석'] = { c_name = '铁矿石', h_name = '철광석', equip_pos = '材料' },
        -- 箱子

        ['고급 무기 외형 선택(귀속)'] = { c_name = '蓝色武器外形选择箱', h_name = '고급 무기 외형 선택(귀속)', equip_pos = '箱子' },
        ['밤까마귀 발톱 부적 상자(귀속)'] = { c_name = '夜鸦爪符箱', h_name = '밤까마귀 발톱 부적 상자(귀속)', equip_pos = '夜鸦箱子' },
        ['밤까마귀 깃털 브로치 상자(귀속)'] = { c_name = '夜鸦胸针箱', h_name = '밤까마귀 깃털 브로치 상자(귀속)', equip_pos = '夜鸦箱子' },
        ['나이트 크로우 점검 보상 상자 I(귀속)'] = { c_name = '夜鸦补偿箱I', h_name = '나이트 크로우 점검 보상 상자 I(귀속)', equip_pos = '箱子' },
        ['나이트 크로우 점검 보상 상자 V(귀속)'] = { c_name = '夜鸦补偿箱V', h_name = '나이트 크로우 점검 보상 상자 V(귀속)', equip_pos = '箱子' },

        -- 选择箱
        ['골드 상자(귀속)'] = { c_name = '金币箱', h_name = '골드 상자(귀속)', equip_pos = '选择箱' ,sel_idx = 0 },
        ['분실된 용병단 장비 상자(귀속)'] =  { c_name = '雇佣兵遗失的装备箱', h_name = '분실된 용병단 장비 상자(귀속)', equip_pos = '选择箱',sel_idx = 0 },
        ['고급 무기 선택 상자(귀속)'] = { c_name = '绿色武器选择箱', h_name = '고급 무기 선택 상자(귀속)', equip_pos = '选择箱',sel_idx = 4 },
        ['고급 보조 장비 선택 상자(귀속)'] = { c_name = '绿色辅助装备选择箱', h_name = '고급 보조 장비 선택 상자(귀속)', equip_pos = '选择箱',sel_idx = 4 },
        ['고급 무기 외형 선택(귀속)'] = { c_name = '绿色武器外形选择箱', h_name = '고급 무기 외형 선택(귀속)', equip_pos = '选择箱',sel_idx = 4 },
        ['음식 바구니(귀속)'] = { c_name = '食物选择箱', h_name = '음식 바구니(귀속)', equip_pos = '选择箱',sel_idx = 1 },
        ['희귀 무기 외형 소환 선택(귀속)'] = { c_name = '蓝色武器外形选择箱', h_name = '희귀 무기 외형 소환 선택(귀속)', equip_pos = '选择箱',sel_idx = 4 },
        ['일반 제작 재료 선택 상자(귀속)'] = { c_name = '一般制作材料选择框(归属)', h_name = '일반 제작 재료 선택 상자(귀속)', equip_pos = '选择箱',sel_idx = -1 },
        ['빛나는 무기 강화 주문서 상자(귀속)'] = { c_name = '闪亮武器强化订单箱(归属)', h_name = '빛나는 무기 강화 주문서 상자(귀속)', equip_pos = '选择箱',sel_idx = 0 },
        ['빛나는 방어구 강화 주문서 상자(귀속)'] = { c_name = '闪亮防御具强化订单箱(归属)', h_name = '빛나는 방어구 강화 주문서 상자(귀속)', equip_pos = '选择箱',sel_idx = 0  },
        ['빛나는 장신구 강화 주문서 상자(귀속)'] = { c_name = '闪亮首饰强化订单箱(归属)', h_name = '빛나는 장신구 강화 주문서 상자(귀속)', equip_pos = '选择箱',sel_idx = 0  },
        ['수련의 숲 재료 상자(귀속)'] = { c_name = '修炼的森林材料箱(归属)', h_name = '수련의 숲 재료 상자(귀속)', equip_pos = '选择箱',sel_idx = 0  },
        ['30일 기념 감사 패키지(귀속)'] =  { c_name = '30日纪念感谢套装(归属)', h_name = '30일 기념 감사 패키지(귀속)', equip_pos = '选择箱',sel_idx = 0 },
        ['30일 기념 페스타 상자(귀속)'] = { c_name = '30日纪念节箱子(归属)', h_name = '30일 기념 페스타 상자(귀속)', equip_pos = '选择箱',sel_idx = 0 },
        ['하급 수련의 숲 상자(귀속)'] = { c_name = '下级修炼的森林箱子(归属)', h_name = '하급 수련의 숲 상자(귀속)', equip_pos = '选择箱',sel_idx = 0 },
        -- 召唤卷
        ['미명의 눈부신 무기 외형 소환 (귀속)'] = { c_name = '橙色武器外形召唤券', h_name = '미명의 눈부신 무기 외형 소환 (귀속)', equip_pos = '召唤券' },
        ['미명의 화려한 활 무기 외형 소환(귀속)'] = { c_name = '紫色弓箭外形召唤券', h_name = '미명의 화려한 활 무기 외형 소환(귀속)', equip_pos = '召唤券' },
        ['미명의 눈부신 탈것 소환 (귀속)'] = { c_name = '橙色坐骑召唤券', h_name = '미명의 눈부신 탈것 소환 (귀속)', equip_pos = '召唤券' },
        ['미명의 화려한 탈것 소환 (귀속)'] = { c_name = '紫色坐骑召唤券', h_name = '미명의 화려한 탈것 소환 (귀속)', equip_pos = '召唤券' },
        ['희귀 탈것 소환(귀속)'] = { c_name = '蓝色坐骑召唤券', h_name = '희귀 탈것 소환(귀속)', equip_pos = '召唤券' },
        ['석양의 탈것 소환(귀속)'] = { c_name = '夕阳的坐骑召唤券', h_name = '석양의 탈것 소환(귀속)', equip_pos = '召唤券' },
        ['희귀 활 무기 외형 소환(귀속)'] = { c_name = '稀有武器外形召唤(归属)', h_name = '희귀 활 무기 외형 소환(귀속)', equip_pos = '召唤券' },
        ['석양의 무기 외형 소환(귀속)'] = { c_name = '夕阳的武器外形召唤', h_name = '석양의 무기 외형 소환(귀속)', equip_pos = '召唤券' },
        ['미명의 화려한 무기 외형 소환 11회(귀속)'] = { c_name = '美明华丽的武器外形召唤11回(归属)', h_name = '미명의 화려한 무기 외형 소환 11회(귀속)', equip_pos = '召唤券' },

        -- 不绑定
        ['수리된 반지'] = { c_name = '新手戒指', h_name = '수리된 반지', equip_pos = '戒指', quality = 1, enhancement_type = '饰品' },
        ['수리된 귀걸이'] = { c_name = '新手耳环', h_name = '수리된 귀걸이', equip_pos = '耳环', quality = 1, enhancement_type = '饰品' },
        ['가벼운 화살통'] = { c_name = '新手箭筒', h_name = '가벼운 화살통', equip_pos = '箭筒', quality = 1, enhancement_type = '武器' },
        ['조잡한 나무 활'] = { c_name = '新手弓箭', h_name = '조잡한 나무 활', equip_pos = '武器', quality = 1, enhancement_type = '武器' },
        ['가죽 바지'] = { c_name = '新手皮裤', h_name = '가죽 바지', equip_pos = '皮裤', quality = 1, enhancement_type = '防具' },
        ['누비 갑옷'] = { c_name = '新手盔甲', h_name = '누비 갑옷', equip_pos = '盔甲', quality = 1, enhancement_type = '防具' },
        ['사슬 투구'] = { c_name = '新手头盔', h_name = '사슬 투구', equip_pos = '头盔', quality = 1, enhancement_type = '防具' },
        ['사슬 장갑'] = { c_name = '新手手套', h_name = '사슬 장갑', equip_pos = '手套', quality = 1, enhancement_type = '防具' },
        ['철 장화'] = { c_name = '新手靴子', h_name = '철 장화', equip_pos = '靴子', quality = 1, enhancement_type = '防具' },
        ['무명 망토'] = { c_name = '新手披风', h_name = '무명 망토', equip_pos = '披风', quality = 1, enhancement_type = '防具' },
        ['수리된 죔쇠 허리띠'] = { c_name = '新手腰带', h_name = '수리된 죔쇠 허리띠', equip_pos = '腰带', quality = 1, enhancement_type = '饰品' },
        ['녹슨 목걸이'] = { c_name = '新手项链', h_name = '녹슨 목걸이', equip_pos = '项链', quality = 1, enhancement_type = '饰品' },

        ['순수한 바스티움 결정'] = { c_name = '纯粹的巴斯提姆结晶', h_name = '순수한 바스티움 결정', equip_pos = '材料' },
        ['순수한 첼라노 결정'] = { c_name = '纯粹的切拉诺结晶', h_name = '순수한 첼라노 결정', equip_pos = '材料' },
        ['이를레타의 증표 I'] = { c_name = '莱塔的信物I', h_name = '이를레타의 증표 I', equip_pos = '材料' },
        ['하급 번영의 증표'] = { c_name = '下级繁荣象征', h_name = '하급 번영의 증표', equip_pos = '材料' },
        ['산코나의 증표 I'] = { c_name = '圣科纳的信物I', h_name = '산코나의 증표 I', equip_pos = '材料' },
        ['질긴 고기'] = { c_name = '结实的肉', h_name = '질긴 고기', equip_pos = '材料' },
        ['찢어진 날개 조각'] = { c_name = '破碎的翅膀', h_name = '찢어진 날개 조각', equip_pos = '材料' },
        ['풍성한 동물털'] = { c_name = '浓密的动物毛', h_name = '풍성한 동물털', equip_pos = '材料' },
        ['고블린 가죽 두건'] = { c_name = '哥布林的皮头巾', h_name = '고블린 가죽 두건', equip_pos = '材料' },
        ['낡은 배낭'] = { c_name = '陈旧的背包', h_name = '낡은 배낭', equip_pos = '材料' },
        ['토끼 고기'] = { c_name = '兔子肉', h_name = '토끼 고기', equip_pos = '材料' },
        ['깨진 달팽이 껍질'] = { c_name = '破碎的蜗牛壳', h_name = '깨진 달팽이 껍질', equip_pos = '材料' },
        ['깨진 갑옷 조각'] = { c_name = '破碎的盔甲', h_name = '깨진 갑옷 조각', equip_pos = '材料' },
        ['낡은 고블린 주머니'] = { c_name = '陈旧的哥布林包', h_name = '낡은 고블린 주머니', equip_pos = '材料' },
        ['야생 산딸기'] = { c_name = '野生山草莓', h_name = '야생 산딸기', equip_pos = '材料' },
        ['오크 해골 장신구'] = { c_name = '半兽人的骷髅头首饰', h_name = '오크 해골 장신구', equip_pos = '材料' },
        ['오색 날개 조각'] = { c_name = '破碎的五色翅膀', h_name = '오색 날개 조각', equip_pos = '材料' },
        ['투박한 오크 칼'] = { c_name = '粗糙的半兽人刀', h_name = '투박한 오크 칼', equip_pos = '材料' },
        ['사마귀 갈고리 발톱'] = { c_name = '螳螂钩爪', h_name = '사마귀 갈고리 발톱', equip_pos = '材料' },
        ['딱딱한 껍데기'] = { c_name = '坚硬的外壳', h_name = '딱딱한 껍데기', equip_pos = '材料' },
        ['늙은 놀 수염'] = { c_name = '老旧的胡须', h_name = '늙은 놀 수염', equip_pos = '材料' },
        ['거북 등딱지'] = { c_name = '坚硬的龟壳', h_name = '거북 등딱지', equip_pos = '材料' },
        ['식용 버섯'] = { c_name = '食用蘑菇', h_name = '식용 버섯', equip_pos = '材料' },
        ['동물의 피'] = { c_name = '动物血', h_name = '동물의 피', equip_pos = '材料' },
        ['동물 뼈 견장'] = { c_name = '动物的肩章', h_name = '동물 뼈 견장', equip_pos = '材料' },
        ['악에 물든 철퇴'] = { c_name = '恐怖的铁锤', h_name = '악에 물든 철퇴', equip_pos = '材料' },
        ['이교도 보급 물자'] = { c_name = '异教徒补给物资', h_name = '이교도 보급 물자', equip_pos = '材料' },
        ['숨겨둔 맥주'] = { c_name = '藏起来的啤酒', h_name = '숨겨둔 맥주', equip_pos = '材料' },
        ['단단한 짐승 뿔'] = { c_name = '坚硬的野兽角', h_name = '단단한 짐승 뿔', equip_pos = '材料' },
        ['부러진 화살'] = { c_name = '断箭', h_name = '부러진 화살', equip_pos = '材料' },
        ['조잡한 뼈 목걸이'] = { c_name = '粗糙的骨头项链', h_name = '조잡한 뼈 목걸이', equip_pos = '材料' },
        ['사악한 백골석'] = { c_name = '邪恶的头骨', h_name = '사악한 백골석', equip_pos = '材料' },
        ['오크 특제 수프'] = { c_name = '半兽人特制汤', h_name = '오크 특제 수프', equip_pos = '材料' },
        ['악에 물든 가루'] = { c_name = '恶灵粉末', h_name = '악에 물든 가루', equip_pos = '材料' },
        ['빈 술병'] = { c_name = '空酒瓶', h_name = '빈 술병', equip_pos = '材料' },
        ['싱싱한 과일'] = { c_name = '新鲜水果', h_name = '싱싱한 과일', equip_pos = '材料' },
        ['약재 가루'] = { c_name = '药材粉末', h_name = '약재 가루', equip_pos = '材料' },
        ['육중한 고기'] = { c_name = '厚重的肉', h_name = '육중한 고기', equip_pos = '材料' },
        ['정체불명의 파편'] = { c_name = '力量碎片', h_name = '정체불명의 파편', equip_pos = '材料' },
        ['누더기 망토'] = { c_name = '破旧的披风', h_name = '누더기 망토', equip_pos = '材料' },
        ['푸른 꽃'] = { c_name = '蓝花', h_name = '푸른 꽃', equip_pos = '材料' },
        ['독거미액'] = { c_name = '蜘蛛毒液', h_name = '독거미액', equip_pos = '材料' },
        ['훼손된 쪽지'] = { c_name = '被损毁的纸条', h_name = '훼손된 쪽지', equip_pos = '材料' },
        ['신선한 생선'] = { c_name = '新鲜的鱼', h_name = '신선한 생선', equip_pos = '材料' },
        ['불길한 해골'] = { c_name = '不祥的骷髅', h_name = '불길한 해골', equip_pos = '材料' },
        ['망자의 비밀 열쇠'] = { c_name = '亡者的秘密钥匙', h_name = '망자의 비밀 열쇠', equip_pos = '材料' },
        ['악에 물든 망자의 가면'] = { c_name = '恶灵面具', h_name = '악에 물든 망자의 가면', equip_pos = '材料' },
        ['벌레 호박석'] = { c_name = '琥珀虫子', h_name = '벌레 호박석', equip_pos = '材料' },
        ['딱딱한 집게발'] = { c_name = '坚硬的螯肢', h_name = '딱딱한 집게발', equip_pos = '材料' },
        ['바스티움 결정'] = { c_name = '巴斯提姆结晶', h_name = '바스티움 결정', equip_pos = '材料' },
        ['첼라노 결정'] = { c_name = '切拉诺结晶', h_name = '첼라노 결정', equip_pos = '材料' },
        ['순수한 아빌리우스 결정'] = { c_name = '纯粹的阿比利乌斯结晶', h_name = '순수한 아빌리우스 결정', equip_pos = '材料' },
        ['이를레타의 증표 II'] = { c_name = '莱塔的信物II', h_name = '이를레타의 증표 II', equip_pos = '材料' },
        ['상급 번영의 증표'] = { c_name = '上级繁荣象征', h_name = '상급 번영의 증표', equip_pos = '材料' },
        ['산코나의 증표 II'] = { c_name = '圣科纳的信物II', h_name = '산코나의 증표 II', equip_pos = '材料' },
        ['고블린 뼈 장식'] = { c_name = '哥布林的骨头项链', h_name = '고블린 뼈 장식', equip_pos = '材料' },
        ['휴대용 물주머니'] = { c_name = '便携式水袋', h_name = '휴대용 물주머니', equip_pos = '材料' },
        ['놀의 곤봉'] = { c_name = '棍棒', h_name = '놀의 곤봉', equip_pos = '材料' },
        ['날카로운 발톱'] = { c_name = '锋利的爪子', h_name = '날카로운 발톱', equip_pos = '材料' },
        ['달달한 과실주'] = { c_name = '美味的水果酒', h_name = '달달한 과실주', equip_pos = '材料' },
        ['사티로스 주술봉'] = { c_name = '萨提罗斯的巫术棒', h_name = '사티로스 주술봉', equip_pos = '材料' },
        ['수풀 끈으로 만든 덫'] = { c_name = '草丛陷阱', h_name = '수풀 끈으로 만든 덫', equip_pos = '材料' },
        ['브리 치즈'] = { c_name = '布里奶酪', h_name = '브리 치즈', equip_pos = '材料' },
        ['벌레 수액'] = { c_name = '树液虫子', h_name = '벌레 수액', equip_pos = '材料' },
        ['기사의 뿔피리'] = { c_name = '角笛', h_name = '기사의 뿔피리', equip_pos = '材料' },
        ['상급 전직의 증표'] = { c_name = '上级转职信物', h_name = '상급 전직의 증표', equip_pos = '材料' },
        ['얼어붙은 눈물'] = { c_name = '眼泪结晶', h_name = '얼어붙은 눈물', equip_pos = '材料' },
        ['창공의 조각'] = { c_name = '天空的碎片', h_name = '창공의 조각', equip_pos = '材料' },
        ['성장의 원천'] = { c_name = '成长的源泉', h_name = '성장의 원천', equip_pos = '材料' },
        ['고대 파피루스'] = { c_name = '古代图纸', h_name = '고대 파피루스', equip_pos = '材料' },
        ['단련의 비전서'] = { c_name = '锻炼的展望书', h_name = '단련의 비전서', equip_pos = '材料' },
        ['도약의 비전서'] = { c_name = '飞跃的展望书', h_name = '도약의 비전서', equip_pos = '材料' },
        ['총명의 비전서'] = { c_name = '聪明的展望书', h_name = '총명의 비전서', equip_pos = '材料' },
        ['번영의 비전서'] = { c_name = '繁荣的展望书', h_name = '번영의 비전서', equip_pos = '材料' },
        ['월장석'] = { c_name = '月长石', h_name = '월장석', equip_pos = '材料' },
        ['혼합 시약'] = { c_name = '混合试剂', h_name = '혼합 시약', equip_pos = '材料' },
        ['철주괴'] = { c_name = '铁块', h_name = '철주괴', equip_pos = '材料' },
        ['수정 결정'] = { c_name = '水晶结晶', h_name = '수정 결정', equip_pos = '材料' },
        ['부드러운 가죽'] = { c_name = '柔软的皮革', h_name = '부드러운 가죽', equip_pos = '材料' },
        ['천연 모피'] = { c_name = '天然毛团', h_name = '천연 모피', equip_pos = '材料' },
        ['전직의 증표'] = { c_name = '转职的信物', h_name = '전직의 증표', equip_pos = '材料' },
        ['철광석'] = { c_name = '铁矿石', h_name = '철광석', equip_pos = '材料' },
        ['수정 광물'] = { c_name = '水晶矿石', h_name = '수정 광물', equip_pos = '材料' },
        ['거친 가죽'] = { c_name = '动物皮革', h_name = '거친 가죽', equip_pos = '材料' },
        ['털뭉치'] = { c_name = '毛团', h_name = '털뭉치', equip_pos = '材料' },
        ['낡은 비행 부품'] = { c_name = '陈旧的飞行零件', h_name = '낡은 비행 부품', equip_pos = '材料' },
        ['금속 파편'] = { c_name = '金属碎片', h_name = '금속 파편', equip_pos = '材料' },
        ['황금 천칭'] = { c_name = '黄金天秤', h_name = '황금 천칭', equip_pos = '材料' },
        ['황금 조각도'] = { c_name = '黄金雕刻刀', h_name = '황금 조각도', equip_pos = '材料' },
        ['사금 주머니'] = { c_name = '金币袋', h_name = '사금 주머니', equip_pos = '材料' },
        ['모리온'] = { c_name = '莫里恩', h_name = '모리온', equip_pos = '材料' },
        ['방어구 강화 주문서'] = { c_name = '防具强化卷', h_name = '방어구 강화 주문서', equip_pos = '防具', quality = 1 },
        ['아티팩트 강화 주문서'] = { c_name = '遗物强化卷', h_name = '아티팩트 강화 주문서', equip_pos = '遗物', quality = 1 },
        ['장신구 강화 주문서'] = { c_name = '饰品强化卷', h_name = '장신구 강화 주문서', equip_pos = '饰品', quality = 1 },
        ['밤까마귀 강화 주문서'] = { c_name = '夜鸦饰品强化卷', h_name = '밤까마귀 강화 주문서', equip_pos = '夜鸦饰品', quality = 1 },
        ['무기 강화 주문서'] = { c_name = '武器强化卷', h_name = '무기 강화 주문서', equip_pos = '武器', quality = 1 },
        ['시간 충전 장치 - 번영의 땅'] = { c_name = '繁荣的土补充石（绿）', h_name = '시간 충전 장치 - 번영의 땅' },
        ['시간 충전 장치 - 수련의 숲'] = { c_name = '修炼之林补充石（蓝）', h_name = '시간 충전 장치 - 수련의 숲' },
        ['시간 충전 장치 - 이를레타 신전'] = { c_name = '伊莱殿神殿补充石（紫）', h_name = '시간 충전 장치 - 이를레타 신전' },
        ['시간 충전 장치 - 산코나 유적'] = { c_name = '圣科拿遗迹补充石（黄）', h_name = '시간 충전 장치 - 산코나 유적' },
        ['시간 충전 장치 - 마사르타 얼음 동굴'] = { c_name = '马萨塔冰窟补充石（橙）', h_name = '시간 충전 장치 - 마사르타 얼음 동굴' },
        ['무기 세공석'] = { c_name = '武器加工蓝色石', h_name = '무기 세공석', equip_pos = '装备材料' },
        ['방어구 세공석'] = { c_name = '防具加工蓝色石', h_name = '방어구 세공석', equip_pos = '装备材料' },
        ['장신구 세공석'] = { c_name = '饰品加工蓝色石', h_name = '장신구 세공석', equip_pos = '装备材料' },
        ['아티팩트 세공석'] = { c_name = '遗物加工蓝色石', h_name = '아티팩트 세공석', equip_pos = '装备材料' },

    },
}

local this = item_res

-------------------------------------------------------------------------------------
-- 判断物品是否绑定
item_res.is_bind_by_name = function(name)
    for _, v in pairs(this.BIND_STAMP) do
        if string.find(name, v) then
            return true
        end
    end
    return false
end

-------------------------------------------------------------------------------------
-- 物品是否可分解
item_res.is_can_deco_by_name = function(name)
    for _, v in pairs(this.NEED_DECO_ITEM) do
        if name == v then
            return true
        end
    end
    return false
end

-------------------------------------------------------------------------------------
-- 物品是否可删除
item_res.is_can_del_by_name = function(name)
    for _, v in pairs(this.NEED_DEL_ITEM) do
        if name == v then
            return true
        end
    end
    return false
end

-------------------------------------------------------------------------------------
-- 返回对象
return item_res

-------------------------------------------------------------------------------------