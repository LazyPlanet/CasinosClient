ControllerBag = ControllerBase:new(nil)

function ControllerBag:new(o,controller_mgr,controller_data,guid)
	o = o or {}
	setmetatable(o,self)
	self.__index = self

	o.ControllerData = controller_data
	o.ControllerMgr = controller_mgr
	o.Guid = guid
	o.ViewMgr = ViewMgr:new(nil)

	return o
end

function ControllerBag:onCreate()
	self.RPC = self.ControllerMgr.RPC
	self.MC = CommonMethodType
	-- 背包中所有道具推送给Client的通知
	self.RPC:RegRpcMethod1(self.MC.BagItemPush2ClientNotify,function(list_item)
		self:s2cBagItemPush2ClientNotify(list_item)
	end)
	-- 临时礼物变更通知
	self.RPC:RegRpcMethod1(self.MC.BagGiftChangedNotify,function(item_data)
		self:s2cBagGiftChangedNotify(item_data)
	end)
	-- 通知删除道具
	self.RPC:RegRpcMethod2(self.MC.BagDeleteItemNotify,function(result,item_objid)
		self:s2cBagDeleteItemNotify(result,item_objid)
	end)
	-- 通知添加道具
	self.RPC:RegRpcMethod1(self.MC.BagAddItemNotify,function(item_data)
		self:s2cBagAddItemNotify(item_data)
	end)
	-- 通知更新道具
	self.RPC:RegRpcMethod1(self.MC.BagUpdateItemNotify,function(item_data)
		self:s2cBagUpdateItemNotify(item_data)
	end)
    self.RPC:RegRpcMethod1(self.MC.BagOperateItemNotify,function(item_data)
        self:OnBagOperateItemNotify(item_data)
    end)

	self.ViewMgr:bindEvListener("EvUiRemoveItem",self)
	self.ViewMgr:bindEvListener("EvUiRequestOperateItem",self)
	self.ViewMgr:bindEvListener("EvBindWeChat",self)
	self.ViewMgr:bindEvListener("EvUiLoginSuccessEx",self)
	self.CasinosContext = CS.Casinos.CasinosContext.Instance
	self.MapItem = {}
	self.ListItemGiftNormal = {}
	self.ListItemConsume = {}
	self.CurrentGift = nil
end

function ControllerBag:onDestroy()
	self.ViewMgr:unbindEvListener(self)
	self.MapItem = {}
	self.MapItem = nil
	self.ListItemGiftNormal = {}
	self.ListItemGiftNormal = nil
	self.ListItemConsume = {}
	self.ListItemConsume = nil
	self.CurrentGift = nil
end

function ControllerBag:onUpdate(tm)
end

function ControllerBag:onHandleEv(ev)
	if(ev.EventName == "EvUiRemoveItem")
	then
		local obj_id = ev.obj_id
		self:RequestRemoveGift(obj_id)
	elseif(ev.EventName == "EvUiRequestOperateItem")
	then
		self:requestOperateItem("",ev.ItemObjId)
	elseif(ev.EventName == "EvBindWeChat")
	then
		self.BindAndUseItemObjId = ev.ItemObjId
	elseif(ev.EventName == "EvUiLoginSuccessEx")
	then
		if self.BindAndUseItemObjId ~= nil then
			self:requestOperateItem("",self.BindAndUseItemObjId)
			self.BindAndUseItemObjId = nil
		end
	end
end

