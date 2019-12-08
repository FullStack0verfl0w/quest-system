local MODULE = {}

MODULE.Class = "DetWepBinoculars"
MODULE.Name = "Eagle eye"
MODULE.Description = [[
Be a Detective and buy
	Binoculars %d times
]]
MODULE.Chance = 25 // Lower the chance, because we'll use 4 almost similar quests. 100 (default chance) / 4 (items)
MODULE.TargetValue = 10

MODULE.RewardType = TTTQuests.RewardType.StandardPoints
MODULE.Reward = 5000

if ( SERVER ) then
	// This is database parameters
	// It needs to create table in database
	// Key is name of parameter
	// Value is default value and type of parameter  
	MODULE.DBParameters = {}
	MODULE.DBParameters["SteamID"] = "\"\"" // Must have
	MODULE.DBParameters["BinocularsBought"] = 0

	// Hooks functions are called on a specific event
	// We shall use them to calculate quest condition
	// and give a reward to a player who fulfilled the condition
	MODULE.Hooks = {}
	MODULE.Hooks["TTTOrderedEquipment"] = function(ply, equip, is_item)

		// Player must be valid
		if IsValid(ply) then

			// Check quest status
			if TTTQuests.HasPlayerQuest(ply, "DetWepBinoculars") && !TTTQuests.IsQuestComplete(ply, "DetWepBinoculars") then

				// A player must be detective
				if ply:IsDetective() then
					
					// Check equipment type
					if ( equip == "weapon_ttt_binoculars" ) then

						// Select a row from table
						local row = sql.MySQLQuery("SELECT BinocularsBought FROM TTTQuests_DetWepBinoculars WHERE SteamID = \"%s\"", ply:SteamID() )

						if row then // Just make sure the row isn't nil
							
							// Get current progress from the row
							local current = row[1].BinocularsBought

							// Check our condition
							if ( current + 1 >= TTTQuests.Quests["DetWepBinoculars"].TargetValue ) then

								// Call the hook
								hook.Run("TTTQuests_QuestComplete", ply, "DetWepBinoculars")
							end

							// Write to new progress to a database
							sql.MySQLQuery("UPDATE TTTQuests_DetWepBinoculars SET BinocularsBought=%d WHERE SteamID = \"%s\"", current + 1, ply:SteamID() )
						end
					end
				end
			end
		end
	end
end

// Register our quest module
TTTQuests:RegisterQuest(MODULE)