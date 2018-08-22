WhoTaunted = LibStub("AceAddon-3.0"):NewAddon("WhoTaunted", "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0")
local AceConfig = LibStub("AceConfigDialog-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("WhoTaunted");

local PlayerName, PlayerRealm = UnitName("player");
local BgDisable = false;
local DisableInPvPZone = false;
local TauntData = {};
local RecentTaunts = {};
local TauntsList = {
	SingleTarget = {
		--Warrior
		355, --Taunt

		--Death Knight
		51399, --Death Grip for Blood (49576 is now just the pull effect)
		56222, --Dark Command

		--Paladin
		62124, --Hand of Reckoning

		--Druid
		6795, --Growl

		--Hunter
		20736, --Distracting Shot

		--Monk
		115546, --Provoke

		--Demon Hunter
		185245, --Torment
	},
	AOE = {
		--Paladin
		204079, --Final Stand
	},
};
local TauntTypes = {
	Normal = "Normal",
	AOE = "AOE",
	Failed = "Failed",
};
local PvPZoneIDs = {
	588, --Ashran
	589, --Ashran
	123, --Wintergrasp
	244, --Tol Barad
	245, --Tol Barad Peninsula
};

function WhoTaunted:OnInitialize()
	WhoTaunted:RegisterEvent("PLAYER_ENTERING_WORLD", "EnteringWorldOnEvent")
	WhoTaunted:RegisterEvent("PLAYER_REGEN_ENABLED", "RegenEnabledOnEvent")
	WhoTaunted:RegisterEvent("ZONE_CHANGED_NEW_AREA", "ZoneChangedOnEvent")
	WhoTaunted:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "CombatLog")
	WhoTaunted:RegisterEvent("UPDATE_CHAT_WINDOWS", "UpdateChatWindowsOnEvent")

	WhoTaunted:RegisterChatCommand("whotaunted", "ChatCommand")
	WhoTaunted:RegisterChatCommand("wtaunted", "ChatCommand")
	WhoTaunted:RegisterChatCommand("wtaunt", "ChatCommand")

	WhoTaunted.db = LibStub("AceDB-3.0"):New("WhoTauntedDB", WhoTaunted.defaults, "profile");
	LibStub("AceConfig-3.0"):RegisterOptionsTable("WhoTaunted", WhoTaunted.options)
	AceConfig:AddToBlizOptions("WhoTaunted", "Who Taunted?");
end

function WhoTaunted:OnEnable()
	if (type(tonumber(WhoTaunted.db.profile.AnounceTauntsOutput)) == "number") or (type(tonumber(WhoTaunted.db.profile.AnounceAOETauntsOutput)) == "number") or (type(tonumber(WhoTaunted.db.profile.AnounceFailsOutput)) == "number") then
		WhoTaunted.db.profile.AnounceTauntsOutput = WhoTaunted.OutputTypes.Self;
		WhoTaunted.db.profile.AnounceAOETauntsOutput = WhoTaunted.OutputTypes.Self;
		WhoTaunted.db.profile.AnounceFailsOutput = WhoTaunted.OutputTypes.Self;
	end
end

function WhoTaunted:OnDisable()
	WhoTaunted:UnregisterAllEvents();
	WhoTaunted:ClearRecentTaunts();
end

function WhoTaunted:UpdateChatWindowsOnEvent(event, ...)
	WhoTaunted:UpdateChatWindows();
end
function WhoTaunted:CombatLog(self, event, ...)
	local timestamp, subEvent, hideCaster, srcGUID, srcName, srcFlags, srcFlags2, dstGUID, dstName, dstFlags, dstFlags2, spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSpellSchool, auraType = CombatLogGetCurrentEventInfo();
	WhoTaunted:DisplayTaunt(subEvent, srcName, spellID, dstName, extraSpellID, GetServerTime());
end

function WhoTaunted:EnteringWorldOnEvent(event, ...)
	local inInstance, instanceType = IsInInstance();
	if (inInstance == true) and (instanceType == "pvp") and (WhoTaunted.db.profile.DisableInBG == true) then
		BgDisable = true;
	else
		BgDisable = false;
	end
	WhoTaunted:ClearRecentTaunts();
end

function WhoTaunted:RegenEnabledOnEvent(event, ...)
	WhoTaunted:ClearRecentTaunts();
