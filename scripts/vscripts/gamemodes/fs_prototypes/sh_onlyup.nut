 // █████╗ ██████╗ ███████╗██╗  ██╗     ██████╗ ███╗   ██╗██╗  ██╗   ██╗    ██╗   ██╗██████╗                           
// ██╔══██╗██╔══██╗██╔════╝╚██╗██╔╝    ██╔═══██╗████╗  ██║██║  ╚██╗ ██╔╝    ██║   ██║██╔══██╗                          
// ███████║██████╔╝█████╗   ╚███╔╝     ██║   ██║██╔██╗ ██║██║   ╚████╔╝     ██║   ██║██████╔╝                          
// ██╔══██║██╔═══╝ ██╔══╝   ██╔██╗     ██║   ██║██║╚██╗██║██║    ╚██╔╝      ██║   ██║██╔═══╝                           
// ██║  ██║██║     ███████╗██╔╝ ██╗    ╚██████╔╝██║ ╚████║███████╗██║       ╚██████╔╝██║                               
// ╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝     ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚═╝        ╚═════╝ ╚═╝                               
                                                                                                                    
// ███╗   ███╗ █████╗ ██████╗ ███████╗    ██████╗ ██╗   ██╗     ██████╗ █████╗ ███████╗███████╗███████╗██████╗ ███████╗
// ████╗ ████║██╔══██╗██╔══██╗██╔════╝    ██╔══██╗╚██╗ ██╔╝    ██╔════╝██╔══██╗██╔════╝██╔════╝██╔════╝██╔══██╗██╔════╝
// ██╔████╔██║███████║██║  ██║█████╗      ██████╔╝ ╚████╔╝     ██║     ███████║█████╗  █████╗  █████╗  ██████╔╝███████╗
// ██║╚██╔╝██║██╔══██║██║  ██║██╔══╝      ██╔══██╗  ╚██╔╝      ██║     ██╔══██║██╔══╝  ██╔══╝  ██╔══╝  ██╔═══╝ ╚════██║
// ██║ ╚═╝ ██║██║  ██║██████╔╝███████╗    ██████╔╝   ██║       ╚██████╗██║  ██║██║     ███████╗██║     ██║     ███████║
// ╚═╝     ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝    ╚═════╝    ╚═╝        ╚═════╝╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝     ╚═╝     ╚══════╝

#if SERVER
global function OnlyUp_Init
global function DEV_RegenerateOnlyUpMap

global const float PLAYER_JUMP_DISTANCE = 56 //231 /// Max horizontal jump capability from calculations
// global const float PLATFORM_SPACING = 165.2 // sqrt(pow(PLAYER_JUMP_DISTANCE, 2) - pow(horizontalRange, 2))

global const int MAX_PLATFORMS = 300 // Max active platforms
global const float MAX_PITCH = 30
global const float MAX_YAW = 360
global const float MAX_ROLL = 15
const int MAX_MODEL_HISTORY = 3 // Prevent same model in last X platforms
vector startPos = <34200, -49000, -7700>
	
