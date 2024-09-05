------------------------------------------------------------------------------------
-- game/resources/map_res.lua
--
-- @module      map_res
-- @author      admin
-- @license     MIT
-- @release     v1.0.0 - 2023-03-22
-- @copyright   2023
-- @usage
-- local map_res = import('game/resources/map_res')
------------------------------------------------------------------------------------
local actor_unit = actor_unit
local pairs      = pairs
---@class map_res
local map_res    = {
    MAP_NAME_LIST = {
        ['첼라노 마을'] = { map_id = 301 ,main_id = 3 ,c_map_name = '切拉诺村' },
        ['경외의 바윗길'] = { map_id = 302 ,main_id = 3 ,c_map_name = '切拉诺村' }, --36级
        ['청빈의 경사로'] = { map_id = 303 ,main_id = 3 ,c_map_name = '切拉诺村' }, --36级
        ['알레인 고지대'] = { map_id = 304 ,main_id = 3 ,c_map_name = '切拉诺村' }, --39级
        ['회색이끼 군락'] = { map_id = 305 ,main_id = 3 ,c_map_name = '切拉诺村' }, --39级
        ['순례자 협곡'] = { map_id = 306 ,main_id = 3 ,c_map_name = '切拉诺村' }, --41级
        ['성긴뿌리 언덕'] = { map_id = 307 ,main_id = 3 ,c_map_name = '切拉诺村' }, --41级
        ['쓸쓸한 무덤가'] = { map_id = 308 ,main_id = 3 ,c_map_name = '切拉诺村' }, --43级
        ['앙상가지 벌판'] = { map_id = 309 ,main_id = 3 ,c_map_name = '切拉诺村' }, --43级
        ['무릎바위 언덕'] = { map_id = 310 ,main_id = 3 ,c_map_name = '切拉诺村' }, --56级
        ['무릎바위 구릉지'] = { map_id = 311 ,main_id = 3 ,c_map_name = '切拉诺村' }, --56级
        ['자락풀 초원'] = { map_id = 312 ,main_id = 3 ,c_map_name = '切拉诺村' }, --57级
        ['알레인 저지대'] = { map_id = 313 ,main_id = 3 ,c_map_name = '切拉诺村' }, --57级
        ['바위벽 협로'] = { map_id = 314 ,main_id = 3 ,c_map_name = '切拉诺村' }, --58级
        ['질퍽이는 가도'] = { map_id = 315 ,main_id = 3 ,c_map_name = '切拉诺村' }, --58级
        ['스카니나 돌무리'] = { map_id = 316 ,main_id = 3 ,c_map_name = '切拉诺村' }, --59级
        ['알레인 봉우리'] = { map_id = 317 ,main_id = 3 ,c_map_name = '切拉诺村' }, --59级
        ['칼날바람 황무지'] = { map_id = 318 ,main_id = 3 ,c_map_name = '切拉诺村' }, --60级
        ['스카니나 정상'] = { map_id = 319 ,main_id = 3 ,c_map_name = '切拉诺村' }, --60级
        ['공허한 앞뜰'] = { map_id = 320 ,main_id = 3 ,c_map_name = '切拉诺村' }, --61级
        ['코모 수도원 터'] = { map_id = 321 ,main_id = 3 ,c_map_name = '切拉诺村' }, --61级
        ['산코나 유적 입구'] = { map_id = 322 ,main_id = 3 ,c_map_name = '切拉诺村' },
        ['앙상가지 비행장'] = { map_id = 324 ,main_id = 3 ,c_map_name = '切拉诺村' },
        ['칼날바람 비행장'] = { map_id = 325 ,main_id = 3 ,c_map_name = '切拉诺村' },
        ['알레인 비행장'] = { map_id = 326 ,main_id = 3 ,c_map_name = '切拉诺村' },
        ['성긴뿌리 비행장'] = { map_id = 327 ,main_id = 3 ,c_map_name = '切拉诺村' },
        ['코모 비행장'] = { map_id = 328 ,main_id = 3 ,c_map_name = '切拉诺村' },
        ['무릎바위 비행장'] = { map_id = 329 ,main_id = 3 ,c_map_name = '切拉诺村' },
        ['바위벽 비행장'] = { map_id = 330 ,main_id = 3 ,c_map_name = '切拉诺村' },
        ['스카니나 비행장'] = { map_id = 331 ,main_id = 3 ,c_map_name = '切拉诺村' },

        ['바스티움 마을'] = { map_id = 201 ,main_id = 2 ,c_map_name = '切拉诺村' },
        ['바위절벽 길목'] = { map_id = 202 ,main_id = 2 ,c_map_name = '切拉诺村' }, --30级
        ['콜리아 기슭'] = { map_id = 203 ,main_id = 2 ,c_map_name = '切拉诺村' }, --30级
        ['쇠락한 공터'] = { map_id = 204 ,main_id = 2 ,c_map_name = '切拉诺村' }, --31级
        ['키큰숲 목초지'] = { map_id = 205 ,main_id = 2 ,c_map_name = '切拉诺村' }, --31级
        ['콜리아 삼거리'] = { map_id = 206 ,main_id = 2 ,c_map_name = '切拉诺村' }, -- 32级
        ['마른땅 벌목지'] = { map_id = 207 ,main_id = 2 ,c_map_name = '切拉诺村' }, -- 32级
        ['실바인 진흙탕'] = { map_id = 208 ,main_id = 2 ,c_map_name = '切拉诺村' }, --34级
        ['실바인 저수지'] = { map_id = 209 ,main_id = 2 ,c_map_name = '切拉诺村' }, --34级
        ['뙤약볕 벌목지'] = { map_id = 210 ,main_id = 2 ,c_map_name = '切拉诺村' }, --45级
        ['젖은발 숲길'] = { map_id = 211 ,main_id = 2 ,c_map_name = '切拉诺村' }, --45级
        ['메아리 폭포'] = { map_id = 212 ,main_id = 2 ,c_map_name = '切拉诺村' },
        ['힐난의 오크 점령지'] = { map_id = 213 ,main_id = 2 ,c_map_name = '切拉诺村' },
        ['산들바람 나뭇길'] = { map_id = 214 ,main_id = 2 ,c_map_name = '切拉诺村' },
        ['파도소리 평야'] = { map_id = 215 ,main_id = 2 ,c_map_name = '切拉诺村' },
        ['이를레타 신전 입구'] = { map_id = 216 ,main_id = 2 ,c_map_name = '切拉诺村' },
        ['바위절벽 비행장'] = { map_id = 217 ,main_id = 2 ,c_map_name = '切拉诺村' },
        ['키큰숲 비행장'] = { map_id = 218 ,main_id = 2 ,c_map_name = '切拉诺村' },
        ['콜리아 비행장'] = { map_id = 219 ,main_id = 2 ,c_map_name = '切拉诺村' },
        ['실바인 비행장'] = { map_id = 220 ,main_id = 2 ,c_map_name = '切拉诺村' },
        ['파도평야 비행장'] = { map_id = 221 ,main_id = 2 ,c_map_name = '切拉诺村' },

        ['아빌리우스 성채'] = { map_id = 101 ,main_id = 1 ,c_map_name = '阿比利乌斯城堡' },
        ['바람소리 언덕'] = { map_id = 102 ,main_id = 1 ,c_map_name = '风声小山坡' },
        ['신록의 호수'] = { map_id = 103 ,main_id = 1 ,c_map_name = '新绿之湖' },
        ['네르바드 비탈'] = { map_id = 104 ,main_id = 1 ,c_map_name = '内巴比妥' },
        ['네르바드 가도'] = { map_id = 105 ,main_id = 1 ,c_map_name = '涅尔巴德' },
        ['네르바드 신전 터'] = { map_id = 106 ,main_id = 1 ,c_map_name = '内巴德神殿' },
        ['몬테노 폐허'] = { map_id = 107 ,main_id = 1 ,c_map_name = '蒙特诺废墟' },
        ['성자의 장원'] = { map_id = 108 ,main_id = 1 ,c_map_name = '圣子的庄园' },
        ['풍요의 들판'] = { map_id = 109 ,main_id = 1 ,c_map_name = '富饶的原野' },
        ['몬테노 강줄기'] = { map_id = 110 ,main_id = 1 ,c_map_name = '蒙特诺河' },
        ['몬테노 범람지'] = { map_id = 111 ,main_id = 1 ,c_map_name = '蒙特诺泛滥成灾' },
        ['오염된 신전 터'] = { map_id = 112 ,main_id = 1 ,c_map_name = '被污染的神殿' },
        ['파괴된 옛 성터'] = { map_id = 113 ,main_id = 1 ,c_map_name = '被破坏的旧城' },
        ['바람소리 비행장'] = { map_id = 114 ,main_id = 1 ,c_map_name = '风声机场' },
        ['바람언덕 비행장'] = { map_id = 115 ,main_id = 1 ,c_map_name = '风坡机场' },
        ['신전 터 비행장'] = { map_id = 116 ,main_id = 1 ,c_map_name = '新神殿机场' },
        ['몬테노 비행장'] = { map_id = 117 ,main_id = 1 ,c_map_name = '蒙特诺机场' },
        ['옛 성터 비행장'] = { map_id = 118 ,main_id = 1 ,c_map_name = '旧城机场' },
    },
    MAIM_MAP_LIST = {
        [1] = { map_id = 1, map_h_name = '第一大陆', map_h_name = '아빌리우스 성채', },
        [2] = { map_id = 2, map_h_name = '第二大陆', map_h_name = '바스티움 마을' },
        [3] = { map_id = 3, map_h_name = '第三大陆', map_h_name = '첼라노 마을' },
    },

}

