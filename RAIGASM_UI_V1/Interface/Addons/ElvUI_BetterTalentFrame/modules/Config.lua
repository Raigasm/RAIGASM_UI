--[[
    ElvUI_BetterTalentFrame
    Copyright (C) Arwic-Frostmourne, All rights reserved.
]]--

local E, L, V, P, G = unpack(ElvUI) -- Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C = E:NewModule("BetterTalentsFrame_Config", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0")
local EP = LibStub("LibElvUIPlugin-1.0")
local addonName, addonTable = ...

-- defaults
P["BetterTalentsFrame"] = {
	["DefaultToTalentsTab"] = true,
	["AutoHidePvPTalents"] = false,
}

function C:InsertOptions()
	E.Options.args.BetterTalentsFrame = {
		order = 100,
		type = "group",
		name = "|cffff8000BetterTalentsFrame|r",
		args = {
			DefaultToTalentsTab = {
				order = 1,
				type = "toggle",
				name = "Default to Talents Tab",
				desc = "Defaults to the talents tab of the talent frame on login. By default WoW shows you the specialization tab.",
				get = function(info)
					return E.db.BetterTalentsFrame.DefaultToTalentsTab
				end,
				set = function(info, value)
					E.db.BetterTalentsFrame.DefaultToTalentsTab = value
				end,
			},
			AutoHidePvPTalents = {
				order = 2,
				type = "toggle",
				name = "Auto Hide PvP Talents",
				desc = "Closes the PvP talents flyout on login. PvP talents and warmode flag are still accessible by manually opening the PvP talents flyout.",
				get = function(info)
					return E.db.BetterTalentsFrame.AutoHidePvPTalents
				end,
				set = function(info, value)
					E.db.BetterTalentsFrame.AutoHidePvPTalents = value
				end,
			},
		},
	}
end

function C:Initialize()
	EP:RegisterPlugin(addonName, C.InsertOptions)
end

E:RegisterModule(C:GetName())
