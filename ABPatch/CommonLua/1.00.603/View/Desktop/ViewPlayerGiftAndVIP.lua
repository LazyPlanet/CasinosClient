ViewPlayerGiftAndVIP = {
    GiftMoveTime = 1,
    GiftPlayerWinMoveTime = 0.1,
    GiftMoveDis = 20,
}

function ViewPlayerGiftAndVIP:new(o,player_guid, com_gift_left, com_gift_right, com_player,view_mgr)
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    o.ViewMgr = view_mgr
    o.GComPlayer = com_player
    o.PlayerGuid = player_guid
    o.GComGiftAndVIPLeft = com_gift_left
    o.GComGiftAndVIPLeft.onClick:Add(
            function(ev)
                o:onClickGift(ev)
            end
    )
    o.GImageGiftLeft = o.GComGiftAndVIPLeft:GetChild("Gift").asImage
    o.GImageVIPLeft = o.GComGiftAndVIPLeft:GetChild("VipSign").asImage
    o.GComGiftAndVIPRight = com_gift_right
    o.GComGiftAndVIPRight.onClick:Add(
            function(ev)
                o:onClickGift(ev)
            end
    )
    o.GImageGiftRight = o.GComGiftAndVIPRight:GetChild("Gift").asImage
    o.GImageVIPRight = o.GComGiftAndVIPRight:GetChild("VipSign").asImage

    return o
end

function ViewPlayerGiftAndVIP:release()
    if (self.TweenerWinMove ~= nil)
    then
        self.TweenerWinMove:Kill()
        self.TweenerWinMove = nil
    end
    if (self.TweenerSendGiftMove ~= nil)
    then
        self.TweenerSendGiftMove:Kill()
        self.TweenerSendGiftMove = nil
    end
    if (self.GLoaderCurrentShowGift ~= nil)
    then
        self.GLoaderCurrentShowGift.icon = nil
    end
end

function ViewPlayerGiftAndVIP:checkGiftAndVIPPos(desk_seatcount, ui_index, vip_level)
    self.ShowLeftGift = true
    self.GComCurrentGiftParent = self.GComGiftAndVIPLeft
    self.GImageCurrentGift = self.GImageGiftLeft
    self.GImageCurrentVIP = self.GImageVIPLeft
    local half_index = math.floor(desk_seatcount / 2)
    if (desk_seatcount == 5)
    then
        half_index = half_index * 2
    end
    if (half_index < ui_index)
    then
        self.GComCurrentGiftParent = self.GComGiftAndVIPRight
        self.GImageCurrentGift = self.GImageGiftRight
        self.ShowLeftGift = false
        self.GImageCurrentVIP = self.GImageVIPRight
    end
    self.GComGiftAndVIPLeft.visible = self.ShowLeftGift
    if(self.ShowLeftGift)
    then
        self.GComGiftAndVIPRight.visible = false
    else
        self.GComGiftAndVIPRight.visible = true
    end
    local is_vip = vip_level > 0
    CS.Casinos.UiHelper.setGObjectVisible(false, self.GImageVIPLeft, self.GImageVIPRight)
    --self.GImageCurrentVIP.visible = is_vip
    local gift_parent_pos = self.GComCurrentGiftParent.xy
    local parent_w = self.GComCurrentGiftParent.width
    local parent_h = self.GComCurrentGiftParent.height
    gift_parent_pos.x = gift_parent_pos.x + (parent_w / 2)
    gift_parent_pos.y = gift_parent_pos.y + (parent_h / 2)
    self.GiftCenterPos = gift_parent_pos
    if (self.GComCurrentShowGift ~= nil)
    then
        CS.Casinos.UiHelper.setGObjectVisible(false, self.GImageCurrentGift)
        self:setGiftPos()
    end
end

function ViewPlayerGiftAndVIP:setGift(item, from_pos, is_sendgift)
    if (item == nil)
    then
        CS.Casinos.UiHelper.setGObjectVisible(true, self.GImageCurrentGift)
        if (self.GComCurrentShowGift ~= nil)
        then
            CS.UnityEngine.GameObject.Destroy(self.GComCurrentShowGift.displayObject.gameObject)
            self.GComCurrentShowGift = nil
        end
    else
        if (self.GComCurrentShowGift ~= nil)
        then
            self.GComCurrentShowGift:Dispose()
            CS.UnityEngine.GameObject.Destroy(self.GComCurrentShowGift.displayObject.gameObject)
            self.GComCurrentShowGift = nil
        end
        if (item.TbDataItem.UnitType ~= "GiftTmp")
        then
            return
        end
        local unit_tmp = item.UnitLink
        local sender_etguid = unit_tmp.GiveEtGuid
        if(sender_etguid == nil or string.len(sender_etguid) <= 0)
        then
            return
        end
        self.GComCurrentShowGift = CS.FairyGUI.UIPackage.CreateObject("Common", "ComGiftDesktopTmp").asCom
        self.GComPlayer:AddChild(self.GComCurrentShowGift)
        self.GComCurrentShowGift.touchable = false
        self.GLoaderCurrentShowGift = self.GComCurrentShowGift:GetChild("LoaderIcon").asLoader
        if (is_sendgift)
        then
            local to_pos = self:getGiftPos()
            if (from_pos == CS.Casinos.LuaHelper.GetVector2(0,0))
            then
                from_pos = to_pos
            end
            self:loadGiftIcon(item.TbDataItem.Id,
                    function()
                        self.TweenerSendGiftMove = CS.Casinos.UiDoTweenHelper.TweenMove(self.GComCurrentShowGift, from_pos, to_pos, 1, true):OnComplete(
                                function()
                                    self.TweenerSendGiftMove = nil
                                end)
                    end
            )
        else
            self:loadGiftIcon(item.TbDataItem.Id, nil)
        end
        CS.Casinos.UiHelper.setGObjectVisible(false, self.GImageCurrentGift)
    end
    if (self.GComCurrentShowGift ~= nil)
    then
        self:setGiftPos()
    end
