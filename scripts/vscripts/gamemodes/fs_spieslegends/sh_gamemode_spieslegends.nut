//███████╗██████╗ ██╗███████╗███████╗    ██╗     ███████╗ ██████╗ ███████╗███╗   ██╗██████╗ ███████╗                  
//██╔════╝██╔══██╗██║██╔════╝██╔════╝    ██║     ██╔════╝██╔════╝ ██╔════╝████╗  ██║██╔══██╗██╔════╝                  
//███████╗██████╔╝██║█████╗  ███████╗    ██║     █████╗  ██║  ███╗█████╗  ██╔██╗ ██║██║  ██║███████╗                  
//╚════██║██╔═══╝ ██║██╔══╝  ╚════██║    ██║     ██╔══╝  ██║   ██║██╔══╝  ██║╚██╗██║██║  ██║╚════██║                  
//███████║██║     ██║███████╗███████║    ███████╗███████╗╚██████╔╝███████╗██║ ╚████║██████╔╝███████║                  
//╚══════╝╚═╝     ╚═╝╚══════╝╚══════╝    ╚══════╝╚══════╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚═════╝ ╚══════╝                  
//███╗   ███╗ █████╗ ██████╗ ███████╗    ██████╗ ██╗   ██╗     ██████╗ █████╗ ███████╗███████╗███████╗██████╗ ███████╗
//████╗ ████║██╔══██╗██╔══██╗██╔════╝    ██╔══██╗╚██╗ ██╔╝    ██╔════╝██╔══██╗██╔════╝██╔════╝██╔════╝██╔══██╗██╔════╝
//██╔████╔██║███████║██║  ██║█████╗      ██████╔╝ ╚████╔╝     ██║     ███████║█████╗  █████╗  █████╗  ██████╔╝███████╗
//██║╚██╔╝██║██╔══██║██║  ██║██╔══╝      ██╔══██╗  ╚██╔╝      ██║     ██╔══██║██╔══╝  ██╔══╝  ██╔══╝  ██╔═══╝ ╚════██║
//██║ ╚═╝ ██║██║  ██║██████╔╝███████╗    ██████╔╝   ██║       ╚██████╗██║  ██║██║     ███████╗██║     ██║     ███████║
//╚═╝     ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝    ╚═════╝    ╚═╝        ╚═════╝╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝     ╚═╝     ╚══════╝
//02-05 2025

untyped //required to change panel .s. attributes

#if SERVER
global function _GamemodeSpiesLegends_Init

global function CreateHackablePanel

global function FS_Spies_IsVictimBackwardsToAttacker

global function SaveLampData

global function DEV_ForceEndRound
global function DEV_TestSelectTeamMenuVotes
global function EndMatch //For DEV purposes

global function Spies_AddPropMap

global function DEV_TestGroundEnt
global function DEV_TestAllLocationSpawns
#endif //SERVER

#if CLIENT
global function Cl_GamemodeSpiesLegends_Init
global function CL_Spies_RegisterNetworkFunctions

global function FS_Spies_Center_Msg
global function FS_Spies_Center_Msg_SetText
global function FS_ShowRoundStartTimeUI
global function FS_ShowRoundStartSelectingTeamTimeUI

global function ServerToClient_UpdateHackingHUD
global function ServerToClient_RoundWinnerScreen
global function ServerToClient_UpdateScoreHUD

global function DEV_TestProgressRui
global function DEV_TestGradientRui

global function BuildAbilitiesDataOnUI

global function ServerCallback_PlayerInVent
global function ServerCallback_PlayerOutOfVent
#endif //CLIENT

global function Sh_GamemodeSpiesLegends_Init

enum eGoalMsgID
{
	ForceRemoveMsg = -1,
	
	//Hack In Progress
	StayAliveInZoneX = 0,
	ReturnToTheZoneX = 1, //Hacker outside zone, reset timer starts
	
	DefendHackerInZoneX = 2, //spy teammate outside radius
	DefendHacker = 3, //spy teammate inside radius
	
	KillHackerInZoneX = 4, //merc player outside radius
	KillHacker = 5, //merc player outside radius
	
	//Hack Canceled (hacker killed)
	DefendStationX = 6,
	
	//Hack Successful
	StationsWillActivate = 7,
	
	RoundTimeExtended = 8
}

enum eHackingHUDState
{
	INITIAL_SETUP = 0,
	TAKEOVER_WINDOW = 1,
	HACK_INTERRUPTED = 2,
	HACK_UNSUCCESSFUL = 3,
	HACK_COMPLETED = 4,
	HACK_IN_PROGRESS = 5
}

enum eTerminalID
{
	STATION_A = 0,
	STATION_B = 1,
	STATION_C = 2
}

enum eHackingStateNotifyReason
{
	RESET_COUNTDOWN = 0,
	TAKEOVER_COUNTDOWN = 1,
	HACKER_KILLED = 2,
	TRANSFER_SUCCESSFUL = 3,
	HACKER_DISCONNECTED = 4,
	ROUND_START = 5
}

struct TerminalSpawn
{
	LocPair &spawn
	bool isOccupied = false
	int id = -1
	int terminalID = eTerminalID.STATION_A
}

struct LocationData
{
	array<TerminalSpawn> terminalSpawns
	array<LocPair> playerSpawns
	string name
}

struct ActiveHackData
{
	entity terminal
	entity visualRadiusFx
	float resetCountdown = 0.0
	bool allowTakeover = false
	bool takeoverCompleted = false
	entity originalHacker
	entity currentHacker
	float totalHackTime = 0.0
	float lastValidTime = 0.0
	float progress
	bool wasInRadius
	bool isActive
	float lastMessageTime = 0.0
}

struct VentData
{
	entity collisionProp
	entity enemyDummyProp
	entity trigger
}

struct LampData
{
	int id
	bool enabled
	vector origin
	vector angles
	int type
	float radius
}

struct SpawnCandidate
{
    LocPair &spawn
    float score
}

global struct AbilityData
{
	string name
	string weaponName
	asset icon
	bool isPassive
}

struct {
	LocationData &selectedLocation
	array<LocationData> locationSettings
	array<AbilityData> spyGadgets
	array<AbilityData> mercGadgets
	
	#if SERVER
		array<entity> mapProps
		int currentLocation = 0
		float endTime

		array<entity> playerSpawnedProps

		int nextMapIndex = 0
		bool mapIndexChanged = true
		
		entity ring
		vector ringCenter
		float ringRadius
		
		//team select menu
		bool selectTeamMenuOpened = false
		int maxvotesallowedforTeamIMC = -1
		int maxvotesallowedforTeamMILITIA = -1
		int requestsforIMC = -1
		int requestsforMILITIA = -1
		float selectTeamEndTime
		
		array<LocPair> lobbySpawns
		
		array<VentData> vents
		array<LampData> lamps
		
		table<string, int> matchPlayers
		bool actuallyPlayingState = false
		
		array<int> usedSpawnIndices // Track spawn indices used this round
		table<string, int> playerLastSpawnIndex // Track each player's last spawn
	#endif //SERVER
	
	
	#if CLIENT
		var centerMsgElement
		
		var roundDataFrame
		var roundDataFrame0
		var timeRemainingText
		var roundNumberText
		var roundDataTerminalsHacked
		
		var hackingProgressRui
		var hackingProgressRuiBg
		var hackingStatusText
		var hackingStatusText2
		var hackerNameText
		
		// Score HUD
		var ltGradient
		var ltBlur
		var ltLogo
		var ltText
		
		var etGradient
		var etBlur
		var etLogo
		var etText
		
		string centerMsgStaticText = ""
		string centerMsgTimeElement = ""
		
		float roundEndTime
		
		int imcScore
		int militiaScore
		
		float currentHackingProgress
		int hackerHandle
		int lastHackerHudState
	#endif //CLIENT
} file

bool debug = true // Militia will always start as hacker team

//=============================================================================
// TEAM CONFIGURATION
//=============================================================================

const bool SELECT_TEAM_MENU_ENABLED = true
const float SELECT_TEAM_TIME = 10.0

//=============================================================================
// SPAWN SYSTEM
//=============================================================================
const float SPAWN_MERC_DEFENSIVE_RADIUS = 1000.0  // Mercs spawn closer to terminals
const float SPAWN_SPY_INFILTRATION_RADIUS = 1800.0  // Spies spawn further out
const float SPAWN_ENEMY_DANGER_RADIUS = 600.0  // Minimum distance from enemies
const float SPAWN_DARKNESS_THRESHOLD = 100.0  // Lamp radius to consider "dark"
const float TIME_TO_RESPAWN = 8.0 // Should be different for Spies and Mercs?
const float TIME_TO_START_SPECTATING = 2.0

//=============================================================================
// TERMINAL SYSTEM
//=============================================================================
// Terminal Management
array<entity> activeTerminals = []
array<TerminalSpawn> shuffledTerminalsSpawns = []
int terminalSpawnIndex = 0
const int SPAWN_HISTORY_SIZE = 3
array<int> recentTerminalSpawnHistory = []

// Terminal Configuration
int TERMINALS_TO_SPAWN = 3 // Don't increase this past 3, it's not supported atm ( I only made pictures for three zones (A B C) ), it also shouldn't be larger that the amount of spawns that exist
int REQUIRED_HACKS
const bool CREATE_NEW_TERMINALS_ON_HACK = true
const bool DESTROY_TERMINAL_ON_HACKING_UNSUCCESFUL = true

//=============================================================================
// HACKING SYSTEM
//=============================================================================
// Hack State Management
array<ActiveHackData> activeHacks = []
int hackedTerminalsCount = 0
bool isAnyTerminalBeingHacked = false
bool SHOULD_HACK_ALL_TERMINALS = true

// Hack Parameters
const float HACK_RADIUS = 800.0 //512.0 //1024.0
const float HACK_DURATION = 45.0
const float HACK_CHECK_INTERVAL = 0.2
const float HACK_REENABLE_TERMINALS_DELAY = 10.0
const float RESET_TIMEOUT_OUT_OF_ZONE = 10.0  // Time before hack cancels when abandoned
const float HACKER_DIED_TAKEOVER_TIME = 16.0 // Time others can continue after hacker died

//=============================================================================
// ROUND SYSTEM
//=============================================================================
// Round Timing
const float ROUND_TIME = 500.0 // 5 minutes
const int ROUND_START_DELAY_TIME = 3

// Round Tracking
int currentRound = 0
int IMC_Score = 0
int MILITIA_Score = 0

//=============================================================================
// VISUAL EFFECTS & ASSETS
//=============================================================================
const asset FX_VENT_HUD = $"P_core_DMG_boost_screen"
const asset FX_VENT_HUD_INSTANT = $"P_wrth_tt_portal_screen_flash"
const string KILL_VENT_FX_SIGNAL = "vent_signal_fx"
const asset VENT_ASSET = $"mdl/thunderdome/thunderdome_cage_floor_128x64_01.rmdl"

//=============================================================================
// OTHERS
//=============================================================================
const float RING_RADIUS_PADDING = 500.0
const float AUTOCLOAK_CD_TIME = 2.0
const bool AUTOCLOAK_CROUCHED_ONLY = true

//██╗███╗   ██╗██╗████████╗
//██║████╗  ██║██║╚══██╔══╝
//██║██╔██╗ ██║██║   ██║   
//██║██║╚██╗██║██║   ██║   
//██║██║ ╚████║██║   ██║   
//╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝   

#if SERVER
void function _GamemodeSpiesLegends_Init()
{
	RegisterSignal( "RoundEndedFromHackingTerminals" )
	RegisterSignal( "HackerChanged" )
	RegisterSignal( "OnRespawnedFromRoundEnd" )
	RegisterSignal( "Signal_OnWeaponAttack" )
	
	PrecacheModel( $"mdl/communication/terminal_usable_imc_01.rmdl" )
	
	PrecacheWeapon( $"mp_weapon_grenade_rev_shell" )
	PrecacheWeapon( $"mp_weapon_grenade_bangalore_single" )
	PrecacheWeapon( $"mp_weapon_proximity_mine_spieslegends" )
	PrecacheWeapon( $"mp_weapon_turret" )
	PrecacheWeapon( $"mp_ability_dodge_roll_v2" )
	PrecacheWeapon( $"melee_data_knife" )
	PrecacheWeapon( $"mp_ability_devices_jammer" )
	PrecacheWeapon( $"mp_weapon_grenade_flashbang_spieslegends" )
	PrecacheWeapon( $"mp_weapon_grenade_electric_smoke_spieslegends" )
	PrecacheWeapon( $"mp_weapon_grenade_sonar_spieslegends" )
	PrecacheWeapon( $"mp_ability_cloak_spieslegends" )
	
	//CALLBACKS
	AddCallback_EntitiesDidLoad( _EntitiesDidLoad )
	AddCallback_OnClientConnected( OnPlayerConnected )
	AddCallback_OnPlayerKilled( OnPlayerKilled )
	AddCallback_OnPlayerRespawned( OnPlayerRespawned )
	AddCallback_OnWeaponAttack( OnWeaponAttack )
	
	//GAMESTATE CALLBACKS
	AddCallback_GameStateEnter( eGameState.Prematch, SpiesLegends_Prematch ) //Select Team
	AddCallback_GameStateEnter( eGameState.Playing, SpiesLegends_MatchStarted )
	
	//DAMAGE CALLBACKS
	AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_proximity_mine, ProximityMine_SetDamage )
	AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_grenade_electric_smoke, ElectricGrenade_SmokeHighlights )
	AddDamageCallbackSourceID( eDamageSourceId.deathField, RingDamagePunch )
	
	AddCallback_OnMapEditorPropSpawned( Spies_OnMapPropSpawned )
	
	//CLIENT COMMANDS CALLBACKS
	AddClientCommandCallback("AskForTeam", ClientCommand_AskForTeam)
	AddClientCommandCallback("AskForGadget", ClientCommand_RequestGadgets)

	PrecacheOITCRoom()
	
	SetupSpiesAbilitiesData()
	SetupMercsAbilitiesData()
	
	if( SHOULD_HACK_ALL_TERMINALS )
		REQUIRED_HACKS = TERMINALS_TO_SPAWN
	else
		REQUIRED_HACKS = TERMINALS_TO_SPAWN - 1
		
	FLASHBANG_AFFECTS_SPIES = false
}

void function Spies_OnMapPropSpawned( entity e, vector pos, vector ang )
{
	if( e.GetModelName() == $"mdl/lamps/warning_light_ON_red.rmdl" )
	{
		SaveLampData( pos, ang, 1 ) //red
	} else if( e.GetModelName() == $"mdl/lamps/light_hanging_industrial_on.rmdl" )
	{
		SaveLampData( pos, ang, 2 ) //yellow
	} else if( e.GetModelName() == $"mdl/lamps/light_fc.rmdl" )
	{	
		SaveLampData( pos, ang, 3 ) //yellow
	}
	
	Spies_AddPropMap( e )
}

#endif //SERVER

#if CLIENT
void function Cl_GamemodeSpiesLegends_Init()
{
	SetConVarFloat("c_thirdpersonshoulderaimdist", 75)
	SetConVarFloat("c_thirdpersonshoulderheight", 15)
	SetConVarFloat("c_thirdpersonshoulderoffset", 15)
	// SetConVarFloat( "thirdperson_override", 1 )
	
	RegisterSignal( "SpiesCenterMsgReset" )
	RegisterSignal( "TimeRemainingHUDReset" )
	
	PrecacheParticleSystem( FX_VENT_HUD )
	PrecacheParticleSystem( FX_VENT_HUD_INSTANT )
	RegisterSignal( KILL_VENT_FX_SIGNAL )
	
	AddCallback_EntitiesDidLoad( Cl_EntitiesDidLoad )
	AddClientCallback_OnResolutionChanged( Cl_OnResolutionChanged )
	AddCallback_UIScriptReset( Cl_UIScriptReset )
	AddCallback_OnYouRespawned( Cl_OnLocalPlayerRespawned )
	
	AddCallback_GameStateEnter( eGameState.WaitingForPlayers, Cl_SpiesLegends_WaitingForPlayers )
	AddCallback_GameStateEnter( eGameState.Playing, Cl_SpiesLegends_Playing )
	
	AddCallback_OnLocalPlayerUnitframeInit( Spies_SetCustomPlayerIcon )
	AddCallback_OnTeammateUnitframeInit( Spies_SetTeammateCustomPlayerIcon )
	
	SetupSpiesAbilitiesData()
	SetupMercsAbilitiesData()
}

void function Cl_EntitiesDidLoad()
{
	// Center MSG HUD
	file.centerMsgElement = HudElement( "FS_Spies_Center_Msg")
	
	// Round Info HUD
	file.roundDataFrame = HudElement( "FS_Spies_RoundInfo_BG")
	file.roundDataTerminalsHacked = HudElement( "FS_Spies_RoundInfo_TerminalsCount" )
	file.roundDataFrame0 = HudElement( "FS_Spies_RoundInfo_BG0")
	file.timeRemainingText = HudElement( "FS_Spies_RoundInfo_Text")
	file.roundNumberText = HudElement( "FS_Spies_RoundInfo_Text2")

	// Hacking Progress HUD
	file.hackingProgressRui = HudElement("FS_ProgressTest")
	file.hackingProgressRuiBg = HudElement("FS_ProgressTest_BG")
	file.hackingStatusText2 = HudElement("FS_ProgressTest_Text2")
	file.hackingStatusText = HudElement("FS_ProgressTest_Text")
	file.hackerNameText = HudElement("FS_ProgressTest_TextHackerName")

	// Score HUD
	file.ltGradient = HudElement("FS_Spies_LocalTeam_Score_Gradient")
	file.ltBlur = HudElement("FS_Spies_LocalTeam_Score_Blur")
	file.ltLogo = HudElement("FS_Spies_LocalTeam_Score_Logo")
	file.ltText = HudElement("FS_Spies_LocalTeam_Score_Text")
	
	file.etGradient = HudElement("FS_Spies_EnemyTeam_Score_Gradient")
	file.etBlur = HudElement("FS_Spies_EnemyTeam_Score_Blur")
	file.etLogo = HudElement("FS_Spies_EnemyTeam_Score_Logo")
	file.etText = HudElement("FS_Spies_EnemyTeam_Score_Text")
	
	BuildAbilitiesDataOnUI()
	
	// if( MapName() == eMaps.mp_rr_arena_empty )
	// {
		// entity dlight_chill_0 = CreateClientSideDynamicLight( < -1717, -1846.195, 1690.609 >, < 90, 0, 0 >, DLIGHT_RICH_BROWN, 200.0 ).SetLightExponent( 2.0 )
	// }
	
	// GetLocalClientPlayer().ClientCommand( "uiscript_reset" )
}

void function Cl_SpiesLegends_WaitingForPlayers() //lobby lightning
{
	// SetConVarToDefault( "mat_autoexposure_force_value" )
	// SetConVarToDefault( "mat_bloom_max_lighting_value" )
	SetConVarFloat( "mat_autoexposure_force_value", 3 )
	SetConVarFloat( "mat_bloom_max_lighting_value", 0.02 )
	
	SetConVarToDefault( "mat_autoexposure_max" )
	SetConVarToDefault( "mat_autoexposure_max_multiplier" )
	SetConVarToDefault( "mat_autoexposure_min" )
	SetConVarToDefault( "mat_autoexposure_min_multiplier" )

	SetConVarToDefault( "mat_sky_scale" )
	SetConVarToDefault( "mat_sky_color" )
	SetConVarToDefault( "mat_sun_scale" )
	SetConVarToDefault( "mat_sun_color" )
}

void function Cl_SpiesLegends_Playing() //hotel map only
{
	SetConVarFloat( "mat_autoexposure_force_value", GetCurrentPlaylistVarFloat( "autoexposure_force_value", 0.35 ) )
	SetConVarFloat( "mat_bloom_max_lighting_value", GetCurrentPlaylistVarFloat( "bloom_lightning_value", 1.0 ) )
	
	SetConVarFloat( "mat_autoexposure_max", 0.3 )
	SetConVarFloat( "mat_autoexposure_max_multiplier", 0.4 )
	SetConVarFloat( "mat_autoexposure_min", GetCurrentPlaylistVarFloat( "autoexposure_min", 0.2 ) )
	SetConVarFloat( "mat_autoexposure_min_multiplier", GetCurrentPlaylistVarFloat( "autoexposure_min_multiplier", 0.5 )	)

	SetConVarFloat( "mat_sky_scale", GetCurrentPlaylistVarFloat( "sky_scale", 0.0 ) )
	SetConVarString( "mat_sky_color", "1.0 1.0 1.0 1.0" )
	SetConVarFloat( "mat_sun_scale", 1.0 )
	SetConVarString( "mat_sun_color", "1.0 1.5 2.0 1.0" )
	
	// SetConVarFloat( "thirdperson_override", 1 )
}

void function Spies_SetTeammateCustomPlayerIcon( entity player, var rui ) 
{
	asset icon
	
	if( player.GetTeam() == 99 )
		icon = $"rui/flowstate_custom/nick_portrait"
	else if( player.GetTeam() == GetGlobalNetInt( "FS_SpyTeam" ) )
		icon = $"rui/flowstate_custom/agent_portrait"
	else
		icon = $"rui/flowstate_custom/nick_portrait"
	
	RuiSetImage( rui, "icon", icon )
}

void function Spies_SetCustomPlayerIcon( entity player, var rui ) 
{
	SURVIVAL_PopulatePlayerInfoRui( player, rui )
	
	RuiSetInt( rui, "micStatus", 0 )
	// RuiSetColorAlpha( rui, "customCharacterColor", SrgbToLinear( <0, 0, 255> / 255.0 ), 1.0 )
	// RuiSetBool( rui, "useCustomCharacterColor", true )
	
	RuiTrackString( rui, "name", player, RUI_TRACK_PLAYER_NAME_STRING )
	asset icon
	
	if( player.GetTeam() == 99 )
		icon = $"rui/flowstate_custom/nick_portrait"
	else if( player.GetTeam() == GetGlobalNetInt( "FS_SpyTeam" ) )
		icon = $"rui/flowstate_custom/agent_portrait"
	else
		icon = $"rui/flowstate_custom/nick_portrait"
	
	RuiSetImage( rui, "playerIcon", icon )
}

void function Cl_OnLocalPlayerRespawned()
{
	if( file.roundEndTime != -1 )
	{
		thread FS_Spies_ShowRoundEndTimeUI( file.roundEndTime )
	}
}

void function Cl_UIScriptReset()
{
	BuildAbilitiesDataOnUI()
}

void function Cl_OnResolutionChanged()
{
	if( file.roundEndTime != -1 )
	{
		thread FS_Spies_ShowRoundEndTimeUI( file.roundEndTime )
	}
	
	ServerToClient_UpdateScoreHUD( TEAM_IMC, file.imcScore )
	ServerToClient_UpdateScoreHUD( TEAM_MILITIA, file.militiaScore )
	
	BuildAbilitiesDataOnUI()
}

void function CL_Spies_RegisterNetworkFunctions()
{
	if ( IsLobby() )
		return
	
	RegisterNetworkedVariableChangeCallback_time( "FS_SpiesRoundEndTime", FS_Spies_RoundEndTimeChanged )
}
#endif //CLIENT

