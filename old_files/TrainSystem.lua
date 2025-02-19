-- by ISSEN / issen.zhang@outlook.com
-- 基于扣分制的评分脚本

function append_string(string, append)
    return string + append + "\n"
end

Penalty =
{
    name = "",
    point = 0,
    pattern = 1,
    reason = "未写明",
    value = nil
}

function Penalty:New(_name, _point, _reason, _pattern)
    local obj = Penalty
    obj.name = _name or ""
    obj.point = _point
    obj.reason = _reason
    obj.pattern = _pattern

    MESSAGE:New("new:" .. obj:ToString(), 20):ToAll()
    return obj
end

function Penalty:ToString()
    local text = ""
    if self.point < 35 then
        text = self.reason .. ".. 扣分-" .. self.point
    end
    return text
end

function Penalty:Instead(_penalty)
    if _penalty.point >= self.point then
        self = _penalty
        MESSAGE:New("扣分啦：" .. _penalty:ToString(), 30):ToAll()
    end
    return self
end

function Penalty:IsNeedInstead(_penalty)
    if _penalty.point >= self.point then
        self = _penalty
        return true
    else
        return false
    end
end

TrainSystem =
{
    _debug_mode           = true,
    _unit                 = nil,
    _client               = nil,

    current_pattern       = 1, --当前飞行流程
    table_pattern         = {},

    full_score            = 35,
    pass_score            = 28,
    penalties             = {},

    time_train_start      = nil,
    time_train_stop       = nil,

    timer_train           = nil,
    main_timer_detla_time = 1,

    alt_delta             = -30,

    is_penalty_info       = true,
}

function TrainSystem:New(_unit_name)
    local self = BASE:Inherit(self, BASE:New())

    self._unit = UNIT:FindByName(_unit_name)
    self._client = self._unit:GetClient()

    return self
end

function TrainSystem:MessageToUnit(msg, duration)
    local m = MESSAGE:New(msg, duration)
    if debug == true then
        m:ToAll()
    else
        if self._unit ~= nil then
            m:ToUnit()
        end
        return self
    end
end

function TrainSystem:MessageToAll(_msg, _dur, _isSound, _isClear)
    local msg = string.format("%s", _msg) or ""
    local dur = _dur or 30
    local isSound = _isSound or false
    local isClear = _isClear or false

    local m = MESSAGE:New(msg, dur)
    if isClear == true
    then
        m:Clear():ToAll()
    else
        m:ToAll()
    end
    if isSound then
        USERSOUND:New("radio click.ogg"):ToAll()
    end
end

function TrainSystem:InitPatternTable(_table)
    self.table_pattern = _table
    return self
end

function TrainSystem:FindPenaltyIndex(_penalty)
    local index = 0
    for i, p in ipairs(self.penalties) do
        if p.name == _penalty.name then
            index = i
        end
    end
    return index
end

function TrainSystem:PenaltyToString(_penalty)
    return self:GetCurrentPattern() .. " - " .. _penalty:ToString()
end

