ControllerIM = ControllerBase:new(nil)

function ControllerIM:new(o, controller_mgr, controller_data, guid)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    o.ControllerData = controller_data
    o.ControllerMgr = controller_mgr
    o.Guid = guid
    o.ViewMgr = ViewMgr:new(nil)
    o.IMChat = IMChat:new(nil, o)
    o.IMFeedback = IMFeedback:new(nil, o)
    o.IMFriendList = IMFriendList:new(nil, o)
    o.IMMailBox = IMMailBox:new(nil, o)
    o.IMChatRecord = IMChatRecord:new(nil, o)

    return o
end

function ControllerIM:onCreate()
    self.ViewMgr:bindEvListener("EvUiCreateMainUi", self)
    self.ViewMgr:bindEvListener("EvUiFindFriend", self)
    self.ViewMgr:bindEvListener("EvUiDeleteFriend", self)
    self.ViewMgr:bindEvListener("EvUiAddFriend", self)
    self.ViewMgr:bindEvListener("EvUiAgreeAddFriend", self)
    self.ViewMgr:bindEvListener("EvUiRefuseAddFriend", self)
    self.ViewMgr:bindEvListener("EvUiSendMsg", self)
    self.ViewMgr:bindEvListener("EvUiChatConfirmRead", self)
    self.ViewMgr:bindEvListener("EvUiClickChatmsg", self)
    self.ViewMgr:bindEvListener("EvUiClickChooseFriendChatTarget", self)
    self.ViewMgr:bindEvListener("EvUiClickFriend", self)
    self.ViewMgr:bindEvListener("EvUiClickChooseFriend", self)
    self.ViewMgr:bindEvListener("EvUiCurrentChatTargetChange", self)
    self.ViewMgr:bindEvListener("EvUiClickInviteFriendPlay", self)
    self.ViewMgr:bindEvListener("EvUiClickDeleteFriendChatRecord", self)
    self.ViewMgr:bindEvListener("EvUiRequestMailRead", self)
    self.ViewMgr:bindEvListener("EvUiRequestMailRecvAttachment", self)
    self.ViewMgr:bindEvListener("EvUiRequestFriendAddOrRemove", self)
    self.ViewMgr:bindEvListener("EvUiSendFeedbackMsg", self)
    self.ViewMgr:bindEvListener("EvUiFeedbackConfirmRead", self)
    self.CasinosContext = CS.Casinos.CasinosContext.Instance
    self.ControllerPlayer = self.ControllerMgr:GetController("ControllerPlayer")
    self:setMainUiIMInfo()
    self.CurrentChatTargetGuid = ""
    local rpc = self.ControllerMgr.RPC
    local m_c = CommonMethodType
    rpc:RegRpcMethod1(m_c.IMAddFriendReqRequestResult, function(result)
        self:OnIMAddFriendReqRequestResult(result)
    end)
    rpc:RegRpcMethod1(m_c.IMAddFriendResRequestResult, function(result)
        self:OnIMAddFriendResRequestResult(result)
    end)
    rpc:RegRpcMethod1(m_c.IMDeleteFriendRequestResult, function(result)
        self:OnIMDeleteFriendRequestResult(result)
    end)
    rpc:RegRpcMethod1(m_c.IMFriendLoginNotify, function(player_guid)
        self:OnIMFriendLoginNotify(player_guid)
    end)
    rpc:RegRpcMethod1(m_c.IMFriendLogoutNotify, function(player_guid)
        self:OnIMFriendLogoutNotify(player_guid)
    end)
    rpc:RegRpcMethod1(m_c.IMFriendInfoCommonUpdateNotify, function(player_info_common)
        self:OnIMFriendInfoCommonUpdateNotify(player_info_common)
    end)
    rpc:RegRpcMethod1(m_c.IMFriendInfoMoreUpdateNotify, function(player_info_more)
        self:OnIMFriendInfoMoreUpdateNotify(player_info_more)
    end)
    rpc:RegRpcMethod1(m_c.IMFriendInfoRealtimeUpdateNotify, function(player_info_realtime)
        self:OnIMFriendInfoRealtimeUpdateNotify(player_info_realtime)
    end)
    rpc:RegRpcMethod1(m_c.IMFriendListAddNotify, function(list_player)
        self:OnIMFriendListAddNotify(list_player)
    end)
    rpc:RegRpcMethod1(m_c.IMFriendListRemoveNotify, function(player_guid)
        self:OnIMFriendListRemoveNotify(player_guid)
    end)
    rpc:RegRpcMethod1(m_c.IMFindFriendNotify, function(list_player)
        self:OnIMFindFriendNotify(list_player)
    end)
    rpc:RegRpcMethod1(m_c.IMRecommandFriendNotify, function(list_player)
        self:OnIMRecommandFriendNotify(list_player)
    end)
    rpc:RegRpcMethod1(m_c.IMEventPush2ClientNotify, function(msg)
        self:OnIMEventPush2ClientNotify(msg)
    end)
    rpc:RegRpcMethod1(m_c.IMChatRecvMsgNotify, function(msg)
        self:OnIMChatRecvMsgNotify(msg)
    end)
    rpc:RegRpcMethod1(m_c.IMChatRecvBatchMsgNotify, function(list_msg)
        self:OnIMChatRecvBatchMsgNotify(list_msg)
    end)
    rpc:RegRpcMethod1(m_c.IMChatRecordRequestResult, function(list_msg)
        self:OnIMChatRecordRequestResult(list_msg)
    end)
    rpc:RegRpcMethod1(m_c.IMMailListInitNotify, function(list_mail)
        self:OnIMMailListInitNotify(list_mail)
    end)
    rpc:RegRpcMethod1(m_c.IMMailOperateRequestResult, function(mail)
        self:OnIMMailOperateRequestResult(mail)
    end)
    rpc:RegRpcMethod1(m_c.IMMailAddNotify, function(mail)
        self:OnIMMailAddNotify(mail)
    end)
    rpc:RegRpcMethod1(m_c.IMMailDeleteNotify, function(mail_guid)
        self:OnIMMailDeleteNotify(mail_guid)
    end)
    rpc:RegRpcMethod1(m_c.IMMailUpdateNotify, function(mail)
        self:OnIMMailUpdateNotify(mail)
    end)
    rpc:RegRpcMethod1(m_c.IMFriendGoldUpdateNotify, function(gold_update)
        self:OnIMFriendGoldUpdate(gold_update)
    end)
    rpc:RegRpcMethod1(m_c.PlayerFeedbackRecvMsgNotify, function(msg)
        self:OnPlayerFeedbackRecvMsgNotify(msg)
    end)
    rpc:RegRpcMethod2(m_c.PlayerFeedbackGetListNotify, function(list_msg, readconfirm_msg_id)
        self:OnPlayerFeedbackGetListNotify(list_msg, readconfirm_msg_id)
    end)

    self.ControllerMgr.RPC:RPC0(m_c.PlayerFeedbackGetListRequest)
