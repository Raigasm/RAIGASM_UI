local L = LibStub("AceLocale-3.0"):GetLocale("GearHelper")

local prefixAddon = "GeARHeLPeRPReFIX"
local gagne = 0

waitingIDTable = waitingIDTable

--[[
Function : AddonLoaded
Scope : local
Description : Initialise l'addon au moment de son chargement
Input : string (le nom de l'addono chargé)
Author : Raphaël Daumas
]]
local function AddonLoaded(_, _, name)
	if GearHelper.db.global.templates == nil then
		GearHelper.db.global.templates = {}
	end

	GearHelper:InitTemplates()

	if name == addonName then
		RegisterAddonMessagePrefix(prefixAddon)
		print(GearHelper:ColorizeString(L["merci"], "Vert"))
	end
end

--[[
Function : OnMerchantShow
Scope : local
Description : Vend / répare automatiquement quand la fenetre d'un marchant s'ouvre
Author : Raphaël Daumas
]]
local function OnMerchantShow()
	gagne = 0
	if GearHelper.db.profile.sellGreyItems then
		for bag = 0, 4 do
			for slot = 1,GetContainerNumSlots(bag) do
				if GetContainerItemID(bag, slot) ~= nil then
					local id = GetContainerItemID(bag, slot)
					if id then
						local result = GearHelper:SiObjetGris(id)
						if result[1] then
							UseContainerItem(bag, slot)
							gagne = gagne + result[2]
						end
					end
				end
			end
		end
	end

	if CanMerchantRepair() and GearHelper.db.profile.autoRepair == 1 or GearHelper.db.profile.autoRepair == 2 then
		local argentPossedee = GetMoney()
		local prix = GetRepairAllCost()
		local droitGuilde = ""
		local argentGuilde = ""

		if IsInGuild() and CanGuildBankRepair() then
			droitGuilde = GetGuildBankWithdrawMoney()
			argentGuilde = GetGuildBankMoney()
		end
		if prix > 0 then
			if  GearHelper.db.profile.autoRepair == 1 then
				if argentPossedee >= prix then
					RepairAllItems(false)
					print(GearHelper:ColorizeString(L["repairCost"], "Rose")..math.floor(prix/10000)..L["dot"]..math.floor((prix % 10000) / 100)..L["gold"])
				else
					print(L["CantRepair"])
				end
			elseif GearHelper.db.profile.autoRepair == 2 then
				if droitGuilde ~= nil and (droitGuilde == -1 or (droitGuilde > argentGuilde and argentGuilde > prix)) then
					RepairAllItems(true)
					print(cRose..L["guildRepairCost"]..math.floor(prix/10000)..L["dot"]..math.floor((prix % 10000) / 100)..L["gold"])
				else
					if argentPossedee >= prix then
						RepairAllItems(false)
						print(cRose..L["repairCost"]..math.floor(prix/10000)..L["dot"]..math.floor((prix % 10000) / 100)..L["gold"])
					else
						print(L["CantRepair"])
					end
				end
			end
		end
	end

	for bag = 0,4 do
		for slot = 1,GetContainerNumSlots(bag) do
			if GetContainerItemID(bag, slot) ~= nil then
				local _, itemCount = GetContainerItemInfo(bag, slot)
				local id = GetContainerItemID(bag, slot)
				if id then
					local _, _, _, _, _, _, _, _, _, _, vendorPrice = GetItemInfo(id)
					if vendorPrice ~= nil then
						gagne = gagne + (vendorPrice * itemCount)
					end
				end
			end
		end
	end
end

--[[
Function : PlayerEnteringWorld
Scope : local
Description : Quand le joueur se connecte : - crée les cw - check si l'addon est à jour - scan l'équipement du joueur - fixe les greens dots ?
Author : Raphaël Daumas
]]
local function PlayerEnteringWorld()
	GearHelper:BuildCWTable()
	if GearHelper.db.profile.addonEnabled == true then
		GearHelper:sendAskVersion()
		GearHelper:ScanCharacter()
		GearHelper:poseDot()
	end
end

-- GearHelper:Print("")
--[[
Function : ChatMsgAddon
Scope : local
Description : Envoi une demande de version ou sa réponse (pour vérifier si l'addon est up to date)
Input : string (le prefixe du message), string (le message envoyé par / reçu par l'addon), string (le nom du joueur qui à envoyé le msg (peut être soit même))
Author : Raphaël Daumas
]]
local function ChatMsgAddon(_, _, prefixMessage, message, _, sender)
	if prefixMessage == prefixAddon then
		local emetteur = ""
		if sender:find("-")then
			emetteur = sender:sub(0, (sender:find("-") - 1))
		else
			emetteur = sender
		end
		if GearHelper.db.profile.addonEnabled== true then
			if emetteur ~= GetUnitName("player") then
				local prefVersion = message:sub(0, (message:find(";") - 1))
				if prefVersion == "answerVersion" then
					local vVersion = message:sub(message:find(";")+1, #message)
					versionCible = vVersion
					GearHelper:receiveAnswer(vVersion, sender)
				end
				if prefVersion == "askVersion" then
					GearHelper:sendAnswerVersion()
				end
			end
		end
	end
end

--[[
Function : ItemPush
Scope : local
Description : Appelé quand un item est envoyé dans un sac. Equipe les items de ce sac qui seraient mieux que ceux équipés.
Input : number (le numéro du sac ddans lequel l'item à été envoyé)
Author : Raphaël Daumas
]]
local function ItemPush(_, _, bag)

	if GearHelper.db.profile.autoEquipLooted.actual then
		local theBag = bag
		if bag == 23 then
			theBag = 4
		elseif bag == 22 then
			theBag = 3
		elseif bag == 21 then
			theBag = 2
		elseif bag == 20 then
			theBag = 1
		end
		GearHelper:equipItem(theBag)
	end
end

--[[
Function : QuestComplete
Scope : local
Description : Accepte la récompensee de quête automatiquement si l'option est activée.
Author : Raphaël Daumas
]]
local function QuestComplete()

	GearHelper.GetQuestRewardCoroutine = coroutine.create(function() GearHelper:GetQuestReward() end)
	coroutine.resume(GearHelper.GetQuestRewardCoroutine)

end

--[[
Function : StartLootRoll
Scope : local
Description : Auto need ou auto greed un item en instance si l'option est activée
Input : number (index du jet (si 3 items tombent en même temps :  0, 1, 2))
Author : Raphaël Daumas
]]
local function StartLootRoll(_, _, number)

	GearHelper.AutoGreedAndNeedCoroutine = coroutine.create(function() GearHelper:AutoGreedAndNeed(number) end)
	coroutine.resume(GearHelper.AutoGreedAndNeedCoroutine)
	-- GearHelper:AutoGreedAndNeed(number)

end

--[[
Function : MerchantClosed
Scope : local
Description : Appelé quand la fenetre d'un marchant se ferme. calcul l'argent gagné pour l'afficher
Author : Raphaël Daumas
]]
local function MerchantClosed()
	if GearHelper.db.profile.sellGreyItems then
		local argentFin = 0
		for bag = 0,4 do
			for slot = 1,GetContainerNumSlots(bag) do
				if GetContainerItemID(bag, slot) ~= nil then
					local _, itemCount = GetContainerItemInfo(bag, slot)
					local id = GetContainerItemID(bag, slot)
					if id then
						local _, _, _, _, _, _, _, _, _, _, vendorPrice = GetItemInfo(id)
						argentFin = argentFin + (vendorPrice * itemCount)
					end
				end
			end
		end
		if(gagne - argentFin > 0) then
			print(GearHelper:ColorizeString(L["moneyEarned"], "Vert")..math.floor((gagne - argentFin)/10000)..L["dot"]..math.floor(((gagne - argentFin) % 10000) / 100)..L["gold"])
			gagne = 0
		end
	end
end

--[[
Function : BagUpdate
Scope : local
Description : ... Bonne question ... fired un peu n'importe quand ?
Author : Raphaël Daumas
]]
local function BagUpdate()
	-- Random check to verify that charInventory is initialized because BagUpdate is fired before PlayerEnteringWorld
	if GearHelper.charInventory["MainHand"] ~= "" and GearHelper.charInventory["MainHand"] ~= nil then
		GearHelper:ScanCharacter()
		GearHelper:poseDot()
	end
end

--[[
Function : ActiveTalentGroupChanged
Scope : local
Description : Appelé quand l'utilisateur change de spé. Utilisé pour équiper les bons items et changer le nom ded la spé dans les CW
Author : Raphaël Daumas
]]
local function ActiveTalentGroupChanged()
	if GearHelper.db.profile.autoEquipWhenSwitchSpe then
		-- waitSpeTime:Show()
		GearHelper:equipItem(0)
		GearHelper:equipItem(1)
		GearHelper:equipItem(2)
		GearHelper:equipItem(3)
		GearHelper:equipItem(4)
	end
	GearHelper.cwTable.args["NoxGroup"].name = "Noxxic "..(GetSpecialization() and select(2, GetSpecializationInfo(GetSpecialization())) or "None")
end

--[[
Function : ChatMsgChannel
Scope : local
Description : Invite le joueur qui envoit le bon msg dans un groupe
Input : string (le message reçu), string (le joueur qui l'a envoyé)
Author : Raphaël Daumas
]]
local function ChatMsgChannel(_, _, msg, sender)
	if GearHelper.db.profile.autoInvite and msg ~= nil then
		local playerIsNotMe = not string.find(sender, GetUnitName("player"))
		if msg:lower() == GearHelper.db.profile.inviteMessage:lower() and playerIsNotMe and GetNumGroupMembers() == 5 then
			ConvertToRaid()
			InviteUnit(sender)
		elseif msg:lower() == GearHelper.db.profile.inviteMessage:lower() and playerIsNotMe then
			InviteUnit(sender)
		end
	end
end

--[[
Function : ChatMsgWhisper
Scope : local
Description : Invite le joueur qui vous chuchote le bon msg dans un groupe
Input : string (le message reçu), string (le joueur qui l'a envoyé)
Author : Raphaël Daumas
]]
local function ChatMsgWhisper(_, _, msg, sender)
	if GearHelper.db.profile.autoInvite and msg ~= nil then
		local playerIsNotMe = not string.find(sender, GetUnitName("player"))
		if msg:lower() == GearHelper.db.profile.inviteMessage:lower() and playerIsNotMe and GetNumGroupMembers() == 5 then
			ConvertToRaid()
			InviteUnit(sender)
		elseif msg:lower() == GearHelper.db.profile.inviteMessage:lower() and playerIsNotMe then
			InviteUnit(sender)
		end
	end
end

--[[
Function : ChatMsgLoot
Scope : local
Description : Si quelqu'un loot quelque chose de mieux que ce qu'on a en instance, crée un lien pour lui demander facilement s'il en a besoin
Input : Trop d'infos envoyées par la fonction de Blizzard
Author : Raphaël Daumas
]]
local function ChatMsgLoot(_, _, message, sender, language, channelString, target, flags, unknown1, channelNumber, channelName, unknown2, counter)
	GearHelper:createLinkAskIfHeNeeds(0, message, sender, language, channelString, target, flags, unknown1, channelNumber, channelName, unknown2, counter)

	local used = false
	for i = 1, NUM_CHAT_WINDOWS do
		local _, _, _, _, _, _, _, _, _, uninteractable = GetChatWindowInfo(i);
		if(uninteractable) then
			SetChatWindowUninteractable(i, false)
			used = true
		end
	end
	if used then
		ReloadUI()
	end
end

--[[
Function : UnitInventoryChanged
Scope : local
Description : Évite d'équiper la meilleur arme si le joueur est en train ed pêcher
Input : string (le joueur qui à changé de stuff ?)
Author : Raphaël Daumas
]]
local function UnitInventoryChanged(_, _, joueur)
	if GearHelper.db.profile.addonEnabled and joueur == "player" then
		GearHelper:ScanCharacter()
		if GetInventoryItemLink("player", GetInventorySlotInfo("MainHandSlot")) ~= nil then
			local _, _, _, _, _, _, subclass  = GetItemInfo(GetInventoryItemLink("player",GetInventorySlotInfo("MainHandSlot")))
			if subclass == L["cannapeche"] then
				GearHelper.db.profile.autoEquipLooted.previous = GearHelper.db.profile.autoEquipLooted.actual
				GearHelper.db.profile.autoEquipLooted.actual = false
			else
				GearHelper.db.profile.autoEquipLooted.actual = GearHelper.db.profile.autoEquipLooted.previous
			end
		end
	end
end

--[[
Function : QuestTurnedIn
Scope : local
Description : Bonne question ? Equipe les bons items quand on accepte une quête ?
Author : Raphaël Daumas
]]
local function QuestTurnedIn()
	if GearHelper.db.profile.autoEquipLooted.actual then
		waitSpeTimer = time()
		waitSpeFrame:Show()
	end
end

--[[
Function : GetItemInfoReceived
Scope : local
Description : Appelé quand un item arrivee en cache
Input : number (id de l'item)
Author : Raphaël Daumas
]]
local function GetItemInfoReceived(_, _, item)
	if GearHelper.db.global.itemWaitList[item] then
		local slotName = GearHelper.db.global.itemWaitList[item]
		GearHelper.db.global.itemWaitList[item] = nil
		GearHelper.charInventory[string.sub(slotName, 1, -5)] = GearHelper:GetEquippedItemLink(GetInventorySlotInfo(slotName), slotName)
	end
	if item ~= nil then
		if GearHelper.idNilGetQuestReward ~= nil then
			if item == GearHelper.idNilGetQuestReward then
				GearHelper:Print(tostring(item).." était nil")
				coroutine.resume(GearHelper.GetQuestRewardCoroutine)
			end
		end
		if 	GearHelper.idNilAutoGreedAndNeed ~= nil then
			if item == 	GearHelper.idNilAutoGreedAndNeed then
				coroutine.resume(GearHelper.AutoGreedAndNeedCoroutine)
			end
		end
	end
end

-- local function QuestFiniched()
-- 	button.overlay = nil
-- end

GearHelper:RegisterEvent("ADDON_LOADED", AddonLoaded, ...)
GearHelper:RegisterEvent("MERCHANT_SHOW", OnMerchantShow)
GearHelper:RegisterEvent("PLAYER_ENTERING_WORLD", PlayerEnteringWorld)
GearHelper:RegisterEvent("CHAT_MSG_ADDON", ChatMsgAddon, ...)
GearHelper:RegisterEvent("ITEM_PUSH", ItemPush, ...)
GearHelper:RegisterEvent("QUEST_COMPLETE", QuestComplete)
GearHelper:RegisterEvent("START_LOOT_ROLL", StartLootRoll, ...)
GearHelper:RegisterEvent("MERCHANT_CLOSED", MerchantClosed)
GearHelper:RegisterEvent("BAG_UPDATE", BagUpdate)
GearHelper:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", ActiveTalentGroupChanged)
GearHelper:RegisterEvent("CHAT_MSG_CHANNEL", ChatMsgChannel, ...)
GearHelper:RegisterEvent("CHAT_MSG_WHISPER", ChatMsgWhisper, ...)
GearHelper:RegisterEvent("CHAT_MSG_LOOT", ChatMsgLoot, ...)
GearHelper:RegisterEvent("UNIT_INVENTORY_CHANGED", UnitInventoryChanged, ...)
GearHelper:RegisterEvent("QUEST_TURNED_IN", QuestTurnedIn)
GearHelper:RegisterEvent("GET_ITEM_INFO_RECEIVED", GetItemInfoReceived, ...)
-- GearHelper:RegisterEvent("QUEST_FINISHED", QuestFiniched, ...)