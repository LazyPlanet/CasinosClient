PlayerSeatWidgetControllerTexas = {
    GroupTitle = "Group",
    TransitionTitle = "Transition",
    FirstSeatName = "FirstSeat",
    TopRightSeatName = "TopRightSeat",
    RightSeatName = "RightSeat",
    BottomRightSeatName = "BottomRightSeat",
    BottomSeatName = "BottomSeat",
    BottomLeftSeatName = "BottomLeftSeat",
    LeftSeatName = "LeftSeat",
    TopLeftSeatName = "TopLeftSeat",
    EndSeatName = "EndSeat"
}

function PlayerSeatWidgetControllerTexas:new(o, player_info, com_playercenter)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.SeatWidget = nil
    o.UiGoldMgr = nil
    o.CardFirst = nil
    o.CardSecond = nil
    o.ShowCard = false
    o.LoaderTicket1 = nil
    o.LoaderTicket2 = nil
    o.ChipRaise = nil
    --o.ChipGetWin = nil
    o.TChipGetWin = {}
    o.TChipInPot = {}
    o.IsGameEnd = false
    o.SeatIndex = 0
    o.AlreadyGetWinGold = false
    o.AlreadyGoldInPot = false
    o.CasinosContext = CS.Casinos.CasinosContext.Instance

    o.PlayerInfo = player_info
    o.GComPlayerCenter = com_playercenter
    local com_ui = o.PlayerInfo.ComUi
    o.MapAllSeatWidgetGroup = {}
    o.MapAllSeatWidgetGroup[PlayerSeatWidgetControllerTexas.FirstSeatName] = com_ui:GetChild(PlayerSeatWidgetControllerTexas.GroupTitle .. PlayerSeatWidgetControllerTexas.FirstSeatName).asGroup
    o.MapAllSeatWidgetGroup[PlayerSeatWidgetControllerTexas.TopRightSeatName] = com_ui:GetChild(PlayerSeatWidgetControllerTexas.GroupTitle .. PlayerSeatWidgetControllerTexas.TopRightSeatName).asGroup
    o.MapAllSeatWidgetGroup[PlayerSeatWidgetControllerTexas.RightSeatName] = com_ui:GetChild(PlayerSeatWidgetControllerTexas.GroupTitle .. PlayerSeatWidgetControllerTexas.RightSeatName).asGroup
    o.MapAllSeatWidgetGroup[PlayerSeatWidgetControllerTexas.BottomRightSeatName] = com_ui:GetChild(PlayerSeatWidgetControllerTexas.GroupTitle .. PlayerSeatWidgetControllerTexas.BottomRightSeatName).asGroup
    o.MapAllSeatWidgetGroup[PlayerSeatWidgetControllerTexas.BottomSeatName] = com_ui:GetChild(PlayerSeatWidgetControllerTexas.GroupTitle .. PlayerSeatWidgetControllerTexas.BottomSeatName).asGroup
    o.MapAllSeatWidgetGroup[PlayerSeatWidgetControllerTexas.BottomLeftSeatName] = com_ui:GetChild(PlayerSeatWidgetControllerTexas.GroupTitle .. PlayerSeatWidgetControllerTexas.BottomLeftSeatName).asGroup
    o.MapAllSeatWidgetGroup[PlayerSeatWidgetControllerTexas.LeftSeatName] = com_ui:GetChild(PlayerSeatWidgetControllerTexas.GroupTitle .. PlayerSeatWidgetControllerTexas.LeftSeatName).asGroup
    o.MapAllSeatWidgetGroup[PlayerSeatWidgetControllerTexas.TopLeftSeatName] = com_ui:GetChild(PlayerSeatWidgetControllerTexas.GroupTitle .. PlayerSeatWidgetControllerTexas.TopLeftSeatName).asGroup
    o.MapAllSeatWidgetGroup[PlayerSeatWidgetControllerTexas.EndSeatName] = com_ui:GetChild(PlayerSeatWidgetControllerTexas.GroupTitle .. PlayerSeatWidgetControllerTexas.EndSeatName).asGroup

    return o
end

function PlayerSeatWidgetControllerTexas:init()
    self.UiGoldMgr = self.PlayerInfo.ViewDesktop.UiChipMgr
    self.SeatIndex = self.PlayerInfo.Player.UiSeatIndex
    self:_resetGold()
    self:_resetCard(true)
    self:_showSeatWidget()
end

function PlayerSeatWidgetControllerTexas:destroy()
    self:_destroyMoveGold()

    if (self.SeatWidget ~= nil)
    then
        self.SeatWidget = nil
    end
end

function PlayerSeatWidgetControllerTexas:release()
    self.LoaderTicket1 = nil
    self.LoaderTicket2 = nil
    self:hideHighLight()
    self:_resetGold()
    self:_resetCard(true)
    if (self.SeatWidget ~= nil)
    then
        self.SeatWidget = nil
    end
    self.CardFirst = nil
    self.CardSecond = nil
    self.IsGameEnd = false
    self.ShowCard = false
    self:_destroyMoveGold()
