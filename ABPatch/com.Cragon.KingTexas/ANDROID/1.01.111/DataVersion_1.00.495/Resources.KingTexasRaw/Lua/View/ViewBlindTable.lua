ViewBlindTable = ViewBase:new()

function ViewBlindTable:new(o)
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

function ViewBlindTable:onCreate()
	ViewHelper:PopUi(self.ComUi,self.ViewMgr.LanMgr:getLanValue("BlindTable"))
	local com_bg = self.ComUi:GetChild("ComBgAndClose").asCom
	local btn_close = com_bg:GetChild("BtnClose").asButton
	btn_close.onClick:Add(
		function()
			self:close()
		end
	)
	local com_shade = com_bg:GetChild("ComShade").asCom
	com_shade.onClick:Add(
		function()
			self:close()
		end
	)
	local btn_fast = self.ComUi:GetChild("BtnTabFast").asButton
	btn_fast.onClick:Add(
		function()
			self:onClickBtnFast()
		end
	)
	local btn_normal = self.ComUi:GetChild("BtnTabNormal").asButton
	btn_normal.onClick:Add(
		function()
			self:onClickBtnNormal()
		end
	)
	local btn_slow = self.ComUi:GetChild("BtnTabSlow").asButton
	btn_slow.onClick:Add(
		function()
			self:onClickBtnSlow()
		end
	)
	self.GControllerState = self.ComUi:GetController("ControllerState")
	self.GListBlind = self.ComUi:GetChild("ListBlind").asList
	self:onClickBtnFast()
end

function ViewBlindTable:close()
	self.ViewMgr:destroyView(self)
end


function ViewBlindTable:onClickBtnFast()
	self.GControllerState:SetSelectedIndex(0)
	self:setList(1)
end

function ViewBlindTable:onClickBtnNormal()
	self.GControllerState:SetSelectedIndex(1)
	self:setList(2)
end

function ViewBlindTable:onClickBtnSlow()
	self.GControllerState:SetSelectedIndex(2)
	self:setList(3)
end

function ViewBlindTable:setList(type)
	self.GListBlind:RemoveChildrenToPool()
	local tableName = nil
	if(type == 1)
	then
		tableName = "TexasRaiseBlindsFast"
	elseif(type == 2)
	then
		tableName = "TexasRaiseBlindsNormal"
	elseif(type == 3)
	then
		tableName = "TexasRaiseBlindsSlow"
	end
	local tb_mgr = CS.Casinos.CasinosContext.Instance.TbDataMgrLua
	local list_data = tb_mgr:GetMapData(tableName)
	for i = 1,#list_data do
		local data = list_data[i]
		local com = self.GListBlind:AddItemFromPool()
		ItemBlind:new(nil,com,data,self.ViewMgr.LanMgr.LanBase)
	end
end

ViewBlindTableFactory = ViewFactory:new()

function ViewBlindTableFactory:new(o,ui_package_name,ui_component_name,
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

function ViewBlindTableFactory:createView()	
	local view = ViewBlindTable:new(nil)	
	return view
end