end

function ControllerIM:onDestroy()
    self.ViewMgr:unbindEvListener(self)
end

function ControllerIM:onUpdate(tm)
end

function ControllerIM:onHandleEv(ev)
    if (ev.EventName == "EvUiCreateMainUi")
    then
        self:setMainUiIMInfo()
    elseif (ev.EventName == "EvUiFindFriend")
    then
        self.IMFriendList:RequestIMFindFriend(ev.search_filter)
    elseif (ev.EventName == "EvUiDeleteFriend")
    then
        self.IMFriendList:RequestIMDeleteFriend(ev.friend_etguid)
    elseif (ev.EventName == "EvUiAddFriend")
    then
        self.IMFriendList:RequestIMAddFriendReq(ev.friend_etguid)
    elseif (ev.EventName == "EvUiAgreeAddFriend")
    then
        local offline_ev = ev.ev
        self.ControllerMgr.RPC:RPC2(CommonMethodType.IMEventClientConfirm, offline_ev._id, "")
        self.IMFriendList:RequestIMAddFriendRes(ev.from_etguid, AddFriendResult.Agree)
    elseif (ev.EventName == "EvUiRefuseAddFriend")
    then
        local offline_ev = ev.ev
        self.ControllerMgr.RPC:RPC2(CommonMethodType.IMEventClientConfirm, offline_ev._id, "")
        self.IMFriendList:RequestIMAddFriendRes(ev.from_etguid, AddFriendResult.Reject)
    end
    if (ev.EventName == "EvUiSendMsg")
    then
        local chat_msg = ev.chat_msg
        self.IMChat:requestIMChatSendMsg(chat_msg)
    elseif (ev.EventName == "EvUiChatConfirmRead")
    then
        local friend_etguid = ev.friend_etguid
        self.IMChat.MapUnReadChats[friend_etguid] = nil
        self.IMChat:requestChatReadConfirm(friend_etguid, ev.msg_id)
        local ev = self.ControllerMgr.ViewMgr:getEv("EvEntityUnreadChatsChanged")
        if (ev == nil)
        then
            ev = EvEntityUnreadChatsChanged:new(nil)
        end
        ev.friend_etguid = friend_etguid
        self.ControllerMgr.ViewMgr:sendEv(ev)
    elseif (ev.EventName == "EvUiSendFeedbackMsg")
    then
        self.IMFeedback:requestIMFeedbackSendMsg(ev.chat_msg)
    elseif (ev.EventName == "EvUiFeedbackConfirmRead")
    then
        self.IMFeedback:requestChatReadConfirm()
    elseif (ev.EventName == "EvUiClickChatmsg")
    then
        local ui_chatfriend = self.ControllerMgr.ViewMgr:getView("ChatFriend")
        if (ui_chatfriend == nil)
        then
            ui_chatfriend = self.ControllerMgr.ViewMgr:createView("ChatFriend")
            ui_chatfriend:initChatMsg(self.CurrentChatTargetGuid)
        else
            self.ControllerMgr.ViewMgr.destroyView(ui_chatfriend)
        end
    elseif (ev.EventName == "EvUiClickChooseFriendChatTarget")
    then
        local ui_choose_target = self.ControllerMgr.ViewMgr:createView("ChatChooseTarget")
        ui_choose_target:setFriendInfo(self.IMFriendList.MapFriendList)
    elseif (ev.EventName == "EvUiClickFriend")
    then
        local ui_friend = self.ControllerMgr.ViewMgr:getView("Friend")
        if (ui_friend == nil)
        then
            ui_friend = self.ControllerMgr.ViewMgr:createView("Friend")
            ui_friend:setFriends(nil)
        else
            self.ControllerMgr.ViewMgr:destroyView(ui_friend)
        end
    elseif (ev.EventName == "EvUiClickChooseFriend")
    then
        if (ev.is_choosechat)
        then
            local friend_guid = ev.friend_info.PlayerInfoCommon.PlayerGuid
            local list_records = self.IMChat:getChatRecords(friend_guid)
            if (list_records == nil)
            then
                self.IMChat:addNewChatTarget(friend_guid)
            end
            local ui_chatfriend = self.ControllerMgr.ViewMgr:getView("ChatFriend")
            if (ui_chatfriend == nil)
            then
                ui_chatfriend = self.ControllerMgr.ViewMgr:createView("ChatFriend")
            end
            ui_chatfriend:initChatMsg(friend_guid)
            self.CurrentChatTargetGuid = friend_guid
        elseif (ev.is_recommand)
        then
            local friend = self.ControllerMgr.ViewMgr:createView("Friend")
            friend:setCurrentRecommandFriend(ev.friend_info)
        else
            local friend_guid = ev.friend_info.PlayerInfoCommon.PlayerGuid
            local current_friend = self.IMFriendList:getFriendInfo(friend_guid)
            local friend = self.ControllerMgr.ViewMgr:createView("Friend")
            friend:setFriends(current_friend)
        end
    elseif (ev.EventName == "EvUiCurrentChatTargetChange")
    then
        self.CurrentChatTargetGuid = ev.current_chattarget
    elseif (ev.EventName == "EvUiClickInviteFriendPlay")
    then
        local invite_friend = self.ControllerMgr.ViewMgr:createView("InviteFriendPlay")
        invite_friend:setFriend()
    elseif (ev.EventName == "EvUiClickDeleteFriendChatRecord")
    then
        if (self.CurrentChatTargetGuid == ev.friend_etguid)
        then
            self.CurrentChatTargetGuid = ""
        end
        self.IMChat:deletePlayerChatRecord(ev.friend_etguid)
    elseif (ev.EventName == "EvUiRequestMailRead")
    then
        local mail_guid = ev.mail_guid
        self.IMMailBox:RequestOperateMail(mail_guid, MailOperateType.Read)
    elseif (ev.EventName == "EvUiRequestMailRecvAttachment")
    then
        local mail_guid = ev.mail_guid
        self.IMMailBox:RequestOperateMail(mail_guid, MailOperateType.RecvAttachment)
    elseif (ev.EventName == "EvUiRequestFriendAddOrRemove")
    then
        local msg_box = self.ControllerMgr.ViewMgr:createView("MsgBox")
        local title = ""
        local content = ""
        local is_add = ev.is_add
        if (is_add == false)
        then
            title = self.ControllerMgr.LanMgr:getLanValue("RemoveFrined")
            content = self.ControllerMgr.LanMgr:getLanValue("DeleteFriend") .. ev.friend_nickname
        else
            title = self.ControllerMgr.LanMgr:getLanValue("AddFriend")
            content = string.format(self.ControllerMgr.LanMgr:getLanValue("SendFriendRequest"), ev.friend_nickname)
        end

        local map_param = {}
        map_param[0] = is_add
        map_param[1] = ev.friend_guid

        msg_box:showMsgBox2(title, content, map_param,
                function(bo, map_pram)
                    if (bo)
                    then
                        local is_addex = map_param[0]
                        local friend_guid = map_param[1]
                        if (is_addex)
                        then
                            local ev = self.ControllerMgr.ViewMgr:getEv("EvUiAddFriend")
                            if (ev == nil)
                            then
                                ev = EvUiAddFriend:new(nil)
                            end
                            ev.friend_etguid = friend_guid
                            self.ControllerMgr.ViewMgr:sendEv(ev)
                        else
                            local ev = self.ControllerMgr.ViewMgr:getEv("EvUiDeleteFriend")
                            if (ev == nil)
                            then
                                ev = EvUiDeleteFriend:new(nil)
                            end
                            ev.friend_etguid = friend_guid
                            self.ControllerMgr.ViewMgr:sendEv(ev)
                        end
                    end
                end
        )
    end