array<asset> PLATFORM_MODELS = [
	$"mdl/containers/underbelly_cargo_container_128_red_02.rmdl",
	$"mdl/desertlands/desertlands_plantroom_rack_02.rmdl",
	$"mdl/playback/playback_staircase_128_top_double_01_a.rmdl"
	$"mdl/desertlands/research_station_container_big_01.rmdl",
	$"mdl/IMC_base/cargo_container_imc_01_white_open.rmdl",
	$"mdl/industrial/cafe_coffe_machine.rmdl",
	// $"mdl/vehicles_r5/land/msc_truck_mod_lrg/veh_land_msc_truck_mod_police_lrg_01_closed_static.rmdl"
	
	$"mdl/vehicles_r5/land/msc_suv_partum/veh_land_msc_suv_partum_static.rmdl",
	$"mdl/vehicles_r5/land/msc_forklift_imc_v2/veh_land_msc_forklift_imc_v2_static.rmdl",
	$"mdl/IMC_base/cargo_container_imc_01_blue.rmdl",
	$"mdl/colony/farmland_domicile_table_02.rmdl",
	$"mdl/beacon/construction_scaff_128_64_128_02.rmdl",
	$"mdl/desertlands/desertlands_city_slanted_building_01_wall_64.rmdl",
	$"mdl/props/death_box/death_box_01.rmdl",
	$"mdl/containers/underbelly_cargo_container_128_blue_02.rmdl",
	$"mdl/industrial/landing_mat_metal_03_large.rmdl"
	$"mdl/colony/farmland_crate_md_80x64x72_03.rmdl" ,
	$"mdl/industrial/traffic_cone_01.rmdl",
	$"mdl/containers/container_medium_tanks_blue.rmdl",
	$"mdl/industrial/construction_materials_cart_03.rmdl"
	
	//bad props dont use
	
	// $"mdl/desertlands/industrial_cargo_container_large_01.rmdl",
	// $"mdl/desertlands/industrial_cargo_container_small_02.rmdl",
	// $"mdl/desertlands/industrial_cargo_container_small_01.rmdl",
	// // $"mdl/desertlands/industrial_cargo_container_small_01.rmdl",
	// $"mdl/levels_terrain/mp_rr_canyonlands/cage_interior_pillar_01.rmdl",
	// $"mdl/thunderdome/thunderdome_cage_ceiling_256x64_01.rmdl",
	// $"mdl/desertlands/fence_large_concrete_metal_dirty_128_01.rmdl",
	// $"mdl/desertlands/wall_city_panel_concrete_192_01.rmdl",
	// $"mdl/pipes/slum_pipe_large_blue_512_01.rmdl",
	// $"mdl/pipes/slum_pipe_large_yellow_512_01.rmdl",
	// $"mdl/desertlands/research_station_small_building_floor_01.rmdl",	
	// $"mdl/colony/farmland_wall_128x064x16_metal_01b.rmdl",
	// $"mdl/containers/lagoon_roof_tanks_02.rmdl",
	// $"mdl/desertlands/industrial_cargo_container_320_01_open.rmdl",
	// $"mdl/desertlands/industrial_cargo_container_320_01.rmdl",
	// $"mdl/thaw/thaw_rock_horizontal_01.rmdl",
	// $"mdl/desertlands/research_station_stairs_bend_01.rmdl",
	// $"mdl/desertlands/research_station_stairs_corner_02.rmdl" ,
]

struct PlatformData {
	entity platform
	vector origin
	vector angles
	vector boundsMin
	vector boundsMax
	int id
	bool isCheckpoint = false
	int checkpointID = -1
}

struct CheckpointResult {
	vector origin
	bool isCheckpoint
}

struct {
	array<PlatformData> activePlatforms
	vector lastSpawnPos
	int currentPlatformCount = 0
	int nextPlatformId = 0
	entity safetyTrigger
	table<entity, int> playerHighScores = {}
	table<entity, int> playerFallCounts = {} // New fall counter table
	array<asset> modelHistory = []  // Track last used models
	table<entity, int> playerCheckpointIDs = {}
	int nextCheckpointID = 0
	table<entity, int> playerLives = {}
} file

void function OnlyUp_Init()
{
	foreach( model in PLATFORM_MODELS )
		PrecacheModel( model )
	
	PrecacheModel( $"mdl/thunderdome/thunderdome_cage_wall_256x256_01.rmdl" )
	PrecacheModel( $"mdl/thunderdome/thunderdome_spike_traps_large_128_01.rmdl" )
	PrecacheParticleSystem( $"P_s2s_flap_wind" )
	
	AddCallback_OnClientConnected(OnPlayerConnected)
	// AddCallback_OnPlayerRespawned(OnPlayerRespawned)
	AddCallback_EntitiesDidLoad(EntitiesDidLoad)
	AddCallback_OnPlayerKilled(OnPlayerKilled)
	
	RegisterSignal( "EndScriptedPropsThread" )
	file.lastSpawnPos = startPos
}
void function OnPlayerKilled(entity player, entity attacker, var attackerDamageInfo)
{
	if ( !IsValid( player ) )
		return
	
	player.SetPlayerNetInt( "respawnStatus", eRespawnStatus.WAITING_FOR_DROPPOD )
	player.SetPlayerNetTime( "respawnStatusEndTime", Time() + 4.0 )
	Remote_CallFunction_NonReplay( player, "ServerCallback_DisplayWaitingForRespawn", player, Time(), player.GetPlayerNetTime( "respawnStatusEndTime" ) )
	Remote_CallFunction_ByRef( player, "ServerCallback_ShowDeathScreen" )
	
	thread RespawnPlayerAtStart(player)
}
void function DEV_RegenerateOnlyUpMap()
{
	for (int i = file.activePlatforms.len() - 1; i >= 0; i--)
	{
		if(i==0)
			continue
		
		file.activePlatforms[i].platform.Destroy()
		file.activePlatforms.remove(i)
	}

	// Reset both tracking tables
	file.playerHighScores.clear()
	file.playerFallCounts.clear()

	// Reset all player progress
	file.playerLives.clear()
	
	// file.activePlatforms.clear()
	file.currentPlatformCount = 1
	file.lastSpawnPos = file.activePlatforms[0].platform.GetOrigin() //<34200, -49000, -7700>
	file.nextPlatformId = 1
	
	foreach(player in GetPlayerArray())
		ShowHighScoreMessage(player)
	
	thread GenerateProceduralMap()
}

