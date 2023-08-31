env.info("== Load Solar Storm ==")
-- 基于MOOSE系统, 增加一种可以自定义某单位的区域
-- 计划特性
-- [ ] 自定义触发箱的空间高度
-- [ ] 基于UNIT航向的前后左右触发箱--使用ZONE_UNIT..offset特性
ZONEBOX_UNIT = {
    ClassName = "ZONEBOX_UNIT",
    AltitudeDiff_Top = 0,
    AltitudetDiff_Bottom = 0
}

function ZONEBOX_UNIT:New(ZoneName, ZoneUnit, Radius, Offset, AltitudeDiffTop, AltitudeDiffBottom)
    local self = BASE:Inherit(self, ZONE_UNIT:New(ZoneName, ZoneUnit, Radius, Offset))

    -- self:F({ZoneName, ZONE_UNIT:GetVec2(), Radius, Offset, AltitudeDiffTop, AltitudeDiffBottom})

    self.ZoneUNIT = ZoneUnit
    if AltitudeDiffTop < AltitudeDiffBottom then
        error("AltitudeDiff Input Error")
    end

    self.AltitudeDiff_Top = AltitudeDiffTop or 0
    self.AltitudeDiff_Bottom = AltitudeDiffBottom or 0

    -- Zone objects are added to the _DATABASE and SET_ZONE objects.
    _EVENTDISPATCHER:CreateEventNewZone(self)

    return self
end

function ZONEBOX_UNIT:IsAltitudeMatched(Altitude)

    local unitAltitude = 0

    if self.ZoneUNIT then
        unitAltitude = self.ZoneUNIT:GetAltitude()
    end

    if unitAltitude + self.AltitudeDiff_Top >= Altitude and unitAltitude + self.AltitudeDiff_Bottom <= Altitude then
        return true
    end

    return false
end

function ZONEBOX_UNIT:IsUnitInBox(Unit)
    return Unit:IsInZone(self) and self:IsAltitudeMatched(Unit:GetAltitude())
end

HELPER = {}

-- 具体参照ENUMS.ReportingName
HELPER.ReportingName = -- 待继续补充
{
    -- Fighters
    Dragon = "JF-17", -- China, correctly Fierce Dragon, Thunder for PAC
    Fagot = "MiG-15",
    Farmer = "MiG-19", -- Shenyang J-6 and Mikoyan-Gurevich MiG-19
    Felon = "Su-57",
    Fencer = "Su-24",
    Fishbed = "MiG-21",
    Fitter = "Su-17", -- Sukhoi Su-7 and Su-17/Su-20/Su-22
    Flogger = "MiG-23", -- and MiG-27
    Flogger_D = "MiG-27", -- and MiG-23
    Flagon = "Su-15",
    Foxbat = "MiG-25",
    Fulcrum = "MiG-29",
    Foxhound = "MiG-31",
    Flanker = "Su-27", -- Sukhoi Su-27/Su-30/Su-33/Su-35/Su-37 and Shenyang J-11/J-15/J-16
    Flanker_C = "Su-30",
    Flanker_E = "Su-35",
    Flanker_F = "Su-37",
    Flanker_L = "J-11A",
    Firebird = "J-10",
    Sea_Flanker = "Su-33",
    Fullback = "Su-34", -- also Su-32
    Frogfoot = "Su-25",
    Tomcat = "F-14", -- Iran
    Mirage = "Mirage", -- various non-NATO
    Codling = "Yak-40",
    Maya = "L-39",
    -- Fighters US/NATO
    Warthog = "A-10",
    -- Mosquito = "A-20",
    Skyhawk = "A-4E",
    Viggen = "AJS37",
    Harrier_B = "AV8BNA",
    Harrier = "AV-8B",
    Spirit = "B-2",
    Aviojet = "C-101",
    Nighthawk = "F-117A",
    Eagle = "F-15C",
    Mudhen = "F-15E",
    Viper = "F-16",
    Phantom = "F-4E",
    Tiger = "F-5", -- was thinkg to name this MiG-25 ;)
    Sabre = "F-86",
    Hornet = "A-18", -- avoiding the slash
    Hawk = "Hawk",
    Albatros = "L-39",
    Goshawk = "T-45",
    Starfighter = "F-104",
    Tornado = "Tornado",
    -- Transport / Bomber / Others
    Atlas = "A400",
    Lancer = "B1-B",
    Stratofortress = "B-52H",
    Hercules = "C-130",
    Super_Hercules = "Hercules",
    Globemaster = "C-17",
    Greyhound = "C-2A",
    Galaxy = "C-5",
    Hawkeye = "E-2D",
    Sentry = "E-3A",
    Stratotanker = "KC-135",
    Extender = "KC-10",
    Orion = "P-3C",
    Viking = "S-3B",
    Osprey = "V-22",
    -- Bomber Rus
    Badger = "H6-J",
    Bear_J = "Tu-142", -- also Tu-95
    Bear = "Tu-95", -- also Tu-142
    Blinder = "Tu-22",
    Blackjack = "Tu-160",
    -- AIC / Transport / Other
    Clank = "An-30",
    Curl = "An-26",
    Candid = "IL-76",
    Midas = "IL-78",
    Mainstay = "A-50",
    Mainring = "KJ-2000", -- A-50 China
    Yak = "Yak-52",
    -- Helos
    Helix = "Ka-27",
    Shark = "Ka-50",
    Hind = "Mi-24",
    Halo = "Mi-26",
    Hip = "Mi-8",
    Havoc = "Mi-28",
    Gazelle = "SA342",
    -- Helos US
    Huey = "UH-1H",
    Cobra = "AH-1",
    Apache = "AH-64",
    Chinook = "CH-47",
    Sea_Stallion = "CH-53",
    Kiowa = "OH-58",
    Seahawk = "SH-60",
    Blackhawk = "UH-60",
    Sea_King = "S-61",
    -- Drones
    UCAV = "WingLoong",
    Reaper = "MQ-9",
    Predator = "MQ-1A",

    -- 以下是自行添加的--
    -- basic by AIRBOSS.AircraftCarrier
    -- @field #string RHINOE F/A-18E Superhornet (mod).
    -- @field #string RHINOF F/A-18F Superhornet (mod).
    -- @field #string GROWLER FEA-18G Superhornet (mod).
    RhinoE = "FA-18E",
    RhinoF = "FA-18F",
    Growler = "EA-18G"
}

