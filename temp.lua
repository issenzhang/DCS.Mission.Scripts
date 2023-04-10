

local SpawnZone = ZONE:New( "zone-tgt2" )
local spawn_tgt2 = SPAWN:New("迫击炮小组")

local tgt2_1 = spawn_tgt2:SpawnInZone(SpawnZone,true)
local tgt2_2 = spawn_tgt2:SpawnInZone(SpawnZone,true)

local MessageBLUE
MessageBLUE = MESSAGE:New("迫击炮小组坐标:",60):ToBlue()

tgt2_1_pos = tgt2_1:GetCoordinate():ToStringLLDMS()
tgt2_2_pos = tgt2_2:GetCoordinate():ToStringLLDMS()

MessageBLUE = MESSAGE:New(tgt2_1_pos,60):ToBlue()
MessageBLUE = MESSAGE:New(tgt2_2_pos,60):ToBlue()

--
maxTempNum = 7
name = "temp"..tostring(math.random(maxTempNum))

static = STATIC:FindByName(name)
pos = static:GetCoordinate()
cord = pos:ToStringLLDDM()
height = "Alt: " .. math.ceil(pos:GetLandHeight()).." Unit: Meter"

msg = "临时坐标点：\n"..cord.."\n"..height.."\n到达后，观察临时坐标点附近目标，并向考官汇报".."("..tostring(name)..")"
MessageBLUE = MESSAGE:New(msg,60):ToBlue()


--#region tgt1相关

function spawnTgt1(zoneNum) -- 1-西侧:对应一组 2-东侧:对应二组

    local temp_rand = generateRandomUniqueNumbers(1,7)
    local temp_group = GROUP:getByName("tgp-"..temp_rand)
    local spawnTgt2 =  SPAWN:NewWithAlias(temp_group,"spawn-tgt1")

    local rand_zones = generateRandomUniqueNumbers(2,20)
    for i,v in ipairs(rand_zones) do
        zoneName = "zonetgt-"..zoneNum.."-"..v
        local spawnZone = ZONE:New(zoneName)
        spawnTgt2:SpawnInZone(spawnZone)
    end

    local t_posWord =
    {
        [1]= "西侧",
        [2]= "东侧",
    }
    local t_typeWord =
    {
        [1]="步兵战车 BTR-82A",
        [2]="自行火炮 2S19",
        [3]="主战坦克 T-90",
        [4]="地地导弹 飞毛腿9P117",
        [5]="老乡の小卡车 改装车-LC",
        [6]="多管火箭炮 飓风9K57",
        [7]="步兵战车 BMP-3",
    }

    local msg =
        "已在TGT点"..t_posWord[zoneNum]..",生成目标.\n"
        .."目标类型:"..t_typeWord[temp_rand].."\n"
        .."请使用吊舱检索目标,并通过无线电进行汇报\n"
        .."特别注意:进行汇报前,禁止接近TGT点5海里内范围.否则考核失败."
    MESSAGE:New(msg,60):ToAll()
    return rand_zones
end

-- 无线电提示tgt1的剩余目标情况
function reportTgt1Pos()
    local groups_tgt2 = SET_GROUP:New():FilterPrefixes("spawn-tgt1") 
    if #groups_tgt2>0 then
        local msg = "当前TGT1共有"..#groups_tgt2.."目标存活\n"
        for i,v in ipairs(groups_tgt2) do
            msg = msg + "#"..i..":" ..v:GetCoordinate():ToStringLLDMS().."\n  "
            ..math.ceil(pos:GetLandHeight()).."Unit: Meter\b"
        end
    end
end
--#endregion

--#region 低空飞行段
LOWFILGHT_HEIGHT_THRESHOLD=400 --低空飞行段的限高
LOWFILGHT_OVERTIME_THRESHOLD=30 --低空飞行段的累计超高时长

LOWFILGHT_GROUPS={} --监控的低空飞行的群组
LOWFILGHT_OVERHEIGHT_DURATION={} --低空飞行群组的超时时长

LOWFILGHT_ZONENAME_IN = "lowlevel-start"
LOWFILGHT_ZONENAME_CHECK = "lowlevel"
LOWFILGHT_ZONENAME_EXIT= "lowlevel-end"

