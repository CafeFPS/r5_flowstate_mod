//Made by @CafeFPS

global function _FS_Carritos_Init
global function FS_Carritos_InitTrackData

// Checkpoint struct
struct Checkpoint
{
	vector point // point on the track
	float distance // distance from start of track to this checkpoint
}

// Track struct
struct Track
{
	array<Checkpoint> points // array of track points
	float trackLength // total length of the track
	void functionref( ) spawnMap
}

// Player struct
struct RacePlayer
{
	entity playerEntity // the player entity
	float distance // player's distance from start of track
	float previousDistance
	Checkpoint& checkpoint // current checkpoint the player is at
	Checkpoint& previousCheckpoint
	float bestLapTime // player's best lap time
	int lapsCompleted = 0 // number of laps completed
}

// Race state struct
struct RaceState
{
	Track& track // the track being raced on
	array<RacePlayer> players // array of players in the race
}

struct
{
	array<Track> tracks
	int currentTrack = 0

	RaceState& currentRaceGame
	array<entity> playerSpawnedProps
	vector lobbyLocation
	vector lobbyAngles
} file

void function _FS_Carritos_Init()
{
	if(GetCurrentPlaylistVarBool("enable_global_chat", true))
		SetConVarBool("sv_forceChatToTeamOnly", false)
	else
		SetConVarBool("sv_forceChatToTeamOnly", true)

	AddCallback_OnClientConnected( FS_Carritos_OnPlayerConnected )

	AddCallback_OnClientDisconnected( FS_Carritos_OnPlayerDisconnected ) //entity player

	// AddCallback_OnPlayerKilled( ) //entity victim, entity attacker, var damageInfo

	AddCallback_EntitiesDidLoad( _EntitiesDidLoad ) // without parameters

	//Register Signals

	//Precache models

	thread FS_Carritos_StartGameThread()
	
	//Init tracks
	FS_Carritos_Track1_Init()
}

void function FS_Carritos_OnPlayerConnected( entity player )
{
    if ( !IsValid( player ) ) return
	_HandleRespawn(player)
	Survival_SetInventoryEnabled( player, false )
	SetPlayerInventory( player, [] )
	
	if(IsPlayerEliminated(player))
		ClearPlayerEliminated(player)
	
	player.SetThirdPersonShoulderModeOn()
	player.SetVelocity(Vector(0,0,0))

	TakeLoadoutRelatedWeapons(player)

	player.SetOrigin( file.lobbyLocation)
	player.SetAngles( file.lobbyAngles)

	SetTeam( player, 99 )
	UpdatePlayerCounts()
	// thread __HighPingCheck( player )
	// thread Flowstate_InitAFKThreadForPlayer(player)
}

void function _HandleRespawn(entity player)
{
	if(!IsValid(player)) return

	if(!IsAlive(player)) 
	{
		DecideRespawnPlayer(player, true)
	}

	player.UnforceStand()
	player.UnfreezeControlsOnServer()
	
	player.SetPlayerNetBool( "pingEnabled", false )
	player.SetMaxHealth( 100 )
	player.SetHealth( 100 )
	player.SetMoveSpeedScale(1)

	player.TakeOffhandWeapon(OFFHAND_TACTICAL)
	player.TakeOffhandWeapon(OFFHAND_ULTIMATE)

	TakeAllWeapons(player)

	//GivePassive(player, ePassives.PAS_PILOT_BLOOD)
	player.MovementEnable()

	//give flowstate holo sprays
	player.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
	player.GiveOffhandWeapon( "mp_ability_emote_projector", OFFHAND_EQUIPMENT )
}

void function FS_Carritos_OnPlayerDisconnected( entity player )
{
    if ( !IsValid( player ) ) return

}

