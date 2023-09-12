AAR_TRAIN = {}

AAR_TRAIN.TimerStep = 5
AAR_TRAIN.TriggerZone = nil
AAR_TRAIN.Ticker = 0
AAR_TRAIN.TimeSpan = 120
AAR_TRAIN.GroupSetInTrain = nil

AAR_TRAIN.TemplateName = ""
AAR_TRAIN.Callsign = nil -- 1-texco 2-arco

AAR_TRAIN.TimerSpawn = nil
AAR_TRAIN.CallsignNum = 0
AAR_TRAIN.TACANNum = 0
AAR_TRAIN.RadioFreq = 0
AAR_TRAIN.ListCallsign = {"Texco", "Arco"}

function AAR_TRAIN:New(ZoneName, TemplateName, Callsign, TACAN_Num, RadioFreq)
    local self = BASE:Inherit(self, FSM:New())

    self.TriggerZone = ZONE:New(ZoneName)
    self.GroupSetInTrain = SET_GROUP:New()

    self.TemplateName = TemplateName
    self.Callsign = Callsign or "Arco"
    self.TACANNum = TACAN_Num or 0
    self.RadioFreq = RadioFreq or 255.000
    self.Ticker = self.TimeSpan

    self.TimerSpawn = TIMER:New(function()
        self:CheckStatus()
    end):Start(0, self.TimerStep)
    return self
end

function AAR_TRAIN:CheckStatus()

    if self.Ticker > 0 then
        self.Ticker = self.Ticker - self.TimerStep
    end

    for _, group in ipairs(SET_GROUP:New():FilterCoalitions("blue"):FilterCategoryAirplane():FilterZones(
        {self.TriggerZone}):FilterOnce():GetSetObjects()) do
        if self.GroupSetInTrain:IsNotInSet(group) then
            if self.Ticker <= 0 then

                local group_aar = SPAWN:New(self.TemplateName):Spawn()

                -- set callsign
                group_aar:CommandSetCallsign(self.Callsign, self.CallsignNum)

                -- set tacan
                group_aar:GetFirstUnit():GetBeacon():ActivateTACAN(self.TACANNum, "Y", self.Callsign, true)

                -- set radio
                group_aar:CommandSetFrequency(self.RadioFreq)

                local msg =
                    "你小队的加油机出发,将于10分钟后抵达汇合点.加油机在线时长10分钟.\n" ..
                        string.format("加油机情报:\n呼号: %s-%d-1\n频率: %f\n塔康: %dY",
                            self.ListCallsign[self.Callsign], self.CallsignNum, self.RadioFreq, self.TACANNum)

                HELPER.MessageToGroup(group, msg, 120)

                TIMER:New(function ()
                    HELPER.MessageToGroup(group,"加油机:已开启空加窗口,时长10分钟.")
                end):Start(600)

                -- reset ticker
                self.Ticker = self.TimeSpan

                -- step-in for next spawn
                self.CallsignNum = self.CallsignNum + 1
                self.TACANNum = self.CallsignNum + 1
                self.RadioFreq = self.RadioFreq + 0.500

            else
                HELPER.MessageToGroup(group, "加油机生成间隔过小,请重新进入触发空域")
            end
        end
    end
end
