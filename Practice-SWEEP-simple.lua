-- SWEEP 多人练习 by ISSEN

--你和你的小伙伴们将从艾尔明翰空军基地起飞, 在1号航路点完成集结后, 在2-3号航路点之间建立巡逻航线.
--建立巡逻航线后, 请通过F10激活训练, 你们需要清除所有升空的敌方战斗机.
--
--激活训练前, 可通过F10菜单, 调整训练难度(敌机机型).
--
--每批次会根据巡逻区域人数, 生成对应人数的敌机.
--击毁全部敌机后, 你机队将有120s重新整理编队.
--一共会生成4波敌机, 难度逐渐增大.
--
--预警机:251.000
--
--4波次完成后, 每次都直接进入挑战关卡
--波次完成后, 有2分钟整理编队的时间
--失败条件:
-- 1. 战损以上本方飞机50%
-- 2. 所有己方飞机飞离任务区60s

-- easy难度
--  1. 2* mig-21    (2*73)
--  2. 2* mig-29    (2*73+2*77)
--  3. 2* jf-17     (2*sd10+2*pl-5)
--  4. 2* su-27     (2*er+2*et+2*73)

-- normal难度
--  1. 2* mig-29    (2*73+2*77)
--  2. 2* su-27     (2*er+2*et+2*73)
--  3. 2* j-11b     (2*er+2*77+2*et+2*73)
--  4. 2* f-15c     (4*120b+2*7m+2*9m)

-- high难度
--  1. 2* f-16      (4*120b+2*9m)
--  2. 2* f-15c     (4*120b+2*7m+2*9m)
--  3. 2* mig-35    (2*R37+...)
--  4. 2* f-14      (4*不死鸟+2*9xx)

DURATION_WAVE_INTERVAL = 120 -- 波次之间的时间间隔(s)
MAX_LOST_RATE = 0.5          -- 判定任务失败的战损比例
ZONE_PRACTICE = "z-practice" -- 练习的交战区域

_SETTINGS:SetPlayerMenuOff()

MESSAGE:New("================\n\nloading Mission...\n\n================", 20):ToAll() -- Message for to test if script is running properly

local function AppendString(string, toappend)
    return string .. toappend + "\n"
end

local function MessageToAll(msg_text, duration)
    MESSAGE:New(msg_text, duration or 60):ToAll()

    USERSOUND:New("radio click.ogg"):ToAll()
end

local wave = 1
local spawn_times = 1
local difficult = 2 --默认中等难度

local status = 1
local table_status =
{
    "未启动/停止",
    "激活中",
    "间歇中",
}

local table_enemy =
{
    { --easy
        "g-mig-21",
        "g-mig-29",
        "g-jf-17",
        "g-su-27",

    },
    { --normal
        "g-mig-29",
        "g-su-27",
        "gj-11-b",
        "g-f-15c"
    },
    { --hard
        "gj-11-b",
        "g-f-15c",
        "g-mig-35",
        "g-f-14"
    },
}

local table_describe_enemy =
{
    { --easy
        "mig-21",
        "mig-29",
        "jf-17",
        "su-27",
    },
    { --normal
        "mig-29",
        "su-27",
        "j-11-b",
        "f-15c"
    },
    { --hard
        "j-11-b",
        "f-15c",
        "mig-35",
        "f-14"
    }
}


local set_client_inzone = SET_CLIENT:New():FilterCategories("plane"):FilterZones({ ZONE:New(ZONE_PRACTICE) })
    :FilterStart()
local set_client = SET_CLIENT:New():FilterCategories("plane"):FilterStart()
local set_enemy = SET_UNIT:New():FilterPrefixes("enemy"):FilterStart()
local init_players_count = 0
local timer_practice = nil
local tick_idle = DURATION_WAVE_INTERVAL

local function wave_instep()
    wave = wave + 1
    if wave > 4 then
        wave = 4
    end
end

local function start_wave()
    local now_wave = wave
    spawn_times = UTILS.Round((set_client:CountAlive() + 1) * 0.5, 0)
    for i = 1, spawn_times do
        local sp = SPAWN:NewWithAlias(table_enemy[difficult][i], "enemy-" .. i)
            :InitAIOn()
            :SpawnInZone(ZONE:New("z-spawn"), true)
    end
    MessageToAll("第" .. wave .. "波敌人已刷新：\n" ..
        table_describe_enemy[difficult][wave] .. " 共" .. spawn_times .. "组")
    status = 2
end

local function info_idle_last_time(last_tick)
    if tick_idle == last_tick then
        MessageToAll(tick_idle .. "s后激活敌机")
    end
end

local function do_idle()
    if tick_idle > 0 then
        tick_idle = tick_idle - 1
    end

    info_idle_last_time(60)
    info_idle_last_time(30)
    info_idle_last_time(10)
    info_idle_last_time(3)
    info_idle_last_time(2)
    info_idle_last_time(1)
end

local function control_practice()
    -- 检查区域内人数
    -- if status ~= 1 then
    --     if set_client_inzone:CountAlive() <= 0.5 * init_players_count then
    --         stop_practice("CAP区域内,己方飞机数量不足." .. sc:CountAlive())
    --     end
    -- end

    -- 检查是否进入idle
    if status == 2 then
        if set_enemy:CountAlive() <= 0 then
            if wave == 4 then
                stop_practice("完成所有波次,恭喜!")
            else
                MessageToAll("波次完成,120s后刷新下一波次.")
                status = 3
                wave_instep()
                tick_idle = DURATION_WAVE_INTERVAL
            end
        end
    end

    -- 检查是否重新激活敌人
    if status == 3 then
        if tick_idle <= 0 then
            status = 2
            start_wave()
        else
            do_idle()
        end
    end
end

local function stop_practice(_reason)
    status = 1

    if _reason ~= nil then
        MessageToAll("训练结束:" .. _reason)
    else
        MessageToAll("训练结束.")
    end

    if timer_practice ~= nil then
        timer_practice:Stop()
    end

    -- 销毁所有红方训练组的飞机
    local timer_destroy = TIMER:New(
        function()
            local su = SET_UNIT:New():FilterPrefixes("enemy"):FilterStart():ForEachUnit(
                function(u)
                    u:Destroy(false)
                end
            )
        end):Start(30)
end

local function start_practice()
    if status == 1 or status == 0 then
        wave = 1

        tick_idle = 20
        status = 3

        init_players_count = set_client_inzone:CountAlive()
        timer_practice = TIMER:New(control_practice):Start(0, 1)
    else
        MessageToAll("训练正在进行中... " .. status)
    end
end

function set_difficult(level)
    if level >= 1 and level <= 3 then
        difficult = level
        local table = { "幼儿园水平", "默认难度", "微微辣" }
        MessageToAll("已经将训练难度调整为: " .. table[difficult])
    end
end

local MenuPractice_Start = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "开始训练", nil,
    start_practice)
local MenuPractice_Stop = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "停止训练", nil,
    function()
        MessageToAll("少年,开弓还能有回头箭吗?\n好好地接导弹吧~~")
    end
)

local Menu_Level = MENU_COALITION:New(coalition.side.BLUE, "难度设置")
local Menu_Level_Set_1 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "简单", Menu_Level, set_difficult, 1)
local Menu_Level_Set_2 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "正常", Menu_Level, set_difficult, 2)
local Menu_Level_Set_3 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "困难", Menu_Level, set_difficult, 3)


-- mission start
MESSAGE:New("================\n\nMission Start! \n\n================", 10, "", true):ToAll()