end

function PlayerSeatWidgetControllerTexas:deskIdle()
    ViewHelper:setGObjectVisible(false, self.SeatWidget.GGroupChipValue)
    ViewHelper:setGObjectVisible(false, self.SeatWidget.GImageDealerSign)
end

function PlayerSeatWidgetControllerTexas:setIsBtn(is_btn)
    ViewHelper:setGObjectVisible(is_btn, self.SeatWidget.GImageDealerSign)
end

function PlayerSeatWidgetControllerTexas:dealCard()
    local notshow_loader_card = false
    if (self.SeatWidget.GLoaderCardFirst ~= nil and self.PlayerInfo.Player.IsMe)
    then
        notshow_loader_card = true
    end

    if (self.PlayerInfo.Player.IsMe)
    then
        self.PlayerInfo.ViewDesktop:showCommonCardType(self.PlayerInfo.Player.DesktopTexas.GameEnd)
    end

    self:_setCardVisible(true)
    self.SeatWidget.TransitionCardInit:Play()
    ViewHelper:setGObjectVisible(true, self.SeatWidget.GImageCardFirst)
    ViewHelper:setGObjectVisible(true, self.SeatWidget.GImageCardSecond)
    if (self.SeatWidget.GLoaderCardFirst ~= nil)
    then
        ViewHelper:setGObjectVisible(notshow_loader_card, self.SeatWidget.GLoaderCardFirst)
        ViewHelper:setGObjectVisible(notshow_loader_card, self.SeatWidget.GLoaderCardSecond)
    end

    if (self.PlayerInfo.Player.PlayerDataDesktop.PlayerActionType == PlayerActionTypeTexas.Fold and self.PlayerInfo.Player.IsMe == false)
    then
        self:playerFold()
    end
end

function PlayerSeatWidgetControllerTexas:showCardAndBetInfo(card_first, card_second, show_card,is_init)
    local is_same = self:_cardsIsTheSame(self.CardFirst, card_first)
    if (is_same)
    then
        is_same = self:_cardsIsTheSame(self.CardSecond, card_second)
    end
    self.CardFirst = card_first
    self.CardSecond = card_second
    self.ShowCard = show_card
    if (self.PlayerInfo.Player.IsMe == true and self.CardFirst ~= nil)
    then
        self:_resetCard(false)
        local me_first_card_name = self.CardFirst.Suit .. "_" .. self.CardFirst.Type
        local l_me_first_card_name = string.lower(me_first_card_name)
        --print("l_me_first_card_name             "..l_me_first_card_name)
        self.SeatWidget.GLoaderCardFirst.color = CS.UnityEngine.Color.white
        self.SeatWidget.GLoaderCardFirst.color = CS.UnityEngine.Color.white
        if (self.SeatWidget.GLoaderCardFirst.texture == nil or is_same == false)
        then
            if (CS.System.String.IsNullOrEmpty(me_first_card_name) == false)
            then
                self.LoaderTicket1 = self.CasinosContext.TextureMgr:getTexture(l_me_first_card_name, self.CasinosContext.PathMgr:combinePersistentDataPath(CS.Casinos.UiHelperCasinos.getABCardResourceTitlePath() .. l_me_first_card_name .. ".ab"),
                        function(ticket, t)
                            if (self.SeatWidget ~= nil)
                            then
                                if ((self.LoaderTicket1 ~= ticket))
                                then
                                    return
                                end
                                self.LoaderTicket1 = nil

                                if (self.ShowCard)
                                then
                                    if (self.SeatWidget.GLoaderCardFirst ~= nil and self.SeatWidget.GLoaderCardFirst.displayObject.gameObject ~= nil)
                                    then
                                        ViewHelper:setGObjectVisible(true, self.SeatWidget.GLoaderCardFirst)
                                        ViewHelper:setGObjectVisible(true, self.SeatWidget.GLoaderCardSecond)
                                    end
                                    ViewHelper:setGObjectVisible(false, self.SeatWidget.GImageCardFirst)
                                    ViewHelper:setGObjectVisible(false, self.SeatWidget.GImageCardSecond)
                                    self.PlayerInfo.ViewDesktop:showCommonCardType(self.PlayerInfo.Player.DesktopTexas.GameEnd)
                                end

                                if (t ~= nil and self.SeatWidget.GLoaderCardFirst.displayObject.gameObject ~= nil)
                                then
                                    self.SeatWidget.GLoaderCardFirst.texture = CS.FairyGUI.NTexture(t)
                                end
                            end
                        end
                )
            end
        end

        local me_second_card_name = self.CardSecond.Suit .. "_" .. self.CardSecond.Type
        local l_me_second_card_name = string.lower(me_second_card_name)
        --print("l_me_second_card_name        "..l_me_second_card_name)
        if (self.SeatWidget.GLoaderCardSecond.texture == nil or is_same == false)
        then
            if (CS.System.String.IsNullOrEmpty(me_second_card_name) == false)
            then
                self.LoaderTicket2 = self.CasinosContext.TextureMgr:getTexture(l_me_second_card_name, self.CasinosContext.PathMgr:combinePersistentDataPath(CS.Casinos.UiHelperCasinos.getABCardResourceTitlePath() .. l_me_second_card_name .. ".ab"),
                        function(ticket, t)
                            if (self.SeatWidget ~= nil)
                            then
                                if ((self.LoaderTicket2 ~= ticket))
                                then
                                    return
                                end
                                self.LoaderTicket2 = nil

                                if (t ~= nil and self.SeatWidget.GLoaderCardSecond.displayObject.gameObject ~= nil)
                                then
                                    self.SeatWidget.GLoaderCardSecond.texture = CS.FairyGUI.NTexture(t)
                                end
                            end
                        end
                )
            end
        else
            local show = (self.PlayerInfo.Player.PlayerDataDesktop.DesktopPlayerState == TexasDesktopPlayerState.InGame) and
                    (self.PlayerInfo.Player.PlayerDataDesktop.PlayerActionType ~= PlayerActionTypeTexas.Fold) and self.IsGameEnd == false
            ViewHelper:setGObjectVisible(show, self.SeatWidget.GImageCardFirst)
            ViewHelper:setGObjectVisible(show, self.SeatWidget.GImageCardSecond)

            if (show == false)
            then
                self:_resetCard(true)
            end
        end
        if is_init then
            self:_showBet()
        end
    end