void function Sh_GamemodeSpiesLegends_Init()
{
	switch( MapName() )
	{
		case eMaps.mp_rr_arena_empty:
			RegisterLocation(
					CreateLocationData(
						"Hotel",
						//Terminals Spawns
						[
							//Last floor
							NewLocPair( <-1785.35291, -1276.8999, 2035.5625>, <0, 87.8335648, 0> )
							NewLocPair( <-1073.73584, -4.97237349, 2035.5625> , <0, 0.390524387, 0> )
							NewLocPair( <-2481.36279, -85.2440796, 2035.5625> , <0, -91.4992752, 0> )
							
							//Third floor
							
							NewLocPair( <-863.949829, 374.855499, 1891.26245> , <0, -176.169327, 0> )
							
							//Second Floor
							
							
							NewLocPair( <-1367.73596, 368.108398, 1747.89453> , <0, 90.7791443, 0> )
							NewLocPair( <-1421.87769, 1313.25415, 1667.16248>, <0, 89.0397186, 0> )
							NewLocPair( <-2324.34619, 807.859619, 1747.26245>, <0, 0.276849449, 0> )
							NewLocPair( <-2391.05151, -1474.76526, 1747.26245> , <0, 179.053726, 0> )
							NewLocPair( <-1548.82544, -26.309679, 1747.26245> , <0, 88.4075089, 0> )
							NewLocPair( <-2378.69653, -295.215363, 1747.26245> , <0, -179.727036, 0> )

							
							//Sótano
							
							NewLocPair( <-1715.66235, -948.475769, 1603.94226>, <0, 90.732933, 0> )
							NewLocPair( <-1807.38867, 284.773499, 1603.49377> , <0, -91.225708, 0> )
							

						],
						//Players Spawns // It's now unified, should be easier to work with the spawn algo
						[
							// RIP (OLD SPAWNS)
							// NewLocPair(<-2086.94385, -585.912354, 2035.5625> , <0, -96.1652222, 0> )
							// NewLocPair(<-2251.29541, -104.514305, 1788.26245> , <0, 172.985764, 0> )
							// NewLocPair(<-2130.88721, -1229.64624, 1795.22253> , <0, 88.8411942, 0> )
							// NewLocPair(<-1257.58203, -358.366638, 1795.13318> , <0, 88.4652786, 0> )
							// NewLocPair(<-2233.27319, 1288.63354, 1603.47717> , <0, -90.1870499, 0> )
							// NewLocPair(<-980.343811, -661.195862, 1651.16248> , <0, -170.756622, 0> )
							// NewLocPair( <-1164.40454, -656.834106, 1891.09448>, <0, 179.474594, 0> )
							// NewLocPair( <-493.644531, 564.486755, 1603.5238>, <0, -92.8610611, 0> )
							// NewLocPair( <-3309.63281, -1306.48022, 1747.23254>, <0, -89.4712906, 0> )
							// NewLocPair( <-1549.40198, -605.131165, 1891.09448>, <0, -41.4555016, 0> )
							// NewLocPair( <-559.9151, 373.873352, 2035.26245>, <0, -179.922012, 0> )
							// NewLocPair( <-1050.45728, -13.6835155, 1891.25098>, <0, 45.6872673, 0> )
							// NewLocPair( <-1629.19067, 914.860291, 1747.28503>, <0, -86.2542496, 0> )
							// NewLocPair( <-1694.98315, -1930.60071, 1603.94226>, <0, 90.6224976, 0> )
							
							//LAST FLOOR
							NewLocPair( <-2479.39746, -106.087387, 2035.5625> , <0, -89.2331619, 0>  )
							NewLocPair( <-2534.90039, -743.408813, 2035.5625> , <0, 44.1224556, 0>   )
							NewLocPair( <-2087.92065, -586.461121, 2035.5625> , <0, -91.8194504, 0>  )
							NewLocPair( <-1805.71057, -1333.19531, 2035.5415> , <0, 88.1520462, 0>   )
							NewLocPair( <-1640.5155, -1068.18848, 2056.24609> , <0, -176.723526, 0>  )
							NewLocPair( <-1814.75635, -115.28923, 2035.55762> , <0, -1.03344405, 0>  )
							NewLocPair( <-1641.20496, -120.593964, 2035.55762> , <0, 173.957367, 0>  )
							NewLocPair( <-1779.80969, 391.714386, 2035.5498> , <0, -45.5437393, 0>   )
							NewLocPair( <-897.199219, 434.014526, 2035.5498> , <0, -135.050079, 0>   )
							NewLocPair( <-538.778809, 205.983521, 2035.26245> , <0, 91.7738647, 0>   )
							NewLocPair( <-685.678406, 448.78598, 2035.26245> , <0, -88.8440857, 0>   )
							NewLocPair( <-1059.59949, 5.72391796, 2035.54443> , <0, -1.33061111, 0>  )

							//THIRD FLOOR
							NewLocPair( <-1051.25354, -18.2520409, 1891.2323> , <0, 35.894165, 0>    )
							NewLocPair( <-883.290649, 416.887817, 1891.23523> , <0, -141.008392, 0>  )
							NewLocPair( <-1456.18372, 440.4198, 1891.23523> , <0, -88.3338242, 0>    )
							NewLocPair( <-1820.76196, 431.40744, 1891.23523> , <0, -45.7178917, 0>   )
							NewLocPair( <-1657.63879, -175.695541, 1891.23523> , <0, 178.98555, 0>   )
							NewLocPair( <-1211.17944, -641.922363, 1891.09448> , <0, -177.691666, 0> )
							NewLocPair( <-1539.51221, -611.410583, 1891.09448> , <0, -88.8063812, 0> )
							NewLocPair( <-2018.70557, -771.53302, 1891.26245> , <0, 90.5596695, 0>   )
							NewLocPair( <-2543.42358, -754.912231, 1891.26245> , <0, 41.6615105, 0>  )
							NewLocPair( <-2387.93091, -109.931137, 1891.26245> , <0, -127.870018, 0> )

							//SECOND FLOOR
							NewLocPair( <-2373.42554, -546.530884, 1747.26245> , <0, -179.062546, 0> )
							NewLocPair( <-3133.62817, -1346.37793, 1747.26245> , <0, -86.1443787, 0> )
							NewLocPair( <-2830.2605, -1561.58508, 1747.26245> , <0, 92.5576019, 0>   )
							NewLocPair( <-2394.60303, -1538.74646, 1747.26245> , <0, 95.8865891, 0>  )
							NewLocPair( <-2669.08496, -1201.97119, 1747.45471> , <0, -176.5009, 0>   )
							NewLocPair( <-1640.2948, -930.272278, 1747.26245> , <0, 179.087616, 0>   )
							NewLocPair( <-1797.10278, 123.869652, 1747.26245> , <0, -44.7477036, 0>  )
							NewLocPair( <-1010.84167, -115.992599, 1739.34094> , <0, -24.5878944, 0> )
							NewLocPair( <-1544.82947, 462.914215, 1747.89453> , <0, 3.05435944, 0>   )
							NewLocPair( <-1372.5332, 384.429626, 1747.89453> , <0, 88.7193375, 0>    )
							NewLocPair( <-1507.95117, 732.427307, 1747.27856> , <0, 96.0262604, 0>   )
							NewLocPair( <-875.556702, 1833.59204, 1667.2489> , <0, -126.4515, 0>     )
							NewLocPair( <-1557.43372, 1291.58911, 1667.24414> , <0, 3.12751174, 0>   )
							NewLocPair( <-2959.39551, 1138.14685, 1747.26245> , <0, 6.63507128, 0>   )
							NewLocPair( <-2384.896, 1215.32117, 1747.0625> , <0, -124.2127, 0>       )
							NewLocPair( <-2996.4502, 550.881226, 1747.26245> , <0, 33.1215439, 0>    )

							//FIRST FLOOR
							NewLocPair( <-2663.76318, -87.6003952, 1603.44373> , <0, -99.3053055, 0> )
							NewLocPair( <-2136.97778, -462.830048, 1603.44373> , <0, 176.621429, 0>  )
							NewLocPair( <-2309.91406, -1945.68445, 1603.49377> , <0, 15.7578154, 0>  )
							NewLocPair( <-1726.48682, -1921.49207, 1603.49377> , <0, 89.1142273, 0>  )
							NewLocPair( <-1121.93555, -1801.45642, 1603.5238> , <0, 171.585724, 0>   )
							NewLocPair( <-1122.12415, -1234.30688, 1603.5238> , <0, -177.058777, 0>  )
							NewLocPair( <-1371.28381, -757.615112, 1603.5238> , <0, -87.4963684, 0>  )
							NewLocPair( <-1977.63428, -746.468567, 1603.49377> , <0, -80.8907089, 0> )
							NewLocPair( <-1633.69373, -299.144897, 1603.5238> , <0, -174.59227, 0>   )
							NewLocPair( <-2318.68018, 103.165642, 1603.49377> , <0, 44.8486786, 0>   )
							NewLocPair( <-2243.94116, 1290.53271, 1603.49377> , <0, -96.7782135, 0>  )
							NewLocPair( <-906.443359, -4.77661896, 1603.49377> , <0, 114.832176, 0>  )
							NewLocPair( <-507.575226, 560.553711, 1603.5238> , <0, -91.358139, 0>    )
							NewLocPair( <-1633.22815, -352.436554, 1603.5238> , <0, -177.97522, 0>   )
						]
					)
			)
		break
	}
}

//  ██████╗ █████╗ ██╗     ██╗     ██████╗  █████╗  ██████╗██╗  ██╗███████╗
// ██╔════╝██╔══██╗██║     ██║     ██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██╔════╝
// ██║     ███████║██║     ██║     ██████╔╝███████║██║     █████╔╝ ███████╗
// ██║     ██╔══██║██║     ██║     ██╔══██╗██╔══██║██║     ██╔═██╗ ╚════██║
// ╚██████╗██║  ██║███████╗███████╗██████╔╝██║  ██║╚██████╗██║  ██╗███████║
//  ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝

#if SERVER
void function OnPlayerConnected( entity player )
{
	thread OnPlayerConnected_THREAD( player )
}

void function OnPlayerConnected_THREAD(entity player)
{	
	if(!IsValid(player))
		return
	
	EndSignal( player, "OnDestroy" )
	
	while( !player.p.isConnected )
		WaitFrame()
	
	player.SetPlayerGameStat( PGS_DEATHS, 0)
	
	AddEntityCallback_OnDamaged( player, OnPlayerDamaged )
	AddButtonPressedPlayerInputCallback( player, IN_ZOOM_TOGGLE, CancelZoomForSpies )
	AddButtonPressedPlayerInputCallback( player, IN_ZOOM, CancelZoomForSpies )
		
	switch(GetGameState())
	{
		case eGameState.WaitingForPlayers:
			RespawnPlayerInLobby( -1, player )
			break
			
		case eGameState.Prematch: // Vote Team or Selecting Location?
			RespawnPlayerInLobby( -1, player )
			// Open VoteTeamMenu
			player.p.teamasked = -1
			// todo(cafe) it should wait until file.selectTeamEndTime is different to -1
			if( file.selectTeamEndTime != -1 && Time() - file.selectTeamEndTime > 2.0 )
				Remote_CallFunction_UI( player, "Open_FSSND_BuyMenu", file.selectTeamEndTime ) // Team select menu
			break
		
		case eGameState.Playing:
			thread function () : (player)
			{
				EndSignal( player, "OnDestroy" )
				
				while( !file.actuallyPlayingState )
					WaitFrame()
				
				if( player.GetPlatformUID() in file.matchPlayers ) //Reconnected player that crashed or something, put in same team and spawn in game
				{
					int originalTeam = file.matchPlayers[player.GetPlatformUID()]
					SetTeam(player, originalTeam)
					
					RespawnPlayerInSelectedLocation(player, false)
					
					Remote_CallFunction_ByRef( player, "UpdateRUITest" )
				} else // If player is not in game table, kick
					KickPlayerById( player.GetPlatformUID(), "Match already started and you weren't one of the original players" )
				
			}()
			
			break
		
		default:
			RespawnPlayerInLobby( -1, player )
			break
	}
	
	//Load lamps
	thread function () : (player)
	{
		foreach( int i, LampData lamp in file.lamps )
		{
			switch( lamp.type )
			{
				case 1:
				Remote_CallFunction_NonReplay( player, "ServerCallback_SpawnOrModifyClientSideDynamicLight", lamp.origin - Vector(0,0,50), < 0, 0, 0 >, 1, lamp.radius, 5.0, lamp.id )
				break
				case 2:
				Remote_CallFunction_NonReplay( player, "ServerCallback_SpawnOrModifyClientSideDynamicLight", lamp.origin - Vector(0,0,50), < 0, 0, 0 >, 0, lamp.radius, 10.0, lamp.id )
				break
				case 3:
				Remote_CallFunction_NonReplay( player, "ServerCallback_SpawnOrModifyClientSideDynamicLight", lamp.origin - Vector(0,0,50), < 0, 0, 0 >, 9, lamp.radius, 10.0, lamp.id )
				break
			}
			
			// lamp.enabled = true
			
			#if DEVELOPER
			if( player == gp()[0] )
				printw("spawned lamp", i + 1, "type", lamp.type)
			#endif
		}
	}()
}

void function CancelZoomForSpies( entity player )
{
	if( !IsValid( player ) || player.GetTeam() != gCurrentSpyTeam )
		return
	
	ClientCommand( player, "-zoom" ) //Hack
}

void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if( DamageInfo_GetDamageSourceIdentifier( damageInfo ) == eDamageSourceId.damagedef_despawn )
		return

	#if DEVELOPER
	printw( "OnPlayerKilled", victim, "- ATTACKER", attacker )
	#endif
	
	thread OnPlayerKilled_THREAD( victim )
}

void function OnPlayerKilled_THREAD( entity player )
{
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "OnRespawnedFromRoundEnd" ) // Cancel this thread in case round ends and player was respawned from EndRound function
	
	player.SetPlayerNetInt( "respawnStatus", eRespawnStatus.WAITING_FOR_DROPPOD )
	player.SetPlayerNetTime( "respawnStatusEndTime", Time() + TIME_TO_RESPAWN )
	Remote_CallFunction_NonReplay( player, "ServerCallback_DisplayWaitingForRespawn", player, Time(), player.GetPlayerNetTime( "respawnStatusEndTime" ) )
	Remote_CallFunction_ByRef( player, "ServerCallback_ShowDeathScreen" )

	wait TIME_TO_START_SPECTATING
	
	thread ObserverThread( player )

	wait TIME_TO_RESPAWN - TIME_TO_START_SPECTATING
	
	RespawnPlayerInSelectedLocation(player, false)
}

void function OnPlayerRespawned( entity player )
{
	//
}

void function _EntitiesDidLoad()
{
	// SetConVarFloat( "thirdperson_override", 1 )
	
	switch( MapName() )
	{
		case eMaps.mp_rr_desertlands_64k_x_64k:
			SpawnOITCRoom( <0,0,50000> )

			file.lobbySpawns.append( NewLocPair( <757.325012, -515.943542, 50001>, <0, 178.960648, 0> ) )
			file.lobbySpawns.append( NewLocPair( <-149.636932, 70.9458618, 50000.0625> , <0, -91.6047058, 0> ) )
			file.lobbySpawns.append( NewLocPair( <-900.124146, -1340.46216, 50000.0625> , <0, 0.491333365, 0> ) )
			file.lobbySpawns.append( NewLocPair( <901.963074, -808.002563, 50151.8633> , <0, -89.5183563, 0> ) )
			file.lobbySpawns.append( NewLocPair( <-2007.54846, -493.074036, 50092.6367> , <0, -52.2841835, 0> ) )
			file.lobbySpawns.append( NewLocPair( <559.942566, -1483.20251, 50180.0273> , <0, 145.356369, 0> ) )
		break

		case eMaps.mp_rr_olympus:
			file.lobbySpawns.append( NewLocPair( <-36691.5195, 10648.4697, -5563.96875>, <0, -1.32621336, 0> ) )
		break
		
		case eMaps.mp_rr_arena_empty:
			PrecacheHotel()
			
			SpawnOITCRoom( <0,0,50000> )
			
			file.lobbySpawns.append( NewLocPair( <757.325012, -515.943542, 50001>, <0, 178.960648, 0> ) )
			file.lobbySpawns.append( NewLocPair( <-149.636932, 70.9458618, 50000.0625> , <0, -91.6047058, 0> ) )
			file.lobbySpawns.append( NewLocPair( <-900.124146, -1340.46216, 50000.0625> , <0, 0.491333365, 0> ) )
			file.lobbySpawns.append( NewLocPair( <901.963074, -808.002563, 50151.8633> , <0, -89.5183563, 0> ) )
			file.lobbySpawns.append( NewLocPair( <901.963074, -808.002563, 50151.8633> , <0, -89.5183563, 0> ) ) //test
			// file.lobbySpawns.append( NewLocPair( <-2007.54846, -493.074036, 50092.6367> , <0, -52.2841835, 0> ) )	
			file.lobbySpawns.append( NewLocPair( <559.942566, -1483.20251, 50180.0273> , <0, 145.356369, 0> ) )

			THREAD_LampsFlickering()
		break
	}
}

void function DEV_TestSelectTeamMenuVotes( int imcVotes, int militiaVotes )
{
	foreach( player in GetPlayerArray() )
	{
		Remote_CallFunction_UI( player, "SND_UpdateVotesForTeam", 0, imcVotes )
		Remote_CallFunction_UI( player, "SND_UpdateVotesForTeam", 1, militiaVotes )
	}
}

//  ██████╗██╗     ██╗███████╗███╗   ██╗████████╗     ██████╗ ██████╗ ███╗   ███╗███╗   ███╗ █████╗ ███╗   ██╗██████╗ ███████╗
// ██╔════╝██║     ██║██╔════╝████╗  ██║╚══██╔══╝    ██╔════╝██╔═══██╗████╗ ████║████╗ ████║██╔══██╗████╗  ██║██╔══██╗██╔════╝
// ██║     ██║     ██║█████╗  ██╔██╗ ██║   ██║       ██║     ██║   ██║██╔████╔██║██╔████╔██║███████║██╔██╗ ██║██║  ██║███████╗
// ██║     ██║     ██║██╔══╝  ██║╚██╗██║   ██║       ██║     ██║   ██║██║╚██╔╝██║██║╚██╔╝██║██╔══██║██║╚██╗██║██║  ██║╚════██║
// ╚██████╗███████╗██║███████╗██║ ╚████║   ██║       ╚██████╗╚██████╔╝██║ ╚═╝ ██║██║ ╚═╝ ██║██║  ██║██║ ╚████║██████╔╝███████║
//  ╚═════╝╚══════╝╚═╝╚══════╝╚═╝  ╚═══╝   ╚═╝        ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ ╚══════╝

bool function ClientCommand_AskForTeam(entity player, array < string > args) 
{	
	if( !IsValid(player) || args.len() != 1 || !file.selectTeamMenuOpened ) return false

	if( player.p.teamasked != -1 )
	{
		if( player.p.teamasked == 0 )
		{
			file.requestsforIMC--
			
			foreach( sPlayer in GetPlayerArray() )
			{
				if( !IsValid(sPlayer) ) continue
				
				Remote_CallFunction_UI( sPlayer, "SND_UpdateVotesForTeam", 0, file.requestsforIMC )
			}
		} else if(  player.p.teamasked == 1 )
		{
			file.requestsforMILITIA--
			
			foreach( sPlayer in GetPlayerArray() )
			{
				if( !IsValid(sPlayer) ) continue
				
				Remote_CallFunction_UI( sPlayer, "SND_UpdateVotesForTeam", 1, file.requestsforMILITIA )
			}
		}
	}
	
	switch(args[0])
	{
		case "0":
			if(file.requestsforIMC < file.maxvotesallowedforTeamIMC)
			{
				player.p.teamasked = 0
				file.requestsforIMC++
				
				foreach( sPlayer in GetPlayerArray() )
				{
					if( !IsValid(sPlayer) ) continue
					
					Remote_CallFunction_UI( sPlayer, "SND_UpdateVotesForTeam", 0, file.requestsforIMC )
				}
			}
		break
		
		case "1":
			if(file.requestsforMILITIA < file.maxvotesallowedforTeamMILITIA)
			{
				player.p.teamasked = 1
				file.requestsforMILITIA++

				foreach( sPlayer in GetPlayerArray() )
				{
					if( !IsValid(sPlayer) ) continue
					
					Remote_CallFunction_UI( sPlayer, "SND_UpdateVotesForTeam", 1, file.requestsforMILITIA )
				}
			}		
		break
		
		// Reenable disabled buttons
		default:
			player.p.teamasked = -1
		break
	}	
	
	return true
}

bool function ClientCommand_RequestGadgets(entity player, array < string > args) 
{	
	if( !IsValid(player) || args.len() != 3 ) 
		return false
	
	int team = args[0].tointeger()
	int idx1 = args[1].tointeger() - 1
	int idx2 = args[2].tointeger() - 1
	
	if( !player.p.canChangeGadgets )
		return false
	
	if( team == 0 && player.GetTeam() != gCurrentSpyTeam )
		return false

	if( team == 1 && player.GetTeam() != gCurrentMercTeam )
		return false
	
	array<AbilityData> pool = ( team == 0 ) ? file.spyGadgets : file.mercGadgets

	if ( team < 0 || team > 1 )
		return false
	
	// If is game starting
	if( player.p.isGameStart && GetGameState() == eGameState.Playing && file.actuallyPlayingState )
	{
		NotifyHackingState( eHackingStateNotifyReason.ROUND_START, player )
		player.p.isGameStart = false
	}
		
	if ( idx1 < 0 || idx1 >= pool.len() || idx2 < 0 || idx2 >= pool.len() )
		return false
	
	if ( idx1 == idx2 )
		return false
	
	player.p.selectedGadget1 = idx1
	player.p.selectedGadget2 = idx2

	player.TakeOffhandWeapon(OFFHAND_TACTICAL)
	player.TakeOffhandWeapon(OFFHAND_ULTIMATE)
	
	player.GiveOffhandWeapon(pool[idx1].weaponName, OFFHAND_TACTICAL)
	player.GiveOffhandWeapon(pool[idx2].weaponName, OFFHAND_ULTIMATE)	

	return true
}

// ██████╗  █████╗ ███╗   ███╗ █████╗  ██████╗ ███████╗     ██████╗ █████╗ ██╗     ██╗     ██████╗  █████╗  ██████╗██╗  ██╗███████╗
// ██╔══██╗██╔══██╗████╗ ████║██╔══██╗██╔════╝ ██╔════╝    ██╔════╝██╔══██╗██║     ██║     ██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██╔════╝
// ██║  ██║███████║██╔████╔██║███████║██║  ███╗█████╗      ██║     ███████║██║     ██║     ██████╔╝███████║██║     █████╔╝ ███████╗
// ██║  ██║██╔══██║██║╚██╔╝██║██╔══██║██║   ██║██╔══╝      ██║     ██╔══██║██║     ██║     ██╔══██╗██╔══██║██║     ██╔═██╗ ╚════██║
// ██████╔╝██║  ██║██║ ╚═╝ ██║██║  ██║╚██████╔╝███████╗    ╚██████╗██║  ██║███████╗███████╗██████╔╝██║  ██║╚██████╗██║  ██╗███████║
// ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝     ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝

void function ProximityMine_SetDamage( entity player, var damageInfo )
{
	if ( !IsValid( player ) || !player.IsPlayer() )
		return
	
	if( player.GetTeam() == gCurrentMercTeam )
		DamageInfo_SetDamage( damageInfo, 0 )
}

void function ElectricGrenade_SmokeHighlights( entity player, var damageInfo )
{
	if ( !IsValid( player ) || !player.IsPlayer() )
		return
	
	if( player.GetTeam() == gCurrentMercTeam )
	{
		// Don't damage mercs
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}
	
	thread function () : ( player, damageInfo )
	{
		Signal( player, "RestartHighlightThread" )
		EndSignal( player, "RestartHighlightThread" )
		EndSignal( player, "OnDeath" )

		// Immediately remove cloak when shooting
		if ( player.IsCloaked( true ) )
			player.SetCloakDuration( 0, 0, 0.2 )

		// Set auto-cloak cooldown for Spy team
		player.p.nextAutoCloakTime = Time() + AUTOCLOAK_CD_TIME
		
		Signal( player, "Signal_OnWeaponAttack" )
		
		Highlight_SetEnemyHighlight( player, "hackers_wallhack" )
		wait 1
		Highlight_ClearEnemyHighlight( player )
	}()
}

 // ██████╗  █████╗ ███╗   ███╗███████╗    ██╗      ██████╗  ██████╗ ██████╗ 
// ██╔════╝ ██╔══██╗████╗ ████║██╔════╝    ██║     ██╔═══██╗██╔═══██╗██╔══██╗
// ██║  ███╗███████║██╔████╔██║█████╗      ██║     ██║   ██║██║   ██║██████╔╝
// ██║   ██║██╔══██║██║╚██╔╝██║██╔══╝      ██║     ██║   ██║██║   ██║██╔═══╝ 
// ╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗    ███████╗╚██████╔╝╚██████╔╝██║     
//  ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝    ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝     

