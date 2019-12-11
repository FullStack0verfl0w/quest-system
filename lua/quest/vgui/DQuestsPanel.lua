local PANEL = {}

function PANEL:Init( )
	self:DockPadding( 10, 10, 10, 10 )
	self:SetSkin( Pointshop2.Config.DermaSkin )

	self.Scroll = vgui.Create("DScrollPanel", self)
	self.Scroll:Dock(FILL)

	self.IconLayout = vgui.Create("DIconLayout", self.Scroll)
	self.IconLayout:Dock(FILL)
	self.IconLayout:SetSpaceX(5)
	self.IconLayout:SetSpaceY(5)

	net.Start("GetPlayerQuests")
	net.SendToServer()
	net.Start("GetQuestsData")
	net.SendToServer()

	timer.Create("DQuestsPanel_Timer", .1, 0, function()
		if ( table.Count(TTTQuests.MyQuests) > 0 && table.Count(TTTQuests.MyQuestsData) > 0 ) then
			for _, class in pairs(TTTQuests.MyQuests) do
				local Quest = TTTQuests.Quests[class]

				if Quest then
					local item = vgui.Create("DQuestItem", self.Scroll, class)
					local typesIcons = {
						[TTTQuests.RewardType.StandardPoints] = "pointshop2/dollar103.png",
						[TTTQuests.RewardType.PremiumPoints] = "materials/pointshop2/donation.png",
						[TTTQuests.RewardType.Item] = "ps-quests/icon-item.png",
						[TTTQuests.RewardType.Experience] = "materials/pointshop2/settings12.png",
						[TTTQuests.RewardType.Random] = "ps-quests/icon-rand.png",
					}
					
					item:SetQuestClass(class)
					item:SetSize(260, 190)
					item:SetHeaderText(Quest.Name)
					item:SetDescText(string.format(Quest.Description, Quest.TargetValue))

					item.RewardType:SetImage(typesIcons[Quest.RewardType] || "ps-quests/icon-rand.png")
					item.RewardType:SetPos(item:GetWide() / 2 - 16, 0)

					if ( Quest.RewardType == TTTQuests.RewardType.Random ) then
						item.RewardTypePanel:SetTooltip("You'll receive some random stuff")
					elseif ( Quest.RewardType == TTTQuests.RewardType.Item ) then
						item.RewardTypePanel:SetTooltip(string.format("You'll receive %s", TTTQuests.GetItemNameByClass(Quest.Reward)))
					elseif ( Quest.RewardType == TTTQuests.RewardType.StandardPoints ) then
						item.RewardTypePanel:SetTooltip(string.format("You'll receive %s Standard Points", Quest.Reward))
					elseif ( Quest.RewardType == TTTQuests.RewardType.PremiumPoints ) then
						item.RewardTypePanel:SetTooltip(string.format("You'll receive %s Donator Points", Quest.Reward))
					elseif ( Quest.RewardType == TTTQuests.RewardType.Experience ) then
						item.RewardTypePanel:SetTooltip(string.format("You'll receive %s Experience", Quest.Reward))
					end

					item.ProgressBar:SetMax(Quest.TargetValue)
					item.ProgressBar:SetCurrent(TTTQuests.MyQuestsData[class])
					item.ProgressBar.Finished = table.HasValue(TTTQuests.MyQuestsFinished, class)
					item.ProgressBar:Dock(BOTTOM)

					item.ProgressBar.ProgressBar:SetSize(item:GetWide() - 24 * 2, 40)
					item.ProgressBar.ProgressBar:SetPos(item:GetWide() / 2 - item.ProgressBar.ProgressBar:GetWide() / 2, 0 )

					self.IconLayout:Add(item)
				else
					local errorText = vgui.Create("DLabel", self)
					errorText:SetText("Something went wrong. Try to reconnect to the server!")
					errorText:SetFont("PS2_LargeHeading")
					errorText:SetTextColor(COLOR_WHITE)
					errorText:Dock(FILL)
					errorText:SetContentAlignment(8)
					break
				end
			end

			if ( TTTQuests.MyQuestsDeadline ) then
				self.QuestDeadline = vgui.Create("DLabel", self)
				self.QuestDeadline:SetText(string.format("Quests will reset in %s", os.date("%H:%M:%S - %d/%m/%Y", TTTQuests.MyQuestsDeadline) ))
				self.QuestDeadline:SetTextColor(COLOR_WHITE)
				self.QuestDeadline:SetFont("PS2_SmallHeading")
				self.QuestDeadline:Dock(BOTTOM)
				self.QuestDeadline:SetContentAlignment(6)
			end

			timer.Destroy("DQuestsPanel_Timer")
		end
	end)
	
end

function PANEL:ApplySchemeSettings( )

end

function PANEL:PerformLayout( )

end

function PANEL:Paint()

end

derma.DefineControl( "DQuestsPanel", "", PANEL, "DPanel" )
Pointshop2:AddInventoryPanel( "Quests", "pointshop2/dollar103.png", "DQuestsPanel" )
TTTQuests.Log("Panel loaded!", COLOR_GREEN)