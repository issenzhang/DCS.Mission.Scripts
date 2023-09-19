-- TFM_TRAINZONE 类是一个用于控制飞行训练区域的Lua脚本类。
-- 该类主要用于创建和管理一个战术训练区域，包括飞机的生成、敌人的生成和训练任务的管理。
-- 它包含一系列参数、变量和函数，用于配置和控制训练区域的行为。
-- 该类的主要功能是根据配置生成敌人，管理训练任务，以及处理相关事件。它可以用于模拟飞行训练和训练区域的控制。
-- 注意: 默认的参数适用于tfm-acm模式的训练.
--      可以通过参数调整来实现类似如BVR巡逻或其他模式的训练.
-- 参数包括：
--   - IsDebugMessage：是否显示调试消息。
--   - TimerStep：计时器步长。
--   - IsSpawnEmeny：是否生成敌人。
--   - IsEndlessMode：是否启用无限模式，即无限生成敌人。
--   - MaxTrainWavesFinished：最大训练波数。
--   - IsSmartSpawn：是否启用智能生成敌人的功能。
--   - TableEnemyTemplate：敌人模板列表。
--   - TableSpawnAlt：生成敌人的高度列表。
--   - TableSpawnBRA：生成敌人的方向列表。
--   - SpawnDistance_At180：冷启动时的生成距离。
--   - SpawnDistance_At0：热启动时的生成距离。
--   - SpawnDistance_K：生成距离系数。
--   - SpawnDelayMin：生成敌人的最小延迟时间。
--   - SpawnDelayMax：生成敌人的最大延迟时间。
--   - EnemyDestoryDelay：敌人销毁延迟时间。
--   - EnemyEmissionOpenDelay：敌人开启雷达的延迟时间。
--   - OutboundMaxDuration：出界最大持续时间。
-- 变量包括：
--   - GroupTrain：训练飞机组。
--   - GroupEnemy：敌人飞机组。
--   - TimerTraining：训练计时器。
--   - TrainWavesFinished：已完成的训练波数。
--   - SpawnTicker：生成敌人的计时器。0
--   - SpawnTickerTrigger：生成敌人的计时触发值。
--   - OutboundTicker：出界计时器。
-- 主要函数包括：
--   - ShowMessage：显示消息。
--   - New：创建一个新的训练区域。
--   - Status：检查训练区域的状态。
--   - SpawnEnemy：生成敌人。
--   - OnEnterIdle：进入空闲状态时的处理。
--   - OnEnterTraining：进入训练状态时的处理。
--   - OnBeforeEnemySpawn：生成敌人前的处理。
--   - OnBeforeAbortOrFinish：终止或完成训练前的处理。
--   - OnEventHit：处理被命中事件。
--   - AllKilled：处理全部敌人被击落事件。
--   - OnEventCrash：处理飞机坠毁事件。
--   - GetRandomTableElement：从列表中随机选择一个元素。
-- 请注意：该注释提供了对类的总体了解，具体的函数实现和逻辑需要查看代码来理解。
--
-- The TFM_TRAINZONE class is a Lua script class used for controlling a flight training zone.
-- This class is primarily used to create and manage a training zone, including aircraft spawning, enemy generation, and training task management.
-- It includes a range of parameters, variables, and functions for configuring and controlling the behavior of the training zone.
-- Parameters include:
--   - IsDebugMessage: Whether to display debug messages.
--   - TimerStep: Timer step.
--   - IsSpawnEmeny: Whether to spawn enemies.
--   - IsEndlessMode: Whether to enable endless mode, which means continuously spawning enemies.
--   - MaxTrainWavesFinished: Maximum number of training waves.
--   - IsSmartSpawn: Whether to enable the intelligent enemy spawning feature.
--   - TableEnemyTemplate: List of enemy templates.
--   - TableSpawnAlt: List of altitudes for enemy spawning.
--   - TableSpawnBRA: List of directions for enemy spawning.
--   - SpawnDistance_At180: Spawn distance when cold-started.
--   - SpawnDistance_At0: Spawn distance when hot-started.
--   - SpawnDistance_K: Spawn distance coefficient.
--   - SpawnDelayMin: Minimum delay for enemy spawning.
--   - SpawnDelayMax: Maximum delay for enemy spawning.
--   - EnemyDestoryDelay: Delay for enemy destruction.
--   - EnemyEmissionOpenDelay: Delay for enemy radar activation.
--   - OutboundMaxDuration: Maximum duration for outbounding.
-- Variables include:
--   - GroupTrain: Training aircraft group.
--   - GroupEnemy: Enemy aircraft group.
--   - TimerTraining: Training timer.
--   - TrainWavesFinished: Number of completed training waves.
--   - SpawnTicker: Timer for enemy spawning.
--   - SpawnTickerTrigger: Trigger value for enemy spawning timer.
--   - OutboundTicker: Timer for outbounding.
-- Key functions include:
--   - ShowMessage: Display a message.
--   - New: Create a new training zone.
--   - Status: Check the status of the training zone.
--   - SpawnEnemy: Generate enemies.
--   - OnEnterIdle: Handling when entering the idle state.
--   - OnEnterTraining: Handling when entering the training state.
--   - OnBeforeEnemySpawn: Pre-handling before enemy spawning.
--   - OnBeforeAbortOrFinish: Pre-handling before aborting or finishing training.
--   - OnEventHit: Handle hit events.
--   - AllKilled: Handle events when all enemies are killed.
--   - OnEventCrash: Handle aircraft crash events.
--   - GetRandomTableElement: Randomly select an element from a list.
-- Please note that this comment provides a general understanding of the class, and specific function implementations and logic need to be reviewed in the code.
TFM_TRAINZONE = {
    ClassName = "TFM_TRAINZONE"
}

