local tz1 = TFM_TRAINZONE:New("TZ-1")
tz1.EnemyEmissionOpenDelay = 120
tz1.IsSmartSpawn = true

local tz2 = TFM_TRAINZONE:New("TZ-2")
tz2.EnemyEmissionOpenDelay = 120
tz2.SpawnDelayMin = 10 -- 生成敌人的最小延迟时间（秒）
tz2.SpawnDelayMax = 20 -- 生成敌人的最大延迟时间（秒）
tz2.IsSmartSpawn = true
local tz3 = TFM_TRAINZONE:New("TZ-3")
tz3.IsSpawnEmeny = false

-- 战术编队训练区(有威胁)