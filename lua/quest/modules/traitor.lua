local MODULE = {}

MODULE.Class = "Traitor"
MODULE.Name = "Counter terrorism"
MODULE.Description = "Kill %d Innocents as Traitor"
MODULE.TargetValue = 5 // This is killed innocent count to finish the quest
MODULE.RewardType = TTTQuests.RewardType.PremiumPoints // For random just define MODULE.Reward like this: {{type = 0, reward = 5000}, {type = 2, reward = "%item_class%"}}
MODULE.Reward = 5000 // Just define it here. It'll be easily edited later

// That is useless for client. We shall be economical with RAM
if ( SERVER ) then
	// This is database parameters
	// It needs to create table in database
	// Key is name of parameter
	// Value is default value and type of parameter  
	MODULE.DBParameters = {}
	MODULE.DBParameters["SteamID"] = "\"\"" // Must have
	MODULE.DBParameters["KilledByTraitor"] = 0

	// Hooks functions are called on a specific event
	// We shall use them to calculate quest condition
	// and give a reward to a player who fulfilled the condition
	MODULE.Hooks = {}
	MODULE.Hooks["DoPlayerDeath"] = function(victim, attacker, dmginfo)
		if ( #player.GetAll() >= TTTQuests.Config.MinPlayers ) then

			// Players must be valid and not bots
			if IsValid(victim)
				&& IsValid(attacker)
				&& attacker:IsPlayer()
				&& victim:IsPlayer()
				&& !attacker:IsBot()
				&& !victim:IsBot()
				&& attacker != victim then

				// Check quest status
				if TTTQuests.HasPlayerQuest(attacker, "Traitor") && !TTTQuests.IsQuestComplete(attacker, "Traitor") then

					// An attacker must be a traitor and a victim must be an innocent
					if attacker:IsTraitor() && !victim:IsTraitor() then

						// Select a row from table
						local row = sql.MySQLQuery("SELECT KilledByTraitor FROM TTTQuests_Traitor WHERE SteamID = \"%s\"", attacker:SteamID() )

						if row then // Just make sure the row isn't nil
							
							// Get current progress from the row
							local currentKills = row[1].KilledByTraitor

							// Check our condition
							if ( currentKills + 1 >= TTTQuests.Quests["Traitor"].TargetValue ) then

								// Call the hook
								hook.Run("TTTQuests_QuestComplete", attacker, "Traitor")
							end

							// Write to new progress to a database
							sql.MySQLQuery("UPDATE TTTQuests_Traitor SET KilledByTraitor=%d WHERE SteamID = \"%s\"", currentKills + 1, attacker:SteamID() )
						end
					end
				end
			end
		end
	end
end

// Register our quest module
TTTQuests:RegisterQuest(MODULE)