--- Parameters ---

TFM_TRAINZONE.IsDebugMessage = true -- 是否显示调试消息
TFM_TRAINZONE.TimerStep = 5 -- 计时器步长

-- NOTES: Default Spawn settings is for tfm-acm train
-- 注意: 默认的生成设置适用于tfm-acm模式的训练

TFM_TRAINZONE.IsSpawnEmeny = true -- 是否生成敌人
TFM_TRAINZONE.IsEndlessMode = false -- 是否无限模式
TFM_TRAINZONE.MaxTrainWavesFinished = 3 -- 最大训练波数

TFM_TRAINZONE.TableEnemyTemplate = {"enemy-f16-highvis", "enemy-f16-lowvis", "enemy-f16-lowvis-15",
                                    "enemy-f16-lowvis-30"} -- 敌人模板列表
TFM_TRAINZONE.TableSpawnAlt = {1000, 15000, 30000} -- 生成敌人的高度（米） 
TFM_TRAINZONE.TableSpawnBRA = {0, 45, 90, 120, 180} -- 生成敌人的方向（度）

TFM_TRAINZONE.IsSmartSpawn = true -- 是否智能生成(根据迎击角度改变生成距离)
TFM_TRAINZONE.SpawnDistance_At180 = 8 -- 冷启动时的生成距离
TFM_TRAINZONE.SpawnDistance_At0 = 20 -- 热启动时的生成距离
TFM_TRAINZONE.SpawnDistance_K = 0 -- 生成距离系数(标定无用,函数内重新计算)
TFM_TRAINZONE.SpawnDelayMin = 60 -- 生成敌人的最小延迟时间（秒）
TFM_TRAINZONE.SpawnDelayMax = 240 -- 生成敌人的最大延迟时间（秒）

TFM_TRAINZONE.EnemyDestoryDelay = 30 -- 敌人销毁延迟时间（秒）
TFM_TRAINZONE.EnemyEmissionOpenDelay = 30 -- 敌人开启雷达延迟时间（秒）

TFM_TRAINZONE.OutboundMaxDuration = 90 -- 出界最大持续时间（秒）

---  Parameters End---

--- values ---

TFM_TRAINZONE.GroupTrain = nil
TFM_TRAINZONE.GroupEnemy = nil

TFM_TRAINZONE.TimerTraining = nil
TFM_TRAINZONE.TrainWavesFinished = nil

TFM_TRAINZONE.SpawnTicker = 0
TFM_TRAINZONE.SpawnTickerTrigger = 0

