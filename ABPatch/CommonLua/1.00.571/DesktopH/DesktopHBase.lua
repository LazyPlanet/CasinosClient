DesktopHBase = {}

function DesktopHBase:new(o,controller_desktoph,factory_name)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function DesktopHBase:onDestroy()
end

function DesktopHBase:onHandleEvent(ev)
end

function DesktopHBase:InitDesktopH(desktoph_data) 
end

function DesktopHBase:refreshDesktopH(desktoph_data)
end

function DesktopHBase:SeatPlayerChanged(sitdown_data)
end

function DesktopHBase:BankPlayerChanged()
end

function DesktopHBase:DesktopHChat(msg)	
end

function DesktopHBase:getMaxBetpotIndex()
end

function DesktopHBase:getBetOperateId()
end

function DesktopHBase:getMaxGoldPecent()
end

function DesktopHBase:getMaxCannotBetPecent()
end

function DesktopHBase:getOperateGold(operate_id) 
end

function DesktopHBase:getWinOrLoosePercent(card_type)
end

function DesktopHBase:getGameReusltTips(card_type, self_betgolds)
end



DesktopHBaseFactory = {}

function DesktopHBaseFactory:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self

	return o
end

function DesktopHBaseFactory:GetName()
end

function DesktopHBaseFactory:CreateDesktop(controller_desktoph,factory_name)
end        