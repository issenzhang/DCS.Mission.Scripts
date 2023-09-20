INTERCEPTS_TRAIN = {
    ClassName = "INTERCEPTS_TRAIN"
}

INTERCEPTS_TRAIN.TableEnemyTemplate = {}
INTERCEPTS_TRAIN.SpawnDelayMin = 60 -- 生成敌人的最小延迟时间（秒）
INTERCEPTS_TRAIN.SpawnDelayMax = 240 -- 生成敌人的最大延迟时间（秒）
INTERCEPTS_TRAIN.SpawnDelayMin = 60 -- 生成敌人的最小延迟时间（秒）

INTERCEPTS_TRAIN.InterceptDuration = 120
INTERCEPTS_TRAIN.ZoneSpawnEnemy = nil
INTERCEPTS_TRAIN.ZoneTrainTrigger = nil

INTERCEPTS_TRAIN.GroupSetInTrain = nil

function INTERCEPTS_TRAIN:New(CenterZoneName, SpawnZoneName)
    local self = BASE:Inherit(self, FSM:New())

    self.ZoneTrainTrigger = ZONE:New(CenterZoneName)
    self.ZoneSpawnEnemy = ZONE:New(SpawnZoneName)

    self.GroupSetInTrain = SET_GROUP:New()

    self.TimerTraining = TIMER:New(function()
        self:Status()
    end):Start(0, 3)

    return self
end

function INTERCEPTS_TRAIN:Status()
    if self:Is("Idle") then
        local groups = SET_GROUP:New():FilterCoalitions("blue"):FilterCategoryAirplane():FilterZones(
            {self.ZoneTrainTrigger}):FilterOnce():GetSetObjects()

        if groups then
            for _, group in ipairs(groups) do
                if self.GroupSetInTrain:IsNotInSet(group) then
                    -- add group into set(and remove it for register again)
                    self.GroupSetInTrain:AddGroup(group)
                    TIMER:New(function()
                        self.GroupSetInTrain:RemoveGroupsByName(group:GetName())
                    end):Start(360)

                    INTERCEPTS_TRAIN_GROUP:New(group,self)
                end
            end
        end
    end
end

INTERCEPTS_TRAIN_GROUP = {
    ClassName = "INTERCEPTS_TRAIN"
}

INTERCEPTS_TRAIN_GROUP.Group = nil
INTERCEPTS_TRAIN_GROUP.Enemy = nil
INTERCEPTS_TRAIN_GROUP.TimerTraining = nil
INTERCEPTS_TRAIN_GROUP.TimerMsg = nil

INTERCEPTS_TRAIN_GROUP.TickerIntercepted = 0
INTERCEPTS_TRAIN_GROUP.TickerMsg = 0
INTERCEPTS_TRAIN_GROUP.TickerSinceSpawned = 0

INTERCEPTS_TRAIN_GROUP.SpawnTicker = 0
INTERCEPTS_TRAIN_GROUP.SpawnTickerTrigger = 0

function INTERCEPTS_TRAIN_GROUP:New(Group, InterceptTrain)
    local self = BASE:Inherit(self, FSM:New())

    self.Group = Group
    self.Train = InterceptTrain

    -- register FSM
    self:SetStartState("Registered")

    self:AddTransition("Registered", "EnemySpawn", "ThreatSpawned")

    self:AddTransition("ThreatSpawned", "Success", "Stopped")

    self:AddTransition("*", "KnockItOff", "Stopped")
    -- end

    self.SpawnTickerTrigger = math.random(self.Train.SpawnDelayMin, self.Train.SpawnDelayMax)
    self.TimerTraining = TIMER:New(function()
        self:Status()
    end):Start(0, 1)    
end

function INTERCEPTS_TRAIN_GROUP:Status()
    if self.Is("Registered") then
        if self.SpawnTicker >= self.SpawnTickerTrigger then
            self:EnemySpawn()
        else
            self.SpawnTicker = self.SpawnTicker + 1
        end
    end

    if self.Is("ThreatSpawned") then
        local isIntercepted = true
        local offset_left = HELPER.MakeOffset(50, 90)
        local offset_right = HELPER.MakeOffset(50, 270)
        local enemyName = self.Enemy:GetName()
        local zb_Left = ZONEBOX_UNIT:New(enemyName .. "-left", self.Enemy, 75, offset_left, 500 / 3, -500 / 3)
        local zb_Right = ZONEBOX_UNIT:New(enemyName .. "-right", self.Enemy, 75, offset_right, 500 / 3, -500 / 3)

        local units = self.Group:GetUnits()
        if units then
            for _, unit in pairs(units) do
                if zb_Left:IsUnitInBox(unit) == false and zb_Right:IsUnitInBox(unit) == false then
                    isIntercepted = false
                end
            end
        end

        local msg = ""
        if isIntercepted then
            self.TickerIntercepted = self.TickerIntercepted + 1
            if self.TickerMsg >= 20 then
                self.TickerMsg = 0
                msg = "你机组已拦截该目标, 保持伴飞并汇报目标类型."
                HELPER.MessageToGroup(self.Group, msg, 10)
            else
                self.TickerMsg = self.TickerMsg + 1
            end

            if self.TickerIntercepted >= self.Train.InterceptDuration then
                self:Success()
            end
        else
            if self.TickerMsg >= 50 then
                self.TickerMsg = 0
                msg = "拦截目标方位:\n" ..
                          self.Enemy:GetCoordinate()
                        :ToStringBULLS(coalition.side.BLUE, SETTINGS:New():IsImperial(), true) ..
                          "\n尽快前出拦截."
                HELPER.MessageToGroup(self.Group, msg, 30)
            else
                self.TickerMsg = self.TickerMsg + 1
            end
        end

        self.TickerSinceSpawned = self.TickerSinceSpawned + 1
        if self.TickerSinceSpawned - self.TickerIntercepted >= 300 then
            HELPER.MessageToGroup(self.Group, "拦截伴飞超时, 本次训练失败")
            self:KnockItOff()
        end
    end
end

function INTERCEPTS_TRAIN_GROUP:OnBeforeEnemySpawn(From, Event, To)
    local template = HELPER.GetRandomTableElement(self.Train.TableEnemyTemplate)
    self.Enemy = SPAWN:NewWithAlias(template .. "vs" .. self.Group:GetName()):SpawnInZone(self.Train.ZoneSpawnEnemy,
        true)
    return true
end

function INTERCEPTS_TRAIN_GROUP:OnBeforeSuccess(From, Event, To)
    HELPER.MessageToGroup(self.Group, "你机队完成本波次拦截训练,返回Hold点重新建立巡逻航线", 60)
    HELPER.MessageToGroup(self.Group, "本次拦截训练总用时:" .. self.TickerIntercepted, 60)
    self.Enemy:Explode(20)
    return true
end

function INTERCEPTS_TRAIN_GROUP:OnBeforeKnockItOff(From, Event, To)
    HELPER.MessageToGroup(self.Group, "本波次拦截训练失败,返回Hold点重新建立巡逻航线", 60)
    self.Enemy:Explode(20)
    return true
end

function INTERCEPTS_TRAIN_GROUP:OnEnterStopped(From, Event, To)
    self.TimerTraining:Stop()
    return true
end