-- 自身模块
local this = map_res

-------------------------------------------------------------------------------------
-- 通过地图名获取据点名
map_res.get_stronghold_name = function(map_name)
    local stronghold_name = ''
    if map_res.MAP_NAME_LIST[map_name] then
        local map_id = map_res.MAP_NAME_LIST[map_name].map_id
        if map_id then
            if map_id >= 300 then
                stronghold_name = '첼라노 마을'
            elseif map_id >= 200 then
                stronghold_name = '바스티움 마을'
            elseif map_id >= 100 then
                stronghold_name = '아빌리우스 성채'
            end
        end
    end
    return stronghold_name
end

-------------------------------------------------------------------------------------
-- 获取地图ID对应大陆ID
map_res.get_main_id_by_map_id = function(map_id)
    for k,v in pairs(this.MAP_NAME_LIST) do
        if v.map_id == map_id then
            return v.main_id,k
        end
    end
    return 0,0
end

-------------------------------------------------------------------------------------
-- 判断是否在剧情地图
map_res.is_in_scene_map = function()
    local main_map_id = actor_unit.main_map_id()
    if main_map_id > 3 then
        return true
    end
    return  false
end

-------------------------------------------------------------------------------------
-- 返回实例对象
-- 
-- @export
return map_res

-------------------------------------------------------------------------------------