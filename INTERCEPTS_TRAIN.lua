INTERCEPTS_TRAIN = {
    ClassName = "INTERCEPTS_TRAIN"
}

INTERCEPTS_TRAIN.TableEnemyTemplate = {}
INTERCEPTS_TRAIN.SpawnDelayMin = 60 -- 生成敌人的最小延迟时间（秒）
INTERCEPTS_TRAIN.SpawnDelayMax = 240 -- 生成敌人的最大延迟时间（秒）
INTERCEPTS_TRAIN.SpawnDelayMin = 60 -- 生成敌人的最小延迟时间（秒）

function INTERCEPTS_TRAIN:New(CenterZoneName, SpawnZoneName)
    local self = BASE:Inherit(self, FSM:New())

    self.ZoneTraining = ZONE:New(ZoneName)

    self.TrainWavesFinished = 0

    -- register FSM

    self.TimerTraining = TIMER:New(function()
        self:Status()
    end):Start(0, 5)

    -- register Event
    self:HandleEvent(EVENTS.Hit)
    self:HandleEvent(EVENTS.Crash)

    return self
end

INTERCEPTS_TRAIN_GROUP = {
    ClassName = "INTERCEPTS_TRAIN"
}

INTERCEPTS_TRAIN_GROUP.Group = nil
INTERCEPTS_TRAIN_GROUP.Enemy = nil
INTERCEPTS_TRAIN_GROUP.TimerTraining = nil

INTERCEPTS_TRAIN_GROUP.TickerIntercept = 0
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
        local isIntercepted = false
        local units = 
        

    end
end