void function EntitiesDidLoad()
{
	Flowstate_CheckForMapTriggersRemoval( true ) //destroy all map triggers

	thread CreateRegenerateMapButton()
	thread GenerateProceduralMap()
}

void function GenerateProceduralMap()
{
	CreateSafetyTrigger()
	
	while(true)
	{
		if(file.currentPlatformCount < MAX_PLATFORMS)
		{
			PlatformData platform = CreatePlatform()
			file.activePlatforms.append(platform)
			file.currentPlatformCount++
			
			CleanupPlatforms()
		}
		WaitFrame()
	}
}

PlatformData function CreatePlatform()
{
	// Random platform selection
	// asset model = PLATFORM_MODELS[RandomInt(PLATFORM_MODELS.len())]
	asset model
	int safetyCounter = 0
	bool validModelFound = false
	
	// Generate full 3D rotation
	vector angles = <RandomFloatRange(-MAX_PITCH, MAX_PITCH),
					RandomFloatRange(-MAX_YAW, MAX_YAW),
					RandomFloatRange(-MAX_ROLL, MAX_ROLL)> 
					
	if( file.currentPlatformCount == 0 )
	{
		model = $"mdl/industrial/landing_mat_metal_03_large.rmdl"
		angles = <0,0,0>
		file.modelHistory.append(model)
	} else
	{
		// Model selection with repetition prevention
		while(!validModelFound && safetyCounter < 50)
		{
			// Create candidate list excluding recent models
			array<asset> candidates = []
			foreach(m in PLATFORM_MODELS)
			{
				if(!file.modelHistory.contains(m))
					candidates.append(m)
			}
			
			// Allow any model if all are in history
			if(candidates.len() == 0)
				candidates = PLATFORM_MODELS
			
			model = candidates[RandomInt(candidates.len())]
			
			// Validate not in recent history
			if(!file.modelHistory.contains(model))
				validModelFound = true
				
			safetyCounter++
		}
		
		// Update model history
		file.modelHistory.append(model)
		if(file.modelHistory.len() > MAX_MODEL_HISTORY)
			file.modelHistory.remove(0)
	}
	
	// Create temporary platform for calculations
	entity tempPlatform = CreatePropDynamic(model, <0,0,0>, angles, 0)
	vector mins = tempPlatform.GetBoundingMins()
	vector maxs = tempPlatform.GetBoundingMaxs()
 	
	bool isKillerWalls
	if( model == $"mdl/industrial/landing_mat_metal_03_large.rmdl" && CoinFlip() && file.currentPlatformCount != 0 )
	{
		isKillerWalls = true
		angles = <0,0,0>
	}   
	// Calculate all local corners
	array<vector> localCorners = [
		mins,
		<maxs.x, mins.y, mins.z>,
		<maxs.x, maxs.y, mins.z>,
		<mins.x, maxs.y, mins.z>,
		<mins.x, mins.y, maxs.z>,
		<maxs.x, mins.y, maxs.z>,
		<maxs.x, maxs.y, maxs.z>,
		<mins.x, maxs.y, maxs.z>
	]
	
	// Transform corners to world space
	vector rightVec = tempPlatform.GetRightVector()
	vector fwdVec = tempPlatform.GetForwardVector()
	vector upVec = tempPlatform.GetUpVector()
	
	vector lowestCorner, highestCorner
	foreach(corner in localCorners)
	{
		vector worldCorner = (rightVec * corner.x) + (fwdVec * corner.y) + (upVec * corner.z)
		if(worldCorner.z < lowestCorner.z || lowestCorner == <0,0,0>)
			lowestCorner = worldCorner
		if(worldCorner.z > highestCorner.z)
			highestCorner = worldCorner
	}
	
	// Calculate spawn position
	vector basePos = file.lastSpawnPos + <0,0, PLAYER_JUMP_DISTANCE * RandomFloatRange(0.1, 0.5) >

	vector spawnPos = basePos - lowestCorner
	
	// Horizontal placement logic
	float horizontalRange = PLAYER_JUMP_DISTANCE * 0.5  // 161.7 units max offset
	int factor = CoinFlip() ? 1 : -1
	vector horizontalOffset = AnglesToRight(<0, RandomFloatRange(0, 360), 0>) * RandomFloatRange(0, horizontalRange) * factor

	if( file.currentPlatformCount == 1 ) // Spawn second platform at a safe distance
	{
		spawnPos = file.lastSpawnPos + <80, 80, PLAYER_JUMP_DISTANCE>
		horizontalOffset = <0, 56, 0>
	}
	
	spawnPos += horizontalOffset
   
	// Cleanup temporary platform
	tempPlatform.Destroy()
	
	// Create final platform
	entity platform = CreatePropDynamic(model, spawnPos, angles, 6)
	platform.AllowMantle()
	platform.SetScriptName("ClimbingPlatform")

	if( isKillerWalls )
		SpawnOnlyUpKillerWalls( platform, spawnPos )
	else if( RandomIntRange( 0, 15 ) == 0 && file.currentPlatformCount > 25 && file.currentPlatformCount <= 50 )
		MakeMovePlatform( platform, spawnPos, angles )
	else if( RandomIntRange( 0, 10 ) == 0 && file.currentPlatformCount > 50 && file.currentPlatformCount <= 100 )
		MakeMovePlatform( platform, spawnPos, angles )
	else if( RandomIntRange( 0, 15 ) == 0 && file.currentPlatformCount > 50 && file.currentPlatformCount <= 100 )
		SpawnFanPusherOnProp( platform, spawnPos )
	else if( RandomIntRange( 0, 10 ) == 0 && file.currentPlatformCount > 100 )
		SpawnFanPusherOnProp( platform, spawnPos )
	
	// Update tracking data
	file.lastSpawnPos = spawnPos + highestCorner
	
	PlatformData newPlatform
	newPlatform.platform = platform
	newPlatform.origin = spawnPos
	newPlatform.angles = angles
	newPlatform.boundsMin = mins
	newPlatform.boundsMax = maxs
	newPlatform.id = file.nextPlatformId++  // Add unique ID
	// Checkpoint generation logic
	bool shouldBeCheckpoint = (file.currentPlatformCount + 1) % 5 == 0
	if(shouldBeCheckpoint)
	{
		newPlatform.isCheckpoint = true
		newPlatform.checkpointID = file.nextCheckpointID++
		// #if DEVELOPER
		// DebugDrawMark(newPlatform.origin + <0,0,50>, 50, 255, 150, 0, true, 999)
		// #endif
	}	
	#if DEVELOPER
	// Debug draw connection line
	if(file.activePlatforms.len() > 0)
	{
		PlatformData prevPlatform = file.activePlatforms.top()
		vector prevHighestWorld = prevPlatform.origin + prevPlatform.boundsMax
		vector newLowestWorld = basePos + highestCorner //maxs //horizontalOffset
		
		DebugDrawLine(
			prevHighestWorld,		 // Start at previous platform's highest point
			newLowestWorld,		   // End at new platform's highest point //lowest point
			255, 150, 0,			  // Orange color (RGB)
			true,					 // Depth test
			999						// Duration in seconds
		)
	}
	
	DrawAngledBox( spawnPos, angles, mins, maxs, 255, 0, 0, true, 999 )
	#endif
	
	return newPlatform
}
void function RespawnPlayerAtStart(entity player, bool fromFall = false)
{
	vector deathPos = player.GetOrigin()
	
	if( !fromFall )
		wait 4
	
	while(file.activePlatforms.len() == 0)
		WaitFrame()
	
	if( !IsAlive(player) )
		DecideRespawnPlayer(player)
	
	// Find respawn position and check if it's a checkpoint
	CheckpointResult result = FindHighestValidCheckpoint(player, deathPos)
	vector respawnPos = result.origin
	bool isCheckpoint = result.isCheckpoint
	
	// Handle lives logic
	if(isCheckpoint && file.playerLives[player] > 0)
	{
		file.playerLives[player]--
		Message_New(player, "Checkpoint Used! Lives Remaining: " + file.playerLives[player])
		player.ForceCrouch()
	}
	else
	{
		if( fromFall )
			return
		
		// Fallback to first platform if no lives or invalid checkpoint
		respawnPos = file.activePlatforms[0].origin
		// if(isCheckpoint)
			// Message_New(player, "Checkpoints Reset\n\nRespawning at Start")
		
		// file.playerLives[player] = 3
		// file.playerCheckpointIDs[player] = -1
	}
	
	player.SetVelocity(<0, 0, 0>)
	player.SetOrigin(respawnPos)
	player.SetAngles(<0, 0, 0>)
	player.UnforceCrouch()
	
	// Update UI
	ShowHighScoreMessage(player)
}