end

function PlayerSeatWidgetControllerTexas:showcard1()
    self.TweenerRotate1 = CS.Casinos.UiDoTweenHelper.TweenRotateY(self.GLoaderCardFirst, 0, 90, 0.1):SetEase(CS.DG.Tweening.Ease.Linear):OnComplete(
            function()
                ViewHelper:setGObjectVisible(true, self.GImageCardFirst)
                ViewHelper:setGObjectVisible(false, self.GLoaderCardFirst)
                self.GImageCardFirst.rotationY = 90
                self.GLoaderCardFirst.rotationY = 90
                self.TweenerRotate1 = CS.Casinos.UiDoTweenHelper.TweenRotateY(self.GImageCardFirst, 90, 270, 0.1):SetEase(CS.DG.Tweening.Ease.Linear):OnComplete(
                        function()
                            self.GImageCardFirst.rotationY = 0
                            self.GLoaderCardFirst.rotationY = 270
                            ViewHelper:setGObjectVisible(false, self.GImageCardFirst)
                            ViewHelper:setGObjectVisible(true, self.GLoaderCardFirst)
                            self.TweenerRotate1 = CS.Casinos.UiDoTweenHelper.TweenRotateY(self.GLoaderCardFirst, 270, 0, 0.1):SetEase(CS.DG.Tweening.Ease.Linear)
                        end
                )
            end
    )
end

function PlayerSeatWidgetControllerTexas:showcard2()
    self.TweenerRotate2 = CS.Casinos.UiDoTweenHelper.TweenRotateY(self.GLoaderCardSecond, 0, 90, 0.1):SetEase(CS.DG.Tweening.Ease.Linear):OnComplete(
            function()
                ViewHelper:setGObjectVisible(true, self.GImageCardSecond)
                ViewHelper:setGObjectVisible(false, self.GLoaderCardSecond)
                self.GImageCardSecond.rotationY = 90
                self.GLoaderCardSecond.rotationY = 90
                self.TweenerRotate2 = CS.Casinos.UiDoTweenHelper.TweenRotateY(self.GImageCardSecond, 90, 270, 0.1):SetEase(CS.DG.Tweening.Ease.Linear):OnComplete(
                        function()
                            self.GImageCardSecond.rotationY = 0
                            self.GLoaderCardSecond.rotationY = 270
                            ViewHelper:setGObjectVisible(false, self.GImageCardSecond)
                            ViewHelper:setGObjectVisible(true, self.GLoaderCardSecond)
                            self.TweenerRotate2 = CS.Casinos.UiDoTweenHelper.TweenRotateY(self.GLoaderCardSecond, 270, 0, 0.1):SetEase(CS.DG.Tweening.Ease.Linear)
                        end
                )
            end
    )
end