end

function ControllerIM:OnIMAddFriendReqRequestResult(result)
    self.IMFriendList:OnIMAddFriendReqRequestResult(result)
end

function ControllerIM:OnIMAddFriendResRequestResult(result)
    self.IMFriendList:OnIMAddFriendResRequestResult(result)
end

function ControllerIM:OnIMDeleteFriendRequestResult(result)
    self.IMFriendList:OnIMDeleteFriendRequestResult(result)
end

function ControllerIM:OnIMFriendLoginNotify(player_guid)
    self.IMFriendList:OnIMFriendLoginNotify(player_guid)
end

function ControllerIM:OnIMFriendLogoutNotify(player_guid)
    self.IMFriendList:OnIMFriendLogoutNotify(player_guid)
end

function ControllerIM:OnIMFriendInfoCommonUpdateNotify(player_info_common)
    self.IMFriendList:OnIMFriendInfoCommonUpdateNotify(player_info_common)
end

function ControllerIM:OnIMFriendInfoMoreUpdateNotify(player_info_more)
    self.IMFriendList:OnIMFriendInfoMoreUpdateNotify(player_info_more)
end

function ControllerIM:OnIMFriendInfoRealtimeUpdateNotify(player_info_realtime)
    self.IMFriendList:OnIMFriendInfoRealtimeUpdateNotify(player_info_realtime)
