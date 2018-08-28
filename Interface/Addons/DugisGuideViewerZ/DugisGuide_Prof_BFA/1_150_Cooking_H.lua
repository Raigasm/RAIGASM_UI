local Guide = DugisGuideViewer:RegisterModule("DugisGuide_Prof_BFA_En_1_150_Cooking_H")
function Guide:Initialize()
 function Guide:Load()DugisGuideViewer:RegisterGuide("|cffffd200Battle for Azeroth Leveling|r", "BFA Cooking (1-150)", nil, "Horde", nil, "P", nil, function()
return [[

N Train Zandalari Cooking (npc:141549) |CO| |N|Speak to (npc:141549) in {Terrace of Crafters} and Train Zandalari Cooking (28.45,50.0)| |Z|1165| |P|1118 1| |NPC|141549|
N 98 (item:160711) |N|Collect 98 (item:160711), these are gathered from using fish caught in Zandalar and Kul Tiras or purchase them from the Auction House| |L|160711 98| |P|1118 50|
B 245 (item:160400) |N|Speak to (npc:142325) and buy 245 (item:160400) in {Terrace of Crafters} (28.45,50.0)| |Z|1165| |P|1118 50| |L|160400 245| |NPC|142325|
B 196 (item:160712) |N|Speak to (npc:142325) and buy 245 (item:160712) in {Terrace of Crafters} (28.45,50.0)| |Z|1165| |P|1118 50| |L|160712 196| |NPC|142325|
B 490 (item:160399) |N|Speak to (npc:142325) and buy 245 (item:160399) in {Terrace of Crafters} (28.45,50.0)| |Z|1165| |P|1118 50| |L|160399 490| |NPC|142325|

N 1-35 (spell:259442) |CO| |N|Cook 34 (spell:259442)<br/><b>340 (item:160399)<br/><b>170 (item:160400)<br/><b>64 (item:160711)<br/><b>136 (item:160712)<br/><br/>Save any (spell:259442) you craft.| |P|1118 35|
N 35-50 (spell:259443) |CO| |N|Learn the Rank 2 Recipe from (npc:141549) and cook 15 (spell:259443)<br/><b>150 (item:160399)<br/><b>75 (item:160400)<br/><b>30 (item:160711)<br/><b>60 (item:160712) (28.45,50.0)| |Z|1165| |P|1118 50|
N 600 (item:154898) |N|Collect (item:154898) by farming or purchase from the Auction House<br/><br/>Use (guide:"Tradeskill Farming") guide for farming| |Z|1165| |P|1118 110|
B 300 (item:160398) |N|Speak to (npc:142325) and buy 300 (item:160398) in {Terrace of Crafters} (28.45,50.0)| |Z|1165| |P|1118 110| |L|160398 300| |NPC|142325|
N 50-90 (spell:259414) |CO| |N|Learn recipe from (npc:141549) and cook 40 (spell:259414)<br/><b>400 (item:154898)<br/><b>200 (item:160398) (28.45,50.0)| |Z|1165| |P|1118 90|
N 90-110 (spell:259415) |CO| |N|Learn Rank 2 recipe from (npc:141549) and cook 20 (spell:259415)<br/><b>200 (item:154898)<br/><b>100 (item:160398) (28.45,50.0)| |Z|1165| |P|1118 110|
N 110-150 (spell:259416) |CO| |N|Rank 3 recipe can be obtain randomly from Cooking World quests and cook 40 (spell:259416)<br/><b>400 (item:154898)<br/><b>200 (item:160398) (28.45,50.0)| |Z|1165| |P|1118 110|

N Guide Complete |N|Congratulation! You reached level 150 with the Zandalari Cooking profession|
]]
end) end
 
 function Guide:Unload()
 end
end