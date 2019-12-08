// Damn. Now I hate it more than JavaScript

include("quest/vgui/DQuestsPanel.lua")
include("quest/vgui/DQuestItem.lua")
include("quest/vgui/DQuestProgressBar.lua")

TTTQuests.MyQuests = {}
TTTQuests.MyQuestsData = {}
TTTQuests.MyQuestsDeadline = false

TTTQuests.GetPlayerQuests = function(len)
	local activeQuests = util.JSONToTable(net.ReadString())
	local questsDeadline = tonumber(net.ReadString()) || os.time()

	TTTQuests.MyQuests = activeQuests
	TTTQuests.MyQuestsDeadline = questsDeadline
end
net.Receive("GetPlayerQuests", TTTQuests.GetPlayerQuests)

surface.GetTextSizeWithFont = function(text, font)
	surface.SetFont(font)
	return surface.GetTextSize(text)
end

TTTQuests.GetItemNameByClass = function(className)
	for _, v in pairs(Pointshop2.GetRegisteredItems()) do
		if ( v.className == className ) then
			return v.PrintName
		end
	end
	return ""
end

// Here we will refre data about quests
TTTQuests.OnOpenMenu = function()
	net.Start("GetQuestsData")
	net.SendToServer()
end
hook.Add("PS2_OpenMenu", "TTTQuests_MenuHook", TTTQuests.OnOpenMenu)

TTTQuests.GetQuestsData = function(len)
	local data = util.JSONToTable(net.ReadString())
	TTTQuests.MyQuestsData = data

	local QuestsPanel
	for _, tab in pairs(Pointshop2.InventoryPanels2) do
		if ( tab.controlName == "DQuestsPanel" ) then
			QuestsPanel = tab.panel
		end
	end
	if QuestsPanel then
		for _, item in pairs(QuestsPanel.IconLayout:GetChildren()) do
			local quest = TTTQuests.Quests[item:GetQuestClass()]
			item.ProgressBar:SetMax(quest.TargetValue)
			item.ProgressBar:SetCurrent(data[item:GetQuestClass()])
		end
	end
end
net.Receive("GetQuestsData", TTTQuests.GetQuestsData)

TTTQuests.Log("Client module loaded!", COLOR_GREEN)