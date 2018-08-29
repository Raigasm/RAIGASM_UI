
ParrotDB = {
	["namespaces"] = {
		["CombatEvents"] = {
			["profiles"] = {
				["Default"] = {
					["dbver"] = 5,
				},
				["Rai"] = {
					["hideUnitNames"] = true,
					["shortenAmount"] = true,
					["throttles"] = {
						["Skill damage"] = 1,
						["Melee damage"] = 1,
					},
					["hideSkillNames"] = true,
					["Notification"] = {
						["Enemy debuff gains"] = {
							["disabled"] = true,
						},
						["Power gain"] = {
							["disabled"] = true,
						},
						["Pet debuff gains"] = {
							["disabled"] = true,
						},
						["Item buff fades"] = {
							["disabled"] = true,
						},
						["Item buff gains"] = {
							["disabled"] = true,
						},
						["Pet debuff fades"] = {
							["disabled"] = true,
						},
						["Power loss"] = {
							["disabled"] = true,
						},
						["Buff gains"] = {
							["disabled"] = true,
						},
						["Debuff fades"] = {
							["disabled"] = true,
						},
						["Pet buff fades"] = {
							["disabled"] = true,
						},
						["Pet buff gains"] = {
							["disabled"] = true,
						},
						["Target buff stack gains"] = {
							["disabled"] = true,
						},
						["Skill cooldown finish"] = {
							["tag"] = "[ready!]",
						},
						["Enemy buff fades"] = {
							["disabled"] = true,
						},
						["Loot money"] = {
							["disabled"] = false,
						},
						["Buff fades"] = {
							["disabled"] = true,
						},
						["Enemy buff gains"] = {
							["disabled"] = true,
						},
						["Target buff gains"] = {
							["disabled"] = true,
						},
						["Enemy debuff fades"] = {
							["disabled"] = true,
						},
						["Debuff gains"] = {
							["disabled"] = true,
						},
						["Buff stack gains"] = {
							["disabled"] = true,
						},
						["Loot items"] = {
							["disabled"] = false,
						},
						["Debuff stack gains"] = {
							["disabled"] = true,
						},
					},
					["hideFullOverheals"] = 3,
					["modifier"] = {
						["resist"] = {
							["tag"] = " (-[Amount])",
						},
						["absorb"] = {
							["tag"] = " (-[Amount])",
						},
						["crit"] = {
							["tag"] = "[Text]!",
						},
						["block"] = {
							["tag"] = " (-[Amount])",
						},
					},
					["dbver"] = 5,
					["Outgoing"] = {
						["Skill damage"] = {
							["tag"] = "[Amount]",
						},
						["Skill DoTs"] = {
							["tag"] = "[Amount]",
						},
					},
					["sthrottles"] = {
						[""] = {
						},
					},
					["filters"] = {
						["Power gain"] = 50,
					},
				},
			},
		},
		["LibDualSpec-1.0"] = {
		},
		["Suppressions"] = {
		},
		["Cooldowns"] = {
		},
		["ScrollAreas"] = {
			["profiles"] = {
				["Default"] = {
					["areas"] = {
						["Notification"] = {
							["stickyDirection"] = "UP;CENTER",
							["direction"] = "UP;CENTER",
							["yOffset"] = 175,
							["iconSide"] = "LEFT",
							["xOffset"] = 0,
							["size"] = 150,
							["animationStyle"] = "Straight",
							["stickyAnimationStyle"] = "Pow",
						},
						["Outgoing"] = {
							["stickyDirection"] = "DOWN;LEFT",
							["direction"] = "DOWN;RIGHT",
							["yOffset"] = -30,
							["iconSide"] = "LEFT",
							["xOffset"] = 60,
							["size"] = 260,
							["animationStyle"] = "Parabola",
							["stickyAnimationStyle"] = "Pow",
						},
						["Incoming"] = {
							["stickyDirection"] = "DOWN;RIGHT",
							["direction"] = "DOWN;LEFT",
							["yOffset"] = -30,
							["iconSide"] = "RIGHT",
							["xOffset"] = -60,
							["size"] = 260,
							["animationStyle"] = "Parabola",
							["stickyAnimationStyle"] = "Pow",
						},
					},
					["dbver"] = 2,
				},
				["Rai"] = {
					["areas"] = {
						["Outgoing"] = {
							["stickyDirection"] = "UP;LEFT",
							["direction"] = "UP;RIGHT",
							["yOffset"] = -61.7407836914063,
							["iconSide"] = "RIGHT",
							["xOffset"] = 118.191528320313,
							["size"] = 260,
							["animationStyle"] = "Parabola",
							["stickyAnimationStyle"] = "Pow",
						},
						["Notification"] = {
							["stickyDirection"] = "UP;CENTER",
							["direction"] = "UP;CENTER",
							["yOffset"] = 137.086669921875,
							["iconSide"] = "LEFT",
							["xOffset"] = -7.9354248046875,
							["size"] = 150,
							["animationStyle"] = "Straight",
							["stickyAnimationStyle"] = "Pow",
						},
						["Incoming"] = {
							["stickyDirection"] = "UP;RIGHT",
							["direction"] = "DOWN;LEFT",
							["yOffset"] = -60.8590087890625,
							["iconSide"] = "LEFT",
							["xOffset"] = -181.674194335938,
							["size"] = 260,
							["animationStyle"] = "Parabola",
							["stickyAnimationStyle"] = "Pow",
						},
					},
					["dbver"] = 2,
				},
			},
		},
		["Display"] = {
			["profiles"] = {
				["Rai"] = {
					["stickyFont"] = "Arial Narrow",
					["stickyFontOutline"] = "NONE",
					["stickyFontSize"] = 18,
					["fontSize"] = 14,
					["fontOutline"] = "NONE",
					["font"] = "Arial Narrow",
				},
			},
		},
		["Triggers"] = {
			["profiles"] = {
				["Default"] = {
					["dbver2"] = 1,
				},
				["Rai"] = {
					["dbver2"] = 1,
				},
			},
		},
	},
	["profileKeys"] = {
		["Raigasm - Draenor"] = "Default",
		["Raimondo - Draenor"] = "Default",
		["Ryugasm - Draenor"] = "Rai",
		["Norfweezy - Draenor"] = "Rai",
		["Badmanting - Draenor"] = "Rai",
	},
	["profiles"] = {
		["Default"] = {
		},
		["Rai"] = {
			["gameHealing"] = true,
			["gamePetDamage"] = true,
			["gameDamage"] = true,
		},
	},
}
