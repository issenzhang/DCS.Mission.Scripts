-- by 39102/Issen
-- issen.zhang@outlook.com

_SETTINGS:SetPlayerMenuOff()

local COALITION =
{
    BLUE = coalition.side.BLUE,
    RED = coalition.side.RED,
    NEUTRAL = coalition.side.NEUTRAL,
}

--由1~x中生成n个互不重复的随机数
function GenerateRandomUniqueNumbers(n, x)
    local numbers = {}
    for i = 1, x do
        table.insert(numbers, i)
    end

    local result = {}
    for i = 1, n do
        local index = math.random(i, #numbers)
        result[i] = numbers[index]
        numbers[index] = numbers[i]
    end
    return result
end

-- 返回目标相对于靶眼的位置
local function reportGroupPosVsBull(_group, _coalition)
    if _coalition ~= nil then
        return _group:GetCoordinate():ToStringBULLS(_coalition, nil, true) ..
            ", Height: " .. math.ceil(_group:GetAltitude(false)) .. "m"
    else
        return _group:GetCoordinate():ToStringBULLS(coalition.side.BLUE, nil, true) ..
            ", Height: " .. math.ceil(_group:GetAltitude(false)) .. "m"
    end
end

-- 返回群组相对于坐标点的位置
-- local function reportGroupPosVsPoint(_group, _point, _point_name)
--     if _group ~= nil and _point ~= nil then
--         local pos = _group:GetCoordinate()
--         local ang = pos:GetAngleRadians(_point)
--         MESSAGE:New("消息展示" .. ang .. "-" .. pos:GetAngleRadians(_point) .. "-" .. pos:GetAngleDegrees(_point), 60)
--             :ToAll()
--         local dis = UTILS.Round(pos:Get2DDistance(_point), 2)
--         local tgt_height = UTILS.Round(_group:GetAltitude(false), 2)
--         return "目标方位信息: 相对方位 " .. ang .. "°(真航向), 相对距离 " ..
--             dis .. " m, 海拔高度: " .. tgt_height .. " m\n"
--             --       .. reportGroupPosVsBull(_group, COALITION.BLUE)
--             --       .. "\n"
--             .. pos:ToStringFromRP(_point, "TGT1")
--     end
-- end

-- 返回群组相对于坐标点的位置
local function reportGroupPosVsPoint(_group, _point, _point_name)
    if _group ~= nil and _point ~= nil then
        local pos = _group:GetCoordinate()
        local ang = pos:GetAngleRadians(_point)
        local dis = pos:Get2DDistance(_point)
        local tgt_height = _group:GetAltitude(false)
        --      return pos:ToStringFromRP(_point, "TGT1")
        --          .. " m, 海拔高度: " .. tgt_height .. " m"
        --          .. " 精确距离：" .. math.ceil(dis) .. " m"

        return "目标相对" .. _point_name .. "信息:\n" ..
            "相对方位：" .. string.format("%0.1f", UTILS.Round(_point:HeadingTo(pos), 1)) .. " °(真航向) " ..
            "相对距离：" .. string.format("%0.2f", UTILS.Round(dis / 1000, 2)) .. " km " ..
            "高度：" .. string.format("%0.2f", UTILS.Round(tgt_height, 2)) .. "m"
    end
end

-- #region tgt1相关
local TGT1_NUM = 1
local TGT1_ZONE_NAME = "TGT1_CENTER"
local TGT1_ZONES_CHECK =
{
    "TGT1_CENTER",
    "TGT1_WEST",
    "TGT1_EAST",
}

local TGT1_posWord =
{
    [1] = "西侧",
    [2] = "东侧",
}

local TGT1_typeWord =
{
    [1] = "步兵战车 BTR-82A",
    [2] = "自行火炮 2S19",
    [3] = "主战坦克 T-90",
    [4] = "地地导弹 飞毛腿9P117",
    [5] = "老乡の小卡车 改装车-LC",
    [6] = "多管火箭炮 飓风9K57",
    [7] = "步兵战车 BMP-3",
}

-- 作弊:无线电提示tgt1的剩余目标情况
local function reportTgt1(_coalition)
    local SETGROUP_TGT1 = SET_GROUP:New()
        :FilterPrefixes("tgt1")
        :FilterActive(true)
        :FilterCategoryGround()
        :FilterOnce()

    local msg = ""
    local groups_tgt1 = SETGROUP_TGT1:GetSetObjects()
    env.info("---- tgt1:" .. #groups_tgt1)

    if #groups_tgt1 > 0 then
        msg = "当前TGT1共有" .. #groups_tgt1 .. "目标存活\n"
        for i, v in ipairs(groups_tgt1) do
            local pos = v:GetCoordinate()
            msg = msg .. "#" .. i .. ":" .. pos:ToStringLLDDM() .. "\n  "
                .. math.ceil(pos:GetLandHeight()) .. "Unit: Meter\n"
        end
    else
        msg = "无存活的TGT1目标"
    end
    MESSAGE:New(msg, 60):ToAll()
end

local function flareGroups(_groups)
    for _, g in ipairs(_groups) do
        g:FlareWhite()
    end
end

-- 作弊:所有tgt1目标放1min的Flare
local function flareTgt1(_coalition)
    local SETGROUP_TGT1 = SET_GROUP:New()
        :FilterPrefixes("tgt1")
        :FilterActive(true)
        :FilterCategoryGround()
        :FilterOnce()

    local msg = ""
    local groups_tgt1 = SETGROUP_TGT1:GetSetObjects()
    env.info("---- tgt1:" .. #groups_tgt1)

    if #groups_tgt1 > 0 then
        msg = "当前TGT1共有" .. #groups_tgt1 .. "目标存活,开始打上花火2分钟.\n"
        t = TIMER:New(flareGroups, groups_tgt1)
        t:Start(0, 1, 120)
    else
        msg = "无存活的TGT1目标"
    end
    MESSAGE:New(msg, 60):ToAll()
end

-- 提示有小组进入TGT1范围
-- function checkTgt1_ZoneCenter_5s()
--     local zone = ZONE:New(TGT1_ZONE_NAME)
--     if TGT1_ZONE_CHECK == true then
--         for i, group in ipairs(SET_GROUP:New():FilterCategoryAirplane():FilterCoalition("blue"):FilterActive():FilterOnce():GetAliveSet()) do
--             if group.IsPartlyOrCompletelyInZone(zone) then
--                 local group_name = group.GetName()
--                 MESSAGE:New("小组: " .. group_name .. " 进入TGT1-5nm范围",2):ToAll()
--             end
--         end
--     end
-- end

SET_GROUP:AddGroupsByName(AddGroupNames)

-- 提示有小组进入城镇(TGT1中心/东侧/西侧)范围
local function checKTgt1_AllZones_5s()
    local sg = SET_GROUP:New()
        :FilterActive()
        :FilterCategoryAirplane()
        :FilterOnce()

    gs = sg:GetSetObjects()
    if #gs > 0 then
        for _, group in pairs(gs) do
            for _, z in pairs(TGT1_ZONES_CHECK) do
                if group:IsPartlyOrCompletelyInZone(ZONE:New(z)) then
                    MESSAGE:New("Info: 小组: " .. group:GetName() .. "位于区域: " .. z .. " 内", 4):ToAll()
                end
            end
        end
    end
end

local function spawnTgt1(_zoneNum) -- 1-西侧:对应一组 2-东侧:对应二组
    local temp_rand = GenerateRandomUniqueNumbers(1, 7)[1]
    local rand_zones = GenerateRandomUniqueNumbers(2, 20)

    local sg = {}

    for i, v in ipairs(rand_zones) do
        local zoneName = "z-tgt1-" .. _zoneNum .. "-" .. v
        local spawnZone = ZONE:New(zoneName)

        local spawnTgt2 = SPAWN
            :NewWithAlias("tgp-" .. temp_rand, "tgt1-" .. _zoneNum .. "#" .. i)
            :InitLimit(2, 2)
            :InitHeading(0, 359)

        local g = spawnTgt2:SpawnInZone(spawnZone)

        env.info("#" .. i .. ":spawn in zone" .. zoneName .. "")

        sg[i] = g
        TGT1_NUM = TGT1_NUM + 1
    end

    local msg = ""
    msg = "已在TGT点" .. TGT1_posWord[_zoneNum] .. "城镇内,生成2个目标.\n"
        .. "目标类型:" .. TGT1_typeWord[temp_rand] .. "\n"
        .. "请使用吊舱检索目标,并通过无线电进行汇报\n"
        .. "特别注意:申请打击目标前,禁止接近TGT点5海里内范围.否则考核失败."
    MESSAGE:New(msg, 60):ToAll()
    -- env.info("sg num: " .. #sg)

    MESSAGE:New("目标方位信息(相对于TGT1点)", 60):ToAll()
    for i2, _g in ipairs(sg) do
        local g_msg = reportGroupPosVsPoint(_g, ZONE:New(TGT1_ZONE_NAME):GetCoordinate(), "TGT1")
        env.info("#" .. i2 .. "-" .. g_msg)
        MESSAGE:New("#" .. i2 .. ":" .. g_msg, 120):ToAll()
    end
end

--#endregion

--#region 低空飞行段
-- 低空段参数
local LOWFILGHT_HEIGHT_THRESHOLD = 121.90  --低空飞行段的限高
local LOWFILGHT_OVERTIME_THRESHOLD = 30 --低空飞行段的累计超高时长

local LOWFILGHT_ZONENAME_IN = "lowlevel-start"
local LOWFILGHT_ZONENAME_CHECK = "lowlevel"
local LOWFILGHT_ZONENAME_EXIT = "lowlevel-end"

-- 监控的低空飞行的群组
local TABLE_GROUP_ONLOWFLY = {}
-- 低空飞行群组的超高计时器
local TABLE_LOWFLIGHT_OVERHEIGHT_DURATION = {}

local GS_GROUP_OnLowFly = SET_GROUP:New()

--检查是否进入目标区域
local function checkGroupIntoLowFlightArea_1s()
    local zone = ZONE:New(LOWFILGHT_ZONENAME_IN)
    local group_set = SET_GROUP:New():FilterCategoryAirplane():FilterActive():FilterZones({ zone }):FilterOnce()
    local groups = group_set:GetSetObjects()

    env.info("Into Area -------------=>" .. #groups)

    if #groups > 0 then
        for _, _group in ipairs(groups) do
            if _group ~= nil and UTILS.IsInTable(GS_GROUP_OnLowFly:GetSetObjects(), _group) == false then
                local group_name = _group:GetName()
                local msg = "提示：" .. group_name .. "小组进入低空飞行区"

                MESSAGE:New(msg, 30):ToAll()

                --向检测清单中追加检测群组
                GS_GROUP_OnLowFly:AddGroup(_group)

                --计时器初始化
                if TABLE_LOWFLIGHT_OVERHEIGHT_DURATION[group_name] == nil
                    or type(TABLE_LOWFLIGHT_OVERHEIGHT_DURATION[group_name]) ~= "table" then
                    TABLE_LOWFLIGHT_OVERHEIGHT_DURATION[group_name] = {}
                end
                local units = _group:GetUnits()
                for i_unit = 1, #units do
                    TABLE_LOWFLIGHT_OVERHEIGHT_DURATION[group_name][i_unit] = 0
                end
            end
        end
    end
end

--检查是否离开目标区域
local function checkGroupExitLowFlightArea_1s()
    local zone = ZONE:New(LOWFILGHT_ZONENAME_EXIT)
    local group_set = SET_GROUP:New():FilterCategoryAirplane():FilterZones({ zone }):FilterActive():FilterOnce()
    local groups = group_set:GetSetObjects()

    for _, _group in ipairs(groups) do
        if UTILS.IsAnyInTable(GS_GROUP_OnLowFly:GetSetObjects(), { _group }) == true then
            local name_group = _group:GetName()
            local msg = name_group .. "离开低空飞行区，成绩通报："
            MESSAGE:New(msg, 60):ToAll()

            -- 通报各机超时成绩
            for i, unit in ipairs(_group:GetUnits()) do
                msg = msg ..
                    "#" .. i ..
                    " " .. unit:GetName() .. " 超时累计: " ..
                    TABLE_LOWFLIGHT_OVERHEIGHT_DURATION[name_group][i] .. " sec\n"
            end
            MESSAGE:New(msg, 120):ToAll()

            --向检测清单中移除检测群组
            GS_GROUP_OnLowFly:RemoveGroupsByName(name_group)
        end
    end
end

-- 高度检查,每秒执行一次
local function checkGroupLowFlightAreaHeight_1s()
    for i, group in ipairs(GS_GROUP_OnLowFly:GetSetObjects()) do
        local duration = 0
        local name_group = group:GetName()

        if group ~= nil then
            local units = group:GetUnits()
            for i_unit, unit in ipairs(units) do
                if unit ~= nil then
                    local username = ""
                    if unit:IsPlayer() == true then
                        username = unit:GetPlayerName()
                    else
                        username = ""
                    end

                    local unit_alt = unit:GetAltitude(true)
                    --MESSAGE:New(unit:GetName() .. math.ceil(unit_alt), 1):ToAll()
                    if unit_alt > LOWFILGHT_HEIGHT_THRESHOLD then
                        local msg_notice = unit:GetName() ..
                            "|" .. username .. " - " .. TABLE_LOWFLIGHT_OVERHEIGHT_DURATION[name_group]
                            [i_unit]
                        env.info(msg_notice)
                        if TABLE_LOWFLIGHT_OVERHEIGHT_DURATION[name_group][i_unit] == nil then
                            TABLE_LOWFLIGHT_OVERHEIGHT_DURATION[name_group][i_unit] = 0
                        else
                            TABLE_LOWFLIGHT_OVERHEIGHT_DURATION[name_group][i_unit] = TABLE_LOWFLIGHT_OVERHEIGHT_DURATION
                                [name_group]
                                [i_unit] + 1
                            duration = duration + TABLE_LOWFLIGHT_OVERHEIGHT_DURATION[name_group][i_unit]
                            MESSAGE:New("警告：\n" ..
                                group:GetName() .. "-" .. username .. "-" .. unit:GetName() .. "正在超高", 1.0)
                                :ToAll()
                        end
                    end
                end
            end

            if duration > LOWFILGHT_OVERTIME_THRESHOLD then --检查小组整体超时是否大于要求值
                local msg = name_group .. "低空飞行段超高时长大于30s,考试不合格，成绩通报：\n"
                -- 通报各机超时情况
                for i_unit = 1, #units do
                    msg = msg ..
                        "#" .. i ..
                        " " .. units[i]:GetName() .. " 超时累计:" ..
                        TABLE_LOWFLIGHT_OVERHEIGHT_DURATION[name_group][i_unit] .. "sec"
                end
                MESSAGE:New(msg, 120):ToAll()

                --检测清单中移除已不合格的检测群组
                GS_GROUP_OnLowFly:RemoveGroupsByName(name_group)
            end
        end
    end
end
--#endregion

--#region tgt3 rocket
local TGT3_NUM = 1
local function spawnTgt3()
    local SpawnZone = ZONE:New("zone-tgt3")
    local spawn_tgt3_1 = SPAWN:NewWithAlias("temp_tgt3", "tgt3-" .. TGT3_NUM .. "-1")
    local spawn_tgt3_2 = SPAWN:NewWithAlias("temp_tgt3", "tgt3-" .. TGT3_NUM .. "-2")

    local tgt3_1 = spawn_tgt3_1:SpawnInZone(SpawnZone, true)
    local tgt3_2 = spawn_tgt3_2:SpawnInZone(SpawnZone, true)

    MESSAGE:New("#" .. TGT3_NUM .. " 迫击炮小组坐标:", 90):ToBlue()

    local tgt3_1_pos = tgt3_1:GetCoordinate():ToStringLLDDM() ..
        "|" .. math.ceil(tgt3_1:GetCoordinate():GetLandHeight()) .. " m"
    local tgt3_2_pos = tgt3_2:GetCoordinate():ToStringLLDDM() ..
        "|" .. math.ceil(tgt3_2:GetCoordinate():GetLandHeight()) .. " m"

    MESSAGE:New(tgt3_1_pos, 90):ToAll()
    MESSAGE:New(tgt3_2_pos, 90):ToAll()
    MESSAGE:New("要求2组摧毁时间差，不超过30秒", 60):ToAll()

    TGT3_NUM = TGT3_NUM + 1
end
--#endregion

--#region 练习目标
local PRATICE_GROUPS =
{
    TANK = "temp-practice-tank",
    CARGO = "temp-practice-cargo",
}

local function respawnPracticeTarget(_group_name, _alias)
    if _alias == nil then
        SPAWN
            :New(_group_name)
            :InitRandomizePosition(true, 30, 100)
            :Spawn()
    else
        SPAWN
            :NewWithAlias(_group_name, _alias)
            :InitRandomizePosition(true, 30, 100)
            :Spawn()
    end
end

local function reportPracticeTargetAlive(_group_name)
    local _g = GROUP:FindByName(_group_name)
    local msg = ""
    if _g ~= nil then
        msg = _group_name .. " 共有" .. #_g:CountAliveUnits() .. " 个单位存活."
    else
        msg = "未找到该群组, 可能已经被摧毁"
    end
end

local function respawnPracticeRocket()
    local SpawnZone = ZONE:New("zone-practice3")
    local spawn_tgt3_1 = SPAWN:NewWithAlias("temp_tgt3", "p-tgt3-1")
    local spawn_tgt3_2 = SPAWN:NewWithAlias("temp_tgt3", "p-tgt3-2")

    local tgt3_1 = spawn_tgt3_1:SpawnInZone(SpawnZone, true)
    local tgt3_2 = spawn_tgt3_2:SpawnInZone(SpawnZone, true)

    MESSAGE:New("#" .. TGT3_NUM .. " 迫击炮小组坐标:", 90):ToBlue()

    local tgt3_1_pos = tgt3_1:GetCoordinate():ToStringLLDDM() .. "|" .. tgt3_1:GetLandHeight() .. " m"
    local tgt3_2_pos = tgt3_2:GetCoordinate():ToStringLLDDM() .. "|" .. tgt3_2:GetLandHeight() .. " m"

    MESSAGE:New(tgt3_1_pos, 90):ToAll()
    MESSAGE:New(tgt3_2_pos, 90):ToAll()
    MESSAGE:New("要求2组摧毁时间差,不超过30秒", 60):ToAll()
end

--#endregion

--注册Menu
local MenuTgt1 = MENU_COALITION:New(coalition.side.BLUE, "TGT1(吊舱检索)")
local MenuTgt1Spawn_1 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "激活西侧城镇内目标", MenuTgt1,
    spawnTgt1, 1)
local MenuTgt1Spawn_2 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "激活东侧城镇内目标", MenuTgt1,
    spawnTgt1, 2)
-- local MenuTgt1Spawn_2 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "申请进入目标区域,实施打击", MenuTgt1, disableTgt1ZoneCheck, nil)
local MenuTgt1Report = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "作弊: 提供TGT1目标坐标", MenuTgt1,
    reportTgt1, nil)
local MenuTgt1Flare = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "作弊: 提供TGT1信号弹指引", MenuTgt1,
    flareTgt1, nil)

