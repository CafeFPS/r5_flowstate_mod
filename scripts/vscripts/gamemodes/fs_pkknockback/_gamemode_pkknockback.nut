//APEX KNOCKBACK RING
//Made by @CafeFPS

// everyone else - advice

global function _GamemodePkknockback_Init
global function _RegisterLocationPK
global function ReturnCenterOfSelectedLocation
global function UpdatePlayersClientUI
global function ReturnSelectedLocationName

bool colombiadebug = false

struct {
	int winnerTeam = 0
	array<entity> ringFlares
	array<entity> boostZones
	vector chosenRingCircle
	
	// Voting
	array<entity> votedPlayers
	bool votingtime = false
	bool votestied = false
	array<int> mapVotes
	array<int> mapIds
	int mappicked = 0
	int currentRound = 1
	float thisRoundEndTime
	float thisRoundVotingEndTime
	
	vector lobbyLocation
	vector lobbyAngles
	array<LocationSettings> locationSettings
	LocationSettings& selectedLocation
} file

void function _GamemodePkknockback_Init()
{
	switch(GetMapName())
	{
		case "mp_rr_aqueduct":
			file.lobbyLocation = <-323.799377, -16008.7832, 11485.8652>
			file.lobbyAngles = <0, 24.2251167, 0>
		break
	}
	
	Sh_ArenaDeathField_Init()
	
	// AddCallback_GameStateEnter( eGameState.Playing, Deathfield_Create )
	// AddCallback_GameStateEnter( eGameState.MapVoting, Deathfield_Destroy )
	
	if(GetCurrentPlaylistVarBool("enable_global_chat", true))
		SetConVarBool("sv_forceChatToTeamOnly", false)
	else
		SetConVarBool("sv_forceChatToTeamOnly", true)
	
	AddCallback_OnClientConnected( void function(entity player) { 
		thread _OnPlayerConnected(player)
    })
	
	AddCallback_OnPlayerKilled( void function(entity victim, entity attacker, var damageInfo) {
        thread _OnPlayerKilled(victim, attacker, damageInfo)
    })
	
	AddCallback_EntitiesDidLoad( _OnEntitiesDidLoad )
	
	AddClientCommandCallback("VoteForMap", ClientCommand_VoteForMap)	
	AddClientCommandCallback("next_round", ClientCommand_NextRoundPKKNOCKBACK)
	AddClientCommandCallback("testcenterpos", ClientCommand_TestPos)
	AddClientCommandCallback("askringsize", ClientCommand_AskRingSize)
	
	PrecacheParticleSystem($"P_enemy_jump_jet_ON_trails")
	PrecacheParticleSystem( $"P_skydive_trail_CP" )
	PrecacheParticleSystem($"P_impact_shieldbreaker_sparks")
	PrecacheParticleSystem($"P_survival_radius_CP_1x100")
	PrecacheParticleSystem(DROPPOD_SPAWN_FX)
	PrecacheParticleSystem($"P_armor_body_CP")

	// PrecacheModel($"mdl/Humans/pilots/ptpov_master_chief.rmdl")
	// PrecacheModel($"mdl/Humans/pilots/w_master_chief.rmdl")
	// PrecacheModel($"mdl/Humans/pilots/w_blisk.rmdl")
	// PrecacheModel($"mdl/Humans/pilots/pov_blisk.rmdl")
	// PrecacheModel($"mdl/Humans/pilots/w_ash_legacy.rmdl")
	// PrecacheModel($"mdl/Humans/pilots/pov_ash_legacy.rmdl")
	
	PrecacheModel($"mdl/fx/ar_survival_radius_1x1.rmdl")
	PrecacheModel($"mdl/fx/ar_edge_sphere_512.rmdl")
	
	RegisterSignal("EndLobbyDistanceThread")
	thread PKKNOCKBACK_StartGameThread()
}

void function _OnEntitiesDidLoad()
{
	// AddSpawnCallback("zipline", _OnPropDynamicSpawned)
	// AddSpawnCallback("prop_dynamic", _OnPropDynamicSpawned)
	// ShipmentMap_Load(<11162.3438, 24561.002, 237.033569>)
}

void function _OnPlayerConnected(entity player)
{
	while(IsDisconnected( player )) WaitFrame()

    if(!IsValid(player)) return
	
	_HandleRespawn(player)
	
	AssignCharacter(player, RandomInt(9))
	player.SetPlayerGameStat( PGS_DEATHS, 0)
	AddEntityCallback_OnDamaged( player, PkKnockback_OnPlayerDamaged )
	UpdatePlayerCounts()
	
	switch(GetGameState())
    {
		case eGameState.WaitingForPlayers:
		case eGameState.MapVoting:
		thread function() : (player)
		{
			if(file.votingtime)
			{
				SetPlayerInventory( player, [] )
				Inventory_SetPlayerEquipment(player, "", "armor")
				
				player.p.roundPlayerPoints = 0
				player.p.ampedDamageBonus = 0
				player.p.ampedFireRateBonus = 0
				player.p.currentPlayerSpeed = 1
				player.e.lastAttacker = null
				
				player.FreezeControlsOnServer()
				
				Remote_CallFunction_ByRef(player, "Minimap_DisableDraw_Internal")

				if( !IsAlive( player ) )
					DoRespawnPlayer(player, null)
				//reset votes
				Remote_CallFunction_Replay(player, "ServerCallback_FSDM_UpdateMapVotesClient", file.mapVotes[0], file.mapVotes[1], file.mapVotes[2], file.mapVotes[3])
				
				//launch champion screen + voting phase
				Remote_CallFunction_Replay(player, "ServerCallback_FSDM_OpenVotingPhase", true)
					
				Remote_CallFunction_NonReplay(player, "ServerCallback_FSDM_CoolCamera")
				Remote_CallFunction_Replay(player, "ServerCallback_FSDM_UpdateVotingMaps", file.mapIds[0], file.mapIds[1], file.mapIds[2], file.mapIds[3])
				Remote_CallFunction_Replay(player, "ServerCallback_FSDM_SetScreen", eFSDMScreen.VoteScreen, file.thisRoundVotingEndTime, eFSDMScreen.NotUsed, eFSDMScreen.NotUsed)

			} else {
				Remote_CallFunction_ByRef(player, "Minimap_DisableDraw_Internal")
				player.FreezeControlsOnServer()
			}
		}()
			break
		case eGameState.Playing:
			StartSpectatingPkKnockback(player, null)
			break
		default:
			break
	}

}

void function _OnPlayerKilled(entity victim, entity attacker, var damageInfo)
{
	if ( !IsValid( victim ) || !IsValid( attacker) || IsValid(victim) && !victim.IsPlayer() )
		return

	switch(GetGameState())
    {
		case eGameState.Playing:
		
			thread function() : (victim, attacker, damageInfo) 
			{
				if( IsValid(attacker) && attacker.IsPlayer() && attacker != victim )
				{
					Remote_CallFunction_NonReplay(attacker, "PKKNOCKBACK_CustomHint", 0, 0)
					attacker.p.roundPlayerPoints+=100
				}
			
				Remote_CallFunction_NonReplay( victim, "PKKNOCKBACK_SetUIVisibility", false)
				Remote_CallFunction_NonReplay( victim, "PKKNOCKBACK_Timer", false, 0 )
			
				int deaths = victim.GetPlayerGameStat( PGS_DEATHS )
				deaths++
				victim.SetPlayerGameStat( PGS_DEATHS, deaths)
				StatusEffect_StopAllOfType( victim, eStatusEffect.damageAmpFXOnly)
				
				wait DEATHCAM_TIME_SHORT

				//thread UpdatePlayersClientUI()

				if( !IsValid(victim) || GetGameState() != eGameState.Playing) return
				
				if(GetPlayerArray_Alive().len() > 1)
					thread StartSpectatingPkKnockback(victim, attacker)
				
				if(!IsValid(attacker) || IsValid(attacker) && !attacker.IsPlayer() ) return

				WpnAutoReloadOnKill(attacker)
				GameRules_SetTeamScore(attacker.GetTeam(), GameRules_GetTeamScore(attacker.GetTeam()) + 1)
				
				
			}()
		break
	}
	
	printt("Flowstate DEBUG - KNOCBACKS player killed.", victim, " -by- ", attacker)
}