end

function WhoTaunted:ZoneChangedOnEvent(event, ...)
	local mapID = C_Map.GetBestMapForUnit("player");
	if (WhoTaunted:IsPvPZone(mapID) == true) and (WhoTaunted.db.profile.DisableInPvPZone == true) then
		DisableInPvPZone = true;
	else
		DisableInPvPZone = false;
	end
end

function WhoTaunted:ChatCommand()
	InterfaceOptionsFrame_OpenToCategory("Who Taunted?");
end

function WhoTaunted:DisplayTaunt(Event, Name, ID, Target, FailType, Time)
	if (Event) and (Name) and (ID) and (Time) and (WhoTaunted:IsRecentTaunt(Name, ID, Time) == false) then
		if (WhoTaunted.db.profile.Disabled == false) and (BgDisable == false) and (DisableInPvPZone == false) and (UnitIsPlayer(Name)) and ((UnitInParty("player")) or (UnitInRaid("player"))) and ((UnitInParty(Name)) or (UnitInRaid(Name))) then
			local OutputMessage = nil;
			local IsTaunt, TauntType;
			local OutputType;

			--Ignore Death Grip Pull Effect for non-Blood Specs
			if (ID == 49576) then
				return;
			end

			if (Event == "SPELL_AURA_APPLIED") then
				IsTaunt, TauntType = WhoTaunted:IsTaunt(ID);
				if (not Target) or (not IsTaunt) or ((TauntType == TauntTypes.Normal) and (WhoTaunted.db.profile.AnounceTaunts == false)) or ((TauntType == TauntTypes.AOE) and (WhoTaunted.db.profile.AnounceAOETaunts == false)) or ((WhoTaunted.db.profile.HideOwnTaunts == true) and (Name == PlayerName)) then
					return;
				end
				OutputType = WhoTaunted:GetOutputType(TauntType);
				local Spell = GetSpellLink(ID);
				if (not Spell) then
					Spell = GetSpellInfo(ID);
				end

				if (TauntType == TauntTypes.Normal) then
					OutputMessage = WhoTaunted:OutputMessageNormal(Name, Target, Spell, OutputType);
				elseif (TauntType == TauntTypes.AOE) then
					OutputMessage = WhoTaunted:OutputMessageAOE(Name, Target, Spell, ID, OutputType);
				end
			elseif (Event == "SPELL_CAST_SUCCESS") then
				IsTaunt, TauntType = WhoTaunted:IsTaunt(ID);
				if (not Target) or (not IsTaunt) or (TauntType == TauntTypes.Normal) or ((TauntType == TauntTypes.AOE) and (WhoTaunted.db.profile.AnounceAOETaunts == false)) or ((WhoTaunted.db.profile.HideOwnTaunts == true) and (Name == PlayerName)) then
					return;
				end
				OutputType = WhoTaunted:GetOutputType(TauntType);
				local Spell = GetSpellLink(ID);
				if (not Spell) then
					Spell = GetSpellInfo(ID);
				end

				if (TauntType == TauntTypes.Normal) then
					OutputMessage = WhoTaunted:OutputMessageNormal(Name, Target, Spell, OutputType);
				elseif (TauntType == TauntTypes.AOE) then
					OutputMessage = WhoTaunted:OutputMessageAOE(Name, Target, Spell, ID, OutputType);
				end
			elseif (Event == "SPELL_MISSED") then
				IsTaunt, TauntType = WhoTaunted:IsTaunt(ID);
				if (not Target) or (not FailType) or (not IsTaunt) or ((TauntType == TauntTypes.Normal) and (WhoTaunted.db.profile.AnounceTaunts == false)) or ((TauntType == TauntTypes.AOE) and (WhoTaunted.db.profile.AnounceAOETaunts == false)) or ((WhoTaunted.db.profile.HideOwnTaunts == true) and (Name == PlayerName)) then
					return;
				end
				TauntType = TauntTypes.Failed;
				OutputType = WhoTaunted:GetOutputType(TauntType);
				local Spell = GetSpellLink(ID);
				if (not Spell) then
					Spell = GetSpellInfo(ID);
				end
				OutputMessage = WhoTaunted:OutputMessageFailed(Name, Target, Spell, ID, OutputType, FailType);
			else
				return;
			end
			if (OutputMessage) and (TauntType) then
				if (OutputType ~= WhoTaunted.OutputTypes.Self) then
					if (WhoTaunted.db.profile.Prefix == true) then
						OutputMessage = L["<WhoTaunted>"].." "..OutputMessage;
					end
				end
				WhoTaunted:AddRecentTaunt(Name, ID, Time);
				WhoTaunted:OutPut(OutputMessage:trim(), OutputType);
			end
		end
	end