void function SpiesLegends_Prematch()
{
	thread function () : ()
	{
		#if DEVELOPER
		printw( "GameState - Prematch" )
		#endif
		// wait 3
		
		// ScreenCoverTransition_AllPlayers( Time() + 5 )
		
		// wait 2
		
		//Destroy hotel map
		// foreach( prop in file.mapProps )
		// {
			// if( IsValid( prop ) && !GetLobbySpawnedProps().contains( prop ) )
				// prop.Destroy()
		// }
		// file.mapProps.clear()
		
		// WaitFrame()
		
		// //Create lobby
		// if( GetLobbySpawnedProps().len() == 0 ) // For next game
			// SpawnOITCRoom( <0,0,50000> )
		
		// wait 2

		foreach( int i, entity player in GetPlayerArray() )
		{
			if( !player.p.isConnected )
				waitthread function () : ( player )
				{
					while( !player.p.isConnected )
						WaitFrame()
				}()
		}
		
		//End Minigames
		
		foreach( int i, entity player in GetPlayerArray() )
		{
			if(!IsValid(player)) continue
			
			if( !player.p.isInLobby )
				RespawnPlayerInLobby( i, player )
		}
		
		//Vote Team
		//Select Location
		
		//After one match is finished, check if there are less than min players, if so, set game state to waiting for players

		if ( !file.mapIndexChanged )
		{
			if( file.locationSettings.len() > 0 )
				file.nextMapIndex = ( file.nextMapIndex + 1 ) % file.locationSettings.len()
		}

		int choice = file.nextMapIndex
		file.mapIndexChanged = false

		//if( !VOTING_PHASE_ENABLE )
		//{
			if( choice in file.locationSettings )
				file.selectedLocation = file.locationSettings[ choice ]
			
			//if( FlowState_LockPOI() )
				//file.selectedLocation = file.locationSettings[ DetermineLockedPOI() ]
		//}
		//else
		//{
			//file.selectedLocation = file.locationSettings[ FS_DM.mappicked ]
		//}
		
		//////////////
		////////////// Select Team Menu
		if( SELECT_TEAM_MENU_ENABLED )
		{
			file.selectTeamEndTime = Time() + SELECT_TEAM_TIME
			
			file.maxvotesallowedforTeamIMC = int(min(ceil(float(GetPlayerArray().len()) / float(2)), 5.0))
			file.maxvotesallowedforTeamMILITIA = GetPlayerArray().len() - file.maxvotesallowedforTeamIMC

			#if DEVELOPER
			printw( "MAX VOTES FOR IMC TEAM:" + file.maxvotesallowedforTeamIMC, "- MAX VOTES FOR MILITIA TEAM:" + file.maxvotesallowedforTeamMILITIA )
			#endif
			
			foreach( sPlayer in GetPlayerArray() )
			{
				if( !IsValid(sPlayer) ) continue
				
				Remote_CallFunction_UI( sPlayer, "SND_UpdateMaxVotesForTeam", TEAM_IMC, file.maxvotesallowedforTeamIMC )
				Remote_CallFunction_UI( sPlayer, "SND_UpdateMaxVotesForTeam", TEAM_MILITIA, file.maxvotesallowedforTeamMILITIA )
			}
			
			file.requestsforIMC = 0
			file.requestsforMILITIA = 0
			
			foreach ( player in GetPlayerArray() )
			{
				if(!IsValid(player)) continue
				
				Remote_CallFunction_ByRef( player, "FS_ShowRoundStartSelectingTeamTimeUI" )
			}
			
			wait 3
			
			file.selectTeamMenuOpened = true
 
			foreach ( player in GetPlayerArray() )
			{
				if(!IsValid(player)) continue
				
				player.p.teamasked = -1
				Remote_CallFunction_UI( player, "Open_FSSND_BuyMenu", file.selectTeamEndTime)	//Team select menu
			}

			wait SELECT_TEAM_TIME + 0.5
			
			GiveSelectedTeamToPlayer()
			
			foreach ( player in GetPlayerArray() )
			{
				if(!IsValid(player)) continue

				Remote_CallFunction_UI( player, "Close_FSSND_BuyMenu")
			}
			
			file.selectTeamEndTime = -1
			file.selectTeamMenuOpened = false
		} else
		////////////// End Select Team Menu
		//////////////
		{
			// Legacy give team logic
			array<entity> players = GetPlayerArray()
			if( !debug )
				players.randomize()
			
			for(int i = 0; i < players.len(); i++)
			{
				entity player = players[i]
				
				if(i % 2 == 0)
				{
					SetTeam(player, TEAM_IMC)
				}
				else
				{
					SetTeam(player, TEAM_MILITIA)
				}
			}
			wait 5
		}
		
		SetGameState( eGameState.Playing )
	}()
}


void function GiveSelectedTeamToPlayer()
{
	int newIMC = 0
	int newMILITIA = 0
	
	array<int> togiveCharacters = [1,2,3,4,5,6,7,8,9,10,11,12] //clone snd_allowedCharacters
	togiveCharacters.randomize()
	
	foreach( player in GetPlayerArray() )
	{
		if(!IsValid(player)) 
			continue
		
		if(player.p.teamasked != -1)
		{
			switch(player.p.teamasked)
			{
				case 0:
					SetTeam(player, TEAM_IMC )

					// //Set ppink
					player.SetSkin(2) //full body camo skin, works for all characters very nice
					player.SetCamo(IMC_color)
					
					newIMC++
					
					continue
				case 1:
					SetTeam(player, TEAM_MILITIA )

					// //Set blue
					player.SetSkin(2)
					player.SetCamo(MILITIA_color)
					
					newMILITIA++
					continue
			}
		}
		
		if( newMILITIA < file.maxvotesallowedforTeamMILITIA )
		{
			SetTeam( player, TEAM_MILITIA )

			//Set blue
			player.SetSkin(2)
			player.SetCamo(MILITIA_color)
			
			newMILITIA++
			continue
		}
		
		if (newIMC < file.maxvotesallowedforTeamIMC)
		{
			SetTeam( player, TEAM_IMC )

			//Set pink
			player.SetSkin(2)
			player.SetCamo(IMC_color)
			
			newIMC++
			continue
		}
	}
	
	foreach ( player in GetPlayerArray() )
	{
		if(!IsValid(player)) continue
		
		Remote_CallFunction_ByRef( player, "UpdateRUITest" )
		
		file.matchPlayers[player.GetPlatformUID()] <- player.GetTeam()
		#if DEVELOPER
		printw( "PLAYER SAVED IN MATCH PLAYERS", player.GetPlayerName(), player.GetPlatformUID(), player.GetTeam() )
		#endif
	}
}

void function SpiesLegends_MatchStarted()
{
	thread function () : ()
	{
		#if DEVELOPER
		printw( "GameState - Match Started" )
		#endif
		
		foreach( int i, entity player in GetPlayerArray() )
		{
			ScreenFadeToBlack( player, 0.5, 5 )
		}
		
		wait 2
		
		//Destroy Lobby
		foreach( lobbyProp in GetLobbySpawnedProps() )
		{
			if( IsValid( lobbyProp ) )
				lobbyProp.Destroy()
		}
		GetLobbySpawnedProps().clear()
		
		WaitFrame()
		
		HotelMapTest()
		wait 0.1
		HotelMapTest2()
		wait 0.1
		HotelMapTest3()
		wait 0.1
		
		wait 2
		
		//Respawn Player in the Selected Location, it should Open Pick Loadut Menu
		//Game starts after 5 seconds
		//Resets vars
		
		//Ring
		CalculateRingCenterAndRadius(file.selectedLocation.playerSpawns)
		file.ring = CreateRing()
		
		currentRound = 0
		SetGlobalNetInt( "FS_SpiesRoundNumber", currentRound )
		IMC_Score = 0
		MILITIA_Score = 0
		
		foreach( int i, entity player in GetPlayerArray() )
		{
			if(!IsValid(player)) continue
			
			Remote_CallFunction_NonReplay( player, "ServerToClient_UpdateScoreHUD", -1, 0 )
		}
		
		if( !debug )
		{
			gCurrentSpyTeam = CoinFlip() ? TEAM_IMC : TEAM_MILITIA	// Track which team is currently spies
			gCurrentMercTeam = gCurrentSpyTeam == TEAM_IMC ? TEAM_MILITIA : TEAM_IMC // Track which team is currently mercs
		} else
		{
			gCurrentSpyTeam = TEAM_IMC	// Track which team is currently spies
			gCurrentMercTeam = TEAM_MILITIA // Track which team is currently mercs
		}
		
		thread StartNextRound()
	}()
}

void function StartNextRound()
{
	currentRound++
	SetGlobalNetInt( "FS_SpiesRoundNumber", currentRound )

    // Clear spawn tracking for new round
    ClearSpawnTracking()
	
	hackedTerminalsCount = 0
	SetGlobalNetInt( "FS_SpiesTerminalsHacked", hackedTerminalsCount )
	
	isAnyTerminalBeingHacked = false
	SetGlobalNetBool( "FS_SpiesIsRoundExtended", false )
	
	// Swap roles every round
	if( currentRound > 1 )
	{
		int temp = gCurrentSpyTeam
		gCurrentSpyTeam = gCurrentMercTeam
		gCurrentMercTeam = temp
	}
	
	SetGlobalNetInt( "FS_SpyTeam", gCurrentSpyTeam )
	
	#if DEVELOPER
	printw( "StartNextRound - CURRENT ROUND: ", currentRound )
	#endif
	
	// Reset Hotel Vents
	if( MapName() == eMaps.mp_rr_arena_empty )
		CreateHotelVents()
	
	// Reset terminals
	ResetAllTerminals()
	
	// Cleanup tracked end such as proximity mines etc
	CleanupLevelTrackedEnts()
	
	// Assign roles to fixed teams
	array<entity> imcPlayers = GetPlayerArrayOfTeam(TEAM_IMC)
	array<entity> militiaPlayers = GetPlayerArrayOfTeam(TEAM_MILITIA)

	// Spawn players
	foreach(int i, entity player in GetPlayerArray())
	{
		if(!IsValid(player)) continue
		
		RespawnPlayerInSelectedLocation(player, true)
		
		Remote_CallFunction_ByRef( player, "UpdateRUITest" )
	}
	
	RoundStartCountdown()

	foreach( int i, entity player in GetPlayerArray_Alive() )
	{
		if(!IsValid(player)) continue
		
		player.UnfreezeControlsOnServer()
		
		player.p.canChangeGadgets = true
		player.p.isGameStart = true
		Remote_CallFunction_UI(player, "GadgetsSelector_Open", player.GetTeam() == gCurrentSpyTeam ? 0 : 1 )
	}
	
	file.actuallyPlayingState = true
	
	// Start round timer
	RoundTimerThink()
}

void function RoundStartCountdown()
{
	float roundStartsIn = Time() + ROUND_START_DELAY_TIME
	
	while(Time() < roundStartsIn)
	{
		#if DEVELOPER
		printw( "Round Starting.." )
		#endif
		wait 1.0
	}
}

void function RoundTimerThink()
{
	#if DEVELOPER
	printw( "RoundTimerThink TIMER STARTED" )
	#endif
	
	EndSignal( svGlobal.levelEnt, "RoundEndedFromHackingTerminals" )
	
	OnThreadEnd(
		function() : ( )
		{
			#if DEVELOPER
			printw( "RoundTimerThink TIMER ENDED" )
			#endif
		}
	)
	
	SetGlobalNetTime( "FS_SpiesRoundEndTime", Time() + ROUND_TIME )
	
	while( Time() < GetGlobalNetTime( "FS_SpiesRoundEndTime" ) && !GetGlobalNetBool( "FS_SpiesIsRoundExtended" ) )
		wait 1.0

	while( GetGlobalNetBool( "FS_SpiesIsRoundExtended" ) )
		wait 1.0
	
	SetGlobalNetTime( "FS_SpiesRoundEndTime", -1 )

	// Cancel any ongoing hack try
	foreach( terminal in activeTerminals )
		if( IsValid( terminal ) )
			ClearChildren( terminal, true )
	
	foreach( player in GetPlayerArray() )
	{
		if(!IsValid(player)) continue
		
		Signal( player, "ScriptAnimStop" )
	}
		
	wait 3
	
	// End round if terminals aren’t all hacked. Only trigered if round time ended
	if(hackedTerminalsCount < REQUIRED_HACKS)
		EndRound( gCurrentMercTeam ) // Give victory to mercs if spies didn't hack enough terminals
}

void function DEV_ForceEndRound()
{
	printw( "DEV_ForceEndRound" )
	SetGlobalNetTime( "FS_SpiesRoundEndTime", Time() )
}

void function ResetAllTerminals()
{
	// Destroy existing terminals
	foreach(entity terminal in activeTerminals)
	{
		foreach( player in GetPlayerArray() )
		{
			if(!IsValid(player)) continue
			
			if( player.GetParent() == terminal )
				player.ClearParent()
		}
		
		if( IsValid( terminal.e.hackableTerminalWaypoint ) )
			terminal.e.hackableTerminalWaypoint.Destroy()
		
		if( IsValid( terminal.e.dummyPanelForMercs ) )
			terminal.e.dummyPanelForMercs.Destroy()

		terminal.Destroy()
	}
	
	activeTerminals.clear()
	recentTerminalSpawnHistory.clear()
	activeHacks.clear()
	
	//Free up this spawn point
	foreach(int i, TerminalSpawn spawn in file.selectedLocation.terminalSpawns)
	{
		spawn.isOccupied = false
	}
	
	// Reinitialize from your original code
	InitTerminalSystem()
}

void function EndRound( int winningTeam )
{
	// Update scores for fixed teams
	if(winningTeam == TEAM_IMC)
		IMC_Score++
	else
		MILITIA_Score++

	#if DEVELOPER
	printw("ROUND ENDED, WINNER: ", winningTeam == gCurrentSpyTeam ? "SPIES" : "MERCS", 
		  "- IMC SCORE: ", IMC_Score, 
		  "- MILITIA SCORE: ", MILITIA_Score, gCurrentSpyTeam == TEAM_IMC ? "SPIES WERE IMC" : "SPIES WERE MILITIA" )
	#endif

	foreach( player in GetPlayerArray( ) )
	{
		if(!IsValid(player)) continue
		
		Remote_CallFunction_NonReplay( player, "FS_Spies_Center_Msg", eGoalMsgID.ForceRemoveMsg, -1, -1, -1 )
		Remote_CallFunction_NonReplay( player, "ServerToClient_UpdateScoreHUD", winningTeam, winningTeam == TEAM_IMC ? IMC_Score : MILITIA_Score )
		Remote_CallFunction_UI(player, "GadgetsSelector_Close" )
		player.p.canChangeGadgets = false
	}
	
	// Check match winner
	if(IMC_Score > 2 || MILITIA_Score > 2)
	{
		thread function () : ( )
		{
			SetGameState( eGameState.WinnerDetermined )
			
			foreach( int i, entity player in GetPlayerArray() )
			{
				if(!IsValid(player)) continue
				
				if( !IsAlive( player ) )
				{
					Signal( player, "OnRespawnedFromRoundEnd" )
					RespawnPlayerInSelectedLocation(player, false)
				}
			}
			
			wait 1
			
			foreach( player in GetPlayerArray() )
			{
				if(!IsValid(player)) continue
				
				// Message( player, IMC_Score >= 2 ? "TEAM IMC WIN" : "TEAM MILITIA WIN" , "Game Over" )
				
				Remote_CallFunction_NonReplay( player, "ServerCallback_MatchEndAnnouncement", true, IMC_Score >= 2 ? TEAM_IMC : TEAM_MILITIA )
			}
			
			wait 8
			
			foreach( player in GetPlayerArray() )
			{
				if(!IsValid(player)) continue
				
				Remote_CallFunction_ByRef( player, "ServerCallback_DestroyEndAnnouncement" )
			}
			
			EndMatch()
		}()
	}
	else
	{
		thread function () : ( winningTeam )
		{	
			// Round End
			// Res dead players
			// Make player invincible
			// Restrict abilities usage
			// Start round winner screen
			// What else?
			
			WaitEndFrame()
			
			foreach( int i, entity player in GetPlayerArray() )
			{
				if(!IsValid(player)) continue
				
				if( !IsAlive( player ) )
				{
					Signal( player, "OnRespawnedFromRoundEnd" )
					RespawnPlayerInSelectedLocation(player, false)
				}
			}
			
			WaitFrame()
			
			foreach( int i, entity player in GetPlayerArray() )
			{
				if(!IsValid(player)) continue
				
				if( !IsInvincible(player ) )
					MakeInvincible(player)
				
				player.MovementDisable()
				DisableOffhandWeapons( player )
				
				Remote_CallFunction_NonReplay( player, "ServerToClient_RoundWinnerScreen", winningTeam, gCurrentSpyTeam)
			}
			
			wait 6
			
			foreach( int i, entity player in GetPlayerArray() )
			{
				ScreenFadeToBlack( player, 2, 1 )
			}
			
			wait 2
			
			thread StartNextRound()
		}()
	}
}


void function EndMatch()
{
	#if DEVELOPER
	printw("GAME ENDED" )
	#endif
	
	if( IsValid( file.ring ) )
		file.ring.Destroy()
	
	SetDeathFieldParams( <0,0,0>, 100000, 0, 90000, 99999 )
	
	file.actuallyPlayingState = false
	file.matchPlayers.clear()
	
	GameRules_ChangeMap( GetMapName(), GameRules_GetGameMode() ) //temp fix for hotel map crashing the map after spawning it again for some reason, prob will leave like this
	// SetGameState( eGameState.Prematch )
}

// ██████╗ ██╗███╗   ██╗ ██████╗ 
// ██╔══██╗██║████╗  ██║██╔════╝ 
// ██████╔╝██║██╔██╗ ██║██║  ███╗
// ██╔══██╗██║██║╚██╗██║██║   ██║
// ██║  ██║██║██║ ╚████║╚██████╔╝
// ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝

entity function CreateRing()
{
	vector ringCenter = file.ringCenter
	float ringRadius = file.ringRadius

	entity circle = CreateEntity( "prop_script" )
	circle.SetValueForModelKey( $"mdl/fx/ar_survival_radius_1x100.rmdl" )
	circle.kv.fadedist = -1
	circle.kv.modelscale = ringRadius
	circle.kv.renderamt = 255
	circle.kv.rendercolor = FlowState_RingColor()
	circle.kv.solid = 0
	circle.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
	circle.SetOrigin( ringCenter )
	circle.SetAngles( <0, 0, 0> )
	circle.NotSolid()
	circle.DisableHibernation()
	circle.Minimap_SetObjectScale( min(ringRadius / SURVIVAL_MINIMAP_RING_SCALE, 1) )
	circle.Minimap_SetAlignUpright( true )
	circle.Minimap_SetZOrder( 2 )
	circle.Minimap_SetClampToEdge( true )
	circle.Minimap_SetCustomState( eMinimapObject_prop_script.OBJECTIVE_AREA )
	SetTargetName( circle, "hotZone" )
	DispatchSpawn(circle)

	foreach ( player in GetPlayerArray() )
	{
		circle.Minimap_AlwaysShow( 0, player )
	}

	SetDeathFieldParams( ringCenter, ringRadius, ringRadius, 90000, 99999 ) // This function from the API allows client to read ringRadius from server so we can use visual effects in shared function. Colombia

	//Audio thread for ring
	foreach(sPlayer in GetPlayerArray())
		thread AudioThread(circle, sPlayer, ringRadius)

	//Damage thread for ring
	thread RingDamage(circle, ringRadius)

	return circle
}

void function AudioThread(entity circle, entity player, float radius)
{
	EndSignal(player, "OnDestroy")
	EndSignal(circle, "OnDestroy")
	
	entity audio
	string soundToPlay = "Survival_Circle_Edge_Small"
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

	while(IsValid(circle) && IsValid(player))
	{
		vector fwdToPlayer   = Normalize( <player.GetOrigin().x, player.GetOrigin().y, 0> - <circle.GetOrigin().x, circle.GetOrigin().y, 0> )
		vector circleEdgePos = circle.GetOrigin() + (fwdToPlayer * radius)
		circleEdgePos.z = player.EyePosition().z
		if ( fabs( circleEdgePos.x ) < 61000 && fabs( circleEdgePos.y ) < 61000 && fabs( circleEdgePos.z ) < 61000 )
		{
			audio.SetOrigin( circleEdgePos )
		}
		wait 0.1
	}

	StopSoundOnEntity(audio, soundToPlay)
}

void function RingDamage( entity circle, float currentRadius)
{
	EndSignal(circle, "OnDestroy")
	
	WaitFrame()
	
	const float DAMAGE_CHECK_STEP_TIME = 1.5

	while ( IsValid(circle) )
	{
		foreach ( player in GetPlayerArray_Alive() )
		{
			if(!IsValid(player)) continue
			
			if ( player.IsPhaseShifted() )
				continue

			float playerDist = Distance2D( player.GetOrigin(), circle.GetOrigin() )
			if ( playerDist > currentRadius )
			{
				Remote_CallFunction_Replay( player, "ServerCallback_PlayerTookDamage", 0, <0, 0, 0>, DF_BYPASS_SHIELD | DF_DOOMED_HEALTH_LOSS, eDamageSourceId.deathField, 0 )
				player.TakeDamage( int( Deathmatch_GetOOBDamagePercent() / 100 * float( player.GetMaxHealth() ) ), null, null, { scriptType = DF_BYPASS_SHIELD | DF_DOOMED_HEALTH_LOSS, damageSourceId = eDamageSourceId.deathField } )
			}
		}
		wait DAMAGE_CHECK_STEP_TIME
	}
}

void function CalculateRingCenterAndRadius( array<LocPair> playerSpawns )
{
	array<LocPair> spawns
	spawns.extend( playerSpawns )
	
	vector finalCenter

	foreach ( spawnLocation in spawns )
	{
		finalCenter += spawnLocation.origin
	}

	finalCenter.x /= float( spawns.len() )
	finalCenter.y /= float( spawns.len() )
	finalCenter.z /= float( spawns.len() )

	file.ringCenter = OriginToGround_Inverse( finalCenter )
	file.ringRadius = 0

	foreach( LocPair spawn in spawns )
	{
		if( Distance2D( spawn.origin, file.ringCenter ) > file.ringRadius )
			file.ringRadius = Distance2D(spawn.origin, file.ringCenter )
	}

	file.ringRadius += RING_RADIUS_PADDING
}

vector function OriginToGround_Inverse( vector origin )
{
	vector startorigin = origin - < 0, 0, 1000 >
	TraceResults traceResult = TraceLine( startorigin, origin + < 0, 0, 128 >, [], TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_NONE )

	return traceResult.endPos
}

// ██████╗ ███████╗███████╗██████╗  █████╗ ██╗    ██╗███╗   ██╗    ██╗      ██████╗  ██████╗ ██╗ ██████╗
// ██╔══██╗██╔════╝██╔════╝██╔══██╗██╔══██╗██║    ██║████╗  ██║    ██║     ██╔═══██╗██╔════╝ ██║██╔════╝
// ██████╔╝█████╗  ███████╗██████╔╝███████║██║ █╗ ██║██╔██╗ ██║    ██║     ██║   ██║██║  ███╗██║██║     
// ██╔══██╗██╔══╝  ╚════██║██╔═══╝ ██╔══██║██║███╗██║██║╚██╗██║    ██║     ██║   ██║██║   ██║██║██║     
// ██║  ██║███████╗███████║██║     ██║  ██║╚███╔███╔╝██║ ╚████║    ███████╗╚██████╔╝╚██████╔╝██║╚██████╗
// ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚═╝  ╚═╝ ╚══╝╚══╝ ╚═╝  ╚═══╝    ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝ ╚═════╝

void function SpiesLegends_DecideRespawnPlayer( entity player )
{
	player.ClearParent()
	
	// if( IsAlive( player ) )
		// player.Die( null, null, { damageSourceId = eDamageSourceId.damagedef_despawn } ) //not required at all
	
	DoRespawnPlayer( player, null )
	
	PlayerStopSpectating( player )
	
	if( player.GetTeam() == gCurrentSpyTeam )
	{
		// SetItemFlavorLoadoutSlot( ToEHI( player ), Loadout_CharacterClass(), GetAllCharacters()[1] ) //was 8(wraith)
		CharacterSelect_AssignCharacter(ToEHI(player), GetAllCharacters()[3]) //to force the player class changed callback
		CharacterSelect_AssignCharacter(ToEHI(player), GetAllCharacters()[1])
	
		player.SetBodyModelOverride( $"mdl/Humans/pilots/w_agent.rmdl" )
		player.SetArmsModelOverride( $"mdl/Humans/pilots/ptpov_agent.rmdl" )
		
		player.SetPlayerSettingsWithMods( $"settings/player/mp/pilot_spieslegends_no3psounds.rpak", [] )
		player.SetThirdPersonShoulderModeOn()
	}
	else
	{
		// SetItemFlavorLoadoutSlot( ToEHI( player ), Loadout_CharacterClass(), GetAllCharacters()[1] ) //was 3(gibby)
		CharacterSelect_AssignCharacter(ToEHI(player), GetAllCharacters()[3]) //to force the player class changed callback
		CharacterSelect_AssignCharacter(ToEHI(player), GetAllCharacters()[1])

		player.SetBodyModelOverride( $"mdl/Humans/pilots/w_nickmercs_hodded.rmdl" )
		player.SetArmsModelOverride( $"mdl/Humans/pilots/ptpov_nickmercs_hodded.rmdl" )
		
		player.SetPlayerSettingsWithMods( $"settings/player/mp/pilot_survival_tracker.rpak", [] )
		player.SetThirdPersonShoulderModeOff()
	}
	
	TakeLoadoutRelatedWeapons( player )
	TakeAllPassives( player )
	player.p.lastRespawnTime = Time()
	Survival_SetInventoryEnabled( player, true )
	SetPlayerInventory( player, [] )

	player.SetPlayerNetInt( "respawnStatus", eRespawnStatus.NONE )

	player.SetPlayerNetBool( "pingEnabled", true )
	player.SetMaxHealth( 100 )
	player.SetHealth( 100 )
	
	player.SetMoveSpeedScale(1)
	player.MovementEnable()
}