void function UpdatePlayersClientUI(bool firstTime = false)
{
	// if(GetGameState() != eGameState.Playing) return
	array<entity> AllPlayers = GetPlayerArray_Alive()
	AllPlayers.sort(ComparePlayerInfo_Knockbacks)

	for(int i = 1; i <= AllPlayers.len(); i++)
	{
		entity player = AllPlayers[i-1]
		
		if(!IsValid(player)) continue
		
		int p2_points = 0
		entity p2_player = null

		int local_points = player.p.roundPlayerPoints
		entity local_player = player
	
		if(i == 1 || firstTime)
		{
			int local_placement = 1
			int p2_placement = 2

			if(AllPlayers.len() > 1 && IsValid(AllPlayers[1]))
			{
				p2_player = AllPlayers[1]
				p2_points = p2_player.p.roundPlayerPoints
			}

			Remote_CallFunction_Replay( player, "PKKNOCKBACK_PlayerKilled", local_points, local_placement, local_player, p2_points, p2_placement, p2_player )
		}
		else
		{
			int local_placement = 2
			int p2_placement = 1

			if(AllPlayers.len() > 0 && IsValid(AllPlayers[0]))
			{
				p2_player = AllPlayers[0]
				p2_points = p2_player.p.roundPlayerPoints
			}

			Remote_CallFunction_Replay( player, "PKKNOCKBACK_PlayerKilled", local_points, local_placement, local_player, p2_points, p2_placement, p2_player )
		}
	}
}

void function PKKNOCKBACK_StartGameThread()
{
    WaitForGameState(eGameState.Playing)
	
    for(;;)
	{
		PKKNOCKBACK_Lobby()
		PKKNOCKBACK_GameLoop()
		WaitFrame()
	}
}

void function PKKNOCKBACK_Lobby() //Execute voting phase here
{
	SetGameState(eGameState.MapVoting)
	
	foreach(player in GetPlayerArray())
	{
		if(!IsValid(player)) continue

		SetPlayerInventory( player, [] )
		Inventory_SetPlayerEquipment(player, "", "armor")
		
		player.p.roundPlayerPoints = 0
		player.p.ampedDamageBonus = 0
		player.p.ampedFireRateBonus = 0
		player.p.currentPlayerSpeed = 1
		player.e.lastAttacker = null
		
		player.FreezeControlsOnServer()
		
		Remote_CallFunction_ByRef(player, "Minimap_DisableDraw_Internal")

		if( !IsAlive( player ) )
			DoRespawnPlayer(player, null)
	}

	ResetMapVotes()

	foreach( player in GetPlayerArray() )
	{
		if( !IsValid( player ) )
			continue
		
		//reset votes
		Remote_CallFunction_Replay(player, "ServerCallback_FSDM_UpdateMapVotesClient", file.mapVotes[0], file.mapVotes[1], file.mapVotes[2], file.mapVotes[3])
		
		//launch champion screen + voting phase
		Remote_CallFunction_Replay(player, "ServerCallback_FSDM_OpenVotingPhase", true)
		// Remote_CallFunction_Replay(player, "ServerCallback_FSDM_ChampionScreenHandle", true, file.winnerTeam, 0)
		// Remote_CallFunction_Replay(player, "ServerCallback_FSDM_SetScreen", eFSDMScreen.WinnerScreen, file.winnerTeam, eFSDMScreen.NotUsed, eFSDMScreen.NotUsed)
	}

	// file.mapIds.append( 0 )
	thread function() : ()
	{
		file.mapIds.append( 1 )
		
		for( int i = 0; i < NUMBER_OF_MAP_SLOTS_FSDM - 1; ++i )
		{
			while( true )
			{
				// Get a random location id from the available locations
				int randomId = RandomIntRange(0, file.locationSettings.len())

				// If the map already isnt picked for voting then append it to the array, otherwise keep looping till it finds one that isnt picked yet
				if( !file.mapIds.contains( randomId ) )
				{
					file.mapIds.append( randomId )
					break
				}
			}
		}
	}()
	
	// wait 7

	// foreach( player in GetPlayerArray() )
	// {
		// if( !IsValid( player ) )
			// continue
		
		// Remote_CallFunction_NonReplay(player, "ServerCallback_FSDM_CoolCamera")
		// Remote_CallFunction_Replay(player, "ServerCallback_FSDM_SetScreen", eFSDMScreen.ScoreboardUI, file.winnerTeam, eFSDMScreen.NotUsed, eFSDMScreen.NotUsed)
		// EmitSoundOnEntityOnlyToPlayer(player, player, "UI_Menu_RoundSummary_Results")
	// }
	
	// wait 7
	
	file.votingtime = true
	file.thisRoundVotingEndTime = Time() + 16
	
	// For each player, set voting screen and update maps that are picked for voting
	
	if( file.mapIds.len() == 4 )
		foreach( player in GetPlayerArray() )
		{
			if( !IsValid( player ) )
				continue
			
			Remote_CallFunction_NonReplay(player, "ServerCallback_FSDM_CoolCamera")
			Remote_CallFunction_Replay(player, "ServerCallback_FSDM_UpdateVotingMaps", file.mapIds[0], file.mapIds[1], file.mapIds[2], file.mapIds[3])
			Remote_CallFunction_Replay(player, "ServerCallback_FSDM_SetScreen", eFSDMScreen.VoteScreen, file.thisRoundVotingEndTime, eFSDMScreen.NotUsed, eFSDMScreen.NotUsed)
		}

	if(!colombiadebug)
		wait 16
	else 
		wait 1
	
	file.votestied = false
	bool anyVotes = false

	// Make voting not allowed
	file.votingtime = false

	// See if there was any votes in the first place
	foreach( int votes in file.mapVotes )
	{
		if( votes > 0 )
		{
			anyVotes = true
			break
		}
	}

	if ( anyVotes )
	{
		// store the highest vote count for any of the maps
		int highestVoteCount = -1

		// store the last map id of the map that has the highest vote count
		int highestVoteId = -1

		// store map ids of all the maps with the highest vote count
		array<int> mapsWithHighestVoteCount


		for(int i = 0; i < NUMBER_OF_MAP_SLOTS_FSDM; ++i)
		{
			int votes = file.mapVotes[i]
			if( votes > highestVoteCount )
			{
				highestVoteCount = votes
				highestVoteId = file.mapIds[i]

				// we have a new highest, so clear the array
				mapsWithHighestVoteCount.clear()
				mapsWithHighestVoteCount.append(file.mapIds[i])
			}
			else if( votes == highestVoteCount ) // if this map also has the highest vote count, add it to the array
			{
				mapsWithHighestVoteCount.append(file.mapIds[i])
			}
		}

		// if there are multiple maps with the highest vote count then it's a tie
		if( mapsWithHighestVoteCount.len() > 1 )
		{
			file.votestied = true
		}
		else // else pick the map with the highest vote count
		{
			// Set the vote screen for each player to show the chosen location
			foreach( player in GetPlayerArray() )
			{
				if( !IsValid( player ) )
					continue

				Remote_CallFunction_Replay(player, "ServerCallback_FSDM_SetScreen", eFSDMScreen.SelectedScreen, eFSDMScreen.NotUsed, highestVoteId, eFSDMScreen.NotUsed)
			}

			// Set the location to the location that won
			file.mappicked = highestVoteId
		}

		if ( file.votestied )
		{
			foreach( player in GetPlayerArray() )
			{
				if( !IsValid( player ) )
					continue

				Remote_CallFunction_Replay(player, "ServerCallback_FSDM_SetScreen", eFSDMScreen.TiedScreen, eFSDMScreen.NotUsed, 42068, eFSDMScreen.NotUsed)
			}

			mapsWithHighestVoteCount.randomize()
			waitthread RandomizeTiedLocations(mapsWithHighestVoteCount)
		}
	}
	else // No one voted so pick random map
	{
		// Pick a random location id from the aviable locations
		if( file.locationSettings.len() > 1 )
			file.mappicked = RandomIntRange(0, file.locationSettings.len() - 1)
		else
			file.mappicked = 0

		// Set the vote screen for each player to show the chosen location
		foreach( player in GetPlayerArray() )
		{
			if( !IsValid( player ) )
				continue

			Remote_CallFunction_Replay(player, "ServerCallback_FSDM_SetScreen", eFSDMScreen.SelectedScreen, eFSDMScreen.NotUsed, file.mappicked, eFSDMScreen.NotUsed)
		}
	}

	//Set selected location
	file.selectedLocation = file.locationSettings[ file.mappicked ]

	if( file.selectedLocation.name == "Shipment" )
		printt("shipment time")

	array<LocPair> spawns = file.selectedLocation.spawns
	int numAirdropsForThisRound = 1
	int tries

	if( file.selectedLocation.name != "Shipment" )
	{
		for (int j = 0; j < numAirdropsForThisRound && tries < 25; j++)
		{
			file.chosenRingCircle = SURVIVAL_FindRing( GetCenterOfCircle( spawns ) )

			if(!VerifyAirdropPoint( file.chosenRingCircle, 0, true ))
			{
				tries++
				j--
			}
		}
	}

	if(tries == 25 || file.selectedLocation.name == "Shipment")
		file.chosenRingCircle = OriginToGround(GetCenterOfCircle( spawns ))
	
	printt("next calculated valid airdrop position, used for deathfield center too: + " + file.chosenRingCircle + " .Colombia")
	
	//wait for timing
	wait 7

	// Close the votemenu for each player
	foreach( player in GetPlayerArray() )
	{
		if( !IsValid( player ) )
			continue
		
		ScreenCoverTransition_Player(player, Time() + 1)
		Remote_CallFunction_Replay(player, "ServerCallback_FSDM_OpenVotingPhase", false)
	}

	wait 2
	// }
	
    // Clear players the voted for next voting
    file.votedPlayers.clear()

    // Clear mapids for next voting
    file.mapIds.clear()	
}