CheckpointResult function FindHighestValidCheckpoint(entity player, vector deathPos)
{
	CheckpointResult result
	result.origin = file.activePlatforms[0].origin //+ <0,0,100> // Default spawn
	result.isCheckpoint = false

	const vector PLAYER_HULL_MINS = <-15, -15, 0>
	const vector PLAYER_HULL_MAXS = <15, 15, 36> // Crouched, standing is 72
	const int MAX_CHECKS_PER_PLATFORM = 8

	array<int> validCheckpointIDs = []
	foreach(platform in file.activePlatforms)
	{
		if(platform.isCheckpoint && 
		   platform.checkpointID <= file.playerCheckpointIDs[player] )//&&
		   //platform.origin.z > deathPos.z)
		{
			validCheckpointIDs.append(platform.checkpointID)
		}
	}
	validCheckpointIDs.sort(ReverseSort)

	foreach(checkpointID in validCheckpointIDs)
	{
		foreach(platform in file.activePlatforms)
		{
			if(platform.checkpointID != checkpointID)
				continue

			entity prop = platform.platform
			vector right = prop.GetRightVector()
			vector fwd = prop.GetForwardVector()
			vector up = prop.GetUpVector()

			// Generate test pattern positions
			array<vector> testPattern = [
				<0.5, 0.5, 0.8>,   // Center
				<0.25, 0.25, 0.8>, // Front-left
				<0.75, 0.25, 0.8>, // Front-right
				<0.25, 0.75, 0.8>, // Back-left
				<0.75, 0.75, 0.8>, // Back-right
				<0.5, 0.25, 0.8>,  // Front-center
				<0.5, 0.75, 0.8>,  // Back-center
				<0.25, 0.5, 0.8>,  // Left-center
				<0.75, 0.5, 0.8>   // Right-center
			]

			for(int i = 0; i < MAX_CHECKS_PER_PLATFORM; i++)
			{
				// Calculate local test position
				vector fraction = testPattern[i % testPattern.len()]
				vector localPos = platform.boundsMin + Vector(
					(platform.boundsMax.x - platform.boundsMin.x) * fraction.x,
					(platform.boundsMax.y - platform.boundsMin.y) * fraction.y,
					(platform.boundsMax.z - platform.boundsMin.z) * fraction.z
				)
				
				// Convert to world position
				vector testPos = platform.origin + 
								(right * localPos.x) + 
								(fwd * localPos.y) + 
								(up * localPos.z)

				// Trace down to find floor
				vector traceStart = testPos + <0,0,50>
				vector traceEnd = testPos - <0,0,100>
				TraceResults floorTrace = TraceHull(
					traceStart, traceEnd, 
					PLAYER_HULL_MINS, PLAYER_HULL_MAXS, 
					[], TRACE_MASK_PLAYERSOLID, 
					TRACE_COLLISION_GROUP_PLAYER
				)

				if(!floorTrace.startSolid && floorTrace.fraction < 1.0)
				{
					vector floorPos = floorTrace.endPos
					
					// Check vertical clearance
					vector headStart = floorPos + <0,0,72>
					vector headEnd = floorPos
					TraceResults headTrace = TraceHull(
						headStart, headEnd,
						PLAYER_HULL_MINS, PLAYER_HULL_MAXS,
						[prop], TRACE_MASK_PLAYERSOLID,
						TRACE_COLLISION_GROUP_PLAYER
					)

					if(headTrace.fraction == 1.0)
					{
						result.origin = floorPos + <0,0,5>
						result.isCheckpoint = true
						return result
					}
				}
			}
		}
	}

	return result
}

