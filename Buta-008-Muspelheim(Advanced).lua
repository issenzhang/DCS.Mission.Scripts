MESSAGE:New("================\n\nloading Mission...\n\n================", 20):ToAll() -- Message for to test if script is running properly

-- Set Players
local players = #NET:New():GetPlayerList()
players = players - 1
if players <= 1 then
    RedPlayers = 3
    BluePlayers = 3
elseif players % 2 == 0 then
    RedPlayers = players / 2
    BluePlayers = players / 2
else
    RedPlayers = (players - 1) / 2
    BluePlayers = (players + 1) / 2
end

--RedPlayers = 3
--BluePlayers = 3
-- Set Players

_SETTINGS:SetPlayerMenuOff()

--Send Message
local function SendToAll(Message)
    MessageToAll(Message, 10)
end

SendToAll("Total plays: " .. players) --Debug

-- Enums
local SIDE = {
    BLUE = coalition.side.BLUE,
    NEUTRAL = coalition.side.NEUTRAL,
    RED = coalition.side.RED,
}

local COALITION = {
    [SIDE.NEUTRAL] = -1,
    [SIDE.RED] = 1,
    [SIDE.BLUE] = 2,
}

local COLOR = {
    [SIDE.NEUTRAL] = { 1, 1, 1 },
    [SIDE.RED] = { 0, 0, 1 },
    [SIDE.BLUE] = { 1, 0, 0 },
}

local LINE_TYPE = {
    [SIDE.NEUTRAL] = 2,
    [SIDE.RED] = 1,
    [SIDE.BLUE] = 1,
}

local SPAWN_LIMIT = {
    RED = {
        Tank = {
            Alive = 1 * RedPlayers,
            Total = 5 * RedPlayers,
        },
        AA = {
            Alive = 2 * RedPlayers / 3,
            Total = 2 * RedPlayers,
        },
    },
    BLUE = {
        Tank = {
            Alive = 1 * BluePlayers,
            Total = 4 * BluePlayers,
        },
        AA = {
            Alive = 2 * BluePlayers / 3,
            Total = 2 * BluePlayers,
        },
    },
    MANPADS = {
        Alive = 3,
        Total = 3 * (BluePlayers + RedPlayers) / 2,
    },
    ARTY = {
        Alive = 14, --in Units
        Total = 2, --in Groups
    },
}
-- Enums

-- Zones
local zones_toCapture = {
    ["1:Alpha"] = SIDE.NEUTRAL,
    ["2:Bravo"] = SIDE.NEUTRAL,
    ["3:Charlie"] = SIDE.NEUTRAL,
    ["4:Delta"] = SIDE.NEUTRAL,
    ["5:Echo"] = SIDE.NEUTRAL,
}

capture_Zones = {}  -- Table of capture zones

RedRespawn = {}     -- Respawn zones for RED
BlueRespawn = {}    -- Respawn zones for Blue
RedArty = {}        -- Spawn zones for RED Artillaries
BlueArty = {}       -- Spawn zones for BLUE Artillaries

ManpadsRespawn = {} -- Respawn zones for RED/BLUE manpads


local spawn_Zones = {
    ["RED"] = {
        respawn = {
            prefix = {
                "Red-Spawn-1",
                "Red-Spawn-2",
                "Red-Spawn-3",
                "Red-Spawn-4",
            },
            sets = RedRespawn,
        },
        arty = {
            prefix = {
                "Red-Arty-1",
                "Red-Arty-2",
            },
            sets = RedArty,
        },
    },
    ["BLUE"] = {
        respawn = {
            prefix = {
                "Blue-Spawn-1",
                "Blue-Spawn-2",
                "Blue-Spawn-3",
                "Blue-Spawn-4",
            },
            sets = BlueRespawn,
        },
        arty = {
            prefix = {
                "Blue-Arty-1",
                "Blue-Arty-2",
            },
            sets = BlueArty,
        },
    },
    ["MANPAD"] = {
        respawn = {
            prefix = {
                "Manpads-1",
                "Manpads-2",
                "Manpads-3",
                "Manpads-4",
                "Manpads-5",
            },
            sets = ManpadsRespawn,
        },
    },
}
-- Zones

