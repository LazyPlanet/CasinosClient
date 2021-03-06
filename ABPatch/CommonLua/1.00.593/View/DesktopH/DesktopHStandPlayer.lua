DesktopHStandPlayer = {}

function DesktopHStandPlayer:new(o,btn_stand_player,chat_parent,view_desktop)
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    o.GBtnStandPlayer = btn_stand_player
    o.ItemChat = nil
    o.GCoChatParent = chat_parent
    o.MapWinGolds = {}
    o.MapWinUiGolds = {}
    o.MapFTaskerGetWinGold = {}
    o.ViewDesktopH = view_desktop

    return o
end

function DesktopHStandPlayer:update(tm)        
            if (self.ItemChat ~= nil)
            then
                self.ItemChat:update(tm)
			end
end

function DesktopHStandPlayer:initStandPlayer()        
   self:_goldEnPool()
   self.MapWinGolds = {}
end

function DesktopHStandPlayer:destroy()        
   self:_goldEnPool()
   self:_cancelTask()
end

function DesktopHStandPlayer:betGolds(bet_potindex, chip_value)
    local from = self:getStandPlayerCenterPos()
    local bet_pot = self.ViewDesktopH:getDesktopHBetPot(bet_potindex)
    bet_pot:betGolds(from, chip_value)
    local standplayer_x = self.GBtnStandPlayer.x
    if (CS.DG.Tweening.DOTween.IsTweening(self.GBtnStandPlayer) == false)
    then
       self.GBtnStandPlayer:TweenMoveX(standplayer_x + self.ViewDesktopH.BetAniX, 0.1):OnComplete(
       function()
		  self.GBtnStandPlayer:TweenMoveX(standplayer_x, 0.1)
	   end
	   )
    end
end

function DesktopHStandPlayer:betState()
   self.MapWinGolds = {}
end

function DesktopHStandPlayer:setOtherStandPlayerResultInfo(betpot_index, stand_playerwinchips)
   self.MapWinGolds[betpot_index] = stand_playerwinchips
end

function DesktopHStandPlayer:showWinGoldsAni(pot_index, from)
    local win_gold = 0
	
    if (self.MapWinGolds[pot_index] ~= nil)
    then
		win_gold = self.MapWinGolds[pot_index]
        if (win_gold <= 0)
        then
            return
        end

        local bet_pot = self.ViewDesktopH:getDesktopHBetPot(pot_index)
        local list_golds = self.MapWinUiGolds[pot_index]                
        if (list_golds == nil)
        then
            list_golds = {}
        end

        self.ViewDesktopH:createGolds(list_golds, nil, win_gold, bet_pot, 9)
        self.MapWinUiGolds[pot_index] = list_golds

        local delay_tm = 0.0
        local delay_t = self.ViewDesktopH:getMoveIntervalTm(#list_golds)
		for key,value in pairs(list_golds) do
			local to = bet_pot:getRandomChipPos()
            value:initMove(from, to,
                DesktopHUiGold.MOVE_CHIP_TM, DesktopHUiGold.MOVE_SOUND, nil, nil, false, delay_tm, true)
            delay_tm = delay_tm + delay_t
		end

        local map_param = {}
        map_param[0] = win_gold
        map_param[1] = pot_index
        local t = CS.Casinos.FTMgr.Instance:startTask(DesktopHBetPot.GivePlayerAniTm - DesktopHBetPot.WinShowAniTm)
        local tasker = CS.Casinos.FTMgr.Instance:whenAll(map_param, 
		function(map_param)
			self:_playWinGoldAni(map_param)
		end
		, t)
        self.MapFTaskerGetWinGold[pot_index] = tasker
    end
end

function DesktopHStandPlayer:reset()
   self:_goldEnPool()
   self:_cancelTask()
end

function DesktopHStandPlayer:setChatText(chat_info)
    local sorting_order = self.GCoChatParent.sortingOrder + self.ViewDesktopH.DesktopHGoldPool:getMaxGoldSortOrder()
    if (self.ItemChat == nil)
    then
        local co_chatname = self.ViewDesktopH.UiDesktopHBase:getStandPlayerChatName()
        self.ItemChat = self.ViewDesktopH.UiDesktopChatParent:addChat(co_chatname, self.ViewDesktopH.ComUi, self.GCoChatParent.position)
        self.ItemChat:setChatTextAndSortingOrder(chat_info, sorting_order)
    else
        self.ItemChat:setChatTextAndSortingOrder(chat_info, sorting_order)
    end
end

function DesktopHStandPlayer:getStandPlayerCenterPos()
   local pos = self.GBtnStandPlayer.xy
    local x = pos.x
    x = x + self.GBtnStandPlayer.width / 2
    pos.x = x
    local y = pos.y
    y = y + self.GBtnStandPlayer.height / 2
   pos.y = y
   return pos
end

function DesktopHStandPlayer:_playWinGoldAni(map_param)
   local pot_index = map_param[1]
   local list_gold = self.MapWinUiGolds[pot_index]
   if (list_gold ~= nil)
   then
       local to = self:getStandPlayerCenterPos()
       local delay_tm = 0.0
       local l = #list_gold
       local delay_t = self.ViewDesktopH:getMoveIntervalTm(l)
       for i, v in pairs(list_gold) do
           v:initMove(v.GCoGold.xy, to,
                   DesktopHUiGold.MOVE_CHIP_TM, DesktopHUiGold.MOVE_SOUND, nil, nil, true, delay_tm,false)
           delay_tm = delay_tm + delay_t
       end

       self.MapWinUiGolds[pot_index] = nil
       self.MapWinGolds[pot_index]= nil
   end
end

function DesktopHStandPlayer:_cancelTask()
	for key,value in pairs(self.MapFTaskerGetWinGold) do
		if (value ~= nil)
		then
			value:cancelTask()
		end
	end
   --[[table.foreach(self.MapFTaskerGetWinGold,
		function(k,v)
			if (v ~= nil)
			then
			    v:cancelTask()
			end
	    end
   )]]
   self.MapFTaskerGetWinGold = {}
end

function DesktopHStandPlayer:_goldEnPool()
	for key,value in pairs(self.MapWinUiGolds) do
        for i, v in pairs(value) do
            self.ViewDesktopH.DesktopHGoldPool:goldHEnPool(v)
        end
	end
    --[[table.foreach(self.MapWinUiGolds,
		function(k,v)
			for i = 0, v.Count - 1 do			
			    self.ViewDesktopH.DesktopHGoldPool:goldHEnPool(chips)
			end
		end
    )]]
    self.MapWinUiGolds = {}
end

function DesktopHStandPlayer:_onClick()     
	local ev = self.ViewMgr:getEv("EvDesktopHClickStandPlayerBtn")
	if(ev == nil)
	then
		ev = EvDesktopHClickStandPlayerBtn:new(nil)
	end
	self.ViewMgr:sendEv(ev)
end