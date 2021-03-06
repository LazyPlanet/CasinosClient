ViewEditAddress = ViewBase:new()

function ViewEditAddress:new(o)
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

function ViewEditAddress:onCreate()
	ViewHelper:PopUi(self.ComUi,self.ViewMgr.LanMgr:getLanValue("EditAddress"))
	self.ViewMgr:bindEvListener("EvEntityResponseGetReceiverAddress", self)
	local com_bg = self.ComUi:GetChild("ComBgAndClose").asCom
	local btn_close = com_bg:GetChild("BtnClose").asButton
	btn_close.onClick:Add(
		function()
			self:onClickBtnClose()
		end
	)
	local com_shade = com_bg:GetChild("ComShade").asCom
	com_shade.onClick:Add(
		function()
			self:onClickBtnClose()
		end
	)
	local btn_save = self.ComUi:GetChild("BtnSave").asButton
	btn_save.onClick:Add(
		function()
			self:onClickBtnSave()
		end
	)
	self.GInputTextName = self.ComUi:GetChild("TextName").asTextField
	self.GInputTextPhoneNum = self.ComUi:GetChild("TextPhoneNum").asTextField
	self.GInputTextQQNum = self.ComUi:GetChild("TextQQNum").asTextField
	self.GInputTextWeChatNum = self.ComUi:GetChild("TextWeChatNum").asTextField
	self.GInputTextAddress = self.ComUi:GetChild("TextAddress").asTextField
	self.GInputTextEmail = self.ComUi:GetChild("TextEmail").asTextField
	local ev = self.ViewMgr:getEv("EvUiRequestGetReceiverAddress")
	if(ev == nil)
	then
		ev = EvUiRequestGetReceiverAddress:new(nil)
	end
	self.ViewMgr:sendEv(ev)
end

function ViewEditAddress:onHandleEv(ev)
	if(ev.EventName == "EvEntityResponseGetReceiverAddress")
	then
		local address = ev.Address
		self:setContent(address)
	end
end

function ViewEditAddress:setContent(address)
	self.GInputTextName.text = address.Name
	self.GInputTextPhoneNum.text = address.PhoneNum
	self.GInputTextQQNum.text = address.QQ
	self.GInputTextWeChatNum.text = address.Weixin
	self.GInputTextAddress.text = address.Address
	self.GInputTextEmail.text = address.EMail
end

function ViewEditAddress:onClickBtnClose()
	self.ViewMgr:destroyView(self)
end

function ViewEditAddress:onClickBtnSave()
	if(self:checkInputContent() == true)
	then
		local address = PlayerAddress:new(nil)
		address.Name = self.GInputTextName.text
		address.PhoneNum = self.GInputTextPhoneNum.text
		address.QQ = self.GInputTextQQNum.text
		address.Weixin = self.GInputTextWeChatNum.text
		address.Address = self.GInputTextAddress.text
		address.EMail = self.GInputTextEmail.text
		local ev = self.ViewMgr:getEv("EvUiRequestEditReceiverAddress")
		if(ev == nil)
		then
			ev = EvUiRequestEditReceiverAddress:new(nil)
		end
		ev.Address = address
		self.ViewMgr:sendEv(ev)
		self.ViewMgr:destroyView(self)
	end
end

function ViewEditAddress:checkInputContent()
	local text_name = self.GInputTextName.text
	local lan_name = string.len(text_name)
	if(lan_name == 0)
	then
		self:showWrongInputTips("请您输入收货人的姓名")
		return false
	end
	for i = 1,string.len(text_name) do
		local temp = string.byte(text_name,i)
		if(temp <= 64 or (temp >= 91 and temp <= 96) or (temp >= 123 and temp <= 127))
		then
			self:showWrongInputTips("名字存在非法字符，请重新输入！")
			return false
		end
	end
	local len_phoneNum = string.len(self.GInputTextPhoneNum.text)
	if(len_phoneNum == 0)
	then
		self:showWrongInputTips("请您输入收货人的手机号码")
		return false
	end
	if(len_phoneNum ~= 11)
	then
		self:showWrongInputTips("您输入的手机号码长度有误")
		return false
	end
	--[[local len_QQ = string.len(self.GInputTextQQNum.text)
	if(len_QQ < 5 or len_QQ > 11)
	then
		self:showWrongInputTips("请您输入正确的QQ号码")
		return false
	end
	local len_wechat = string.len(self.GInputTextWeChatNum.text)
	if(len_wechat == 0)
	then
		self:showWrongInputTips("请您输入正确的微信号码")
		return false
	end
	local len_address = string.len(self.GInputTextAddress.text)
	if(len_address == 0)
	then
		self:showWrongInputTips("请您输入收货人的正确地址")
		return false
	end
	local len_email = string.len(self.GInputTextEmail.text)
	if(len_email == 0)
	then
		self:showWrongInputTips("请您输入收货人的电子邮箱")
		return false
	end]]
	return true
end

function ViewEditAddress:showWrongInputTips(tips)
	local msg_box = self.ViewMgr:createView("MsgBox")
	msg_box:showMsgBox1("",tips)
end

ViewEditAddressFactory = ViewFactory:new()

function ViewEditAddressFactory:new(o,ui_package_name,ui_component_name,
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

function ViewEditAddressFactory:createView()	
	local view = ViewEditAddress:new(nil)	
	return view
end