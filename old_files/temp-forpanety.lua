-- by ISSEN / issen.zhang@outlook.com

Table_Pattern_CN = {
    "1-未分类",
    "2-滑行",
    "3-滑跑",
    "4-一边(爬升)",
    "5-一转三",
    "6-三边",
    "7-着陆准备",
    "8-四边",
    "9-五边(进近)",
    "10-着陆",
    "11-滑回",
    "12-结束" }



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
    obj.point = _point or 0
    obj.reason = _reason or ""
    obj.pattern = _pattern or 1

    -- MESSAGE:New("new:" .. obj:ToString(), 20):ToAll()
    return obj
end

function Penalty:ToString()
    local text = ""
    if self.point < 35 then
        text = Table_Pattern_CN[self.pattern] ..
            ":" .. "name:" .. self.name .. "reason:" .. self.reason .. ".. 扣分-" .. self.point
    end
    return text
end

function Penalty:Notify()
   -- MESSAGE:New("扣分升级啦：" .. self:ToString(), 30):ToAll()
end

function Penalty:Instead(_penalty)
    if _penalty.point >= self.point then
        self = _penalty
        _penalty:Notify()
    end
    return self
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
     --   USERSOUND:New("radio click.ogg"):ToAll()
    end
end

function TrainSystem:InitPatternTable(_table)
    self.table_pattern = _table
    return self
end

function TrainSystem:FindPenaltyIndex(_penalty)
     print("--penalties--")
    for index, value in ipairs(self.penalties) do
         print(value:ToString())
    end
     print("--end--")

     print("find this" .. _penalty:ToString())
    local index = 0
    if #self.penalties > 0 then
        for i, p in ipairs(self.penalties) do
             print("check:[" .. p.name .. "] ==? [" .. _penalty.name .. "]")
            if p.name == _penalty.name then
                 print("found:[" .. p.name .. "]==[" .. _penalty.name .. "]")
                index = i
            end
        end
    end
    return index
end

function TrainSystem:PenaltyToString(_penalty)
    return _penalty:ToString()
end

function TrainSystem:AddPenalty(_penalty)
     print("ready to find" .. _penalty:ToString())
    local index = self:FindPenaltyIndex(_penalty)

     print("index=" .. index)
    if index == 0 then
        if (_penalty.point or 0) > 0 then
            --self:MessageToAll("新被扣分啦：" .. self:PenaltyToString(_penalty), 30)
             print("new p.." .. _penalty:ToString())
            table.insert(self.penalties, #self.penalties + 1, _penalty)
        end
    else
        self.penalties[index] = self.penalties[index]:Instead(_penalty)
         print("rewrite p :" .. _penalty:ToString())
    end

    return self
end

function TrainSystem:AddPenaltyByDetail(_name, _point, _reason, _pattern)
    local _p = Penalty:New(_name, _point, _reason, _pattern or self.current_pattern)
     print("to be added:" .. _p:ToString())
    self:AddPenalty(_p)
    return self
end