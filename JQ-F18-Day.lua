_SETTINGS:SetPlayerMenuOff()

MESSAGE:New("================\n\nloading Mission...\n\n================", 20):ToAll() -- Message for to test if script is running properly

local function AppendString(string, toappend)
    return string .. toappend + "\n"
end

local function MessageToAll(msg_text, duration)
    MESSAGE:New(msg_text, duration or 60):ToAll()

    USERSOUND:New("radio click.ogg"):ToAll()
end

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
            function(_gourp)
                if GROUP_AAR_Active:IsNotInSet(_gourp) then
                    local typeName = _gourp:GetTypeName()
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

                    GROUP_AAR_Active:AddGroup(_gourp)
                    TIMER:New(
                        function()
                            GROUP_AAR_Active:RemoveGroupsByName(_gourp)
                        end):Start(120)
                end
            end
        )
end
