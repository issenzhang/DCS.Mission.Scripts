TAC_ACM_TRAINZONE = {
    ClassName = "TAC_ACM_TRAINZONE"
}

--- Parameters ---

-- group_name(weapon)/heading/distance/speed

-- todo:confirm template name
TAC_ACM_TRAINZONE.EnemyTemplateName = "EnemyTemplate"

TAC_ACM_TRAINZONE.TableSpawnAlt = {
    ["low"] = 1000 / 3,
    ["med"] = 15000 / 3,
    ["high"] = 30000 / 3
}

TAC_ACM_TRAINZONE.TableSpawnBRA = {
    -- [type name] = {left_angle},right_angle}
    ["hot"] = {0, 0},
    ["flank"] = {45, 360 - 45},
    ["beam"] = {90, 360 - 90},
    ["drag"] = {120, 360 - 120}
    -- ["cold"] = {180, 180}
}

-- spawn distance = abs(spawn_bra-180) * SpawnDistance_K + SpawnDistance_At180
TAC_ACM_TRAINZONE.SpawnDistance_At180 = 10
TAC_ACM_TRAINZONE.SpawnDistance_K = (20 - TAC_ACM_TRAINZONE.SpawnDistance_At180) / 180

TAC_ACM_TRAINZONE.SpawnDelayMin = 60
TAC_ACM_TRAINZONE.SpawnDelayMax = 180

TAC_ACM_TRAINZONE.MaxTrainWaves = 3
TAC_ACM_TRAINZONE.EnemyDestoryDelay = 30

TAC_ACM_TRAINZONE.EnemyEmissionOpenDelay = 30

---  Parameters End---

--- values ---

TAC_ACM_TRAINZONE.GroupTrain = nil
TAC_ACM_TRAINZONE.GroupEnemy = nil

TAC_ACM_TRAINZONE.TimerTraining = nil
TAC_ACM_TRAINZONE.TrainWaves = nil

--- values end ---

--- functions ---
function TAC_ACM_TRAINZONE:ShowMessage(Message, Duration, isClean, isToAll, ToGroup)
    local msg = MESSAGE:New(Message, Duration or 15, nil, true)

    if isToAll or false then
        if ToGroup then
            msg:ToGroup(ToGroup)
        else
            msg:ToGroup(self.GroupTrain)
        end
    else
        msg:ToAll()
    end
end

function TAC_ACM_TRAINZONE:New(ZoneName)
    local self = BASE:Inherit(self, FSM:New())

    self.ZoneTraining = ZONE:New(ZoneName)

    self.TrainWaves = 0

    self:SetStartState("Idle")

    self:AddTransition("Idle", "TrainStart", "Training")
    self:AddTransition("Training", "EnemySpawn", "Threat")
    self:AddTransition("Threat", "KillEnemy", "Training")

    self:AddTransition({"Training", "Threat"}, "KnockItOff", "Finishing")
    self:AddTransition("*", "Complate", "Finishing")

    self:AddTransition("Finishing", "ZoneClear", "Idle")

    self.TimerTraining = TIMER:New(function()
        self:Status()
    end):Start(0, 5)

    return self
end