end

function ControllerIM:OnIMFriendListAddNotify(list_player)
    self.IMFriendList:OnIMFriendListAddNotify(list_player)
end

function ControllerIM:OnIMFriendListRemoveNotify(player_guid)
    self.IMFriendList:OnIMFriendListRemoveNotify(player_guid)
end

function ControllerIM:OnIMFindFriendNotify(list_player)
    self.IMFriendList:OnIMFindFriendNotify(list_player)
end

function ControllerIM:OnIMRecommandFriendNotify(list_player)
    self.IMFriendList:OnIMRecommandFriendNotify(list_player)
end

function ControllerIM:OnIMEventPush2ClientNotify(ev)
    self.IMFriendList:OnIMEventPush2ClientNotify(ev)
end

function ControllerIM:OnIMFriendGoldUpdate(gold_update)
    self.IMFriendList:OnIMFriendGoldUpdate(gold_update)
end

function ControllerIM:OnIMChatRecvMsgNotify(msg)
    self.IMChat:OnIMChatRecvMsgNotify(msg)
end

function ControllerIM:OnPlayerFeedbackRecvMsgNotify(msg)
    self.IMFeedback:OnPlayerFeedbackRecvMsgNotify(msg)
end

function ControllerIM:OnPlayerFeedbackGetListNotify(list_msg, readconfirm_msg_id)
    self.IMFeedback:OnPlayerFeedbackGetListNotify(list_msg, readconfirm_msg_id)
end

