ACM_TRAIN_ZONE = {
    ClassName = "ZONEBOX_UNIT"
}

--- CLASS Parameter ---

-- group_name(weapon)/heading/distance/speed
ACM_TRAIN_ZONE.TableTemplateEmeny = {}

ACM_TRAIN_ZONE.WaveDefeated = 0

ACM_TRAIN_ZONE.MaxTrainWaves = 3
ACM_TRAIN_ZONE.SpawnDelayMin = 30
ACM_TRAIN_ZONE.SpawnDelayMax = 120

ACM_TRAIN_ZONE.EmenyDestoryDelay = 30

--- CLASS Parameter End---

--- values ---

ACM_TRAIN_ZONE.GroupTrain = nil

ACM_TRAIN_ZONE.GroupEmeny = nil

ACM_TRAIN_ZONE.TimerTraining = nil

ACM_TRAIN_ZONE.TrainWaves = nil

--- values end ---

--- functions ---
function ACM_TRAIN_ZONE:ShowMessage(Message, Duration, isClean, isToAll)
    local msg = MESSAGE:New(Message, Duration or 15, nil, true)

    if isToAll or false then
        msg:ToGroup(self.GroupTrain)
    else
        msg:ToAll()
    end
end

function ACM_TRAIN_ZONE:New(ZoneName)
    local self = BASE:Inherit(self, FSM:New())

    self.ZoneTraining = ZONE:New(ZoneName)

    self:SetStartState("Idle")

    self:AddTransition("Idle", "TrainStart", "Training")
    self:AddTransition("Training", "EmenySpawn", "Threat")
    self:AddTransition("Threat", "KillEmeny", "Training")

    self:AddTransition({"Training", "Threat"}, "KnockItOff", "Finishing")
    self:AddTransition("*", "Complate", "Finishing")

    self:AddTransition("Finishing", "ZoneClear", "Idle")

    self.TimerTraining = TIMER:New(function()
        self:Status()
    end)

    return self
end

function ACM_TRAIN_ZONE:Status()

    if self.Is("Idle") then
        local groups = SET_GROUP:New():FilterCoalitions("blue"):FilterCategoryAirplane()
            :FilterZones({self.ZoneTraining}):FilterOnce():GetSetObjects()

        if groups then

            for _, group in ipairs(groups) do
                if group:CountAliveUnits() == 2 and group:IsCompletelyInZone(self.ZoneTraining) then
                    self.GroupTrain = group
                    self:TrainStart()
                    self.GroupTrain:HandleEvent(EVENTS.Hit, function()
                        self:ShowMessage("导演部: 你机队被命中,训练终止.")
                        self:KnockItOff()
                    end)
                end
            end

        end
    end

    if self.Is("Training") or self.Is("EmenySpawn") then
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
        end
    end

end

function ACM_TRAIN_ZONE:OnEnterTraining(From, Event, To)

    if self.TrainWaves > self.MaxTrainWaves then
        self:ShowMessage("导演部: 你机队已经完成训练任务.")
        self:Complate()
    else
        self:ShowMessage("导演部: 训练开始/继续.敌机将会刷新,注意保持瞭望.")
        self.TrainWaves = self.TrainWaves + 1
        self.EmenySpawn(math.random(self.SpawnDelayMin, self.SpawnDelayMax))
    end

    return true
end

function ACM_TRAIN_ZONE:OnBeforeEmenySpawn(From, Event, To)
    -- todo: Repalce "TEMPLATE"
    self.GroupEmeny = SPAWN:New("TEMPLATE"):Spawn()

    -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Wrapper.Group.html
    -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Core.Spawn.html

    -- SPAWN:InitGroupHeading(HeadingMin, HeadingMax, unitVar)
    -- SPAWN:InitSkill(Skill)
    --

    self.GroupEmeny:HandleEvent(EVENTS.Kill, function()
        self:ShowMessage("GoodKill~")
        self:KillEmeny()
    end)

    return true
end

function ACM_TRAIN_ZONE:OnBeforeKnockItOff(From, Event, To)

    self:ShowMessage("退出该训练空域, 或直接返回机场")
    if self.GroupEmeny then
        self.GroupEmeny:Destroy(false, self.EmenyDestoryDelay)
    end

    return true
end