string function ReturnSelectedLocationName()
{
	return file.selectedLocation.name
}

vector function ReturnCenterOfSelectedLocation()
{
	return file.chosenRingCircle
}

void function PKKNOCKBACK_GameLoop()
{
	array<LocPair> spawns = file.selectedLocation.spawns
	array<LocPair> actualSpawns

	//get spawn points inside allowed radius
	foreach(spawn in spawns)
	{
		if( Distance( spawn.origin, file.chosenRingCircle ) <= GetCurrentPlaylistVarFloat( "survival_death_field_start_radius", -1.0 ) )
			actualSpawns.append(spawn)
	}

	if(actualSpawns.len() == 0) //just in case it doesn't found spawn points inside allowed radius
	{
		//get initial seed for ring, the nearest spawn point to the center
		array<float> SpawnsDistances
		foreach(spawn in spawns)
		{
			SpawnsDistances.append(Distance( spawn.origin, file.chosenRingCircle ))
		}
		float compare = 99999
		int j = 0
		for(int i = 0; i < spawns.len(); i++)
		{
			if(SpawnsDistances[i] < compare)
			{
				compare = SpawnsDistances[i]
				j = i
			}
		}		
		file.chosenRingCircle = spawns[j].origin

		//get spawn points inside allowed radius
		foreach(spawn in spawns)
		{
			if( Distance( spawn.origin, file.chosenRingCircle ) <= GetCurrentPlaylistVarFloat( "deathfield_radius_0", -1.0 ) )
				actualSpawns.append(spawn)
		}
	}
	
	SurvivalCommentary_ResetAllData()

	foreach(player in GetPlayerArray())
	{
		if(!IsValid(player)) continue
		
		ScreenCoverTransition_Player(player, Time() + 1)
	}	
	float endtime = Time() + GetCurrentPlaylistVarFloat("PkKnockback_Round_LimitTime", 300 ) + WAIT_TIME_WHEN_RINGCLOSED
	
	foreach( player in GetPlayerArray() ) //tpin all players to arena
	{
		if(!IsValid(player)) continue
		
		Signal(player, "EndLobbyDistanceThread")
		
		_HandleRespawn(player)
		
		Remote_CallFunction_ByRef(player, "Minimap_EnableDraw_Internal")
		
		StartParticleEffectInWorld( GetParticleSystemIndex( $"P_impact_shieldbreaker_sparks" ), player.GetOrigin(), Vector(0,0,0) )
		EmitSoundOnEntityOnlyToPlayer( player, player, "PhaseGate_Enter_1p" )
		EmitSoundOnEntityExceptToPlayer( player, player, "PhaseGate_Enter_3p" )

		player.SetVelocity(Vector(0,0,0))
		
		int randomspawn = RandomIntRangeInclusive(0, actualSpawns.len()-1)

		player.SetOrigin(actualSpawns[randomspawn].origin)	
		player.SetAngles(actualSpawns[randomspawn].angles)	
		
		TakeLoadoutRelatedWeapons(player)
		
		player.GiveWeapon( "mp_weapon_melee_boxing_ring", WEAPON_INVENTORY_SLOT_PRIMARY_2, [] )
		player.GiveOffhandWeapon( "melee_boxing_ring", OFFHAND_MELEE, [] )
		player.GiveWeapon( "mp_weapon_energy_shotgun", WEAPON_INVENTORY_SLOT_PRIMARY_0 )
		
		if(CoinFlip())
			player.GiveOffhandWeapon("mp_ability_grapple", OFFHAND_TACTICAL)
		else
			player.GiveOffhandWeapon("mp_ability_selfpushback", OFFHAND_TACTICAL)
		
	    player.GiveOffhandWeapon("mp_weapon_bubble_bunker", OFFHAND_ULTIMATE)
		player.GetOffhandWeapon( OFFHAND_ULTIMATE ).AddMod("knockbacks")
		
		player.SetActiveWeaponBySlot(eActiveInventorySlot.mainHand, WEAPON_INVENTORY_SLOT_PRIMARY_0)
	
		DeployAndEnableWeapons(player)
		Highlight_SetFriendlyHighlight( player, "prophunt_teammate" )
		ClearInvincible(player)
		player.SetThirdPersonShoulderModeOff()
		
		SetPlayerInventory( player, [] )
		Inventory_SetPlayerEquipment(player, "backpack_pickup_lv3", "backpack")
		// array<string> optics = ["optic_cq_hcog_classic", "optic_cq_hcog_bruiser", "optic_cq_holosight", "optic_cq_threat", "optic_cq_holosight_variable", "optic_ranged_hcog", "optic_ranged_aog_variable", "optic_sniper_variable", "optic_sniper_threat"]
		// foreach(optic in optics)
			// SURVIVAL_AddToPlayerInventory(player, optic)
		Inventory_SetPlayerEquipment(player, "armor_pickup_lv2", "armor")
		player.SetShieldHealth( 75 )
		
		//Start skydiving?
		// if(ReturnSelectedLocationName() != "Shipment")
		// {
			// player.SetOrigin(Vector(actualSpawns[randomspawn].origin.x, actualSpawns[randomspawn].origin.y, actualSpawns[randomspawn].origin.z + 6500))	
			// player.SetAngles(VectorToAngles( file.chosenRingCircle - player.GetOrigin() ) )
			// thread PlayerSkydiveFromCurrentPosition( player )
		// }
		Remote_CallFunction_NonReplay(player, "PKKNOCKBACK_SetUIVisibility", true)
		Remote_CallFunction_NonReplay( player, "PKKNOCKBACK_Timer", true, endtime )
	}
	
	UpdatePlayerCounts()
	SetGameState(eGameState.Playing)
	
	// array<entity> allPlayers = GetPlayerArray_Alive()
	
	// foreach(player in allPlayers)
	// {
		// if(player.GetPlayerName() == "HisWattson2222")
		// {
			// //AssignCharacter(player, 1)
			
			// player.SetBodyModelOverride($"mdl/Humans/pilots/w_master_chief.rmdl")
			// player.SetArmsModelOverride($"mdl/Humans/pilots/ptpov_master_chief.rmdl")			
		// } 
	// }
	
	// foreach(player in allPlayers)
		// if( player.GetPlayerName() == "HisWattson2222" )
			// allPlayers.removebyvalue(player)
	
	// entity randomPlayerToBeBlisk 
	
	// if( allPlayers.len() > 0 ) 
		// randomPlayerToBeBlisk  = allPlayers.getrandom()
	
	// if( IsValid(randomPlayerToBeBlisk) )
	// {
		// //AssignCharacter(randomPlayerToBeBlisk, 1)
		// randomPlayerToBeBlisk.SetBodyModelOverride($"mdl/Humans/pilots/w_blisk.rmdl")
		// randomPlayerToBeBlisk.SetArmsModelOverride($"mdl/Humans/pilots/pov_blisk.rmdl")	
	// }
	
	// foreach(player in allPlayers)
		// if( player == randomPlayerToBeBlisk )
			// allPlayers.removebyvalue(player)
		
	// entity randomPlayerToBeAsh
	
	// if( allPlayers.len() > 0 ) 
		// randomPlayerToBeAsh  = allPlayers.getrandom()
	
	// if( IsValid(randomPlayerToBeAsh) )
	// {
		// //AssignCharacter(randomPlayerToBeBlisk, 1)
		// randomPlayerToBeAsh.SetBodyModelOverride($"mdl/Humans/pilots/w_ash_legacy.rmdl")
		// randomPlayerToBeAsh.SetArmsModelOverride($"mdl/Humans/pilots/pov_ash_legacy.rmdl")	
	// }	
	
	SetGlobalNetInt( "currentDeathFieldStage", 0 )
	FlagClear( "DoneCreatingDeathFieldPosition" )
	FlagClear( "DeathFieldPaused" )
	FlagClear( "SUR_DeathFieldShrinking" )
	// Deathfield_Create()
	WaitFrame()
	
	thread HandleRingFlares(file.chosenRingCircle)
	thread HandleBoostZones(file.chosenRingCircle)
	
	FlagSet( "DeathCircleActive" )
	FlagSet( "AllowDeathFieldUpdate" )
	bool carepackagespawned = false
	
	thread UpdatePlayersClientUI( true )
	
	thread function() : ()
	{
		if(file.currentRound > 1)
		{
			wait 3
			if(GetGameState() != eGameState.Playing) return
			array<entity> AllPlayers = GetPlayerArray()
			if(AllPlayers.len() > 0)
			{
				AllPlayers.sort(ComparePlayerInfo_TotalPoints_Knockbacks	)
			}
			string msg = ""
			for(int i = 0; i < min(6, AllPlayers.len()); i++)
			{
				entity Player = AllPlayers[i]
				switch(i)
				{
					case 0:
						msg = msg + "1. " + Player.GetPlayerName() + ":   " + Player.p.totalpoints + " points. \n"
						break
					case 1:
						msg = msg + "2. " + Player.GetPlayerName() + ":   " + Player.p.totalpoints + " points. \n"
						break
					case 2:
						msg = msg + "3. " + Player.GetPlayerName() + ":   " + Player.p.totalpoints + " points. \n"
						break
					default:
						msg = msg + Player.GetPlayerName() + ":   " + Player.p.totalpoints + " points. \n"
						break
				}
			}
			
			foreach ( entity player in GetPlayerArray() )
			{
				Message(player, "BEST PLAYERS", msg + "\n \n Temp message this will be changed", 5, "")
			}
		}
		wait 10
		
		if(GetGameState() != eGameState.Playing) return
		
		foreach(player in GetPlayerArray_Alive())
		{
			if(!IsValid(player)) continue
			
			Remote_CallFunction_NonReplay(player, "PKKNOCKBACK_CustomHint", 3, 0) //credits ;)
			if(file.currentRound > 1)
			{
				Remote_CallFunction_NonReplay(player, "PKKNOCKBACK_CustomHint", 10, player.p.totalpoints)
			}
		}
	}()
	
	while( Time() < endtime )
	{
		if(GetPlayerArray_Alive().len() == 0)
		{
			SetGameState(eGameState.MapVoting)
			break
		}
			
		if( GetPlayerArray_Alive().len() == 1 && GetPlayerArray().len() > 1)
		{

			// if(GetPlayerArray_Alive().len() == 1 && IsValid(GetPlayerArray_Alive()[0]))
			// {
				// SetChampion( GetPlayerArray_Alive()[0] )
				// file.winnerTeam = GetPlayerArray_Alive()[0].GetTeam()
			// } else
				// file.winnerTeam = 0 //no winner
			
			SetGameState(eGameState.MapVoting)
			break
		}
		
		//printt(SURVIVAL_GetDeathFieldCurrentRadius())
		if(SURVIVAL_GetDeathFieldCurrentRadius() < 3000 && SURVIVAL_GetDeathFieldCurrentRadius() >= 2950 && !carepackagespawned)
		{
			//Play the announcement
			AddSurvivalCommentaryEvent(eSurvivalEventType.CARE_PACKAGE_DROPPING)
			entity fx = StartParticleEffectInWorld_ReturnEntity(GetParticleSystemIndex( DROPPOD_SPAWN_FX ), OriginToGround(file.chosenRingCircle), Vector(0,0,0))
			fx.kv.fadedist = 9999
			thread AirdropItems( file.chosenRingCircle, Vector(0,0,0), ["mp_weapon_raygun", "mp_weapon_throwingknife", "mp_weapon_sniper" ], fx, "droppod_loot_drop", null, 0, "" )
			carepackagespawned = true
		}
		
		if(GetGameState() == eGameState.MapVoting)
		{
			//Round ended
			break
		}
		WaitFrame()	
	}
	
	if(GetGameState() != eGameState.MapVoting)
		SetGameState(eGameState.MapVoting)
	
	foreach(carePackage in ReturnCarePackagesNewArray())
	{
		if(IsValid(carePackage))
		{
			printt("destroying care package right now with position " + carePackage.GetOrigin())
			carePackage.Destroy()
		}
	}
	
	if(IsValid(SURVIVAL_GetDeathField()))
		Signal(SURVIVAL_GetDeathField(), "EndClientEffectsThread")
	
	FlagSet( "DeathFieldPaused" )
	FlagClear( "DeathCircleActive" )
	
	SetGlobalNetTime( "nextCircleStartTime", 0 )
	SetGlobalNetTime( "circleCloseTime", 0 )
	
	array<entity> AllPlayers = GetPlayerArray()
	if(AllPlayers.len() > 0)
	{
		AllPlayers.sort(ComparePlayerInfo_Knockbacks)
		SetChampion(AllPlayers[0])
	}
	
	if( IsValid( GetChampion() ) )
	{
		file.winnerTeam = GetChampion().GetTeam()
	}

	thread SurvivalCommentary_HostAnnounce( eSurvivalCommentaryBucket.WINNER, 3.0 )
			
	bool wastie = false
	
	wait 0.1
	
	// if(!wastie)
	// {
		foreach ( entity player in GetPlayerArray() )
		{
			if(!IsValid(player)) continue

			Remote_CallFunction_NonReplay(player, "PKKNOCKBACK_SetUIVisibility", false)
			Remote_CallFunction_NonReplay( player, "PKKNOCKBACK_Timer", false, 0 )
			
			Remote_CallFunction_ByRef(player, "Minimap_DisableDraw_Internal")
			MakeInvincible( player )
			AddCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD_INSTANT )
			AddCinematicFlag( player, CE_FLAG_HIDE_PERMANENT_HUD )
			// Remote_CallFunction_NonReplay( player, "ServerCallback_PlayMatchEndMusic" )
			Remote_CallFunction_NonReplay( player, "ServerCallback_MatchEndAnnouncement", player == GetChampion(), file.winnerTeam )
		}

		wait 3.5
	// }
	
	// if(!wastie)
	// {
		foreach ( player in GetPlayerArray() )
		{
			if(!IsValid(player)) continue
			
			player.p.totalpoints += player.p.roundPlayerPoints
			Remote_CallFunction_NonReplay( player, "ServerCallback_DestroyEndAnnouncement")
			// RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD_INSTANT )
			// RemoveCinematicFlag( player, CE_FLAG_HIDE_PERMANENT_HUD )
			// Remote_CallFunction_Replay(player, "ServerCallback_FSDM_ChampionScreenHandle", true, file.winnerTeam, 0)
		}
		//wait 7	
	// }
	
	foreach ( entity player in GetPlayerArray() )
	{
		if(!IsValid(player)) continue
		
		
	
		Remote_CallFunction_NonReplay(player, "PKKNOCKBACK_SetUIVisibility", false)
		
		// if(AllPlayers.len() >= 2 && AllPlayers[0].p.roundPlayerPoints == AllPlayers[1].p.roundPlayerPoints)
		// {
			// Message(player, "TIE", AllPlayers[0].GetPlayerName() + " and " + AllPlayers[1].GetPlayerName() + " were tied with " + GetChampion().p.roundPlayerPoints + " points.", 5, "")
			// wastie = true
		// }
		// else if(AllPlayers.len() > 0)
			// Message(player, "WINNER DECIDED", GetChampion().GetPlayerName() + " won this round with " + GetChampion().p.roundPlayerPoints + " points.", 5, "")
	}

	// wait 4	

	foreach(player in GetPlayerArray() )
	{
		if(!IsValid(player)) continue
		
		ScreenCoverTransition_Player(player, Time() + 1)
	}
	
	wait 0.2
	
	foreach(player in GetPlayerArray() )
	{
		if(!IsValid(player)) continue
		
		RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD_INSTANT )
		RemoveCinematicFlag( player, CE_FLAG_HIDE_PERMANENT_HUD )
	}
	
	file.currentRound++
	
	UpdatePlayerCounts()
	// Deathfield_Destroy()
}

