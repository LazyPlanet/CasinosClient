TbDataLanZh = TbDataBase:new()

function TbDataLanZh:new(id)
	o = {}
	setmetatable(o,self)
	self.__index = self
	o.Id = id
	o.ViewObjType = nil
	o.LanguageKey = nil
	o.LanguageValue = nil

	return o
end

function TbDataLanZh:load(list_datainfo)
	for i = 0, list_datainfo.Count - 1 do
		local data = list_datainfo[i]
		if(data.data_name == "I_ObjType")
		then
			self.ViewObjType = tonumber(data.data_value)
		end
		if(data.data_name == "T_LanguageKey")
		then
			self.LanguageKey = tostring(data.data_value)
		end
		if(data.data_name == "T_LanguageValue")
		then
			self.LanguageValue = tostring(data.data_value)		
		end
	end	
end


TbDataFactoryLanZh = TbDataFactoryBase:new()

function TbDataFactoryLanZh:new(o)
	o = o or {}  
    setmetatable(o,self)  
    self.__index = self  		
	
    return o
end

function TbDataFactoryLanZh:createTbData(id)
	return TbDataLanZh:new(id)
end