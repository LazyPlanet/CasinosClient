UnitRedEnvelopes = Unit:new()

function UnitRedEnvelopes:new(o,item)
    o = o or {}
	setmetatable(o,self)
	self.__index = self
	o.UnitType = "RedEnvelopes"
	o.Item = item
	o.CreateTime = nil
    o.Value = 0
	if (o.Item.ItemData.map_unit_data == nil or o.Item.ItemData.map_unit_data.Count == 0)
    then        
        o.CreateTime = CS.System.DateTime.UtcNow
        o:_saveData()
    end

    o:_setup()
	
	return o
end

function UnitRedEnvelopes:_setup()
    local create_time = self.Item.ItemData.map_unit_data[1]
            if (CS.System.String.IsNullOrEmpty(create_time) == false)
            then
                self.CreateTime = CS.Casinos.LuaHelper.JsonDeserializeDateTime(create_time)
            end

    local value = self.Item.ItemData.map_unit_data[2]
    self.Value = value
end
		
function UnitRedEnvelopes:_saveData()
            if (self.Item.ItemData.map_unit_data == nil)
            then
                self.Item.ItemData.map_unit_data = CS.Casinos.LuaHelper.GetNewStringStringMap()
            end

    self.Item.ItemData.map_unit_data[1] = CS.Casinos.EbTool.jsonSerialize(self.CreateTime)
    self.Item.ItemData.map_unit_data[2] = self.Value
end



UnitFacRedEnvelopes = UnitFac:new()

function UnitFacRedEnvelopes:new(o)
    o = o or {}
	setmetatable(o,self)
	self.__index = self	

	return o
end

function UnitFacRedEnvelopes:createUnit(item)	
	return UnitRedEnvelopes:new(nil,item)
end