function PlayerSeatWidgetControllerTexas:raiseChips()
    if (self.ChipRaise ~= nil)
    then
        self.UiGoldMgr:chipEnquee(self.ChipRaise)
        self.ChipRaise = nil
    end
    local from = self.SeatWidget.GComChipStart.xy
    local to = self.SeatWidget.GComChipEnd.xy
    self.ChipRaise = self.UiGoldMgr:moveChip(from, to,
            0.3, "chip", CS.Casinos.ChipMoveType.Raise, self.PlayerInfo.ComUi,
            function()
                if (self.ChipRaise == nil)
                then
                    return
                end

                if (self.SeatWidget ~= nil)
                then
                    CS.Casinos.CasinosContext.Instance:play("chip", CS.Casinos._eSoundLayer.LayerNormal)
                    self:_showBet()
                end

                self.ChipRaise = nil
            end
    ,
            function()
                if (self.PlayerInfo.ComUi.displayObject ~= nil and self.PlayerInfo.ComUi.displayObject.gameObject ~= nil)
                then
                    CS.Casinos.CasinosContext.Instance:play("chip", CS.Casinos._eSoundLayer.LayerNormal)
                end
            end
    )
end

function PlayerSeatWidgetControllerTexas:sendWinnerChips(winner_golds, map_win_pot)
    if (self.TChipGetWin ~= nil)
    then
        for i, v in pairs(self.TChipGetWin) do
            self.UiGoldMgr:chipEnquee(v)
        end
        self.TChipGetWin = {}
    end

    local to = self.SeatWidget.GComChipStart.xy
    for i, v in pairs(map_win_pot) do
        local current_pot_xy = self.PlayerInfo.ViewDesktop.UiPot:getPotPos(i + 1)
        if current_pot_xy ~= nil then
            local from = self.PlayerInfo.ViewDesktop.ComUi:TransformPoint(current_pot_xy, self.PlayerInfo.ComUi)
            local get_pot = self.UiGoldMgr:moveWinChip(i + 1, from, to,
                    0.3, "chipfly", CS.Casinos.ChipMoveType.RunOutOfMainPot, self.PlayerInfo.ComUi,
                    function()
                        if (self.AlreadyGetWinGold)
                        then
                            return
                        end
                        self.AlreadyGetWinGold = true

                        if (self.SeatWidget ~= nil)
                        then
                            if winner_golds > 0 then
                                self.PlayerInfo:showWinStar(winner_golds)
                            else
                                self.PlayerInfo:playerStackChange()
                                --ViewHelper:setGObjectVisible(true, self.SeatWidget.GGroupChipValue)
                                --self.SeatWidget.GTextChipValue.text = UiChipShowHelper:getGoldShowStr(winner_golds, self.PlayerInfo.ViewMgr.LanMgr.LanBase)
                            end
                        end
                    end
            ,
                    function()
                        if v then
                            self.PlayerInfo.ViewDesktop.UiPot:resetViewPot(i + 1)
                        end

                        if (self.PlayerInfo.ComUi.displayObject ~= nil and self.PlayerInfo.ComUi.displayObject.gameObject ~= nil)
                        then
                            CS.Casinos.CasinosContext.Instance:play("chipfly", CS.Casinos._eSoundLayer.LayerNormal)
                        end
                    end
            )
            table.insert(self.TChipGetWin, get_pot)
        end
    end
end

function PlayerSeatWidgetControllerTexas:playerFold()
    if (self.SeatWidget ~= nil)
    then
        self.SeatWidget.TransitionCardFold:Play(
                function()
                    if (self.SeatWidget ~= nil)
                    then
                        local player_state = self.PlayerInfo.Player.PlayerDataDesktop.DesktopPlayerState
                        local action_type = self.PlayerInfo.Player.PlayerDataDesktop.PlayerActionType
                        local show_card = (player_state == TexasDesktopPlayerState.InGame) and
                                (action_type ~= PlayerActionTypeTexas.Fold) and self.IsGameEnd == false
                        self:_setCardVisible(show_card)
                    end
                end
        )
    end
end

function PlayerSeatWidgetControllerTexas:goldsInMainPot(t_playerchips_inpot)
    if (self.TChipInPot ~= nil)
    then
        for i, v in pairs(self.TChipInPot) do
            self.UiGoldMgr:chipEnquee(v)
        end
        self.TChipInPot = {}
    end

    local from = self.SeatWidget.GComChipEnd.xy
    for i, v in pairs(t_playerchips_inpot) do
        local current_pot_xy = self.PlayerInfo.ViewDesktop.UiPot:getPotPos(i)
        if current_pot_xy ~= nil then
            local to = self.PlayerInfo.ViewDesktop.ComUi:TransformPoint(current_pot_xy, self.PlayerInfo.ComUi)
            local chip_in_pot = self.UiGoldMgr:moveChip(from, to,
                    0.3, "hechip", CS.Casinos.ChipMoveType.GoToMainPot, self.PlayerInfo.ComUi,
                    function()
                        if (self.AlreadyGoldInPot)
                        then
                            return
                        end
                        self.AlreadyGoldInPot = false

                        if (self.SeatWidget ~= nil)
                        then
                            self:_resetGold()
                            if (self.PlayerInfo.ViewDesktop ~= nil)
                            then
                                self.PlayerInfo.ViewDesktop:playerSendChipsToPotDone()
                            end
                        end
                    end
            ,
                    function()
                        if (self.PlayerInfo.ComUi.displayObject ~= nil and self.PlayerInfo.ComUi.displayObject.gameObject ~= nil)
                        then
                            CS.Casinos.CasinosContext.Instance:play("hechip", CS.Casinos._eSoundLayer.LayerNormal)
                        end
                        if (self.SeatWidget ~= nil)
                        then
                            self:_resetGold()
                        end
                    end
            )
            table.insert(self.TChipInPot, chip_in_pot)
        end
    end