end

function WhoTaunted:IsTaunt(SpellID)
	local IsTaunt, TauntType = false, "";
	for k, v in pairs(TauntsList.SingleTarget) do
		if (GetSpellInfo(v) == GetSpellInfo(SpellID)) then
			IsTaunt, TauntType = true, TauntTypes.Normal;
			break;
		end
	end
	for k, v in pairs(TauntsList.AOE) do
		if (GetSpellInfo(v) == GetSpellInfo(SpellID)) then
			IsTaunt, TauntType = true, TauntTypes.AOE;
			break;
		end
	end
	return IsTaunt, TauntType;
end

function WhoTaunted:IsPvPZone(MapID)
	local IsPvPZone = false;
	if (MapID) and (type(MapID) == "number") then
		for k, v in pairs(PvPZoneIDs) do
			if (MapID == v) then
				IsPvPZone = true;
				break;
			end
		end
	end
	return IsPvPZone;
end

function WhoTaunted:AddRecentTaunt(TauntName, TauntID, TauntTime)
	if (TauntName) and (TauntID) and (TauntTime) and (type(TauntTime) == "number") then
		table.insert(RecentTaunts,{
			Name = TauntName,
			ID = TauntID,
			TimeStamp = TauntTime,
		});
	end
end

function WhoTaunted:IsRecentTaunt(TauntName, TauntID, TauntTime)
	local IsRecentTaunt = false;

	if (TauntName) and (TauntID) and (TauntTime) and (type(TauntTime) == "number") then
		for k, v in pairs(RecentTaunts) do
			if (RecentTaunts[k].Name == TauntName) and (GetSpellInfo(RecentTaunts[k].ID) == GetSpellInfo(TauntID)) and (RecentTaunts[k].TimeStamp == TauntTime) then
				IsRecentTaunt = true;
				break;
			end
		end
	end

	return IsRecentTaunt;
end

function WhoTaunted:ClearRecentTaunts()
	RecentTaunts = table.wipe(RecentTaunts);
end

function WhoTaunted:OutputMessageNormal(Name, Target, Spell, OutputType)
	local OutputMessage = nil;

	OutputMessage = "lc1"..Name.."lr1 "..L["taunted"].." "..Target;
	if (WhoTaunted.db.profile.DisplayAbility == true) then
		OutputMessage = OutputMessage.." "..L["using"].." "..Spell..".";
	else
		OutputMessage = OutputMessage..".";
	end

	if (OutputType == WhoTaunted.OutputTypes.Self) then
		OutputMessage = OutputMessage:gsub("lc1", "|c"..WhoTaunted:GetClassColor(Name)):gsub("lr1", "|r");
	else
		OutputMessage = OutputMessage:gsub("lc1", ""):gsub("lr1", "");
	end

	return OutputMessage;
end

function WhoTaunted:OutputMessageAOE(Name, Target, Spell, ID, OutputType)
	local OutputMessage = nil;

	OutputMessage = "lc1"..Name.."lr1 "..L["AOE"].." "..L["taunted"];
	if (WhoTaunted.db.profile.DisplayAbility == true) then
		OutputMessage = OutputMessage.." "..L["using"].." "..Spell..".";
	else
		OutputMessage = OutputMessage..".";
	end

	if (OutputType == WhoTaunted.OutputTypes.Self) then
		OutputMessage = OutputMessage:gsub("lc1", "|c"..WhoTaunted:GetClassColor(Name)):gsub("lr1", "|r"):gsub("lc2", "|c"..WhoTaunted:GetClassColor(Target)):gsub("lr2", "|r");
	else
		OutputMessage = OutputMessage:gsub("lc1", ""):gsub("lr1", ""):gsub("lc2", ""):gsub("lr2", "");
	end

	return OutputMessage;
end