end

function ViewPlayerGiftAndVIP:playerIsShowDown()
    self.IsShowDown = true
    local to = 0
    if (self.ShowLeftGift)
    then
        to = -ViewPlayerGiftAndVIP.GiftMoveDis
    else
        to = ViewPlayerGiftAndVIP.GiftMoveDis
    end
    if (self.GComCurrentShowGift ~= nil)
    then
        to = to + self.GComCurrentShowGift.x
        self.TweenerWinMove = CS.Casinos.UiDoTweenHelper.TweenMoveX(self.GComCurrentShowGift, self.GComCurrentShowGift.x, to, ViewPlayerGiftAndVIP.GiftPlayerWinMoveTime, true)
    else
        to = to + self.GImageCurrentGift.x
        self.TweenerWinMove = CS.Casinos.UiDoTweenHelper.TweenMoveX(self.GImageCurrentGift, self.GImageCurrentGift.x, to, ViewPlayerGiftAndVIP.GiftPlayerWinMoveTime, true)
    end
    self.TweenerWinMove:SetAutoKill(false)
end

function ViewPlayerGiftAndVIP:reset()
    if (self.IsShowDown)
    then
        if (self.TweenerWinMove ~= nil)
        then
            self.TweenerWinMove:PlayBackwards()
            self.TweenerWinMove = nil
        end
        self.IsShowDown = false
    end
end

function ViewPlayerGiftAndVIP:onClickGift(ev)
    ev:StopPropagation()
    local ev = self.ViewMgr:getEv("EvCreateGiftShop")
    if(ev == nil)
    then
        ev = EvCreateGiftShop:new(nil)
    end
    ev.is_tmp_gift = true
    ev.to_player_etguid = self.PlayerGuid
    self.ViewMgr:sendEv(ev)
end

function ViewPlayerGiftAndVIP:loadGiftIcon(tb_giftid, load_icon_down)
    local tb_mgr = TbDataMgr:new(nil)
    local tb_gift = tb_mgr:GetData("Item",tb_giftid)
    local gift_path = CS.Casinos.CasinosContext.Instance:AppendStrWithSB(CS.Casinos.CasinosContext.Instance.ABResourcePathTitle, "Item/", tostring(tb_gift.Icon), ".ab")
    self.LoaderTicket = CS.Casinos.CasinosContext.Instance.AsyncAssetLoadGroup:asyncLoadAsset(CS.Casinos.CasinosContext.Instance.PathMgr:combinePersistentDataPath(gift_path),
            tb_gift.Icon, CS._eAsyncAssetLoadType.LocalBundleAsset,
            function(ticket, path, obj)
                if (self.GComCurrentShowGift == nil)
                then
                    return
                end
                if (self.LoaderTicket ~= ticket)
                then
                    return
                end
                self.LoaderTicket = nil
                if (obj ~= nil)
                then
                    local t = CS.Casinos.LuaHelper.UnityObjectCastToTexture(obj)
                    self.GLoaderCurrentShowGift.image.texture = CS.FairyGUI.NTexture(t)
                    self.GLoaderCurrentShowGift.image.width = self.GLoaderCurrentShowGift.width
                    self.GLoaderCurrentShowGift.image.height = self.GLoaderCurrentShowGift.height
                end
                if (load_icon_down ~= nil)
                then
                    load_icon_down()
                end
            end
    )
end

function ViewPlayerGiftAndVIP:setGiftPos()
    self.GComCurrentShowGift.xy = self:getGiftPos()
end

function ViewPlayerGiftAndVIP:getGiftPos()
    local gift_pos = CS.Casinos.LuaHelper.GetVector2(self.GiftCenterPos.x,self.GiftCenterPos.y)
    local w = self.GComCurrentShowGift.width
    local h = self.GComCurrentShowGift.height
    gift_pos.x = gift_pos.x - (w / 2)
    gift_pos.y = gift_pos.y -(h / 2)
    return gift_pos
end