void function _EntitiesDidLoad() //Setup lobby locations
{
	switch( MapName() )
	{
		case eMaps.mp_rr_olympus_mu1:
		case eMaps.mp_rr_arena_empty:
		case eMaps.mp_flowstate:
		case eMaps.mp_rr_arena_phase_runner:
		case eMaps.mp_rr_arena_composite:
			entity startEnt = GetEnt( "info_player_start" )
			
			file.lobbyLocation = startEnt.GetOrigin()
			file.lobbyAngles = startEnt.GetAngles()
		break

		case eMaps.mp_rr_desertlands_64k_x_64k:
			file.lobbyLocation = <17791.3203, 10835.2314, -2985.83618>
			file.lobbyAngles = <0, -114.427933, 0>
		break

		case eMaps.mp_rr_arena_skygarden:
			file.lobbyLocation = <-208.090103, 6830.30225, 3138.40137>
			file.lobbyAngles = <0, 122, 0>
		break

		case eMaps.mp_rr_party_crasher_new:
			file.lobbyLocation = <-1399.06775, 427.32309, 1298.39697>
			file.lobbyAngles = <0, 22, 0>
		break
	}
	AddSpawnCallback("prop_dynamic", _OnPropDynamicSpawned)
	DestroyPlayerProps()
}

void function FS_Carritos_StartGameThread()
{
    WaitForGameState(eGameState.Playing)

    while(true)
	{
		//Temp!
		foreach( player in GetPlayerArray() ) //tpin players
		{
			if( !IsValid( player ) ) //remove from the array instead
				continue

			Message( player, "APEX KART", "INDEV - Starting soon", 10 )
		}
		wait 5//Temp!
		
		//This is a point where mathmaking already happened
		//Install realms based stuff

		FS_Carritos_InitRaceData( file.tracks[ file.currentTrack ], GetPlayerArray() )

		RaceState currentRaceGame = file.currentRaceGame
		Track currentTrack = currentRaceGame.track

		array< RacePlayer > racePlayers = currentRaceGame.players // array of players in the race

		foreach( playerStruct in racePlayers ) //tpin players
		{
			entity player = playerStruct.playerEntity
			if( !IsValid( player ) ) //remove from the array instead
				continue
			vector lastPoint = currentTrack.points[currentTrack.points.len()-2].point
			player.SetOrigin( lastPoint ) //debug value
			vector angle = <0,VectorToAngles( currentTrack.points[0].point - lastPoint ).y,0>
			player.SetAngles( angle )
			SpawnTridentAtOrigin( lastPoint, angle )
			CreatePanelText( player, "punto 0", "", currentTrack.points[0].point + <0,0,100>, <0, -180, 0>, false, 2 )
			CreatePanelText( player, "punto 1", "", currentTrack.points[1].point + <0,0,100>, <0, -180, 0>, false, 2 )
			CreatePanelText( player, "punto 2", "", currentTrack.points[2].point + <0,0,100>, <0, -180, 0>, false, 2 )
			CreatePanelText( player, "ultimo", "", currentTrack.points[currentTrack.points.len()-1].point + <0,0,100>, <0, -180, 0>, false, 2 )
			player.FreezeControlsOnServer()
			Message( player, "APEX KART", "Starting soon", 3 )
		}
		
		wait 5
		
		foreach( playerStruct in racePlayers ) //tpin players
		{
			entity player = playerStruct.playerEntity
			if( !IsValid( player ) ) //remove from the array instead
				continue

			AddCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD_INSTANT )
			AddCinematicFlag( player, CE_FLAG_HIDE_PERMANENT_HUD )
			player.UnfreezeControlsOnServer()
			thread function () : ( )
			{
				while( true )
				{
					FS_Carritos_UpdatePlayerPositions( file.currentRaceGame )
					WaitFrame()
				}
			}()
		}		
		
		WaitForever() //!temp
	}
}

void function _OnPropDynamicSpawned(entity prop)
{
    file.playerSpawnedProps.append(prop)
}

void function DestroyPlayerProps()
{
    foreach(prop in file.playerSpawnedProps)
    {
        if(IsValid(prop))
            prop.Destroy()
    }
    file.playerSpawnedProps.clear()
}

// Function to initialize the tracks
void function FS_Carritos_InitTrackData( array<vector> points, void functionref() spawnMap ) 
{
	Track track

	// calculate distances for each checkpoint
	float distance = 0.0
	for (int i = 0; i < points.len(); i++)
	{
		Checkpoint checkpoint
		checkpoint.point = points[i]
		track.points.append(checkpoint)
		distance += Distance(points[i], points[(i + 1) % points.len()])
		checkpoint.distance = distance
	}
	track.trackLength = distance
	printt( "Track length test", track.trackLength )

	track.spawnMap = spawnMap

	file.tracks.append( track )
}

