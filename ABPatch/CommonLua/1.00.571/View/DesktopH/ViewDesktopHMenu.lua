ViewDesktopHMenu = ViewBase:new()

function ViewDesktopHMenu:new(o)
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
    o.CoMenuEx = nil
    o.ViewDesktopH = nil

    return o
end

function ViewDesktopHMenu:onCreate()
    self.ComUi.onClick:Add(
            function()
                self:_onClickMenuCo()
            end    )
    self.CoMenuEx = self.ComUi:GetChild("CoMenuEx").asCom
    local btn_return = self.CoMenuEx:GetChild("BtnReturn").asButton
    btn_return.onClick:Add(
            function()
                self:_onClickBtnReturn()
            end    )
    local btn_cardtype = self.CoMenuEx:GetChild("BtnCardType").asButton
    btn_cardtype.onClick:Add(
            function()
                self:_onClickBtnCardType()
            end    )
    local btn_help = self.CoMenuEx:GetChild("BtnHelp").asButton
    btn_help.onClick:Add(
            function()
                self:_onClickBtnHelp()
            end    )
    local btn_charge = self.CoMenuEx:GetChild("BtnRecharge").asButton
    btn_charge.onClick:Add(
            function()
                self:_onClickBtnCharge()
            end    )
    local btn_reward = self.CoMenuEx:GetChild("BtnReward").asButton
    self.ComRewardTips = btn_reward:GetChild("ComRewardTips").asCom
    self.TransitionNewReward = self.ComRewardTips:GetTransition("TransitionNewMsg")
    btn_reward.onClick:Add(
            function()
                local ev = self.ViewMgr:getEv("EvClickShowReward")
                if(ev == nil)
                then
                    ev = EvClickShowReward:new(nil)
                end
                self.ViewMgr:sendEv(ev)
            end    )
    self.ViewDesktopH = self.ViewMgr:getView("DesktopH")
end

function ViewDesktopHMenu:showMenu(have_reward)
    local pos = CS.UnityEngine.Vector3()
    pos.x = 0
    pos.y = -self.CoMenuEx.height
    pos.z = 1
    self.CoMenuEx.position = pos
    self.CoMenuEx:TweenMoveY(0, 0.25)
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

function ViewDesktopHMenu:_onClickMenuCo()
    self.CoMenuEx:TweenMoveY(-self.CoMenuEx.height, 0.25):OnComplete(
            function()
                self.ViewMgr:destroyView(self)
            end
    )
end

function ViewDesktopHMenu:_onClickBtnReturn()
    local ev = self.ViewMgr:getEv("EvUiClickLeaveDesktopHundred")
    if(ev == nil)
    then
        ev = EvUiClickLeaveDesktopHundred:new(nil)
    end
    self.ViewMgr:sendEv(ev)
end

function ViewDesktopHMenu:_onClickBtnCardType()
    local card_type = self.ViewMgr:createView("DesktopHCardType")
    local p = self.ViewDesktopH:getDesktopBasePackageName()
    local co_cardtype = CS.FairyGUI.UIPackage.CreateObject(p,self.ViewDesktopH.UiDesktopHComDesktopHCardTypeTitle .. self.ViewDesktopH.FactoryName).asCom
    self.ViewMgr.LanMgr:parseComponent(co_cardtype)
    card_type:showCardType(co_cardtype)
end

function ViewDesktopHMenu:_onClickBtnHelp()
    local help = self.ViewMgr:createView("DesktopHHelp")
    local p = self.ViewDesktopH:getDesktopBasePackageName()
    local co_betpot = CS.FairyGUI.UIPackage.CreateObject(p, self.ViewDesktopH.UiDesktopHComDesktopHHelpTitle .. self.ViewDesktopH.FactoryName).asCom
    self.ViewMgr.LanMgr:parseComponent(co_betpot)
    help:setComHelp(co_betpot)
end

function ViewDesktopHMenu:_onClickBtnCharge()
    self.ViewMgr:createView("Shop")
end



ViewDesktopHMenuFactory = ViewFactory:new()

function ViewDesktopHMenuFactory:new(o,ui_package_name,ui_component_name,
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

function ViewDesktopHMenuFactory:createView()
    local view = ViewDesktopHMenu:new(nil)
    return view
end