function HELPER.GetReportingName(TypeName)
    local reportName = nil
    local typename = string.lower(TypeName)

    for name, value in pairs(HELPER.ReportingName) do
        local svalue = string.lower(value)
        if string.find(typename, svalue, 1, true) then
            reportName = name
        end
    end
    if reportName == nil then
        -- env.info("HELPER: TypeName Not Found:" .. TypeName)
    end
    return reportName
end

-- 模拟太阳风暴以及其应对办法
-- wiki参考: @https://wiki.unitedearth.cc/
SOLAR_STORM = {
    ClassName = "SOLAR_STORM"
}

---- SOLAR STORM Settings ----
SOLAR_STORM.IsDebugMode = true

SOLAR_STORM.TableShieldUnitNamePrefixes = {}
SOLAR_STORM.TableFortressNamePrefixes = {}
SOLAR_STORM.TableSAMNamePrefixes = {}

-- todo: enable sam function
SOLAR_STORM.IsAvailableUnderStrikeSAM = true -- true:受到太阳风影响的SAM仍会开机(但效率受到影响,通过SAMRangeUnderStrike配置)
SOLAR_STORM.SAMRangeUnderStrike = 10 -- (%) 0%~100% 受太阳风暴影响,防空雷达的开机时,雷达的开火射程

-- todo: enable gps weapon fucntion
SOLAR_STORM.IsAvailableUnderStrike_GPSWeapons = false
---- SOLAR STORM SETTINGS END ----

--- SOLAR STORM Values ---
SOLAR_STORM.TableFortress = {}
SOLAR_STORM.TableShieldUnit = {}

SOLAR_STORM.UnitSetShield = nil
SOLAR_STORM.UnitSetFortress = nil
SOLAR_STORM.UnitSetSAM = nil

SOLAR_STORM.TimerUpdateUnit = nil
SOLAR_STORM.TimerUpdateStatus = nil
SOLAR_STORM.TimerSAM = nil
--- SOLAR STORM Values End---