void function MakePlayerSpy(entity player)
{
	SpiesLegends_DecideRespawnPlayer( player )
	
	// Add auto-cloak thread
	thread THREAD_AutoCloak(player)

	player.TakeNormalWeaponByIndexNow( WEAPON_INVENTORY_SLOT_PRIMARY_0 )
	player.TakeNormalWeaponByIndexNow( WEAPON_INVENTORY_SLOT_PRIMARY_1 )

	entity main = player.GiveWeapon( "mp_weapon_shotgun_pistol", WEAPON_INVENTORY_SLOT_PRIMARY_0, ["optic_cq_hcog_classic", "spieslegends_nozoom"], false )
	
	SetupInfiniteAmmoForWeapon( player, main )
	
	main.SetWeaponCharm( $"mdl/flowstate_custom/charm_nickmercs.rmdl", "CHARM")
}

void function MakePlayerMerc(entity player)
{
	SpiesLegends_DecideRespawnPlayer( player )
	
	//Give merc weapon
	player.TakeNormalWeaponByIndexNow( WEAPON_INVENTORY_SLOT_PRIMARY_0 )
	player.TakeNormalWeaponByIndexNow( WEAPON_INVENTORY_SLOT_PRIMARY_1 )
	
	entity main = player.GiveWeapon( "mp_weapon_alternator_smg", WEAPON_INVENTORY_SLOT_PRIMARY_0, ["optic_cq_hcog_classic", "bullets_mag_l3", "stock_tactical_l3", "laser_sight_l3"], false )
	entity secondary = player.GiveWeapon( "mp_weapon_wingman", WEAPON_INVENTORY_SLOT_PRIMARY_1, ["optic_cq_hcog_classic", "sniper_mag_l3"], false )
	
	SetupInfiniteAmmoForWeapon( player, main )
	SetupInfiniteAmmoForWeapon( player, secondary )
	
	main.SetWeaponCharm( $"mdl/flowstate_custom/charm_nickmercs.rmdl", "CHARM")
	secondary.SetWeaponCharm( $"mdl/flowstate_custom/charm_nickmercs.rmdl", "CHARM")
}

void function RespawnPlayerInLobby( int i, entity player )
{
	if( !IsValid(player) )
		return
	
	DecideRespawnPlayer( player, true )

	player.SetThirdPersonShoulderModeOff()
	
	player.UnforceStand()
	player.UnfreezeControlsOnServer()
	
	player.SetPlayerNetBool( "pingEnabled", false )
	player.SetMaxHealth( 100 )
	player.SetHealth( 100 )
	player.SetMoveSpeedScale(1)

	player.MovementEnable()
	
	//give flowstate holo sprays
	// player.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
	// player.GiveOffhandWeapon( "mp_ability_emote_projector", OFFHAND_EQUIPMENT )	
	
	TakeAllPassives( player )
	player.TakeOffhandWeapon( OFFHAND_TACTICAL )
	player.TakeOffhandWeapon( OFFHAND_ULTIMATE )

	Survival_SetInventoryEnabled( player, false )
	SetPlayerInventory( player, [] )
	
	LocPair spawnLocPair = i == -1 ? file.lobbySpawns.getrandom() : file.lobbySpawns[ i % int( min(6, GetPlayerArray().len() ) ) ]
	
	player.SetVelocity( <0, 0, 0> )
	
	player.SnapToAbsOrigin( spawnLocPair.origin )
	player.SnapEyeAngles( spawnLocPair.angles )
	player.SnapFeetToEyes()
	
	if( !IsInvincible(player ) )
		MakeInvincible(player)
	
	SetTeam( player, 99 )
	
	player.p.isInLobby = true

	CharacterSelect_AssignCharacter(ToEHI(player), GetAllCharacters()[3]) //Set gibby so we trigger the player class changed callback when match starts

	player.SetBodyModelOverride( $"mdl/Humans/pilots/w_nickmercs_hodded.rmdl" )
	player.SetArmsModelOverride( $"mdl/Humans/pilots/ptpov_nickmercs_hodded.rmdl" )
}

void function RespawnPlayerInSelectedLocation( entity player, bool isRoundStart = false )
{
	if( !IsValid(player) || !player.IsPlayer() )
		return
	
	int team = player.GetTeam()
	
	player.ClearParent()
	
	if(player.GetTeam() == gCurrentSpyTeam)
		MakePlayerSpy(player)
	else
		MakePlayerMerc(player)
	
	player.UnforceStand()
	
	if( !isRoundStart )
		player.UnfreezeControlsOnServer()
	else
	{
		player.FreezeControlsOnServer()
		Remote_CallFunction_ByRef( player, "FS_ShowRoundStartTimeUI" )
	}
	
	//give flowstate holo sprays
	// player.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
	// player.GiveOffhandWeapon( "mp_ability_emote_projector", OFFHAND_EQUIPMENT )	
	
	player.TakeOffhandWeapon( OFFHAND_TACTICAL )
	player.TakeOffhandWeapon( OFFHAND_ULTIMATE )

	player.TakeNormalWeaponByIndexNow( WEAPON_INVENTORY_SLOT_PRIMARY_2 )
	player.TakeOffhandWeapon( OFFHAND_MELEE )

	player.GiveWeapon( "mp_weapon_melee_survival", WEAPON_INVENTORY_SLOT_PRIMARY_2, [] ) //todo add dataknife heirloom
	player.GiveOffhandWeapon( "melee_data_knife", OFFHAND_MELEE, [] )
	
	if( player.GetTeam() == gCurrentSpyTeam )
	{
		Inventory_SetPlayerEquipment(player, "armor_pickup_lv1", "armor")
		player.SetShieldHealthMax( player.GetShieldHealthMax() )
		player.SetShieldHealth( player.GetShieldHealthMax() )
		
		// Inventory_SetPlayerEquipment(player, "", "armor")
		Inventory_SetPlayerEquipment(player, "", "backpack")
		Inventory_SetPlayerEquipment(player, "", "incapshield")
		Inventory_SetPlayerEquipment(player, "", "helmet")

		TakePassive(player, ePassives.PAS_FAST_HEAL)
		TakePassive(player, ePassives.PAS_PILOT_BLOOD)
		TakePassive(player, ePassives.PAS_FORTIFIED)
	} else if( player.GetTeam() == gCurrentMercTeam )
	{
		GivePassive(player, ePassives.PAS_PILOT_BLOOD)
		GivePassive(player, ePassives.PAS_FAST_HEAL)
		GivePassive(player, ePassives.PAS_FORTIFIED)
		
		Inventory_SetPlayerEquipment(player, "helmet_pickup_lv3", "helmet")
		Inventory_SetPlayerEquipment(player, "armor_pickup_lv3", "armor")
		player.SetShieldHealthMax( player.GetShieldHealthMax() )
		player.SetShieldHealth( player.GetShieldHealthMax() )
	}
	
    LocPair spawn = player.GetTeam() == gCurrentSpyTeam ? 
        GetSpySpawnLocation(isRoundStart, player) : 
        GetMercSpawnLocation(player, isRoundStart)
	
	player.SetVelocity( <0, 0, 0> )
	
	player.SnapToAbsOrigin( spawn.origin )
	player.SnapEyeAngles( spawn.angles )
	player.SnapFeetToEyes()
	
	if( IsInvincible(player ) )
		ClearInvincible(player)
	
	EnableOffhandWeapons( player )
	
	thread SpiesLegends_GrantSpawnImmunity( player, 3 ) 
	
	if( player.GetTeam() == TEAM_IMC )
	{
		player.SetSkin(2)
		player.SetCamo(IMC_color)
	} else if( player.GetTeam() == TEAM_MILITIA )
	{
		player.SetSkin(2)
		player.SetCamo(MILITIA_color)
	}
	
	if( !isRoundStart )
	{
		player.p.canChangeGadgets = true
		Remote_CallFunction_UI(player, "GadgetsSelector_Open", player.GetTeam() == gCurrentSpyTeam ? 0 : 1 )
	}

	array<AbilityData> pool = ( player.GetTeam() == gCurrentSpyTeam ) ? file.spyGadgets : file.mercGadgets
	
	player.TakeOffhandWeapon(OFFHAND_TACTICAL)
	player.TakeOffhandWeapon(OFFHAND_ULTIMATE)
	
	player.GiveOffhandWeapon(pool[player.p.selectedGadget1].weaponName, OFFHAND_TACTICAL)	
	player.GiveOffhandWeapon(pool[player.p.selectedGadget2].weaponName, OFFHAND_ULTIMATE)	
}

void function SpiesLegends_GrantSpawnImmunity(entity player, float duration)
{
	// printw( "SpiesLegends_GrantSpawnImmunity START " )
	if( !IsValid(player) )
		return
	
	EndSignal( player, "OnDestroy" )
	// EndSignal( player, "OnDeath" )

	// EmitSoundOnEntityOnlyToPlayer( player, player, "PhaseGate_Enter_1p" )
	// EmitSoundOnEntityExceptToPlayer( player, player, "PhaseGate_Enter_3p" )

	StatusEffect_AddTimed( player, eStatusEffect.adrenaline_visuals, 1.0, duration, duration )
	StatusEffect_AddTimed( player, eStatusEffect.speed_boost, 0.3, duration, duration )
	StatusEffect_AddTimed( player, eStatusEffect.drone_healing, 1.0, duration, duration )
	StatusEffect_AddTimed( player, eStatusEffect.stim_visual_effect, 1.0, duration, duration )

	player.SetTakeDamageType( DAMAGE_NO )
	
	if( !IsInvincible( player ) )
		MakeInvincible( player )
	
	float endTime = Time() + duration
	
	while(Time() <= endTime)
		wait 0.1
	
	player.MakeVisible()
	
	if( IsInvincible( player ) )
		ClearInvincible( player )
	
	StatusEffect_StopAllOfType( player, eStatusEffect.adrenaline_visuals )
	StatusEffect_StopAllOfType( player, eStatusEffect.speed_boost )
	StatusEffect_StopAllOfType( player, eStatusEffect.drone_healing )
	StatusEffect_StopAllOfType( player, eStatusEffect.stim_visual_effect )
	
	WaitEndFrame()
	
	player.MakeVisible()
	
	if( IsInvincible( player ) )
		ClearInvincible( player )
	
	player.SetTakeDamageType( DAMAGE_YES )
	
	// printw( "SpiesLegends_GrantSpawnImmunity END" )
}

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
// NEW SPAWNS SYSTEM ??
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////

// LocPair function GetSpySpawnLocation( int i )
// {
	// return file.selectedLocation.playerSpawns.getrandom() // temp
// }

// LocPair function GetMercSpawnLocation( int i )
// {
	// return file.selectedLocation.playerSpawns.getrandom() // temp
// }
void function ClearSpawnTracking()
{
    file.usedSpawnIndices.clear()
}

LocPair function GetSpySpawnLocation(bool isRoundStart = false, entity player = null)
{
    if(isRoundStart)
    {
        return GetRoundStartSpawn(player)
    }
    
    // Original logic for non-round start spawns
    array<SpawnCandidate> candidates = EvaluateSpySpawns()
    
    if(candidates.len() == 0)
        return file.selectedLocation.playerSpawns.getrandom()
    
    int numOptions = minint(3, candidates.len())
    array<SpawnCandidate> topCandidates = candidates.slice(0, numOptions)
    
    return SelectBestSpawn(topCandidates)
}

LocPair function GetMercSpawnLocation(entity player, bool isRoundStart = false)
{
    if(isRoundStart)
    {
        return GetRoundStartSpawn(player)
    }
    
    // Original logic for non-round start spawns
    array<SpawnCandidate> candidates = EvaluateMercSpawns(player)
    
    if(candidates.len() == 0)
        return file.selectedLocation.playerSpawns.getrandom()
    
    return SelectBestSpawn(candidates)
}

LocPair function GetRoundStartSpawn(entity player)
{
    array<LocPair> availableSpawns = []
    string playerUID = player.GetPlatformUID()
    bool isSpy = player.GetTeam() == gCurrentSpyTeam
    bool isMerc = player.GetTeam() == gCurrentMercTeam

	#if DEVELOPER
	printw("=== GetRoundStartSpawn START ===")
	printw("Player:", player.GetPlayerName(), "Team:", isSpy ? "SPY" : "MERC", "UID:", playerUID)
	printw("Total spawn points:", file.selectedLocation.playerSpawns.len())
	printw("Already used spawns:", file.usedSpawnIndices.len())
	#endif
    
    // Distance constraints for round start
    const float MIN_SPY_TERMINAL_DISTANCE = 1200.0
    const float MAX_MERC_TERMINAL_DISTANCE = 500.0  // Mercs should spawn close to defend
    
    // Build list of available spawns
    for(int i = 0; i < file.selectedLocation.playerSpawns.len(); i++)
    {
        // Skip if this spawn index was already used this round
        if(file.usedSpawnIndices.contains(i))
            continue
            
        // Skip if this was the player's last spawn (from previous round)
        if(playerUID in file.playerLastSpawnIndex && file.playerLastSpawnIndex[playerUID] == i)
            continue
            
        // Check if spawn is clear
        LocPair spawn = file.selectedLocation.playerSpawns[i]
        if(!SpawnSystem_CheckSpawn(spawn.origin))
            continue
            
        // For spies, check they're FAR from all terminals
        if(isSpy)
        {
            bool tooCloseToTerminal = false
            foreach(terminal in activeTerminals)
            {
                if(!IsValid(terminal))
                    continue
                    
                float dist = Distance2D(spawn.origin, terminal.GetOrigin())
                if(dist < MIN_SPY_TERMINAL_DISTANCE)
                {
                    tooCloseToTerminal = true
					
					#if DEVELOPER
					printw("  Spawn", i, "SKIPPED - Spy too close to terminal (", dist, "units)")
					#endif
                    break
                }
            }
            
            if(tooCloseToTerminal)
            {
                continue
            }
        }
        
        // For mercs, check they're CLOSE to at least one terminal
        if(isMerc)
        {
            bool closeToAnyTerminal = false
            foreach(terminal in activeTerminals)
            {
                if(!IsValid(terminal))
                    continue
                    
                float dist = Distance2D(spawn.origin, terminal.GetOrigin())
                if(dist <= MAX_MERC_TERMINAL_DISTANCE)
                {
                    closeToAnyTerminal = true
                    break
                }
            }
            
            if(!closeToAnyTerminal)
            {
				#if DEVELOPER
				printw("Spawn", i, "too far from terminals for merc player", player.GetPlayerName())
				#endif
                continue
            }
        }
		#if DEVELOPER
		printw("  Spawn", i, "AVAILABLE")
		#endif
		
        availableSpawns.append(spawn)
    }
    
    // If no spawns available (shouldn't happen with proper map design), use any available spawn
    if(availableSpawns.len() == 0)
    {
		#if DEVELOPER
		printw("!!! FALLBACK 1: No spawns found - clearing used spawns and trying again")
		#endif
        
        // Reset and try again with just the "not recently used" constraint
        file.usedSpawnIndices.clear()
        
        for(int i = 0; i < file.selectedLocation.playerSpawns.len(); i++)
        {
            if(SpawnSystem_CheckSpawn(file.selectedLocation.playerSpawns[i].origin))
                availableSpawns.append(file.selectedLocation.playerSpawns[i])
        }
        
        if(availableSpawns.len() == 0)
            return file.selectedLocation.playerSpawns.getrandom() // Ultimate fallback
    }
    
    // Select a spawn and track it
    LocPair selectedSpawn = availableSpawns.getrandom()
    
    // Find the index of this spawn in the original array
    for(int i = 0; i < file.selectedLocation.playerSpawns.len(); i++)
    {
        if(file.selectedLocation.playerSpawns[i] == selectedSpawn)
        {
            file.usedSpawnIndices.append(i)
            file.playerLastSpawnIndex[playerUID] <- i
            
			#if DEVELOPER
			printw("Player", player.GetPlayerName(), "spawning at index", i, "- Total used spawns:", file.usedSpawnIndices.len())
			#endif
            break
        }
    }
    
    return selectedSpawn
}

// Spy spawn evaluation
array<SpawnCandidate> function EvaluateSpySpawns()
{
    array<SpawnCandidate> candidates
    
    foreach(spawn in file.selectedLocation.playerSpawns)
    {
        SpawnCandidate candidate
        candidate.spawn = spawn
        candidate.score = 0
        
        // Skip if spawn is blocked
        if(!SpawnSystem_CheckSpawn(spawn.origin))
            continue
        
        // 1. Enemy proximity check (most important)
        bool tooCloseToEnemy = false
        foreach(enemy in GetPlayerArrayOfTeam_Alive(gCurrentMercTeam))
        {
            float dist = Distance2D(spawn.origin, enemy.GetOrigin())
            if(dist < SPAWN_ENEMY_DANGER_RADIUS)
            {
                tooCloseToEnemy = true
                break
            }
            
            // Penalty for visible spawns
            // if(dist < 2000 && PlayerCanSeePosition(enemy, spawn.origin))
                // candidate.score -= 50
        }
        
        if(tooCloseToEnemy)
            continue
        
        // 2. Darkness bonus (spies prefer dark areas)
        float darknessScore = CalculateDarknessScore(spawn.origin)
        candidate.score += darknessScore * 30
        
        // 3. Vent proximity bonus
        float ventBonus = CalculateVentProximityScore(spawn.origin)
        candidate.score += ventBonus * 20
        
        // 4. Flanking path bonus (multiple approach options)
        int approachPaths = CountApproachPaths(spawn.origin)
        candidate.score += (approachPaths * 15).tofloat()
        
        // 5. Distance from terminals (prefer infiltration distance)
		float terminalScore = 0
		foreach(terminal in activeTerminals)
		{
			if(!IsValid(terminal))
				continue
				
			float dist = Distance2D(spawn.origin, terminal.GetOrigin())
			
			// Adjusted sweet spot for hotel map size
			if(dist > 1200 && dist < SPAWN_SPY_INFILTRATION_RADIUS)
				terminalScore += 25
			else if(dist < 800)
				terminalScore -= 30  // Heavy penalty for spawning too close
			else if(dist > 2200)
				terminalScore -= 10  // Slight penalty for being too far
		}
        candidate.score += terminalScore
        
        // 6. Height advantage for stealth
        if(spawn.origin.z > file.ringCenter.z + 100)
            candidate.score += 15
        
        candidates.append(candidate)
    }
    
    // Sort by score
    candidates.sort( SortByScore )
    
    return candidates
}

int function SortByScore( SpawnCandidate a, SpawnCandidate b )
{
    // For descending order (highest score first)
    if ( a.score > b.score )
        return -1
    else if ( a.score < b.score )
        return 1
    return 0
}

// Merc spawn evaluation
array<SpawnCandidate> function EvaluateMercSpawns( entity player )
{
    array<SpawnCandidate> candidates
    
    foreach(spawn in file.selectedLocation.playerSpawns)
    {
        SpawnCandidate candidate
        candidate.spawn = spawn
        candidate.score = 0
        
        // Skip if spawn is blocked
        if(!SpawnSystem_CheckSpawn(spawn.origin))
            continue
        
        // 1. Enemy proximity check
        bool tooCloseToEnemy = false
        foreach(enemy in GetPlayerArrayOfTeam_Alive(gCurrentSpyTeam))
        {
            float dist = Distance2D(spawn.origin, enemy.GetOrigin())
            if(dist < SPAWN_ENEMY_DANGER_RADIUS)
            {
                tooCloseToEnemy = true
                break
            }
        }
        
        if(tooCloseToEnemy)
            continue
        
        // 2. Terminal defense positioning
        float defenseScore = 0
        int terminalsInRange = 0
        
        foreach(terminal in activeTerminals)
        {
            if(!IsValid(terminal))
                continue
                
            float dist = Distance2D(spawn.origin, terminal.GetOrigin())
            
            // Optimal defensive range
            if(dist < SPAWN_MERC_DEFENSIVE_RADIUS)
            {
                defenseScore += 40
                terminalsInRange++
                
                // Bonus for active hack defense
                if(IsTerminalHackActive(terminal))
                    defenseScore += 30
            }
        }
        
        // Bonus for covering multiple terminals
        if(terminalsInRange >= 2)
            defenseScore += 25
            
        candidate.score += defenseScore
        
        // 3. Lighting preference (mercs prefer lit areas)
        float lightScore = CalculateLightingScore(spawn.origin)
        candidate.score += lightScore * 20
        
        // 4. Chokepoint control
        if(IsNearChokepoint(spawn.origin))
            candidate.score += 25
        
        // 5. Team clustering (mercs work in groups)
        int nearbyAllies = 0
        foreach(ally in GetPlayerArrayOfTeam_Alive(gCurrentMercTeam))
        {
            if(ally == player)
                continue
                
            float dist = Distance2D(spawn.origin, ally.GetOrigin())
            if(dist > 500 && dist < 1500)
                nearbyAllies++
        }
        
        if(nearbyAllies > 0 && nearbyAllies <= 2)
            candidate.score += 20  // Good squad positioning
        
        candidates.append(candidate)
    }
    
    // Sort by score
    candidates.sort( SortByScore )
    
    return candidates
}

// Helper functions
float function CalculateDarknessScore(vector origin)
{
    float score = 1.0  // Base darkness
    
    foreach(lamp in file.lamps)
    {
        if(!lamp.enabled)
            continue
            
        float dist = Distance(origin, lamp.origin)
        if(dist < lamp.radius)
        {
            // The closer to lamp center, the less dark
            score *= (dist / lamp.radius)
        }
    }
    
    return score
}

float function CalculateLightingScore(vector origin)
{
    return 1.0 - CalculateDarknessScore(origin)
}

float function CalculateVentProximityScore(vector origin)
{
    float closestVentDist = 9999
    
    foreach(vent in file.vents)
    {
        if(!IsValid(vent.collisionProp))
            continue
            
        float dist = Distance2D(origin, vent.collisionProp.GetOrigin())
        if(dist < closestVentDist)
            closestVentDist = dist
    }
    
    if(closestVentDist < 300)
        return 1.0
    else if(closestVentDist < 600)
        return 0.5
	
    return 0
}

int function CountApproachPaths(vector origin)
{
    int validPaths = 0
    array<vector> directions = [
        <1,0,0>, <-1,0,0>, <0,1,0>, <0,-1,0>,
        <1,1,0>, <1,-1,0>, <-1,1,0>, <-1,-1,0>
    ]
    
    foreach(dir in directions)
    {
        TraceResults trace = TraceLine(
            origin + <0,0,50>,
            origin + (Normalize(dir) * 500) + <0,0,50>,
            [], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE
        )
        
        if(trace.fraction > 0.8)
            validPaths++
    }
    
    return validPaths
}

bool function IsNearChokepoint(vector origin)
{
    // Simplified chokepoint detection - check if area has limited approaches
    int paths = CountApproachPaths(origin)
    return paths <= 4  // Limited paths = chokepoint
}

LocPair function SelectBestSpawn(array<SpawnCandidate> candidates)
{
    if(candidates.len() == 0)
        return file.selectedLocation.playerSpawns.getrandom()
    
    // Add some randomness to top candidates to prevent predictability
    float totalScore = 0
    foreach(candidate in candidates)
        totalScore += max(candidate.score, 1)
    
    float random = RandomFloat(totalScore)
    float current = 0
    
    foreach(candidate in candidates)
    {
        current += max(candidate.score, 1)
        if(random <= current)
            return candidate.spawn
    }
    
    return candidates[0].spawn
}

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////

void function DEV_TestAllLocationSpawns() //Found 0 stuck spawns out of 52 total ( 05 / 27 / 2025 )
{
    array<LocPair> spawns = file.selectedLocation.playerSpawns
    int stuckCount = 0
    
    foreach(int i, LocPair spawn in spawns)
    {
        if(!SpawnSystem_CheckSpawn(spawn.origin))
        {
            printw("STUCK SPAWN #" + i + " at", spawn.origin)
            stuckCount++
        }
    }
    
    printw("Found", stuckCount, "stuck spawns out of", spawns.len(), "total")
}



