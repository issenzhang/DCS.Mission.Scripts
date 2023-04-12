--#region AAR 自动生成
local AAR_Temp_130 = "AAR_Tecxo"
local AAR_Temp_135 = "AAR_Arco"

local Num_TACAN = 1

local AAR_List_Type =
{
    ['F/A-18'] = AAR_Temp_130,
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

GROUP_AAR_Active = SET_GROUP:New()

function AAR_Check()
    local group_aar = SET_GROUP:New():FilterActive():FilterCategoryAirplane():FilterZones():FilterOnce()
        :ForEachGroupPartlyInZone(
            function(GroupObject)
                if GROUP_AAR_Active:IsNotInSet(GroupObject) then
                    local typeName = GroupObject:GetTypeName()
                    local aar = SPAWN:New(AAR_List_Type[typeName]):Spawn()

                    aar:CommandSetCallsign(AAR_List_Callsign[AAR_List_Type[typeName]],
                        AAR_List_Callsign_Num[AAR_List_Type[typeName]])
                    aar:CommandActivateBeacon(
                        BEACON.Type.TACAN,
                        BEACON.System.TACAN_TANKER_X,
                        Num_TACAN,
                        "X",
                        nil,
                        nil
                    )
                    AAR_List_Callsign_Num[AAR_List_Type[typeName]] = AAR_List_Callsign_Num[AAR_List_Type[typeName]] + 1
                    Num_TACAN = Num_TACAN + 1
                end
            end
        )
end

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