function WhoTaunted:OutputMessageFailed(Name, Target, Spell, ID, OutputType, FailType)
	local OutputMessage = nil;

	OutputMessage = "lc1"..Name..L["'s"].."lr1 "..L["taunt"];
	if (WhoTaunted.db.profile.DisplayAbility == true) then
		OutputMessage = OutputMessage.." "..Spell;
	end
	OutputMessage = OutputMessage.." "..L["against"].." "..Target.." lc2"..string.upper(L["Failed:"].." "..FailType).."lr2!";

	if (OutputType == WhoTaunted.OutputTypes.Self) then
		OutputMessage = OutputMessage:gsub("lc1", "|c"..WhoTaunted:GetClassColor(Name)):gsub("lr1", "|r"):gsub("lc2", "|c00FF0000"):gsub("lr2", "|r");
	else
		OutputMessage = OutputMessage:gsub("lc1", ""):gsub("lr1", ""):gsub("lc2", ""):gsub("lr2", "");
	end

	return OutputMessage;
end

function WhoTaunted:OutPut(msg, output, dest)
	if (not output) or (output == "") then
		output = WhoTaunted.OutputTypes.Self;
	end
	if (msg) then
		if (string.lower(output) == "raid") then
			if (IsInRaid()) and (GetNumGroupMembers() >= 1) then
				ChatThrottleLib:SendChatMessage("NORMAL", "WhoTaunted", tostring(msg), "RAID");
			end
		elseif (string.lower(output) == "raidwarning") or (string.lower(output) == "rw") then
			if (IsInRaid()) and (GetNumGroupMembers() >= 1) then
				local isLeader = UnitIsGroupLeader("player");
				local isAssistant = UnitIsGroupAssistant("player");
				if ((isLeader) and (isLeader == true)) or ((isAssistant) and (isAssistant == true)) then
					ChatThrottleLib:SendChatMessage("NORMAL", "WhoTaunted", tostring(msg), "RAID_WARNING");
				else
					ChatThrottleLib:SendChatMessage("NORMAL", "WhoTaunted", tostring(msg), "RAID");
				end
			end
		elseif (string.lower(output) == "party") then
			local isInParty = UnitInParty("player");
			if (isInParty) and (isInParty == true) and (GetNumSubgroupMembers() >= 1) then
				ChatThrottleLib:SendChatMessage("NORMAL", "WhoTaunted", tostring(msg), "PARTY");
			end
		elseif (string.lower(output) == "say") then
			ChatThrottleLib:SendChatMessage("NORMAL", "WhoTaunted", tostring(msg), "SAY");
		elseif (string.lower(output) == "yell") then
			ChatThrottleLib:SendChatMessage("NORMAL", "WhoTaunted", tostring(msg), "YELL");
		elseif (string.lower(output) == "whisper") and (dest) then
			ChatThrottleLib:SendChatMessage("NORMAL", "WhoTaunted", tostring(msg), "WHISPER", nil, dest);
		elseif (string.lower(output) == "guild") then
			ChatThrottleLib:SendChatMessage("NORMAL", "WhoTaunted", tostring(msg), "GUILD");
		elseif (string.lower(output) == "officer") then
			ChatThrottleLib:SendChatMessage("NORMAL", "WhoTaunted", tostring(msg), "OFFICER");
		elseif (string.lower(output) == "channel") and (dest) and (WhoTaunted:IsChatChannel(dest) == true) then
			local id, name = GetChannelName(dest);
			if (id > 0) and (name ~= nil) then
				ChatThrottleLib:SendChatMessage("NORMAL", "WhoTaunted", tostring(msg), "CHANNEL", nil, id);
			end
		elseif (string.lower(output) == "print") or (string.lower(output) == "self") then
			if (WhoTaunted:IsChatWindow(WhoTaunted.db.profile.ChatWindow) == true) then
				WhoTaunted:PrintToChatWindow(tostring(msg), WhoTaunted.db.profile.ChatWindow)
			else
				WhoTaunted.db.profile.ChatWindow = "";
				WhoTaunted:Print(tostring(msg));
			end
		end
	end
end

function WhoTaunted:GetOutputType(TauntType)
	local OutputType = WhoTaunted.OutputTypes.Self;
	if (TauntType == TauntTypes.Normal) then
		OutputType = WhoTaunted.db.profile.AnounceTauntsOutput;
	elseif (TauntType == TauntTypes.AOE) then
		OutputType = WhoTaunted.db.profile.AnounceAOETauntsOutput;
	elseif (TauntType == TauntTypes.Failed) then
		OutputType = WhoTaunted.db.profile.AnounceFailsOutput;
	end
	return OutputType;