-- Units
RedGrounds = { -- RED units prefix
    "Red-Tank-1",
    "Red-Tank-2",
    "Red-Tank-3",
    "Red-Tank-4",
    "Red-Scout-1",
    "Red-Scout-2",
    "Red-Scout-3",
    "Red-Scout-4",
    "Red-Scout-5",
    "Red-Scout-6",
    "Red-Scout-7"
}
RedAAs = { "Red-AA-1", "Red-AA-2", "Red-AA-3", "Red-AA-4", "Red-AA-5", "Red-AA-6" } -- RED units prefix
RedAmmo = SPAWN:New("Red-Ammo")                                              -- RED units prefix

BlueGrounds = {                                                              -- BLUE units prefix
    "Blue-Tank-1",
    "Blue-Tank-2",
    "Blue-Tank-3",
    "Blue-Tank-4",
    "Blue-Tank-5",
    "Blue-Tank-6",
    "Blue-Scout-1",
    "Blue-Scout-2",
    "Blue-Scout-3",
    "Blue-Scout-4",
    "Blue-Scout-5"
}
BlueAAs = { "Blue-AA-1", "Blue-AA-2", "Blue-AA-3", "Blue-AA-4", "Blue-AA-5", "Blue-AA-6" } -- BLUE units prefix
BlueAmmo = SPAWN:New("Blue-Ammo")                                                   -- BLUE units prefix

local UNIT_RESPAWN = {
    ["tank"] = {
        RED = {
            respawnZone = RedRespawn,
            prefix = RedGrounds,
            limit = {
                alive = SPAWN_LIMIT.RED.Tank.Alive,
                total = SPAWN_LIMIT.RED.Tank.Total,
            },
        },
        BLUE = {
            respawnZone = BlueRespawn,
            prefix = BlueGrounds,
            limit = {
                alive = SPAWN_LIMIT.BLUE.Tank.Alive,
                total = SPAWN_LIMIT.BLUE.Tank.Total,
            },
        },
    },
    ["aa"] = {
        RED = {
            respawnZone = RedRespawn,
            prefix = RedAAs,
            limit = {
                alive = SPAWN_LIMIT.RED.AA.Alive,
                total = SPAWN_LIMIT.RED.AA.Total,
            },
        },
        BLUE = {
            respawnZone = BlueRespawn,
            prefix = BlueAAs,
            limit = {
                alive = SPAWN_LIMIT.BLUE.AA.Alive,
                total = SPAWN_LIMIT.BLUE.AA.Total,
            },
        },
    },
    ["manpads"] = {
        RED = {
            respawnZone = ManpadsRespawn,
            prefix = { "Red-Manpad-1" },
            limit = {
                alive = SPAWN_LIMIT.MANPADS.Alive,
                total = SPAWN_LIMIT.MANPADS.Total,
            },
        },
        BLUE = {
            respawnZone = ManpadsRespawn,
            prefix = { "Blue-Manpad-1" },
            limit = {
                alive = SPAWN_LIMIT.MANPADS.Alive,
                total = SPAWN_LIMIT.MANPADS.Total,
            },
        },
    },
    ["arty"] = {
        RED = {
            respawnZone = RedArty,
            prefix = { "Red-Arty-1" },
            limit = {
                alive = SPAWN_LIMIT.ARTY.Alive,
                total = SPAWN_LIMIT.ARTY.Total,
            },
        },
        BLUE = {
            respawnZone = BlueArty,
            prefix = { "Blue-Arty-1" },
            limit = {
                alive = SPAWN_LIMIT.ARTY.Alive,
                total = SPAWN_LIMIT.ARTY.Total,
            },
        },
    },
}
-- Units

-- Functions
local function draw_zones(_zones) -- Draw Zones
    for k, v in pairs(_zones) do
        ZONE
            :New(k)
            :DrawZone(COALITION[v], COLOR[v], 0.45, COLOR[v], 0.25, LINE_TYPE[v], false)
            :GetCoordinate()
            :TextToAll(k, COALITION[v], { 0, 0, 0 }, 1, { 0, 0, 0 }, 0, 16, false)
    end
end

local function set_Capture_Zones(_zones, tb) -- Set capture zones
    for k, v in pairs(_zones) do
        local zone = ZONE_CAPTURE_COALITION:New(ZONE:New(k), coalition.side.NEUTRAL):SetMarkZone(false):Start(5, 5)
        table.insert(tb, zone)
    end