void function _HandleRespawn(entity player)
{
	if(!IsValid(player)) return

	try{
		if(player.p.isSpectating)
		{
			player.p.isSpectating = false
			player.SetPlayerNetInt( "spectatorTargetCount", 0 )
			player.SetSpecReplayDelay( 0 )
			player.SetObserverTarget( null )
			player.StopObserverMode()
			Remote_CallFunction_NonReplay(player, "ServerCallback_KillReplayHud_Deactivate")
		}
	}catch(e420){}

	if(!IsAlive(player)) 
	{
		DecideRespawnPlayer(player, true)
	}
	
	ItemFlavor playerCharacter = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_CharacterClass() )
	asset characterSetFile = CharacterClass_GetSetFile( playerCharacter )
	player.SetPlayerSettingsWithMods( characterSetFile, [] )
	
	player.UnforceStand()
	player.UnfreezeControlsOnServer()
	
	player.SetPlayerNetBool( "pingEnabled", true )
	player.SetHealth( 100 )
	player.SetMoveSpeedScale(1)
	TakeAllWeapons(player)
	player.MovementEnable()
	Survival_SetInventoryEnabled( player, false )
}

void function AssignCharacter( entity player, int index )
{
	ItemFlavor PersonajeEscogido = GetAllCharacters()[index]
	CharacterSelect_AssignCharacter( ToEHI( player ), PersonajeEscogido )		
	
	ItemFlavor playerCharacter = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_CharacterClass() )
	asset characterSetFile = CharacterClass_GetSetFile( playerCharacter )
	player.SetPlayerSettingsWithMods( characterSetFile, [] )

	TakeAllWeapons(player)
}

