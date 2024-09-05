-------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @author:   admin
-- @email:    88888@qq.com
-- @date:     2022-06-30
-- @module:   shop_res
-- @describe: 物品资源
-- @version:  v1.0
--
local pairs = pairs
local string = string
-------------------------------------------------------------------------------------
-- 物品资源
---@class shop_res
local shop_res = {
    -- 新手村
    ['아빌리우스 성채'] = {
        ['杂货商人'] = {
            npc_pos = { x = -17292.49, y = -78982.35, z = 11259.81 , map_id = 101},
            transfer_id = 0x1613F9,
            name = '마야',
            class_name = 'Role_EtcStore_C',
            sell_item = {
                ['生命药水（小）'] = { h_name = '생명력 물약(귀속)', price = 15 },
                ['瞬移卷轴'] = { h_name = '순간 이동 주문서(귀속)', price = 800 },
                ['蓝色攻速灵药'] = { h_name = '돌격의 영약(귀속)', price = 800 },
            },
        },
        ['武器商人'] = {
            npc_pos = { x = -18108.74, y = -78224.72, z = 11271.81 , map_id = 101},
            transfer_id = 0x1613F9,
            name = '이삭',
            class_name = 'Role_EquipmentStore_C',
        },
        ['仓库管理员'] = {
            npc_pos = { x = -13530.93, y = -81051.23, z = 11151.66 , map_id = 101},
            transfer_id = 0x1613F9,
            name = '아인',
            class_name = 'Role_WareHouse_C',
        },
        ['初级技能书商人'] = {
            npc_pos = { x = -14123.04, y = -82311.87, z = 11150.91 , map_id = 101},
            transfer_id = 0x1613F9,
            name = '루체',
            class_name = 'Role_AlchemyStore_C',
            sell_item = {
                ['主动技能书-集中攻击I'] = { h_name = '기술서 - 집중 공격 I(귀속)', price = 30000 },
                ['主动技能书-情态I'] = { h_name = '기술서 - 마음 가짐 I(귀속)', price = 30000 },
                ['主动技能书-速决I'] = { h_name = '기술서 - 속결 I(귀속)', price = 80000 },
                ['被动技能书-瞄准目标I'] = { h_name = '기술서 - 표적 노리기 I(귀속)', price = 80000 },
                ['被动技能书-危机感知I'] = { h_name = '기술서 - 위기 감지 I(귀속)', price = 80000 },
            },

        },
        ['技能书商人'] = {
            npc_pos = { x = -12798.83, y = -78706.46, z = 11209.25 , map_id = 101},
            transfer_id = 0x1613F9,
            name = '브레드',
            class_name = 'Role_SkillStore_C',
            sell_item = {
                ['主动技能书-集中攻击II'] = { h_name = '기술서 부록 - 집중 공격 II(귀속)', price = 90000 },
                ['主动技能书-情态II'] = { h_name = '기술서 부록 - 마음 가짐 II(귀속)', price = 90000 },
                ['主动技能书-轨道轰炸I'] = { h_name = '기술서 - 궤도 폭격 I(귀속)', price = 500000 },
                ['主动技能书-精准射击I'] = { h_name = '기술서 - 정밀 사격 I(귀속)', price = 500000 },
                ['主动技能书-狩猎开始I'] = { h_name = '기술서 - 사냥 개시 I(귀속)', price = 500000 },
                ['被动技能书-神宫的保佑I'] = { h_name = '기술서 - 신궁의 가호 I(귀속)', price = 500000 },
                ['被动技能书-风的召唤I'] = { h_name = '기술서 - 바람의 부름 I(귀속)', price = 500000 },
                ['主动技能书-速决II'] = { h_name = '기술서 부록 - 속결 II(귀속)', price = 750000 },
                ['被动技能书-瞄准目标II'] = { h_name = '기술서 부록 - 표적 노리기 II(귀속)', price = 750000 },
                ['被动技能书-危机感知II'] = { h_name = '기술서 부록 - 위기 감지 II(귀속)', price = 750000 },
                ['被动技能书-瞄准目标III'] = { h_name = '기술서 부록 - 표적 노리기 III(귀속)', price = 1250000 },
                ['被动技能书-危机感知III'] = { h_name = '기술서 부록 - 위기 감지 III(귀속)', price = 1250000 },
                ['主动技能书-轨道轰炸II'] = { h_name = '기술서 부록 - 궤도 폭격 II(귀속)', price = 1500000 },
                ['主动技能书-精准射击II'] = { h_name = '기술서 부록 - 정밀 사격 II(귀속)', price = 1500000 },
                ['主动技能书-狩猎开始II'] = { h_name = '기술서 부록 - 사냥 개시 II(귀속)', price = 1500000 },
                ['被动技能书-神宫的保佑II'] = { h_name = '기술서 부록 - 신궁의 가호 II(귀속)', price = 1500000 },
                ['被动技能书-风的召唤II'] = { h_name = '기술서 부록 - 바람의 부름 II(귀속)', price = 1500000 },
                ['主动技能书-轨道轰炸III'] = { h_name = '기술서 부록 - 궤도 폭격 III(귀속)', price = 2500000 },
                ['主动技能书-风暴的诗I'] = { h_name = '기술서 - 폭풍의 시 I(귀속)', price = 9000000 },
                ['被动技能书-致命一击I'] = { h_name = '기술서 - 치명적 한방 I(귀속)', price = 9000000 },
            },
        },
        ['遗物商人'] = {
            npc_pos = { x = -15690.08, y = -78470.93, z = 11252.35 , map_id = 101},
            transfer_id = 0x1613F9,
            name = '랜든',
            class_name = 'Role_ArtifactStore_C',
            sell_item = {
                ['生命护身符（绿）'] = { h_name = '생명의 호신부(귀속)', price = 200000 },
            },
        },
    },
    -- 巴士底姆村（第七章完结进入）
    ['바스티움 마을'] = {
        ['杂货商人'] = {
            npc_pos = { x = -24851.63, y = -55850.00, z = 2061.32 , map_id = 201},
            transfer_id = 0x161456,
            name = '라일라',
            class_name = 'Role_EtcStore_C',
            sell_item = {
                ['生命药水（小）'] = { h_name = '생명력 물약(귀속)', price = 15 },
                ['瞬移卷轴'] = { h_name = '순간 이동 주문서(귀속)', price = 800 },
                ['蓝色攻速灵药'] = { h_name = '돌격의 영약(귀속)', price = 800 },
            },
        },
        ['武器商人'] = {
            npc_pos = { x = -28041.63, y = -52900.00, z = 2083.84 , map_id = 201},
            transfer_id = 0x161456,
            name = '제이비어',
            class_name = 'Role_EquipmentStore_C',
        },
        ['仓库管理员'] = {
            npc_pos = { x = -27381.63, y = -56970.00, z = 2035.79 , map_id = 201},
            transfer_id = 0x161456,
            name = '카터',
            class_name = 'Role_WareHouse_C',
        },
        ['初级技能书商人'] = {
            npc_pos = { x = -26220.70, y = -53894.70, z = 1995.10 , map_id = 201},
            transfer_id = 0x161456,
            name = '알핀',
            class_name = 'Role_AlchemyStore_C',
            sell_item = {
                ['主动技能书-集中攻击I'] = { h_name = '기술서 - 집중 공격 I(귀속)', price = 30000 },
                ['主动技能书-情态I'] = { h_name = '기술서 - 마음 가짐 I(귀속)', price = 30000 },
                ['主动技能书-速决I'] = { h_name = '기술서 - 속결 I(귀속)', price = 80000 },
                ['被动技能书-瞄准目标I'] = { h_name = '기술서 - 표적 노리기 I(귀속)', price = 80000 },
                ['被动技能书-危机感知I'] = { h_name = '기술서 - 위기 감지 I(귀속)', price = 80000 },
            },

        },
        ['技能书商人'] = {
            npc_pos = { x = -24651.63, y = -53500.00, z = 2121.56 , map_id = 201},
            transfer_id = 0x161456,
            name = '레딘',
            class_name = 'Role_SkillStore_C',
            sell_item = {
                ['主动技能书-集中攻击II'] = { h_name = '기술서 부록 - 집중 공격 II(귀속)', price = 90000 },
                ['主动技能书-情态II'] = { h_name = '기술서 부록 - 마음 가짐 II(귀속)', price = 90000 },
                ['主动技能书-轨道轰炸I'] = { h_name = '기술서 - 궤도 폭격 I(귀속)', price = 500000 },
                ['主动技能书-精准射击I'] = { h_name = '기술서 - 정밀 사격 I(귀속)', price = 500000 },
                ['主动技能书-狩猎开始I'] = { h_name = '기술서 - 사냥 개시 I(귀속)', price = 500000 },
                ['被动技能书-神宫的保佑I'] = { h_name = '기술서 - 신궁의 가호 I(귀속)', price = 500000 },
                ['被动技能书-风的召唤I'] = { h_name = '기술서 - 바람의 부름 I(귀속)', price = 500000 },
                ['主动技能书-速决II'] = { h_name = '기술서 부록 - 속결 II(귀속)', price = 750000 },
                ['被动技能书-瞄准目标II'] = { h_name = '기술서 부록 - 표적 노리기 II(귀속)', price = 750000 },
                ['被动技能书-危机感知II'] = { h_name = '기술서 부록 - 위기 감지 II(귀속)', price = 750000 },
                ['被动技能书-瞄准目标III'] = { h_name = '기술서 부록 - 표적 노리기 III(귀속)', price = 1250000 },
                ['被动技能书-危机感知III'] = { h_name = '기술서 부록 - 위기 감지 III(귀속)', price = 1250000 },
                ['主动技能书-轨道轰炸II'] = { h_name = '기술서 부록 - 궤도 폭격 II(귀속)', price = 1500000 },
                ['主动技能书-精准射击II'] = { h_name = '기술서 부록 - 정밀 사격 II(귀속)', price = 1500000 },
                ['主动技能书-狩猎开始II'] = { h_name = '기술서 부록 - 사냥 개시 II(귀속)', price = 1500000 },
                ['被动技能书-神宫的保佑II'] = { h_name = '기술서 부록 - 신궁의 가호 II(귀속)', price = 1500000 },
                ['被动技能书-风的召唤II'] = { h_name = '기술서 부록 - 바람의 부름 II(귀속)', price = 1500000 },
                ['主动技能书-轨道轰炸III'] = { h_name = '기술서 부록 - 궤도 폭격 III(귀속)', price = 2500000 },
                ['主动技能书-风暴的诗I'] = { h_name = '기술서 - 폭풍의 시 I(귀속)', price = 9000000 },
                ['被动技能书-致命一击I'] = { h_name = '기술서 - 치명적 한방 I(귀속)', price = 9000000 },
            },
        },
        ['遗物商人'] = {
            npc_pos = { x = -25351.63, y = -56800.00, z = 2084.26 , map_id = 201 },
            transfer_id = 0x161456,
            name = '요제프',
            class_name = 'Role_ArtifactStore_C',
            sell_item = {
                ['生命护身符（绿）'] = { h_name = '생명의 호신부(귀속)', price = 200000 },
            },
        },
    },
    -- 切拉诺村（第十五章完结进入）
    ['첼라노 마을'] = {
        ['杂货商人'] = {
            npc_pos = { x = 116492.00, y = 73440.00, z = 19232.49 , map_id = 301 },
            transfer_id = 0x1614C1,
            name = '에이린',
            class_name = 'Role_EtcStore_C',
            sell_item = {
                ['生命药水（小）'] = { h_name = '생명력 물약(귀속)', price = 15 },
                ['瞬移卷轴'] = { h_name = '순간 이동 주문서(귀속)', price = 800 },
                ['蓝色攻速灵药'] = { h_name = '돌격의 영약(귀속)', price = 800 },
            },
        },
        ['武器商人'] = {
            npc_pos = { x = 111201.00, y = 72027.00, z = 19208.21 , map_id = 301 },
            transfer_id = 0x1614C1,
            name = '단테',
            class_name = 'Role_EquipmentStore_C',
        },
        ['仓库管理员'] = {
            npc_pos = { x = 117479.00, y = 75049.00, z = 19231.97 , map_id = 301 },
            transfer_id = 0x1614C1,
            name = '에단',
            class_name = 'Role_WareHouse_C',
        },
        ['初级技能书商人'] = {
            npc_pos = { x = 114229.00, y = 81405.00, z = 19568.71 , map_id = 301 },
            transfer_id = 0x1614C1,
            name = '루체',
            class_name = 'Role_AlchemyStore_C',
            sell_item = {
                ['主动技能书-集中攻击I'] = { h_name = '기술서 - 집중 공격 I(귀속)', price = 30000 },
                ['主动技能书-情态I'] = { h_name = '기술서 - 마음 가짐 I(귀속)', price = 30000 },
                ['主动技能书-速决I'] = { h_name = '기술서 - 속결 I(귀속)', price = 80000 },
                ['被动技能书-瞄准目标I'] = { h_name = '기술서 - 표적 노리기 I(귀속)', price = 80000 },
                ['被动技能书-危机感知I'] = { h_name = '기술서 - 위기 감지 I(귀속)', price = 80000 },
            },
        },
        ['技能书商人'] = {
            npc_pos = { x = 114965.00, y = 79131.00, z = 19458.74 , map_id = 301 },
            transfer_id = 0x1614C1,
            name = '매트',
            class_name = 'Role_SkillStore_C',
            sell_item = {
                ['主动技能书-集中攻击II'] = { h_name = '기술서 부록 - 집중 공격 II(귀속)', price = 90000 },
                ['主动技能书-情态II'] = { h_name = '기술서 부록 - 마음 가짐 II(귀속)', price = 90000 },
                ['主动技能书-轨道轰炸I'] = { h_name = '기술서 - 궤도 폭격 I(귀속)', price = 500000 },
                ['主动技能书-精准射击I'] = { h_name = '기술서 - 정밀 사격 I(귀속)', price = 500000 },
                ['主动技能书-狩猎开始I'] = { h_name = '기술서 - 사냥 개시 I(귀속)', price = 500000 },
                ['被动技能书-神宫的保佑I'] = { h_name = '기술서 - 신궁의 가호 I(귀속)', price = 500000 },
                ['被动技能书-风的召唤I'] = { h_name = '기술서 - 바람의 부름 I(귀속)', price = 500000 },
                ['主动技能书-速决II'] = { h_name = '기술서 부록 - 속결 II(귀속)', price = 750000 },
                ['被动技能书-瞄准目标II'] = { h_name = '기술서 부록 - 표적 노리기 II(귀속)', price = 750000 },
                ['被动技能书-危机感知II'] = { h_name = '기술서 부록 - 위기 감지 II(귀속)', price = 750000 },
                ['被动技能书-瞄准目标III'] = { h_name = '기술서 부록 - 표적 노리기 III(귀속)', price = 1250000 },
                ['被动技能书-危机感知III'] = { h_name = '기술서 부록 - 위기 감지 III(귀속)', price = 1250000 },
                ['主动技能书-轨道轰炸II'] = { h_name = '기술서 부록 - 궤도 폭격 II(귀속)', price = 1500000 },
                ['主动技能书-精准射击II'] = { h_name = '기술서 부록 - 정밀 사격 II(귀속)', price = 1500000 },
                ['主动技能书-狩猎开始II'] = { h_name = '기술서 부록 - 사냥 개시 II(귀속)', price = 1500000 },
                ['被动技能书-神宫的保佑II'] = { h_name = '기술서 부록 - 신궁의 가호 II(귀속)', price = 1500000 },
                ['被动技能书-风的召唤II'] = { h_name = '기술서 부록 - 바람의 부름 II(귀속)', price = 1500000 },
                ['主动技能书-轨道轰炸III'] = { h_name = '기술서 부록 - 궤도 폭격 III(귀속)', price = 2500000 },
                ['主动技能书-风暴的诗I'] = { h_name = '기술서 - 폭풍의 시 I(귀속)', price = 9000000 },
                ['被动技能书-致命一击I'] = { h_name = '기술서 - 치명적 한방 I(귀속)', price = 9000000 },
            },
        },
        ['遗物商人'] = {
            npc_pos = { x = 115776.00, y = 76668.00, z = 19250.06, map_id = 301 },
            transfer_id = 0x1614C1,
            name = '카를',
            class_name = 'Role_ArtifactStore_C',
            sell_item = {
               ['生命护身符（绿）'] = { h_name = '생명의 호신부(귀속)', price = 200000 },
            },
        },
    },

    BUY_ITEM_LIST = {
        [1] = {item_name = '主动技能书-集中攻击II', need_level = 15},
        [2] = {item_name = '主动技能书-情态II', need_level = 15},
        [3] = {item_name = '主动技能书-精准射击I', need_level = 30},
        [4] = {item_name = '主动技能书-狩猎开始I', need_level = 30},
        [5] = {item_name = '生命药水（小）'},
        [6] = {item_name = '瞬移卷轴'},
        [7] = {item_name = '蓝色攻速灵药'},
        [8] = {item_name = '生命护身符（绿）'},



        -- shop_ent.buy_item('生命药水（小）')
        --    local buy_book_list = shop_res.BUY_BOOK_LIST
        --    local my_level = actor_unit.local_player_level()
        --
        --    for i = 1, #buy_book_list do
        --        local skill_book_name = buy_book_list[i].book_name
        --        local need_level = buy_book_list[i].need_level
        --        if need_level and my_level > need_level then
        --            shop_ent.buy_item(skill_book_name)
        --        elseif not need_level then
        --            shop_ent.buy_item(skill_book_name)
        --        end
        --    end
        --
        --
        --    shop_ent.buy_item('瞬移卷轴') -- 순간 이동 주문서(귀속)
        --    shop_ent.buy_item('蓝色攻速灵药') -- 순간 이동 주문서(귀속)
        --    shop_ent.buy_item('生命护身符（绿）')
    },
    -- 购买商城物品列表
    BUY_CASH_LIST = {
        ['武器强化卷'] = { level = 30, h_name = '무기 강화 주문서' },
        ['防具强化卷'] = { level = 30, h_name = '방어구 강화 주문서' },
        ['武器外观召唤I'] = { level = 20, h_name = '미명의 무기 외형 소환 I', },
        ['武器外观召唤II'] = { level = 30, h_name = '미명의 무기 외형 소환 II' },
        ['武器外观召唤III'] = { level = 40, h_name = '미명의 무기 외형 소환 III' },
        ['坐骑召唤I'] = { level = 20, h_name = '미명의 탈것 소환 I' },
        ['坐骑召唤II'] = { level = 30, h_name = '미명의 탈것 소환 II' },
        ['坐骑召唤III'] = { level = 40, h_name = '미명의 탈것 소환 III' },
        ['绿色防御灵药'] = { level = 8, h_name = '파수의 영약' },
    },
}

local this = shop_res

-------------------------------------------------------------------------------------
-- 返回对象
return shop_res

-------------------------------------------------------------------------------------