end

function PlayerSeatWidgetControllerTexas:resetSeatIndex()
    self.SeatIndex = self.PlayerInfo.Player.UiSeatIndex
    self:_showSeatWidget()
end

function PlayerSeatWidgetControllerTexas:preflopBegin()
    self.IsGameEnd = false
    self.AlreadyGetWinGold = false
    self.AlreadyGoldInPot = false
    self:_resetGold()
    self:_resetCard(true)
    self:_destroyMoveGold()
    self:hideHighLight()
end

function PlayerSeatWidgetControllerTexas:flop()
    self:_showBet()
end

function PlayerSeatWidgetControllerTexas:turn()
    self:_showBet()
end

function PlayerSeatWidgetControllerTexas:river()
    self:_showBet()
end

function PlayerSeatWidgetControllerTexas:gameEnd()
    self:_showBet()
    self.IsGameEnd = true
    self.CardFirst = nil
    self.CardSecond = nil
end

function PlayerSeatWidgetControllerTexas:reset()
    self:_resetGold()
    self:_resetCard(true)
end

function PlayerSeatWidgetControllerTexas:hideHighLight()
    if (self.SeatWidget.GImageCardFirstHighLight ~= nil)
    then
        ViewHelper:setGObjectVisible(false, self.SeatWidget.GImageCardFirstHighLight)
        ViewHelper:setGObjectVisible(false, self.SeatWidget.GImageCardSecondHighLight)
    end
end

function PlayerSeatWidgetControllerTexas:showHandCardHighLight(best_hand, card_type_str)
    local show_cardtype_tips = true
    local hand_type = best_hand.RankType
    if (hand_type == CS.Casinos.HandRankTypeTexas.None or hand_type == CS.Casinos.HandRankTypeTexas.HighCard)
    then
        show_cardtype_tips = false
    end

    if (show_cardtype_tips and self.SeatWidget.GLoaderCardFirst.visible)
    then
        if self.PlayerInfo.Player.PlayerDataDesktop.DesktopPlayerState == TexasDesktopPlayerState.InGame and CS.System.String.IsNullOrEmpty(card_type_str) == false then
            if self.SeatWidget.GroupCardType ~= nil then
                ViewHelper:setGObjectVisible(true, self.SeatWidget.GroupCardType)
                self.SeatWidget.TextCardType.text = card_type_str
            end
        end
        local t_cards = CS.Casinos.LuaHelper.ListToLuatable(best_hand.RankTypeCards)
        self:_checkSelfHand(t_cards, self.SeatWidget.GImageCardFirstHighLight, self.CardFirst)
        self:_checkSelfHand(t_cards, self.SeatWidget.GImageCardSecondHighLight, self.CardSecond)
    end
end

function PlayerSeatWidgetControllerTexas:hideBetInfoAndCards()
    self:_resetGold()
    self:_setCardVisible(false)
end

function PlayerSeatWidgetControllerTexas:setShowCardState(showcard_state)
    if self.SeatWidget.GImageShowCard1 == nil then
        return
    end

    if showcard_state == TexasPlayerShowCardState.First then
        ViewHelper:setGObjectVisible(true, self.SeatWidget.GImageShowCard1)
        ViewHelper:setGObjectVisible(false, self.SeatWidget.GImageShowCard2)
    elseif showcard_state == TexasPlayerShowCardState.Second then
        ViewHelper:setGObjectVisible(false, self.SeatWidget.GImageShowCard1)
        ViewHelper:setGObjectVisible(true, self.SeatWidget.GImageShowCard2)
    elseif showcard_state == TexasPlayerShowCardState.FirstAndSecond then
        ViewHelper:setGObjectVisible(true, self.SeatWidget.GImageShowCard1)
        ViewHelper:setGObjectVisible(true, self.SeatWidget.GImageShowCard2)
    elseif showcard_state == TexasPlayerShowCardState.None then
        ViewHelper:setGObjectVisible(false, self.SeatWidget.GImageShowCard1)
        ViewHelper:setGObjectVisible(false, self.SeatWidget.GImageShowCard2)
    end
end

