local Guide = DugisGuideViewer:RegisterModule("DugisGuide_Prof_Alliance_En_Cooking_WoD")
function Guide:Initialize()
	function Guide:Load()DugisGuideViewer:RegisterGuide("|cffffd200Warlords Leveling|r", "Warlords Cooking 1-100", nil, "Alliance", nil, "P", nil, function()
return [[

N Read First |N|You must have a character level 100+ and Warlords of Draenor is required. <br/><br/>Leveling is available in Draenor from 1-100. <br/><br/>Tick this step.|
N Cooking Recipes |N|Cooking recipes are learned from creating consumable items, so if a particular recipe is not avaialble, continue cooking Draenor recipes until you learn it. Tick this step.|

N (item:111387) |N|Kill any NPCs in Draenor until you find (item:111387)| |L|111387| |P|342 1|
U (item:111387) |N|Train Draenor Cooking| |U|111387| |P|342 1|

N 1-20 (item:111456) |CO| |N|Cook 30 (item:111456) <br/>Created with; <br/><b>75 (item:109137)| |P|342 25| --Crescent Saberfish Flesh
N 20-50 (item:111439) |CO| |N|Created with; <br/><b>10 (item:109142)| |P|342 50| --Sea Scorpion Segment
N 50-75 (item:111450) |CO| |N|Created with; <br/><b>5 (item:109132) <br/><b>5 (item:109140) <br/><b>1 (item:109124)| |P|342 75| --Pan-Seared Talbuk, Sturgeon Stew, Frostweed
N 75-100 (item:111458) |CO| |N|Created with; <br/><b>10 (item:109142) <br/><b>10 (item:109143) <br/><b>10 (item:109140) <br/><b>10 (item:109139) <br/><b>10 (item:109141) <br/><b>10 (item:109138)| |P|342 100| --Sea Scorpion Segement, Abyssal Gulper Eel Flesh, Blind Lake Sturgeon Flesh, Fat Sleeper Flesh, Fire Ammonite Tentacle, Jawless Skulker Flesh

N Guide Complete

]]
end, {description = [[This guide covers how to level up the Draenor Cooking profession from 1-100]]})	
	end
	function Guide:Unload()
	end
end