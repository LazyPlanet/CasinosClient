ViewChatChooseTarget = ViewBase:new()

function ViewChatChooseTarget:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self
	o.ViewMgr = nil
	o.GoUi = nil
	o.ComUi = nil
	o.Panel = nil
	o.UILayer = nil
	o.InitDepth = nil
	o.ViewKey = nil

    return o
end

function ViewChatChooseTarget:onCreate()
	ViewHelper:PopUi(self.ComUi,self.ViewMgr.LanMgr:getLanValue("ChooseFriendChat"))
	self.CasinosContext = CS.Casinos.CasinosContext.Instance
	self.ControllerIM = self.ViewMgr.ControllerMgr:GetController("IM")
	local com_bg = self.ComUi:GetChild("ComBgAndClose").asCom
	local btn_close = com_bg:GetChild("BtnClose").asButton
	btn_close.onClick:Add(
		function()
			self:onClickClose()
		end
	)
	local com_shade = com_bg:GetChild("ComShade").asCom
    com_shade.onClick:Add(
		function()
			self:onClickClose()
		end
	)
	self.ControllerHaveFriend = self.ComUi:GetController("ControllerHaveFriend")
    self.GTextInputSearchTarget = self.ComUi:GetChild("TextInputSearch").asTextInput
    self.GListChatTarget = self.ComUi:GetChild("ListChatTarget").asList
    self.GListChatTarget:SetVirtual()
    self.GListChatTarget.itemRenderer = function(a,b)
		self:RenderListItemChatTarget(a,b)
	end
	self.ViewMgr:bindEvListener("EvUiClickChooseFriend",self)
end

function ViewChatChooseTarget:onDestroy()
	self.ViewMgr:unbindEvListener(self)
end

function ViewChatChooseTarget:onHandleEv(ev)
	if(ev ~= nil)
	then
		if (ev.EventName == "EvUiClickChooseFriend")
		then
			self:onClickClose()
		end
	end
end

function ViewChatChooseTarget:setFriendInfo(map_frienditem)
	if (map_frienditem == nil or LuaHelper:GetTableCount(map_frienditem) == 0)
	then
		self.ControllerHaveFriend.selectedIndex = 1
        return
	end
    self.ControllerHaveFriend.selectedIndex = 0
    self.GListChatTarget.numItems = LuaHelper:GetTableCount(map_frienditem)
end

function ViewChatChooseTarget:RenderListItemChatTarget(index, obj)
	local list_have_record_friend = self.ControllerIM.IMFriendList.ListFriendGuid
	local com = CS.Casinos.LuaHelper.GObjectCastToGCom(obj)
    if (self.CasinosContext.UseLan)
	then
		self.ViewMgr.LanMgr:parseComponent(com)
	end
    local item = ItemChooseChatTargetInfo:new(nil,com,self.ControllerIM)
    if (#list_have_record_friend > index)
	then
		local friend_guid = list_have_record_friend[index + 1]
        local player_info = self.ControllerIM.IMFriendList.MapFriendList[friend_guid]
        if (player_info ~= nil)
		then
			item:setFriendInfo(player_info)
		end
	end
end

function ViewChatChooseTarget:onClickClose()
	self.ViewMgr:destroyView(self)
end



ViewChatChooseTargetFactory = ViewFactory:new()

function ViewChatChooseTargetFactory:new(o,ui_package_name,ui_component_name,
	ui_layer,is_single,fit_screen)
	o = o or {}  
    setmetatable(o,self)  
    self.__index = self
	self.PackageName = ui_package_name
	self.ComponentName = ui_component_name
	self.UILayer = ui_layer
	self.IsSingle = is_single
	self.FitScreen = fit_screen
    return o
end

function ViewChatChooseTargetFactory:createView()	
	local view = ViewChatChooseTarget:new(nil)	
	return view
end