void function PkKnockback_OnPlayerDamaged( entity victim, var damageInfo )
{
	if ( !IsValid( victim ) || !victim.IsPlayer() || Bleedout_IsBleedingOut( victim ) )
		return

	entity weapon               = DamageInfo_GetWeapon( damageInfo )
	entity attacker 			= DamageInfo_GetAttacker( damageInfo )
	entity inflictor 			= DamageInfo_GetInflictor( damageInfo )
	float damage				= DamageInfo_GetDamage( damageInfo )
	int damageSourceId 			= DamageInfo_GetDamageSourceIdentifier( damageInfo )
	float distance              = Distance( attacker.GetOrigin() , victim.GetOrigin() )
	
	vector damageOrigin = GetDamageOrigin( damageInfo, victim )
	
	if(!attacker.IsPlayer()) return

	victim.e.lastAttacker = attacker
	UpdateLastDamageTime(victim)

	entity meleeweapon = GetPlayerMeleeAttackWeapon(attacker)
	
	//if(IsValid(weapon) && IsValid(meleeweapon))
		//printt(weapon.GetWeaponClassName(), damage, meleeweapon.GetWeaponClassName())
	
	if(IsValid(meleeweapon) && meleeweapon.GetWeaponClassName() == "melee_boxing_ring" && meleeweapon == attacker.GetActiveWeapon( eActiveInventorySlot.mainHand ))
	{
		//printt("was melee")
		damage = 50
	}
	
	for(int i = 0; i < attacker.p.ampedDamageBonus; i++) //esto es una sumatoria
	{
		damage += damage*0.10
		damage = RoundToNearestInt(damage)	
	}
	
	if(victim.IsMantling())
		victim.ClearTraverse()
	
	victim.Zipline_Stop()

	DamageInfo_SetDamage( damageInfo, 0 )
	
	victim.KnockBack( Vector(0,0,4) + victim.GetVelocity() + attacker.GetViewForward() * 7 * damage, 0.6 ) //*max(1,attacker.p.ampedDamageBonus)
	
	Remote_CallFunction_NonReplay( attacker, "ShowDamageFlyout", victim, damage )
	
	Remote_CallFunction_Replay(
		victim,
		"ServerCallback_PlayerTookDamage",

		damage,

		damageOrigin.x,
		damageOrigin.y,
		damageOrigin.z,

		DF_BYPASS_SHIELD | DF_DOOMED_HEALTH_LOSS,
		damageSourceId,

		null
	)
	
	//actual knockback with 0.5 duration

	thread function() : (victim)
	{
		victim.MovementDisable()
		wait 0.6
		if(IsValid(victim))
			victim.MovementEnable()
	}()	
}

void function _RegisterLocationPK(LocationSettings locationSettings)
{
    file.locationSettings.append(locationSettings)
}

void function CheckDistanceWhileInLobby(entity player)
{
	EndSignal(player, "EndLobbyDistanceThread")
	
	while(IsValid(player))
	{
		if(Distance(player.GetOrigin(),file.lobbyLocation)>2000)
		{
			player.SetVelocity(Vector(0,0,0))
			player.SetOrigin(file.lobbyLocation)
		}
		WaitFrame()
	}	
}

void function StartSpectatingPkKnockback( entity player, entity attacker )
{	
	array<entity> clientTeam = GetPlayerArrayOfTeam_Alive( player.GetTeam() )
	clientTeam.fastremovebyvalue( player )

	bool isAloneOrSquadEliminated = clientTeam.len() == 0
	
	entity specTarget = null

	if ( IsValid(attacker) )
	{
		if ( attacker == player ) return;
		if ( attacker == null ) return;
		if ( !IsValid( attacker ) || !IsAlive( attacker ) ) return;
		
		specTarget = attacker;
	}
	else if ( isAloneOrSquadEliminated )
	{
		array<entity> alivePlayers = GetPlayerArray_Alive()
		if ( alivePlayers.len() > 0 )
			specTarget = alivePlayers.getrandom()
		else
			return
	}
	else
		specTarget = clientTeam.getrandom()

	if( IsValid( specTarget ) && ShouldSetObserverTarget( specTarget ) && !IsAlive( player ) )
	{
		player.SetPlayerNetInt( "spectatorTargetCount", GetPlayerArrayOfTeam_Alive( specTarget.GetTeam() ).len() )
		player.SetSpecReplayDelay( 1 )
		player.StartObserverMode( OBS_MODE_IN_EYE )
		player.SetObserverTarget( specTarget )
		Remote_CallFunction_NonReplay(player, "ServerCallback_KillReplayHud_Activate")
		player.p.isSpectating = true
	}
}

// purpose: display the UI for randomization of tied maps at the end of voting
void function RandomizeTiedLocations(array<int> maps)
{
    bool donerandomizing = false
    int randomizeammount = RandomIntRange(50, 75)
    int i = 0
    int mapslength = maps.len()
    int currentmapindex = 0
    int selectedamp = 0

    while (!donerandomizing)
    {
        // If currentmapindex is out of range set to 0
        if (currentmapindex >= mapslength)
            currentmapindex = 0

        // Update Randomizer ui for each player
        foreach( player in GetPlayerArray() )
        {
            if( !IsValid( player ) )
                continue

            Remote_CallFunction_Replay(player, "ServerCallback_FSDM_SetScreen", eFSDMScreen.TiedScreen, 69, maps[currentmapindex], 0)
        }

        // stop randomizing once the randomize ammount is done
        if (i >= randomizeammount)
        {
            donerandomizing = true
            selectedamp = currentmapindex
        }

        i++
        currentmapindex++

        if (i >= randomizeammount - 15 && i < randomizeammount - 5) // slow down voting randomizer speed
        {
            wait 0.15
        }
        else if (i >= randomizeammount - 5) // slow down voting randomizer speed
        {
            wait 0.25
        }
        else // default voting randomizer speed
        {
            wait 0.05
        }
    }

    // Show final selected map
    foreach( player in GetPlayerArray() )
    {
        if( !IsValid( player ) )
            continue

        Remote_CallFunction_Replay(player, "ServerCallback_FSDM_SetScreen", eFSDMScreen.TiedScreen, 69, maps[selectedamp], 1)
    }

    // Pause on selected map for a sec for visuals
    wait 0.5

    // Procede to final location picked screen
    foreach( player in GetPlayerArray() )
    {
        if( !IsValid( player ) )
            continue

        Remote_CallFunction_Replay(player, "ServerCallback_FSDM_SetScreen", eFSDMScreen.SelectedScreen, 69, maps[selectedamp], eFSDMScreen.NotUsed)
    }

    // Set selected location on server
    file.mappicked = maps[selectedamp]
}

void function ResetMapVotes()
{
    file.mapVotes.clear()
    file.mapVotes.resize( NUMBER_OF_MAP_SLOTS_FSDM )
}