// ███╗   ███╗███████╗██╗     ███████╗███████╗    ████████╗███████╗███████╗████████╗
// ████╗ ████║██╔════╝██║     ██╔════╝██╔════╝    ╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝
// ██╔████╔██║█████╗  ██║     █████╗  █████╗         ██║   █████╗  ███████╗   ██║   
// ██║╚██╔╝██║██╔══╝  ██║     ██╔══╝  ██╔══╝         ██║   ██╔══╝  ╚════██║   ██║   
// ██║ ╚═╝ ██║███████╗███████╗███████╗███████╗       ██║   ███████╗███████║   ██║   
// ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝╚══════╝       ╚═╝   ╚══════╝╚══════╝   ╚═╝  

// melee was hooked to support insta finishers from the back
bool function FS_Spies_IsVictimBackwardsToAttacker( entity attacker, entity victim, vector damageOrigin, int viewAngle = 85 )
{
	if( !IsValid( attacker ) || !IsValid( victim ) )
		return false
	
	if( attacker.GetTeam() != gCurrentSpyTeam )
		return false
	
	if( !IsEnemyTeam( victim.GetTeam(), attacker.GetTeam() ) )
		return false
	
	vector dir = damageOrigin - victim.GetOrigin()
	dir = Normalize( dir )
	float dot = DotProduct( victim.GetPlayerOrNPCViewVector(), dir )
	float yaw = DotToAngle( dot )
	
	return ( yaw > 180 - viewAngle )
}

 // █████╗ ██╗   ██╗████████╗ ██████╗  ██████╗██╗      ██████╗  █████╗ ██╗  ██╗    ████████╗███████╗███████╗████████╗
// ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗██╔════╝██║     ██╔═══██╗██╔══██╗██║ ██╔╝    ╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝
// ███████║██║   ██║   ██║   ██║   ██║██║     ██║     ██║   ██║███████║█████╔╝        ██║   █████╗  ███████╗   ██║   
// ██╔══██║██║   ██║   ██║   ██║   ██║██║     ██║     ██║   ██║██╔══██║██╔═██╗        ██║   ██╔══╝  ╚════██║   ██║   
// ██║  ██║╚██████╔╝   ██║   ╚██████╔╝╚██████╗███████╗╚██████╔╝██║  ██║██║  ██╗       ██║   ███████╗███████║   ██║   
// ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝  ╚═════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝       ╚═╝   ╚══════╝╚══════╝   ╚═╝   

void function OnWeaponAttack( entity player, entity weapon, string weaponName, int ammoUsed, vector origin, vector dir )
{
    if ( !IsValid( player ) )
        return
	
	// #if DEVELOPER
	// printw( "OnWeaponAttack", player, weaponName )
	// #endif
	
	if( player.GetTeam() == gCurrentSpyTeam )
	{
		// Immediately remove cloak when shooting
		if ( player.IsCloaked( true ) )
			player.SetCloakDuration( 0, 0, 0.2 )

		// Set auto-cloak cooldown for Spy team
		player.p.nextAutoCloakTime = Time() + AUTOCLOAK_CD_TIME
		
		Signal( player, "Signal_OnWeaponAttack" )
	}
}

void function OnPlayerDamaged( entity victim, var damageInfo )
{
	if ( !IsValid( victim ) || !victim.IsPlayer() )
		return
	
	if( !file.actuallyPlayingState )
		return
	
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	
	if( !IsValid( attacker ) || !attacker.IsPlayer() )
		return
	
	if( victim.GetTeam() == gCurrentSpyTeam )
	{
		// Immediately remove cloak when shooting
		if ( victim.IsCloaked( true ) )
			victim.SetCloakDuration( 0, 0, 0.2 )

		// Set auto-cloak cooldown for Spy team
		victim.p.nextAutoCloakTime = Time() + AUTOCLOAK_CD_TIME
	}
}

void function THREAD_AutoCloak(entity player)
{
	if( !IsValid( player ) )
		return
	
    EndSignal(player, "OnDestroy")
	
    const float WALL_DISTANCE = 60.0
	
    OnThreadEnd(
		function() : ( player )
		{
			if( IsValid(player) )
			{
				player.SetCloakDuration( 0, 0, 0.2 )

				player.SetMoveSpeedScale( 1.0 )
				player.p.isPlayerInVent = false
				
				Remote_CallFunction_ByRef( player, "ServerCallback_PlayerOutOfVent" )
			}
		}
	)
	
    while(IsValid(player) && IsAlive(player) && player.GetTeam() == gCurrentSpyTeam )
    {
		float currentTime = Time()
        float nextAutoCloakTime = player.p.nextAutoCloakTime
		bool isManualCloakActive = player.p.isPlayerInCloakAbility
	
		if( IsPlayerInVent( player ) && !player.p.isPlayerInVent ) // Player is in vent
		{
			player.SetMoveSpeedScale( 2.0 )
			player.p.isPlayerInVent = true
			
			Remote_CallFunction_ByRef( player, "ServerCallback_PlayerInVent" )
			Message_New( player, "VENT ACCESS GRANTED", 2 )
			
			#if DEVELOPER
			if( player == gp()[0] )
				printw( "PLAYER INSIDE VENT" )
			#endif
			
			// prob mode 1p sound to client
			// EmitSoundOnEntityOnlyToPlayer( player, player, "PhaseGate_Enter_1p" )
			EmitSoundOnEntityExceptToPlayer( player, player, "PhaseGate_Enter_3p" )
			
		} else if( !IsPlayerInVent( player ) && player.p.isPlayerInVent )
		{
			player.SetMoveSpeedScale( 1.0 )
			player.p.isPlayerInVent = false
			
			Remote_CallFunction_ByRef( player, "ServerCallback_PlayerOutOfVent" )
			#if DEVELOPER
			if( player == gp()[0] )
				printw( "PLAYER OUTSIDE VENT" )
			#endif
		}
		
		if( !isManualCloakActive ) // Only autocloak if players are not in cloak ability
		{
			// Check cooldown state
			if( currentTime < nextAutoCloakTime )
			{
				// Force uncloak during cooldown period
				if( player.IsCloaked( true ) )
					player.SetCloakDuration( 0, 0, 0.2 )
			}
			else
			{
				// Normal cloak behavior when not in cooldown
				if( ShouldAutoCloak(player, WALL_DISTANCE) )
				{
					if( !player.IsCloaked( true ) )
						player.SetCloakDuration( 0.2, -1, 0 )
				}
				else if( player.IsCloaked( true ) )
					player.SetCloakDuration( 0, 0, 0.2 )
			}
		}
        
        WaitFrame()
    }
}

bool function ShouldAutoCloak(entity player, float wallDistance)
{
	if( player.ContextAction_IsMeleeExecution() )
		return false
	
	vector startPoint = player.GetOrigin() + player.GetUpVector() * 20
		
    // Check proximity to lamps
	foreach ( int i, LampData lamp in file.lamps )
    {
        vector lampOrigin = lamp.origin - <0,0,15>
        float dist = Distance( startPoint, lampOrigin )
        
		// Early out if light is disabled
		if( !lamp.enabled )
			continue
		
        // Early out if too far
        if ( dist >= lamp.radius )
            continue
		
        // Add vertical offset to avoid floor checks
        TraceResults trace = TraceLine(
            lampOrigin,
            startPoint,
            GetPlayerArray(), // Ignore all players
            TRACE_MASK_SOLID,
            TRACE_COLLISION_GROUP_NONE
        )
		
		// #if DEVELOPER
		// if( player == gp()[0] )
			// printw( "NEAR LAMP WITH ID:", i, "DISTANCE", dist, "WITH ORIGIN", lamp.origin, "ANGLES", lamp.angles, "TYPE", lamp.type)	
		// #endif
		
        // Only block cloak if there's direct line of sight
        if ( trace.fraction >= 1.0 )
            return false
    }
	
	if( AUTOCLOAK_CROUCHED_ONLY && !player.IsCrouched() ) // Only when crouched
		return false
    	
    // Get player-oriented directions
    vector forward = player.GetForwardVector()
    vector right = player.GetRightVector()
    vector up = player.GetUpVector()

    // Check proximity to walls/obstacles using player-relative directions
    array<vector> directions = [
        right,        // Player's right
        -right,       // Player's left
        forward,       // Player's forward
        -forward,      // Player's backward
        up,            // Player's up
        -up            // Player's down
    ]

    int wallsNearby = 0
    foreach(vector dir in directions)
    {
        TraceResults trace = TraceLine(
            startPoint,
            startPoint + (dir * wallDistance),
            GetPlayerArray(), 
            TRACE_MASK_SOLID, 
            TRACE_COLLISION_GROUP_NONE
        )
        
        if(trace.fraction < 0.9)
            wallsNearby++
    }
	
    return wallsNearby >= 2
}

// Ez pz
bool function IsPlayerInVent(entity player)
{
	entity groundEnt = player.GetGroundEntity()
	
	// #if DEVELOPER
	// if( player == gp()[0] )
		// printw( "DEBUG PLAYER IN VENT - Current:", IsValid(groundEnt) ? groundEnt.GetModelName() : " INVALID " ," - Last Ent:", player.p.lastGroundEntityName )
	// #endif
	
	if( IsValid( groundEnt ) )
	{
		player.p.lastGroundEntityName = groundEnt.GetModelName()
		return groundEnt.GetModelName() == VENT_ASSET
	}
	
    return player.p.lastGroundEntityName == VENT_ASSET
}


// ██╗  ██╗ █████╗  ██████╗██╗  ██╗ █████╗ ██████╗ ██╗     ███████╗    ████████╗███████╗██████╗ ███╗   ███╗██╗███╗   ██╗ █████╗ ██╗     ███████╗
// ██║  ██║██╔══██╗██╔════╝██║ ██╔╝██╔══██╗██╔══██╗██║     ██╔════╝    ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║████╗  ██║██╔══██╗██║     ██╔════╝
// ███████║███████║██║     █████╔╝ ███████║██████╔╝██║     █████╗         ██║   █████╗  ██████╔╝██╔████╔██║██║██╔██╗ ██║███████║██║     ███████╗
// ██╔══██║██╔══██║██║     ██╔═██╗ ██╔══██║██╔══██╗██║     ██╔══╝         ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║██║╚██╗██║██╔══██║██║     ╚════██║
// ██║  ██║██║  ██║╚██████╗██║  ██╗██║  ██║██████╔╝███████╗███████╗       ██║   ███████╗██║  ██║██║ ╚═╝ ██║██║██║ ╚████║██║  ██║███████╗███████║
// ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝       ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝╚══════╝

void function InitTerminalSystem()
{
	#if DEVELOPER
	printw( "InitTerminalSystem" )
	#endif
	
	ShuffleTerminalSpawns() 
	
	//Create initial 3 terminals
	for (int i = 0; i < TERMINALS_TO_SPAWN; i++) 
	{
		if( CREATE_NEW_TERMINALS_ON_HACK && terminalSpawnIndex >= shuffledTerminalsSpawns.len() )
			ShuffleTerminalSpawns()
		
		if( shuffledTerminalsSpawns.len() == 0 )
			break
		
		TerminalSpawn spawnData = shuffledTerminalsSpawns[terminalSpawnIndex]
		spawnData.terminalID = GetTerminalID(i)
		
		//Mark as occupied in original array
		foreach( TerminalSpawn spawn in file.selectedLocation.terminalSpawns )
		{
			if( spawn.id == spawnData.id )
			{
				spawn.isOccupied = true
				spawn.terminalID = spawnData.terminalID
				break
			}
		}
		
		activeTerminals.append( CreateHackablePanel( spawnData.spawn.origin, spawnData.spawn.angles, spawnData.id, spawnData.terminalID ) )
		terminalSpawnIndex++
	}	
}

void function ShuffleTerminalSpawns() 
{
	array<TerminalSpawn> availableSpawns = []
	foreach(TerminalSpawn spawn in file.selectedLocation.terminalSpawns)
	{
		bool isRecent = recentTerminalSpawnHistory.contains(spawn.id)
		if(!spawn.isOccupied && !isRecent)
			availableSpawns.append( spawn )
	}

	if(availableSpawns.len() == 0)
	{
		//Fallback to any available spawn if all are recent
		foreach(TerminalSpawn spawn in file.selectedLocation.terminalSpawns)
		{
			if(!spawn.isOccupied)
				availableSpawns.append( spawn )
		}
	}

	if(availableSpawns.len() > 0)
	{
		availableSpawns.randomize()
		TerminalSpawn farthestSpawn = FindFarthestSpawn(availableSpawns, activeTerminals)
		availableSpawns.remove(availableSpawns.find(farthestSpawn))
		availableSpawns.insert(0, farthestSpawn)
	}
	
	shuffledTerminalsSpawns = availableSpawns
	terminalSpawnIndex = 0
}

string function GetTerminalLetter(int index)
{
	array<string> letters = ["A", "B", "C"]
	return letters[index % 3]
}

TerminalSpawn function FindFarthestSpawn(array<TerminalSpawn> availableSpawns, array<entity> activeTerminals)
{
	if(activeTerminals.len() == 0)
		return availableSpawns[0]

	TerminalSpawn farthestSpawn = availableSpawns[0]
	float maxDistance = -1.0

	foreach(TerminalSpawn spawn in availableSpawns)
	{
		float minDistanceToTerminals = 99999.9
		foreach(terminal in activeTerminals)
		{
			float distance = Distance(spawn.spawn.origin, terminal.GetOrigin())
			if(distance < minDistanceToTerminals)
				minDistanceToTerminals = distance
		}

		if(minDistanceToTerminals > maxDistance)
		{
			maxDistance = minDistanceToTerminals
			farthestSpawn = spawn
		}
	}

	return farthestSpawn
}

entity function CreateHackablePanel( vector origin, vector angles, int spawnID, int terminalID = eTerminalID.STATION_A, bool shouldEnable = true )
{
	#if DEVELOPER
	printw( "CreateHackablePanel", spawnID )
	#endif
	
	entity control_panel = CreateEntity( "prop_control_panel" )
	control_panel.SetValueForModelKey( $"mdl/communication/terminal_usable_imc_01.rmdl" )
	control_panel.kv.fadedist = -1
	control_panel.kv.renderamt = 255
	control_panel.kv.rendercolor = "255 255 255"
	control_panel.kv.solid = 6 //0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
	
	control_panel.kv.hackRadius = 500
	control_panel.kv.requireHoldUse = 1
	control_panel.kv.singleUse = 1
	control_panel.kv.teamnumber = gCurrentSpyTeam

	control_panel.kv.spawnflags = 0
	control_panel.kv.toggleFlagWhenHacked = 0
	control_panel.kv.script_name = "SpiesHackableTerminal"

	//hack: Setting origin twice. SetOrigin needs to happen before DispatchSpawn, otherwise the prop may not touch triggers
	control_panel.SetOrigin( origin ) 
	control_panel.SetAngles( angles ) 

	DispatchSpawn( control_panel )
	
	SetTeam( control_panel, gCurrentSpyTeam )
	control_panel.SetUsableByGroup( "friendlies pilot" )
	control_panel.AddUsableValue( USABLE_CUSTOM_HINTS | USABLE_BY_PILOTS )

	//spawnID
	control_panel.e.hackableTerminalSpawnID = spawnID
	
	//letter
	control_panel.e.terminalID = terminalID 
	
	//Waypoint
	if( shouldEnable )
		CreateWaypointForTerminal( control_panel )
	
	//hack: Setting origin twice. SetOrigin needs to happen after DispatchSpawn, otherwise origin is snapped to nearest whole unit
	control_panel.SetOrigin( origin ) 
	control_panel.SetAngles( angles ) 

	control_panel.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY
	
	ControlPanel_SetPlayerStartUsingFunc( control_panel, HackableTerminal_OnUseStarted )
	ControlPanel_SetPlayerFinishesUsingFunc( control_panel, HackableTerminal_OnUseFinished )

	ClearCallback_CanUseEntityCallback( control_panel )
	SetCallback_CanUseEntityCallback( control_panel, HackableTerminal_CanUse )
	
	//Mercs terminals, to avoid them to see prop anims while being hacked
	{
		entity panel_dummy = CreateEntity( "prop_control_panel" )
		panel_dummy.SetValueForModelKey( $"mdl/communication/terminal_usable_imc_01.rmdl" )
		panel_dummy.kv.fadedist = -1
		panel_dummy.kv.renderamt = 255
		panel_dummy.kv.rendercolor = "255 255 255"
		panel_dummy.kv.solid = 6 //0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only

		panel_dummy.kv.teamnumber = gCurrentMercTeam
		
		//hack: Setting origin twice. SetOrigin needs to happen before DispatchSpawn, otherwise the prop may not touch triggers
		panel_dummy.SetOrigin( origin ) 
		panel_dummy.SetAngles( angles ) 

		DispatchSpawn( panel_dummy )
		
		SetTeam( panel_dummy, gCurrentMercTeam )
		
		//hack: Setting origin twice. SetOrigin needs to happen after DispatchSpawn, otherwise origin is snapped to nearest whole unit
		panel_dummy.SetOrigin( origin ) 
		panel_dummy.SetAngles( angles ) 

		panel_dummy.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY
		panel_dummy.s.hackedOnce = true
		panel_dummy.UnsetUsable()
		panel_dummy.SetUsePrompts( "#EMPTY_STRING", "#EMPTY_STRING" )
		control_panel.e.dummyPanelForMercs = panel_dummy
	}
	
	return control_panel
}

void function CreateWaypointForTerminal( entity panel, int state = 0)
{
	if( IsValid( panel.e.hackableTerminalWaypoint ) )
		panel.e.hackableTerminalWaypoint.Destroy()
	
	int waypointToUse 
	
	switch(panel.e.terminalID)
	{
		case eTerminalID.STATION_A:
			if( state == 1 )
				waypointToUse = ePingType.SPIESLEGENDS_STATION_A_ATTACK
			else
				waypointToUse = ePingType.SPIESLEGENDS_STATION_A
		break
		
		case eTerminalID.STATION_B:
			if( state == 1 )
				waypointToUse = ePingType.SPIESLEGENDS_STATION_B_ATTACK
			else
				waypointToUse = ePingType.SPIESLEGENDS_STATION_B
		break
		
		case eTerminalID.STATION_C:
			if( state == 1 )
				waypointToUse = ePingType.SPIESLEGENDS_STATION_C_ATTACK
			else
				waypointToUse = ePingType.SPIESLEGENDS_STATION_C
		break
	}
	
	entity wp = CreateWaypoint_BasicLocation( panel.GetOrigin() + <0, 0, 80>, waypointToUse )
	panel.e.hackableTerminalWaypoint = wp
}

int function GetTerminalID(int index)
{
	return eTerminalID.STATION_A + (index % 3)
}

void function HackableTerminal_OnUseStarted( entity terminal, entity player )
{
	#if DEVELOPER
	printw("HackableTerminal_OnUseStarted")
	#endif
	terminal.e.isBeingDataknifed = true
	
	EmitSoundOnEntityOnlyToPlayer( player, player, "UI_CraftingTable_Open_1P" )
	// Disable the other terminals
	foreach( entity panel in activeTerminals )
	{
		if( panel != terminal )
		{
			// if( IsValid( panel.e.hackableTerminalWaypoint ) )
				// panel.e.hackableTerminalWaypoint.Destroy()
			
			panel.SetUsePrompts( "Another terminal is trying to be hacked", "Another terminal is trying to be hacked" )
		}
	}
}

void function HackableTerminal_OnUseFinished( entity terminal, entity player, bool success)
{
	if( success )
	{
		// Only spies can hack
		if(player.GetTeam() != gCurrentSpyTeam)
			return
		
		EmitSoundOnEntityOnlyToPlayer( player, player, "UI_CraftingTable_Close_1P" )
		
		terminal.SetUsePrompts( "Transferring data...", "Transferring data..." )
		if( IsValid( terminal.e.dummyPanelForMercs ) )
			terminal.e.dummyPanelForMercs.SetUsePrompts( "Transferring data...", "Transferring data..." )

		// Remove terminals waypoint
		foreach( entity panel in activeTerminals )
		{
			if( IsValid( panel.e.hackableTerminalWaypoint ) )
				panel.e.hackableTerminalWaypoint.Destroy()
				
			panel.SetUsePrompts( "Terminal disabled during transfer", "Terminal disabled during transfer" )
		}
		CreateWaypointForTerminal( terminal, 1 ) //Create red waypoint
		
		if(isAnyTerminalBeingHacked && IsTerminalHackActive( terminal ) )
		{
			// Attempt takeover
			ActiveHackData existingHack = GetActiveHackForTerminal(terminal)
			if(existingHack.allowTakeover)
			{
				// Transfer hack progress
				existingHack.currentHacker = player
				existingHack.allowTakeover = false
				existingHack.takeoverCompleted = true
				existingHack.resetCountdown = 0.0
				Signal(terminal, "HackerChanged") // Reset any existing signals
				thread HackProgressThread(existingHack)
				return
			}
		}
		else
		{
			isAnyTerminalBeingHacked = true
			terminal.e.isBeingDataknifed = false
			
			// Create new hack data
			ActiveHackData hackData
			hackData.terminal = terminal
			hackData.originalHacker = player
			hackData.currentHacker = player
			hackData.totalHackTime = 0.0  // Reset accumulated time
			hackData.lastValidTime = Time()
			hackData.progress = 0.0
			hackData.wasInRadius = true
			hackData.isActive = true

			// Visual radius fx
			{
				entity circle = CreateEntity( "prop_dynamic" )
				circle.SetValueForModelKey( $"mdl/fx/ar_edge_sphere_512.rmdl" )
				circle.kv.rendercolor = "235, 52, 52"
				circle.kv.modelscale = 3.125 //512 = 2.0 / 1024.0 = 4.0 / 800 = 3.125
				circle.SetOrigin( hackData.terminal.GetOrigin() )
				circle.SetAngles( <0, 0, 0> )
				DispatchSpawn(circle)
				circle.SetParent( hackData.terminal )
				
				hackData.visualRadiusFx = circle
			}
			
			// Check if we need to extend time when hack starts
			float remainingTime = GetGlobalNetTime( "FS_SpiesRoundEndTime" ) - Time()
			if(remainingTime < HACK_DURATION)
			{
				// Extend round time by full hack duration
				float newEndTime = ceil( Time() + HACK_DURATION + 1 )
				SetGlobalNetBool( "FS_SpiesIsRoundExtended", true )
				SetGlobalNetTime( "FS_SpiesRoundEndTime", newEndTime )
			}
			
			// Add to global array
			activeHacks.append(hackData)
			
			// Start hack thread
			thread HackProgressThread(hackData)

			// // Show UI
			// Remote_CallFunction_NonReplay(player, "ShowHackProgress", terminal, HACK_DURATION)
		}
	} else
	{
		#if DEVELOPER
		printw("HackableTerminal_OnUseFinished NOT SUCCESS")
		#endif
		terminal.e.isBeingDataknifed = false

		// Disable the other terminals
		foreach( entity panel in activeTerminals )
		{
			if( IsValid( panel ) && !IsTerminalHackActive( panel ) )
				panel.SetUsePrompts( "#DEFAULT_HACK_HOLD_PROMPT", "#DEFAULT_HACK_HOLD_PROMPT" )
		}
	}
}