// Function to initialize the race state
void function FS_Carritos_InitRaceData(Track track, array<entity> players) 
{
	RaceState raceState
	raceState.track = track

	// initialize players
	for (int i = 0; i < players.len(); i++)
	{
		RacePlayer player
		Checkpoint checkpoint
		player.playerEntity = players[i]
		player.distance = 0.0
		player.checkpoint = checkpoint
		player.bestLapTime = 0.0
		player.lapsCompleted = 0
		raceState.players.append(player)
	}
	
	track.spawnMap() //spawn the map
	
	file.currentRaceGame = raceState
}

// Function to update the player positions on the track
void function FS_Carritos_UpdatePlayerPositions(RaceState raceState) 
{
	for (int i = 0; i < raceState.players.len(); i++) 
	{
		RacePlayer playerStruct = raceState.players[i]

		entity player = playerStruct.playerEntity
		vector playerPos = player.GetOrigin()

		// find the closest point on the track to the player
		Checkpoint checkPointStruct = raceState.track.points[0]

		vector closestPoint = checkPointStruct.point

		float closestDistance = Distance(playerPos, closestPoint)
		for (int j = 1; j < raceState.track.points.len(); j++)
		{
			float distance = Distance(playerPos, raceState.track.points[j].point)
			if (distance < closestDistance) 
			{
				closestPoint = raceState.track.points[j].point
				closestDistance = distance
			}
		}
		
		// calculate the player's dist
		for (int j = 0; j < raceState.track.points.len(); j++)
		{
			if (Distance(closestPoint, raceState.track.points[j].point) < closestDistance) 
			{
				closestDistance = raceState.track.points[j].distance
				break
			}
		}
		
		// update the player's checkpoint
		for (int j = 0; j < raceState.track.points.len(); j++)
		{
			if (closestDistance >= raceState.track.points[j].distance) 
			{
				playerStruct.checkpoint = raceState.track.points[j]
			}
		}

		// update the player's distance traveled
		playerStruct.distance += closestDistance - playerStruct.previousDistance
		playerStruct.previousDistance = closestDistance

		// check if the player has completed a lap
		if (closestDistance >= raceState.track.trackLength && playerStruct.lapsCompleted > 0)
		{
			Checkpoint checkpoint
			playerStruct.lapsCompleted++
			playerStruct.bestLapTime = min(playerStruct.bestLapTime, playerStruct.distance / playerStruct.lapsCompleted)
			playerStruct.distance -= raceState.track.trackLength
			playerStruct.checkpoint = checkpoint
		}

		Checkpoint pointPos = playerStruct.checkpoint
		// pointPos.distance
		DebugDrawLine( player.GetOrigin(), pointPos.point, 255, 0, 0, true, 0.1 )
		printt( FS_Carritos_GetPlayerPositions( file.currentRaceGame ), playerStruct.distance)
	}
}
int function GetClosestCheckpointIndex(array<Checkpoint> checkpoints, vector point) 
{
    int closestIndex = 0
    float closestDistance = Distance(point, checkpoints[0].point)
    for (int i = 1; i < checkpoints.len(); i++)
    {
        float distance = Distance(point, checkpoints[i].point)
        if (distance < closestDistance) 
        {
            closestIndex = i
            closestDistance = distance
        }
    }
    return closestIndex
}
// Function to get the player positions in the scoreboard
string function FS_Carritos_GetPlayerPositions( RaceState raceState ) 
{
	string scoreboard = ""
	for ( int i = 0; i < raceState.players.len(); i++) 
	{
		RacePlayer playerStruct = raceState.players[i]
		entity player = playerStruct.playerEntity
		int position = 1
		for( int j = 0; j < raceState.players.len(); j++ ) 
		{
			if (playerStruct.distance < raceState.players[j].distance) 
			{
				position++
			}
		}
		scoreboard += format( "%d. %s - Lap %d - Time: %f- Distance: %f - Track Length: %f", position, player.GetPlayerName(), playerStruct.lapsCompleted, playerStruct.bestLapTime, playerStruct.distance, raceState.track.trackLength )
	}
	return scoreboard
}