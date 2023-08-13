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

function HELPER.GetReportingName(Unit)
    -- 获取爆炸当量信息
    local typeName = Unit:GetTypeName()
    local reportName = nil
    for name, value in pairs(HELPER.ReportingName) do
        local svalue = string.lower(value)
        if string.find(typename, svalue, 1, true) then
            reportName = name
        end
    end
    if reportName == nil then
        Unit:T("HELPER: TypeName Not Found:" .. typeName)
        return reportName
    end

    -- 模拟太阳风暴以及其应对办法
    -- wiki参考: @https://wiki.unitedearth.cc/
    SOLAR_STORM = {
        ClassName = "SOLAR_STORM"
    }

    SOLAR_STORM.TableFortress = {}

    function SOLAR_STORM:New()
        local self = BASE:Inherit(self, FSM:New())

        -- 配置FSM信息
        -- Start State.
        self:SetStartState("Stopped")

        -- Add FSM transitions.
        -- From State --> Event --> To State
        self:AddTransition("Stopped", "Start", "Happenning")
        self:AddTransition("Happenning", "Stop", "Stopped")

        self:AddTransition("*", "CheckStatus", "*")
    end

    function SOLAR_STORM:AddShieldFotressByUnitNamePrefix(UnitNamePrefix)
    end

    function SOLAR_STORM:AddShieldFotressByUnitNameTable(UnitNameTable)
    end

    -- @field 堡垒单位
    FORTRESS_UNIT = {
        ClassName = "FORTRESS_UNIT"
    }

    FORTRESS_UNIT.DefaultData = {1000, 1000, -1000} -- 半径,上限高度,下限高度(负数为本体向下) (单位:米)

    FORTRESS_UNIT.UnitTypeData = {
        Hercules = {300, 300, 300}, -- C-130
        Super_Hercules = {300, 300, 300}, -- SUPER C-130
        Growler = {150, 150, 150}, -- EA-18G
        Viking = {150, 150, 150}, -- S-3B
        Hawkeye = {300, 300, 300}, -- E-2D
        Sea_King = {150, 150, 150} -- S-61
    }

    function FORTRESS_UNIT:New(FortressUnit)
        local type = HELPER.GetReportingName(FortressUnit)
        local fortressData = FORTRESS_UNIT.DefaultData
        if type then
            local data = FORTRESS_UNIT.UnitTypeData[type]
            if data then
                fortressData = data
            end
        end
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

    ----------------------
    -- SHIELD Settings
    ----------------------

    SHIELD_UNIT.TimeInterval = 1 -- UNIT执行周期
    SHIELD_UNIT.DefaultMessageDuration = 15 -- 一般信息的显示时长

    SHIELD_UNIT.DefaultShieldHealth = 1200 -- 护盾能量值
    SHIELD_UNIT.DefualBoomHealth = -600 -- 机体受损的护盾阈值
    SHIELD_UNIT.DefaultSShieldSpeedConsume = 1 -- 护盾消耗速率（/秒）
    SHIELD_UNIT.DefaultSShieldSpeedRecovery = 15 -- 护盾回复速率（/秒）

    ------------------
    -- 受损惩罚
    ------------------
    SHIELD_UNIT.ShieldExhaustExplodePower = 0.001 -- 护盾耗尽情况下的火光效果模拟
    SHIELD_UNIT.DefaultBoomExplodePower = 0.15 -- 默认机体受损的爆炸当量

    SHIELD_UNIT.UnitTypeExplodePower = -- 各机型的受损爆炸当量
    {
        Hornet = 0.15, -- F/A-18C:损坏部分飞控系统
        RhinoE = 0.15,
        RhinoF = 0.15,
        Growler = 0.15,
        Mudhen = 1.6, -- F-15E:损坏单发引擎
        Viper = 0.7 -- F-16:损坏通讯天线
    }

    ----------------------
    -- SHIELD Settings End
    ----------------------

    function SHIELD_UNIT:New(ShieldUnit)
        local self = BASE:Inherit(self, FSM:New())
        self:F(ShieldUnit)

        self.Unit = ShieldUnit

        -- 配置FSM信息
        -- Start State.
        self:SetStartState("Init")

        -- Add FSM transitions.
        -- From State --> Event --> To State
        self:AddTransition("Init", "Start", "Stopped") -- 护盾被激活
        self:AddTransition("Stopped", "ExitSafeZone", "Protecting") -- 护盾被激活
        self:AddTransition({"Protecting", "Damaging"}, "EnterSafeZone", "Stopped") -- 护盾被回复
        self:AddTransition("Protecting", "Exhaust", "Damaging") -- 机体受损中
        self:AddTransition("Damaging", "Boom", "Damaged") -- 机体破损

        self:AddTransition("*", "CheckStatus", "*") -- 过程控制事件

        self:SetStatusUpdateTime(self.TimeInterval)
    end

    --- Set time interval for updating player status and other things.
    -- @param #SHIELD_UNIT self
    -- @param #number TimeInterval Time interval in seconds. Default 1 sec.
    -- @return #SHIELD_UNIT self
    function SHIELD_UNIT:SetStatusUpdateTime(TimeInterval)
        self.dTstatus = TimeInterval or 1
        return self
    end

    function SHIELD_UNIT:MessageNotify(Message, Duration, Name)
        if self.Unit.IsClient() then
            self.Unit:MessageToClient(Message, Duration or self.DefaultMessageDuration, self.Unit:GetClient(), Name)
        else
            self.Unit:MessageToGroup(Message, Duration or self.DefaultMessageDuration, self.DefaultMessageDuration,
                self.Unit:GetGroup(), Name)
        end
    end

    -- 护盾耗尽
    function SHIELD_UNIT:OnAfterExhaust(From, Event, To)
        self:MessageNotify("警告:护盾已经耗尽.机体正在受损.")
    end

    function SHIELD_UNIT:OnEnterDamaging(From, Event, To)
        self.TimerExhaust = TIMER:New(self.Unit:Explode(self.ShieldExhaustExplodePower)):Start(1, 1)
    end

    function SHIELD_UNIT:OnLeaveDamaging(From, Event, To)
        self.TimerExhaust:Stop()
    end

    -- 摧毁或损坏受太阳风暴的单位
    function SHIELD_UNIT:OnAfterBoom(From, Event, To)

        local reportName = HELPER.GetReportingName(self.ShieldUnit)
        local power = SHIELD_UNIT.DefaultExplodePower
        if reportName then
            power = SHIELD_UNIT.ExplodePowerExhaust[reportName]
        end

        self.Unit:Explode(power)
    end

    function SHIELD_UNIT:OnAfterCheckStatus(From, Event, To)

        -- 初始化
        -- TODO: 补充初始化说明信息
        if self:Is("Init") then
            self:Start()
        end

        if self:Is("Stopped") then

            -- 回复护盾值(如果护盾值小于零,则自动归零)
            if self.ShieldHealth < 0 then
                self.ShieldHealth = 0
            end
            if self.ShieldHealth < self.MaxShieldHealth then
                self.ShieldHealth = self.ShieldHealth + self.ShieldSpeedRecovery * self.TimeInterval
            else
                self.ShieldHealth = self.MaxShieldHealth
            end
        end

        if self:Is("Protecting") or self:Is("") then
            -- 护盾值消耗
            self.ShieldHealth = self.ShieldHealth - self.ShieldSpeedConsume * self.TimeInterval

            if self.ShieldHealth <= 0 then
                self:Exhaust()
            end

            -- TODO: 添加护盾值消耗程度的报警
        end

        if self:Is("Damaging") then
            -- 护盾值消耗
            self.ShieldHealth = self.ShieldHealth - self.ShieldSpeedConsume * self.TimeInterval

            if self.ShieldHealth <= self.BoomShieldHealth then
                self.Boom()
            end
        end
    end
end