end

function WhoTaunted:IsChatChannel(ChannelName)
	local IsChatChannel = false;
	for i = 1, NUM_CHAT_WINDOWS, 1 do
		for k, v in pairs({ GetChatWindowChannels(i) }) do
			if (string.lower(tostring(v)) == string.lower(tostring(ChannelName))) then
				IsChatChannel = true;
				break;
			end
		end
		if (IsChatChannel == true) then
			break;
		end
	end
	return IsChatChannel;
end

function WhoTaunted:UpdateChatWindows()
	WhoTaunted.options.args.General.args.ChatWindow.values = WhoTaunted:GetChatWindows();
end

function WhoTaunted:GetChatWindows()
	local ChatWindows = {};
	for i = 1, NUM_CHAT_WINDOWS, 1 do
		local name, fontSize, r, g, b, alpha, shown, locked, docked, uninteractable = GetChatWindowInfo(i);
		if (name) and (tostring(name) ~= COMBAT_LOG) and (name:trim() ~= "") then
			ChatWindows[tostring(name)] = tostring(name);
		end
	end
	return ChatWindows;
end

function WhoTaunted:IsChatWindow(ChatWindow)
	local IsChatWindow = false;
	for i = 1, NUM_CHAT_WINDOWS, 1 do
		local name, fontSize, r, g, b, alpha, shown, locked, docked, uninteractable = GetChatWindowInfo(i);
		if (name) and (name:trim() ~= "") and (tostring(name) == tostring(ChatWindow)) then
			IsChatWindow = true;
			break;
		end
	end
	return IsChatWindow;
end

function WhoTaunted:PrintToChatWindow(message, ChatWindow)
	for i = 1, NUM_CHAT_WINDOWS, 1 do
		local name, fontSize, r, g, b, alpha, shown, locked, docked, uninteractable = GetChatWindowInfo(i);
		if (name) and (name:trim() ~= "") and (tostring(name) == tostring(ChatWindow)) then
			WhoTaunted:Print(_G["ChatFrame"..i], tostring(message));
		end
	end
end

function WhoTaunted:GetClassColor(Unit)
	local localizedclass = nil;
	local ClassColor = nil;
	if (Unit) then
		localizedclass = UnitClass(Unit);
		if (localizedclass) then
			if (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_MALE["DEATHKNIGHT"])) or (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_FEMALE["DEATHKNIGHT"])) then
				ClassColor = "00C41F3B";
			elseif (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_MALE["DRUID"])) or (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_FEMALE["DRUID"])) then
				ClassColor = "00FF7D0A";
			elseif (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_MALE["HUNTER"])) or (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_FEMALE["HUNTER"])) then
				ClassColor = "00ABD473";
			elseif (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_MALE["MAGE"])) or (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_FEMALE["MAGE"])) then
				ClassColor = "0069CCF0";
			elseif (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_MALE["MONK"])) or (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_FEMALE["MONK"])) then
				ClassColor = "0000FF96";
			elseif (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_MALE["PALADIN"])) or (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_FEMALE["PALADIN"])) then
				ClassColor = "00F58CBA";
			elseif (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_MALE["PRIEST"])) or (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_FEMALE["PRIEST"])) then
				ClassColor = "00FFFFFF";
			elseif (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_MALE["ROGUE"])) or (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_FEMALE["ROGUE"])) then
				ClassColor = "00FFF569";
				elseif (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_MALE["DEMONHUNTER"])) or (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_FEMALE["DEMONHUNTER"])) then
				ClassColor = "00A330C9";
			elseif (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_MALE["SHAMAN"])) or (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_FEMALE["SHAMAN"])) then
				ClassColor = "002459FF";
			elseif (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_MALE["WARLOCK"])) or (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_FEMALE["WARLOCK"])) then
				ClassColor = "009482CA";
			elseif (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_MALE["WARRIOR"])) or (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_FEMALE["WARRIOR"])) then
				ClassColor = "00C79C6E";
			end
		end
	end

	if (ClassColor == nil) then
		ClassColor = "00FFFFFF";
	end

	return ClassColor;
end
