IMFeedback = {}

function IMFeedback:new(o,co_im)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	self.ControllerIM = co_im
	self.MapChats = {}
	self.MapChatsShow = {}
	self.MapChatIndex = {}
	self.MapChatIndexTmp = {}
	self.HaveNewMsg = false
	return o
end

function IMFeedback:OnPlayerFeedbackRecvMsgNotify(msg)
	local self_guid = self.ControllerIM.Guid
	local c_msg = ChatMsgClientRecv:new(nil)
	c_msg:setData(msg)
	if(c_msg.sender_guid ~= self_guid  and c_msg.recver_guid ~= self_guid)
	then
		return
	end
	self.HaveNewMsg = true
	self:recvMsg(self.MapChats, c_msg)
end

function IMFeedback:OnPlayerFeedbackGetListNotify(list_msg,readconfirm_msg_id)
	local msg_count = #list_msg
	if (list_msg == nil or msg_count == 0)
	then
		return
	end

	local last_record = list_msg[msg_count]

	if last_record.msg_id ~= readconfirm_msg_id then
		self.HaveNewMsg = true
	end

	self:recvMsgs(self.MapChats, list_msg)
end

function IMFeedback:requestChatReadConfirm()
	self.HaveNewMsg = false
	self.ControllerIM.ControllerMgr.RPC:RPC0(CommonMethodType.PlayerFeedbackReadConfirmRequest)
end

function IMFeedback:requestIMFeedbackSendMsg(chat_msg)
	self.ControllerIM.ControllerMgr.RPC:RPC1(CommonMethodType.PlayerFeedbackSendMsgRequest, chat_msg)
end

function IMFeedback:getListChatShow()
	return self.MapChatsShow
end

function IMFeedback:getChatRecords()
	return self.MapChats
end

function IMFeedback:recvMsg(map_records,msg)
	table.insert(map_records,msg)
	self:createChatShowTm(msg)

	local ev = self.ControllerIM.ControllerMgr.ViewMgr:getEv("EvEntityReceiveFeedbackChat")
	if(ev == nil)
	then
		ev = EvEntityReceiveFeedbackChat:new(nil)
	end
	ev.chat_msg = msg
	self.ControllerIM.ControllerMgr.ViewMgr:sendEv(ev)
end

function IMFeedback:recvMsgs(map_records,list_msg)
	for key,value in pairs(list_msg) do
		table.insert(map_records,value)
	end

	for key,value in pairs(list_msg) do
		self:createChatShowTm( value)
	end

	local list_chatshow = self:getListChatShow()
	local ev = self.ControllerIM.ControllerMgr.ViewMgr:getEv("EvEntityReceiveFeedbackChats")
	if(ev == nil)
	then
		ev = EvEntityReceiveFeedbackChats:new(nil)
	end
	ev.list_allchats = list_chatshow
	self.ControllerIM.ControllerMgr.ViewMgr:sendEv(ev)
end

function IMFeedback:createChatShowTm(new_chat)
	if (new_chat == nil)
	then
		return
	end

	if (#self.MapChatsShow == 0)
	then
		local client_show = ChatMsgClientShow:new(nil)
		client_show.dt = new_chat.dt
		client_show.is_tm = true
		table.insert(self.MapChatsShow,client_show)
	else
		local last_chat = self.MapChatsShow[#self.MapChatsShow]
		local l_tm = CS.System.DateTime.Parse(last_chat.dt)
		local n_tm = CS.System.DateTime.Parse(new_chat.dt)
		local is_same_minute = CS.Casinos.UiHelper.timeIsSameMinute(l_tm,n_tm)
		if (is_same_minute == false)
		then
			local client_show = ChatMsgClientShow:new(nil)
			client_show.dt = new_chat.dt
			client_show.is_tm = true
			table.insert(self.MapChatsShow,client_show)
		end
	end
	local real_chat = self:transationChat(new_chat)
	table.insert(self.MapChatsShow,real_chat)
end

function IMFeedback:transationChat(chat)
	local chat_show = ChatMsgClientShow:new(nil)
	chat_show.dt = chat.dt
	chat_show.msg_id = chat.msg_id
	chat_show.sender_guid = chat.sender_guid
	chat_show.sender_nickname = chat.sender_nickname
	chat_show.sender_viplevel = chat.sender_viplevel
	chat_show.recver_guid = chat.recver_guid
	chat_show.recver_nickname = chat.recver_nickname
	chat_show.recver_viplevel = chat.recver_viplevel
	chat_show.msg = chat.msg
	chat_show.dt = chat.dt
	chat_show.is_tm = false
	return chat_show
end