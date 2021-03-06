ItemDesktopHBetOperate = {}

function ItemDesktopHBetOperate:new(o,bet_operat,ui_desktoph)
    o = o or {}
    setmetatable(o,self)
    self.__index = self
	o.ViewDesktopH = ui_desktoph
            o.GComBetOperate = bet_operat
            o.GComBetOperate.onClick:Add(
                    function()
                        o:_onClick()
                end            )
			o.GLoaderOperateBg = nil
			o.GImageOperateCurrent = nil
			o.mTbOperateId = nil
			o.mIsCurrentOperate = nil
			o.mCanOperate = nil
    o.ViewMgr = ViewMgr:new(nil)
    return o
end

function ItemDesktopHBetOperate:setOperateInfo(tb_operate_id, operate_value, can_operate, is_currentoperate)        
            self.mTbOperateId = tb_operate_id
            self.mCanOperate = can_operate
            self.mIsCurrentOperate = is_currentoperate
            self.GLoaderOperateBg = self.GComBetOperate:GetChild("GoldIcon").asLoader
            local package_name = self.ViewDesktopH.UiDesktopHPackageNameTitle
            if (CS.Casinos.CasinosContext.Instance.UseLan)
            then
                package_name = self.ViewDesktopH.ViewMgr.LanMgr:getLanPackageName()
            end
            self.GLoaderOperateBg.icon = CS.Casinos.UiHelperCasinos.FormatePackageImagePath(package_name, "Gold" .. operate_value)
            self.GImageOperateCurrent = self.GComBetOperate:GetChild("GoldChoose")
            local text_operate_value = self.GComBetOperate:GetChild("TextOperateValue")
            if (text_operate_value ~= nil)
            then
                text_operate_value.text = CS.Casinos.CasinosContext.Instance.UiChipShowHelper.getGoldShowStr(operate_value, self.ViewDesktopH.ViewMgr.LanBase, true, 0)
            end
            self:_setCanOperate(self.mCanOperate)
            self:_setIsCurrentOperate(self.mIsCurrentOperate)
end

function ItemDesktopHBetOperate:setIsCurrentOperate(is_currentoperate)        
            self.mIsCurrentOperate = is_currentoperate
            self:_setIsCurrentOperate(self.mIsCurrentOperate)
end

function ItemDesktopHBetOperate:setcanOperate(can_operate)        
            self.mCanOperate = can_operate
            self:_setCanOperate(self.mCanOperate)
end

function ItemDesktopHBetOperate:_setCanOperate(can_operate)        
            if (can_operate)
            then
                self.GLoaderOperateBg.alpha = 1
                self.GComBetOperate.enabled = true            
            else            
                self.GLoaderOperateBg.alpha = 0.5
                self.GComBetOperate.enabled = false
            end
end

function ItemDesktopHBetOperate:_setIsCurrentOperate(is_currentoperate)        
            if (self.GImageOperateCurrent ~= nil)
            then	
                self.GImageOperateCurrent.visible = is_currentoperate
            end
end

function ItemDesktopHBetOperate:_onClick()        
			local ev = self.ViewMgr:getEv("EvDesktopHClickBetOperateType")
				if(ev == nil)
				then
					ev = EvDesktopHClickBetOperateType:new(nil)
				end		
				ev.tb_bet_operateid = self.mTbOperateId
				self.ViewMgr:sendEv(ev)          
end