void function HandleRingFlares(vector center)
{	
	OnThreadEnd(
		function() : ( )
		{
			foreach(ring in file.ringFlares) //destroy all in-movement ring flares
				if(IsValid(ring))
					ring.Destroy()
			
			file.ringFlares.clear()
		}
	)
	
	vector nextpos
	float maxdistance
	float lastangle = 0
	bool shouldcontinue = true
	int tries = 0
	int maxamount
	
	// if(ReturnSelectedLocationName() == "Shipment")
		// maxamount = 4
	// else
		maxamount = 7
	
	while( GetGameState() == eGameState.Playing )
	{
		wait 0.1
		
		foreach(ring in file.ringFlares)
		{
			if(!IsValid(ring)) 
				file.ringFlares.removebyvalue(ring)
		}
		
		if(file.ringFlares.len() == maxamount)
			continue
		
		if(SURVIVAL_GetDeathFieldCurrentRadius() <= 550) break
		
		for (int j = 0; j < 1 && tries <= 50; j++)
        {
			if( GetGameState() != eGameState.Playing ) break
			
			if(SURVIVAL_GetDeathFieldCurrentRadius() <= 550) break
			
			maxdistance = max(0, SURVIVAL_GetDeathFieldCurrentRadius()-500) //don't spawn ring flares on the borders
			
			if(maxdistance == 0) //threshold reached, break this
				break
			
			if(ReturnSelectedLocationName() == "Shipment")
			{
				nextpos = GetRandomCenter( center, 500, maxdistance, lastangle % 360, lastangle + 45 % 360)
				nextpos.z = 250
			}
			else
				nextpos = SURVIVAL_FindRing( GetRandomCenter( center, 500, maxdistance, lastangle % 360, lastangle + 45 % 360) )
			
			lastangle+=45
			
			shouldcontinue = false
			foreach(ring in file.ringFlares)
			{
				if(!IsValid(ring)) 
				{
					file.ringFlares.removebyvalue(ring)
					continue
				}
				
				if(shouldcontinue)
					continue
				
				if(Distance2D( ring.GetOrigin(), nextpos ) <= 2000) // to make nextpos valid it should be 2000 units away from other ring flares
				{
					// printt("ring flare too near, finding ring flare location. | Tries: " + tries + ". Colombia")
					tries++
					j-- //makes the for loop repeat
					shouldcontinue = true
					WaitFrame()
				}
			}
		
			if(shouldcontinue)
				continue
			
			foreach(boostZone in file.boostZones)
			{
				if(!IsValid(boostZone)) 
				{
					file.boostZones.removebyvalue(boostZone)
					continue
				}
				
				if(shouldcontinue)
					continue
				
				if(Distance2D( boostZone.GetOrigin(), nextpos ) <= 500) // to make nextpos valid it should be 2000 units away from other boost zones
				{
					// printt("boostZone too near, finding Boost Zone location. | Tries: " + tries + ". Colombia")
					tries++
					j-- //makes the for loop repeat
					shouldcontinue = true
					WaitFrame()
				}
			}
			
			//no ring flares near, let's check for players 			
			foreach( player in GetPlayerArray_Alive() )
			{
				if(!IsValid(player))
					continue
				
				if(shouldcontinue)
					continue
				
				if(Distance2D( player.GetOrigin(), nextpos ) <= 300) // it should spawn at least 300 units away from players
				{
					// printt("player too near, finding ring flare location. | Tries: " + tries + ". Colombia")
					tries++
					j-- //makes the for loop repeat
					shouldcontinue = true
					WaitFrame()
				}
			}
		}
		
		if(tries <= 50)
		{
			RingFlareStart(OriginToGround(nextpos))
			tries = 0
		} else
		{
			// printt("couldn't find a location for next ring flare. Colombia")
			tries = 0
		}
	}
}

void function HandleBoostZones(vector center)
{	
	OnThreadEnd(
		function() : ( )
		{
			foreach(ring in file.boostZones) //destroy all in-movement boost zones
				if(IsValid(ring))
					ring.Destroy()
			
			file.boostZones.clear()
		}
	)
	
	vector nextpos
	float maxdistance
	float lastangle = 0
	bool shouldcontinue = true
	int tries = 0
	int maxamount = 6
	
	while( GetGameState() == eGameState.Playing)
	{
		wait 0.1
		
		foreach(ring in file.boostZones)
		{
			if(!IsValid(ring)) 
				file.boostZones.removebyvalue(ring)
		}
		
		if(file.boostZones.len() == maxamount)
			continue
		
		if(SURVIVAL_GetDeathFieldCurrentRadius() <= 550) break
		
		for (int j = 0; j < 1 && tries <= 200; j++)
        {
			if( GetGameState() != eGameState.Playing ) break
			
			if( SURVIVAL_GetDeathFieldCurrentRadius() <= 250 ) break
			
			maxdistance = max(0, SURVIVAL_GetDeathFieldCurrentRadius()-600) //don't spawn boost zones on the borders
			
			if(maxdistance == 0) //threshold reached, break this
				break
			
			if(ReturnSelectedLocationName() == "Shipment")
			{
				nextpos = GetRandomCenter( center, 1, 1400, lastangle % 360, lastangle + 20 % 360)
				nextpos.z = 250
			}
			else
				nextpos = SURVIVAL_FindRing( GetRandomCenter( center, 200, maxdistance, lastangle % 360, lastangle + 45 % 360) )
			
			lastangle+=20
			
			shouldcontinue = false
			foreach(ring in file.ringFlares)
			{
				if(!IsValid(ring)) 
				{
					file.ringFlares.removebyvalue(ring)
					continue
				}
				
				if(shouldcontinue)
					continue
				
				if(Distance2D( ring.GetOrigin(), nextpos ) <= 500) // to make nextpos valid it should be 2000 units away from other ring flares
				{
					// printt("ring flare too near, finding ring flare location. | Tries: " + tries + ". Colombia")
					tries++
					j-- //makes the for loop repeat
					shouldcontinue = true
					WaitFrame()
				}
			}
			
			if(shouldcontinue)
				continue
			
			foreach(boostZone in file.boostZones)
			{
				if(!IsValid(boostZone)) 
				{
					file.boostZones.removebyvalue(boostZone)
					continue
				}
				
				if(shouldcontinue)
					continue
				
				if(Distance2D( boostZone.GetOrigin(), nextpos ) <= 500) // to make nextpos valid it should be 2000 units away from other boost zones
				{
					// printt("boostZone too near, finding Boost Zone location. | Tries: " + tries + ". Colombia")
					tries++
					j-- //makes the for loop repeat
					shouldcontinue = true
					WaitFrame()
				}
			}
		
			if(shouldcontinue)
				continue
			
			//no ring flares near, let's check for players 			
			foreach( player in GetPlayerArray_Alive() )
			{
				if(!IsValid(player))
					continue
				
				if(shouldcontinue)
					continue
				
				if(Distance2D( player.GetOrigin(), nextpos ) <= 50) // it should spawn at least 300 units away from players
				{
					// printt("player too near, finding Boost Zone location. | Tries: " + tries + ". Colombia")
					tries++
					j-- //makes the for loop repeat
					shouldcontinue = true
					WaitFrame()
				}
			}
		
			if(shouldcontinue)
				continue
			
			if(!VerifyAirdropPoint( nextpos, 0, true ) && ReturnSelectedLocationName() != "Shipment")
			{
				// printt("rejected by multiple traces, finding Boost Zone location. | Tries: " + tries + ". Colombia")
				tries++
				j--
			}
			//all checks passed, good pos
		}
		
		if(tries <= 200)
		{
			thread BoostZoneStart(nextpos)
			tries = 0
		} else
		{
			// printt("couldn't find a location for next boost zone. Colombia")
			tries = 0
		}
	}
}