function TrainSystem:AddPenalty(_penalty)
    local index = self:FindPenaltyIndex(_penalty) or 0
    if index == 0 then
        if (_penalty.point or 0) > 0 then
            self:MessageToAll("扣分啦：" .. self:PenaltyToString(_penalty), 30)
            table.insert(self.penalties, #self.penalties + 1, _penalty)
        end
    else
        self.penalties[index] = self.penalties[index]:Instead(_penalty)
    end

    return self
end

function TrainSystem:AddPenaltyByDetail(_name, _point, _reason, _pattern)
    local _penalty = Penalty:New(_name, _point, _reason, _pattern)
    self:AddPenalty(_penalty)
    return self
end

function TrainSystem:GetScore()
    local score = self.full_score
    for _, p in ipairs(self.penalties) do
        if p.failed == true then
            return 0
        else
            score = score - p.point
        end
    end

    if score <= 0 then
        return 0
    else
        return score
    end
end

function TrainSystem:GetReport()
    local text = ""

    --text:append(self._client:GetPlayer() " - 总分: " .. self:GetScore() .. "/35")
    append_string(text, "--------------------")

    for _, p in ipairs(self.penalties) do
        append_string(text, p:ToString())
    end
    return text
end

function TrainSystem:GetCurrentPattern()
    return self.table_pattern[self.current_pattern]
end

function TrainSystem:CheckDuration(_func, _duration, _penalty)
    local judge = 0
    TIMER:New(
        function()
            if _func == true then
                judge = judge + 1
            end
        end
    ):Start(0, self.main_timer_detla_time, _duration)
    if judge >= _duration / self.main_timer_detla_time
    then
        TrainSystem:AddPenalty(_penalty)
    end
end

function TrainSystem:IsInZone(zone_name)
    return self._unit:IsInZone(ZONE:New(zone_name))
end

function TrainSystem:IsNotInZone(zone_name)
    return self._unit:IsNotInZone(ZONE:New(zone_name))
end

function TrainSystem:GetAltitude(isRadarAlt)
    if isRadarAlt == true then
        return UTILS.Round(self._unit:GetAltitude(true), 2)
    else
        return UTILS.Round(self._unit:GetAltitude(false) + self.alt_delta, 2)
    end
end

function TrainSystem:GetIAS()
    return UTILS.Round(UTILS.MpsToKmph(self._unit:GetAirspeedIndicated()), 2)
end

function TrainSystem:GetSpeed()
    return UTILS.Round(self._unit:GetVelocityKMH(), 2)
end

function TrainSystem:GetVV()
    return UTILS.Round(self._unit:GetVelocityVec3().y, 2)
end

function TrainSystem:GetRoll()
    return UTILS.Round(self._unit:GetRoll(), 2)
end

function TrainSystem:GetPitch()
    return UTILS.Round(self._unit:GetPitch(), 2)
end

function TrainSystem:GetHeading()
    return UTILS.Round(self._unit:GetHeading(), 2)
end

function TrainSystem:ToStringData()
    local _msg = ""

    _msg = append_string(_msg, "UnitName: " .. self._unit:Name())
    if self._client ~= nil then
        append_string(_msg, "ClientName: " .. self._client:GetName())
    end
    _msg = append_string(_msg, "Current Pattern: " .. self:GetCurrentPattern())

    local is_air = ""
    if self._unit:InAir() == true then
        is_air = "In Air"
    else
        is_air = "Groung"
    end
    _msg = append_string(_msg, "IsAir: " .. is_air .. "")

    _msg = append_string(_msg, "R/A: " .. self:GetAltitude(true) .. " m")
    _msg = append_string(_msg, "B/A: " .. self:GetAltitude(false) .. " m")

    _msg = append_string(_msg, "IAS: " .. self:GetIAS() .. " km/h")
    _msg = append_string(_msg, "Speed: " .. self:GetSpeed() .. " km/h")
    _msg = append_string(_msg, "V/V: " .. self:GetVV() .. " m/s")


    _msg = append_string(_msg, "Roll: " .. self:GetRoll() .. " degree")
    _msg = append_string(_msg, "Pitch: " .. self:GetPitch() .. " degree")
    _msg = append_string(_msg, "Heading: " .. self:GetHeading() .. " degree")

    _msg = append_string(_msg, "#Penalties: " .. #self.penalties)

    if #self.penalties >= 1 then
        _msg = append_string(_msg, "Last Penalty:\n" .. self:PenaltyToString(self.penalties[#self.penalties]))
    else
        _msg = append_string(_msg, "No Penalty yet.")
    end

    return _msg
end

function TrainSystem:SetDebugMode(debug_mode)
    self._debug_mode = debug_mode
    return self
end

function TrainSystem:ToggleDebugMode()
    if self._debug_mode == true then
        self._debug_mode = false
    else
        self._debug_mode = true
    end
    return self
end