int function ReverseSort(int a, int b)
{
	// Sorts integers in descending order
	if(b > a)
		return 1
	else if(b < a)
		return -1
	return 0
}

void function CreateRegenerateMapButton()
{
	while(file.activePlatforms.len() == 0)
		WaitFrame()
	
	AddCallback_OnUseEntity(CreateFRButton( file.activePlatforms[0].platform.GetOrigin() + < 50, 30, 10 >, < 0, -90, 0 > , "%use% Regenerate Map"), void
		function(entity panel, entity user, int input) {
			DEV_RegenerateOnlyUpMap()
		})
}

void function PlayerPlatformTracker(entity player)
{
	player.EndSignal("OnDestroy")
	int lastPlatformId = -1
	vector lastSafePosition = <0,0,0>
	float fallThreshold = 256.0

	while(true)
	{
		if(IsValid(player) && IsAlive(player))
		{
			// Initialize high score
			if(!(player in file.playerHighScores)) 
			{
				file.playerHighScores[player] <- 0
				file.playerFallCounts[player] <- 0
			}

			// Initialize checkpoint tracking
			if(!(player in file.playerCheckpointIDs))
				file.playerCheckpointIDs[player] <- -1
			
			// Initialize player stats
			if(!(player in file.playerLives))
				file.playerLives[player] <- 3
			
			// Check mantling state
			bool isMantling = player.IsMantling()
			
			// Get current platform
			entity groundEnt = player.GetGroundEntity()
			int currentPlatformId = -1
			if(IsValid(groundEnt) && groundEnt.GetScriptName() == "ClimbingPlatform" && !isMantling)
			{
				foreach(platform in file.activePlatforms)
				{
					if(platform.platform == groundEnt)
					{
						currentPlatformId = platform.id
						lastSafePosition = player.GetOrigin() //platform.platform.GetOrigin() // player.GetOrigin()

						// Update high score
						if(currentPlatformId > file.playerHighScores[player])
							file.playerHighScores[player] = currentPlatformId

						// Update checkpoint if standing on one
						if(platform.isCheckpoint && platform.checkpointID > file.playerCheckpointIDs[player])
						{
							file.playerCheckpointIDs[player] = platform.checkpointID
							Message_New(player, "CHECKPOINT REACHED" ) //(" + platform.checkpointID + ")")
						}
						
						break
					}
				}
			}

			// Platform changed check
			if(currentPlatformId != lastPlatformId && !isMantling)
			{
				if(currentPlatformId != -1)
				{
					printt("Player " + player.GetPlayerName() + " stepped onto platform ID: " + currentPlatformId)
					lastPlatformId = currentPlatformId
					
					ShowHighScoreMessage(player)
				}
				else if(lastPlatformId != -1)
				{
					// Fall detection
					vector playerPos = player.GetOrigin()
					if(playerPos.z < (lastSafePosition.z - fallThreshold))
					{
						// Increment fall counter
						file.playerFallCounts[player]++
						
						printt("Player " + player.GetPlayerName() + " fell from platform ID: " + lastPlatformId)
						ShowHighScoreMessage(player)
						
						RespawnPlayerAtStart(player, true)
						lastPlatformId = -1
					}
				}
			}
		}
		WaitFrame()
	}
}