void function BoostZoneStart(vector origin)
{
	if(ReturnSelectedLocationName() == "Shipment")
		origin.z = 250
	
	int type = RandomIntRangeInclusive(0,2)
	int radius = 128
	string color
	
	switch(type)
	{
		case 0: //damage boost
			color = "179, 21, 137"
		break
		
		case 1: //speed boost
			color = "179, 174, 21"
		break
		
		case 2: //rapid fire
			color = "179, 21, 60"
		break
	}
	
	entity circle = CreateEntity( "prop_script" )
	circle.SetValueForModelKey( $"mdl/dev/empty_model.rmdl" )
	circle.kv.fadedist = -1
	circle.kv.modelscale = radius
	circle.kv.renderamt = 25
	circle.kv.rendercolor = color
	circle.kv.solid = 6
	circle.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
	circle.SetOrigin( origin + Vector(0,0,20))
	circle.SetAngles( <0, 0, 0> )
	circle.Hide()
	circle.NotSolid()
	circle.DisableHibernation()
    circle.Minimap_SetObjectScale( radius / SURVIVAL_MINIMAP_RING_SCALE )
    circle.Minimap_SetAlignUpright( true )
    circle.Minimap_SetZOrder( 2 )
    circle.Minimap_SetClampToEdge( true )
    circle.Minimap_SetCustomState( eMinimapObject_prop_script.OBJECTIVE_AREA )
	SetTargetName( circle, "boostZone" )
	DispatchSpawn(circle)
	
	entity trigger = CreateEntity( "trigger_cylinder" )
	trigger.SetRadius( radius - 30 )
	trigger.SetAboveHeight( 64 )
	trigger.SetBelowHeight( 64 )
	trigger.SetOrigin( origin + Vector(0,0,64) )
	DispatchSpawn( trigger )
	trigger.SetParent(circle)
	trigger.SetEnterCallback( BoostZoneEnter )
	trigger.SetLeaveCallback( BoostZoneExit )
	trigger.SearchForNewTouchingEntity()
	
	array<entity> wps
	
	thread handleBoostZoneWaypoint(circle, type)
	
	entity circleVisual = CreateEntity( "prop_dynamic" )
	circleVisual.SetValueForModelKey( $"mdl/fx/ar_edge_sphere_512.rmdl" )
	circleVisual.kv.modelscale = 0.25
	circleVisual.SetOrigin( origin + Vector(0,0,10))
	circleVisual.SetAngles( <0, 0, 0> )
	circleVisual.kv.rendercolor = color
	DispatchSpawn(circleVisual)
		
	circleVisual.SetParent(circle)

	entity circleVisual2 = CreateEntity( "prop_dynamic" )
	circleVisual2.SetValueForModelKey( $"mdl/fx/plasma_sphere_01.rmdl" )
	circleVisual2.kv.modelscale = 3.1
	circleVisual2.SetOrigin( origin )
	circleVisual2.SetAngles( <0, 0, 0> )
	circleVisual2.kv.rendercolor = color
	DispatchSpawn(circleVisual2)
		
	circleVisual2.SetParent(circle)

    foreach ( player in GetPlayerArray() )
    {
        circle.Minimap_AlwaysShow( 0, player )
    }
	
	EndSignal(circle, "OnDestroy")
	file.boostZones.append(circle)
	
	thread HandleBoostZoneLerpColor(circle, circleVisual, circleVisual2, Time(), type)
	
   	OnThreadEnd(
		function() : ( type, radius, wps, circle )
		{
			foreach(wp in wps)
				if(IsValid(wp)) wp.Destroy()

			if(IsValid(circle)) circle.Destroy()

			//check for players inside here + add perks
			foreach ( player in GetPlayerArray_Alive() )
			{
				if(!IsValid(player)) continue
				
				float playerDist = Distance2D( player.GetOrigin(), circle.GetOrigin() )
				
				if ( playerDist < radius )
				{
					switch(type)
					{
						case 0: //damage boost
							if(player.p.ampedDamageBonus == BOOSTZONE_MAX_TIMES_GRAB_LIMIT)
							{
								Remote_CallFunction_NonReplay(player, "PKKNOCKBACK_CustomHint", 4, 0)
							} else
							{
								player.p.ampedDamageBonus = minint(player.p.ampedDamageBonus+1, BOOSTZONE_MAX_TIMES_GRAB_LIMIT)
							
								thread PlayEffectOnPlayerBoostZoneGrabbed(player, type)
								
								Remote_CallFunction_NonReplay(player, "PKKNOCKBACK_CustomHint", 1, 0)
								
								// foreach ( player2 in GetPlayerArray_Alive() )
								// {
									// Remote_CallFunction_NonReplay(player2, "PKKNOCKBACK_CustomHint", 2, player.GetEncodedEHandle())	
								// }
							}
						break
						
						case 1: //speed boost
							if(player.p.currentPlayerSpeed >= 1.5)
							{
								Remote_CallFunction_NonReplay(player, "PKKNOCKBACK_CustomHint", 6, 0)
							} else
							{
								player.p.currentPlayerSpeed = min(player.p.currentPlayerSpeed + player.p.currentPlayerSpeed*0.10,  1.5)
								
								player.SetMoveSpeedScale(player.p.currentPlayerSpeed)
								
								thread PlayEffectOnPlayerBoostZoneGrabbed(player, type)

								Remote_CallFunction_NonReplay(player, "PKKNOCKBACK_CustomHint", 8, 0)
								
								// foreach ( player2 in GetPlayerArray_Alive() )
								// {
									// Remote_CallFunction_NonReplay(player2, "PKKNOCKBACK_CustomHint", 2, player.GetEncodedEHandle())	
								// }
							}
						break
						
						case 2: //rapid fire
							if(player.p.ampedFireRateBonus == FIREZONE_MAX_TIMES_GRAB_LIMIT)
							{
								Remote_CallFunction_NonReplay(player, "PKKNOCKBACK_CustomHint", 7, 0)
							} else
							{
								player.p.ampedFireRateBonus = minint(player.p.ampedFireRateBonus+1, BOOSTZONE_MAX_TIMES_GRAB_LIMIT)

								array<entity> weapons = player.GetMainWeapons()
								foreach ( weapon in weapons )
								{
									if(weapon.GetWeaponClassName() == "mp_weapon_energy_shotgun")
									{
										if(weapon.HasMod("pushback_fireboost_l1"))
											weapon.RemoveMod( "pushback_fireboost_l1" )
										
										if(weapon.HasMod("pushback_fireboost_l2"))
											weapon.RemoveMod( "pushback_fireboost_l2" )
										
										if(weapon.HasMod("pushback_fireboost_l3"))
											weapon.RemoveMod( "pushback_fireboost_l3" )

										switch(player.p.ampedFireRateBonus)
										{
											case 1:
												weapon.AddMod( "pushback_fireboost_l1" )
											break
											
											case 2:
												weapon.AddMod( "pushback_fireboost_l2" )
											break
											
											case 3:
												weapon.AddMod( "pushback_fireboost_l3" )
											break
										}
									}									
								}
								
								thread PlayEffectOnPlayerBoostZoneGrabbed(player, type)

								Remote_CallFunction_NonReplay(player, "PKKNOCKBACK_CustomHint", 9, 0)
								
								// foreach ( player2 in GetPlayerArray_Alive() )
								// {
									// Remote_CallFunction_NonReplay(player2, "PKKNOCKBACK_CustomHint", 2, player.GetEncodedEHandle())	
								// }
							}
						break
					}

				}
			}
		}
	) 
	
	wait BOOSTZONE_ALIVE_TIME
}

void function PlayEffectOnPlayerBoostZoneGrabbed( entity player, int type)
{
	try{
	int shieldbodyFX = GetParticleSystemIndex( $"P_armor_body_CP" )
	int attachID = player.LookupAttachment( "CHESTFOCUS" )
	
	entity ColoredFX = StartParticleEffectOnEntity_ReturnEntity( player, shieldbodyFX, FX_PATTACH_POINT_FOLLOW, attachID )

	vector color
	
	switch(type)
	{
		case 0:
			color = Vector(0, 179, 255)
		break
		
		case 1:
			color = Vector(230, 0, 255)
		break
		
		case 2: 
			color = Vector(221, 255, 0)
		break
	}
	
	EffectSetControlPointVector( ColoredFX, 1, color )
	}catch(e420){}
}

void function BoostZoneEnter(entity trigger, entity ent)
{
	if(!ent.IsPlayer()) return
	
	StatusEffect_AddEndless( ent, eStatusEffect.damageAmpFXOnly, 0.2 )
	
	thread function() : (trigger, ent)
	{
		EndSignal( trigger, "OnDestroy" )
		EndSignal( ent, "OnDestroy" )
		EndSignal( ent, "OnDeath" )
	
		while( IsValid(trigger) && IsValid(ent) && trigger.IsTouching( ent ) && GetGameState() == eGameState.Playing )
		{
			wait 3.1
			
			if( !IsValid(trigger) || !IsValid(ent) || !trigger.IsTouching( ent ) || GetGameState() != eGameState.Playing) break
			
			if(Time() > ent.p.lastTimeGrabberBoostZonePoints + 3)
			{
				Remote_CallFunction_NonReplay(ent, "PKKNOCKBACK_CustomHint", 5, 0)
				ent.p.roundPlayerPoints+=3
				ent.p.lastTimeGrabberBoostZonePoints = Time()
			}
		}
	}()
}

void function BoostZoneExit(entity trigger, entity ent)
{
	if(!ent.IsPlayer()) return
	
	StatusEffect_StopAllOfType( ent, eStatusEffect.damageAmpFXOnly)
}

void function HandleBoostZoneLerpColor(entity circle, entity visual1, entity visual2, float startTime, int type)
{
	EndSignal(circle, "OnDestroy")
	
	float endTime = startTime + BOOSTZONE_ALIVE_TIME
	float frac

	while(Time() < endTime)
	{
		frac = Time() / endTime
		visual1.kv.rendercolor = GetBoostZoneTriLerpColor( frac, type )
		visual2.kv.rendercolor = GetBoostZoneTriLerpColor( frac, type )
		WaitFrame()
	}
}

vector function GetBoostZoneTriLerpColor( float frac, int type)
{
	vector color1
	vector color2
	vector color3 = Vector(255, 255, 255)

	switch(type)
	{
		case 0:
			color1 = Vector(0, 179, 255)
			color2 = Vector(0, 179, 255)
		break
		
		case 1:
			color1 = Vector(230, 0, 255)
			color2 = Vector(230, 0, 255)
		break
		
		case 2: 
			color1 = Vector(221, 255, 0)
			color2 = Vector(221, 255, 0)
		break
	}
	
	return GetTriLerpColor( frac, color1, color2, color3, 0.94, 0.99 )
}

void function handleBoostZoneWaypoint(entity circle, int type)
{
	if( !IsValid(circle) ) return
	
	EndSignal(circle, "OnDestroy")
	
	array<entity>  wp
	
	OnThreadEnd(
		function() : ( wp )
		{
			foreach(waypoint in wp)	
			{
				if(IsValid(waypoint)) 
				{
					waypoint.Destroy()
					wp.removebyvalue(waypoint)
				}
			}
		}
	)
	int pingType 
	
	switch(type)
	{
		case 0: //damage boost
			pingType = ePingType.BOOSTZONE
		break
		
		case 1: //speed boost
			pingType = ePingType.SPEEDZONE
		break
		
		case 2: //rapid fire
			pingType = ePingType.RAPIDFIREZONE
		break
	}
	
	foreach(sPlayer in GetPlayerArray_Alive())
	{
		if(!IsValid(sPlayer)) continue
		entity waypoint = CreateWaypoint_Test( sPlayer, pingType, circle.GetOrigin(), -1, false)
		waypoint.SetWaypointGametime( 0, Time() + BOOSTZONE_ALIVE_TIME )
		wp.append(waypoint)
	}
	
	wait BOOSTZONE_ALIVE_TIME
}