TFM_TRAINZONE.OutboundTicker = 0

--- values end ---

--- functions ---
function TFM_TRAINZONE:ShowMessage(Message, Duration, IsClean, IsToAll, ToGroup)

    Message = Message or ""
    IsClean = IsClean or false
    IsToAll = IsToAll or false

    local msg = MESSAGE:New(self:GetState() .. Message, Duration or 15, nil, IsClean)

    if IsToAll or self.IsDebugMessage then
        msg:ToAll()
    else
        if ToGroup then
            msg:ToGroup(ToGroup)
        else
            msg:ToGroup(self.GroupTrain)
        end

    end
end

function TFM_TRAINZONE:New(ZoneName)
    local self = BASE:Inherit(self, FSM:New())

    self.ZoneTraining = ZONE:New(ZoneName)

    self.TrainWavesFinished = 0

    -- register FSM

    self:SetStartState("ZoneClearUp")

    self:AddTransition("Idle", "EnterZone", "Training")
    self:AddTransition("Training", "EnemySpawn", "ThreatSpawned")

    self:AddTransition("Training", "Outbound", "Outbounded")
    self:AddTransition("Outbounded", "ReturnZone", "Training")

    self:AddTransition("ThreatSpawned", "EnemyDisarm", "Training")
    self:AddTransition({"Training", "ThreatSpawned", "Outbounded"}, "AbortOrFinish", "ZoneClearUp")
    self:AddTransition("ZoneClearUp", "ZoneClear", "Idle")

    self.TimerTraining = TIMER:New(function()
        self:Status()
    end):Start(0, 5)

    -- register Event
    self:HandleEvent(EVENTS.Hit)
    self:HandleEvent(EVENTS.Crash)

    return self
end

function TFM_TRAINZONE:Status()

    if self:Is("Idle") then
        local groups = SET_GROUP:New():FilterCoalitions("blue"):FilterCategoryAirplane()
            :FilterZones({self.ZoneTraining}):FilterOnce():GetSetObjects()

        if groups then
            for _, group in ipairs(groups) do
                local countAlive = group:CountAliveUnits()
                local isInZone = group:IsCompletelyInZone(self.ZoneTraining)
                if countAlive >= 1 and isInZone then
                    -- 双机群组countAlive=1 不知道为什么
                    -- start training                    
                    self.GroupTrain = group
                    self:EnterZone()

                    -- reset train waves
                    self.TrainWavesFinished = 0

                else
                    self:ShowMessage("导演部: 机队必须同时进入该空域, 才能启动训练" ..
                                         tostring(countAlive) .. "//" .. tostring(isInZone), nil, nil, nil, group)
                end
            end
        end
    end

    if self:Is("Training") or self:Is("ThreatSpawned") or self:Is("Outbounded") then
        -- local isAllInZone = self.GroupTrain:IsCompletelyInZone(self.ZoneTraining)
        local isNotAliveCount = self.GroupTrain:CountAliveUnits()
        if isNotAliveCount == 0 then
            self:ShowMessage("导演部: 你机队出界或者人数不足,训练终止.")
            self:AbortOrFinish()
        end
    end

    if self:Is("Training") then

        -- check outbound
        local isAllInZone = self.GroupTrain:IsCompletelyInZone(self.ZoneTraining)
        if isAllInZone == false then
            self:Outbound()
        end

        -- spawn enemy
        if self.IsSpawnEmeny then
            self.SpawnTicker = self.SpawnTicker + self.TimerStep
            if (self.SpawnTicker >= self.SpawnTickerTrigger) then
                self.SpawnTicker = 0
                self:EnemySpawn()
            end
        end
    end

    if self:Is("Outbounded") then
        local isAllInZone = self.GroupTrain:IsCompletelyInZone(self.ZoneTraining)
        if isAllInZone == true then
            self:ReturnZone()
        else
            self.OutboundTicker = self.OutboundTicker + self.TimerStep
            if self.OutboundTicker > self.OutboundMaxDuration then
                self:ShowMessage("导演部: 你机队出界时间超时,训练终止.")
                self:AbortOrFinish()
            else
                self:ShowMessage("导演部: 你机队已经出界,尽快返回训练区域.\n剩余时间:" ..
                                     tostring(self.OutboundMaxDuration - self.OutboundTicker) .. "s.")
            end
        end
    end

    -- bug:妈的 isalive一直是false, 黑人问号脸, 弃用
    -- -- enemy check    
    -- if self:Is("ThreatSpawned") then
    --     if self.GroupEnemy then
    --         if not self.GroupEnemy:IsAlive() then
    --             env.info(self.GroupEnemy.GroupName)
    --             env.info(self.GroupEnemy:IsAlive())
    --             env.info("All kill cause 0")
    --             self:AllKilled()
    --         end
    --     else
    --         env.info("All kill cause None")
    --         self:AllKilled()
    --     end
    -- end

    -- check cleanup
    if self:Is("ZoneClearUp") then
        local count = SET_GROUP:New():FilterCoalitions("blue"):FilterCategoryAirplane():FilterZones({self.ZoneTraining})
            :FilterOnce():CountAlive()
        if count == 0 then
            self:ZoneClear()
        else
            self:ShowMessage("导演部: " .. self.ZoneTraining:GetName() ..
                                 " 空域尚未清空, 所有机组请先退出该空域.", nil, false, true)
        end
    end

    return self
