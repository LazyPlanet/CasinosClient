ViewOnlineReward = {}

function ViewOnlineReward:new(o,co_onlinereward,view_mgr)
    o = o or {}
    setmetatable(o,self)
    self.__index = self
	self.ViewMgr = view_mgr
	o.GCoOnlineReward = co_onlinereward
    o.GTextOnlineCountDownTm = o.GCoOnlineReward:GetChild("TextOnlineReward").asTextField
    o.GCoOnlineReward.onClick:Add(
		function()
			o:onClickOnlineReward()
		end
	)
    return o
end

function ViewOnlineReward:setCanGetReward(can_get_reward)
	self:switchController(can_get_reward)
end

function ViewOnlineReward:switchController(can_get_reward)
	self.GTextOnlineCountDownTm.text = self.ViewMgr.LanMgr:getLanValue("Take")
end

function ViewOnlineReward:setLeftTm(left_tm)
	self.GTextOnlineCountDownTm.text = left_tm
end

function ViewOnlineReward:onClickOnlineReward()
	local ev = self.ViewMgr:getEv("EvOnGetOnLineReward")
	if(ev == nil)
	then
		ev = EvOnGetOnLineReward:new(nil)
	end
	self.ViewMgr:sendEv(ev)
end