local MenuTgt2 = MENU_COALITION:New(coalition.side.BLUE, "TGT2(集束炸弹)")
local MenuTgt2Report = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "通报炸弹攻击情况", MenuTgt2,
    function()
        local g_tgt2_1 = GROUP:FindByName("tgt2-1")
        local g_tgt2_2 = GROUP:FindByName("tgt2-2")

        local function report(_group)
            if _group ~= nil then
                return _group:GetName() .. ":有 " .. _group:CountAliveUnits() .. " 个单位存活."
            else
                return _group:GetName() .. "不存在,或已经完全摧毁"
            end
        end
        MESSAGE:New(report(g_tgt2_1) .. "\n" .. report(g_tgt2_2), 30):ToAll()
    end
    , nil)

local MenuTgt3 = MENU_COALITION:New(coalition.side.BLUE, "TGT3(火箭弹目标)")
local MenuTgt3Spawn = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "生成2组迫击炮阵地", MenuTgt3, spawnTgt3,
    nil)

local MenuPractice = MENU_COALITION:New(coalition.side.BLUE, "对地练习")
local MenuPractice_Tank = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "重置坦克（CCIP练习）", MenuPractice,
    respawnPracticeTarget,
    PRATICE_GROUPS.TANK)
local MenuPractice_Cargo = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "重置车队（集束炸弹）", MenuPractice,
    respawnPracticeTarget,
    PRATICE_GROUPS.CARGO)

local MenuPractice_Cargo_Report = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "通报车队存活情况",
    MenuPractice,
    function(_c)
        local _gs = SET_GROUP:New()
            :FilterPrefixes("temp-practice-cargo")
            :FilterActive(true)
            :FilterCategoryGround()
            :FilterOnce()

        local gs = _gs:GetSetObjects()
        local _g = gs[1]

        local msg = ""
        if _g == nil then
            msg = "不存在练习车队，或已经完全摧毁"
        else
            msg = "车队当前存活车辆数：" .. _g:CountAliveUnits() .. " 辆"
        end
        MESSAGE:New(msg, 30):ToAll()
    end, {}
)

local MenuPractice_Practice3 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "生成2组迫击炮阵地", MenuPractice,
    respawnPracticeRocket, nil)
--注册监控事件
TIMER:New(checKTgt1_AllZones_5s):Start(1, 5)

TIMER:New(checkGroupIntoLowFlightArea_1s):Start(1, 1)
TIMER:New(checkGroupExitLowFlightArea_1s):Start(1, 1)
TIMER:New(checkGroupLowFlightAreaHeight_1s):Start(1, 1)