void function HackProgressThread(ActiveHackData hackData)
{
	entity terminal = hackData.terminal
	entity hacker = hackData.originalHacker
	hackData.currentHacker = hacker
	hackData.lastValidTime = Time()  // Initialize timing

	EndSignal( hacker, "OnDestroy" )
	EndSignal( hacker, "OnDeath" )
	EndSignal( terminal, "OnDestroy" )
	
	OnThreadEnd(
		function() : ( terminal, hackData )
		{
			if( IsValid( terminal ) && hackData.progress < 1.0 && IsTerminalHackActive( terminal ) && IsValid( hackData.currentHacker ) && !IsAlive( hackData.currentHacker ) || hackData.progress < 1.0 && IsTerminalHackActive( terminal ) && !IsValid( hackData.currentHacker ) ) // Unfinished, then it was cancelled because player died or disconnected
			{
				terminal.SetUsePrompts( "Hold %use% to finish the hack", "Hold %use% to finish the hack" )
				hackData.allowTakeover = true
				
				if( IsValid( hackData.currentHacker ) && !IsAlive( hackData.currentHacker ) )
					NotifyHackingState( eHackingStateNotifyReason.HACKER_KILLED )
				else if( !IsValid( hackData.currentHacker ) )
					NotifyHackingState( eHackingStateNotifyReason.HACKER_DISCONNECTED )
				
				thread TakeoverWindowThread(hackData)

				foreach( sPlayer in GetPlayerArrayOfTeam( gCurrentMercTeam ) )
				{
					if(!IsValid(sPlayer)) continue
					
					Remote_CallFunction_NonReplay( sPlayer, "FS_Spies_Center_Msg", eGoalMsgID.DefendStationX, terminal.e.terminalID, GoalMsgIDGetDuration( eGoalMsgID.DefendStationX ), HACKER_DIED_TAKEOVER_TIME )
				}
				
				foreach( sPlayer in GetPlayerArray() )
				{
					if(!IsValid(sPlayer) || !sPlayer.p.clientScriptInitialized) continue
					
					Remote_CallFunction_NonReplay(
						sPlayer,
						"ServerToClient_UpdateHackingHUD",
						hackData.progress,
						eHackingHUDState.TAKEOVER_WINDOW, // Interrupted state
						hackData.currentHacker.GetEncodedEHandle(),
						-1
					)
				}
				
				#if DEVELOPER
				printw( "HACK INTERRUPTED, HACKER DIED OR DISCONNECTED, TAKEOVER ENABLED" )
				#endif
			}
		}
	)
	
	foreach( sPlayer in GetPlayerArray() )
	{
		if(!IsValid(sPlayer) || !sPlayer.p.clientScriptInitialized) continue
		
		Remote_CallFunction_NonReplay(
			sPlayer,
			"ServerToClient_UpdateHackingHUD",
			hackData.progress,
			eHackingHUDState.INITIAL_SETUP, // First set up
			hacker.GetEncodedEHandle(),
			-1
		)
	}
	
	while( hackData.isActive && IsValid(terminal) && IsValid(hacker) )
	{
		float currentTime = Time()
		bool validHacker = IsValid(hackData.currentHacker) && IsAlive(hackData.currentHacker)
		bool inRadius = IsAlive( hacker ) && Distance(hacker.GetOrigin(), terminal.GetOrigin()) <= HACK_RADIUS && !hacker.p.isPlayerInVent
		
		if(!inRadius && validHacker)
		{
			hackData.resetCountdown = min(hackData.resetCountdown + (currentTime - hackData.lastValidTime), RESET_TIMEOUT_OUT_OF_ZONE)
			#if DEVELOPER
			printw( "RESET TERMINAL IN", RESET_TIMEOUT_OUT_OF_ZONE - hackData.resetCountdown )
			#endif
			
			if(hackData.resetCountdown >= RESET_TIMEOUT_OUT_OF_ZONE)
			{
				if( !DESTROY_TERMINAL_ON_HACKING_UNSUCCESFUL )
					ForceDestroyTerminal( null, eHackingStateNotifyReason.RESET_COUNTDOWN )
				else
					ForceDestroyTerminal( terminal, eHackingStateNotifyReason.RESET_COUNTDOWN )
				
				if( IsValid( terminal ) && IsTerminalHackActive( terminal ) )
				{
					ActiveHackData existingHack = GetActiveHackForTerminal(terminal)
					activeHacks.fastremovebyvalue( existingHack )
					
					terminal.SetUsePrompts( "Hacking will be enabled soon", "Hacking will be enabled soon" )
					if( IsValid( terminal.e.dummyPanelForMercs ) )
						terminal.e.dummyPanelForMercs.SetUsePrompts( "Hacking will be enabled soon", "Hacking will be enabled soon" )
					
					if( IsValid( hackData.visualRadiusFx ) )
						hackData.visualRadiusFx.Destroy()
				}
			
				if( GetGlobalNetBool( "FS_SpiesIsRoundExtended" ) )
					SetGlobalNetBool( "FS_SpiesIsRoundExtended", false )

				foreach( sPlayer in GetPlayerArray() )
				{
					if(!IsValid(sPlayer) || !sPlayer.p.clientScriptInitialized) continue
					
					Remote_CallFunction_NonReplay(
						sPlayer,
						"ServerToClient_UpdateHackingHUD",
						hackData.progress,
						eHackingHUDState.HACK_UNSUCCESSFUL, // Shutdown
						hackData.currentHacker.GetEncodedEHandle(),
						gCurrentSpyTeam
					)
				}

				if( IsValid( terminal.e.hackableTerminalWaypoint ) )
					terminal.e.hackableTerminalWaypoint.Destroy()
			
				#if DEVELOPER
				printw( "HACKING CANCELLED DUE TO RESET COUNTDOWN" )
				#endif
				return
			}
		}

		if( inRadius )
		{
			foreach( sPlayer in GetPlayerArray() )
			{
				if(!IsValid(sPlayer) || !sPlayer.p.clientScriptInitialized) continue
				
				// Progress Update
				Remote_CallFunction_NonReplay(
					sPlayer,
					"ServerToClient_UpdateHackingHUD",
					hackData.progress,
					eHackingHUDState.HACK_IN_PROGRESS, // Normal state
					hacker.GetEncodedEHandle(),
					-1
				)
			}
			
			if(currentTime - hackData.lastMessageTime >= 5.0)
			{
				foreach( sPlayer in GetPlayerArrayOfTeam_Alive( gCurrentSpyTeam ) )
				{
					if(!IsValid(sPlayer)) continue
					
					if( sPlayer == hacker )
						Remote_CallFunction_NonReplay( sPlayer, "FS_Spies_Center_Msg", eGoalMsgID.StayAliveInZoneX, terminal.e.terminalID, GoalMsgIDGetDuration( eGoalMsgID.StayAliveInZoneX ), -1 )
					else
					{
						bool sPlayerInRadius = IsAlive( sPlayer ) && Distance(sPlayer.GetOrigin(), terminal.GetOrigin()) <= HACK_RADIUS
						
						if( !sPlayerInRadius )
							Remote_CallFunction_NonReplay( sPlayer, "FS_Spies_Center_Msg", eGoalMsgID.DefendHackerInZoneX, terminal.e.terminalID, GoalMsgIDGetDuration( eGoalMsgID.DefendHackerInZoneX ), -1 )
						else
							Remote_CallFunction_NonReplay( sPlayer, "FS_Spies_Center_Msg", eGoalMsgID.DefendHacker, terminal.e.terminalID, GoalMsgIDGetDuration( eGoalMsgID.DefendHacker ), -1 )
					}
				}

				foreach( sPlayer in GetPlayerArrayOfTeam_Alive( gCurrentMercTeam ) )
				{
					if(!IsValid(sPlayer)) continue
					
					bool sPlayerInRadius = IsAlive( sPlayer ) && Distance(sPlayer.GetOrigin(), terminal.GetOrigin()) <= HACK_RADIUS
					
					if( !sPlayerInRadius )
						Remote_CallFunction_NonReplay( sPlayer, "FS_Spies_Center_Msg", eGoalMsgID.KillHackerInZoneX, terminal.e.terminalID, GoalMsgIDGetDuration( eGoalMsgID.KillHackerInZoneX ), -1 )
					else
						Remote_CallFunction_NonReplay( sPlayer, "FS_Spies_Center_Msg", eGoalMsgID.KillHacker, terminal.e.terminalID, GoalMsgIDGetDuration( eGoalMsgID.KillHacker ), -1 )
				}
				hackData.lastMessageTime = currentTime  // Reset timer
			}
			
			// Update visual state if returning to radius
			if(!hackData.wasInRadius)
			{
				// Remote_CallFunction_NonReplay(hacker, "HackResumed")
				hackData.wasInRadius = true

				#if DEVELOPER
				printw( "HACKING RESUMED" )
				#endif
				
				hackData.lastMessageTime = currentTime - 5.0
			}
			
			// Calculate time since last valid check and accumulate
			float deltaTime = currentTime - hackData.lastValidTime
			hackData.totalHackTime += deltaTime
			hackData.progress = hackData.totalHackTime / HACK_DURATION
			
			// Update UI
			// Remote_CallFunction_NonReplay(hacker, "UpdateHackProgress", hackData.progress)
			
			#if DEVELOPER
			printw( "HACKING IN PROGRESS", hackData.progress )
			#endif
			
			// Check for completion
			if(hackData.progress >= 1.0)
			{
				CompleteHack(hackData)
				return
			}
		}
		else
		{
			// Handle out-of-radius state
			if(hackData.wasInRadius)
			{
				foreach( sPlayer in GetPlayerArray() )
				{
					if(!IsValid(sPlayer) || !sPlayer.p.clientScriptInitialized) continue
					
					Remote_CallFunction_NonReplay(
						sPlayer,
						"ServerToClient_UpdateHackingHUD",
						hackData.progress,
						eHackingHUDState.HACK_INTERRUPTED, // Interrupted state
						hacker.GetEncodedEHandle(),
						-1
					)
				}
				
				Remote_CallFunction_NonReplay( hacker, "FS_Spies_Center_Msg", eGoalMsgID.ReturnToTheZoneX, terminal.e.terminalID, GoalMsgIDGetDuration( eGoalMsgID.ReturnToTheZoneX ), RESET_TIMEOUT_OUT_OF_ZONE - hackData.resetCountdown )
				hackData.wasInRadius = false
				
				#if DEVELOPER
				printw( "HACKING INTERRUPTED" )
				#endif
			}
		}

		// Update timestamp for next calculation
		hackData.lastValidTime = currentTime
		wait HACK_CHECK_INTERVAL
	}
}

// New takeover window thread
void function TakeoverWindowThread(ActiveHackData hackData)
{
	float endTime = Time() + HACKER_DIED_TAKEOVER_TIME
	entity terminal = hackData.terminal
	float pausedTimeLeft = 0.0
	bool wasPaused = false
	
	EndSignal(terminal, "HackerChanged")
	
	while(Time() < endTime && IsValid(terminal))
	{
		// Check if takeover was completed during the loop
		if(hackData.takeoverCompleted)
		{
			#if DEVELOPER
			printw("TAKEOVER COMPLETED - EXITING THREAD")
			#endif
			return  // Exit cleanly without cleanup
		}
		
		// Check pause state
		if( terminal.e.isBeingDataknifed )
		{
			if(!wasPaused)
			{
				// Store remaining time when first entering paused state
				pausedTimeLeft = endTime - Time()
				wasPaused = true
				
				#if DEVELOPER
				printw( "RETAKE PAUSED - TIME REMAINING: " + pausedTimeLeft )
				#endif
			}
			
			// Maintain original endTime while paused
			wait 0.5
			continue
		}
		else if(wasPaused)
		{
			// Restore timer with remaining time when unpausing
			endTime = Time() + pausedTimeLeft
			wasPaused = false
			
			#if DEVELOPER
			printw( "RETAKE RESUMED" )
			#endif
		}

		// Normal timer update
		float timeRemaining = endTime - Time()
		
		#if DEVELOPER
		printw( "RETAKE TIME REMAINING: " + timeRemaining )
		#endif
		
		// // Update UI for potential takers
		// foreach(player in GetPlayerArrayOfTeam(hackData.originalHacker.GetTeam()))
		// {
			// if(!IsValid(player)) continue
			
			// if(IsValid(player) && player != hackData.originalHacker)
			// {
				// // Remote_CallFunction_NonReplay(player, "FS_Spies_ShowTakeoverPrompt", 
					// // hackData.progress, 
					// // endTime - Time(),
					// // terminal.e.terminalID)
			// }
		// }
		wait 0.5
	}
	
	// Cleanup if no one took over, this part won't be triggered if the signal "HackerChanged" is executed
	if(IsValid(terminal) && !hackData.takeoverCompleted)
	{
		#if DEVELOPER
		printw("TAKEOVER WINDOW EXPIRED - CLEANING UP")
		#endif
		
		foreach( sPlayer in GetPlayerArray() )
		{
			if(!IsValid(sPlayer) || !sPlayer.p.clientScriptInitialized) continue
			
			Remote_CallFunction_NonReplay(
				sPlayer,
				"ServerToClient_UpdateHackingHUD",
				hackData.progress,
				eHackingHUDState.HACK_UNSUCCESSFUL, // Shutdown
				hackData.currentHacker.GetEncodedEHandle(),
				gCurrentSpyTeam
			)
		}
		
		if( IsValid( terminal.e.hackableTerminalWaypoint ) )
			terminal.e.hackableTerminalWaypoint.Destroy()
		
		if( !DESTROY_TERMINAL_ON_HACKING_UNSUCCESFUL )
			ForceDestroyTerminal( null, eHackingStateNotifyReason.TAKEOVER_COUNTDOWN )
		else
			ForceDestroyTerminal( terminal, eHackingStateNotifyReason.TAKEOVER_COUNTDOWN )
		
		if( IsValid( terminal ) && IsTerminalHackActive( terminal ) )
		{
			ActiveHackData existingHack = GetActiveHackForTerminal(terminal)
			activeHacks.fastremovebyvalue( existingHack )
			
			terminal.SetUsePrompts( "Hacking will be enabled soon", "Hacking will be enabled soon" )
			if( IsValid( terminal.e.dummyPanelForMercs ) )
				terminal.e.dummyPanelForMercs.SetUsePrompts( "Hacking will be enabled soon", "Hacking will be enabled soon" )
			
			if( IsValid( hackData.visualRadiusFx ) )
				hackData.visualRadiusFx.Destroy()
		}
		
		if( GetGlobalNetBool( "FS_SpiesIsRoundExtended" ) )
			SetGlobalNetBool( "FS_SpiesIsRoundExtended", false )
		
		#if DEVELOPER
		printw( "TAKEOVER TIME ENDED" )
		#endif
	}
}

void function ForceDestroyTerminal( entity terminal, int reason )
{
	if( IsValid( terminal ) )
	{
		terminal.s.hackedOnce = true
		terminal.UnsetUsable()
		terminal.NotSolid()
		terminal.SetUsePrompts( "#EMPTY_STRING", "#EMPTY_STRING" )
		
		if( IsValid( terminal.e.hackableTerminalWaypoint ) )
			terminal.e.hackableTerminalWaypoint.Destroy()
		
		if( IsValid( terminal.e.dummyPanelForMercs ) )
			terminal.e.dummyPanelForMercs.Dissolve( ENTITY_DISSOLVE_CORE, <0,0,0>, 1000 )
		
		int idx = activeTerminals.find(terminal)
		if(idx > -1)
			activeTerminals.remove(idx)
		
		int spawnID = terminal.e.hackableTerminalSpawnID
		
		recentTerminalSpawnHistory.append(spawnID)
		
		if(recentTerminalSpawnHistory.len() > SPAWN_HISTORY_SIZE)
			recentTerminalSpawnHistory.remove(0)
		
		terminal.Dissolve( ENTITY_DISSOLVE_CORE, <0,0,0>, 1000 ) //Use destroy callback to move hack place

		if( activeTerminals.len() <= 1 && hackedTerminalsCount == 0 || activeTerminals.len() == 0 && hackedTerminalsCount == 1 )
		{
			Signal( svGlobal.levelEnt, "RoundEndedFromHackingTerminals" )
			EndRound( gCurrentMercTeam )
			return
		}
		
		if( eHackingStateNotifyReason.TRANSFER_SUCCESSFUL && hackedTerminalsCount == REQUIRED_HACKS)
		{
			Signal( svGlobal.levelEnt, "RoundEndedFromHackingTerminals" )
			// NotifyHackingState( reason )
			
			EndRound( gCurrentSpyTeam )
			return
		}
	}
	
	NotifyHackingState( reason )
	
	thread ReactivateTerminalsAfterDelay()
	
	if( GetGlobalNetBool( "FS_SpiesIsRoundExtended" ) )
		SetGlobalNetBool( "FS_SpiesIsRoundExtended", false )
}

//todo (cafe): localize these msgs
void function NotifyHackingState( int reason, entity player = null )
{
	string spiesTitle = ""
	string spiesSubtext = ""
	string mercsTitle = ""
	string mercsSubtext = ""
	
	switch( reason )
	{
		case eHackingStateNotifyReason.ROUND_START:
			if( SHOULD_HACK_ALL_TERMINALS )
				spiesTitle = "HACK THREE STATIONS"
			else
				spiesTitle = "HACK TWO STATIONS"
			spiesSubtext = "STEAL DATA FROM LEGENDS"
			mercsTitle = "DEFEND ALL STATIONS"
			mercsSubtext = "STOP SPIES FROM HACKING"
		break
		
		case eHackingStateNotifyReason.HACKER_DISCONNECTED:
			spiesTitle = "HACKER DISCONNECTED"
			spiesSubtext = "FINISH THE HACK"
			mercsTitle = "HACKER DISCONNECTED"
			mercsSubtext = "DEFEND THE STATION FROM THE TAKEOVER"
		break
		
		case eHackingStateNotifyReason.HACKER_KILLED:
			spiesTitle = "HACKER DIED"
			spiesSubtext = "FINISH THE HACK"
			mercsTitle = "HACKER KILLED"
			mercsSubtext = "DEFEND THE STATION FROM THE TAKEOVER"
		break
		
		case eHackingStateNotifyReason.TAKEOVER_COUNTDOWN:
		case eHackingStateNotifyReason.RESET_COUNTDOWN:
			spiesTitle = "HACK UNSUCCESSFUL"
			if( !GetGlobalNetBool( "FS_SpiesIsRoundExtended" ) )
				spiesSubtext = "HACK A STATION"
			mercsTitle = "HACK PREVENTED"
			mercsSubtext = "DEFEND THE STATIONS"
		break
		
		case eHackingStateNotifyReason.TRANSFER_SUCCESSFUL:
			spiesTitle = "HACK COMPLETED"
			if( !GetGlobalNetBool( "FS_SpiesIsRoundExtended" ) )
				spiesSubtext = "HACK A STATION"
			mercsTitle = "HACK NOT PREVENTED"
			mercsSubtext = "DEFEND THE STATIONS"
		break
	}
	
	if( IsValid( player ) ) // Was sent to a specific player
	{
		if( player.GetTeam() == gCurrentMercTeam )
			Message( player, mercsTitle, mercsSubtext )
		else if( player.GetTeam() == gCurrentSpyTeam )
			Message( player, spiesTitle, spiesSubtext )
	} else // No player defined, send it to all
	{
		foreach( sPlayer in GetPlayerArrayOfTeam( gCurrentMercTeam ) )
		{
			if(!IsValid(sPlayer)) continue
			
			Message( sPlayer, mercsTitle, mercsSubtext )
		}

		foreach( sPlayer in GetPlayerArrayOfTeam( gCurrentSpyTeam ) )
		{
			if(!IsValid(sPlayer)) continue
			
			if( reason == eHackingStateNotifyReason.HACKER_KILLED && activeHacks.len() > 0 && activeHacks[0].currentHacker == sPlayer )
				continue
			
			Message( sPlayer, spiesTitle, spiesSubtext )
		}
	}
}

void function CompleteHack(ActiveHackData hackData)
{
	#if DEVELOPER
	printw( "HACK COMPLETED!" )
	#endif
	
	foreach( sPlayer in GetPlayerArray() )
	{
		if(!IsValid(sPlayer) || !sPlayer.p.clientScriptInitialized) continue
		
		Remote_CallFunction_NonReplay(
			sPlayer,
			"ServerToClient_UpdateHackingHUD",
			hackData.progress,
			eHackingHUDState.HACK_COMPLETED, // Hack Completed, Shutdown
			hackData.currentHacker.GetEncodedEHandle(),
			gCurrentSpyTeam
		)
	}
	
	HackableTerminal_TransferSuccessful( hackData.terminal )
}

bool function IsTerminalHackActive( entity terminal )
{
	foreach(int i, ActiveHackData data in activeHacks)
	{
		if(data.terminal == terminal)
			return true
	}
	
	return false
}

bool function IsAnyTerminalBeingDataknifed()
{
	foreach(int i, entity terminal in activeTerminals )
	{
		if( terminal.e.isBeingDataknifed )
			return true
	}
	
	return false
}

void function ReactivateTerminalsAfterDelay()
{
	if( GetGlobalNetBool( "FS_SpiesIsRoundExtended" ) || GetGlobalNetTime( "FS_SpiesRoundEndTime" ) - Time() < HACK_REENABLE_TERMINALS_DELAY)
		return
	
	OnThreadEnd(
		function() : ()
		{
			foreach( entity terminal in activeTerminals )
			{
				if( IsValid( terminal ) )
				{
					terminal.SetUsableByGroup( "friendlies pilot" )
					terminal.SetUsePrompts( "#DEFAULT_HACK_HOLD_PROMPT", "#DEFAULT_HACK_HOLD_PROMPT" )
					if( IsValid( terminal.e.dummyPanelForMercs ) )
						terminal.e.dummyPanelForMercs.SetUsePrompts( "#EMPTY_STRING", "#EMPTY_STRING" )

					//Waypoint
					CreateWaypointForTerminal( terminal )
					
					terminal.AddUsableValue( USABLE_CUSTOM_HINTS | USABLE_BY_PILOTS )
					terminal.e.isBeingDataknifed = false
				}
			}
			
			isAnyTerminalBeingHacked = false
		}
	)
	
	#if DEVELOPER
	printw( "TERMINALS WILL BE ENABLED IN", HACK_REENABLE_TERMINALS_DELAY, "SECONDS" )
	#endif
	
	foreach( sPlayer in GetPlayerArray( ) )
	{
		if(!IsValid(sPlayer)) continue
		
		Remote_CallFunction_NonReplay( sPlayer, "FS_Spies_Center_Msg", eGoalMsgID.ForceRemoveMsg, -1, -1, -1 )
	}
	
	wait HACK_REENABLE_TERMINALS_DELAY / 2
	
	foreach( player in GetPlayerArray() )
	{
		if(!IsValid(player)) continue
		
		Remote_CallFunction_NonReplay( player, "FS_Spies_Center_Msg", eGoalMsgID.StationsWillActivate, -1, GoalMsgIDGetDuration( eGoalMsgID.StationsWillActivate ), HACK_REENABLE_TERMINALS_DELAY / 2 )
	}
	wait HACK_REENABLE_TERMINALS_DELAY / 2
}

void function HackableTerminal_TransferSuccessful( entity terminal )
{
	#if DEVELOPER
	printw("HackableTerminal_TransferSuccessful")
	#endif
	
	int spawnID = terminal.e.hackableTerminalSpawnID
	int terminalID = terminal.e.terminalID
	
	hackedTerminalsCount++
	SetGlobalNetInt( "FS_SpiesTerminalsHacked", hackedTerminalsCount )
	
	ForceDestroyTerminal( terminal, eHackingStateNotifyReason.TRANSFER_SUCCESSFUL )

	
	if( CREATE_NEW_TERMINALS_ON_HACK )
	{
		ShuffleTerminalSpawns()
		if(shuffledTerminalsSpawns.len() > 0)
		{
			TerminalSpawn spawnData = shuffledTerminalsSpawns[0]

			foreach( TerminalSpawn spawn in file.selectedLocation.terminalSpawns )
			{
				if( spawn.id == spawnData.id )
				{
					spawn.isOccupied = true
					break
				}
			}
			
			activeTerminals.append( CreateHackablePanel(spawnData.spawn.origin, spawnData.spawn.angles, spawnData.id, terminalID, false ) )
		}
	}

	//Free up this spawn point
	foreach(TerminalSpawn spawn in file.selectedLocation.terminalSpawns)
	{
		if(spawn.id == spawnID)
		{
			spawn.isOccupied = false
			break
		}
	}
}

bool function HackableTerminal_CanUse( entity player, entity terminal )
{
	if ( GetGameState() != eGameState.Playing )
		return false
	
	if ( !ControlPanel_CanUseFunction( player, terminal ) )
		return false

	if( player.GetTeam() != gCurrentSpyTeam )
		return false
	
	if( Time() >= GetGlobalNetTime( "FS_SpiesRoundEndTime" ) )
		return false
	
	// if( terminal.s.hackedOnce )
		// return false
	
	// if( IsTerminalHackActive( terminal ) )
		// return false

	// if( activeHacks.len() > 0 )
		// return false

	if( isAnyTerminalBeingHacked && !IsTerminalHackActive( terminal ) )
		return false
	
	// if( terminal.e.isBeingDataknifed )
		// return false
	
	if( IsAnyTerminalBeingDataknifed() )
		return false
	
	if( Distance(player.GetOrigin(), terminal.GetOrigin()) > HACK_RADIUS )
		return false
		
	// Check for takeover possibility
	if( IsTerminalHackActive( terminal ) )
	{
		ActiveHackData existingHack = GetActiveHackForTerminal(terminal)
		return existingHack.allowTakeover
	}

	return true
}

ActiveHackData function GetActiveHackForTerminal(entity terminal)
{
	foreach(ActiveHackData hack in activeHacks)
	{
		if(IsValid(hack.terminal))
		{
			if(hack.terminal == terminal)
				return hack
		}
	}
	
	unreachable
}
#endif //SERVER