void function RingFlareStart(vector origin)
{
	if(ReturnSelectedLocationName() == "Shipment")
		origin.z = 250
	
	entity circle = CreateEntity( "prop_script" )
	circle.SetValueForModelKey( $"mdl/dev/empty_model.rmdl" )
	circle.kv.fadedist = -1
	circle.kv.renderamt = 255
	circle.kv.rendercolor = "235, 110, 52"
	circle.kv.solid = 0
	circle.SetOrigin( origin )
	circle.SetAngles( <0, 0, 0> )
	circle.NotSolid()
	circle.DisableHibernation()
    circle.Minimap_SetObjectScale( 1 / SURVIVAL_MINIMAP_RING_SCALE )
    circle.Minimap_SetAlignUpright( true )
    circle.Minimap_SetZOrder( 2 )
    circle.Minimap_SetClampToEdge( true )
    circle.Minimap_SetCustomState( eMinimapObject_prop_script.OBJECTIVE_AREA )
	SetTargetName( circle, "ringFlare" )
	DispatchSpawn(circle)
    
    foreach ( player in GetPlayerArray() )
    {
        circle.Minimap_AlwaysShow( 0, player )
    }
	
	file.ringFlares.append(circle)
	
	printt("Ring Flare spawned! at " + origin)
	entity fx = StartParticleEffectOnEntity_ReturnEntity(circle, GetParticleSystemIndex( $"P_survival_radius_CP_1x100" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
	fx.kv.fadedist = 9999
	fx.SetParent(circle)

	thread IncreaseSizeOverTimeAndDoDamage(circle, fx)
	foreach(player in GetPlayerArray_Alive())
	{
		if(!IsValid(player)) continue
		thread AudioThread(circle, player)
	}
}

void function AudioThread(entity circle, entity player)
{
	EndSignal(circle, "OnDestroy")
	
	entity audio
	string soundToPlay = "Survival_Circle_Edge_Small_Movement"
	
	OnThreadEnd(
		function() : ( soundToPlay, audio)
		{
			
			if(IsValid(audio)) audio.Destroy()
		}
	)
	
	audio = CreateScriptMover()
	audio.SetOrigin( circle.GetOrigin() )
	audio.SetAngles( <0, 0, 0> )
	EmitSoundOnEntity( audio, soundToPlay )
	
	while(IsValid(circle) && IsValid(player)){
			vector fwdToPlayer   = Normalize( <player.GetOrigin().x, player.GetOrigin().y, 0> - <circle.GetOrigin().x, circle.GetOrigin().y, 0> )
			vector circleEdgePos = circle.GetOrigin() + (fwdToPlayer * RINGFLARE_MAX_RADIUS)
			circleEdgePos.z = player.EyePosition().z
			if ( fabs( circleEdgePos.x ) < 61000 && fabs( circleEdgePos.y ) < 61000 && fabs( circleEdgePos.z ) < 61000 )
			{
				audio.SetOrigin( circleEdgePos )
			}
		WaitFrame()
	}
	
	StopSoundOnEntity(audio, soundToPlay)
}

void function IncreaseSizeOverTimeAndDoDamage(entity circle, entity fx)
{
	if( !IsValid( circle ) ) return

	EndSignal(circle, "OnDestroy")

	OnThreadEnd(
		function() : (circle, fx)
		{
			foreach ( player in GetPlayerArray() )
			{
				if(IsValid(circle))
					circle.Minimap_Hide( 0, player )
			}
			
			if(IsValid(circle))
				circle.Destroy()
			
			if(IsValid(fx))
				fx.Destroy()
		}
	)

	float radius = 1
	bool startreversal = false
	float waitTime = Time() + 1.5
	
	while(true)
	{
		WaitFrame()
		
		if(Time() >= waitTime)
		{
			foreach ( player in GetPlayerArray_Alive() )
			{
				if(!IsValid(player)) continue
				
				float playerDist = Distance2D( player.GetOrigin(), circle.GetOrigin() )
				
				if ( playerDist < radius )
				{
					if(IsValid(player.e.lastAttacker))
						player.Die( player.e.lastAttacker, player.e.lastAttacker, { damageSourceId = eDamageSourceId.mp_weapon_energy_shotgun } )
					else
						player.Die( null, null, { damageSourceId = eDamageSourceId.deathField } )
				}
			}
		}

		if(radius < RINGFLARE_MAX_RADIUS && !startreversal)
			radius += RINGFLARE_GROWTH_SPEED
		else 
			startreversal = true
		
		if(radius > 0 && startreversal)
			radius -= RINGFLARE_REDUCESIZE_SPEED

		if(radius <= 0 && startreversal)
			break
	

	    EffectSetControlPointVector( fx, 1, <radius, 0, 0> )
		circle.Minimap_SetObjectScale( min(max(0, radius / SURVIVAL_MINIMAP_RING_SCALE ), 1) )
	}
}

bool function ClientCommand_NextRoundPKKNOCKBACK(entity player, array<string> args)
{
	if( !IsValid(player) ) return false

	SetGameState(eGameState.MapVoting)
	return true
}

bool function ClientCommand_AskRingSize(entity player, array<string> args)
{
	if(!IsValid(player)) return false
	
	Remote_CallFunction_NonReplay(player, "UpdateRingSizeFromServer", SURVIVAL_GetDeathFieldCurrentRadius())	
	return true 
}
bool function ClientCommand_TestPos(entity player, array<string> args)
{
	if(!IsValid(player)) return false
	
	player.SetOrigin(ReturnCenterOfSelectedLocation())
	return true 
}

bool function ClientCommand_VoteForMap(entity player, array<string> args)
{
	if(!IsValid(player)) return false
	
    // don't allow multiple votes
    if ( file.votedPlayers.contains( player ) )
        return false

    // dont allow votes if its not voting time
    if ( !file.votingtime )
        return false

    // get map id from args
    int mapid = args[0].tointeger()

    // reject map ids that are outside of the range
    if ( mapid >= NUMBER_OF_MAP_SLOTS_FSDM || mapid < 0 )
        return false

    // add a vote for selected maps
    file.mapVotes[mapid]++

    // update current amount of votes for each map
    foreach( p in GetPlayerArray() )
    {
        if( !IsValid( p ) )
            continue

        Remote_CallFunction_Replay(p, "ServerCallback_FSDM_UpdateMapVotesClient", file.mapVotes[0], file.mapVotes[1], file.mapVotes[2], file.mapVotes[3])
    }

    // append player to the list of players the voted so they cant vote again
    file.votedPlayers.append(player)

    return true
}

int function ComparePlayerInfo_Knockbacks(entity a, entity b)
{
	if(a.p.roundPlayerPoints < b.p.roundPlayerPoints) 
		return 1
	else if(a.p.roundPlayerPoints > b.p.roundPlayerPoints) 
		return -1
	
	return 0
}

int function ComparePlayerInfo_TotalPoints_Knockbacks(entity a, entity b)
{
	if(a.p.totalpoints < b.p.totalpoints) 
		return 1
	else if(a.p.totalpoints > b.p.totalpoints) 
		return -1
	
	return 0
}

vector function SURVIVAL_FindRing( vector center )
{
	bool foundSpot = false

	int numTries      = 0
	int timesToTry    = 20
	float radius      = 500
	float minDistance = 500

	while ( !foundSpot )
	{
		if ( numTries > timesToTry )
		{
			numTries = 0
			radius += 200.0
			if ( radius > 5000.0 )
			{
				radius = 5000.0
			}
		}

		vector startPos = GetRandomCenter( center, minDistance, radius, 0.0, 360.0 )

		vector maxs          = <1000,1000,1000>//bigger than model to compensate for large effect
		vector mins          = <1000,1000,1000>
		TraceResults trace   = TraceHull( <startPos.x, startPos.y, 10000>, <startPos.x, startPos.y, -10000>, mins, maxs, null, TRACE_MASK_TITANSOLID, TRACE_COLLISION_GROUP_NONE )
		vector ornull endPos = NavMesh_ClampPointForHullWithExtents( trace.endPos + <0, 0, 10>, HULL_TITAN, <1000,1000,1000>)

		if ( endPos != null )
		{
			vector pos = expect vector( endPos )

			trace = TraceHull( pos + <0, 0, 2000>, pos, mins, maxs, null, TRACE_MASK_TITANSOLID, TRACE_COLLISION_GROUP_NONE )
			return OriginToGround(trace.endPos)
		}

		numTries++
		WaitFrame()
	}

	unreachable
}