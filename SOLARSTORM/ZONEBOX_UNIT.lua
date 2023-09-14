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

    self:F({ZoneName, ZoneUNIT:GetVec2(), Radius, Offset, AltitudeDiffTop, AltitudeDiffBottom})

    self.ZoneUNIT = ZoneUnit
    if AltitudeDiffTop < AltitudeDiffBottom then
        error("AltitudeDiff Input Error")
    end

    self.AltitudeDiff_Top = AltitudeDiffTop or 0
    self.AltitudeDiff_Bottom = AltitudeDiffBottom or 0

    -- Zone objects are added to the _DATABASE and SET_ZONE objects.
    _EVENTDISPATCHER:CreateEventNewZone(self)
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