function ControllerBag:s2cBagItemPush2ClientNotify(list_item)
	if (list_item ~= nil and #list_item > 0)
	then
		local eb_data_mgr = self.ControllerMgr.TbDataMgr
		for i = 1,#list_item do
			local data = ItemData1:new(nil)
			data:setData(list_item[i])
			local item = Item:new(nil,eb_data_mgr,data)
			self.MapItem[item.ItemData.item_objid] = item
			if (item.UnitLink.UnitType == "GiftNormal")
			then
				table.insert(self.ListItemGiftNormal,item)
			elseif(item.UnitLink.UnitType == "Consume" or item.UnitLink.UnitType == "GoodsVoucher" or item.UnitLink.UnitType == "GoldPackage" or item.UnitLink.UnitType == "WechatRedEnvelopes")
			then
				table.insert(self.ListItemConsume,item)
			end
		end
	end
	self:sortListBagItem()
end


function ControllerBag:s2cBagGiftChangedNotify(item_data)
	local data = nil
	if(item_data ~= nil)
	then
		data = ItemData1:new(nil)
		data:setData(item_data)
	end
	if (data == nil or CS.System.String.IsNullOrEmpty(data.item_objid) or data.map_unit_data == nil)
	then
		self.CurrentGift = nil
	else
		local eb_data_mgr = self.ControllerMgr.TbDataMgr
		self.CurrentGift = Item:new(nil,eb_data_mgr,data)
	end

	local ev = self.ControllerMgr.ViewMgr:getEv("EvEntityCurrentTmpGiftChange")
	if(ev == nil)
	then
		ev = EvEntityCurrentTmpGiftChange:new(nil)
	end
	self.ControllerMgr.ViewMgr:sendEv(ev)
end

function ControllerBag:s2cBagDeleteItemNotify(result,item_objid)
	if (result ~= ProtocolResult.Success)
	then
		ViewHelper:UiShowInfoFailed(self.ViewMgr.LanMgr:getLanValue("RemoveItemFailed"))
		return
	end
	for key,value in pairs(self.MapItem) do
		if(key == item_objid)
		then
			value = nil
			key = nil
			break
		end
	end
	self:removeItemFromList(self.ListItemGiftNormal, item_objid)
	self:removeItemFromList(self.ListItemConsume, item_objid)
	local ev = self.ControllerMgr.ViewMgr:getEv("EvEntityBagDeleteItem")
	if(ev == nil)
	then
		ev = EvEntityBagDeleteItem:new(nil)
	end
	ev.item_objid = item_objid
	self.ControllerMgr.ViewMgr:sendEv(ev)
end

function ControllerBag:OnBagOperateItemNotify(result)
	self:s2cOnOperateItem(result)
end

function ControllerBag:s2cOnOperateItem(result)
	if (result.result ~= ProtocolResult.Success)
	then
		ViewHelper:UiShowInfoFailed(self.ViewMgr.LanMgr:getLanValue("UseItemFailed"))
		return
	end
	ViewHelper:UiShowInfoFailed(self.ViewMgr.LanMgr:getLanValue("UseItemSuccess"))

	--[[local item = nil
    for key,value in pairs(self.MapItem) do
        if(key == result.item_objid)
        then
            item = value
            break
        end
    end
    if (item == nil)
    then
        return
    end
    local ev = self.ControllerMgr.ViewMgr:getEv("EvEntityBagOperateItem")
    if(ev == nil)
    then
        ev = EvEntityBagOperateItem:new(nil)
    end
    ev.item = item
    self.ControllerMgr.ViewMgr:sendEv(ev)]]
end

function ControllerBag:s2cBagAddItemNotify(item_data)
	local data = ItemData1:new(nil)
	data:setData(item_data)
	local eb_data_mgr = self.ControllerMgr.TbDataMgr
	local item = Item:new(nil,eb_data_mgr,data)
	self.MapItem[item.ItemData.item_objid] = item
	if (item.UnitLink.UnitType == "GiftNormal")
	then
		table.insert(self.ListItemGiftNormal,item)
		self:sortListBagItem()
	elseif(item.UnitLink.UnitType == "Consume" or item.UnitLink.UnitType == "GoodsVoucher" or item.UnitLink.UnitType == "GoldPackage" or item.UnitLink.UnitType == "WechatRedEnvelopes")
	then
		table.insert(self.ListItemConsume,item)
	end

	if (item.UnitLink.UnitType == "GiftNormal")
	then
		local gift_normal = item.UnitLink

		if (self.Guid ~= gift_normal.GivePlayerEtGuid)
		then
			if (gift_normal.GiveBy ~= self.Guid)
			then
				local msg = CS.System.String.Format("%s%s：%s", gift_normal.GiveBy, self.ViewMgr.LanMgr:getLanValue("SendItems"),
						item.TbDataItem.Name)
				local msg_box = self.ControllerMgr.ViewMgr:createView("MsgBox")
				msg_box:showMsgBox1(self.ViewMgr.LanMgr:getLanValue("ReceiveItems"), msg, nil)
			end
		end
	end

	local ev = self.ControllerMgr.ViewMgr:getEv("EvEntityBagAddItem")
	if(ev == nil)
	then
		ev = EvEntityBagAddItem:new(nil)
	end
	ev.item = item
	self.ControllerMgr.ViewMgr:sendEv(ev)
end

function ControllerBag:s2cBagUpdateItemNotify(item_data)
	local data = ItemData1:new(nil)
	data:setData(item_data)
	local eb_data_mgr = self.ControllerMgr.TbDataMgr
	local item = Item:new(nil,eb_data_mgr,data)
	self.MapItem[item.ItemData.item_objid] = item
	self:updateItem(self.ListItemGiftNormal,item)
	self:updateItem(self.ListItemConsume,item)
	local msg = self.ViewMgr.LanMgr:getLanValue("UpdateProp") .. self.ControllerMgr.LanMgr:getLanValue(item.TbDataItem.Name)
	ViewHelper:UiShowInfoSuccess(msg)

	local ev = self.ControllerMgr.ViewMgr:getEv("EvEntityBagUpdateItem")
	if(ev == nil)
	then
		ev = EvEntityBagUpdateItem:new(nil)
	end
	ev.item = item
	self.ControllerMgr.ViewMgr:sendEv(ev)

	return item
end

-- 请求使用道具
function ControllerBag:requestOperateItem(operate_id,item_objid)
	local item_operate = ItemOperate:new(nil)
	item_operate.operate_id = operate_id
	item_operate.item_objid = item_objid
	self.RPC:RPC1(self.MC.BagOperateItemRequest,item_operate:getData4Pack())
end

function ControllerBag:getAlreadyHaveItemCount(item_tbid)
	local item_count = 0
	for key,value in pairs(self.MapItem) do
		if (value.TbDataItem.Id == item_tbid)
		then
			item_count = item_count + value.ItemData.count
		end
	end

	return item_count
end

function ControllerBag:RequestRemoveGift(item_objid)
	self.RPC:RPC1(self.MC.BagDeleteItemRequest,item_objid)
end

function ControllerBag:sortListBagItem()
	table.sort(self.ListItemGiftNormal,
			function(x,y)
				local price_typex = x.TbDataItem.PriceType
				local price_typey = y.TbDataItem.PriceType
				if(price_typex ~= price_typey)
				then
					return price_typex > price_typey
				else
					local price_x = x.TbDataItem.Price
					local price_y = y.TbDataItem.Price
					if(price_x ~= price_y)
					then
						return price_x > price_y
					else
						local gift_normalx = x.UnitLink
						local gift_normaly = y.UnitLink
						return gift_normalx.CreateTime > gift_normaly.CreateTime
					end
				end
			end
	)
end

function ControllerBag:removeItemFromList(list_item,item_objid)
	local item = nil
	local item_key = nil
	for key,value in pairs(list_item) do
		if(value.ItemData.item_objid == item_objid)
		then
			item = value
			item_key = key
			break
		end
	end
	if (item ~= nil)
	then
		table.remove(list_item,item_key)
	end
end

function ControllerBag:updateItem(list_item,item)
	local item_index = nil
	for key,value in pairs(list_item) do
		if(value.ItemData.item_objid == item.ItemData.item_objid)
		then
			item_index = key
			break
		end
	end
	if(item_index ~= nil)
	then
		table.remove(list_item,item_index)
		table.insert(list_item,item_index,item)
		self:sortListBagItem()
	end
end

function ControllerBag:haveItem(tb_id)
	local l = self.ListItemConsume
	local have_i = false
	local item = nil
	for i, v in pairs(l) do
		if v.TbDataItem.Id == tb_id then
			have_i = true
			item = v
			break
		end
	end

	return have_i,item
end


ControllerBagFactory = ControllerFactory:new()

function ControllerBagFactory:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	self.ControllerName = "Bag"
	return o
end

function ControllerBagFactory:createController(controller_mgr,controller_data,guid)
	local controller = ControllerBag:new(nil,controller_mgr,controller_data,guid)
	return controller
end