end

function TFM_TRAINZONE:SpawnEnemy()
    -- ref
    -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Wrapper.Group.html
    -- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Core.Spawn.html    

    -- do spawm enemy parameters
    -- bug:无法通过alt_spawn控制生成飞机的高度,只能通过飞机模板来控制
    local bra_degree = 0
    local distance_spawn = 8
    local alt_spawn = GetRandomTableElement(self.TableSpawnAlt)
    local type_spawn = GetRandomTableElement(self.TableEnemyTemplate)

    if self.IsSmartSpawn then
        bra_degree = GetRandomTableElement(self.TableSpawnBRA)
        if math.random(2) == 1 then
            local bra_degree = 360 - bra_degree
        end
        local k_distance = (self.SpawnDistance_At0 - self.SpawnDistance_At180) / 180
        distance_spawn = self.SpawnDistance_At180 + math.abs(bra_degree - 180) * k_distance
        local zoneSpawn = ZONE_UNIT:New("spawn", self.GroupTrain:GetUnits()[1], 10, {
            rho = distance_spawn * 1800,
            theta = bra_degree,
            relative_to_unit = true
        })
        local pos_group = self.GroupTrain:GetCoordinate()
        local pos_zone = zoneSpawn:GetCoordinate()
        local heading_spawn = pos_zone:HeadingTo(pos_group)

        self.GroupEnemy = SPAWN:New(type_spawn):InitHeading(heading_spawn):InitSkill("Excellent"):SpawnInZone(zoneSpawn,
            alt_spawn, alt_spawn + 1000)

        env.info("Enemy Spawned:" .. type_spawn .. "/" .. tostring(distance_spawn) .. "/@" ..
                     tostring(bra_degree .. "km/alt:" .. tostring(alt_spawn)))
    else
        self.GroupEnemy = SPAWN:New(type_spawn):InitSkill("Excellent"):SpawnInZone(self.ZoneTraining, true, 12000)
    end

    -- delay enemy radar open
    if self.EnemyEmissionOpenDelay > 0 then
        self.GroupEnemy:EnableEmission(false)
        local timer_emssion = TIMER:New(function()
            self.GroupEnemy:EnableEmission(true)
        end):Start(self.EnemyEmissionOpenDelay)
    end

    -- register crash event
    self.GroupEnemy:HandleEvent(EVENTS.Crash, function()
        self:ShowMessage("GoodKill~ GoodKill~")
        self.TrainWavesFinished = self.TrainWavesFinished + 1
        if self.IsEndlessMode or self.TrainWavesFinished < self.MaxTrainWavesFinished then
            self:EnemyDisarm()
        elseif self.TrainWavesFinished >= self.MaxTrainWavesFinished then
            self:ShowMessage("你机队已经完成训练.")
            self:AbortOrFinish()
        end
    end)
    --
    -- add task
    self.GroupEnemy:TaskAttackGroup(self.GroupTrain)
    -- self.GroupEnemy:PushTask()