function SOLAR_STORM:New()
    local self = BASE:Inherit(self, FSM:New())

    -- 配置FSM信息
    -- Start State.
    self:SetStartState("Stopped")

    -- Add FSM transitions.
    -- From State --> Event --> To State
    self:AddTransition("Stopped", "Strike", "Happenning")
    self:AddTransition("Happenning", "Stop", "Stopped")

    -- add timer
    self.TimerUpdateUnit = TIMER:New(function()
        self:UpdateUnits()
    end):Start(0, 2)

    self.TimerUpdateStatus = TIMER:New(function()
        self:UpdateStatus()
    end):Start(0, 1)

    return self
end

--- SOLAR SOTRM USER FUNCTIONS ----
function SOLAR_STORM:SetShieldNamePrefixes(TableNamePrefixes)
    self.TableShieldUnitNamePrefixes = TableNamePrefixes
    return self
end

function SOLAR_STORM:SetFortressNamePrefixes(TableNamePrefixes)
    self.TableFortressNamePrefixes = TableNamePrefixes
    return self
end

function SOLAR_STORM:SetSAMNamePrefixes(TableNamePrefixes)
    self.TableSAMNamePrefixes = TableNamePrefixes
end

function SOLAR_STORM:UpdateUnits()
    -- add unit set
    self.UnitSetShield = SET_UNIT:New():FilterActive():FilterPrefixes(self.TableShieldUnitNamePrefixes):FilterOnce()

    self.UnitSetFortress = SET_UNIT:New():FilterActive():FilterPrefixes(self.TableFortressNamePrefixes):FilterOnce()

    -- update fortress
    local tf = self:UpdateTable(self.TableFortress, self.UnitSetFortress)
    for _, unit in ipairs(tf) do
        self:AddFortress(unit)
    end

    -- update shield unit
    local ts = self:UpdateTable(self.TableShieldUnit, self.UnitSetShield)
    -- env.info("solar-debug: #ts" .. tostring(#ts))
    for _, unit in ipairs(ts) do
        self:AddShieldUnit(unit)
    end
end

-- add set_unit into table
function SOLAR_STORM:UpdateTable(TableUnit, SetUnit)
    local t_toadd = {}
    for _, p_unit in ipairs(SetUnit:GetSetObjects()) do
        local isAlready = false
        if TableUnit then
            for _, t_unit in ipairs(TableUnit) do
                if t_unit.Unit:Name() == p_unit:Name() then
                    isAlready = true
                    break
                end
            end
        end

        if not isAlready then
            -- env.info("solar-debug: Adding unit in update table " .. p_unit:GetName())
            table.insert(t_toadd, p_unit)
        end
    end

    -- env.info("solar-debug #t_toadd: " .. tostring(#t_toadd))

    return t_toadd
end

-- add fortress into table
function SOLAR_STORM:AddFortress(FortressUnit, Data)
    env.info("solar-debug: adding fortress" .. FortressUnit:GetName())
    table.insert(self.TableFortress, FORTRESS_UNIT:New(FortressUnit, Data))
end

-- add shield unit into table
function SOLAR_STORM:AddShieldUnit(ShieldUnit)
    env.info("solar-debug: adding Shield Unit" .. ShieldUnit:GetName())
    table.insert(self.TableShieldUnit, SHIELD_UNIT:New(ShieldUnit))
end

-- foreach ShieldUnit to update its status
function SOLAR_STORM:UpdateStatus()

    -- env.info("In UpdateStatus: #TableShieldUnit: " .. tostring(#self.TableShieldUnit))
    -- update shield unit status
    for _, unit in ipairs(self.TableShieldUnit) do
        if self:CheckShieldUnit(unit) then
            env.info(unit.Unit:GetName() .. " in safe zone")
            unit:EnterSafeZone()
        else
            env.info(unit.Unit:GetName() .. " exit safe zone")
            unit:ExitSafeZone()
        end
        -- env.info(unit.Unit:GetName() .." unit state: "..unit:GetState())
        -- env.info(unit.Unit:GetName() .." unit shield health: "..unit.ShieldHealth)
    end

    -- show debug mode
    if self.IsDebugMode then
        self:ShowDebugMessage()
    end
end

-- check ShieldUnit in protect area
function SOLAR_STORM:CheckShieldUnit(ShieldUnit)

    if self:Is("Stopped") then
        return true
    end

    for _, fortress in ipairs(self.TableFortress) do
        if fortress:IsProtectingShieldUnit(ShieldUnit) then
            return true
        end
    end

    return false
end

-- show debug message
function SOLAR_STORM:ShowDebugMessage()
    local msg = ""
    msg = msg .. "Current State: " .. self:GetState() .. "\n"
    msg = msg .. "Current Shield Units: " .. #self.TableShieldUnit .. "\n"
    msg = msg .. "Current Fortress Units: " .. #self.TableFortress .. "\n"

    local m = MESSAGE:New(msg, 1, nil, true):ToAll()
    return self
end

---- SOLAR STORM USER FUCTIONS END ----

---- FSM EVENTS ----

-- @field 堡垒单位
FORTRESS_UNIT = {
    ClassName = "FORTRESS_UNIT",
    FortressData = {},
    Unit = nil
}

---- Data Settings ----

-- todo:重新制订数据
FORTRESS_UNIT.DefaultData = {1000, 1000, -1000} -- 半径,上限高度,下限高度(负数为本体向下) (单位:米)
FORTRESS_UNIT.DefaultGroundData = {5 * 1800, 4000 / 3, -1000 / 3} -- 5NM/4000ft
FORTRESS_UNIT.DefaultShipData = {5 * 1800, 4000 / 3, -1000 / 3} -- 5nm/4000ft
FORTRESS_UNIT.DefaultAirData = {1000, 1000, -1000} -- 1000ft/1000ft

FORTRESS_UNIT.IsDefautlStart = true

---- Data Settings End ----

FORTRESS_UNIT.UnitTypeData = {
    Hercules = {300, 300, 300}, -- C-130
    Super_Hercules = {300, 300, 300}, -- SUPER C-130
    Growler = {150, 150, 150}, -- EA-18G
    Viking = {150, 150, 150}, -- S-3B
    Hawkeye = {300, 300, 300}, -- E-2D
    Sea_King = {150, 150, 150} -- S-61
}

function FORTRESS_UNIT:SetFortressData(Data)
    self.FortressData = Data
    return self
end

function FORTRESS_UNIT:GetDefaultFortressData(FortressUnit)
    if FortressUnit:IsGround() then
        return FORTRESS_UNIT.DefaultGroundData
    elseif FortressUnit:IsShip() then
        return FORTRESS_UNIT.DefaultShipData
    elseif FortressUnit:IsAir() then
        -- todo: 制订各机型的数据
        return FORTRESS_UNIT.DefaultAirData
    else
        return FORTRESS_UNIT.DefaultData
    end
end

function FORTRESS_UNIT:IsProtectingShieldUnit(ShieldUnit)
    if self.Is("Protecting") then
        local zb =
            ZONEBOX_UNIT:New("", self.Unit, self.FortressData[1], nil, self.FortressData[2], self.FortressData[3])
        if zb:IsUnitInBox(ShieldUnit.Unit) then
            return true
        end
    end
    return false
end

function FORTRESS_UNIT:New(FortressUnit, FortressData)
    local self = BASE:Inherit(self, FSM:New())
    self.Unit = FortressUnit

    -- set fortress unit data    
    self:SetFortressData(FortressData or FORTRESS_UNIT:GetDefaultFortressData(FortressUnit))

    --- FSM INIT ---    
    -- Start State.
    if FORTRESS_UNIT.IsDefaultProtecting then
        self:SetStartState("Protecting")
    else
        self:SetStartState("Stopped")
    end

    -- Add FSM transitions.
    -- From State --> Event --> To State
    self:AddTransition("Stopped", "Start", "Protecting")
    self:AddTransition("Protecting", "Stop", "Stopped")

    -- --- EVENT REGISTER ---
    -- self:HandleEvent(EVENTS.Crash, self._OnEventCrashOrDead)
    -- self:HandleEvent(EVENTS.Dead, self._OnEventCrashOrDead)

    return self
end

-- @field 带有护盾的单位
SHIELD_UNIT = {
    ClassName = "SHIELD_UNIT",

    ShieldHealth = 0,
    MaxShieldHealth = 0, -- 护盾上限值
    BoomShieldHealth = 0, -- 护盾下限值(爆炸啦)
    ShieldSpeedConsume = 1, -- 护盾消耗速率（/秒）
    ShieldSpeedRecovery = 15, -- 护盾回复速率（/秒）

    dTstatus = 1,
    TimerExhaust = nil,

    Unit = nil
}

--- SHIELD Settings ---

SHIELD_UNIT.DefaultTimeInterval = 1 -- UNIT执行周期
SHIELD_UNIT.DefaultMessageDuration = 15 -- 一般信息的显示时长

SHIELD_UNIT.DefaultShieldHealth = 600 -- 护盾能量值(10min)
SHIELD_UNIT.DefualtBoomHealth = -300 -- 机体受损的护盾阈值(5min)
SHIELD_UNIT.DefaultSShieldSpeedConsume = 1 -- 护盾消耗速率（/秒）
SHIELD_UNIT.DefaultSShieldSpeedRecovery = 15 -- 护盾回复速率（/秒）

--- 受损惩罚 ---
SHIELD_UNIT.ShieldExhaustExplodePower = 0.001 -- 护盾耗尽情况下的火光效果模拟
SHIELD_UNIT.DefaultBoomExplodePower = 0.15 -- 默认机体受损的爆炸当量

SHIELD_UNIT.UnitTypeExplodePower = -- 各机型的受损爆炸当量
{
    Hornet = 0.15, -- F/A-18C:损坏部分飞控系统
    RhinoE = 0.15,
    RhinoF = 0.15,
    Growler = 0.15,
    Mudhen = 1.6, -- F-15E:损坏单发引擎
    Viper = 0.7, -- F-16:损坏通讯天线
    Dragon = 0.15 -- JF-17:损坏部分航电,后续影响未明
}

SHIELD_UNIT.ShieldStatusShow = {
    ["Recovering"] = "...未激活...",
    ["Protecting"] = "..护盾消耗中..",
    ["Damaging"] = ".护盾耗尽,机体受损!.",
    ["Damaged"] = ".你的坤儿已经炸啦!."
}

--- SHIELD Settings End ---

--- SHIELD User Functions ---

function SHIELD_UNIT:SetShieldHealth(Health)
    self.ShieldHealth = Health
    return self
end

function SHIELD_UNIT:SetStatusUpdateTime(TimeInterval)
    self.dTstatus = TimeInterval or 1
    return self
end

-- todo: 重新制作通知方法&加入debug
-- todo: 添加发送声音警告
function SHIELD_UNIT:MessageNotify(Message, Duration, Name)
    if self.Unit:IsClient() then
        self.Unit:MessageToClient(Message, Duration or self.DefaultMessageDuration, self.Unit:GetClient(), Name)
    else
        self.Unit:MessageToAll(Message, Duration or self.DefaultMessageDuration, Name)
    end
    return self
end

function SHIELD_UNIT:GenerateShieldBar(Health)

    local solidSymbol = "■"
    local emptySymbol = "□"

    if Health < 0 then
        Health = 0
    elseif Health > self.DefaultShieldHealth then
        Health = self.DefaultShieldHealth
    end

    local maxBars = 20
    local percentage = (self.DefaultShieldHealth - Health) / self.DefaultShieldHealth

    local solidBars = math.max(1, math.floor(maxBars * (1 - percentage)))
    local emptyBars = maxBars - solidBars

    if Health == 0 then
        solidBars = 0
        emptyBars = maxBars
    end

    local result = ""

    for i = 1, solidBars do
        result = result .. solidSymbol
    end

    for i = 1, emptyBars do
        result = result .. emptySymbol
    end

    return result
end

function SHIELD_UNIT:ShowShieldStatus()
    if self.Unit:IsClient() then
        -- =============================
        -- 护盾能量: ■■■■■■■■■■■■■■■■■■■■
        local msg = "========= 电磁护盾监控 ============\n"
        msg = msg .. "护盾状态: " .. SHIELD_UNIT.ShieldStatusShow[self:GetState()] .. "\n"
        msg = msg .. "护盾能量: " .. self:GenerateShieldBar(self.ShieldHealth) .. "\n"
        msg = msg .. "=============================="
        -- msg = msg .. "护盾状态: " .. self:GetState() .. "\n"
        -- msg = msg .. "护盾能量: " .. self.ShieldHealth

        MESSAGE:New(msg, self.DefaultTimeInterval, nil, true):ToClient(self.Unit:GetClient())
    end
end

--- User Functions End ---

function SHIELD_UNIT:New(ShieldUnit)
    local self = BASE:Inherit(self, FSM:New())
    self:F(ShieldUnit)

    self.Unit = ShieldUnit

    -- Initiate parameters
    self:SetStatusUpdateTime(SHIELD_UNIT.DefaultTimeInterval)
    self.BoomShieldHealth = SHIELD_UNIT.DefaultBoomExplodePower
    self.ShieldHealth = SHIELD_UNIT.DefaultShieldHealth
    self.ShieldSpeedConsume = SHIELD_UNIT.DefaultSShieldSpeedConsume
    self.ShieldSpeedRecovery = SHIELD_UNIT.DefaultSShieldSpeedRecovery

    self.MaxShieldHealth = SHIELD_UNIT.DefaultShieldHealth
    self.BoomShieldHealth = SHIELD_UNIT.DefualtBoomHealth

    -- FSM settings

    -- Start State.
    self:SetStartState("Init")

    -- Add FSM transitions.
    -- From State --> Event --> To State
    self:AddTransition("Init", "Start", "Recovering") -- 护盾初始化
    self:AddTransition("Recovering", "ExitSafeZone", "Protecting") -- 护盾被激活
    self:AddTransition({"Protecting", "Damaging"}, "EnterSafeZone", "Recovering") -- 护盾被回复

    self:AddTransition("*", "Exhaust", "Damaging") -- 机体受损中 -- for fsm test
    -- self:AddTransition("Protecting", "Exhaust", "Damaging") -- 机体受损中

    self:AddTransition("Damaging", "Boom", "Damaged") -- 机体破损    

    self.TimerCheckStatus = TIMER:New(function()
        self:CheckStatus()
    end):Start(1, self.dTstatus)

    return self
end

--- FSM FUNCTIONS ---

-- 护盾耗尽
function SHIELD_UNIT:OnAfterExhaust(From, Event, To)
    self:MessageNotify("警告: 护盾已经耗尽. 机体正在受损. 请尽快重新充能护盾.")
end

function SHIELD_UNIT:OnEnterDamaging(From, Event, To)
    self.TimerExhaust = TIMER:New(function()
        self.Unit:Explode(self.ShieldExhaustExplodePower)
    end):Start(1, 5)
end

function SHIELD_UNIT:OnLeaveDamaging(From, Event, To)
    self.TimerExhaust:Stop()
end

-- 摧毁或损坏受太阳风暴的单位
function SHIELD_UNIT:OnAfterBoom(From, Event, To)

    local reportName = HELPER.GetReportingName(self.Unit:GetTypeName())
    local power = SHIELD_UNIT.DefaultBoomExplodePower
    if reportName then
        if SHIELD_UNIT.UnitTypeExplodePower[reportName] then
            power = SHIELD_UNIT.UnitTypeExplodePower[reportName]
        end
    end
    env.info("Debug: TypeName:" .. (reportName or "typename:" .. self.Unit:GetTypeName()) .. " Boom power:" ..
                 tostring(power))
    self.Unit:Explode(power)
end

------------------
-- FSM FUNCTIONS END
------------------

function SHIELD_UNIT:CheckStatus()
    -- 初始化    
    -- TODO: 补充初始化说明信息
    if self:Is("Init") then
        self:Start()
    end

    if self:Is("Recovering") then

        -- 回复护盾值(如果护盾值小于零,则自动归零)
        if self.ShieldHealth < 0 then
            self.ShieldHealth = 0
            env.info("Debug: Recovery Shiled Health")
        end
        if self.ShieldHealth < self.MaxShieldHealth then
            self.ShieldHealth = self.ShieldHealth + self.ShieldSpeedRecovery * self.dTstatus
        else
            self.ShieldHealth = self.MaxShieldHealth
        end
    end

    if self:Is("Protecting") then
        -- 护盾值消耗
        self.ShieldHealth = self.ShieldHealth - self.ShieldSpeedConsume * self.dTstatus

        if self.ShieldHealth < 0 then
            self:Exhaust()
        end

        -- TODO: 添加护盾值消耗程度的报警
    end

    if self:Is("Damaging") then
        -- 护盾值消耗
        self.ShieldHealth = self.ShieldHealth - self.ShieldSpeedConsume * self.dTstatus

        if self.ShieldHealth <= self.BoomShieldHealth then
            self:Boom()
        end
    end

    -- show status
    self:ShowShieldStatus()
    -- env.info("In CheckStatus")
    -- env.info(self.Unit:GetName() .." unit state: "..self:GetState())
    -- env.info(self.Unit:GetName() .." unit shield health: "..self.ShieldHealth)
    return self
end

env.info("== End Solar Storm Loading ==")