function PlayerSeatWidgetControllerTexas:_resetCard(hide_card)
    if (self.SeatWidget == nil)
    then
        return
    end

    if self.SeatWidget.GroupCardType ~= nil then
        ViewHelper:setGObjectVisible(false, self.SeatWidget.GroupCardType)
    end
    self.SeatWidget.TransitionCardInit:Play()
    if self.TweenerRotate1 ~= nil then
        self.TweenerRotate1:Kill(true)
    end
    if self.TweenerRotate2 ~= nil then
        self.TweenerRotate2:Kill(true)
    end
    self.LoaderTicket1 = nil
    self.LoaderTicket2 = nil
    if (self.SeatWidget.GLoaderCardFirst ~= nil)
    then
        self.SeatWidget.GLoaderCardFirst.icon = nil
        self.SeatWidget.GLoaderCardSecond.icon = nil
    end

    if (hide_card == true)
    then
        self:_setCardVisible(false)
    end
end

function PlayerSeatWidgetControllerTexas:_cardsIsTheSame(card, card_compare)
    local is_same = true
    if (card ~= nil)
    then
        if (card_compare ~= nil)
        then
            if (card.Suit ~= card_compare.Suit or card.Type ~= card_compare.Type)
            then
                is_same = false
            end
        else
            is_same = false
        end
    else
        if (card_compare ~= nil)
        then
            is_same = false
        else
            print("New Card Is Null")
        end
    end

    return is_same
end

function PlayerSeatWidgetControllerTexas:_showSeatWidget()
    local seatwidget_name = self:_getSeatWidgetName()
    if (CS.System.String.IsNullOrEmpty(seatwidget_name))
    then
        print("Player self.SeatIndex Invalid!")
        return
    end

    local com_ui = self.PlayerInfo.ComUi
    local current_widget_group = nil
    for k, v in pairs(self.MapAllSeatWidgetGroup) do
        local widget_group = v
        if (seatwidget_name == k)
        then
            widget_group.visible = true
            current_widget_group = widget_group
        else
            widget_group.visible = false
        end
    end

    self.SeatWidget = _tSeatWidgetEx:new(nil)
    local group_betvalue = com_ui:GetChildInGroup(current_widget_group, "GroupBetValue").asGroup
    self.SeatWidget.GGroupChipValue = group_betvalue
    local dealer_sign = com_ui:GetChildInGroup(current_widget_group, "DeskDealer").asImage
    self.SeatWidget.GImageDealerSign = dealer_sign
    local chip_value = com_ui:GetChildInGroup(group_betvalue, "TextBetChipValue").asTextField
    self.SeatWidget.GTextChipValue = chip_value
    local chip_sign = com_ui:GetChildInGroup(group_betvalue, "Chip").asLoader
    self.SeatWidget.GLoaderChipSign = chip_sign
    self.SeatWidget.GComChipStart = self.GComPlayerCenter
    local com_chipmove_end = com_ui:GetChildInGroup(current_widget_group, "ComChipEnd").asCom
    self.SeatWidget.GComChipEnd = com_chipmove_end
    local group_card = com_ui:GetChildInGroup(current_widget_group, "GroupCard").asGroup
    local card_one = com_ui:GetChildInGroup(group_card, "CardOne").asImage
    self.SeatWidget.GImageCardFirst = card_one
    local card_two = com_ui:GetChildInGroup(group_card, "CardTwo").asImage
    self.SeatWidget.GImageCardSecond = card_two
    local loader_card_one = nil
    local loader_card_two = nil
    local loader_card_oneex = com_ui:GetChildInGroup(group_card, "LoaderCardOne")
    if (loader_card_oneex ~= nil)
    then
        self.SeatWidget.GImageShowCard1 = com_ui:GetChildInGroup(group_card, "ShowCard1").asImage
        self.SeatWidget.GImageShowCard2 = com_ui:GetChildInGroup(group_card, "ShowCard2").asImage
        loader_card_one = loader_card_oneex.asLoader
        loader_card_one.onClick:Clear()
        loader_card_one.onClick:Add(
                function(ev)
                    self:onClickCard1(ev)
                end)
        loader_card_two = com_ui:GetChildInGroup(group_card, "LoaderCardTwo").asLoader
        loader_card_two.onClick:Clear()
        loader_card_two.onClick:Add(
                function(ev)
                    self:onClickCard2(ev)
                end
        )
        if self.PlayerInfo.Player.IsMe then
            self.SeatWidget.GroupCardType = com_ui:GetChildInGroup(current_widget_group, "GroupCardType").asGroup
            self.SeatWidget.TextCardType = com_ui:GetChildInGroup(self.SeatWidget.GroupCardType, "TextCardType").asTextField
        end
    end
    self.SeatWidget.GLoaderCardFirst = loader_card_one
    self.SeatWidget.GLoaderCardSecond = loader_card_two
    local image_card_one_highlight = nil
    local image_card_two_highlight = nil
    local image_card_one_highlightex = com_ui:GetChildInGroup(group_card, "ImageCardOneHighLight")
    if (image_card_one_highlightex ~= nil)
    then
        image_card_one_highlight = image_card_one_highlightex.asImage
        image_card_two_highlight = com_ui:GetChildInGroup(group_card, "ImageCardTwoHighLight").asImage
    end
    self.SeatWidget.GImageCardFirstHighLight = image_card_one_highlight
    self.SeatWidget.GImageCardSecondHighLight = image_card_two_highlight
    self:hideHighLight()
    local transiton_cardfold = com_ui:GetTransition(self.TransitionTitle .. seatwidget_name)
    self.SeatWidget.TransitionCardFold = transiton_cardfold
    local transiton_cardinit = com_ui:GetTransition(self.TransitionTitle .. seatwidget_name .. "Init")
    self.SeatWidget.TransitionCardInit = transiton_cardinit

    ViewHelper:setGObjectVisible(self.PlayerInfo.Player.DesktopTexas.DealerSeatIndex == self.PlayerInfo.Player.PlayerDataDesktop.SeatIndex,
            self.SeatWidget.GImageDealerSign)
    local player_state = self.PlayerInfo.Player.PlayerDataDesktop.DesktopPlayerState
    local action_type = self.PlayerInfo.Player.PlayerDataDesktop.PlayerActionType
    local show_card = (player_state == TexasDesktopPlayerState.InGame) and
            (action_type ~= PlayerActionTypeTexas.Fold) and self.IsGameEnd == false
    self:_setCardVisible(show_card)
    self:_showBet()
    self:hideHighLight()