void function ShowHighScoreMessage(entity player)
{
	if(!IsValid(player)) return
 
	// Initialize high score
	if(!(player in file.playerHighScores))
	{
		file.playerHighScores[player] <- 0
		file.playerFallCounts[player] <- 0
	}
	
	// Initialize checkpoint tracking
	if(!(player in file.playerCheckpointIDs))
		file.playerCheckpointIDs[player] <- -1
	
	// Initialize player stats
	if(!(player in file.playerLives))
		file.playerLives[player] <- 3	
	int fallCount = file.playerFallCounts[player]
	int highScore = file.playerHighScores[player]
	string message = format("Highest Climb: %d\nFall Count: %d\n\n By CafeFPS", highScore, fallCount)
	
	// Display near first platform
	if(file.activePlatforms.len() > 0)
	{
		vector pos = file.activePlatforms[0].platform.GetOrigin() + < 80, 0, 100 >
		RemovePanelText( player, 1 )
		CreatePanelText(player, "Apex Up", message, pos, < 0, 0, 0 >, false, 1, 1) 
	}
}

void function CreateSafetyTrigger()
{
	if( IsValid( file.safetyTrigger ) )
		file.safetyTrigger.Destroy()
	
	entity trigger = MapEditor_CreateTrigger( startPos - < 0, 0, 500 >, < 0, 0, 0 > , 10000, 50, false)
	
	trigger.SetEnterCallback(OnSafetyTriggerEnter)
	DispatchSpawn(trigger)
	file.safetyTrigger = trigger
}