end

local function timer_CountDown()
    MESSAGE:New("任务结束，还有" .. countDown .. "秒后重启(不需要退出服务器)", 0.5, "", false):ToAll()

    countDown = countDown - 1
end

function ZONE_CAPTURE_COALITION:OnEnterCaptured() --Custom funciton when zone be captured
    local Coalition = self:GetCoalition()
    self:E({ Coalition = Coalition })
    if Coalition == coalition.side.BLUE then
        self:GetCoordinate(1):SmokeBlue()
        self:UndrawZone()
        self:DrawZone(-1, { 0, 0, 1 }, 0.45, { 0, 0, 1 }, 0.25, 1, false)
        BlueAmmo:SpawnInZone(self, false)
        SendToAll("区域" .. self:GetZoneName() .. "已被蓝方占领")

        local count = 0
        for k, v in pairs(capture_Zones) do
            if v:GetCoalition() == coalition.side.BLUE
            then
                count = count + 1
            end
        end
        if count == 5 then
            ZONE:New("Win"):FlareZone(FLARECOLOR.Green, 20, 0, 1):SmokeZone(SMOKECOLOR.Blue, 20, 1)
            SendToAll("=====\n\n蓝方获胜\n\n=====")
            countDown = 30
            TIMER:New(timer_CountDown):Start(0, 1, 30)
            USERFLAG:New("Restart"):Set(true, 30)
        end
    else
        self:GetCoordinate(1):SmokeRed()
        self:UndrawZone()
        self:DrawZone(-1, { 1, 0, 0 }, 0.45, { 1, 0, 0 }, 0.25, 1, false)
        RedAmmo:SpawnInZone(self, false)
        SendToAll("区域" .. self:GetZoneName() .. "已被红方占领")
        local count = 0
        for k, v in pairs(capture_Zones) do
            if v:GetCoalition() == coalition.side.RED
            then
                count = count + 1
            end
        end
        if count == 5 then
            ZONE:New("Win"):FlareZone(FLARECOLOR.Red, 20, 0, 1):SmokeZone(SMOKECOLOR.Red, 20, 1)
            SendToAll("=====\n\n红方获胜\n\n=====")
            countDown = 30
            TIMER:New(timer_CountDown):Start(0, 1, 30)
            USERFLAG:New("Restart"):Set(true, 30)
        end
    end
end

local function set_zones(_zones) -- Set respawn zones
    for k, v in pairs(_zones) do
        for i, var in pairs(_zones[k].respawn.prefix) do
            local zone = ZONE:New(var)
            table.insert(_zones[k].respawn.sets, zone)
        end

        if _zones[k].arty ~= nil then
            for i, var in pairs(_zones[k].arty.prefix) do
                local zone = ZONE:New(var)
                table.insert(_zones[k].arty.sets, zone)
            end
        end
    end
end

local function spawn_units(_units)
    for k, v in pairs(_units) do
        SendToAll("spawning BLUE: " .. k .. " in " .. _units[k].BLUE.limit.alive)
        SPAWN
            :New(_units[k].BLUE.prefix[1])
            :InitRandomizeTemplate(_units[k].BLUE.prefix)
            :InitRandomizeZones(_units[k].BLUE.respawnZone)
            :InitLimit(_units[k].BLUE.limit.alive, _units[k].BLUE.limit.total)
            :SpawnScheduled(5, 1)

        SendToAll("spawning RED: " .. k .. " in " .. _units[k].RED.limit.alive)
        SPAWN
            :New(_units[k].RED.prefix[1])
            :InitRandomizeTemplate(_units[k].RED.prefix)
            :InitRandomizeZones(_units[k].RED.respawnZone)
            :InitLimit(_units[k].RED.limit.alive, _units[k].RED.limit.total)
            :SpawnScheduled(5, 1)
    end
end
-- Functions

--Main
set_Capture_Zones(zones_toCapture, capture_Zones)
draw_zones(zones_toCapture)

set_zones(spawn_Zones)

spawn_units(UNIT_RESPAWN)
--Main

MESSAGE:New("================\n\nMission Start! \n\n================", 10, "", true):ToAll()