end

function PlayerSeatWidgetControllerTexas:_showBet()
    if (self.PlayerInfo.Player.PlayerDataDesktop.CurrentRoundBet > 0)
    then
        ViewHelper:setGObjectVisible(true, self.SeatWidget.GGroupChipValue)
        self.SeatWidget.GTextChipValue.text = UiChipShowHelper:getGoldShowStr(self.PlayerInfo.Player.PlayerDataDesktop.CurrentRoundBet,
                self.PlayerInfo.ViewMgr.LanMgr.LanBase,true,1)
    else
        self:_resetGold()
    end
end

function PlayerSeatWidgetControllerTexas:_setCardVisible(is_visible)
    ViewHelper:setGObjectVisible(is_visible, self.SeatWidget.GImageCardFirst)
    ViewHelper:setGObjectVisible(is_visible, self.SeatWidget.GImageCardSecond)
    if (self.SeatWidget.GImageCardFirstHighLight ~= nil and is_visible == false)
    then
        ViewHelper:setGObjectVisible(is_visible, self.SeatWidget.GImageCardFirstHighLight)
        ViewHelper:setGObjectVisible(is_visible, self.SeatWidget.GImageCardSecondHighLight)
        ViewHelper:setGObjectVisible(false, self.SeatWidget.GImageShowCard1)
        ViewHelper:setGObjectVisible(false, self.SeatWidget.GImageShowCard2)
    end
    if (self.SeatWidget.GLoaderCardFirst ~= nil)
    then
        ViewHelper:setGObjectVisible(is_visible, self.SeatWidget.GLoaderCardFirst)
        ViewHelper:setGObjectVisible(is_visible, self.SeatWidget.GLoaderCardSecond)
        if is_visible == false then
            if self.SeatWidget.GroupCardType ~= nil then
                ViewHelper:setGObjectVisible(is_visible, self.SeatWidget.GroupCardType)
            end
        end
    end
end

