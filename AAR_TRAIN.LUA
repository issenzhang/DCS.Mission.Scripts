AAR_TRAIN = {}

AAR_TRAIN.TimerStep = 5
AAR_TRAIN.TriggerZone = nil
AAR_TRAIN.Ticker = 0
AAR_TRAIN.TimeSpan = 10
AAR_TRAIN.GroupSetInTrain = nil

AAR_TRAIN.TemplateName = ""
AAR_TRAIN.Callsign = nil -- 1-texco 2-arco 3-shell

AAR_TRAIN.TimerSpawn = nil
AAR_TRAIN.CallsignNum = 1
AAR_TRAIN.TACANNum = 1
AAR_TRAIN.RadioFreq = 0
AAR_TRAIN.ListCallsign = {"Texco", "Arco", "Shell"}

function AAR_TRAIN:New(ZoneName, TemplateName, Callsign, TACAN_Num, RadioFreq)
    local self = BASE:Inherit(self, FSM:New())

    self.TriggerZone = ZONE:New(ZoneName)
    self.GroupSetInTrain = SET_GROUP:New()

    self.TemplateName = TemplateName
    self.Callsign = Callsign or 1
    self.TACANNum = TACAN_Num or 0
    self.RadioFreq = RadioFreq or 255.000
    self.Ticker = 0

    self.TimerSpawn = TIMER:New(function()
        self:CheckStatus()
    end):Start(0, self.TimerStep)
    return self
end

function AAR_TRAIN:CheckStatus()

    if self.Ticker > 0 then
        self.Ticker = self.Ticker - self.TimerStep
    end

    local groups = SET_GROUP:New():FilterCoalitions("blue"):FilterCategoryAirplane():FilterZones({self.TriggerZone})
        :FilterOnce():GetSetObjects()

    if groups then
        for _, group in ipairs(groups) do
            if self.GroupSetInTrain:IsNotInSet(group) then
                if self.Ticker <= 0 then

                    -- add group into set
                    self.GroupSetInTrain:AddGroup(group)
                    TIMER:New(function()
                       self.GroupSetInTrain:RemoveGroupsByName(group:GetName())
                    end):Start(120)

                    local group_aar = SPAWN:NewWithAlias(self.TemplateName,string.format("%s-%d-1_%.3f",self.ListCallsign[self.Callsign], self.CallsignNum, self.RadioFreq)):Spawn()

                    -- set callsign
                    group_aar:CommandSetCallsign(self.Callsign, self.CallsignNum)

                    -- set tacan
                    group_aar:GetFirstUnit():GetBeacon():ActivateTACAN(self.TACANNum, "Y", self.Callsign, true)

                    -- set radio
                    group_aar:CommandSetFrequency(self.RadioFreq)

                    local msg =
                        "你小队的加油机出发,将于10分钟后抵达汇合点.加油机在线时长10分钟.\n" ..
                            string.format("加油机情报:\n- 呼号: %s-%d-1\n- 频率: %.3f\n- 塔康: %dY",
                                self.ListCallsign[self.Callsign], self.CallsignNum, self.RadioFreq, self.TACANNum)

                    HELPER.MessageToGroup(group, msg, 120)

                    TIMER:New(function()
                        HELPER.MessageToGroup(group, "加油机:已开启空加窗口,时长10分钟.")
                    end):Start(600)

                    -- reset ticker
                    self.Ticker = self.TimeSpan

                    -- step-in for next spawn
                    self.CallsignNum = self.CallsignNum + 1
                    self.TACANNum = self.TACANNum + 1
                    self.RadioFreq = self.RadioFreq + 0.500
                else
                    HELPER.MessageToGroup(group, "加油机生成间隔过小,请重新进入触发空域")
                end
            end
        end
    end
end
