-- by ISSEN / issen.gamming@outlook.com
Table_Pattern_CN = { "1-未分类", "2-滑行", "3-滑跑", "4-一边(爬升)", "5-一转三", "6-三边",
    "7-着陆准备", "8-四边", "9-五边(进近)", "10-着陆", "11-滑回", "12-结束" }

-- by ISSEN / issen.zhang@outlook.com
-- 基于扣分制的评分脚本

function append_string(string, append)
    return string .. (append or "") .. "\n"
end

Penalty = {
    name = "",
    point = 0,
    pattern = "",
    reason = "未写明",
    value = nil
}
Penalty.__index = Penalty

function Penalty:New(_name, _point, _reason, _value, _pattern)
    local self = BASE:Inherit(self, BASE:New())

    self.name = _name or ""
    self.point = _point or 0
    self.reason = _reason or ""
    self.pattern = _pattern or ""
    self.value = _value or 0

    return self
end

function Penalty:ToString()
    local text = ""

    text = ".. -" .. self.point .. " .. 阶段: " .. self.pattern .. " 原因: " .. self.reason
    if self.value ~= nil then
        text = text .. "(" .. self.value .. ")"
    end

    return text
end

function Penalty:Notify()
    -- MESSAGE:New("扣分啦：" .. _penalty:ToString(), 30):ToAll()
end

function Penalty:Instead(_penalty)
    if _penalty.point > self.point then
        self = _penalty
        -- _penalty:Notify()
    end
    return self
end

function Penalty:IsNeedInstead(_penalty)
    if _penalty.point > self.point then
        return true
    else
        return false
    end
end

TrainSystem = {
    _debug_mode = true,
    _unit = nil,
    _client = nil,

    current_pattern = 1, -- 当前飞行流程
    table_pattern = {},

    full_score = 35,
    pass_score = 28,
    penalties = {},

    time_train_start = nil,
    time_train_stop = nil,

    timer_train = nil,
    main_timer_detla_time = 1,

    alt_delta = -30,

    is_penalty_info = true
}

function TrainSystem:New(_unit_name, _table_attern)
    local self = BASE:Inherit(self, BASE:New())

    self._unit = UNIT:FindByName(_unit_name)

    self.table_pattern = _table_attern

    return self
end

--[[ function TrainSystem:MessageToUnit(msg, duration)
    local m = MESSAGE:New(msg, duration)
    if debug == true then
        m:ToAll()
    else
        if self._unit ~= nil then
            m:ToUnit()
        end
        return self
    end
end ]]

function TrainSystem:MessageToAll(_msg, _dur, _isSound, _isClear)
    local msg = string.format("%s", _msg) or ""
    local dur = _dur or 30
    local isSound = _isSound or false
    local isClear = _isClear or false

    local m = MESSAGE:New(msg, dur)
    if isClear == true then
        m:Clear():ToAll()
    else
        m:ToAll()
    end
    if isSound then
        USERSOUND:New("radio click.ogg"):ToAll()
    end
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

