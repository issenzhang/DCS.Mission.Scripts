--#region 常用脚本
local function AppendString(string, toappend)
    return string .. toappend + "\n"
end

local function MessageToAll(msg_text, duration)
    MESSAGE:New(msg_text, duration or 60):ToAll()

    USERSOUND:New("radio click.ogg"):ToAll()
end
--#endregion

--#region AAR 自动生成
local AAR_Temp_130 = "AAR_Tecxo"
local AAR_Temp_135 = "AAR_Arco"

local Num_TACAN = 1

local AAR_List_Type =
{
    ['F/A-18'] = AAR_Temp_130,
}

local AAR_List_Callsign_Name =
{
    ['AAR_Tecxo'] = "Tecxo", --Tecxo
    ['AAR_Arco'] = "Arco",   --Arco
}

local AAR_List_Callsign =
{
    ['AAR_Tecxo'] = 1, --Tecxo
    ['AAR_Arco'] = 2,  --Arco
}


local AAR_List_Callsign_Num =
{
    ['AAR_Tecxo'] = 1, --Tecxo
    ['AAR_Arco'] = 1,  --Arco
}

local TIME_SPAN_AAR_SPAWN = 60

local setgroup_AAR = SET_GROUP:New()
local zone_AAR_Check = ZONE:New("z-aar")
local tick_AAR_Spawn = 0

local function step_tick_aar()
    if tick_AAR_Spawn < TIME_SPAN_AAR_SPAWN then
        tick_AAR_Spawn = tick_AAR_Spawn + 1
    end
end

function SpawnAAR(_group)
    local group_name = _group:GetName()
    local typeName = _group:GetTypeName()
    BASE:E(group_name .. "|" .. typeName .. "|" .. "in zone.")
    BASE:E(group_name .. "|" .. typeName .. "|" .. "in zone.")
    if setgroup_AAR:IsNotInSet(_group) then
        -- 生成的加油机时间间隔必须大于1min
        if tick_AAR_Spawn == TIME_SPAN_AAR_SPAWN then
            local aar = SPAWN:New(AAR_List_Type[typeName]):Spawn()

            aar:CommandSetCallsign(AAR_List_Callsign[AAR_List_Type[typeName]],
                AAR_List_Callsign_Num[AAR_List_Type[typeName]])

            aar:CommandActivateBeacon(
                BEACON.Type.TACAN,
                BEACON.System.TACAN_TANKER_X,
                Num_TACAN,
                "X",
                nil,
                nil)

            setgroup_AAR:AddGroup(_group)
            TIMER:New(function()
                setgroup_AAR:RemoveGroupsByName(group_name)
            end):Start(60)

            local msg = ""
            msg = AppendString(msg, "小组" .. group_name .. ":")
            msg = AppendString(msg, "加油机将于10min后到达 3号航路点")
            msg = AppendString(msg, "加油机信息:")
            msg = AppendString(msg,
                "Callsign: " .. AAR_List_Callsign_Name[typeName] ..
                "-" .. AAR_List_Callsign_Num[AAR_List_Type[typeName]] .. "-1")
            msg = AppendString(msg, "Tacan: " .. Num_TACAN .. "X")
            MessageToAll(msg)

            AAR_List_Callsign_Num[AAR_List_Type[typeName]] = AAR_List_Callsign_Num[AAR_List_Type[typeName]] + 1
            Num_TACAN = Num_TACAN + 1
        else
            MessageToAll("小组" .. group_name ":\n  与前机组距离过近,等待1分钟后再进入2号航路点.")
        end
    else
        Base:E(_group:GetName() .. " Already in AAR Mission.")
    end
end

function Detect_Wypt2()
    local group_aar = SET_GROUP:New():FilterActive():FilterCategoryAirplane():FilterZones({ zone_AAR_Check }):FilterOnce()
        :ForEachGroupPartlyInZone(
            function(_group)
                SpawnAAR(_group)
            end
        )
end

TIMER:New(Detect_Wypt2):Start(1, 1)

--#region 靶场练习目标

local PRATICE_GROUPS =
{
    TANK = "temp-practice-tank",
    CARGO = "temp-practice-cargo",
}

local function RespawnPracticeTarget(_group_name)
    SPAWN
        :New(_group_name)
        :InitRandomizePosition(true, 30, 100)
        :Spawn()
end

local function RespawnPracticeRocket()
    local SpawnZone = ZONE:New("zone-practice3")
    local spawn_tgt3_1 = SPAWN:NewWithAlias("temp_tgt3", "p-tgt3-1")
    local spawn_tgt3_2 = SPAWN:NewWithAlias("temp_tgt3", "p-tgt3-2")

    local tgt3_1 = spawn_tgt3_1:SpawnInZone(SpawnZone, true)
    local tgt3_2 = spawn_tgt3_2:SpawnInZone(SpawnZone, true)

    MESSAGE:New("#" .. TGT3_NUM .. " 迫击炮小组坐标:", 90):ToBlue()

    tgt3_1_pos = tgt3_1:GetCoordinate():ToStringLLDMS()
    tgt3_2_pos = tgt3_2:GetCoordinate():ToStringLLDMS()

    MESSAGE:New(tgt3_1_pos, 90):ToAll()
    MESSAGE:New(tgt3_2_pos, 90):ToAll()
    MESSAGE:New("要求2组摧毁时间差，不超过30秒", 60):ToAll()
end

local MenuPractice = MENU_COALITION:New(coalition.side.BLUE, "对地练习")
local MenuPractice_Tank = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "重置坦克（CCIP练习）", MenuPractice,
    RespawnPracticeTarget,
    PRATICE_GROUPS.TANK)
local MenuPractice_Cargo = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "重置车队（集束炸弹）", MenuPractice,
    RespawnPracticeTarget,
    PRATICE_GROUPS.CARGO)

local MenuPractice_Practice3 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "生成2组迫击炮阵地", MenuPractice,
    RespawnPracticeRocket, nil)

--#endregion