function TAC_ACM_TRAINZONE:Status()

    if self.Is("Idle") then
        local groups = SET_GROUP:New():FilterCoalitions("blue"):FilterCategoryAirplane()
            :FilterZones({self.ZoneTraining}):FilterOnce():GetSetObjects()

        if groups then
            for _, group in ipairs(groups) do
                if not group:CountAliveUnits() == 2 then
                    self:ShowMessage("导演部: 你机队数量不满足条件,无法启动训练", nil, nil, nil,
                        group)
                elseif not group:IsCompletelyInZone(self.ZoneTraining) then
                    self:ShowMessage("导演部: 你机队未完全进入训练空域, 无法启动训练", nil, nil,
                        nil, group)
                else
                    -- start training                    
                    self.GroupTrain = group
                    self:TrainStart()
                    -- reset train waves
                    self.TrainWaves = 0

                    -- register hit event
                    self.GroupTrain:HandleEvent(EVENTS.Hit, function()
                        self:ShowMessage("导演部: 你机队被命中,训练终止.")
                        self:KnockItOff()
                    end)
                end
            end
        end
    end

    if self.Is("Training") or self.Is("EnemySpawn") then
        if not self.GroupTrain.IsCompletelyInZone(self.ZoneTraining) then
            self:ShowMessage("导演部: 你机队出界,训练终止.")
            self:KnockItOff()
        end
    end

    if self.Is("Finishing") then
        local count = SET_GROUP:New():FilterCoalitions("blue"):FilterCategoryAirplane():FilterZones({self.ZoneTraining})
            :FilterOnce():CountAlive()
        if count == 0 then
            self:ShowMessage("导演部: " .. self.ZoneTraining:GetName() .. " 净空, 可以进入机组训练", false,
                true)
            self:ZoneClear()
            else
                self:ShowMessage("导演部: " .. self.ZoneTraining:GetName() .. " 空域尚未清空, 所有机组请先退出该空域.", false,
                true)
        end
    end

    return self
end

function TAC_ACM_TRAINZONE:OnEnterTraining(From, Event, To)

    -- set train group Immortal
    self:SetCommandImmortal(true)

    if self.TrainWaves > self.MaxTrainWaves then
        self:ShowMessage("导演部: 你机队已经完成训练任务.")
        self:SetCommandImmortal(false)
        self:Complate()
    else
        self:ShowMessage("导演部: 训练开始/继续.敌机将会刷新,注意保持瞭望.")
        self.TrainWaves = self.TrainWaves + 1
        self:EnemySpawn(math.random(self.SpawnDelayMin, self.SpawnDelayMax))
    end

    return true
end

function TAC_ACM_TRAINZONE:OnBeforeEnemySpawn(From, Event, To)

    -- ref
    -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Wrapper.Group.html
    -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Core.Spawn.html    

    local bra_spawn = UTILS.GetRandomTableElement(UTILS.GetRandomTableElement(self.TableSpawnBRA))
    local distance_spawn = self.SpawnDistance_At180 + math.abs(bra_spawn - 180) * self.SpawnDistance_K
    local alt_spawn = UTILS.GetRandomTableElement(self.TableSpawnAlt)

    local zoneSpawn = ZONE_UNIT:New("spawn", self.GroupTrain:GetUnits()[1], 10, {
        rho = distance_spawn,
        theta = bra_spawn,
        relative_to_unit = true
    })

    local pos_group = self.GroupTrain:GetCoordinate()
    local pos_zone = zoneSpawn:GetCoordinate()
    local heading_spawn = pos_zone:HeadingTo(pos_group)

    self.GroupEnemy = SPAWN:New("TEMPLATE"):InitHeading(heading_spawn):InitSkill("Excellent"):SpawnInZone(zoneSpawn,
        alt_spawn, alt_spawn + 500)

    -- add task
    self.GroupEnemy:TaskAttackGroup(self.GroupTrain)

    -- delay radar open
    if self.EnemyEmissionOpenDelay >0 then 
        self.GroupEnemy:EnableEmission(false)
        local timer_emssion = TIMER:New(function ()
            self.GroupEnemy:EnableEmission(true)            
        end):Start(self.EnemyEmissionOpenDelay)
    end    

    self.GroupEnemy:HandleEvent(EVENTS.Kill, function()
        self:ShowMessage("GoodKill~")
        self:KillEnemy()
    end)

    return true
end

function TAC_ACM_TRAINZONE:OnBeforeKnockItOff(From, Event, To)

    self:ShowMessage("退出训练空域重置, 或直接返回机场")
    self:SetCommandImmortal(false)
    if self.GroupEnemy then
        self.GroupEnemy:Destroy(false, self.EnemyDestoryDelay)
    end

    return true
end