string function TerminalIDToString(int terminalID)
{
	switch(terminalID)
	{
		case eTerminalID.STATION_A:
			return "A"
		case eTerminalID.STATION_B:
			return "B"
		case eTerminalID.STATION_C:
			return "C"
		default:
			return "?"
	}
	
	unreachable
}

//todo (cafe): localize these msgs
string function GoalMsgIDToString(int goalID, int terminalID)
{
	switch(goalID)
	{
		case eGoalMsgID.StayAliveInZoneX:
			return "Stay Alive In Zone " + TerminalIDToString(terminalID) + "\nTRANSFERRING DATA"
		case eGoalMsgID.ReturnToTheZoneX:
			return "Return To Zone " + TerminalIDToString(terminalID)
		
		case eGoalMsgID.DefendHackerInZoneX:
			return "Defend Hacker In Zone " + TerminalIDToString(terminalID)
		case eGoalMsgID.KillHackerInZoneX:
			return "Kill Hacker In Zone " + TerminalIDToString(terminalID)
		case eGoalMsgID.DefendHacker:
			return "Defend The Hacker"
		case eGoalMsgID.KillHacker:
			return "Kill The Hacker"
			
		case eGoalMsgID.DefendStationX:
			return "Defend Station " + TerminalIDToString(terminalID)
			
		case eGoalMsgID.StationsWillActivate:
			return "Stations Will Activate In "
			
		default:
			return "?"
	}
	
	unreachable
}

int function GoalMsgIDGetDuration(int goalID)
{
	switch(goalID)
	{
		case eGoalMsgID.StayAliveInZoneX:
		case eGoalMsgID.DefendHackerInZoneX:
		case eGoalMsgID.KillHackerInZoneX:
		case eGoalMsgID.DefendHacker:
		case eGoalMsgID.KillHacker:
		case eGoalMsgID.DefendStationX:
			return 3
		
		case eGoalMsgID.ReturnToTheZoneX:
		case eGoalMsgID.StationsWillActivate:
			return -1
		
		default:
			return -1
	}
	
	unreachable
}

LocationData function CreateLocationData(string name, array<LocPair> terminalSpawns, array<LocPair> playerSpawns)
{
	LocationData locationSettings
	locationSettings.name = name
	locationSettings.playerSpawns = playerSpawns
	
	array<TerminalSpawn> terminalsSpawns
	foreach( int i, spawn in terminalSpawns )
	{
		TerminalSpawn tSpawn
		tSpawn.spawn = spawn
		tSpawn.isOccupied = false
		tSpawn.id = i
		terminalsSpawns.append( tSpawn )
	}
	locationSettings.terminalSpawns = terminalsSpawns
	
	return locationSettings
}

void function RegisterLocation(LocationData locationSettings)
{
	file.locationSettings.append(locationSettings)
}

#if CLIENT
void function FS_Spies_RoundEndTimeChanged( entity player, float old, float new, bool actuallyChanged )
{
	if ( !actuallyChanged  )
		return
	
	if( new == -1 )
	{
		Signal( GetLocalViewPlayer(), "TimeRemainingHUDReset" )
		file.roundEndTime = -1
		return
	}
	
	thread FS_Spies_ShowRoundEndTimeUI( new )
	
}

void function FS_Spies_ShowRoundEndTimeUI( float endtime )
{
	Signal( GetLocalViewPlayer(), "TimeRemainingHUDReset" )
	EndSignal( GetLocalViewPlayer(), "TimeRemainingHUDReset" )
	
	bool wasRoundExtended = GetGlobalNetBool( "FS_SpiesIsRoundExtended" )
	file.roundEndTime = endtime
	
	// #if DEVELOPER
	// printw( "FS_Spies_RoundEndTimeChanged", old, endtime, "- EXTENDED ROUND?", wasRoundExtended )
	// #endif
	
	var timeRemainingText = file.timeRemainingText
	
	if( file.timeRemainingText == null ) // Edge case for respawning
		return
	
	var roundNumberText = file.roundNumberText
	var roundDataFrame0 = file.roundDataFrame0
	var roundDataFrame = file.roundDataFrame
	var roundDataTerminalsHacked = file.roundDataTerminalsHacked
	
	array<var> roundDataElements
	roundDataElements.append( roundNumberText )
	roundDataElements.append( timeRemainingText )
	roundDataElements.append( roundDataFrame )
	roundDataElements.append( roundDataFrame0 )
	roundDataElements.append( roundDataTerminalsHacked )
	
	BuildAndShowScoreHUD( true )
	
	OnThreadEnd(
		function() : ( roundDataElements )
		{
			foreach( elem in roundDataElements )
			{
				Hud_SetVisible( elem, false )
				Hud_ReturnToBasePos( elem )
			}
			
			BuildAndShowScoreHUD( false )
		}
	)
	
	UISize screenSize = GetScreenSize()
	float resMultX = screenSize.width / 1920.0
	float resMultY = screenSize.height / 1080.0
	
	int xOffset = 0
	int yOffset = -100
	
	foreach( elem in roundDataElements )
	{
		// if( elem == roundDataFrame ) //|| elem == roundDataFrame0 ) //temp
			// continue //temp
		
		Hud_SetVisible( elem, true )

		UIPos basePos = REPLACEHud_GetPos( elem )
		
		Hud_SetAlpha( elem, 0 )
		Hud_SetPos( elem, basePos.x + xOffset * resMultX, basePos.y + yOffset * resMultY )
		
		Hud_FadeOverTime( elem, 255, 0.15, INTERPOLATOR_ACCEL )
		Hud_MoveOverTime( elem, basePos.x, basePos.y, 0.15 )
		
		thread FlickerMsgElement( false, elem )
	}
	
	string roundNumberMsg = "ROUND " + GetGlobalNetInt( "FS_SpiesRoundNumber" ) //+ " " + ( wasRoundExtended ? "- TIME EXTENDED" : "" )
	
	entity player = GetLocalViewPlayer()
	// EndSignal( player, "OnDestroy" )
	
	if( player.GetTeam() == GetGlobalNetInt( "FS_SpyTeam" ) )
	{
		roundNumberMsg += " - HACK"
	} else
	{
		roundNumberMsg += " - DEFEND"
	}
	
	Hud_SetText( file.roundNumberText, roundNumberMsg )
	
	if( wasRoundExtended )
	{
		Hud_SetText( timeRemainingText, "EXTENDED" )
		WaitForever()
	}
	
	DisplayTime dt
	
	while ( Time() <= endtime )
	{
		dt = SecondsToDHMSM( endtime - Time() )
		Hud_SetText( timeRemainingText, format( "%.2d:%.2d:%.2d", dt.minutes, dt.seconds, dt.milliseconds ) )
		
		if( IsValid( player ) )
		{
			if( player.GetTeam() == GetGlobalNetInt( "FS_SpyTeam" ) )
				Hud_SetText( roundDataTerminalsHacked, "TERMINALS HACKED: " + GetGlobalNetInt( "FS_SpiesTerminalsHacked" ) + " / 3" )
			else
				Hud_SetText( roundDataTerminalsHacked, "TERMINALS BREACHED: " + GetGlobalNetInt( "FS_SpiesTerminalsHacked" ) + " / 3" )
		}
		
		WaitFrame()
	}
}

void function FS_Spies_Center_Msg( int goalID, int terminalID, int duration, int timeRemaining )
{
	thread function () : ( duration, goalID, terminalID, timeRemaining )
	{
		if( goalID == eGoalMsgID.ForceRemoveMsg )
		{
			Signal( GetLocalClientPlayer(), "SpiesCenterMsgReset" )
			return
		}
		
		Signal( GetLocalClientPlayer(), "SpiesCenterMsgReset" )
		EndSignal( GetLocalClientPlayer(), "SpiesCenterMsgReset" )
		EndSignal( GetLocalClientPlayer(), "OnDeath" )
		
		UISize screenSize = GetScreenSize()
		float resMultX = screenSize.width / 1920.0
		float resMultY = screenSize.height / 1080.0
		
		int xOffset = 0
		int yOffset = 400
		
		var msgElement = file.centerMsgElement
		
		Hud_SetVisible( msgElement, true )

		OnThreadEnd(
			function() : ( msgElement )
			{
				Hud_SetVisible( msgElement, false )
				Hud_ReturnToBasePos( msgElement )
			}
		)
		
		//Actual anim
		{
			UIPos basePos = REPLACEHud_GetPos( msgElement )
			
			Hud_SetAlpha( msgElement, 0 )
			Hud_SetPos( msgElement, basePos.x + xOffset * resMultX, basePos.y - 100 * resMultY )
			
			Hud_FadeOverTime( msgElement, 255, 0.15, INTERPOLATOR_ACCEL )
			Hud_MoveOverTime( msgElement, basePos.x, basePos.y, 0.15 )
			
			// file.centerMsgStaticText = GoalMsgIDToString( goalID, terminalID )
			Hud_SetText( msgElement, GoalMsgIDToString( goalID, terminalID ) )
			
			if( timeRemaining != -1 )
			{
				thread FS_Spies_Center_Msg_SetText( goalID, terminalID, timeRemaining )
			}
			
			thread FlickerMsgElement( true, msgElement )
			
			wait 0.25 //fade and move times
			
			if( duration != -1 )
				wait duration //actual desired duration
			else
				WaitForever()
			
			UIPos currentPos = REPLACEHud_GetPos( msgElement )

			Hud_FadeOverTime( msgElement, 0, 0.15, INTERPOLATOR_ACCEL )
			Hud_MoveOverTime( msgElement, currentPos.x + xOffset * resMultX, currentPos.y + yOffset * resMultY, 0.25 )
			
			wait 0.3
		}
	}()
}

void function FS_ShowRoundStartTimeUI()
{
	DoF_SetFarDepth( 1000, 2000 )
	
	Hud_SetVisible( HudElement( "FS_Respawn_Countdown_Center" ), true )

	int timeToStart = ROUND_START_DELAY_TIME
	
	thread Flowstate_RespawnTimer_Thread( timeToStart, 3 )
	thread Spies_RoundStart_Sounds( Time() + timeToStart, 0 )
}

void function FS_ShowRoundStartSelectingTeamTimeUI()
{
	DoF_SetFarDepth( 1000, 2000 )
	
	Hud_SetVisible( HudElement( "FS_Respawn_Countdown_Center" ), true )

	int timeToStart = ROUND_START_DELAY_TIME
	
	thread Flowstate_RespawnTimer_Thread( timeToStart, 4 )
	thread Spies_RoundStart_Sounds( Time() + timeToStart, 1 )
}

void function Spies_RoundStart_Sounds( float starttime, int type = 0)
{
	entity player = GetLocalViewPlayer()
	
	EndSignal( player, "OnDestroy" )
	
	if( type == 4 )
		EndSignal( player, "SpiesCenterMsgReset" )
		
	// Obituary_Print_Localized( "%$rui/flowstate_custom/colombia_flag_papa% Game mode by @CafeFPS - Engine by @AmosModz", GetChatTitleColorForPlayer( GetLocalViewPlayer() ), BURN_COLOR )
	
	while( Time() < ( starttime - 3.0 ) )
	{
		EmitSoundOnEntity( player, "UI_Survival_Intro_LaunchCountDown_10Seconds" )
		wait 1.0
	}

	while( Time() < starttime - 0.5 )
	{
		EmitSoundOnEntity( player, "UI_Survival_Intro_LaunchCountDown_3Seconds" )
		wait 1.0
	}

	while( Time() < starttime )
		WaitFrame()
	
	if( type == 0 )	
		EmitSoundOnEntity( player, "UI_InGame_TitanWar_CampsDeployed" ) //"UI_InGame_NextRound" )
	else if( type == 1 )
		EmitSoundOnEntity( player, "UI_Survival_Intro_LaunchCountDown_Finish" )
	else if( type == 3 )
		EmitSoundOnEntity( player, "UI_InGame_TitanWar_ClearTerritory" )
	else if( type == 4 )
		EmitSoundOnEntity( player, "ui_ingame_markedfordeath_playermarked" )
	
	DoF_SetNearDepthToDefault()
	DoF_SetFarDepthToDefault()
}

string function GetDynamicTimeElement( int goalID, int timeRemaining)
{
	string dynamicText = ""
	switch( goalID )
	{
		case eGoalMsgID.ReturnToTheZoneX:
			dynamicText = "\n       " + "RESET IN" + " " + format("%02d", ceil(timeRemaining))// + "s"
		break
		
		case eGoalMsgID.StationsWillActivate:
			dynamicText = format("%02d", ceil(timeRemaining))// + "s"
		break
	}
	
	return dynamicText
}

void function FS_Spies_Center_Msg_SetText( int goalID, int terminalID, int timeRemaining )
{
	#if DEVELOPER
	printw( "FS_Spies_Center_Msg_SetText THREAD", timeRemaining )
	#endif
	
	string baseText = GoalMsgIDToString( goalID, terminalID )
	
	EndSignal( GetLocalViewPlayer(), "SpiesCenterMsgReset" )
	EndSignal( GetLocalViewPlayer(), "OnDeath" )
	
	if( timeRemaining == -1 )
		return

	if( goalID == eGoalMsgID.StationsWillActivate )
		thread Spies_RoundStart_Sounds( Time() + timeRemaining, 3 )
	else if( goalID == eGoalMsgID.ReturnToTheZoneX )
		thread Spies_RoundStart_Sounds( Time() + timeRemaining, 4 )
	
	int endtime = int( Time() ) + timeRemaining
	
	while ( Time() <= endtime )
	{
		Hud_SetText( file.centerMsgElement, baseText + GetDynamicTimeElement( goalID, timeRemaining ) )
		
		timeRemaining--
		wait 1
	}
	
	Hud_SetVisible( file.centerMsgElement, false )
}
	
void function FS_Spies_Center_Msg_ForceEnd()
{
	Signal( GetLocalClientPlayer(), "SpiesCenterMsgReset" )
}

void function FlickerMsgElement( bool isCenterMsg, var msgElement )
{
	if( isCenterMsg )
		EndSignal( GetLocalClientPlayer(), "SpiesCenterMsgReset" )
	
	OnThreadEnd(
		function() : ( msgElement )
		{
			Hud_SetAlpha( msgElement, 255 )
		}
	)
	
	for( int j = 0; j < 5; j++ )
	{
		Hud_SetAlpha( msgElement, 50 )
		wait 0.025
		Hud_SetAlpha( msgElement, 255 )
		wait 0.025
	}
}

void function ServerToClient_UpdateHackingHUD(float progress, int state, int eHandle, int spyTeam )
{
    // Early return if HUD elements aren't initialized yet
    if(!IsValid(file.hackingProgressRui) || !IsValid(file.hackingProgressRuiBg) ||
       !IsValid(file.hackingStatusText) || !IsValid(file.hackingStatusText2) ||
       !IsValid(file.hackerNameText))
    {
        #if DEVELOPER
        printw("SKIPPING HUD UPDATE - ELEMENTS NOT INITIALIZED YET")
        #endif
        return
    }
	
	entity player = GetLocalViewPlayer()
	entity hacker = GetEntityFromEncodedEHandle(eHandle)
	string statusText = "HACK IN PROGRESS"
	string name = IsValid(hacker) ? hacker.GetPlayerName() : ""
	
	if( IsValid( hacker ) )
		file.hackerHandle = eHandle
	
	array<var> hudElements
	hudElements.append( file.hackingProgressRui )
	hudElements.append( file.hackingProgressRuiBg )
	hudElements.append( file.hackingStatusText )
	hudElements.append( file.hackingStatusText2 )
	hudElements.append( file.hackerNameText )
	
	switch(state)
	{
		case eHackingHUDState.TAKEOVER_WINDOW: // New hacker
			statusText = "TAKEOVER WINDOW"
			EmitSoundOnEntity(GetLocalViewPlayer(), "ui_lobby_rankchip_enable")
			break
		
		case eHackingHUDState.HACK_INTERRUPTED: // Interrupted
			statusText = "HACK INTERRUPTED"
			EmitSoundOnEntity(GetLocalViewPlayer(), "ui_lobby_rankchip_disable")
			break
			
		case eHackingHUDState.HACK_UNSUCCESSFUL:
			if( player.GetTeam() == spyTeam )
			{
				statusText = "HACK UNSUCCESSFUL"
				EmitSoundOnEntity(GetLocalViewPlayer(), "ui_ingame_coop_defeat")
			}
			else
			{
				statusText = "HACK PREVENTED"
				EmitSoundOnEntity(GetLocalViewPlayer(), "ui_ingame_challengecompleted")
			}
			
			break
			
		case eHackingHUDState.HACK_COMPLETED:
			if( player.GetTeam() == spyTeam )
			{
				statusText = "HACK COMPLETED"
				EmitSoundOnEntity(GetLocalViewPlayer(), "ui_ingame_challengecompleted")
			}
			else
			{
				statusText = "HACK NOT PREVENTED"
				EmitSoundOnEntity(GetLocalViewPlayer(), "ui_ingame_coop_defeat")
			}
			
			break
	}

	// Update RUI and text elements
	RuiSetImage(Hud_GetRui( file.hackingProgressRuiBg ), "basicImage", $"rui/flowstate_custom/sl_hackinprogress" )
	RuiSetFloat(Hud_GetRui( file.hackingProgressRui ), "installProgress", progress)
	file.currentHackingProgress = progress
	
	Hud_SetText(file.hackingStatusText, statusText)
	
	if( state != file.lastHackerHudState ) // If it's not progress update, flicker it
	{
		thread FlickerMsgElement( false, file.hackingStatusText )
		
		if( state == eHackingHUDState.HACK_IN_PROGRESS )
		{
			EmitSoundOnEntity( GetLocalViewPlayer(), "ui_lobby_rankchip_enable" )
			// EmitSoundOnEntity( GetLocalViewPlayer(), "Valk_Hover_Loop_1P" )
		} else
		{
			// StopSoundOnEntity( GetLocalViewPlayer(), "Valk_Hover_Loop_1P" )
		}
	}
	
	file.lastHackerHudState = state
	
	if(name != "")
	{
		if( state == eHackingHUDState.TAKEOVER_WINDOW )
		{
			Hud_SetText(file.hackingStatusText2, "HACKER KILLED")
		} else
		{
			Hud_SetText(file.hackingStatusText2, "HACKER")
		}
		
		Hud_SetText(file.hackerNameText, name)
	}
	
	if( state == eHackingHUDState.HACK_UNSUCCESSFUL || state == eHackingHUDState.HACK_COMPLETED )
	{
		thread function () : (hudElements)
		{
			wait 3
			
			foreach( elem in hudElements )
			{
				UIPos basePos = REPLACEHud_GetBasePos( elem )
				// Hud_SetVisible(elem, false)
				// Hud_SetPos(elem, basePos.x + xOffset * resMultX, basePos.y - yOffset * resMultY)

				Hud_MoveOverTime(elem, basePos.x, basePos.y + 400, 0.15)
				Hud_FadeOverTime(elem, 0, 0.15, INTERPOLATOR_ACCEL)
				
				if( elem == file.hackingProgressRuiBg )
					Hud_SetVisible(elem, false)
			}
		}()
	} else if( state == eHackingHUDState.INITIAL_SETUP ) // First set up
	{
		UISize screenSize = GetScreenSize()
		float resMultX = screenSize.width / 1920.0
		float resMultY = screenSize.height / 1080.0
		
		int xOffset = 0
		int yOffset = 100
		
		foreach( elem in hudElements )
		{
			UIPos basePos = REPLACEHud_GetBasePos( elem )
			
			Hud_SetAlpha(elem, 0)
			Hud_SetPos(elem, basePos.x + xOffset * resMultX, basePos.y - yOffset * resMultY)
			
			Hud_FadeOverTime(elem, 255, 0.15, INTERPOLATOR_ACCEL)
			Hud_MoveOverTime(elem, basePos.x, basePos.y, 0.15)
			
			Hud_SetVisible(elem, true)
		}
	}
}

void function ServerToClient_RoundWinnerScreen(int winnerTeam, int currentSpyTeam)
{
	thread function() : (winnerTeam, currentSpyTeam)
	{
		entity player = GetLocalClientPlayer()

		DoF_SetFarDepth( 50, 1000 )

		OnThreadEnd(
			function() : ( )
			{
				DoF_SetNearDepthToDefault()
				DoF_SetFarDepthToDefault()
			}
		)

		EmitSoundOnEntity(player, "UI_InGame_Top5_Streak_1X")
		
		var LTMLogo = HudElement( "SkullLogo")
		var RoundWinOrLoseText = HudElement( "WinOrLoseText")
		var WinOrLoseReason = HudElement( "WinOrLoseReason")
		var LTMBoxMsg = HudElement( "LTMBoxMsg")
		
		bool localPlayerIsWinner = player.GetTeam() == winnerTeam
		bool localPlayerIsSpy = player.GetTeam() == currentSpyTeam
		
		if( localPlayerIsWinner )
			RuiSetImage( Hud_GetRui( LTMLogo ), "basicImage", $"rui/flowstatecustom/ltm_logo" )
		else
			RuiSetImage( Hud_GetRui( LTMLogo ), "basicImage", $"rui/flowstatecustom/ltm_logo_red" )
		
		
		if( localPlayerIsWinner )
			RuiSetImage( Hud_GetRui( LTMBoxMsg ), "basicImage", $"rui/flowstatecustom/ltm_box_msg" )
		else
			RuiSetImage( Hud_GetRui( LTMBoxMsg ), "basicImage", $"rui/flowstatecustom/ltm_box_msg_red" )
		
		string roundText// = localPlayerIsWinner ? "ROUND WIN" : "ROUND LOSS"
		
		if( localPlayerIsWinner ) //winnerTeam == currentSpyTeam )
		{
			roundText = "ROUND WIN"
		} else
		{
			roundText = "ROUND LOSS"
		}
		
		string reasonText
		
		if( localPlayerIsWinner )
		{
			if( localPlayerIsSpy )
				reasonText = "ENOUGH DATA SECURED"
			else
				reasonText = "TERMINALS PROTECTED"
		}
		else
		{
			if( localPlayerIsSpy )
				reasonText = "YOU FAILED TO EXTRACT ENOUGH DATA"
			else
				reasonText = "CRITICAL SYSTEMS BREACHED"
		}
		
		Hud_SetText( RoundWinOrLoseText, roundText )
		Hud_SetText( WinOrLoseReason, reasonText )
		
		WaitFrame()
		
		Hud_SetEnabled( LTMLogo, true )
		Hud_SetVisible( LTMLogo, true )
		
		Hud_SetEnabled( RoundWinOrLoseText, true )
		Hud_SetVisible( RoundWinOrLoseText, true )
		
		Hud_SetEnabled( WinOrLoseReason, true )
		Hud_SetVisible( WinOrLoseReason, true )
		
		Hud_SetEnabled( LTMBoxMsg, true )
		Hud_SetVisible( LTMBoxMsg, true )
		
		Hud_SetSize( LTMLogo, 0, 0 )
		Hud_SetSize( LTMBoxMsg, 0, 0 )
		Hud_SetSize( RoundWinOrLoseText, 0, 0 )
		Hud_SetSize( WinOrLoseReason, 0, 0 )

		Hud_ScaleOverTime( LTMLogo, 1.2, 1.2, 0.4, INTERPOLATOR_ACCEL )
		
		wait 0.4
		
		Hud_ScaleOverTime( LTMLogo, 1, 1, 0.15, INTERPOLATOR_LINEAR )
		
		wait 0.35
		
		Hud_ScaleOverTime( RoundWinOrLoseText, 1, 1, 0.35, INTERPOLATOR_SIMPLESPLINE )
		Hud_ScaleOverTime( LTMBoxMsg, 1, 1, 0.3, INTERPOLATOR_SIMPLESPLINE )
		Hud_ScaleOverTime( WinOrLoseReason, 1, 1, 0.35, INTERPOLATOR_SIMPLESPLINE )
		
		wait 4.5
		
		Hud_ScaleOverTime( LTMLogo, 1.3, 0.05, 0.15, INTERPOLATOR_ACCEL )
		
		Hud_ScaleOverTime( RoundWinOrLoseText, 1.3, 0.05, 0.15, INTERPOLATOR_ACCEL )
		Hud_ScaleOverTime( LTMBoxMsg, 1.3, 0.05, 0.15, INTERPOLATOR_ACCEL )
		Hud_ScaleOverTime( WinOrLoseReason, 1.3, 0.05, 0.15, INTERPOLATOR_ACCEL )
		
		wait 0.15
		
		Hud_ScaleOverTime( LTMLogo, 0, 0, 0.1, INTERPOLATOR_LINEAR )
		Hud_ScaleOverTime( RoundWinOrLoseText, 0, 0, 0.1, INTERPOLATOR_LINEAR )
		Hud_ScaleOverTime( LTMBoxMsg, 0, 0, 0.1, INTERPOLATOR_LINEAR )
		Hud_ScaleOverTime( WinOrLoseReason, 0, 0, 0.1, INTERPOLATOR_LINEAR )
		
		if(IsValid(GetLocalViewPlayer()))
			EmitSoundOnEntity(GetLocalViewPlayer(), "HUD_MP_Match_End_WinLoss_UI_Sweep_1P")
		
		wait 1.15
		
		Hud_SetEnabled( LTMLogo, false )
		Hud_SetVisible( LTMLogo, false )
		
		Hud_SetEnabled( RoundWinOrLoseText, false )
		Hud_SetVisible( RoundWinOrLoseText, false )
		
		Hud_SetEnabled( WinOrLoseReason, false )
		Hud_SetVisible( WinOrLoseReason, false )
		
		Hud_SetEnabled( LTMBoxMsg, false )
		Hud_SetVisible( LTMBoxMsg, false )
		
		Hud_SetSize( LTMLogo, 1, 1 )
		Hud_SetSize( RoundWinOrLoseText, 1, 1 )
	}()
}