end

function TFM_TRAINZONE:OnEnterIdle(From, Event, To)
    self:ShowMessage("导演部: " .. self.ZoneTraining:GetName() .. " 净空, 可以进入机组训练", nil, false,
        true)
    self.ZoneTraining:DrawZone(-1, {0, 1, 0}, 0.8, nil, nil, 1, false)
    return true
end

function TFM_TRAINZONE:OnEnterTraining(From, Event, To)

    self.ZoneTraining:DrawZone(-1, {1, 0, 0}, 0.8, nil, nil, 1, false)

    -- set train group Immortal
    self.GroupTrain:SetCommandImmortal(true)
    local msg = ""
    if self.TrainWavesFinished == 0 then
        msg = "导演部: 训练开始. .." .. tostring(self.TrainWavesFinished)
    else
        msg = "导演部: 训练继续. .." .. tostring(self.TrainWavesFinished)
    end

    self:ShowMessage(msg)

    -- set enemy spawn countdown
    -- 太菜 用不来异步方法 废弃
    -- self:__EnemySpawn(math.random(self.SpawnDelayMin, self.SpawnDelayMax))
    if self.IsSpawnEmeny then
        self.SpawnTicker = 0
        self.SpawnTickerTrigger = math.random(self.SpawnDelayMin, self.SpawnDelayMax)
    end

    return true
end

function TFM_TRAINZONE:OnBeforeEnemySpawn(From, Event, To)

    self:SpawnEnemy()

    return true
end

function TFM_TRAINZONE:OnBeforeAbortOrFinish(From, Event, To)
    self:ShowMessage("退出训练空域以重置训练, 或直接返回机场")

    if self.GroupEnemy then
        env.info("ta_train: do enemy Destroy")
        self.GroupEnemy:Destroy(false, self.EnemyDestoryDelay)
    end

    -- do some cleanup
    self.TrainWavesFinished = 0
    self.GroupTrain:SetCommandImmortal(false)
    self.GroupTrain = nil

    return true
end

function TFM_TRAINZONE:OnEventHit(EventData)
    if self:Is("Training") or self:Is("ThreatSpawned") then
        if self.GroupTrain then
            local group = EventData.TgtGroup
            if group.GroupName == self.GroupTrain.GroupName then
                self:ShowMessage("导演部: 你机队被命中,训练终止.")
                self:AbortOrFinish()
            end
        end
    end
end

function TFM_TRAINZONE:AllKilled()
    self:ShowMessage("GoodKill~ GoodKill~")
    self.TrainWavesFinished = self.TrainWavesFinished + 1
    if self.IsEndlessMode or self.TrainWavesFinished < self.MaxTrainWavesFinished then
        -- continue spawn
        self.GroupEnemy = nil
        self:EnemyDisarm()
    elseif self.TrainWavesFinished >= self.MaxTrainWavesFinished then
        self:ShowMessage("导演部: 恭喜,你机队已经完成训练.")
        self:AbortOrFinish()
    end
end

function TFM_TRAINZONE:OnEventCrash(EventData)
    env.info("==CRASH EVENT==")
    env.info("ini group:" .. EventData.IniGroup.GroupName)
    env.info("tgt group:" .. EventData.TgtGroup.GroupName)
    --    if self:Is("ThreatSpawned") then
    --        if self.GroupEnemy then
    --            local group = EventData.TgtGroup
    --            if group.GroupName == self.GroupEnemy.GroupName then
    --                self:ShowMessage("GoodKill~ GoodKill~")
    --                self.TrainWavesFinished = self.TrainWavesFinished + 1
    --                if self.IsEndlessMode or self.TrainWavesFinished < self.MaxTrainWavesFinished then
    --                    self.GroupEnemy = nil
    --                    self:EnemyDisarm()
    --                elseif self.TrainWavesFinished >= self.MaxTrainWavesFinished then
    --                    self:ShowMessage("你机队已经完成训练.")
    --                    self:AbortOrFinish()
    --                end
    --            end
    --        end
    --    end
end

function GetRandomTableElement(table)
    math.random()
    math.random()
    math.random()

    return table[math.random(#table)]
end