function PlayerSeatWidgetControllerTexas:_getSeatWidgetName()
    local seatwidget_name = ""
    if (self.PlayerInfo.DesktopSeatCount == 5)
    then
        if (self.PlayerInfo.Player.UiSeatIndex == 0)
        then
            seatwidget_name = PlayerSeatWidgetControllerTexas.FirstSeatName
        elseif (self.PlayerInfo.Player.UiSeatIndex == 2)
        then
            seatwidget_name = PlayerSeatWidgetControllerTexas.RightSeatName
        elseif (self.PlayerInfo.Player.UiSeatIndex == 4)
        then
            seatwidget_name = PlayerSeatWidgetControllerTexas.BottomSeatName
        elseif (self.PlayerInfo.Player.UiSeatIndex == 6)
        then
            seatwidget_name = PlayerSeatWidgetControllerTexas.LeftSeatName
        elseif (self.PlayerInfo.Player.UiSeatIndex == 8)
        then
            seatwidget_name = PlayerSeatWidgetControllerTexas.EndSeatName
        end
    elseif (self.PlayerInfo.DesktopSeatCount == 9 or self.PlayerInfo.DesktopSeatCount == 6)
    then
        if (self.PlayerInfo.Player.UiSeatIndex == 0)
        then
            seatwidget_name = PlayerSeatWidgetControllerTexas.FirstSeatName
        elseif (self.PlayerInfo.Player.UiSeatIndex == 1)
        then
            seatwidget_name = PlayerSeatWidgetControllerTexas.TopRightSeatName
        elseif (self.PlayerInfo.Player.UiSeatIndex == 2)
        then
            seatwidget_name = PlayerSeatWidgetControllerTexas.RightSeatName
        elseif (self.PlayerInfo.Player.UiSeatIndex == 3)
        then
            seatwidget_name = PlayerSeatWidgetControllerTexas.BottomRightSeatName
        elseif (self.PlayerInfo.Player.UiSeatIndex == 4)
        then
            seatwidget_name = PlayerSeatWidgetControllerTexas.BottomSeatName
        elseif (self.PlayerInfo.Player.UiSeatIndex == 5)
        then
            seatwidget_name = PlayerSeatWidgetControllerTexas.BottomLeftSeatName
        elseif (self.PlayerInfo.Player.UiSeatIndex == 6)
        then
            seatwidget_name = PlayerSeatWidgetControllerTexas.LeftSeatName
        elseif (self.PlayerInfo.Player.UiSeatIndex == 7)
        then
            seatwidget_name = PlayerSeatWidgetControllerTexas.TopLeftSeatName
        elseif (self.PlayerInfo.Player.UiSeatIndex == 8)
        then
            seatwidget_name = PlayerSeatWidgetControllerTexas.EndSeatName
        end
    end

    return seatwidget_name
end

function PlayerSeatWidgetControllerTexas:_resetGold()
    if (self.SeatWidget ~= nil)
    then
        self.SeatWidget.GTextChipValue.text = ""
        ViewHelper:setGObjectVisible(false, self.SeatWidget.GGroupChipValue)
    end
end

function PlayerSeatWidgetControllerTexas:_checkSelfHand(list_card, image_highlight, card)
    if (card == nil)
    then
        return
    end

    local show_hightlight = false
    for i, v in pairs(list_card) do
        if (card.Suit == v.suit and card.Type == v.type)
        then
            show_hightlight = true
            break
        end
    end

    if (image_highlight ~= nil)
    then
        ViewHelper:setGObjectVisible(show_hightlight, image_highlight)
    end

    if (self.IsGameEnd and show_hightlight == false)
    then
        if (card == self.CardFirst)
        then
            self.SeatWidget.GLoaderCardFirst.color = CS.UnityEngine.Color.gray
        else
            self.SeatWidget.GLoaderCardFirst.color = CS.UnityEngine.Color.gray
        end
    end
end

function PlayerSeatWidgetControllerTexas:_destroyMoveGold()
    if (self.TChipInPot ~= nil)
    then
        for i, v in pairs(self.TChipInPot) do
            self.UiGoldMgr:chipEnquee(v)
        end
        self.TChipInPot = {}
    end

    if (self.TChipGetWin ~= nil)
    then
        for i, v in pairs(self.TChipGetWin) do
            self.UiGoldMgr:chipEnquee(v)
        end
        self.TChipGetWin = {}
    end

    if (self.ChipRaise ~= nil)
    then
        self.UiGoldMgr:chipEnquee(self.ChipRaise)
        self.ChipRaise = nil
    end
end

function PlayerSeatWidgetControllerTexas:onClickCard1(ev)
    ev:StopPropagation()

    local ev = self.PlayerInfo.ViewMgr:getEv("EvUiClickShowCard")
    if (ev == nil)
    then
        ev = EvUiClickShowCard:new(nil)
    end
    ev.click_card1 = true
    self.PlayerInfo.ViewMgr:sendEv(ev)
end

function PlayerSeatWidgetControllerTexas:onClickCard2(ev)
    ev:StopPropagation()
    local ev = self.PlayerInfo.ViewMgr:getEv("EvUiClickShowCard")
    if (ev == nil)
    then
        ev = EvUiClickShowCard:new(nil)
    end
    ev.click_card1 = false
    self.PlayerInfo.ViewMgr:sendEv(ev)
end

_tSeatWidgetEx = {}

function _tSeatWidgetEx:new(o)
    o = {} or o
    setmetatable(o, self)
    self.__index = self
    o.GImageDealerSign = nil
    o.GGroupChipValue = nil
    o.GTextChipValue = nil
    o.GLoaderChipSign = nil
    o.GComChipStart = nil
    o.GComChipEnd = nil
    o.GLoaderCardFirst = nil
    o.GImageCardFirst = nil
    o.GImageCardFirstHighLight = nil
    o.GImageShowCard1 = nil
    o.GLoaderCardSecond = nil
    o.GImageCardSecond = nil
    o.GImageCardSecondHighLight = nil
    o.GImageShowCard2 = nil
    o.TransitionCardFold = nil
    o.TransitionCardInit = nil
    o.GroupCardType = nil
    o.TextCardType = nil

    return o
end