void function ServerToClient_UpdateScoreHUD( int team, int score )
{
	if( team == -1 )
	{
		Hud_SetText( file.ltText, "0 / 3" )
		Hud_SetText( file.etText, "0 / 3" )

		file.imcScore = 0
		file.militiaScore = 0
		return
	}
	
	bool isTeamLocalTeam = team == GetLocalViewPlayer().GetTeam()
	
	if( isTeamLocalTeam )
	{
		Hud_SetText( file.ltText, score.tostring() + " / 3" ) // hardcoded max score is temp
	} else
	{
		Hud_SetText( file.etText, score.tostring() + " / 3" ) // hardcoded max score is temp
	}
	
	if( team == TEAM_IMC )
		file.imcScore = score
	else if( team == TEAM_MILITIA )
		file.militiaScore = score
}

void function BuildAndShowScoreHUD( bool show )
{
	array<var> hudElements
	hudElements.append( file.ltGradient )
	hudElements.append( file.ltBlur )
	hudElements.append( file.ltLogo )
	hudElements.append( file.ltText )
	hudElements.append( file.etGradient )
	hudElements.append( file.etBlur )
	hudElements.append( file.etLogo )
	hudElements.append( file.etText )
	
	if( show )
	{
		UISize screenSize = GetScreenSize()
		float resMultX = screenSize.width / 1920.0
		float resMultY = screenSize.height / 1080.0
		
		int xOffset = 0
		int yOffset = -100
		
		foreach( elem in hudElements )
		{
			Hud_SetVisible( elem, true )

			UIPos basePos = REPLACEHud_GetPos( elem )
			
			Hud_SetAlpha( elem, 0 )
			Hud_SetPos( elem, basePos.x + xOffset * resMultX, basePos.y + yOffset * resMultY )
			
			Hud_FadeOverTime( elem, 255, 0.15, INTERPOLATOR_ACCEL )
			Hud_MoveOverTime( elem, basePos.x, basePos.y, 0.15 )
			
			thread FlickerMsgElement( false, elem )
		}
	} else
	{
		foreach( elem in hudElements )
			Hud_SetVisible(elem, false )
	}
	
	int localTeam = GetLocalViewPlayer().GetTeam()
	
	RuiSetImage( Hud_GetRui( file.ltGradient ), "basicImage", $"rui/menu/common/gradient_blue" )
	RuiSetImage( Hud_GetRui( file.etGradient ), "basicImage", $"rui/menu/common/gradient_red" )
	
	if( localTeam == TEAM_IMC )
	{
		RuiSetImage( Hud_GetRui( file.ltLogo ), "basicImage", $"rui/flowstatecustom/imc" )
		RuiSetImage( Hud_GetRui( file.etLogo ), "basicImage", $"rui/flowstatecustom/militia" )
	} else if( localTeam == TEAM_MILITIA )
	{
		RuiSetImage( Hud_GetRui( file.ltLogo ), "basicImage", $"rui/flowstatecustom/militia" )
		RuiSetImage( Hud_GetRui( file.etLogo ), "basicImage", $"rui/flowstatecustom/imc" )
	}
}

void function DEV_TestGradientRui( )
{
	var gradient = HudElement( "FS_Spies_LocalTeam_Score_Gradient")
	
	RuiSetImage( Hud_GetRui( gradient ), "basicImage", $"rui/menu/common/gradient_blue" )
	
	var logo = HudElement( "FS_Spies_LocalTeam_Score_Logo")
	RuiSetImage( Hud_GetRui( logo ), "basicImage", $"rui/flowstatecustom/militia" )

	var gradient2 = HudElement( "FS_Spies_EnemyTeam_Score_Gradient")
	
	RuiSetImage( Hud_GetRui( gradient2 ), "basicImage", $"rui/menu/common/gradient_red" )

	var logo2 = HudElement( "FS_Spies_EnemyTeam_Score_Logo")
	RuiSetImage( Hud_GetRui( logo2 ), "basicImage", $"rui/flowstatecustom/imc" )
}

void function DEV_TestProgressRui( bool show, float progress )
{
	array<var> hudElements
	hudElements.append( file.hackingProgressRui )
	hudElements.append( file.hackingProgressRuiBg )
	hudElements.append( file.hackingStatusText )
	hudElements.append( file.hackingStatusText2 )
	hudElements.append( file.hackerNameText )
	
	UISize screenSize = GetScreenSize()
	float resMultX = screenSize.width / 1920.0
	float resMultY = screenSize.height / 1080.0
	
	int xOffset = 0
	int yOffset = 100
	
	RuiSetImage( Hud_GetRui( file.hackingProgressRuiBg ), "basicImage", $"rui/flowstate_custom/sl_hackinprogress" )
	RuiSetFloat( Hud_GetRui( HudElement( "FS_ProgressTest" ) ), "installProgress", progress )
	
	foreach( elem in hudElements )
	{
		if( show )
		{
			UIPos basePos = REPLACEHud_GetPos( elem )
			
			Hud_SetAlpha(elem, 0)
			Hud_SetPos(elem, basePos.x + xOffset * resMultX, basePos.y - yOffset * resMultY)
			
			Hud_FadeOverTime(elem, 255, 0.15, INTERPOLATOR_ACCEL)
			Hud_MoveOverTime(elem, basePos.x, basePos.y, 0.15)
			
			Hud_SetVisible(elem, true)
		} else
		{
			Hud_SetVisible(elem, false)
		}
	}
}

// ██╗   ██╗███████╗███╗   ██╗████████╗███████╗
// ██║   ██║██╔════╝████╗  ██║╚══██╔══╝██╔════╝
// ██║   ██║█████╗  ██╔██╗ ██║   ██║   ███████╗
// ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║   ╚════██║
//  ╚████╔╝ ███████╗██║ ╚████║   ██║   ███████║
//   ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝
// Only 30 dlights entities on client allowed by code :(

void function ServerCallback_PlayerInVent()
{
	entity player = GetLocalViewPlayer()
	
	EmitSoundOnEntity( player, "PhaseGate_Enter_1p" )
	
	thread InVentScreenFx_Thread( player )
}

void function ServerCallback_PlayerOutOfVent()
{
	entity player = GetLocalViewPlayer()
	
	if ( IsValid( player ) )
	{
		if ( player == GetLocalViewPlayer() )
		{
			Signal( player, KILL_VENT_FX_SIGNAL )
		}
	}
}

void function InVentScreenFx_Thread( entity player )
{
	Signal( player, KILL_VENT_FX_SIGNAL )

	EndSignal( player, "OnDeath", "OnDestroy", KILL_VENT_FX_SIGNAL )
	
	int fxHandle = StartParticleEffectOnEntityWithPos( player, GetParticleSystemIndex( FX_VENT_HUD ), FX_PATTACH_ABSORIGIN_FOLLOW, -1, player.EyePosition(), <0,0,0> )
	EffectSetIsWithCockpit( fxHandle, true )

	int fxHandle2 = StartParticleEffectOnEntityWithPos( player, GetParticleSystemIndex( FX_VENT_HUD_INSTANT ), FX_PATTACH_ABSORIGIN_FOLLOW, -1, player.EyePosition(), <0,0,0> )
	EffectSetIsWithCockpit( fxHandle2, true )
	
	OnThreadEnd(
		function(): ( player, fxHandle )
		{
			if ( EffectDoesExist( fxHandle ) )
			{
				EffectStop( fxHandle, false, true )
			}
		}
	)
	
	WaitForever()
}
#endif //CLIENT

#if SERVER
entity function CreateVentDoorTrigger(vector origin, vector angles)
{
	VentData vent
	
    // Create vent prop
    vent.collisionProp = CreatePropDynamic($"mdl/canyonlands/clands_wall_vent_round_01_a.rmdl", origin, angles, 6)
    vent.collisionProp.SetCollisionAllowed(true)
    vent.collisionProp.SetModelScale( 1.6 )
	SetTeam( vent.collisionProp, gCurrentSpyTeam )
	vent.collisionProp.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY
	
	Highlight_SetNeutralHighlight( vent.collisionProp, "friendly_player_decoy" )
	Highlight_SetFriendlyHighlight( vent.collisionProp, "friendly_player_decoy" )

    vent.enemyDummyProp = CreatePropDynamic($"mdl/canyonlands/clands_wall_vent_round_01_a.rmdl", origin, angles, 0)
    vent.enemyDummyProp.SetCollisionAllowed(false)
    vent.enemyDummyProp.SetModelScale( 1.6 )
	SetTeam( vent.enemyDummyProp, gCurrentMercTeam )
	vent.enemyDummyProp.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY
	// vent.enemyDummyProp.SetParent( vent.collisionProp )
	
    // Get model bounds
    vector mins = vent.collisionProp.GetBoundingMins()
    vector maxs = vent.collisionProp.GetBoundingMaxs()
    
    // Calculate trigger size based on model bounds
    float radius = GetPropRadius( vent.collisionProp )
    float height = maxs.z - mins.z
    
    // Create cylindrical trigger matching model bounds
    vent.trigger = CreateEntity("trigger_cylinder")
    vent.trigger.SetRadius(radius)
    vent.trigger.SetAboveHeight(height/2)
    vent.trigger.SetBelowHeight(height/2)
    vent.trigger.SetOrigin(origin + (mins + maxs) * 0.5) // Center trigger
    vent.trigger.SetAngles(angles)
    vent.trigger.SetEnterCallback(OnVentTriggerEnter)
    vent.trigger.SetLeaveCallback(OnVentTriggerLeave)
	
	vent.trigger.SetParent( vent.collisionProp )
    DispatchSpawn(vent.trigger)
    
    file.vents.append( vent )
    return vent.collisionProp
}

float function GetPropRadius(entity prop)
{
    vector mins = prop.GetBoundingMins()
    vector maxs = prop.GetBoundingMaxs()
    return max(fabs(mins.x), fabs(maxs.x)) * 1.3
}

void function DEV_TestGroundEnt()
{
	entity player = gp()[0]
	
	entity groundEnt = player.GetGroundEntity()
	
	while( IsValid( player ) )
	{
		groundEnt = player.GetGroundEntity()
		if( IsValid( groundEnt ) )
			printt( groundEnt.GetModelName() )
		WaitFrame()
	
	}
}

void function OnVentTriggerEnter(entity trigger, entity player)
{
    if(!IsValid(player) || !player.IsPlayer() || GetGameState() != eGameState.Playing )
        return
    
	entity prop = trigger.GetParent()
	
	if( !IsValid( prop ) )
		return
	
	if( player.GetTeam() != gCurrentSpyTeam ) //&& prop.e.isVentUnlocked )
	{
		KnockBackPlayer( player, -player.GetForwardVector()*100, 1, 0.25 )
		return
	} 
	// else if( player.GetTeam() != gCurrentSpyTeam )
		// return

	// printw( "OnVentTriggerEnter" )
	prop.SetCollisionAllowed( false )
	// prop.e.isVentUnlocked = true
}

void function OnVentTriggerLeave(entity trigger, entity player)
{
    if(!IsValid(player) || !player.IsPlayer() || player.GetTeam() != gCurrentSpyTeam)
        return
    
    // printw( "OnVentTriggerLeave" )
	entity prop = trigger.GetParent()
	
	if( !IsValid( prop ) )
		return
	
	prop.SetCollisionAllowed( true )
	// prop.e.isVentUnlocked = false
}

void function CreateHotelVents()
{
	foreach( vent in file.vents )
	{
		if( IsValid( vent.collisionProp ) )
			vent.collisionProp.Destroy()
			
		if( IsValid( vent.enemyDummyProp ) )
			vent.enemyDummyProp.Destroy()
	}
	
    CreateVentDoorTrigger( < -1188.8, 1238.5, 1827 >, < 0, 0, 0 >)
    CreateVentDoorTrigger( < -1594.3, 401.6, 1827 >, < 0, -90, 0 >)
    // CreateVentDoorTrigger( < -567.5, 469.3, 1655 >, < 0, -90, 0 >)
    CreateVentDoorTrigger( < -1703, 694.6, 1827 >, < 0, 0, 0 >)
    CreateVentDoorTrigger( < -1191.4, 956.3, 1827 >, < 0, -180, 0 >)
    CreateVentDoorTrigger( < -1702.6, 188.9, 1828.8 >, < 0, -180, 0 >)
    CreateVentDoorTrigger( < -2277.4, 401.0008, 1827 >, < 0, 90, 0 >)
    CreateVentDoorTrigger( < -1850, -1478.3, 1683.5 >, < 0, -90, 0 >)
    CreateVentDoorTrigger( < -1589, -469.8, 1683.2 >, < 0, 90, 0 >)
    CreateVentDoorTrigger( < -2134.8, -809.1, 1970.6 >, < 0, 0, 0 >)
    CreateVentDoorTrigger( < -2071.4, -809, 2115.3 >, < 0, 0, 0 >)
    CreateVentDoorTrigger( < -1604.5, -358.2, 1970.6 >, < 0, 90, 0 >)
    CreateVentDoorTrigger( < -1077.2, -853, 1683.2 >, < 0, 90, 0 >)
    CreateVentDoorTrigger( < -2341, -1222.2, 1827 >, < 0, 90, 0 >)
    CreateVentDoorTrigger( < -1851.1, -422.5, 1827 >, < 0, -90, 0 >)
    CreateVentDoorTrigger( < -2341, -422.5, 1827 >, < 0, 90, 0 >)
    CreateVentDoorTrigger( < -1255.9, -73.5, 1827 >, < 0, 0, 0 >)
    CreateVentDoorTrigger( < -1604.5, -663, 2115.3 >, < 0, 90, 0 >)
    CreateVentDoorTrigger( < -1960, -1222.5, 2115.3 >, < 0, -90, 0 >)
    CreateVentDoorTrigger( < -1192, 476.8, 1971.8 >, < 0, -180, 0 >)
    CreateVentDoorTrigger( < -1093.7, -662.8, 1970.6 >, < 0, 90, 0 >)
    CreateVentDoorTrigger( < -2101, -1478.3, 1678 >, < 0, 90, 0 >)
    CreateVentDoorTrigger( < -2119.5, 630.9001, 1953.9 >, < 0, 0, 0 >)
}

// ██╗      █████╗ ███╗   ███╗██████╗ ███████╗
// ██║     ██╔══██╗████╗ ████║██╔══██╗██╔════╝
// ██║     ███████║██╔████╔██║██████╔╝███████╗
// ██║     ██╔══██║██║╚██╔╝██║██╔═══╝ ╚════██║
// ███████╗██║  ██║██║ ╚═╝ ██║██║     ███████║
// ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝     ╚══════╝

void function SaveLampData( vector origin, vector angles, int type = -1 )
{
	LampData lamp
	
	lamp.id = file.lamps.len()
	lamp.enabled = true
	lamp.origin = origin
	lamp.angles = angles
	lamp.type = type
	
	switch( type )
	{
		case 1:
		lamp.radius = 100.0
		break
		
		case 2:
		lamp.radius = 150.0
		break
		
		case 3 :
		lamp.radius = 150.0
		break
	}
	
	file.lamps.append( lamp )
	
	printw( "Saved lamp data", file.lamps.len() + 1 )
}

void function THREAD_LampsFlickering()
{
	while( true )
	{
		wait RandomIntRange( 2, 5 )
		
		if( GetGameState() != eGameState.Playing )
			continue
		
		array<LampData> allLamps = clone file.lamps
		
		// Filter out disabled lamps
		for ( int i = allLamps.len() - 1; i >= 0; i-- )
		{
			if( !allLamps[i].enabled )
				allLamps.remove( i )
		}
		
		// Lamp selection logic remains the same
		array<LampData> lampsToFlicker
		bool disablingAllLamps = false
		if( RandomIntRange( 1, 100 ) > 10 && allLamps.len() >= 2 )
		{
			lampsToFlicker.append( allLamps.getrandom() )
			allLamps.removebyvalue( lampsToFlicker.top() )
			lampsToFlicker.append( allLamps.getrandom() )
		}
		else if( allLamps.len() >= 1 )
		{
			lampsToFlicker.extend( allLamps )
			disablingAllLamps = true
		}

		foreach( LampData lamp in lampsToFlicker )
		{
			thread function() : ( disablingAllLamps, lamp )
			{
				bool useFadeEffect = disablingAllLamps ? false : true
				float originalRadius = lamp.radius
				float fadeDuration = 1.0 // Seconds for fade out/in
				int steps = 10 // Number of interpolation steps
				
				lamp.enabled = false
				
				if( useFadeEffect )
				{
					// Fade out
					for( int i = steps; i >= 0; i-- )
					{
						float currentRadius = originalRadius * (i / steps.tofloat())
						UpdateLampForAllPlayers( lamp, currentRadius )
						wait fadeDuration / steps
					}
				}
				else
				{
					// Immediate off
					UpdateLampForAllPlayers( lamp, 0 )
				}

				// Wait while lamp is off
				wait RandomIntRange( 3, 10 )

				if( useFadeEffect )
				{
					// Fade in
					for( int i = 0; i <= steps; i++ )
					{
						float currentRadius = originalRadius * (i / steps.tofloat())
						UpdateLampForAllPlayers( lamp, currentRadius )
						wait fadeDuration / steps
					}
				}
				else
				{
					// Immediate restore
					UpdateLampForAllPlayers( lamp, originalRadius )
				}

				// Re-enable lamp
				lamp.enabled = true
			}()
		}
	}
}

// Helper function to update lamp state for all players
void function UpdateLampForAllPlayers( LampData lamp, float radius )
{
	lamp.radius = radius
	
	foreach( player in GetPlayerArray() )
	{
		if( radius > 0 )
		{
			switch( lamp.type )
			{
				case 1:
					Remote_CallFunction_NonReplay( player, "ServerCallback_SpawnOrModifyClientSideDynamicLight", lamp.origin - Vector(0,0,50), <0,0,0>, 1, radius, 5.0, lamp.id )
					break
				case 2:
					Remote_CallFunction_NonReplay( player, "ServerCallback_SpawnOrModifyClientSideDynamicLight", lamp.origin - Vector(0,0,50), <0,0,0>, 0, radius, 10.0, lamp.id )
					break
				case 3:
					Remote_CallFunction_NonReplay( player, "ServerCallback_SpawnOrModifyClientSideDynamicLight", lamp.origin - Vector(0,0,50), <0,0,0>, 9, radius, 10.0, lamp.id )
					break
			}
		}
	}
}

void function Spies_AddPropMap( entity prop ) //?
{
	file.mapProps.append( prop ) 
}
#endif

//Shared
// ██████╗  █████╗ ██████╗  ██████╗ ███████╗████████╗███████╗    ███████╗███████╗██╗     ███████╗ ██████╗████████╗ ██████╗ ██████╗ 
//██╔════╝ ██╔══██╗██╔══██╗██╔════╝ ██╔════╝╚══██╔══╝██╔════╝    ██╔════╝██╔════╝██║     ██╔════╝██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗
//██║  ███╗███████║██║  ██║██║  ███╗█████╗     ██║   ███████╗    ███████╗█████╗  ██║     █████╗  ██║        ██║   ██║   ██║██████╔╝
//██║   ██║██╔══██║██║  ██║██║   ██║██╔══╝     ██║   ╚════██║    ╚════██║██╔══╝  ██║     ██╔══╝  ██║        ██║   ██║   ██║██╔══██╗
//╚██████╔╝██║  ██║██████╔╝╚██████╔╝███████╗   ██║   ███████║    ███████║███████╗███████╗███████╗╚██████╗   ██║   ╚██████╔╝██║  ██║
// ╚═════╝ ╚═╝  ╚═╝╚═════╝  ╚═════╝ ╚══════╝   ╚═╝   ╚══════╝    ╚══════╝╚══════╝╚══════╝╚══════╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝
// 

void function SetupSpiesAbilitiesData()
{
	file.spyGadgets.clear()
	file.spyGadgets.append( CreateAbilityData( "Cloak", "mp_ability_cloak_spieslegends", $"rui/flowstate_custom/ability_cloak", false ) )
	file.spyGadgets.append( CreateAbilityData( "Smoke Grenade", "mp_weapon_grenade_bangalore_single", $"rui/flowstate_custom/ability_smoke_grenade", false ) )
	file.spyGadgets.append( CreateAbilityData( "Flashbang Grenade", "mp_weapon_grenade_flashbang_spieslegends", $"rui/flowstate_custom/ability_flashbang", false ) )
	file.spyGadgets.append( CreateAbilityData( "Void Dash", "mp_ability_dodge_roll_v2", $"rui/flowstate_custom/ability_void_dash", false ) )
	file.spyGadgets.append( CreateAbilityData( "Devices Jammer", "mp_ability_devices_jammer", $"rui/flowstate_custom/devices_jammer", false ) )
	// file.spyGadgets.append( CreateAbilityData( "Satchel Camera", "temp", $"rui/flowstate_custom/camera_satchel", false ) )
	
	file.spyGadgets.append( CreateAbilityData( "Veil", "temp", $"rui/flowstate_custom/passive_autocloak", true ) )
	file.spyGadgets.append( CreateAbilityData( "Silent", "temp", $"rui/flowstate_custom/passive_nofootsteps", true ) )
	file.spyGadgets.append( CreateAbilityData( "Execute", "temp", $"rui/flowstate_custom/passive_kill_from_behind", true ) )
}

void function SetupMercsAbilitiesData()
{
	file.mercGadgets.clear()
	file.mercGadgets.append( CreateAbilityData( "Proximity Mine", "mp_weapon_proximity_mine_spieslegends", $"rui/flowstate_custom/ability_proximity_mine", false ) )
	file.mercGadgets.append( CreateAbilityData( "Electric Smoke", "mp_weapon_grenade_electric_smoke_spieslegends", $"rui/flowstate_custom/ability_electric_smoke", false ) )
	file.mercGadgets.append( CreateAbilityData( "Pulse Blade", "mp_weapon_grenade_sonar_spieslegends", $"rui/flowstate_custom/ability_pulse_blade", false ) )
	file.mercGadgets.append( CreateAbilityData( "Rev Shell", "mp_weapon_grenade_rev_shell", $"rui/flowstate_custom/rev_shel", false ) )
	file.mercGadgets.append( CreateAbilityData( "Turret", "mp_weapon_turret", $"rui/flowstate_custom/turret", false ) )
	
	file.mercGadgets.append( CreateAbilityData( "Surge", "temp", $"rui/flowstate_custom/passive_fastheal", true ) )
	file.mercGadgets.append( CreateAbilityData( "Regen", "temp", $"rui/flowstate_custom/passive_heal_out_of_combat", true ) )
	file.mercGadgets.append( CreateAbilityData( "Fortified", "temp", $"rui/flowstate_custom/passive_fortified", true ) )
}

AbilityData function CreateAbilityData(string name, string weaponName, asset icon, bool isPassive)
{
	AbilityData ability
	ability.name = name
	ability.weaponName = weaponName
	ability.icon = icon
	ability.isPassive = isPassive
	
	return ability
}

#if CLIENT
void function BuildAbilitiesDataOnUI()
{
	RunUIScript("ClearAbilitiesData")
	
	foreach( ability in file.spyGadgets )
		RunUIScript("AddSpyAbility", ability.name, ability.weaponName, ability.icon, ability.isPassive )
	
	foreach( ability in file.mercGadgets )
		RunUIScript("AddMercAbility", ability.name, ability.weaponName, ability.icon, ability.isPassive )
}
#endif