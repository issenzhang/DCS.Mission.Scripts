HELPER = {}

HELPER.SoundFileName = "radio click.ogg"

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
        env.info("HELPER: TypeName Not Found: \"" .. TypeName .. "\"")
    end
    return reportName
end

function HELPER.MessageToGroup(Group, MessageText, Duration, IsClear, IsSound)
    if Group then
        MessageText = MessageText or ""
        Duration = Duration or 30
        IsClear = IsClear or false
        IsSound = IsSound or true

        local groupName = Group:GetName()
        local playersName = ""

        if Group:GetPlayerNames() then
            for _, pn in ipairs(Group:GetPlayerNames()) do
                playersName = playersName .. "/" .. pn
            end
            playersName = string.sub(playersName, 2)
        end

        local Text = "Group " .. groupName .. " (" .. playersName .. "):\n" .. MessageText
        env.info("Helper: Message to group:\n" .. Text)
        MESSAGE:New(Text, Duration, nil, IsClear):ToGroup(Group)

        if IsSound then
            USERSOUND:New(HELPER.SoundFileName):ToGroup(Group)
        end
    else
        env.info("HELPER.MessageToGroup: Group is nil")
    end
end