void function OnSafetyTriggerEnter(entity trigger, entity player)
{
	if(IsValid(player) && player.IsPlayer())
	{
		PlatformData firstPlatform = file.activePlatforms[0]
		player.SetOrigin(firstPlatform.origin)
		PutPlayerInSafeSpot( player, null, null, firstPlatform.origin + <0, 128, 128>, firstPlatform.origin )
		player.SetVelocity(<0, 0, 0>)
		player.SetAngles(<0, 0, 0>)
		
		if( file.playerLives[player] != 3 )
			Message_New(player, "Lives Reset\n\nRespawning at Start")
		
		file.playerLives[player] = 3
		file.playerCheckpointIDs[player] = -1
		
		
		printt("Player " + player.GetPlayerName() + " was saved by safety trigger")
	}
}

void function OnPlayerConnected(entity player)
{
	thread RespawnPlayerAtStart(player)
	thread PlayerPlatformTracker(player)
}

// Cleanup old platforms
void function CleanupPlatforms()
{
	while(file.activePlatforms.len() > MAX_PLATFORMS)
	{
		PlatformData platform = file.activePlatforms.remove(0)
		if(IsValid(platform.platform))
			platform.platform.Destroy()
		file.currentPlatformCount--
	}
}

void function SpawnOnlyUpKillerWalls( entity prop, vector origin)
{
	EndSignal(svGlobal.levelEnt, "EndScriptedPropsThread")

	vector angles = Vector(0,0,90)

	array<entity> Rotators = [
		CreateEntity( "script_mover_lightweight" ),
		CreateEntity( "script_mover_lightweight" )
	]

	foreach(entity rotator in Rotators)
	{
		rotator.kv.solid = SOLID_VPHYSICS
		rotator.kv.fadedist = -1
		rotator.SetValueForModelKey( $"mdl/industrial/landing_mat_metal_03_large.rmdl" )
		rotator.kv.SpawnAsPhysicsMover = 0
		rotator.e.isDoorBlocker = true
		rotator.SetPusher( true )
		rotator.SetAngles( angles )
		rotator.SetOrigin( origin + Vector(0,0,66))
		DispatchSpawn( rotator )
		
		rotator.SetParent( prop )
	}
	
	thread function() : (prop, Rotators, origin)
	{
		EndSignal( prop, "OnDestroy" )
		EndSignal(svGlobal.levelEnt, "EndScriptedPropsThread")

		float timemoving = 2.0
		vector startpos = origin + Vector(0,0,66)

		entity rotator = Rotators[0]
		entity rotator2 = Rotators[1]
		
		while( IsValid(rotator) && IsValid(rotator2))
		{
			rotator.NonPhysicsMoveTo( startpos+AnglesToUp(rotator.GetAngles())*128, timemoving, 0, 0.5 )
			rotator2.NonPhysicsMoveTo( startpos+AnglesToUp(rotator.GetAngles())*-128, timemoving, 0, 0.5 )

			wait timemoving
		
			if( !IsValid(rotator) || !IsValid(rotator2) )
				break
			
			rotator.NonPhysicsMoveTo( startpos, 0.3, 0, 0 )
			rotator2.NonPhysicsMoveTo( startpos, 0.3, 0, 0 )

			wait 0.3
		}
	}()
}

