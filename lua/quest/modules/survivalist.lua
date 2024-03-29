local MODULE = {}

MODULE.Class = "Survivalist"
MODULE.Name = "Survivalist"
MODULE.Description = "Survive %d rounds"
MODULE.TargetValue = 3 // This is surivived rounds count to finish the quest
MODULE.RewardType = TTTQuests.RewardType.Random
MODULE.Reward = {
	{rewardType = TTTQuests.RewardType.StandardPoints, reward = 3000},
	{rewardType = TTTQuests.RewardType.Item, reward = "38"},
} // Just define it here. It'll be easily edited later

// That is useless for client. We shall be economical with RAM
if ( SERVER ) then
	// This is database parameters
	// It needs to create table in database
	// Key is name of parameter
	// Value is default value and type of parameter  
	MODULE.DBParameters = {}
	MODULE.DBParameters["SteamID"] = "\"\"" // Must have
	MODULE.DBParameters["RoundSurvived"] = 0

	// Hooks functions are called on a specific event
	// We shall use them to calculate quest condition
	// and give a reward to a player who fulfilled the condition
	MODULE.Hooks = {}
	MODULE.Hooks["TTTEndRound"] = function(result)
		if ( #player.GetAll() >= TTTQuests.Config.MinPlayers ) then

			for _, ply in pairs(player.GetAll()) do
				
				// Players must be valid and not be dead
				if IsValid(ply) && !ply:IsSpec() then

					// Check quest status
					if TTTQuests.HasPlayerQuest(ply, "Survivalist") && !TTTQuests.IsQuestComplete(ply, "Survivalist") then

						// Select a row from table
						local row = sql.MySQLQuery("SELECT RoundSurvived FROM TTTQuests_Survivalist WHERE SteamID = \"%s\"", ply:SteamID() )

						if row then // Just make sure the row isn't nil
							
							// Get current progress from the row
							local currentRounds = row[1].RoundSurvived

							// Check our condition
							if ( currentRounds + 1 >= TTTQuests.Quests["Survivalist"].TargetValue ) then

								// Call the hook
								hook.Run("TTTQuests_QuestComplete", ply, "Survivalist")
							end

							// Write to new progress to a database
							sql.MySQLQuery("UPDATE TTTQuests_Survivalist SET RoundSurvived=%d WHERE SteamID = \"%s\"", currentRounds + 1, ply:SteamID() )
						end
					end
				end
			end
		end
	end
end

// Register our quest module
TTTQuests:RegisterQuest(MODULE)