function TrainSystem:AddPenalty(_penalty)
    local index = self:FindPenaltyIndex(_penalty) or 0
    if index == 0 then
        if (_penalty.point or 0) > 0 then
            table.insert(self.penalties, #self.penalties + 1, _penalty)
        end
    else
        if (self.penalties[index]:IsNeedInstead(_penalty)) then
            table.remove(self.penalties, index)
            table.insert(self.penalties, #self.penalties + 1, _penalty)
        end
    end

    return self
end

function TrainSystem:AddPenaltyByDetail(_name, _point, _reason, _value, _pattern_num)
    local _penalty =
        Penalty:New(_name, _point, _reason, _value, self.table_pattern[_pattern_num or self.current_pattern])
    self:AddPenalty(_penalty)
    return self
end

function TrainSystem:GetPanaltyScore()
    local pp = 0
    for _, p in ipairs(self.penalties) do
        pp = pp + p.point
    end
    if pp > self.full_score then
        return self.full_score
    else
        return pp
    end
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

    text = append_string(text, "-----------成绩单-----------")
    text = append_string(text, "总分: " .. self:GetScore() .. "/35")
    text = append_string(text, "扣分细则:")
    for _, p in ipairs(self.penalties) do
        text = append_string(text, p:ToString())
    end
    return text
end

function TrainSystem:GetCurrentPattern()
    return self.table_pattern[self.current_pattern]
end

function TrainSystem:CheckDuration(_func, _duration, _penalty)
    local judge = 0
    TIMER:New(function()
        if _func == true then
            judge = judge + 1
        end
    end):Start(0, self.main_timer_detla_time, _duration)
    if judge >= _duration / self.main_timer_detla_time then
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

function TrainSystem:InAir()
    return self._unit:InAir()
end

function TrainSystem:ToStringData()
    local _msg = ""

    _msg = append_string(_msg, "UnitName: " .. self._unit:Name())
    if self._client ~= nil then
        append_string(_msg, "ClientName: " .. self._client:GetName())
    end
    _msg = append_string(_msg, "Current Pattern: " .. self:GetCurrentPattern())

    local is_air = ""
    if self:InAir() == true then
        is_air = "In Air"
    else
        is_air = "Ground"
    end
    _msg = append_string(_msg, "InAir: " .. is_air .. "")

    _msg = append_string(_msg, "R/A: " .. self:GetAltitude(true) .. " m")
    _msg = append_string(_msg, "B/A: " .. self:GetAltitude(false) .. " m")

    _msg = append_string(_msg, "IAS: " .. self:GetIAS() .. " km/h")
    _msg = append_string(_msg, "Speed: " .. self:GetSpeed() .. " km/h")
    _msg = append_string(_msg, "V/V: " .. self:GetVV() .. " m/s")

    _msg = append_string(_msg, "Roll: " .. self:GetRoll() .. " degree")
    _msg = append_string(_msg, "Pitch: " .. self:GetPitch() .. " degree")
    _msg = append_string(_msg, "Heading: " .. self:GetHeading() .. " degree")

    _msg = append_string(_msg, "ClimbCheck: " .. self:GetHeading() .. " degree")

    _msg = append_string(_msg, "-------------------")
    _msg = append_string(_msg, "当前累计扣分: " .. self:GetPanaltyScore())
    -- _msg = append_string(_msg, "#Penalties: " .. #self.penalties)
    _msg = append_string(_msg, "总扣分条目: " .. #self.penalties)

    if #self.penalties >= 1 then
        _msg = append_string(_msg, "最近的扣分项:\n" .. self.penalties[#self.penalties]:ToString())
    else
        _msg = append_string(_msg, "还没被扣分呢(骄傲~)")
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

L39 = {
    is_check_climb = false,
    is_checked_7km = false,
    is_checked_final_outer = false,
    is_checked_final_inner = false,

    height_7km = 0,
    height_final_outer = 0,
    height_final_inner = 0
}

function L39:New(_unit_name)
    local self = BASE:Inherit(self, TrainSystem:New(_unit_name, Table_Pattern_CN))
    self.full_score = 35
    self.pass_score = 28

    return self
end

function L39:CheckPattern_Taxi()
    local MAX_GROUND_SPEED = 60
    local MAX_GROUND_TURNING_SPEED = 20
    local groun_speed = self:GetSpeed()

    if self:IsInZone("z-taxi-s-1") or self:IsInZone("z-taxi-s-2") then
        if groun_speed >= MAX_GROUND_SPEED * 1.5 then
            self:AddPenaltyByDetail("taxi_overspeed", 5, "滑行超速50%~", groun_speed)
        elseif groun_speed >= MAX_GROUND_SPEED * 1.25 then
            self:AddPenaltyByDetail("taxi_overspeed", 2, "滑行超速25%~50%", groun_speed)
        elseif groun_speed >= MAX_GROUND_SPEED then
            self:AddPenaltyByDetail("taxi_overspeed", 1, "滑行超速0%~25%", groun_speed)
        end
    end

    if self:IsInZone("z-taxi-s-1") and self:IsNotInZone("z-taxi-s-c-1") then
        self:AddPenaltyByDetail("taxi_notcenter", 5, "滑行未压中线")
    end

    if self:IsInZone("z-taxi-s-2") and self:IsNotInZone("z-taxi-s-c-2") then
        self:AddPenaltyByDetail("taxi_notcenter", 5, "滑行未压中线")
    end

    if self:IsInZone("z-taxi-turning") then
        if groun_speed >= MAX_GROUND_TURNING_SPEED * 1.5 then
            self:AddPenaltyByDetail("taxi_overspeed", 5, "滑行超速50%~(转弯)", groun_speed)
        elseif groun_speed >= MAX_GROUND_TURNING_SPEED * 1.25 then
            self:AddPenaltyByDetail("taxi_overspeed", 2, "滑行超速25%~50%(转弯)", groun_speed)
        elseif groun_speed >= MAX_GROUND_TURNING_SPEED then
            self:AddPenaltyByDetail("taxi_overspeed", 1, "滑行超速0%~25%(转弯)", groun_speed)
        end
    end

    if groun_speed >= 260 then
        self:AddPenaltyByDetail("taxi_not_rolling_takeoff", 35, "非标准起飞", groun_speed)
    end
    return self
end

function L39:CheckPattern_Rolling()
    -- 起飞俯仰检测起始值
    local SPEED_ROLLING_PITCH = 120

    -- 最大滑跑速度
    local SPEED_ROLLING_MAX = 230

    local speed = self:GetSpeed()
    local pitch = self:GetPitch()

    if speed >= SPEED_ROLLING_PITCH then
        if pitch >= 15 then
            self:AddPenaltyByDetail("rolling_pitch", 3, "滑跑迎角≥15°", pitch)
        elseif pitch >= 10 then
            self:AddPenaltyByDetail("rolling_pitch", 1, "滑跑迎角≥10°", pitch)
        end
    end

    local ZONE_ROLLING_2 = "z-rolling-2"
    local ZONE_ROLLING_1 = "z-rolling-1"

    if self:IsNotInZone(ZONE_ROLLING_2) == true then
        self:AddPenaltyByDetail("rolling_angle", 2, "滑跑偏航≥5°")
    elseif self:IsNotInZone(ZONE_ROLLING_1) == true then
        self:AddPenaltyByDetail("rolling_angle", 1, "滑跑偏航≥3°")
    end

    -- 非正式监测项目
    if speed >= SPEED_ROLLING_MAX then
        self:AddPenaltyByDetail("error_flag_takeoff", 3, "滑跑超速或襟翼位置不正确")
    end
    return self
end

function L39:CheckPattern_Upwind()
    if self:IsInZone("z-takeoff-check") then
        if self:IsNotInZone("z-takeoff-2") == true then
            self:AddPenaltyByDetail("takeoff_angle", 2, "起飞偏航≥5°")
        elseif self:IsNotInZone("z-takeoff-1") == true then
            self:AddPenaltyByDetail("takeoff_angle", 1, "起飞偏航≥3°")
        end
    end

    local height = self:GetAltitude(true) -- 用雷达高度替代
    -- 起飞超高不转向
    local HEIGHT_TAKEOFF_MAX = 450 + 90
    if height > HEIGHT_TAKEOFF_MAX then
        self:AddPenaltyByDetail("takeoff_height", 2, "高度450m仍未转向")
    end

    -- 起飞反复接地
    if self:InAir() == false then
        self:AddPenaltyByDetail("takeoff_touchground", 5, "起飞反复接地")
    end
    return self
end

function L39:CheckPattern_Crosswind()
    -- 一转三坡度
    local roll = math.abs(self:GetRoll())
    local ROLL_MAX_2 = 45
    local ROLL_MAX_1 = 35
    if roll >= ROLL_MAX_2 then
        self:AddPenaltyByDetail("upwind_roll", 2, "一转三坡度≥45°", roll)
    elseif roll >= ROLL_MAX_1 then
        self:AddPenaltyByDetail("upwind_roll", 1, "一转三坡度≥35", roll)
    end
    return self
end

function L39:CheckPattern_Climb()
    local vv = self:GetVV()
    local height = self:GetAltitude()
    if vv <= -1 and height <= 550 then
        self:AddPenaltyByDetail("climb_error", 35, "爬升阶段中掉高", height)
    end
end

function L39:CheckPattern_Downwind()
    local ias = self:GetIAS()
    if ias <= 350 then
        self:AddPenaltyByDetail("downwind_lowspeed", 3, "三边空速≤350Km/h", ias)
    elseif ias <= 380 then
        self:AddPenaltyByDetail("downwind_lowspeed", 1, "三边空速≤380Km/h", ias)
    end

    if ias >= 450 then
        self:AddPenaltyByDetail("downwind_overspeed", 3, "三边空速≥450Km/h", ias)
    elseif ias >= 420 then
        self:AddPenaltyByDetail("downwind_overspeed", 1, "三边空速≥420Km/h", ias)
    end

    local height = self:GetAltitude(false) - 15
    if height >= 650 then
        self:AddPenaltyByDetail("downwind_toohigh", 3, "三边高度≥650m", height)
    elseif height >= 620 then
        self:AddPenaltyByDetail("downwind_toohigh", 1, "三边高度≥620m", height)
    end

    if height <= 550 then
        self:AddPenaltyByDetail("downwind_toolow", 3, "三边高度≤550m", height)
    elseif height <= 580 then
        self:AddPenaltyByDetail("downwind_toolow", 1, "三边高度≤580m", height)
    end

    local heading = self._unit:GetHeading(false)
    local heading_delta = math.abs(267 - heading)
    if heading_delta > 5 then
        self:AddPenaltyByDetail("downwind_angle", 2, "三边偏航>5°", heading)
    elseif heading_delta > 3 then
        self:AddPenaltyByDetail("downwind_angle", 1, "三边偏航>3°", heading)
    end

    return self
end

function L39:CheckPattern_PreBase()
    local heading = self._unit:GetHeading(true)
    local heading_delta = math.abs(267 - heading)
    if heading_delta > 5 then
        self:AddPenaltyByDetail("prebase_angle", 2, "减速过程偏航>5°", heading)
    elseif heading_delta > 3 then
        self:AddPenaltyByDetail("prebase_angle", 1, "减速过程偏航>3°", heading)
    end

    local height = self:GetAltitude(true) - 15
    if height >= 650 then
        self:AddPenaltyByDetail("prebase_toohigh", 3, "减速过程高度≥650m", height)
    elseif height >= 620 then
        self:AddPenaltyByDetail("prebase_toohigh", 1, "减速过程高度≥620m", height)
    end

    if height <= 550 then
        self:AddPenaltyByDetail("prebase_toolow", 3, "减速过程高度≤550m", height)
    elseif height <= 580 then
        self:AddPenaltyByDetail("prebase_toolow", 1, "减速过程高度≤580m", height)
    end

    local speed = self:GetSpeed()
    local ZONE_GEARDOWN = "z-geardown"
    if self:IsInZone(ZONE_GEARDOWN) and speed >= 380 then
        self:AddPenaltyByDetail("prebase_toolong", 3, "NDB过250°未减速")
    end
    return self
end

function L39:CheckPattern_Base()
    local ias = self:GetSpeed()
    if ias >= 300 then
        self:AddPenaltyByDetail("base_overspeed", 3, "二转空速≥300Km/h", ias)
    elseif ias <= 200 then
        self:AddPenaltyByDetail("base_overspeed", 1, "二转空速≤200Km/h", ias)
    end

    local climb = self:GetVV()
    if climb > 1.0 then
        self:AddPenaltyByDetail("base_climb", 35, "二转出现爬升", climb)
    end

    local height = self:GetAltitude(true)
    local distance = self._unit:GetCoordinate():Get2DDistance(ZONE:New("z-10km"):GetCoordinate())
    if height <= 300 and distance > 10000 then
        self:AddPenaltyByDetail("base_toolow", 35, "二转过低(<300m)", height)
    end
    return self
end

function L39:CheckPattern_Final()
    local ias = self:GetIAS()
    if ias >= 300 then
        self:AddPenaltyByDetail("final_overspeed", 3, "进近空速≥300Km/h", ias)
    elseif ias <= 280 then
        self:AddPenaltyByDetail("final_overspeed", 1, "进近空速≤200Km/h", ias)
    end

    local climb = self:GetVV()
    if climb > 1.0 then
        self:AddPenaltyByDetail("final_climb", 35, "进近出现爬升", climb)
    end

    local height = self:GetAltitude(true)
    local distance = self._unit:GetCoordinate():Get2DDistance(ZONE:New("z-10km"):GetCoordinate())
    if height <= 300 and distance > 10000 then
        self:AddPenaltyByDetail("final_10km_toolow", 35, "10km进近过低(<300m)", height)
    end

    if self:IsInZone("z-final-7km") and self.is_checked_7km == false then
        if self:IsInZone("z-7km-aim") == true then
            self:AddPenaltyByDetail("final-7km", 3, "7km未对准跑道")
        end
        self.is_checked_7km = true
    end

    if self:IsInZone("z-final-outer") and self.is_checked_final_outer == false then
        MESSAGE:New("远台高度: " .. height .. "m", 20):ToClient(self._client)

        self.height_final_outer = height
        if height >= 230 then
            self:AddPenaltyByDetail("final_outer_high", 2, "远台高度≥230m", height)
        elseif height <= 120 then
            self:AddPenaltyByDetail("final_outer_low", 2, "远台高度≤120m", height)
        end
        self.is_checked_final_outer = true
    end

    if self:IsInZone("z-final-inner") and self.is_checked_final_inner == false then
        self.height_final_inner = height
        MESSAGE:New("近台高度: " .. height .. "m", 20):ToClient(self._client)
        if height >= 110 then
            self:AddPenaltyByDetail("final_inner_high", 2, "近台高度≥110m", height)
        elseif height <= 40 then
            self:AddPenaltyByDetail("final_inner_low", 2, "近台高度≤40m", height)
        end
        self.is_checked_final_inner = true
    end

    -- 拉漂判断 -- TBD
    return self
end

-- 触地判断
function L39:CheckPattern_Landing()
    if self:IsNotInZone("z-landing-aim") then
        self:AddPenaltyByDetail("landing_not_in_area", 3, "着陆超出接地区")
    end

    if self:IsNotInZone("z-rolling-center") then
        self:AddPenaltyByDetail("landing_not_aim_center", 35, "着陆未压中线")
    end
    return self
end

function L39:CheckPattern_AfterLanding()
    if self:InAir() == true then
        self:AddPenaltyByDetail("repeat_landing", 3, "着陆弹跳")
    end

    if self:IsNotInZone("z-rolling-center") == true then
        self:AddPenaltyByDetail("landing_center", 35, "接地,滑行未保持中线")
    end
    return self
end

function L39:CheckPattern_TaxiBack()
    local ground_speed = self._unit:GetVelocityKMH()
    local MAX_GROUND_SPEED = 60

    if ground_speed >= MAX_GROUND_SPEED * 1.5 then
        self:AddPenaltyByDetail("taxi_back_overspeed", 5, "滑行超速50%~")
    elseif ground_speed >= MAX_GROUND_SPEED * 1.25 then
        self:AddPenaltyByDetail("taxi_back_overspeed", 2, "滑行超速25%~50%")
    elseif ground_speed >= MAX_GROUND_SPEED then
        self:AddPenaltyByDetail("taxi_back_overspeed", 1, "滑行超速0%~25%")
    end

    if self:IsInZone("z-miss-exit") == true then
        self:AddPenaltyByDetail("miss_exit", 3, "错过滑行道")
    end
    return self
end

function L39:CheckOutBound()
    if self:CheckTrainning() == true then
        if self:IsNotInZone("z-trainning") then
            self:AddPenaltyByDetail("outbound", 35, "离开训练区域")
            self:TrainStop()
        end
    end
    return self
end

function L39:ControlStatus_Taxi()
    self:CheckPattern_Taxi()

    local ground_speed = self._unit:GetVelocityKMH()
    if (self:IsInZone("z-pre-takeoff")) and ground_speed < 3 then -- 添加快速起飞区域
        self.current_pattern = 3
        return true
    end
    return false
end

function L39:ControlStatus_Rolling()
    self:CheckPattern_Taxi()

    if self._unit:InAir() == true then
        self.current_pattern = 4
        self.is_check_climb = true
        return true
    end
    return false
end

function L39:ControlStatus_Upwind()
    self:CheckPattern_Upwind()

    local height = self:GetAltitude(true)
    local ias = self:GetIAS()
    local roll = math.abs(self:GetRoll())

    if height > 350 and ias > 350 and roll > 10 then
        self.current_pattern = 5
        return true
    end
    return false
end

function L39:ControlStatus_Climb()
    if self.is_check_climb == true then
        self:CheckPattern_Climb()
    end

    local height = self:GetAltitude(true)
    if self.current_pattern == 4 or self.current_pattern == 5 or self.current_pattern == 6 then
        if height > 540 then
            self.is_check_climb = false
        end
    end
end

function L39:ControlStatus_CrossWind()
    self:CheckPattern_Crosswind()

    local height = self:GetAltitude(true)
    local roll = math.abs(self:GetRoll())

    if height >= 580 and roll <= 5 then
        self.current_pattern = 6
        return true
    end
    return false
end

function L39:ControlStatus_DownWind()
    self:CheckPattern_Downwind()

    if self:IsInZone("z-pre-landing") then
        self.current_pattern = 7
        return true
    end
    return false
end

function L39:ControlStatus_PreBase()
    self:CheckPattern_PreBase()

    local roll = math.abs(self:GetRoll())
    if roll >= 12 then
        self.current_pattern = 8
        return true
    end
    return false
end

function L39:ControlStatus_Base()
    self:CheckPattern_Base()

    local roll = math.abs(self:GetRoll())
    local heading = self._unit:GetHeading()
    local heading_delta = math.abs(87 - heading)
    if roll <= 10 and heading_delta <= 10 and self:IsInZone("z-final") then
        self.current_pattern = 9
        return true
    end
    return false
end

function L39:ControlStatus_Final()
    self:CheckPattern_Final()

    if self:InAir() == false then
        self.current_pattern = 10

        -- 检查着陆点位置以及接地姿态(仅瞬时检测一次)
        self:CheckPattern_Landing()
        return true
    end
    return false
end

function L39:ControlStatus_AfterLanding()
    self:CheckPattern_AfterLanding()

    local ground_speed = self._unit:GetVelocityKMH()

    if ground_speed <= 55 then
        self.current_pattern = 11
        return true
    end
    return false
end

function L39:ControlStatus_TaxiBack()
    self:CheckPattern_TaxiBack()

    if self:IsInZone("z-end") == true then
        self.current_pattern = 12
        return true
    end

    return false
end

function L39:ShowDebugData()
    if self._debug_mode == true then
        local msg = self:ToStringData()
        if self.current_pattern < 12 then
            MESSAGE:New(msg, 1):Clear():ToAll()
            env.info("----------")
            for _, p in ipairs(self.penalties) do
                env.info(p:ToString())
            end
        end
    end
    return self
end

function L39:CheckTrainning()
    if self.current_pattern >= 2 and self.current_pattern <= 11 then
        return true
    else
        return false
    end
end

function L39:CallStatus()
    -- if self._debug_mode == true then
    --     self:ShowDebugData()
    -- end

    self:ShowDebugData()

    if self.current_pattern == 2 then
        self:ControlStatus_Taxi()
    elseif self.current_pattern == 3 then
        self:ControlStatus_Rolling()
    elseif self.current_pattern == 4 then
        self:ControlStatus_Upwind()
    elseif self.current_pattern == 5 then
        self:ControlStatus_CrossWind()
    elseif self.current_pattern == 6 then
        self:ControlStatus_DownWind()
    elseif self.current_pattern == 7 then
        self:ControlStatus_PreBase()
    elseif self.current_pattern == 8 then
        self:ControlStatus_Base()
    elseif self.current_pattern == 9 then
        self:ControlStatus_Final()
    elseif self.current_pattern == 10 then
        self:ControlStatus_AfterLanding()
    elseif self.current_pattern == 11 then
        self:ControlStatus_TaxiBack()
    elseif self.current_pattern == 12 then
        self:TrainStop()
    end

    if self.check_climb == true then
        self:CheckPattern_Climb()
    end

    return self
end

function L39:TrainStart()
    local msg = ""
    if self.current_pattern == 1 or self.current_pattern == 12 then
        msg = append_string(msg, self._unit:GetPlayerName() .. "开始五边模拟考核,祝次次压中线")
        MESSAGE:New(msg, 30, nil, true):ToClient(self._client)
        self.current_pattern = 2
        self.timer_train = TIMER:New(self.CallStatus, self):Start(0, self.main_timer_detla_time)
        self:SetDebugMode(true)
        return self
    else
        msg = append_string(msg,
            self._client.Name() " .. 已经在考试阶段中(状态:" .. self:GetCurrentPattern() .. ")")
        return self
    end
end

function L39:TrainStop()
    self.timer_train:Stop()
    local msg = ""
    msg = append_string(msg, "考核结束!")
    msg = append_string(msg, self:GetReport())
    MESSAGE:New(msg, 60, nil, true):ToAll()
end

local set_clients = SET_CLIENT:New():FilterActive():FilterCategories("plane"):FilterStart()
local set_inTraining = SET_CLIENT:New()

function init_test(client)
    if set_inTraining:IsNotInSet(client) then
        set_inTraining:AddClientsByName(client:GetName())
        local l39 = L39:New(client:GetName())
        l39:TrainStart()
    end
end

-- local timer_mission = TIMER:New(
--     function()
--         set_clients:ForEachClientInZone(ZONE:New("z-init"), init_test)
--     end):Start(0, 1)

local timer_mission = TIMER:New(function()
    local clients = set_clients:GetSetObjects()
    for _, v in ipairs(clients) do
        if v:IsInZone(ZONE:New("z-init")) == true then
            init_test(v)
        end
    end
end):Start(0, 1)
