ForestPartyBanker{}

function ForestPartyBanker:new(o,com)
    o = o or {}
    setmetatable(o,self)
    self.__index = self	
	self.ComBanker = com
    local com_headIcon = self.ComBanker:GetChild("ComHeadIcon").asCom
    self.BankerHeadIcon = ViewHeadIcon:new(nil,com_headIcon,
		function()
			self:onClickHeadIcon()
		end
	)
    self.TextName = self.ComBanker:GetChild("TextName").asTextField
    self.TextGold = self.ComBanker:GetChild("TextGold").asTextField
    self.TextBureau = self.ComBanker:GetChild("TextBureau").asTextField
    self.TextBeBankerLimitMin = self.ComBanker:GetChild("TextBeBankerLimitMin").asTextField
    self.ControllerBanker = self.ComBanker:GetController("ControllerBanker")
    self:SetBankerInfo()
    return o
end

function ForestPartyBanker:SetBankerInfo()
	local banker_data = ControllerForestParty.BankerData
    local player_guid = banker_data.PlayerInfoCommon.PlayerGuid
    self.TextName.text = banker_data.PlayerInfoCommon.NickName
    self.BankerHeadIcon:setPlayerInfo(banker_data.PlayerInfoCommon.IconName,
        banker_data.PlayerInfoCommon.AccountId, banker_data.PlayerInfoCommon.VIPLevel)
    if (player_guid == nil)
	then
		self.ControllerBanker:SetSelectedIndex(1)
        self.TextBeBankerLimitMin.text = CS.Casinos.CasinosContext.Instance.UiChipShowHelper:getGoldShowStr
            (ControllerForestParty.TbdataDeskTop.BeBankerLimit, CS.Casinos.CasinosContext.Instance.LanMgr.LanBase, true, 0)
	else
	then
		self.ControllerBanker:SetSelectedIndex(0)
        self.TextGold.text = CS.Casinos.CasinosContext.Instance.UiChipShowHelper:getGoldShowStr(banker_data.Gold, CS.Casinos.CasinosContext.Instance.LanMgr.LanBase)
        self.TextBureau.text = banker_data.Bureau.ToString()
	end
end

function ForestPartyBanker:onClickHeadIcon()
	local view_mgr = ViewMgr:new(nil)
	view_mgr.createView("PlayerProfile")
end

