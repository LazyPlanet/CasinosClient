ViewDesktopMenuTexas = ViewBase:new()

function ViewDesktopMenuTexas:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.ViewMgr = nil
    o.GoUi = nil
    o.ComUi = nil
    o.Panel = nil
    o.UILayer = nil
    o.InitDepth = nil
    o.ViewKey = nil
    o.GCoCardType = nil

    return o
end

function ViewDesktopMenuTexas:onCreate()
    self.GBtnStandUp = self.ComUi:GetChild("Lan_Btn_StandUp").asButton
    self.GBtnStandUp.onClick:Add(
            function()
                self:_onClickStandUp()
            end)
    self.GBtnLeaveInMiddle = self.ComUi:GetChild("Lan_Btn_LeaveHalfWay").asButton
    self.GBtnLeaveInMiddle.onClick:Add(
            function()
                self:_onClickLeaveInMiddle()
            end)
    self.TransitionCreate = self.ComUi:GetTransition("TransitionCreate")
    self.TransitionCreate:Play()
    local com_shade = self.ComUi:GetChild("ComShade").asCom
    com_shade.onClick:Add(
            function()
                self:_onClickContinue()
            end
    )
    local btn_exitgame = self.ComUi:GetChild("Lan_Btn_ExitGame").asButton
    btn_exitgame.onClick:Add(
            function()
                self:_onClickExit()
            end
    )
    local btn_inviteFriend = self.ComUi:GetChild("Lan_Btn_InviteFriend").asButton
    btn_inviteFriend.onClick:Add(
            function()
                self:_onClickInviteFriend()
            end
    )

    local btn_hint = self.ComUi:GetChild("Lan_Btn_CardType").asButton
    btn_hint.onClick:Add(
            function()
                self:_onClickHelp()
            end
    )
    local btn_reward = self.ComUi:GetChild("BtnReward").asButton
    self.ComRewardTips = btn_reward:GetChild("ComRewardTips").asCom
    self.TransitionNewReward = self.ComRewardTips:GetTransition("TransitionNewMsg")
    btn_reward.onClick:Add(
            function()
                self:close()
                local ev = self.ViewMgr:getEv("EvClickShowReward")
                if(ev == nil)
                then
                    ev = EvClickShowReward:new(nil)
                end
                self.ViewMgr:sendEv(ev)
            end    )
    self.mIsOb = false
    self.mIsWaitwhile = false
end

function ViewDesktopMenuTexas:setPlayerState(is_ob, is_waitwhile,have_reward)
    self.mIsOb = is_ob
    self.mIsWaitwhile = is_waitwhile
    if (is_ob)
    then
        self.GBtnStandUp.enabled = false
        self.GBtnLeaveInMiddle.enabled = false
    elseif (is_waitwhile)
    then
        self.GBtnLeaveInMiddle.enabled = false
    else
        self.GBtnStandUp.enabled = true
        self.GBtnLeaveInMiddle.enabled = true
    end

    if (have_reward == false)
    then
        ViewHelper:setGObjectVisible(false, self.ComRewardTips)
    else
        ViewHelper:setGObjectVisible(true, self.ComRewardTips)
        if (self.TransitionNewReward.playing == false)
        then
            self.TransitionNewReward:Play()
        end
    end
end

function ViewDesktopMenuTexas:_onClickContinue()
    self:close()
end

function ViewDesktopMenuTexas:_onClickExit()
    self.TransitionCreate:PlayReverse(
            function()
                self.ViewMgr:destroyView(self)
                local ev = self.ViewMgr:getEv("EvUiClickExitDesk")
                if (ev == nil)
                then
                    ev = EvUiClickExitDesk:new(nil)
                end
                self.ViewMgr:sendEv(ev)
            end
    )
end

function ViewDesktopMenuTexas: _onClickInviteFriend()
    local ev = self.ViewMgr:getEv("EvUiClickInviteFriendPlay")
    if (ev == nil)
    then
        ev = EvUiClickInviteFriendPlay:new(nil)
    end
    self.ViewMgr:sendEv(ev)
    self:close()
end

function ViewDesktopMenuTexas: _onClickLeaveInMiddle()
    if (self.mIsOb == false and self.mIsWaitwhile == false)
    then
        local ev = self.ViewMgr:getEv("EvUiClickWaitWhile")
        if (ev == nil)
        then
            ev = EvUiClickWaitWhile:new(nil)
        end
        self.ViewMgr:sendEv(ev)
    end
    self:close()
end

function ViewDesktopMenuTexas:_onClickStandUp()
    if (self.mIsOb == false)
    then
        local ev = self.ViewMgr:getEv("EvUiClickOB")
        if (ev == nil)
        then
            ev = EvUiClickOB:new(nil)
        end
        self.ViewMgr:sendEv(ev)
    end
    self:close()
end

function ViewDesktopMenuTexas:_onClickHelp()
    self.ViewMgr:createView("DesktopHintsTexas")
    self:close()
end

function ViewDesktopMenuTexas:close()
    self.TransitionCreate:PlayReverse(
		function()
			self.ViewMgr:destroyView(self)
		end
    )
end

ViewDesktopMenuTexasFactory = ViewFactory:new()

function ViewDesktopMenuTexasFactory:new(o, ui_package_name, ui_component_name,
                                         ui_layer, is_single, fit_screen)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.PackageName = ui_package_name
    self.ComponentName = ui_component_name
    self.UILayer = ui_layer
    self.IsSingle = is_single
    self.FitScreen = fit_screen
    return o
end

function ViewDesktopMenuTexasFactory:createView()
    local view = ViewDesktopMenuTexas:new(nil)
    return view
end