void function MakeMovePlatform(entity prop, vector origin, vector angles)
{
	vector angles1 = Vector(0,0,0)
	
	entity rotator = CreateEntity( "script_mover_lightweight" )
	{
		rotator.kv.solid = 0
		rotator.kv.fadedist = -1
		rotator.SetValueForModelKey( prop.GetModelName() )
		rotator.kv.SpawnAsPhysicsMover = 0
		rotator.e.isDoorBlocker = true
		DispatchSpawn( rotator )
		rotator.SetAngles(angles1)
		rotator.SetOrigin(origin )//+ Vector(256,0,0))
		rotator.Hide()
		rotator.SetPusher( true )
	}

	prop.SetParent(rotator)

	thread function() : (prop, rotator)
	{
		EndSignal(prop, "OnDestroy")
		EndSignal(svGlobal.levelEnt, "EndScriptedPropsThread")

		float timemoving = 3.0
		vector startpos = rotator.GetOrigin()

		//bad code moment
		vector MoveRight = startpos+AnglesToRight(rotator.GetAngles())*300
		vector MoveLeft = startpos+AnglesToRight(rotator.GetAngles())*-300

		vector MoveTo = CoinFlip() ? MoveLeft : MoveRight

		while(IsValid(rotator))
		{
			rotator.NonPhysicsMoveTo( MoveTo , timemoving, 1, 1 )
			wait timemoving
			rotator.NonPhysicsMoveTo( startpos, timemoving, 1, 1 )
			wait timemoving

			if(MoveTo == MoveRight)
				MoveTo = MoveLeft
			else if(MoveTo == MoveLeft)
				MoveTo = MoveRight

		}
	}()
}

void function SpawnFanPusherOnProp(entity prop, vector origin)
{
	origin = origin + AnglesToUp(prop.GetAngles()) * 64//+ AnglesToUp(<-90,0,90>) * 128
	
	entity rotator = CreateEntity( "script_mover_lightweight" )
	{
		rotator.kv.solid = SOLID_VPHYSICS
		rotator.kv.fadedist = -1
		rotator.kv.SpawnAsPhysicsMover = 0
		rotator.e.isDoorBlocker = true
		rotator.SetOrigin(origin)
		rotator.SetAngles(<-90,0,90>)
		rotator.SetScriptName("FanPusher")
		DispatchSpawn( rotator )
		rotator.SetParent(prop)
	}

	//Wind column effect, two so we complete a cylinder-like shape
	entity fx = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( $"P_s2s_flap_wind" ), origin, Vector(-90,0,0) )
	{
		EmitSoundOnEntity(fx, "HoverTank_Emit_EdgeWind")
		fx.SetParent(prop)
	}

	entity fx2 = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( $"P_s2s_flap_wind" ), origin, Vector(-90,-90,0) )
	{
		fx2.SetParent(prop)
	}

	//Circle on ground FX
	entity circle = CreateEntity( "prop_script" )
	{
		circle.SetValueForModelKey( $"mdl/weapons_r5/weapon_tesla_trap/mp_weapon_tesla_trap_ar_trigger_radius.rmdl" )
		circle.kv.fadedist = 30000
		circle.kv.renderamt = 0
		circle.kv.rendercolor = "250, 250, 250"
		circle.kv.modelscale = 0.12
		circle.kv.solid = 0
		circle.SetOrigin( fx.GetOrigin() + <0.0, 0.0, -25>)
		circle.SetAngles( Vector(0,0,0) )
		circle.NotSolid()
		DispatchSpawn(circle)
		circle.SetParent(prop)
	}
}
#endif