function checkGroupIntoLowFlightArea_1s() --检查是否进入目标区域
    local zone = ZONE:New(LOWFILGHT_ZONENAME_IN)
    for i,group in ipairs(SET_GROUP:New():FilterCategoryAirplane():FilterCoalition( "blue" ):FilterActive()) do
        if group:IsAirPlane() then
            if group.IsCompletelyInZone(zone) then
                if  checkExist(LOWFILGHT_GROUPS)==true  then
                    group_name=group.GetName()
                    msg = group_name.."进入低空飞行区"
                    MESSAGE:New(msg,60):ToAll()

                    --向检测清单中追加检测群组
                    LOWFILGHT_GROUPS[#LOWFILGHT_GROUPS+1] = group_name

                    --计时器初始化
                    local units = group:GetUnits() 
                    for i_unit=1, #units do 
                        CHECKHEIGHT_GROUPS[group_name][i_unit] = 0
                    end
                end
            end
        end
    end
end

function checkGroupExitLowFlightArea_1s() --检查是否离开目标区域
    local zone = ZONE:New(LOWFILGHT_ZONENAME_EXIT)
    for i,group in ipairs(SET_GROUP:New():FilterCategoryAirplane():FilterCoalition( "blue" ):FilterActive()) do
        if group:IsAirPlane() then
            if group.IsCompletelyInZone(zone) then
                group_name=group.GetName()
                msg = group_name.."离开低空飞行区"
                MESSAGE:New(msg,60):ToAll()

                --向检测清单中移除检测群组
                table.remove(LOWFILGHT_GROUPS, group_name)
            end
        end
    end
end

function checkGroupLowFilghtAreaHeight_1s() -- 高度检查.每秒执行一次

    for i,name_group in ipairs(LOWFILGHT_GROUPS) do

        local group = GROUP:FindByName(name_group)
        local duration = 0

        if group~=nil then
            local units = group:GetUnits()
            for i_unit=1,#units do
                if units[i_unit]:GetAltitude(true)>LOWFILGHT_HEIGHT_THRESHOLD then
                    LOWFILGHT_OVERHEIGHT_DURATION[name_group][i_unit] = LOWFILGHT_OVERHEIGHT_DURATION[name_group][i_unit]+1
                    duration = duration+LOWFILGHT_OVERHEIGHT_DURATION[name_group][i_unit]
                end
            end

            if duration>LOWFILGHT_OVERTIME_THRESHOLD then --检查小组整体超时是否大于要求值
                local msg = name_group.."低空飞行段超高时长大于30s,考试不合格\n"
                for i_unit=1,#units do
                    msg = msg.."#"..i.." "..units[i]:GetName().. "超时累计:"..LOWFILGHT_OVERHEIGHT_DURATION[name_group][i_unit].."sec"
                end
                MESSAGE:New(msg,60):ToAll()
                --向检测清单中移除检测群组
                table.remove(LOWFILGHT_GROUPS, group_name)
            end
        end
    end
end
--#endregion

--#region tgt3 rocket

function spawnTgt3()
local SpawnZone = ZONE:New( "zone-tgt3" )
local spawn_tgt3 = SPAWN:New("temp_tgt3")

local tgt3_1 = spawn_tgt3:SpawnInZone(SpawnZone,true)
local tgt3_2 = spawn_tgt3:SpawnInZone(SpawnZone,true)

MESSAGE:New("迫击炮小组坐标:",60):ToBlue()

tgt3_1_pos = tgt3_1:GetCoordinate():ToStringLLDMS()
tgt3_2_pos = tgt3_2:GetCoordinate():ToStringLLDMS()

MESSAGE:New(tgt3_1_pos,60):ToAll()
MESSAGE:New(tgt3_2_pos,60):ToAll()
end
--#endregion

function generateRandomUniqueNumbers(n, x)--由1~x中生成n个互不重复的随机数
    math.randomseed(os.time())
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

function findgroups(group_name) -- 查找匹配的群组
    table ={}
    for i,g in DATABASE.GROUPS do
        if string.find(g.GetName(),group_name) then
            table.adds(g)
        end
    end
    return table
end

function checkExist(list,element)
    for i,v in ipairs(list) do
       if v==element then
        return true
       end
    end
    return false
end