ItemDesktopHSeat = {}

function ItemDesktopHSeat:new(o,co_chair,view_mgr)
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    o.ViewMgr = view_mgr
     o.GCoChair = co_chair
            local co_headicon = o.GCoChair:GetChild("CoHeadIcon").asCom
            o.UiHeadIcon =  ViewHeadIcon:new(nil,co_headicon)
            o.GTextPlayerNickName = o.GCoChair:GetChild("NickNameSelf").asTextField
            o.GTextPlayerGolds = o.GCoChair:GetChild("GoldSelf").asTextField
            o.ControllerSeat = o.GCoChair:GetController("ControllerSeat")
            o.ControllerSeat.selectedIndex = 1
			o.PlayerDataDesktopH = nil

    return o
end

function ItemDesktopHSeat:setSeatPlayerData(player_info, seat_index, player_changed)        
            local controller_index = 1
            if (player_info ~= nil)
            then
                controller_index = 0
                self.PlayerDataDesktopH = player_info

                if (player_changed)
                then
                    self.UiHeadIcon:setPlayerInfoDesktopH(self.PlayerDataDesktopH, false)
                end

                self.GTextPlayerNickName.text = player_info.PlayerInfoCommon.NickName
                self.GTextPlayerGolds.text = UiChipShowHelper:getGoldShowStr(player_info.Gold, self.ViewMgr.LanMgr.LanBase)
            end

            self.ControllerSeat.selectedIndex = controller_index
end

function ItemDesktopHSeat:updatePlayerGolds(golds)        
            self.GTextPlayerGolds.text = UiChipShowHelper:getGoldShowStr(golds, self.ViewMgr.LanMgr.LanBase)
end

function ItemDesktopHSeat:updatePlayerIcon(head_icon)        
            self.UiHeadIcon.GLoaderPlayerIcon.texture = CS.FairyGUI.NTexture(head_icon)
end