function ControllerIM:OnIMChatRecvBatchMsgNotify(list_msg)
    local t = nil
    if list_msg ~= nil then
        t = {}
        for i, v in pairs(list_msg) do
            local m = ChatMsgClientRecv:new(nil)
            m:setData(v)
            table.insert(t, m)
        end
    end
    self.IMChat:OnIMChatRecvBatchMsgNotify(t)
end

function ControllerIM:OnIMChatRecordRequestResult(list_msg)
    local t = nil
    if list_msg ~= nil then
        t = {}
        for i, v in pairs(list_msg) do
            local m = ChatMsgClientRecv:new(nil)
            m:setData(v)
            table.insert(t, m)
        end
    end
    self.IMChat:OnIMChatRecordRequestResult(t)
end

function ControllerIM:OnIMMailListInitNotify(list_mail)
    self.IMMailBox:OnIMMailListInitNotify(list_mail)
end

function ControllerIM:OnIMMailAddNotify(mail)
    self.IMMailBox:OnIMMailAddNotify(mail)
end

function ControllerIM:OnIMMailDeleteNotify(mail_guid)
    self.IMMailBox:OnIMMailDeleteNotify(mail_guid)
end

function ControllerIM:OnIMMailUpdateNotify(mail)
    self.IMMailBox:OnIMMailUpdateNotify(mail)
end

function ControllerIM:OnIMMailOperateRequestResult(result)
    self.IMMailBox:OnIMMailOperateRequestResult(result)
end

function ControllerIM:setMainUiIMInfo()
    local view_main = self.ControllerMgr.ViewMgr:getView("Main")
    if (view_main ~= nil)
    then
        view_main:setFriendInfo(self.IMFriendList.MapFriendList)
        view_main:setRecommandFriendInfo(self.IMFriendList.ListRecommendPlayer)
        view_main:setNewChatCount(self.IMChat:getAllNewChatCount())
    end
end

function ControllerIM:showIMResult(result_title, result)
    local msg = ""
    if (result == IMResult.Success)
    then
        msg = result_title .. self.ControllerMgr.LanMgr:getLanValue("Success");
        ViewHelper:UiShowInfoSuccess(msg)
        return
    elseif (result == IMResult.Failed)
    then
        msg = result_title .. self.ControllerMgr.LanMgr:getLanValue("Failed")
    elseif (result == IMResult.Exist)
    then
        msg = result_title .. self.ControllerMgr.LanMgr:getLanValue("Exists")
    elseif (result == IMResult.Timeout)
    then
        msg = result_title .. self.ControllerMgr.LanMgr:getLanValue("TimeOut")
    elseif (result == IMResult.DbError)
    then
        msg = self.ControllerMgr.LanMgr:getLanValue("ServerError")
    elseif (result == IMResult.FriendExist)
    then
        msg = self.ControllerMgr.LanMgr:getLanValue("FriendExists")
    elseif (result == IMResult.FriendNotExist)
    then
        msg = self.ControllerMgr.LanMgr:getLanValue("FriendNotExists")
    elseif (result == IMResult.AddFriendCanntAddSelf)
    then
        msg = self.ControllerMgr.LanMgr:getLanValue("AddSelfFriendTips")
    elseif (result == IMResult.AddFriendInBlackList)
    then
        msg = self.ControllerMgr.LanMgr:getLanValue("FrinedInBlackListTips")
    elseif (result == IMResult.AddFriendEventExist)
    then
        msg = self.ControllerMgr.LanMgr:getLanValue("AddFriendRequestExists")
    elseif (result == IMResult.AddFriendEventNotExist)
    then
        msg = self.ControllerMgr.LanMgr:getLanValue("HandleAddFriendRequestFailed")
    end

    ViewHelper:UiShowInfoFailed(msg)
end

function ControllerIM:getMails()
    return self.IMMailBox:getMails()
end

function ControllerIM:haveNewMail()
    local have_new = false
    if (self.IMMailBox ~= nil)
    then
        have_new = self.IMMailBox:haveNewMail()
    end
    return have_new
end

function ControllerIM:isFriend(friend_guid)
    if (self.IMFriendList.MapFriendList[friend_guid] ~= nil)
    then
        return true
    else
        return false
    end
end

ControllerIMFactory = ControllerFactory:new()

function ControllerIMFactory:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.ControllerName = "IM"
    return o
end

function ControllerIMFactory:createController(controller_mgr, controller_data, guid)
    local controller = ControllerIM:new(nil, controller_mgr, controller_data, guid)
    return controller
end
	