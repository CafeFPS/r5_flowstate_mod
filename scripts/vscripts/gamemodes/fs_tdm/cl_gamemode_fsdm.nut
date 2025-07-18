untyped

global function Cl_CustomTDM_Init
global function Cl_RegisterLocation
global function OpenTDMWeaponSelectorUI
global function ServerCallback_SendScoreboardToClient
global function ServerCallback_SendProphuntPropsScoreboardToClient
global function ServerCallback_SendProphuntHuntersScoreboardToClient
global function ServerCallback_ClearScoreboardOnClient
	
//Statistics
global function ServerCallback_OpenStatisticsUI

//Persistence
global function ServerCallback_SetLGDuelPesistenceSettings

// Voting
global function ServerCallback_FSDM_OpenVotingPhase
global function ServerCallback_FSDM_ChampionScreenHandle
global function ServerCallback_FSDM_UpdateVotingMaps
global function ServerCallback_FSDM_UpdateMapVotesClient
global function ServerCallback_FSDM_SetScreen
global function ServerCallback_FSDM_CoolCamera
global function PROPHUNT_AddWinningSquadData_PropTeamAddModelIndex
global function DM_HintCatalog
global function FSDM_CloseVotingPhase

//Ui callbacks
global function UI_To_Client_VoteForMap_FSDM

//networked vars callbacks
global function CL_FSDM_RegisterNetworkFunctions

global function FSHaloMod_CreateKillStreakAnnouncement

global function Flowstate_ShowRoundEndTimeUI
global function Flowstate_PlayStartRoundSounds
global function Flowstate_ShowStartTimeUI
global function FS_1v1_ToggleUIVisibility
global function Toggle1v1Scoreboard
global function ForceHide1v1Scoreboard
global function ForceShow1v1Scoreboard

global function fs_NewBoxBuildMessage
global function fs_NewBoxShowMessage

global function fs_ServerMsgsToChatBox_BuildMessage
global function fs_ServerMsgsToChatBox_ShowMessage

global function FS_Scenarios_TogglePlayersCardsVisibility

global function FS_Scenarios_AddAllyHandle
global function FS_Scenarios_AddEnemyHandle
global function FS_Scenarios_AddEnemyHandle2

global function FS_Scenarios_InitPlayersCards
global function FS_Scenarios_SetupPlayersCards
global function FS_Scenarios_ChangeAliveStateForPlayer
global function FS_CreateTeleportFirstPersonEffectOnPlayer

global function FS_Show1v1Banner
global function FS_SetHideEndTimeUI

global function Gamemode1v1_ForceLegendSelector_Deprecated
global function Tracker_ShowChampion

global function Flowstate_ShowRespawnTimeUI
global function Flowstate_ShowMatchFoundUI

global function UiToClient_ConfirmRest
global function FS_Scenarios_SetRingCloseTimeForMinimap

global function FS4DIntroSequence
global function HaloBrIntroSequence
global function Flowstate_RespawnTimer_Thread
global function SelfShowChampion

global function SetShow1v1Scoreboard
global function FS_1v1_DisplayHints

const string CIRCLE_CLOSING_IN_SOUND = "UI_InGame_RingMoveWarning" //"survival_circle_close_alarm_01"

struct {
    LocationSettings &selectedLocation
    array<LocationSettings> locationSettings
	int teamwon
	vector victorySequencePosition = < 0, 0, 10000 >
	vector victorySequenceAngles = < 0, 0, 0 >
	SquadSummaryData winnerSquadSummaryData
	bool forceShowSelectedLocation = false

	var activeQuickHint
	var activeQuickHint2
	var countdownRui

	float currentX_Offset = 0
	float currentY_Offset = 0
	asset currentMapImage
	float mapscale
	bool show1v1Scoreboard = true

	string fs_newMsgBoxString        = ""
	string fs_newMsgBoxSubString     = ""
	
	string fs_newServerMsgsToChatBoxString        = ""
	string fs_newServerMsgsToChatBoxSubString     = ""

	//Scenarios cards
	var vsBasicImage
	var vsBasicImage2
	array<var> allyTeamCards
	array<var> enemyTeamCards
	array<var> enemyTeamCards2
	
	array<int> allyTeamHandles
	array<int> enemyTeamHandles
	array<int> enemyTeamHandles2

	bool hideendtimeui = false
} file

struct VictoryCameraPackage
{
	vector camera_offset_start
	vector camera_offset_end
	vector camera_focus_offset
	float camera_fov
}

bool hasvoted = false
bool isvoting = false
bool roundover = false
array<var> overHeadRuis
array<entity> cleanupEnts

void function Cl_CustomTDM_Init()
{
    AddCallback_EntitiesDidLoad( FS_DM_OnEntitiesDidLoad )
	AddClientCallback_OnResolutionChanged( Cl_OnResolutionChanged )

	RegisterButtonPressedCallback(KEY_ENTER, ClientReportChat)
	PrecacheParticleSystem($"P_wpn_lasercannon_aim_short_blue")
	PrecacheParticleSystem($"P_training_teleport_FP")
	PrecacheParticleSystem( $"P_wrth_tt_portal_screen_flash" )
	
	RegisterSignal("ChallengeStartRemoveCameras")
	RegisterSignal("ChangeCameraToSelectedLocation")
	RegisterSignal("FSDM_EndTimer")
	RegisterSignal("NewKillChangeRui")
	RegisterSignal("FS_CloseNewMsgBox")
	RegisterSignal("FS_1v1Banner")
	RegisterSignal("StopCurrentEnemyThread")
	RegisterSignal("Destroy1v1SettingsHint")
	
	if( GetCurrentPlaylistVarBool( "enable_oddball_gamemode", false ) )
		Cl_FsOddballInit()
	
	switch( Playlist() )
	{
		case ePlaylists.fs_scenarios:
			AddCallback_OnClientScriptInit( FS_Scenarios_OnClientScriptInit )
			FS_Scenarios_Score_System_Init()
		break 
		
		case ePlaylists.fs_1v1:
			AddCallback_CharacterSelectMenu_OnCharacterLocked( Gamemode1v1_OnSelectedLegend )
			AddCallback_OnCharacterSelectMenuClosed( Gamemode1v1_OnLegendSelector_Close )
		case ePlaylists.fs_vamp_1v1:
		// case ePlaylists.fs_1v1_headshotsonly:
		case ePlaylists.fs_lgduels_1v1:
			RegisterConCommandTriggeredCallback( "+scriptCommand5", FS_RestButton )
			RegisterConCommandTriggeredCallback( "+scriptCommand3", FS_SettingsButton )
			RegisterConCommandTriggeredCallback( "+scriptCommand4", FS_SpectateButton )
		break 
		
		case ePlaylists.fs_haloMod:
			RegisterConCommandTriggeredCallback( "weaponSelectOrdnance", SetRecentWeapon )
		break

	}
	
	thread DisableChat_UntilRemoteIsReady_Thread()
}

void function Gamemode1v1_ForceLegendSelector_Deprecated() //TODO: Client-based open
{
	OpenCharacterSelectAimTrainer( true )
}

void function Gamemode1v1_OnLegendSelector_Close()
{
	CharacterSelect_SetMenuState( eNewCharacterSelectMenuState.PICKING )
}

void function Gamemode1v1_OnSelectedLegend( ItemFlavor character )
{
	entity player = GetLocalClientPlayer()
	
	if( IsValid( player ) )
	{
		thread
		(
			void function() : ( player, character )
			{
				wait 0.5 //rawr timing issue
				RunUIScript( "Gamemode1v1_CloseLegendMenu" )
				player.ClientCommand( "challenge legend -1 " + string( ItemFlavor_GetGUID( character ) ) )
				ScreenFade( GetLocalViewPlayer(), 255, 255, 255, 255, .1, 0, FFADE_PURGE | FFADE_INOUT | FFADE_NOT_IN_REPLAY )
			}
		)()
		
	}
}

const MAX_WAIT_FOR_BATCH = 20
const MAX_WAIT_FOR_CONNECT = 5
void function DisableChat_UntilRemoteIsReady_Thread()
{
	WaitClientConnection()
	
	if( !GetServerVar( "tracker_enabled" ) )
		return
		
	HideChat()

	OnThreadEnd
	(
		void function()
		{
			ShowChat()
		}
	)
	
	entity player = GetLocalClientPlayer()
	float startTime = Time()
	
	while( !GetServerVar( "batch_fetch_complete" ) )
	{	
		if( !IsValid( player ) )
			return 
		
		if( Time() > startTime + MAX_WAIT_FOR_BATCH )
			break
		
		WaitFrames( 5 )
	}
		
}

void function WaitClientConnection()
{
	FlagWait( "ClientInitComplete" )
}

void function FS_Scenarios_OnClientScriptInit( entity player ) 
{
	FS_Scenarios_InitPlayersCards()
}

void function CL_FSDM_RegisterNetworkFunctions()
{
	if ( IsLobby() )
		return
	
	if( Playlist() == ePlaylists.fs_scenarios )
	{
		RegisterNetworkedVariableChangeCallback_time( "FS_Scenarios_gameStartTime", Flowstate_StartTimeChanged )
		RegisterNetworkedVariableChangeCallback_bool( "characterSelectionReady", FS_Scenarios_OnGroupCharacterSelectReady )
	}

	RegisterNetworkedVariableChangeCallback_time( "flowstate_DMStartTime", Flowstate_StartTimeChanged )
	RegisterNetworkedVariableChangeCallback_time( "flowstate_DMRoundEndTime", Flowstate_RoundEndTimeChanged )
	if( Playlist() == ePlaylists.fs_1v1 || Playlist() == ePlaylists.fs_vamp_1v1 || Playlist() == ePlaylists.fs_1v1_headshots_only || Playlist() == ePlaylists.fs_lgduels_1v1 )
	{
		RegisterNetworkedVariableChangeCallback_ent( "FSDM_1v1_Enemy", Flowstate_1v1EnemyChanged )
		RegisterNetworkedVariableChangeCallback_bool( "FS_PlayerIsMnk", FS_1v1_InputChanged )
		RegisterNetworkedVariableChangeCallback_int( "FS_1v1_PlayerState", FS_1v1_PlayerStateChanged )
	}
}

void function FS_SetHideEndTimeUI( bool show )
{
	file.hideendtimeui = show
}

void function FS_Scenarios_OnGroupCharacterSelectReady( entity player, bool old, bool new, bool actuallyChanged )
{
	if ( player != GetLocalClientPlayer() )
		return

	if( new )
	{
		#if DEVELOPER 
			printt( "[Scenarios Character Select] Open" )
		#endif 
		
		Fullmap_SetVisible( false )
		UpdateMainHudVisibility( GetLocalViewPlayer() )
		Flowstate_ForceRemoveAllObituaries()
		FS_SetHideEndTimeUI( true )
		Obituary_Print_Localized( "%$rui/bullet_point% Players Connected: " + GetPlayerArray().len(), GetChatTitleColorForPlayer( GetLocalViewPlayer() ), BURN_COLOR )
		Obituary_Print_Localized( "FS Scenarios - Made by @CafeFPS and mkos.", GetChatTitleColorForPlayer( GetLocalViewPlayer() ), BURN_COLOR )
		OpenCharacterSelectNewMenu()
	}
	else
	{
		#if DEVELOPER
			printt( "[Scenarios Character Select] Close" )
		#endif 
		
		CloseCharacterSelectNewMenu()
		RunUIScript( "UI_CloseCharacterSelect" )
		FS_SetHideEndTimeUI( false )
	}
}

void function Gamemode1v1_PlayRestFX()
{
	entity player = GetLocalClientPlayer()
	int fxHandle = StartParticleEffectOnEntityWithPos( player, GetParticleSystemIndex( $"P_wrth_tt_portal_screen_flash" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1, player.EyePosition(), <0,0,0> )
	EffectSetIsWithCockpit( fxHandle, true )

	EmitSoundOnEntity( player, "gruntcooper_wounded_loop_1p" )
}

void function FS_1v1_PlayerStateChanged( entity player, int oldValue, int newValue, bool actuallyChanged )
{
	if ( newValue == e1v1State.CHARSELECT ) //not called
		return

	var text = HudElement( "FS_DMCountDown_Text" )
	var frame = HudElement( "FS_DMCountDown_Frame" )

	if ( player != GetLocalClientPlayer() )
	{
		newValue = e1v1State.SPECTATING // (cafe) handles weird bug where newValue is sent as CHARSELECT) when it has to be SPECTATING based on server netvar choice
	} else
	{
		UIPos basepos = REPLACEHud_GetBasePos( frame )
		UIPos baseposText = REPLACEHud_GetBasePos( text )
		UISize screenSize = GetScreenSize()
		
		if( newValue != e1v1State.MATCHING )
		{
			Hud_SetPos( text, baseposText.x -70	 * screenSize.width / 1920.0, baseposText.y + 12 * screenSize.height / 1080.0 ) //text is parented to the frame so not need to change text pos
			Hud_SetPos( frame, basepos.x -15 * screenSize.width / 1920.0, basepos.y + 250 * screenSize.height / 1080.0 ) //text is parented to the frame so not need to change text pos
		} else
		{
			Hud_SetPos( text, baseposText.x -70	 * screenSize.width / 1920.0, baseposText.y + 12 * screenSize.height / 1080.0 ) //text is parented to the frame so not need to change text pos
			Hud_SetPos( frame, basepos.x -15 * screenSize.width / 1920.0, basepos.y + 0 * screenSize.height / 1080.0 ) //text is parented to the frame so not need to change text pos
		}
	}
		
	#if DEVELOPER
		printw( "[CLIENT] 1v1 LOCAL PLAYER STATE CHANGED TO:",newValue,  DEV_GetEnumStringSafe( "e1v1State", newValue ) )
	#endif
	switch( newValue )
	{
		case e1v1State.INVALID:
		//
		break
		
		case e1v1State.MATCH_START:
		SetWaitingRoomLightningTest()
		break
		
		case e1v1State.SPECTATING:
		FS_1v1_DisplayHints(e1v1State.SPECTATING)
		break
		
		case e1v1State.RESTING:
		EmitSoundOnEntity( GetLocalClientPlayer(), "UI_InGame_FD_UnReadyUp_1p" )
		Gamemode1v1_PlayRestFX()
		Minimap_DisableDraw_Internal()
		FS_1v1_DisplayHints(e1v1State.RESTING)
		SetWaitingRoomLightningTest()
		Minimap_DisableDraw_Internal()
		// RunUIScript("FS_1v1_SettingsMenu_Open")
		break

		case e1v1State.WAITING:
		if( oldValue == e1v1State.RESTING )
		{
			EmitSoundOnEntity( GetLocalClientPlayer(), "UI_InGame_FD_ReadyUp_1p" )
			Gamemode1v1_PlayRestFX()
		}
		Minimap_DisableDraw_Internal()
		RunUIScript("FS_1v1_SettingsMenu_Close")
		FS_1v1_DisplayHints(e1v1State.WAITING)
		SetWaitingRoomLightningTest()
		Minimap_DisableDraw_Internal()
		break
		
		case e1v1State.MATCHING:
		RunUIScript("FS_1v1_SettingsMenu_Close")
		Signal( player, "Destroy1v1SettingsHint" )
		SetDefaultLightning()
		Minimap_EnableDraw_Internal()
		break
		
		default:
		RunUIScript("FS_1v1_SettingsMenu_Close")
		Signal( player, "Destroy1v1SettingsHint" )
		// SetDefaultLightning()
		break
	}
}

void function SetWaitingRoomLightningTest()
{
	// switch( GetMapName() )
	// {
		// case "mp_rr_arena_composite":
			// SetConVarFloat( "mat_autoexposure_force_value", 0.8 )
			// SetConVarFloat( "mat_bloom_max_lighting_value", 0.03 )
			
			// // SetConVarFloat( "mat_autoexposure_max", 0.3 )
			// // SetConVarFloat( "mat_autoexposure_max_multiplier", 0.4 )
			// // SetConVarFloat( "mat_autoexposure_min", 0.2 )
			// // SetConVarFloat( "mat_autoexposure_min_multiplier", 1.0 )

			// SetConVarFloat( "mat_sky_scale", 2.0 )
			// SetConVarString( "mat_sky_color", "1.0 1.0 1.0 1.0" )
			// SetConVarFloat( "mat_sun_scale", 0.0 )
			// SetConVarString( "mat_sun_color", "1.0 1.5 2.0 1.0" )
		// break
	// }
}

void function SetDefaultLightning()
{
	// SetConVarToDefault( "mat_autoexposure_force_value" )
	// SetConVarToDefault( "mat_bloom_max_lighting_value" )
	
	// SetConVarToDefault( "mat_autoexposure_max" )
	// SetConVarToDefault( "mat_autoexposure_max_multiplier" )
	// SetConVarToDefault( "mat_autoexposure_min" )
	// SetConVarToDefault( "mat_autoexposure_min_multiplier" )

	// SetConVarToDefault( "mat_sky_scale" )
	// SetConVarToDefault( "mat_sky_color" )
	// SetConVarToDefault( "mat_sun_scale" )
	// SetConVarToDefault( "mat_sun_color" )
}

void function FS_1v1_InputChanged( entity player, bool old, bool new, bool actuallyChanged )
{
	entity localPlayer = GetLocalClientPlayer()
	
	if( player != localPlayer )
		return
	
	if( new )
		MG_MovementOverlay_toggle( true )
	else
		MG_MovementOverlay_toggle( false )
}

void function Flowstate_1v1EnemyChanged( entity player, entity oldEnt, entity newEnt, bool actuallyChanged )
{
	if( Playlist() != ePlaylists.fs_1v1 && Playlist() != ePlaylists.fs_lgduels_1v1 )
		return
	
	entity localPlayer = GetLocalClientPlayer()
	
	if( player != localPlayer )
		return
	
	// #if DEVELOPER
		// printw( "Flowstate_1v1EnemyChanged ", newEnt, actuallyChanged )
	// #endif
	
	if ( !IsValid( localPlayer ) || !IsValid( newEnt ) || !newEnt.IsPlayer() || localPlayer != GetLocalViewPlayer() )
	{
		FS_1v1_ToggleUIVisibility( false, null )
		return
	}
	
	FS_1v1_ToggleUIVisibility( true, newEnt )
}

void function FS_1v1_ToggleUIVisibility( bool toggle, entity newEnt )
{
	entity player = GetLocalClientPlayer()
	
	Signal( player, "StopCurrentEnemyThread" )
	
	if( !file.show1v1Scoreboard )
		toggle = false

	Hud_SetVisible( HudElement( "FS_1v1_UI_BG"), toggle )
	Hud_SetVisible( HudElement( "FS_1v1_UI_EnemyName"), toggle )

	// Hud_SetVisible( HudElement( "FS_1v1_UI_KillLeader"), toggle )
	// RuiSetImage( Hud_GetRui( HudElement( "FS_1v1_UI_KillLeader") ), "basicImage", $"rui/hud/gamestate/player_kills_leader_icon" )
	
	if( IsValid( newEnt ) )
	{
		//añadir check para el largo del nombre
		Hud_SetText( HudElement( "FS_1v1_UI_EnemyName"), newEnt.GetPlayerName() ) 
		thread function() : ( player, toggle )
		{
			Hud_ReturnToBasePos( HudElement( "FS_1v1_UI_EnemyName") )
			Hud_SetSize( HudElement( "FS_1v1_UI_EnemyName"), 0, 0 )
			Hud_ScaleOverTime( HudElement( "FS_1v1_UI_EnemyName"), 1.3, 1.3, 0.05, INTERPOLATOR_ACCEL)
			wait 0.05
			Hud_ScaleOverTime( HudElement( "FS_1v1_UI_EnemyName"), 1, 1, 0.1, INTERPOLATOR_SIMPLESPLINE)
		}()
	}
	Hud_SetVisible( HudElement( "FS_1v1_UI_EnemyKills"), toggle )
	Hud_SetVisible( HudElement( "FS_1v1_UI_EnemyDeaths"), toggle )
	Hud_SetVisible( HudElement( "FS_1v1_UI_EnemyDamage"), toggle )
	Hud_SetVisible( HudElement( "FS_1v1_UI_EnemyLatency"), toggle )
	Hud_SetVisible( HudElement( "FS_1v1_UI_EnemyPosition"), toggle )

	Hud_SetVisible( HudElement( "FS_1v1_UI_Name"), toggle )
	//añadir check para el largo del nombre
	Hud_SetText( HudElement( "FS_1v1_UI_Name"), GetLocalClientPlayer().GetPlayerName() ) 

	Hud_SetVisible( HudElement( "FS_1v1_UI_Kills"), toggle )
	Hud_SetVisible( HudElement( "FS_1v1_UI_Deaths"), toggle )
	Hud_SetVisible( HudElement( "FS_1v1_UI_Damage"), toggle )
	Hud_SetVisible( HudElement( "FS_1v1_UI_Latency"), toggle )
	Hud_SetVisible( HudElement( "FS_1v1_UI_Position"), toggle )

	RuiSetImage( Hud_GetRui( HudElement( "FS_1v1_UI_BG") ), "basicImage", $"rui/flowstate_custom/1v1_bg" )
	
	if( !toggle ) 
		return
	
	thread FS_1v1_StartUpdatingValues( newEnt )
}

void function FS_1v1_StartUpdatingValues( entity newEnt )
{
	entity player = GetLocalClientPlayer()
	
	Signal( player, "StopCurrentEnemyThread" )
	EndSignal( player, "StopCurrentEnemyThread" )
	
	while( file.show1v1Scoreboard && IsValid( newEnt ) && IsValid( player ) )
	{
		Hud_SetText( HudElement( "FS_1v1_UI_EnemyKills"), newEnt.GetPlayerNetInt( "kills" ).tostring() ) 
		Hud_SetText( HudElement( "FS_1v1_UI_EnemyDeaths"), newEnt.GetPlayerNetInt( "deaths" ).tostring() ) 
		Hud_SetText( HudElement( "FS_1v1_UI_EnemyDamage"), newEnt.GetPlayerNetInt( "damage" ).tostring() ) 
		Hud_SetText( HudElement( "FS_1v1_UI_EnemyLatency"), newEnt.GetPlayerNetInt( "latency" ).tostring() )
		Hud_SetText( HudElement( "FS_1v1_UI_EnemyPosition"), newEnt.GetPlayerNetInt( "FSDM_1v1_PositionInScoreboard" ).tostring() ) 
		
		Hud_SetText( HudElement( "FS_1v1_UI_Kills"), player.GetPlayerNetInt( "kills" ).tostring() ) 
		Hud_SetText( HudElement( "FS_1v1_UI_Deaths"), player.GetPlayerNetInt( "deaths" ).tostring() ) 
		Hud_SetText( HudElement( "FS_1v1_UI_Damage"), player.GetPlayerNetInt( "damage" ).tostring() ) 
		Hud_SetText( HudElement( "FS_1v1_UI_Latency"), player.GetPlayerNetInt( "latency" ).tostring() )
		Hud_SetText( HudElement( "FS_1v1_UI_Position"), player.GetPlayerNetInt( "FSDM_1v1_PositionInScoreboard" ).tostring() ) 
		wait 0.5
	}
}

void function SetShow1v1Scoreboard( string show )
{
	bool bShow = show == "0" ? false : true
	
	file.show1v1Scoreboard = bShow
	
	// Toggle1v1Scoreboard()
}

void function Toggle1v1Scoreboard() 
{
	entity player = GetLocalClientPlayer()

	if( file.show1v1Scoreboard )
	{
		file.show1v1Scoreboard = false
		Signal( player, "StopCurrentEnemyThread" )
		FS_1v1_ToggleUIVisibility( false, null )
	}
	else
	{
		if( GetGlobalNetInt( "FSDM_GameState" ) == eTDMState.IN_PROGRESS && player.GetPlayerNetEnt( "FSDM_1v1_Enemy" ) != null )
		{
			file.show1v1Scoreboard = true
			FS_1v1_ToggleUIVisibility( true, player.GetPlayerNetEnt( "FSDM_1v1_Enemy" ) )
		}
	}
}

void function ForceHide1v1Scoreboard() 
{
	entity player = GetLocalClientPlayer()

	// if( file.show1v1Scoreboard )
	// {
		// file.show1v1Scoreboard = false
		Signal( player, "StopCurrentEnemyThread" )
		FS_1v1_ToggleUIVisibility( false, null )
	// }
	// else
	// {
		// file.show1v1Scoreboard = true
		
		// if( GetGlobalNetInt( "FSDM_GameState" ) == eTDMState.IN_PROGRESS && player.GetPlayerNetEnt( "FSDM_1v1_Enemy" ) != null )
		// {
			// FS_1v1_ToggleUIVisibility( true, player.GetPlayerNetEnt( "FSDM_1v1_Enemy" ) )
		// }
	// }
}

void function ForceShow1v1Scoreboard() 
{
	entity player = GetLocalClientPlayer()

	// if( file.show1v1Scoreboard )
	// {
		// file.show1v1Scoreboard = false
		// Signal( player, "StopCurrentEnemyThread" )
		// FS_1v1_ToggleUIVisibility( false, null )
	// }
	// else
	// {
		if( GetGlobalNetInt( "FSDM_GameState" ) == eTDMState.IN_PROGRESS && player.GetPlayerNetEnt( "FSDM_1v1_Enemy" ) != null  && file.show1v1Scoreboard )
		{
			FS_1v1_ToggleUIVisibility( true, player.GetPlayerNetEnt( "FSDM_1v1_Enemy" ) )
		}
	// }
}

void function Cl_OnResolutionChanged()
{
	if( FS_GetScoreEventTopo() != null )
	{
		UISize screenSize = GetScreenSize()
		TopologyCreateData tcd = BuildTopologyCreateData( true, false )
		RuiTopology_UpdatePos( FS_GetScoreEventTopo(), tcd.org + <0,screenSize.height * -0.618,0>, tcd.right, tcd.down)
	}

	UISize screenSize = GetScreenSize()
	Hud_SetSize( HudElement( "FS_DMCountDown_Frame" ), 248 * screenSize.width / 1920.0, 88 * screenSize.height / 1080.0 )
	if( IsValid( GetLocalViewPlayer() ) )
	FS_1v1_PlayerStateChanged( GetLocalViewPlayer(), 0, GetLocalViewPlayer().GetPlayerNetInt( "FS_1v1_PlayerState" ) , false )
	
	if( GetGlobalNetInt( "FSDM_GameState" ) != eTDMState.IN_PROGRESS )
	{
		Flowstate_ShowRoundEndTimeUI( -1 )
		return
	}
	
	Flowstate_ShowRoundEndTimeUI( GetGlobalNetTime( "flowstate_DMRoundEndTime" ) )
	
	entity player = GetLocalClientPlayer()

	if( GetGlobalNetInt( "FSDM_GameState" ) == eTDMState.IN_PROGRESS && player.GetPlayerNetEnt( "FSDM_1v1_Enemy" ) != null )
	{
		FS_1v1_ToggleUIVisibility( true, player.GetPlayerNetEnt( "FSDM_1v1_Enemy" ) )
	}
	
	if( Playlist() == ePlaylists.fs_1v1_coaching )
	{
		ReloadRecordingsList()
	}
}

void function Flowstate_RoundEndTimeChanged( entity player, float old, float new, bool actuallyChanged )
{
	// if ( !actuallyChanged  )
		// return

	thread Flowstate_ShowRoundEndTimeUI( new )
	
}

void function SetRecentWeapon( entity player )
{
	Grenade_SetLastActive( player.GetActiveWeapon( eActiveInventorySlot.mainHand ) )
}

void function Flowstate_StartTimeChanged( entity player, float old, float new, bool actuallyChanged )
{
	if ( !actuallyChanged  )
		return
	
	thread Flowstate_PlayStartRoundSounds( )
	thread Flowstate_ShowStartTimeUI( new )
}

void function FS_Scenarios_SetRingCloseTimeForMinimap( int seconds )
{
	float endtime = Time() + seconds
	SetNextCircleDisplayCustomClosing( endtime, "FLOWSTATE ZONE WARS" )
}

void function Flowstate_ShowRoundEndTimeUI( float new )
{
	#if DEVELOPER
		printt( "show round end time ui ", new, " - current time: " + Time() )
	#endif
	if( new == -1 || Playlist() == ePlaylists.fs_movementgym )
	{
		//force to hide
		Signal( GetLocalClientPlayer(), "FSDM_EndTimer")
		Hud_SetVisible( HudElement( "FS_DMCountDown_Text" ), false )
		Hud_SetVisible( HudElement( "FS_DMCountDown_Frame" ), false )
		return
	}
	
	if( Playlist() == ePlaylists.fs_1v1 || Playlist() == ePlaylists.fs_vamp_1v1 || Playlist() == ePlaylists.fs_1v1_headshots_only || Playlist() == ePlaylists.fs_lgduels_1v1 )
	{
		// UISize screenSize = GetScreenSize()
		// Hud_SetPos( text, baseposText.x -70	 * screenSize.width / 1920.0, baseposText.y + 12 * screenSize.height / 1080.0 )
		UISize screenSize = GetScreenSize()
		Hud_SetSize( HudElement( "FS_DMCountDown_Frame" ), 248 * screenSize.width / 1920.0, 88 * screenSize.height / 1080.0 )
		RuiSetImage( Hud_GetRui( HudElement( "FS_DMCountDown_Frame" ) ), "basicImage", $"rui/flowstate_custom/1v1_timeremaining" )
	}
	else
		RuiSetImage( Hud_GetRui( HudElement( "FS_DMCountDown_Frame" ) ), "basicImage", $"rui/flowstate_custom/dm_countdown" )
	
	thread Flowstate_DMTimer_Thread( new )
}
	
void function Flowstate_DMTimer_Thread( float endtime )
{
	entity player = GetLocalClientPlayer()
	Signal( player, "FSDM_EndTimer")
	EndSignal( player, "FSDM_EndTimer")

	var text = HudElement( "FS_DMCountDown_Text" )
	var frame = HudElement( "FS_DMCountDown_Frame" )
	
	OnThreadEnd(
		function() : ( player, text, frame )
		{
			Hud_SetVisible( text, false )
			Hud_SetVisible( frame, false )
			RunUIScript("FS_1v1_SettingsMenu_Close")
			if( IsValid( player ) )
				Signal( player, "Destroy1v1SettingsHint" )
		}
	)

	Hud_SetVisible( text, true )
	Hud_SetVisible( frame, true )

	float startTime = Gamemode() == eGamemodes.WINTEREXPRESS ? Time() : GetGlobalNetTime( "flowstate_DMStartTime" )
	
	string main = "Time Remaining: "
	
	if( Playlist() == ePlaylists.fs_1v1 || Playlist() == ePlaylists.fs_vamp_1v1 || Playlist() == ePlaylists.fs_1v1_headshots_only || Playlist() == ePlaylists.fs_lgduels_1v1 )
		main = ""

	UIPos basepos = REPLACEHud_GetBasePos( frame )	
	UISize screenSize = GetScreenSize()
	
	switch( Playlist() )
	{
		case ePlaylists.fs_scenarios:
		
		if( GetServerVar( "tracker_enabled" ) )
			main = "Stats shipping in: "
		
		Hud_SetPos( frame, basepos.x - 5 * screenSize.width / 1920.0, basepos.y - 50 * screenSize.height / 1080.0 ) //text is parented to the frame so not need to change text pos
		break
		
		case ePlaylists.fs_1v1:
		case ePlaylists.fs_vamp_1v1:
		case ePlaylists.fs_1v1_headshots_only:
		case ePlaylists.fs_lgduels_1v1:
		
		UIPos baseposText = REPLACEHud_GetBasePos( text )
		Hud_SetPos( text, baseposText.x -70	 * screenSize.width / 1920.0, baseposText.y + 12 * screenSize.height / 1080.0 ) //text is parented to the frame so not need to change text pos
		Hud_SetPos( frame, basepos.x -15 * screenSize.width / 1920.0, basepos.y + 0 * screenSize.height / 1080.0 ) //text is parented to the frame so not need to change text pos
		break
	}

	switch( Gamemode() )
	{
		case eGamemodes.WINTEREXPRESS:
		main = "Round Ending In: "
		break
	}

	while ( startTime <= endtime )
	{
        int elapsedtime = int(endtime) - Time().tointeger()
		
		DisplayTime dt = SecondsToDHMS( elapsedtime )
		Hud_SetText( text, main + format( "%.2d:%.2d", dt.minutes, dt.seconds ))
		startTime++

		Hud_SetVisible( text, !file.hideendtimeui )
		Hud_SetVisible( frame, !file.hideendtimeui )
			
		wait 1
	}
}

void function Flowstate_ShowStartTimeUI( float new )
{
	if( new == -1 )
	{
		Hud_SetVisible( HudElement( "FS_DMCountDown_Text_Center" ), false )
		Hud_SetVisible( HudElement( "FS_DMCountDown_Frame_Center" ), false )
		return
	}

	Hud_SetVisible( HudElement( "FS_DMCountDown_Text_Center" ), true )
	Hud_SetVisible( HudElement( "FS_DMCountDown_Frame_Center" ), true )
	RuiSetImage( Hud_GetRui( HudElement( "FS_DMCountDown_Frame_Center" ) ), "basicImage", $"rui/flowstate_custom/dm_starttimer_bg" )
	
	thread Flowstate_StartTime_Thread( new )
}
	
void function Flowstate_StartTime_Thread( float endtime )
{
	entity player = GetLocalClientPlayer()

	OnThreadEnd(
		function() : ()
		{
			Hud_SetVisible( HudElement( "FS_DMCountDown_Text_Center" ), false )
			Hud_SetVisible( HudElement( "FS_DMCountDown_Frame_Center" ), false )
		}
	)
	
	string msg = "Deathmatch Starting in "
	
	if( GetCurrentPlaylistVarBool( "enable_oddball_gamemode", false ) )
		msg = "Oddball Starting in "
	else if( Gamemode() == eGamemodes.CUSTOM_CTF )
		msg = "CTF Starting in "
	else if( Playlist() == ePlaylists.fs_scenarios )
		msg = "Zone War Starting in "
	else if( Playlist() == ePlaylists.fs_realistic_ttv )
		msg = "Realistic TTV Survival in : "

	while ( Time() <= endtime )
	{
        int elapsedtime = int( endtime ) - Time().tointeger()

		DisplayTime dt = SecondsToDHMS( elapsedtime )
		
		if( dt.seconds == 0 )
			break

		Hud_SetText( HudElement( "FS_DMCountDown_Text_Center"), msg + dt.seconds )
		
		wait 1
	}
}



void function Flowstate_ShowMatchFoundUI( int timeUntilRespawn )
{
	if( timeUntilRespawn == -1 )
	{
		Hud_SetVisible( HudElement( "FS_Respawn_Countdown_Center" ), false )
		// Hud_SetVisible( HudElement( "FS_Respawn_Countdown_Frame_Center" ), false )
		return
	}

	Hud_SetVisible( HudElement( "FS_Respawn_Countdown_Center" ), true )
	// Hud_SetVisible( HudElement( "FS_Respawn_Countdown_Frame_Center" ), false )
	// RuiSetImage( Hud_GetRui( HudElement( "FS_Respawn_Countdown_Frame_Center" ) ), "basicImage", $"rui/flowstate_custom/dm_starttimer_bg" )
	
	thread Flowstate_RespawnTimer_Thread( timeUntilRespawn, 2 )
}

void function Flowstate_ShowRespawnTimeUI( int timeUntilRespawn )
{
	if( timeUntilRespawn == -1 )
	{
		Hud_SetVisible( HudElement( "FS_Respawn_Countdown_Center" ), false )
		// Hud_SetVisible( HudElement( "FS_Respawn_Countdown_Frame_Center" ), false )
		return
	}

	Hud_SetVisible( HudElement( "FS_Respawn_Countdown_Center" ), true )
	// Hud_SetVisible( HudElement( "FS_Respawn_Countdown_Frame_Center" ), false )
	// RuiSetImage( Hud_GetRui( HudElement( "FS_Respawn_Countdown_Frame_Center" ) ), "basicImage", $"rui/flowstate_custom/dm_starttimer_bg" )
	
	thread Flowstate_RespawnTimer_Thread( timeUntilRespawn, 1 )
}
	
void function Flowstate_RespawnTimer_Thread( int timeUntilRespawn, int type )
{
	clGlobal.levelEnt.EndSignal( "LocalClientPlayerRespawned" )
	// entity player = GetLocalViewPlayer()
	
	// if( !IsValid( player ) )
		// return
		
	// player.EndSignal( "OnDestroy" )

	OnThreadEnd
	(
		void function() : ()
		{
			Hud_SetVisible( HudElement( "FS_Respawn_Countdown_Center" ), false )
			// Hud_SetVisible( HudElement( "FS_Respawn_Countdown_Frame_Center" ), false )
		}
	)
	
	string msg = "Respawning in "

	if( Playlist() == ePlaylists.fs_scenarios )
		msg = "Lobby in "
	
	if( type == 2 )
	{
		msg = "Match Found "
	} else if( type == 3 )
	{
		msg = "Round Starts In "
	} else if( type == 4 )
	{
		msg = "Selecting Team In "
	}
	
	while ( timeUntilRespawn > 0 )
	{
		Hud_SetText( HudElement( "FS_Respawn_Countdown_Center"), msg + string( timeUntilRespawn ) )
		
		timeUntilRespawn--
		wait 1
	}
}

void function Flowstate_PlayStartRoundSounds()
{
	//sounds
	entity player = GetLocalViewPlayer()

	float doorsOpenTime = GetGlobalNetTime( "flowstate_DMStartTime" )
	float threeSecondWarningTime = doorsOpenTime - 3.0

	while( GetGlobalNetTime( "flowstate_DMStartTime" ) < 0 )
		WaitFrame()

	if ( Time() > GetGlobalNetTime( "flowstate_DMStartTime" ) )
		return

	if( Flowstate_IsHaloMode() )
	{
		Obituary_Print_Localized( "%$rui/flowstate_custom/colombia_flag_papa% Made in Colombia with love by @CafeFPS and Darkes65.", GetChatTitleColorForPlayer( GetLocalViewPlayer() ), BURN_COLOR )
		// Obituary_Print_Localized( "%$rui/flowstatecustom/hiswattson_ltms% Devised by HisWattson.", GetChatTitleColorForPlayer( GetLocalViewPlayer() ), BURN_COLOR )
		Obituary_Print_Localized( "Welcome to Flowstate Halo DM Mod v1.0 - Powered by R5Reloaded", GetChatTitleColorForPlayer( GetLocalViewPlayer() ), BURN_COLOR )
	}
	
	if( Gamemode() == eGamemodes.CUSTOM_CTF && !Flowstate_IsHaloMode() )
	{
		Obituary_Print_Localized( "%$rui/bullet_point% Made by zee_x64. Reworked by @CafeFPS.", GetChatTitleColorForPlayer( GetLocalViewPlayer() ), BURN_COLOR )
	}

	while( Time() < ( GetGlobalNetTime( "flowstate_DMStartTime" ) - 3.0 ) )
	{
		EmitSoundOnEntity( player, "UI_Survival_Intro_LaunchCountDown_10Seconds" )
		wait 1.0
	}

	while( Time() < GetGlobalNetTime( "flowstate_DMStartTime" ) - 0.5 )
	{
		EmitSoundOnEntity( player, "UI_Survival_Intro_LaunchCountDown_3Seconds" )
		wait 1.0
	}

	while( Time() < GetGlobalNetTime( "flowstate_DMStartTime" ) )
		WaitFrame()

	EmitSoundOnEntity( player, "UI_Survival_Intro_LaunchCountDown_Finish" )
}

void function Cl_RegisterLocation(LocationSettings locationSettings)
{
    file.locationSettings.append(locationSettings)
}

void function ClientReportChat(var button)
{
	if( CHAT_TEXT == "" || isMuted() )
		return
	
	string text = "say " + CHAT_TEXT
	text = IsSafeString( text, 255 ) ? text : "?" //(mk):prevent being kicked
	GetLocalClientPlayer().ClientCommand( text )
}

void function ServerCallback_FSDM_CoolCamera()
{
    thread CoolCamera()
}

LocPair function NewCameraPair(vector origin, vector angles)
{
    LocPair locPair
    locPair.origin = origin
    locPair.angles = angles

    return locPair
}

void function CoolCamera()
//based on sal's tdm
{
    entity player = GetLocalClientPlayer()
	player.EndSignal("ChangeCameraToSelectedLocation")
	array<LocPair> cutsceneSpawns
	
    if(!IsValid(player)) return
	
	switch( MapName() )
	{
		case eMaps.mp_rr_desertlands_64k_x_64k:
		case eMaps.mp_rr_desertlands_64k_x_64k_nx:
		case eMaps.mp_rr_desertlands_64k_x_64k_tt:		
		cutsceneSpawns.append(NewCameraPair(<10915.0039, 6811.3418, -3539.73657>,<0, -100.5355, 0>))
		cutsceneSpawns.append(NewCameraPair(<9586.79199, 24404.5898, -2019.6366>, <0, -52.6216431, 0>)) 
		cutsceneSpawns.append(NewCameraPair(<-29335.9199, 11470.1729, -2374.77954>,<0, -2.17369795, 0>))
		cutsceneSpawns.append(NewCameraPair(<16346.3076, -34468.9492, -1109.32153>, <0, -44.3879509, 0>))
		cutsceneSpawns.append(NewCameraPair(<1133.25562, -20102.9648, -2488.08252>, <0, -24.9140873, 0>))		
		cutsceneSpawns.append(NewCameraPair(<4225.83447, 3396.84448, -3090.29712>,<0, 38.1615944, 0>))
		cutsceneSpawns.append(NewCameraPair(<-9873.3916, 5598.64307, -2453.47461>,<0, -107.887512, 0>))
		cutsceneSpawns.append(NewCameraPair(<-28200.6348, 2603.86792, -3899.62598>,<0, -94.3539505, 0>))
		cutsceneSpawns.append(NewCameraPair(<-13217.0469, 24311.4375, -3157.30908>,<0, 97.8569489, 0>))
		break
		
		case eMaps.mp_rr_canyonlands_staging:
		cutsceneSpawns.append(NewCameraPair(<32645.04,-9575.77,-25911.94>, <7.71,91.67,0.00>)) 
		cutsceneSpawns.append(NewCameraPair(<49180.1055, -6836.14502, -23461.8379>, <0, -55.7723808, 0>)) 
		cutsceneSpawns.append(NewCameraPair(<43552.3203, -1023.86182, -25270.9766>, <0, 20.9528542, 0>))
		cutsceneSpawns.append(NewCameraPair(<30038.0254, -1036.81982, -23369.6035>, <55, -24.2035522, 0>))
		break
		
		case eMaps.mp_rr_canyonlands_mu1:
		case eMaps.mp_rr_canyonlands_mu1_night:
		case eMaps.mp_rr_canyonlands_64k_x_64k:
		cutsceneSpawns.append(NewCameraPair(<-7984.68408, -16770.2031, 3972.28271>, <0, -158.605301, 0>)) 
		cutsceneSpawns.append(NewCameraPair(<-19691.1621, 5229.45264, 4238.53125>, <0, -54.6054993, 0>))
		cutsceneSpawns.append(NewCameraPair(<13270.0576, -20413.9023, 2999.29468>, <0, 98.6180649, 0>))
		cutsceneSpawns.append(NewCameraPair(<-25250.0391, -723.554199, 3427.51831>, <0, -55.5126762, 0>))
		cutsceneSpawns.append(NewCameraPair(<10445.5107, -30267.8691, 3435.0647>,<0, -151.025223, 0>))
		cutsceneSpawns.append(NewCameraPair(<-21710.4395, -12452.8604, 2887.22778>,<0, 29.4609108, 0>))
		cutsceneSpawns.append(NewCameraPair(<-17403.5469, 15699.3867, 4041.38379>,<0, -1.59664249, 0>))
		cutsceneSpawns.append(NewCameraPair(<-3939.00781, 16862.0586, 3525.45728>,<0, 142.246902, 0>))
		cutsceneSpawns.append(NewCameraPair(<26928.9668, 7577.22363, 2926.2876>,<0, 55.0248222, 0>))
		cutsceneSpawns.append(NewCameraPair(<32170.3008, -1944.38562, 3590.89258>,<0, 27.8040161, 0>))
		break
		
		case eMaps.mp_rr_arena_phase_runner:
		cutsceneSpawns.append(NewCameraPair(<26864.2109, 15601.6094, -552.943604> , <0, -150.047638, 0>))
		cutsceneSpawns.append(NewCameraPair(<28349.5098, 16262.6318, -60.8187943> , <0, -23.0048409, 0>))
		cutsceneSpawns.append(NewCameraPair(<31179.7949, 14227.6787, 1918.80981> , <0, 145.544983, 0>))
		cutsceneSpawns.append(NewCameraPair(<30483.4727, 18615.0508, -563.385559> , <0, 69.6765442, 0>))
		cutsceneSpawns.append(NewCameraPair(<24773.834, 21167.2012, 52.9560318> , <0, 63.6609154, 0>))
		cutsceneSpawns.append(NewCameraPair(<22836.1133, 16965.5742, -516.453979> , <0, -10.6384602, 0>))
		break
		
		case eMaps.mp_rr_party_crasher:
		cutsceneSpawns.append(NewCameraPair(<-1363.75867, -2183.58081, 1354.65466>, <0, 72.5054092, 0>)) 
		cutsceneSpawns.append(NewCameraPair(<2378.75439, 1177.52783, 1309.69019>, <0, 146.118546, 0>))
		cutsceneSpawns.append(NewCameraPair(<-1472.35242, -1927.02917, 2238.11084>, <0, 169.861725, 0>))
		cutsceneSpawns.append(NewCameraPair(<681.364319, -240.568985, 945.704834>, <0, 53.7547188, 0>))
		break
		
		case eMaps.mp_rr_arena_composite:
		cutsceneSpawns.append(NewCameraPair(<2343.25171, 4311.43896, 829.289917>, <0, -139.293152, 0>)) 
		cutsceneSpawns.append(NewCameraPair(<-1661.23608, 2852.71924, 657.674316>, <0, -56.0820427, 0>)) 
		cutsceneSpawns.append(NewCameraPair(<-640.810059, 1039.97424, 514.500793>, <0, -23.5162239, 0>)) 
		break
		
		case eMaps.mp_rr_aqueduct:
		//case eMaps.mp_rr_aqueduct_night:
		cutsceneSpawns.append(NewCameraPair(<1593.85205, -3274.99365, 1044.39099>, <0, -126.270805, 0>)) 
		cutsceneSpawns.append(NewCameraPair(<1489.99255, -6570.93262, 741.996887>, <0, 133.833832, 0>))
		break 
		
		/*case eMaps.mp_rr_arena_skygarden:
		cutsceneSpawns.append(NewCameraPair(<-9000, 3274.99365, 4044.39099>, <0, -126.270805, 0>)) 
		cutsceneSpawns.append(NewCameraPair(<1489.99255, -6570.93262, 4041.996887>, <0, 133.833832, 0>)) 
		break*/
	}

	if( cutsceneSpawns.len() == 0 )
		return

    //EmitSoundOnEntity( player, "music_skyway_04_smartpistolrun" )

    float playerFOV = player.GetFOV()
	
	cutsceneSpawns.randomize()
	vector randomcameraPos = cutsceneSpawns[0].origin
	vector randomcameraAng = cutsceneSpawns[0].angles
	
    entity camera = CreateClientSidePointCamera(randomcameraPos, randomcameraAng, 17)
    camera.SetFOV(100)
    entity cutsceneMover = CreateClientsideScriptMover($"mdl/dev/empty_model.rmdl", randomcameraPos, randomcameraAng)
    camera.SetParent(cutsceneMover)
	GetLocalClientPlayer().SetMenuCameraEntity( camera )
	DoF_SetFarDepth( 6000, 10000 )	
	
	OnThreadEnd(
		function() : ( player, cutsceneMover, camera, cutsceneSpawns )
		{
			thread function() : (player, cutsceneMover, camera, cutsceneSpawns)
			{
				if( Gamemode() == eGamemodes.fs_snd )
				{
					GetLocalClientPlayer().ClearMenuCameraEntity()
					cutsceneMover.Destroy()

					// if(IsValid(player))
					// {
						// FadeOutSoundOnEntity( player, "music_skyway_04_smartpistolrun", 1 )
					// }
					if(IsValid(camera))
					{
						camera.Destroy()
					}
					DoF_SetNearDepthToDefault()
					DoF_SetFarDepthToDefault()
					return
				}
					
				EndSignal(player, "ChallengeStartRemoveCameras")
				
				OnThreadEnd(
				function() : ( player, cutsceneMover, camera )
				{
					GetLocalClientPlayer().ClearMenuCameraEntity()
					cutsceneMover.Destroy()

					// if(IsValid(player))
					// {
						// FadeOutSoundOnEntity( player, "music_skyway_04_smartpistolrun", 1 )
					// }
					if(IsValid(camera))
					{
						camera.Destroy()
					}
					DoF_SetNearDepthToDefault()
					DoF_SetFarDepthToDefault()			
				})
				
				waitthread CoolCameraMovement(player, cutsceneMover, camera, file.selectedLocation.spawns, true)
			}()
		}
	)
	
	waitthread CoolCameraMovement(player, cutsceneMover, camera, cutsceneSpawns)
}

void function CoolCameraMovement(entity player, entity cutsceneMover, entity camera, array<LocPair> cutsceneSpawns, bool isSelectedZoneCamera = false)
{
	int locationindex = 0
	
	vector startpos
	vector startangs
	
	vector finalpos
	vector finalangs	
	
	if(isSelectedZoneCamera)
	{
		LocPair far = file.selectedLocation.spawns.getrandom()
		startpos = far.origin
		if(file.selectedLocation.name != "Swamps")
			startpos.z+= 2000
		else
			startpos.z+= 1500
		startangs = far.angles
		
		finalpos = GetCenterOfCircle(file.selectedLocation.spawns)
		//calcular el más lejano
	}
	else
	{
		startpos = cutsceneSpawns[locationindex].origin
		startangs = cutsceneSpawns[locationindex].angles
	}
		
	while(true){
		if(locationindex == cutsceneSpawns.len()){
			locationindex = 0
		}
		
		if(!isSelectedZoneCamera)
		{
			startpos = cutsceneSpawns[locationindex].origin
			startangs = cutsceneSpawns[locationindex].angles		
		}
		locationindex++
		cutsceneMover.SetOrigin(startpos)
		cutsceneMover.SetAngles(startangs)
		camera.SetOrigin(startpos)
		camera.SetAngles(startangs)
		
		if(isSelectedZoneCamera)
		{
			camera.SetFOV(90)
			cutsceneMover.NonPhysicsMoveTo(finalpos, 30, 0, 0)
			cutsceneMover.NonPhysicsRotateTo( VectorToAngles( finalpos - startpos ), 5, 0.0, 6 / 2.0 )
			WaitForever()
		}
		else
		{
			cutsceneMover.NonPhysicsMoveTo(startpos + AnglesToRight(startangs) * 700, 15, 0, 0)
			cutsceneMover.NonPhysicsRotateTo( startangs, 10, 0.0, 6 / 2.0 )	
			wait 5
		}
	}	
}

LocPair function GetUbicacionMasLejana(LocPair random)
{
	array<float> allspawnsDistances
	
	for(int i = 0; i<file.selectedLocation.spawns.len(); i++)
	{
		allspawnsDistances.append(Distance(random.origin, file.selectedLocation.spawns[i].origin))
	}
	
	float compareDis = -1
	int bestpos = 0
	for(int j = 1; j<allspawnsDistances.len(); j++)
	{
		if(allspawnsDistances[j] > compareDis)
		{
			compareDis = allspawnsDistances[j]
			bestpos = j
		}	
	}

    return file.selectedLocation.spawns[bestpos]
}

void function FS_DM_OnEntitiesDidLoad()
{
	if( Playlist() == ePlaylists.fs_1v1 )
	{
		Send1v1SettingsToServer()
	}
	
    if( GetGlobalNetTime( "flowstate_DMRoundEndTime" ) < Time() || GetGameState() != eGameState.Playing || GetGlobalNetTime( "flowstate_DMRoundEndTime" ) == -1 ) // Updates round end time for players connected mid game
        return

    Flowstate_ShowRoundEndTimeUI( GetGlobalNetTime( "flowstate_DMRoundEndTime" ) )
}

void function OpenTDMWeaponSelectorUI()
{
	entity player = GetLocalClientPlayer()
    
	if( Playlist() == ePlaylists.fs_aimtrainer )
		player.ClientCommand("CC_TDM_Weapon_Selector_Open")
	
	DoF_SetFarDepth( 1, 300 )
	RunUIScript("OpenFRChallengesSettingsWpnSelector")
}

void function ServerCallback_SendScoreboardToClient(int eHandle, int score, int deaths, float kd, int damage, int latency)
{
	if ( !EHIHasValidScriptStruct( eHandle ) ) 
		return
		
	RunUIScript( "SendScoreboardToUI", EHI_GetName(eHandle), score, deaths, kd, damage, latency)
}

void function ServerCallback_SendProphuntPropsScoreboardToClient(int eHandle, int score, int survivaltime)
{
	if ( !EHIHasValidScriptStruct( eHandle ) ) 
		return
	
	RunUIScript( "SendPropsScoreboardToUI", EHI_GetName(eHandle), score, survivaltime)
}

void function ServerCallback_SendProphuntHuntersScoreboardToClient(int eHandle, int propskilled)
{
	if ( !EHIHasValidScriptStruct( eHandle ) ) 
		return
	
	RunUIScript( "SendHuntersScoreboardToUI", EHI_GetName(eHandle), propskilled)
}

void function ServerCallback_ClearScoreboardOnClient()
{
	if( Gamemode() == eGamemodes.fs_prophunt )
		RunUIScript( "ClearProphuntScoreboardOnUI")
	else
		RunUIScript( "ClearScoreboardOnUI")
}

void function ServerCallback_OpenStatisticsUI()
{
	entity player = GetLocalClientPlayer()
	RunUIScript( "OpenStatisticsUI" )	
}

void function ServerCallback_FSDM_OpenVotingPhase(bool shouldOpen)
{
	if(shouldOpen)
	{
		//try { GetLocalClientPlayer().ClearMenuCameraEntity(); GetWinnerPropCameraEntities()[0].ClearParent(); GetWinnerPropCameraEntities()[0].Destroy(); GetWinnerPropCameraEntities()[1].Destroy() } catch (exceptio2n){ }
		RunUIScript( "Open_FSDM_VotingPhase" )
	}
	else
		FSDM_CloseVotingPhase()
	
}

void function ServerCallback_SetLGDuelPesistenceSettings( float s1, int s2, int s3, int s4, float s5, int s6, int s7, int s8 )
{
	#if DEVELOPER 
		printt("Calling LoadLgDuelSettings with: ", s1, s2, s3, s4, s5, s6, s7, s8 )
	#endif	
	
	// LGDuels_SetFromPersistence( s1, s2, s3, s4, s5, s6, s7, s8 )	
	//RunUIScript( "LoadLgDuelSettings", s1, s2, s3, s4, s5, s6, s7, s8 )
}

void function ServerCallback_FSDM_ChampionScreenHandle(bool shouldOpen, int TeamWon, int skinindex)
{
    file.teamwon = TeamWon
	
    if( shouldOpen )
        thread CreateChampionUI(skinindex)
    else
        thread DestroyChampionUI()
}

void function CreateChampionUI(int skinindex)
{
    hasvoted = false
    isvoting = true
    roundover = true
	
    EmitSoundOnEntity( GetLocalClientPlayer(), "Music_CharacterSelect_Wattson" )
    // ScreenFade(GetLocalClientPlayer(), 0, 0, 0, 255, 0.4, 0.5, FFADE_OUT | FFADE_PURGE)
    // wait 0.9
	
    entity targetBackground = GetEntByScriptName( "target_char_sel_bg_new" )
    entity targetCamera = GetEntByScriptName( "target_char_sel_camera_new" )
	
	if(file.teamwon != 3 && Gamemode() == eGamemodes.fs_prophunt || Gamemode() == eGamemodes.flowstate_pkknockback )
	{
		//Clear Winning Squad Data
		AddWinningSquadData( -1, -1)
		
		//Set Squad Data For Each Player In Winning Team
		foreach( int i, entity player in GetPlayerArrayOfTeam_Alive( file.teamwon ) )
		{
			AddWinningSquadData( i, player.GetEncodedEHandle())
		}
	}
    thread Show_FSDM_VictorySequence(skinindex)
	
    // ScreenFade(GetLocalClientPlayer(), 0, 0, 0, 255, 0.3, 0.0, FFADE_IN | FFADE_PURGE)
}

void function DestroyChampionUI()
{
    foreach( rui in overHeadRuis )
		RuiDestroyIfAlive( rui )

    foreach( entity ent in cleanupEnts )
		ent.Destroy()

    overHeadRuis.clear()
    cleanupEnts.clear()	
}

void function FSDM_CloseVotingPhase()
{
    isvoting = false
    
    FadeOutSoundOnEntity( GetLocalClientPlayer(), "Music_CharacterSelect_Event3_Solo", 0.2 )

    // wait 1

    GetLocalClientPlayer().ClearMenuCameraEntity()

    RunUIScript( "Close_FSDM_VoteMenu" )
    GetLocalClientPlayer().Signal("ChallengeStartRemoveCameras")
}

void function UpdateUIVoteTimer(int team)
{
	RunUIScript( "UpdateVoteTimerHeader_FSDM" )
    float time = team - Time()
    while(time > -1)
    {
        RunUIScript( "UpdateVoteTimer_FSDM", int(time))

        if (time <= 5 && time != 0)
            EmitSoundOnEntity( GetLocalClientPlayer(), "ui_ingame_markedfordeath_countdowntomarked" )

        if (time == 0)
            EmitSoundOnEntity( GetLocalClientPlayer(), "ui_ingame_markedfordeath_countdowntoyouaremarked" )

        time--

        wait 1
    }
}

void function UI_To_Client_VoteForMap_FSDM(int mapid)
{
    if(hasvoted)
        return

    entity player = GetLocalClientPlayer()
    player.ClientCommand("VoteForMap " + mapid)
    RunUIScript("UpdateVotedFor_FSDM", mapid + 1)

    hasvoted = true
}

void function ServerCallback_FSDM_UpdateMapVotesClient( int map1votes, int map2votes, int map3votes, int map4votes)
{
    RunUIScript("UpdateVotesUI_FSDM", map1votes, map2votes, map3votes, map4votes)
}

void function ServerCallback_FSDM_UpdateVotingMaps( int map1, int map2, int map3, int map4)
{
    RunUIScript("UpdateMapsForVoting_FSDM", file.locationSettings[map1].name, file.locationSettings[map1].locationAsset, file.locationSettings[map2].name, file.locationSettings[map2].locationAsset, file.locationSettings[map3].name, file.locationSettings[map3].locationAsset, file.locationSettings[map4].name, file.locationSettings[map4].locationAsset)
}

void function ServerCallback_FSDM_SetScreen(int screen, int team, int mapid, int done)
{
    switch(screen)
    {
        case eFSDMScreen.ScoreboardUI: //Sets the screen to the winners screen
			DestroyChampionUI()
			
			if( Gamemode() == eGamemodes.fs_prophunt )
				RunUIScript("Set_FSDM_ProphuntScoreboardScreen")
			else
				RunUIScript("Set_FSDM_ScoreboardScreen")
			
            break

        case eFSDMScreen.WinnerScreen: //Sets the screen to the winners screen
            RunUIScript("Set_FSDM_TeamWonScreen", GetWinningTeamText(team))
            break

        case eFSDMScreen.VoteScreen: //Sets the screen to the vote screen
			DestroyChampionUI()
			
			hasvoted = false
			isvoting = true
			roundover = true
			
            EmitSoundOnEntity( GetLocalClientPlayer(), "UI_PostGame_CoinMove" )
            thread UpdateUIVoteTimer(team)
            RunUIScript("Set_FSDM_VotingScreen")
            break

        case eFSDMScreen.TiedScreen: //Sets the screen to the tied screen
            switch(done)
            {
				case 0:
					EmitSoundOnEntity( GetLocalClientPlayer(), "HUD_match_start_timer_tick_1P" )
					break
				case 1:
					EmitSoundOnEntity( GetLocalClientPlayer(),  "UI_PostGame_CoinMove" )
					break
            }

            if (mapid == 42068)
                RunUIScript( "UpdateVotedLocation_FSDMTied", "")
            else
                RunUIScript( "UpdateVotedLocation_FSDMTied", file.locationSettings[mapid].name)
            break

        case eFSDMScreen.SelectedScreen: //Sets the screen to the selected location screen
            EmitSoundOnEntity( GetLocalClientPlayer(), "UI_PostGame_Level_Up_Pilot" )
            RunUIScript( "UpdateVotedLocation_FSDM", file.locationSettings[mapid].name)
			file.selectedLocation = file.locationSettings[mapid]
			Signal(GetLocalClientPlayer(), "ChangeCameraToSelectedLocation")
            break

        case eFSDMScreen.NextRoundScreen: //Sets the screen to the next round screen
            EmitSoundOnEntity( GetLocalClientPlayer(), "UI_PostGame_Level_Up_Pilot" )
            FadeOutSoundOnEntity( GetLocalClientPlayer(), "Music_CharacterSelect_Wattson", 0.2 )
            RunUIScript("Set_FSDM_VoteMenuNextRound")
            break
    }
}

string function GetWinningTeamText(int team)
{
    string teamwon = ""
    // switch(team)
    // {
        // case TEAM_IMC:
            // teamwon = "IMC has won"
            // break
        // case TEAM_MILITIA:
            // teamwon = "MILITIA has won"
            // break
        // case 69:
            // teamwon = "Winner couldn't be decided"
            // break
    // }
	// if(IsFFAGame())
		// teamwon = GetPlayerArrayOfTeam( team )[0].GetPlayerName() + " has won."
	// else
		// teamwon = "Team " + team + " has won."
	
    return teamwon
}

array<ItemFlavor> function GetAllGoodAnimsFromGladcardStancesForCharacter_ChampionScreen(ItemFlavor character)
{
	array<ItemFlavor> actualGoodAnimsForThisCharacter
	switch(ItemFlavor_GetHumanReadableRef( character )){
			case "character_pathfinder":
		actualGoodAnimsForThisCharacter.append( GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( "SAID00543164026" ) ) )
		return actualGoodAnimsForThisCharacter
		
			case "character_bangalore":
		actualGoodAnimsForThisCharacter.append( GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( "SAID02041779191" ) ) )
		return actualGoodAnimsForThisCharacter
		
			case "character_bloodhound":
		actualGoodAnimsForThisCharacter.append( GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( "SAID00982377873" ) ) )
		actualGoodAnimsForThisCharacter.append( GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( "SAID00924111436" ) ) )
		return actualGoodAnimsForThisCharacter
		
			case "character_caustic":
		actualGoodAnimsForThisCharacter.append( GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( "SAID01037940994" ) ) )
		actualGoodAnimsForThisCharacter.append( GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( "SAID01924098215" ) ) )
		actualGoodAnimsForThisCharacter.append( GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( "SAID00844387739" ) ) )
		return actualGoodAnimsForThisCharacter
		
			case "character_gibraltar":
		actualGoodAnimsForThisCharacter.append( GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( "SAID00335495845" ) ) )
		actualGoodAnimsForThisCharacter.append( GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( "SAID01763092699" ) ) )
		actualGoodAnimsForThisCharacter.append( GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( "SAID01066049905" ) ) )
		actualGoodAnimsForThisCharacter.append( GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( "SAID01139949206" ) ) )
		actualGoodAnimsForThisCharacter.append( GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( "SAID00558533496" ) ) )
		return actualGoodAnimsForThisCharacter
		
			case "character_lifeline":
		actualGoodAnimsForThisCharacter.append( GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( "SAID00294421454" ) ) )
		actualGoodAnimsForThisCharacter.append( GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( "SAID01386679009" ) ) )
		return actualGoodAnimsForThisCharacter

			case "character_mirage":
		actualGoodAnimsForThisCharacter.append( GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( "SAID01262193178" ) ) )
		actualGoodAnimsForThisCharacter.append( GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( "SAID00986179205" ) ) )
		actualGoodAnimsForThisCharacter.append( GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( "SAID00002234092" ) ) )
		return actualGoodAnimsForThisCharacter
		
			case "character_octane":
		actualGoodAnimsForThisCharacter.append( GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( "SAID01698467954" ) ) )
		return actualGoodAnimsForThisCharacter
		
			case "character_wraith":
		actualGoodAnimsForThisCharacter.append( GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( "SAID01474484292" ) ) )
		actualGoodAnimsForThisCharacter.append( GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( "SAID01587991597" ) ) )
		actualGoodAnimsForThisCharacter.append( GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( "SAID02046254916" ) ) )
		actualGoodAnimsForThisCharacter.append( GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( "SAID01527711638" ) ) )
		return actualGoodAnimsForThisCharacter

			case "character_wattson":
		actualGoodAnimsForThisCharacter.append( GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( "SAID01638491567" ) ) )
		return actualGoodAnimsForThisCharacter
		
			case "character_crypto":
		actualGoodAnimsForThisCharacter.append( GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( "SAID00269538572" ) ) )
		actualGoodAnimsForThisCharacter.append( GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( "SAID00814728196" ) ) )
		actualGoodAnimsForThisCharacter.append( GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( "SAID01574566414" ) ) )
		return actualGoodAnimsForThisCharacter

			case "character_revenant":
		if( MapName() != eMaps.mp_rr_canyonlands_mu2 && MapName() != eMaps.mp_rr_canyonlands_mu1 && MapName() != eMaps.mp_rr_canyonlands_mu1_night && MapName() != eMaps.mp_rr_canyonlands_64k_x_64k ) 
			actualGoodAnimsForThisCharacter.append( GetItemFlavorByAsset( $"settings/itemflav/gcard_stance/revenant/epic_01.rpak" ) )
			actualGoodAnimsForThisCharacter.append( GetItemFlavorByAsset( $"settings/itemflav/gcard_stance/revenant/epic_02.rpak" ) )
			actualGoodAnimsForThisCharacter.append( GetItemFlavorByAsset( $"settings/itemflav/gcard_stance/revenant/epic_03.rpak" ) )
			actualGoodAnimsForThisCharacter.append( GetItemFlavorByAsset( $"settings/itemflav/gcard_stance/revenant/epic_04.rpak" ) )
		return actualGoodAnimsForThisCharacter
		
			case "character_loba":
		if( MapName() != eMaps.mp_rr_canyonlands_mu2 && MapName() != eMaps.mp_rr_canyonlands_mu1 && MapName() != eMaps.mp_rr_canyonlands_mu1_night && MapName() != eMaps.mp_rr_canyonlands_64k_x_64k ) 
			actualGoodAnimsForThisCharacter.append( GetItemFlavorByAsset( $"settings/itemflav/gcard_stance/loba/s05e01_epic_01.rpak" ) )
			actualGoodAnimsForThisCharacter.append( GetItemFlavorByAsset( $"settings/itemflav/gcard_stance/loba/epic_01.rpak" ) )
			actualGoodAnimsForThisCharacter.append( GetItemFlavorByAsset( $"settings/itemflav/gcard_stance/loba/epic_02.rpak" ) )
			actualGoodAnimsForThisCharacter.append( GetItemFlavorByAsset( $"settings/itemflav/gcard_stance/loba/epic_03.rpak" ) )
			actualGoodAnimsForThisCharacter.append( GetItemFlavorByAsset( $"settings/itemflav/gcard_stance/loba/epic_04.rpak" ) )
			actualGoodAnimsForThisCharacter.append( GetItemFlavorByAsset( $"settings/itemflav/gcard_stance/loba/epic_05.rpak" ) )
		return actualGoodAnimsForThisCharacter
		
			case "character_rampart":
		if( MapName() != eMaps.mp_rr_canyonlands_mu2 && MapName() != eMaps.mp_rr_canyonlands_mu1 && MapName() != eMaps.mp_rr_canyonlands_mu1_night && MapName() != eMaps.mp_rr_canyonlands_64k_x_64k ) 
			actualGoodAnimsForThisCharacter.append( GetItemFlavorByAsset( $"settings/itemflav/gcard_stance/rampart/epic_01.rpak" ) )
			actualGoodAnimsForThisCharacter.append( GetItemFlavorByAsset( $"settings/itemflav/gcard_stance/rampart/epic_02.rpak" ) )
			actualGoodAnimsForThisCharacter.append( GetItemFlavorByAsset( $"settings/itemflav/gcard_stance/rampart/epic_03.rpak" ) )
			actualGoodAnimsForThisCharacter.append( GetItemFlavorByAsset( $"settings/itemflav/gcard_stance/rampart/epic_05.rpak" ) )
		return actualGoodAnimsForThisCharacter
	}
	return actualGoodAnimsForThisCharacter
}

//Orginal code from cl_gamemode_survival.nut
//Modifed slightly
void function Show_FSDM_VictorySequence(int skinindex)
{
	DoF_SetFarDepth( 500, 1000 )
	entity player = GetLocalClientPlayer()

	try { GetWinnerPropCameraEntities()[0].ClearParent(); GetWinnerPropCameraEntities()[0].Destroy(); GetWinnerPropCameraEntities()[1].Destroy() } catch (exceptio2n){ }

	if ( MapName() == eMaps.mp_rr_desertlands_64k_x_64k || MapName() == eMaps.mp_rr_desertlands_64k_x_64k_nx )
	{
		file.victorySequencePosition = file.selectedLocation.victorypos.origin - < 0, 0, 52>
		file.victorySequenceAngles = file.selectedLocation.victorypos.angles
	}
	else if( MapName() == eMaps.mp_rr_canyonlands_mu1 )
	{
		file.victorySequencePosition = <-19443.75, -26319.9316, 9915.63965>	
		file.victorySequenceAngles = <0, 0, 0>
	}
	
	asset defaultModel                = GetGlobalSettingsAsset( DEFAULT_PILOT_SETTINGS, "bodyModel" )
	LoadoutEntry loadoutSlotCharacter = Loadout_CharacterClass()
	vector characterAngles            = < file.victorySequenceAngles.x / 2.0, Clamp(file.victorySequenceAngles.y-60, -180, 180), file.victorySequenceAngles.z >

	VictoryPlatformModelData victoryPlatformModelData = GetVictorySequencePlatformModel()

	entity platformModel
	entity characterModel
	int maxPlayersToShow = 3
	int maxPropsToShow = 1
	if ( victoryPlatformModelData.isSet )
	{
		platformModel = CreateClientSidePropDynamic( file.victorySequencePosition + victoryPlatformModelData.originOffset, victoryPlatformModelData.modelAngles, victoryPlatformModelData.modelAsset )
		
		cleanupEnts.append( platformModel )
		int playersOnPodium = 0

		VictorySequenceOrderPlayerFirst( player )

		foreach( int i, SquadSummaryPlayerData data in file.winnerSquadSummaryData.playerData )
		{
			if ( i >= maxPlayersToShow && Gamemode() != eGamemodes.fs_prophunt )
				break
			
			if ( file.teamwon != 3 && i >= maxPlayersToShow && Gamemode() == eGamemodes.fs_prophunt )
				break

			if ( file.teamwon == 3 && i >= maxPropsToShow && Gamemode() == eGamemodes.fs_prophunt )
				break
			
			string playerName = ""
			if ( EHIHasValidScriptStruct( data.eHandle ) )
				playerName = EHI_GetName( data.eHandle )
			
			if(file.teamwon == 3 && Gamemode() == eGamemodes.fs_prophunt )
				{
					if ( !LoadoutSlot_IsReady( data.eHandle, loadoutSlotCharacter ) )
						continue

					ItemFlavor character = LoadoutSlot_GetItemFlavor( data.eHandle, loadoutSlotCharacter )

					if ( !LoadoutSlot_IsReady( data.eHandle, Loadout_CharacterSkin( character ) ) )
						continue

					vector pos = GetVictorySquadFormationPosition( file.victorySequencePosition, file.victorySequenceAngles, i )
					entity characterNode = CreateScriptRef( pos, characterAngles )
					characterNode.SetParent( platformModel, "", true )

					characterModel = CreateClientSidePropDynamic( pos, characterAngles, prophuntAssets[data.prophuntModelIndex] )
					SetForceDrawWhileParented( characterModel, true )
					characterModel.MakeSafeForUIScriptHack()
					cleanupEnts.append( characterModel )

					foreach( func in s_callbacks_OnVictoryCharacterModelSpawned )
						func( characterModel, character, data.eHandle )

					characterModel.SetParent( characterNode, "", false )

					entity overheadNameEnt = CreateClientSidePropDynamic( pos + (AnglesToUp( file.victorySequenceAngles ) * 73), <0, 0, 0>, $"mdl/dev/empty_model.rmdl" )
					overheadNameEnt.Hide()

					var overheadRuiName = RuiCreate( $"ui/winning_squad_member_overhead_name.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 0 )
					RuiSetString(overheadRuiName, "playerName", playerName)
					RuiTrackFloat3(overheadRuiName, "position", overheadNameEnt, RUI_TRACK_ABSORIGIN_FOLLOW)

					overHeadRuis.append( overheadRuiName )

					playersOnPodium++
				}
			else
			{
				if ( !LoadoutSlot_IsReady( data.eHandle, loadoutSlotCharacter ) )
					continue

				ItemFlavor character = LoadoutSlot_GetItemFlavor( data.eHandle, loadoutSlotCharacter )

				if ( !LoadoutSlot_IsReady( data.eHandle, Loadout_CharacterSkin( character ) ) )
					continue

				
				ItemFlavor characterSkin 
				if(skinindex == 0)
					characterSkin = GetValidItemFlavorsForLoadoutSlot( data.eHandle, Loadout_CharacterSkin( character ) )[0]
				else
					characterSkin = GetValidItemFlavorsForLoadoutSlot( data.eHandle, Loadout_CharacterSkin( character ) )[GetValidItemFlavorsForLoadoutSlot( data.eHandle, Loadout_CharacterSkin( character ) ).len()-skinindex]
				
				vector pos = GetVictorySquadFormationPosition( file.victorySequencePosition, file.victorySequenceAngles, i )
				printt(pos)
				entity characterNode = CreateScriptRef( pos, characterAngles )
				characterNode.SetParent( platformModel, "", true )

				characterModel = CreateClientSidePropDynamic( pos, characterAngles, defaultModel )
				SetForceDrawWhileParented( characterModel, true )
				characterModel.MakeSafeForUIScriptHack()
				CharacterSkin_Apply( characterModel, characterSkin )

				cleanupEnts.append( characterModel )

				foreach( func in s_callbacks_OnVictoryCharacterModelSpawned )
					func( characterModel, character, data.eHandle )

				//characterModel.SetParent( characterNode, "", false )
				
				ItemFlavor anim = GetAllGoodAnimsFromGladcardStancesForCharacter_ChampionScreen(character).getrandom()
				asset animtoplay = GetGlobalSettingsAsset( ItemFlavor_GetAsset( anim ), "movingAnimSeq" )
				thread PlayAnim( characterModel, animtoplay, characterNode )
				characterModel.Anim_SetPlaybackRate(0.8)

				//characterModel.Anim_EnableUseAnimatedRefAttachmentInsteadOfRootMotion()

				entity overheadNameEnt = CreateClientSidePropDynamic( pos + (AnglesToUp( file.victorySequenceAngles ) * 73), <0, 0, 0>, $"mdl/dev/empty_model.rmdl" )
				overheadNameEnt.Hide()

				var overheadRuiName = RuiCreate( $"ui/winning_squad_member_overhead_name.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 0 )
				RuiSetString(overheadRuiName, "playerName", playerName)
				RuiTrackFloat3(overheadRuiName, "position", overheadNameEnt, RUI_TRACK_ABSORIGIN_FOLLOW)

				overHeadRuis.append( overheadRuiName )

				playersOnPodium++
			}
		}

		string dialogueApexChampion
        // if (file.teamwon == TEAM_IMC || file.teamwon == TEAM_MILITIA)
        // {
            if (player.GetTeam() == file.teamwon)
            {
                if ( playersOnPodium > 1 )
                    dialogueApexChampion = "diag_ap_aiNotify_winnerFound_07"
                else
                    dialogueApexChampion = "diag_ap_aiNotify_winnerFound_10"
            }
            else
            {
                if ( playersOnPodium > 1 )
                    dialogueApexChampion = "diag_ap_aiNotify_winnerFound_08"
                else
                    dialogueApexChampion = "diag_ap_ainotify_introchampion_01_02"
            }

            EmitSoundOnEntityAfterDelay( platformModel, dialogueApexChampion, 0.5 )
        // }
		
		vector AnglesToUseCamera
		
		// if(file.teamwon != 3 && GameRules_GetGameMode() == "fs_prophunt")
			// AnglesToUseCamera = characterModel.GetAngles()
		// else
			AnglesToUseCamera = file.victorySequenceAngles
		
		VictoryCameraPackage victoryCameraPackage
		victoryCameraPackage.camera_offset_start = AnglesToForward( AnglesToUseCamera ) * 300 + AnglesToUp( AnglesToUseCamera ) * 100
		victoryCameraPackage.camera_offset_end = AnglesToForward( AnglesToUseCamera ) * 300 + AnglesToRight( AnglesToUseCamera ) *200 + AnglesToUp( AnglesToUseCamera ) * 100
		//if(CoinFlip()) victoryCameraPackage.camera_offset_end = AnglesToForward( AnglesToUseCamera ) * 300 + AnglesToRight( AnglesToUseCamera ) *-200 + AnglesToUp( AnglesToUseCamera ) * 100
		victoryCameraPackage.camera_focus_offset = <0, 0, 40>
		//victoryCameraPackage.camera_fov = 20
	
		vector camera_offset_start = victoryCameraPackage.camera_offset_start
		vector camera_offset_end   = victoryCameraPackage.camera_offset_end
		vector camera_focus_offset = victoryCameraPackage.camera_focus_offset
		
		vector camera_start_pos = OffsetPointRelativeToVector( file.victorySequencePosition, camera_offset_start, AnglesToForward( AnglesToUseCamera ) )
		vector camera_end_pos   = OffsetPointRelativeToVector( file.victorySequencePosition, camera_offset_end, AnglesToForward( AnglesToUseCamera ) )
		vector camera_focus_pos = OffsetPointRelativeToVector( file.victorySequencePosition, camera_focus_offset, AnglesToForward( AnglesToUseCamera ) )
		vector camera_start_angles = VectorToAngles( camera_focus_pos - camera_start_pos )
		vector camera_end_angles   = VectorToAngles( camera_focus_pos - camera_end_pos )

        //Create camera and mover
		entity cameraMover = CreateClientsideScriptMover( $"mdl/dev/empty_model.rmdl", camera_start_pos, camera_start_angles )
		entity camera      = CreateClientSidePointCamera( camera_start_pos, camera_start_angles, 35 )
		player.SetMenuCameraEntity( camera )
		camera.SetParent( cameraMover, "", false )
		cleanupEnts.append( camera )

		cleanupEnts.append( cameraMover )
		thread CameraMovement(cameraMover, camera_end_pos, camera_end_angles)
	}
}

void function CameraMovement(entity cameraMover, vector camera_end_pos, vector camera_end_angles)
{
	vector initialOrigin = cameraMover.GetOrigin()
	vector initialAngles = cameraMover.GetAngles()

	//Move camera to end pos
	cameraMover.NonPhysicsMoveTo( camera_end_pos, 10, 0.0, 6 / 2.0 )
	cameraMover.NonPhysicsRotateTo( camera_end_angles, 10, 0.0, 6 / 2.0 )	
	// wait 3
	// if(!IsValid(cameraMover)) return
	// cameraMover.NonPhysicsMoveTo( initialOrigin, 5, 0.0, 5 / 2.0 )
	// cameraMover.NonPhysicsRotateTo( initialAngles, 5, 0.0, 5 / 2.0 )	
}

void function AddWinningSquadData( int index, int eHandle)
{
	if ( index == -1 )
	{
		file.winnerSquadSummaryData.playerData.clear()
		file.winnerSquadSummaryData.squadPlacement = -1
		return
	}

	SquadSummaryPlayerData data
	data.eHandle = eHandle
	file.winnerSquadSummaryData.playerData.append( data )
	file.winnerSquadSummaryData.squadPlacement = 1
}

void function PROPHUNT_AddWinningSquadData_PropTeamAddModelIndex( bool clear, int eHandle, int ModelIndex)
{
	if ( clear )
	{
		file.winnerSquadSummaryData.playerData.clear()
		file.winnerSquadSummaryData.squadPlacement = -1
	}
	
	SquadSummaryPlayerData data
	data.eHandle = eHandle
	data.prophuntModelIndex = ModelIndex
	file.winnerSquadSummaryData.playerData.append( data )
	file.winnerSquadSummaryData.squadPlacement = 1
}

void function VictorySequenceOrderPlayerFirst( entity player )
{
	int playerEHandle = player.GetEncodedEHandle()
	bool hadLocalPlayer = false
	array<SquadSummaryPlayerData> playerDataArray
	SquadSummaryPlayerData localPlayerData

	foreach( SquadSummaryPlayerData data in file.winnerSquadSummaryData.playerData )
	{
		if ( data.eHandle == playerEHandle )
		{
			localPlayerData = data
			hadLocalPlayer = true
			continue
		}

		playerDataArray.append( data )
	}

	file.winnerSquadSummaryData.playerData = playerDataArray
	if ( hadLocalPlayer )
		file.winnerSquadSummaryData.playerData.insert( 0, localPlayerData )
}

vector function GetVictorySquadFormationPosition( vector mainPosition, vector angles, int index )
{
	if ( index == 0 )
		return mainPosition - <0, 0, 8>

	float offset_side = 48.0
	float offset_back = -28.0

	int groupOffsetIndex = index / 3
	int internalGroupOffsetIndex = index % 3

	float internalGroupOffsetSide = 34.0                                                                                           
	float internalGroupOffsetBack = -38.0                                                                              

	float groupOffsetSide = 114.0                                                                                            
	float groupOffsetBack = -64.0                                                                               

	float finalOffsetSide = ( groupOffsetSide * ( groupOffsetIndex % 2 == 0 ? 1 : -1 ) * ( groupOffsetIndex == 0 ? 0 : 1 ) ) + ( internalGroupOffsetSide * ( internalGroupOffsetIndex % 2 == 0 ? 1 : -1 ) * ( internalGroupOffsetIndex == 0 ? 0 : 1 ) )
	float finalOffsetBack = ( groupOffsetBack * ( groupOffsetIndex == 0 ? 0 : 1 ) ) + ( internalGroupOffsetBack * ( internalGroupOffsetIndex == 0 ? 0 : 1 ) )

	vector offset = < finalOffsetSide, finalOffsetBack, -8 >
	return OffsetPointRelativeToVector( mainPosition, offset, AnglesToForward( angles ) )
}

void function DM_HintCatalog( int index, entity otherPlayer )
{
	if( !IsValid( GetLocalViewPlayer() ) ) 
		return

	switch( index )
	{
		case 0:
		DM_QuickHint( "Hold %use% to lock nearest enemy", true, 10)
		break
		
		case 1:
		DM_QuickHint( "One more kill to get Energy Sword.", true, 3)
		EmitSoundOnEntity(GetLocalViewPlayer(), "UI_InGame_FD_SliderExit" )
		break

		case 2:
		DM_QuickHint( "Keep the ball to score points.\nGet " + ODDBALL_POINTS_TO_WIN + " points to win the round.", true, 5)
		EmitSoundOnEntity(GetLocalViewPlayer(), "UI_InGame_FD_SliderExit" )
		break
		
		case 3:
		switch( Playlist() )
		{
			case ePlaylists.fs_movementrecorder:
			Obituary_Print_Localized( "R5Reloaded by @AmosModz", GetChatTitleColorForPlayer( GetLocalViewPlayer() ), BURN_COLOR )
			Obituary_Print_Localized( "FS Movement Recorder - Made by @CafeFPS and mkos.", GetChatTitleColorForPlayer( GetLocalViewPlayer() ), BURN_COLOR )
			break

			case ePlaylists.fs_lgduels_1v1:
			Obituary_Print_Localized( "R5Reloaded by @AmosModz", GetChatTitleColorForPlayer( GetLocalViewPlayer() ), BURN_COLOR )
			Obituary_Print_Localized( "FS LG Duels - Made by @CafeFPS and mkos.", GetChatTitleColorForPlayer( GetLocalViewPlayer() ), BURN_COLOR )
			break
			
			case ePlaylists.fs_scenarios:
			Obituary_Print_Localized( "R5Reloaded by @AmosModz", GetChatTitleColorForPlayer( GetLocalViewPlayer() ), BURN_COLOR )
			Obituary_Print_Localized( "%$rui/bullet_point% Players Connected: " + GetPlayerArray().len(), GetChatTitleColorForPlayer( GetLocalViewPlayer() ), BURN_COLOR )
			Obituary_Print_Localized( "FS Scenarios - Made and designed by @CafeFPS with the help from @ttvmkos.", GetChatTitleColorForPlayer( GetLocalViewPlayer() ), BURN_COLOR )
			break
			
			case ePlaylists.fs_1v1:
			Obituary_Print_Localized( "R5Reloaded by @AmosModz", GetChatTitleColorForPlayer( GetLocalViewPlayer() ), BURN_COLOR )
			Obituary_Print_Localized( "R5 1V1 by Flowstate", GetChatTitleColorForPlayer( GetLocalViewPlayer() ), BURN_COLOR )
			break
		}
		break

		case 4:
		DM_QuickHint( "You have to kill the two dummies at the same time before you can continue!", true, 3 )
		break

		case 5:
		DM_QuickHint( "Starting new game in " + GetCurrentPlaylistVarFloat( "survival_server_restart_after_end_time", 30 ) + " seconds.", true, 5 )
		break
		
		case -1:
		if(file.activeQuickHint != null)
		{
			RuiDestroyIfAlive( file.activeQuickHint )
			file.activeQuickHint = null
		}
		break
	}
}

void function DM_QuickHint( string hintText, bool blueText = false, float duration = 2.5)
{
	if(file.activeQuickHint != null)
	{
		RuiDestroyIfAlive( file.activeQuickHint )
		file.activeQuickHint = null
	}
	file.activeQuickHint = CreateFullscreenRui( $"ui/announcement_quick_right.rpak" )
	
	RuiSetGameTime( file.activeQuickHint, "startTime", Time() )
	RuiSetString( file.activeQuickHint, "messageText", hintText )
	RuiSetFloat( file.activeQuickHint, "duration", duration.tofloat() )
	
	if(blueText)
		RuiSetFloat3( file.activeQuickHint, "eventColor", SrgbToLinear( <48, 107, 255> / 255.0 ) )
	else
		RuiSetFloat3( file.activeQuickHint, "eventColor", SrgbToLinear( <255, 0, 119> / 255.0 ) )
}

array<void functionref( entity, ItemFlavor, int )> s_callbacks_OnVictoryCharacterModelSpawned

array< string > SurvivorQuoteCatalog = [ //this is so bad maybe change it to datatable?
	"",
	"",
	"Double Kill!",
	"Triple Kill!",
	"Overkill!",
	"Killtacular!",
	"Killtrocity!",
	"Killamanjaro!",
	"Killtastrophe!",
	"Killpocalypse!",
	"Killionaire!"
]

array< asset > SurvivorAssetCatalog = [ //this is so bad maybe change it to datatable?
	$"",
	$"",
	$"rui/flowstate_custom/halomod_badges/2",
	$"rui/flowstate_custom/halomod_badges/3",
	$"rui/flowstate_custom/halomod_badges/4",
	$"rui/flowstate_custom/halomod_badges/5",
	$"rui/flowstate_custom/halomod_badges/6",
	$"rui/flowstate_custom/halomod_badges/7",
	$"rui/flowstate_custom/halomod_badges/8",
	$"rui/flowstate_custom/halomod_badges/9",
	$"rui/flowstate_custom/halomod_badges/10"
]

void function FSHaloMod_CreateKillStreakAnnouncement( int index )
{
	thread function () : ( index )
	{
		array< string > quotesCatalogToUse

		asset badge = SurvivorAssetCatalog[index]
		string quote = SurvivorQuoteCatalog[index]
		float duration = 3.5
		
		if( badge == $"" ) return
		
		Signal(GetLocalClientPlayer(), "NewKillChangeRui")
		EndSignal(GetLocalClientPlayer(), "NewKillChangeRui")

		var KillStreakRuiBadge = HudElement( "KillStreakBadge1")
		var KillStreakRuiText = HudElement( "KillStreakText1")
		
		OnThreadEnd(
			function() : ( KillStreakRuiBadge, KillStreakRuiText )
			{
				Hud_SetEnabled( KillStreakRuiBadge, false )
				Hud_SetVisible( KillStreakRuiBadge, false )
				
				Hud_SetEnabled( KillStreakRuiText, false )
				Hud_SetVisible( KillStreakRuiText, false )
			}
		)
		
		RuiSetImage( Hud_GetRui( KillStreakRuiBadge ), "basicImage", badge )
		
		Hud_ReturnToBasePos(KillStreakRuiBadge)
		Hud_ReturnToBasePos(KillStreakRuiText)

		Hud_SetText( KillStreakRuiText, quote )

		Hud_SetSize( KillStreakRuiBadge, 0, 0 )
		Hud_ScaleOverTime( KillStreakRuiBadge, 1.6, 1.6, 0.20, INTERPOLATOR_SIMPLESPLINE)

		// Hud_SetSize( KillStreakRuiText, 0, 0 )
		// Hud_ScaleOverTime( KillStreakRuiText, 1, 1, 0.15, INTERPOLATOR_ACCEL)
		
		Hud_SetAlpha( KillStreakRuiBadge, 255 )
		Hud_SetAlpha( KillStreakRuiText, 255 )

		Hud_SetEnabled( KillStreakRuiBadge, true )
		Hud_SetVisible( KillStreakRuiBadge, true )
		
		Hud_SetEnabled( KillStreakRuiText, true )
		Hud_SetVisible( KillStreakRuiText, true )
		
		wait 0.20
		
		Hud_ScaleOverTime( KillStreakRuiBadge, 1, 1, 0.20, INTERPOLATOR_SIMPLESPLINE)
		
		wait 0.20 + duration
		
		waitthread FSHaloMod_KillStreak_FadeOut(KillStreakRuiBadge, KillStreakRuiText)
	}()
}

void function FSHaloMod_KillStreak_FadeOut( var label, var label2, int xOffset = 200, int yOffset = 0, float duration = 0.3 )
{
	EndSignal(GetLocalClientPlayer(), "NewKillChangeRui")
	
	UIPos currentPos = REPLACEHud_GetPos( label )
	UIPos currentPos2 = REPLACEHud_GetPos( label2 )

	OnThreadEnd(
		function() : ( label, label2, currentPos, xOffset, yOffset )
		{
			Hud_SetEnabled( label, false )
			Hud_SetVisible( label, false )
			
			Hud_SetEnabled( label2, false )
			Hud_SetVisible( label2, false )
		}
	)

	Hud_FadeOverTime( label, 0, duration/2, INTERPOLATOR_ACCEL )
	Hud_FadeOverTime( label2, 0, duration/2, INTERPOLATOR_ACCEL )

	Hud_MoveOverTime( label, currentPos.x + xOffset, currentPos.y + yOffset, duration )
	
	wait duration
}

void function fs_ServerMsgsToChatBox_BuildMessage( Type, ... )
{
	// clGlobal.levelEnt.Signal( "FS_CloseNewMsgBox" )
	
	if( file.fs_newServerMsgsToChatBoxString == "" )
		file.fs_newServerMsgsToChatBoxString += "[SERVER] "

	if ( Type == 0 )
	{
		for ( int i = 0; i < vargc; i++ )
			file.fs_newServerMsgsToChatBoxString += format("%c", vargv[i] )
	}
	else if ( Type == 1 )
	{
		for ( int i = 0; i < vargc; i++ )
			file.fs_newServerMsgsToChatBoxSubString += format("%c", vargv[i] )
	}
}

void function fs_ServerMsgsToChatBox_ShowMessage( Width, Duration, ... )
{
	RunUIScript( "Open_FS_MsgsChatBox" )

	string toSend = file.fs_newServerMsgsToChatBoxString
	array separateLines = split(toSend, "\n")
	int totalLines = separateLines.len()
	
	int highestcharts = -1
	foreach( line in separateLines )
	{
		int thislinecharacters = 0
		foreach( character in line )
		{
			thislinecharacters++
		}
		if( thislinecharacters > highestcharts )
			highestcharts = thislinecharacters
	}

	float height = float( 40 * totalLines )
	float width = 7.9 * highestcharts
	RunUIScript( "FS_MsgsChatBox_SetText", file.fs_newServerMsgsToChatBoxString, width, height )

	file.fs_newServerMsgsToChatBoxString = ""
	file.fs_newServerMsgsToChatBoxSubString = ""
}

void function fs_NewBoxBuildMessage( Type, ... )
{
	// clGlobal.levelEnt.Signal( "FS_CloseNewMsgBox" )

	if ( Type == 0 )
	{
		for ( int i = 0; i < vargc; i++ )
			file.fs_newMsgBoxString += format("%c", vargv[i] )
	}
	else if ( Type == 1 )
	{
		for ( int i = 0; i < vargc; i++ )
			file.fs_newMsgBoxSubString += format("%c", vargv[i] )
	}
}

void function fs_NewBoxShowMessage( float duration )
{
	Flowstate_AddCustomScoreEventMessage(  file.fs_newMsgBoxString, duration )

	file.fs_newMsgBoxString = ""
	file.fs_newMsgBoxSubString = ""
	// thread FS_NewBox_Msg( duration )
}

void function FS_Show1v1Banner( entity player )
{
	#if !DEVELOPER
		if( GetGameState() >= eGameState.Playing )
			return
	#endif
				
	float duration = 5

	clGlobal.levelEnt.Signal( "FS_1v1Banner" )
	clGlobal.levelEnt.EndSignal( "FS_1v1Banner" )
	player.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( )
		{
			Hud_SetVisible( HudElement( "FS_1v1Banner" ), false )
		}
	)
	
	Hud_ReturnToBasePos( HudElement( "FS_1v1Banner" ) )
	Hud_SetSize( HudElement( "FS_1v1Banner" ), 0, 0 )
	
	Hud_SetVisible( HudElement( "FS_1v1Banner" ), true )	
	Hud_ScaleOverTime( HudElement( "FS_1v1Banner" ), 1.7, 1.7, 1, INTERPOLATOR_ACCEL )
	wait 1
	Hud_ScaleOverTime( HudElement( "FS_1v1Banner" ), 1, 1, 2, INTERPOLATOR_SIMPLESPLINE )
	wait duration - 2
	Hud_FadeOverTime( HudElement( "FS_1v1Banner" ), 0, 3, INTERPOLATOR_ACCEL )
	wait 2
}

void function FS_Scenarios_InitPlayersCards()
{
	file.allyTeamCards.clear()
	file.enemyTeamCards.clear()
	file.enemyTeamCards2.clear()

	#if DEVELOPER
		printt( "FS_Scenarios_InitPlayersCards" )
	#endif 
	
	file.vsBasicImage = HudElement( "ScenariosVS" )
	file.vsBasicImage2 = HudElement( "ScenariosVS_2" )
	RuiSetImage( Hud_GetRui( file.vsBasicImage ), "basicImage", $"rui/flowstatecustom/vs" )
	RuiSetImage( Hud_GetRui( file.vsBasicImage2 ), "basicImage", $"rui/flowstatecustom/vs" )

	for(int i = 0; i<3; i++ )
	{
		var button = HudElement( "TestCharacterL" + i )
		file.allyTeamCards.append( button )

		RuiSetBool( Hud_GetRui( button ), "isPurchasable", false )
		RuiSetString( Hud_GetRui( button ), "buttonText", "@CafeFPS" )
		RuiSetImage( Hud_GetRui( button ), "buttonImage", $"rui/menu/buttons/lobby_character_select/random" )
		RuiSetImage( Hud_GetRui( button ), "bgImage", $"rui/flowstate_custom/colombia_flag_papa" )
		RuiSetImage( Hud_GetRui( button ), "roleImage", $"" )
		Hud_SetVisible( button, false )
	}

	for(int i = 0; i<3; i++ )
	{
		var button = HudElement( "TestCharacterR" + i )
		file.enemyTeamCards.append( button )
		
		RuiSetBool( Hud_GetRui( button ), "isPurchasable", false )
		RuiSetString( Hud_GetRui( button ), "buttonText", "@CafeFPS" )
		RuiSetImage( Hud_GetRui( button ), "buttonImage", $"rui/menu/buttons/lobby_character_select/random" )
		RuiSetImage( Hud_GetRui( button ), "bgImage", $"rui/flowstate_custom/colombia_flag_papa" )
		RuiSetImage( Hud_GetRui( button ), "roleImage", $"" )
		Hud_SetVisible( button , false )
	}

	for(int i = 0; i<3; i++ )
	{
		var button = HudElement( "TestCharacterF" + i )
		file.enemyTeamCards2.append( button )
		
		RuiSetBool( Hud_GetRui( button ), "isPurchasable", false )
		RuiSetString( Hud_GetRui( button ), "buttonText", "@CafeFPS" )
		RuiSetImage( Hud_GetRui( button ), "buttonImage", $"rui/menu/buttons/lobby_character_select/random" )
		RuiSetImage( Hud_GetRui( button ), "bgImage", $"rui/flowstate_custom/colombia_flag_papa" )
		RuiSetImage( Hud_GetRui( button ), "roleImage", $"" )
		Hud_SetVisible( button , false )
	}
}

void function FS_Scenarios_AddEnemyHandle( entity enemyPlayer )
{
	if( !IsValid( enemyPlayer ) )
		return

	// printt( "added handle for enemy team player", handle )
	file.enemyTeamHandles.append( enemyPlayer.GetEncodedEHandle() )
}

void function FS_Scenarios_AddEnemyHandle2( entity enemyPlayer )
{
	if( !IsValid( enemyPlayer ) )
		return

	// printt( "added handle for enemy team player", handle )
	file.enemyTeamHandles2.append( enemyPlayer.GetEncodedEHandle() )
}

void function FS_Scenarios_AddAllyHandle( entity allyPlayer )
{
	if( !IsValid( allyPlayer ) )
		return

	// printt( "added handle for ally team player", handle )
	file.allyTeamHandles.append( allyPlayer.GetEncodedEHandle() )
}

void function FS_Scenarios_SetupPlayersCards( bool onlyUpdate )
{
	#if DEVELOPER
		printt("FS_Scenarios_SetupPlayersCards", onlyUpdate, file.enemyTeamHandles2.len(), file.enemyTeamHandles.len(), file.allyTeamHandles.len() )
	#endif

	if( file.vsBasicImage != null )
		Hud_SetVisible( file.vsBasicImage, false )
		
	if( file.vsBasicImage2 != null )
		Hud_SetVisible( file.vsBasicImage2, false )
	
	foreach( int i, int handle in file.enemyTeamHandles2 )
	{
		if( i >= file.enemyTeamCards2.len() )
			continue

		thread function() : ( i, handle )
		{
			entity enemyPlayer = GetEntityFromEncodedEHandle( handle )
			
			if( !IsValid( enemyPlayer ) )
				return

			EndSignal( enemyPlayer, "OnDestroy" )

			ItemFlavor character = LoadoutSlot_WaitForItemFlavor( handle, Loadout_CharacterClass() )

			RuiSetBool( Hud_GetRui( file.enemyTeamCards2[i] ), "isPurchasable", true )
			RuiSetString( Hud_GetRui( file.enemyTeamCards2[i] ), "buttonText", enemyPlayer.GetPlayerName() )
			RuiSetImage( Hud_GetRui( file.enemyTeamCards2[i] ), "buttonImage", CharacterClass_GetGalleryPortrait( character ) )
			RuiSetImage( Hud_GetRui( file.enemyTeamCards2[i] ), "bgImage", CharacterClass_GetGalleryPortraitBackground( character ) )
			RuiSetImage( Hud_GetRui( file.enemyTeamCards2[i] ), "roleImage", $"" )

			// Hud_SetVisible( file.enemyTeamCards2[i], true )
		}()
	}

	foreach( int i, int handle in file.enemyTeamHandles )
	{
		if( i > file.enemyTeamCards.len() )
			continue

		thread function() : ( i, handle )
		{
			entity enemyPlayer = GetEntityFromEncodedEHandle( handle )
			
			if( !IsValid( enemyPlayer ) )
				return

			EndSignal( enemyPlayer, "OnDestroy" )

			ItemFlavor character = LoadoutSlot_WaitForItemFlavor( handle, Loadout_CharacterClass() )

			RuiSetBool( Hud_GetRui( file.enemyTeamCards[i] ), "isPurchasable", true )
			RuiSetString( Hud_GetRui( file.enemyTeamCards[i] ), "buttonText", enemyPlayer.GetPlayerName() )
			RuiSetImage( Hud_GetRui( file.enemyTeamCards[i] ), "buttonImage", CharacterClass_GetGalleryPortrait( character ) )
			RuiSetImage( Hud_GetRui( file.enemyTeamCards[i] ), "bgImage", CharacterClass_GetGalleryPortraitBackground( character ) )
			RuiSetImage( Hud_GetRui( file.enemyTeamCards[i] ), "roleImage", $"" )

			// Hud_SetVisible( file.enemyTeamCards[i], true )
		}()
	}

	foreach( int i, int handle in file.allyTeamHandles )
	{
		if( i > file.allyTeamCards.len() )
			continue

		thread function() : ( i, handle )
		{
			entity allyPlayer = GetEntityFromEncodedEHandle( handle )
			
			if( !IsValid( allyPlayer ) )
				return

			EndSignal( allyPlayer, "OnDestroy" )

			ItemFlavor character = LoadoutSlot_WaitForItemFlavor( handle, Loadout_CharacterClass() )

			RuiSetBool( Hud_GetRui( file.allyTeamCards[i] ), "isPurchasable", true )
			RuiSetString( Hud_GetRui( file.allyTeamCards[i] ), "buttonText", allyPlayer.GetPlayerName() )
			RuiSetImage( Hud_GetRui( file.allyTeamCards[i] ), "buttonImage", CharacterClass_GetGalleryPortrait( character ) )
			RuiSetImage( Hud_GetRui( file.allyTeamCards[i] ), "bgImage", CharacterClass_GetGalleryPortraitBackground( character ) )
			RuiSetImage( Hud_GetRui( file.allyTeamCards[i] ), "roleImage", $"" )

			// Hud_SetVisible( file.allyTeamCards[i], true )
		}()
	}

	
	if( file.enemyTeamHandles.len() > 0 && file.allyTeamHandles.len() > 0 && !onlyUpdate )
		FS_Scenarios_TogglePlayersCardsVisibility( true, false )
}

void function FS_Scenarios_TogglePlayersCardsVisibility( bool show, bool reset )
{
	#if DEVELOPER
		printt("FS_Scenarios_TogglePlayersCardsVisibility", show, reset)
	#endif
	if( file.vsBasicImage != null )
		Hud_SetVisible( file.vsBasicImage, show )

	if( file.vsBasicImage2 != null && file.enemyTeamHandles2.len() > 0 && show )
		Hud_SetVisible( file.vsBasicImage2, true )
	else if( file.vsBasicImage2 != null && file.enemyTeamHandles2.len() == 0 || file.vsBasicImage2 != null && !show )
		Hud_SetVisible( file.vsBasicImage2, false )

	foreach( button in file.allyTeamCards )
	{
		Hud_SetVisible( button, show )
	}

	foreach( button in file.enemyTeamCards )
	{
		Hud_SetVisible( button, show )
	}

	foreach( button in file.enemyTeamCards2 )
	{
		Hud_SetVisible( button, show )
	}

	if( show ) 
	{
		FS_DestroyCompass()

		//hide the player cards that are not going to be used
		for( int i = 0; i < file.allyTeamCards.len(); i++ )
		{
			if( i < file.allyTeamHandles.len() )
				continue
			
			Hud_SetVisible( file.allyTeamCards[i], false )
		}

		for( int i = 0; i < file.enemyTeamCards.len(); i++ )
		{
			if( i < file.enemyTeamHandles.len() )
				continue
			
			Hud_SetVisible( file.enemyTeamCards[i], false )
		}

		for( int i = 0; i < file.enemyTeamCards2.len(); i++ )
		{
			if( i < file.enemyTeamHandles2.len() )
				continue
			
			Hud_SetVisible( file.enemyTeamCards2[i], false )
		}
		
		if( file.allyTeamCards.len() != 0 && file.enemyTeamCards.len() != 0 && file.enemyTeamCards2.len() != 0 || Gamemode() == eGamemodes.WINTEREXPRESS )
		{
			UIPos wepSelectorBasePos = REPLACEHud_GetBasePos( file.vsBasicImage )	
			UISize screenSize = GetScreenSize()
			Hud_SetPos( file.vsBasicImage, wepSelectorBasePos.x - 165 * screenSize.width / 1920.0, wepSelectorBasePos.y + 2 * screenSize.height / 1080.0 )
		}
		
	} 
		
	if( !show && reset )
	{
		file.allyTeamHandles.clear()
		file.enemyTeamHandles.clear()
		file.enemyTeamHandles2.clear()
		FS_Scenarios_InitPlayersCards()
	}
	
	if( !show && Playlist() == ePlaylists.fs_scenarios )
	{
		SetNextCircleDisplayCustomClear()
	}
}

void function FS_Scenarios_ChangeAliveStateForPlayer( entity player, bool alive )
{
	int eHandle = player.GetEncodedEHandle()
	
	foreach( int i, int handle in file.allyTeamHandles )
	{
		if( handle == eHandle )
		{
			RuiSetBool( Hud_GetRui( file.allyTeamCards[i] ), "isPurchasable", alive )
			RuiSetImage( Hud_GetRui( file.allyTeamCards[i] ), "roleImage", alive ? $"" : $"rui/rui_screens/skull" )
			return
		}
	}
	
	foreach( int i, int handle in file.enemyTeamHandles )
	{
		if( handle == eHandle )
		{
			RuiSetBool( Hud_GetRui( file.enemyTeamCards[i] ), "isPurchasable", alive )
			RuiSetImage( Hud_GetRui( file.enemyTeamCards[i] ), "roleImage", alive ? $"" : $"rui/rui_screens/skull" )
			return
		}
	}

	foreach( int i, int handle in file.enemyTeamHandles2 )
	{
		if( handle == eHandle )
		{
			RuiSetBool( Hud_GetRui( file.enemyTeamCards2[i] ), "isPurchasable", alive )
			RuiSetImage( Hud_GetRui( file.enemyTeamCards2[i] ), "roleImage", alive ? $"" : $"rui/rui_screens/skull" )
			return
		}
	}
}

void function FS_CreateTeleportFirstPersonEffectOnPlayer()
{
	entity player = GetLocalViewPlayer()

	if ( IsValid( player.GetCockpit() ) )
	{
		int fxHandle = StartParticleEffectOnEntity( player.GetCockpit(), GetParticleSystemIndex( $"P_training_teleport_FP" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
		EffectSetIsWithCockpit( fxHandle, true )
	}
}

void function Tracker_ShowChampion()
{
	if ( GetCurrentPlaylistVarBool( "show_short_champion_screen", true ) )
		thread DoChampionSquadCardsPresentation()
}

void function SelfShowChampion()
{
	if( IsShowingChampionPresentation() )
		return 
		
	thread DoChampionSquadCardsPresentation( true )
}

void function UiToClient_ConfirmRest( string arg )
{
	entity player = GetLocalClientPlayer()
	if( IsValid( player ) )
		player.ClientCommand( arg )
		
	SpamWarning( 10, "confirmed rest? arg: \"" + arg + "\"" )
}

void function FS4DIntroSequence()
{
	thread void function() : ()
	{
		var rui = RuiCreate( $"ui/cockpit_console_text_top_right.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 0)
		RuiSetInt( rui, "maxLines", 1 );
		RuiSetInt( rui, "lineNum", 0 );
		RuiSetFloat2( rui, "msgPos", <0.45, 0.4875, 0> )
		RuiSetString( rui, "msgText", "EladNLG Presents" )
		RuiSetFloat3( rui, "msgColor", <1, 1, 1> )
		RuiSetFloat( rui, "msgFontSize", 24.0)
		RuiSetFloat( rui, "msgAlpha", 0.9 )
		RuiSetFloat( rui, "thicken", 0.0 )

		float endTime = Time() + 6
		while (Time() < endTime)
		{
			float timeLeft = endTime - Time()
			RuiSetFloat( rui, "msgAlpha", 0.9 * min(1, timeLeft) )
			wait 0.001
		}
		RuiDestroy( rui )

		rui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 0)
		RuiSetInt( rui, "maxLines", 1 );
		RuiSetInt( rui, "lineNum", 0 );
		RuiSetFloat2( rui, "msgPos", <0.55, 0.475, 0> )
		RuiSetString( rui, "msgText", "Powered by flowstate\nand r5reloaded" )
		RuiSetFloat3( rui, "msgColor", <1, 1, 1> )
		RuiSetFloat( rui, "msgFontSize", 24.0)
		RuiSetFloat( rui, "msgAlpha", 0.9 )
		RuiSetFloat( rui, "thicken", 0.0 )
		
		endTime = Time() + 6
		while (Time() < endTime)
		{
			float timeLeft = endTime - Time()
			RuiSetFloat( rui, "msgAlpha", 0.9 * min(1, timeLeft) )
			wait 0.001
		}
		RuiDestroy( rui )

		
		rui = RuiCreate( $"ui/cockpit_console_text_center.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 0)
		RuiSetInt( rui, "maxLines", 1 );
		RuiSetInt( rui, "lineNum", 0 );
		RuiSetFloat2( rui, "msgPos", <0.0, 0.0, 0> )
		RuiSetString( rui, "msgText", "4d apex" )
		RuiSetFloat3( rui, "msgColor", <1, 1, 1> )
		RuiSetFloat( rui, "msgFontSize", 144.0)
		RuiSetFloat( rui, "msgAlpha", 0.9 )
		RuiSetFloat( rui, "thicken", 0.0 )
		
		endTime = Time() + 6
		while (Time() < endTime)
		{
			float timeLeft = endTime - Time()
			RuiSetFloat( rui, "msgAlpha", 0.9 * min(1, timeLeft) )
			wait 0.001
		}
		RuiDestroy( rui )
	}()
}

//sorry janu
void function HaloBrIntroSequence()
{
	thread void function() : ()
	{
		var rui = RuiCreate( $"ui/cockpit_console_text_top_right.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 0)
		RuiSetInt( rui, "maxLines", 1 );
		RuiSetInt( rui, "lineNum", 0 );
		RuiSetFloat2( rui, "msgPos", <0.45, 0.2, 0> )
		RuiSetString( rui, "msgText", "HisWattson Presents" )
		RuiSetFloat3( rui, "msgColor", <1, 1, 1> )
		RuiSetFloat( rui, "msgFontSize", 50.0)
		RuiSetFloat( rui, "msgAlpha", 0.9 )
		RuiSetFloat( rui, "thicken", 0.0 )

		float endTime = Time() + 5
		while (Time() < endTime)
		{
			float timeLeft = endTime - Time()
			RuiSetFloat( rui, "msgAlpha", 0.9 * min(1, timeLeft) )
			wait 0.001
		}
		RuiDestroy( rui )

		rui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 0)
		RuiSetInt( rui, "maxLines", 1 );
		RuiSetInt( rui, "lineNum", 0 );
		RuiSetFloat2( rui, "msgPos", <0.55, 0.17, 0> )
		RuiSetString( rui, "msgText", "Designed by CafeFPS\nHosted by karma-gaming.net\nPowered by R5Reloaded" )
		RuiSetFloat3( rui, "msgColor", <1, 1, 1> )
		RuiSetFloat( rui, "msgFontSize", 50.0)
		RuiSetFloat( rui, "msgAlpha", 0.9 )
		RuiSetFloat( rui, "thicken", 0.0 )
		
		endTime = Time() + 5
		while (Time() < endTime)
		{
			float timeLeft = endTime - Time()
			RuiSetFloat( rui, "msgAlpha", 0.9 * min(1, timeLeft) )
			wait 0.001
		}
		RuiDestroy( rui )

		
		rui = RuiCreate( $"ui/cockpit_console_text_center.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 0)
		RuiSetInt( rui, "maxLines", 1 );
		RuiSetInt( rui, "lineNum", 0 );
		RuiSetFloat2( rui, "msgPos", <0.0, -0.22, 0> )
		RuiSetString( rui, "msgText", "   HALO MOD\nBATTLE ROYALE" )
		RuiSetFloat3( rui, "msgColor", <1, 1, 1> )
		RuiSetFloat( rui, "msgFontSize", 110.0)
		RuiSetFloat( rui, "msgAlpha", 0.9 )
		RuiSetFloat( rui, "thicken", 0.0 )
		
		endTime = Time() + 5
		while (Time() < endTime)
		{
			float timeLeft = endTime - Time()
			RuiSetFloat( rui, "msgAlpha", 0.9 * min(1, timeLeft) )
			wait 0.001
		}
		RuiDestroy( rui )
	}()
}

//(cafe) FS 1v1 Settings
void function Send1v1SettingsToServer()
{
	entity player = GetLocalClientPlayer()
	
	player.ClientCommand("CC_1v1_StartInRest " + GetConVarInt("fs_1v1_startinrest").tostring())	
	player.ClientCommand("CC_1v1_IBMM " + GetConVarInt("fs_1v1_ibmm").tostring())
	player.ClientCommand("CC_1v1_AcceptChallenges " + GetConVarInt("fs_1v1_acceptchallenges").tostring())
	player.ClientCommand("CC_1v1_ShowInputBanner " + GetConVarInt("fs_1v1_showinputbanner").tostring())		
	player.ClientCommand("CC_1v1_ShowVsUI " + GetConVarInt("fs_1v1_showvsui").tostring())
	SetShow1v1Scoreboard( GetConVarInt("fs_1v1_showvsui").tostring() )
	
	player.ClientCommand("CC_1v1_CamoColor " + GetConVarInt("fs_1v1_camo").tostring())
	player.ClientCommand("CC_1v1_Heirloom " + GetConVarInt("fs_1v1_heirloom").tostring())
	
	player.ClientCommand("CC_1v1_MaxEnemyLatency " + GetConVarInt("fs_1v1_maxenemylatency").tostring())
	player.ClientCommand("CC_1v1_MaxIBMMTime " + GetConVarInt("fs_1v1_maxibmmtime").tostring())
}

void function FS_RestButton( entity player )
{
	if ( player != GetLocalViewPlayer() )
		return
	
	if ( player != GetLocalClientPlayer() )
		return
	
	if( player.GetPlayerNetInt( "FS_1v1_PlayerState" ) != e1v1State.WAITING && player.GetPlayerNetInt( "FS_1v1_PlayerState" ) != e1v1State.RESTING )
		return
	
	if ( IsControllerModeActive() )
	{
		if ( TryPingBlockingFunction( player, "quickchat" ) )
			return
	}
	
	RunUIScript("FS_1v1_SettingsMenu_Close")
	player.ClientCommand( "rest" )
	return
}


void function FS_SettingsButton( entity player )
{
	if ( player != GetLocalViewPlayer() )
		return
	
	if ( player != GetLocalClientPlayer() )
		return

	if( player.GetPlayerNetInt( "FS_1v1_PlayerState" ) != e1v1State.RESTING )
		return
	
	RunUIScript("FS_1v1_SettingsMenu_Open")
	Signal( player, "Destroy1v1SettingsHint" )
}

void function FS_SpectateButton( entity player )
{
	if ( player != GetLocalViewPlayer() )
		return
	
	if ( player != GetLocalClientPlayer() )
		return

	if( player.GetPlayerNetInt( "FS_1v1_PlayerState" ) != e1v1State.RESTING )
		return
	
	RunUIScript("FS_1v1_SettingsMenu_Close")
	player.ClientCommand( "spectate_1v1" )
}

void function FS_1v1_DisplayHints( int state )
{
	thread function () : (state)
	{
		entity player = GetLocalClientPlayer()

		if ( !IsValid( player ) )
			return
		
		int actualState = state
		if( state == -1 )
			actualState = player.GetPlayerNetInt( "FS_1v1_PlayerState" )
		
		string text = ""
		
		switch( actualState )
		{
			case e1v1State.RESTING:
			text = "%scriptCommand5% STOP RESTING\n%scriptCommand3% SETTINGS\n%scriptCommand4% SPECTATE\n%toggle_map% SCOREBOARD"
			break

			case e1v1State.WAITING:
			text = "%scriptCommand5% REST\n%toggle_map% SCOREBOARD"
			break
			
			case e1v1State.SPECTATING:
			text = "%jump% STOP SPECTATING"
			break
			
			
			default:
			text = "BUG THIS"
			break
		}
		
		// if( player.GetPlayerNetInt( "FS_1v1_PlayerState" ) != e1v1State.RESTING )
			// return
			
		player.EndSignal( "OnDestroy" )
		player.Signal( "Destroy1v1SettingsHint" )
		player.EndSignal( "Destroy1v1SettingsHint" )

		// AddPlayerHint( 420.0, 0.15, $"", text )
		Gamemode1v1_PermaHint( text )
		
		printw( "FS_1v1_DisplayHints", player )
		
		OnThreadEnd(
			function() : (text)
			{
				// RunUIScript("FS_1v1_SettingsMenu_Close")
				// HidePlayerHint( text )
				if(file.activeQuickHint2 != null)
				{
					RuiDestroyIfAlive( file.activeQuickHint2 )
					file.activeQuickHint2 = null
				}
			}
		)

		WaitForever()
	}()
}

void function Gamemode1v1_PermaHint( string hintText )
{
	if(file.activeQuickHint2 != null)
	{
		RuiDestroyIfAlive( file.activeQuickHint2 )
		file.activeQuickHint2 = null
	}

	file.activeQuickHint2 = CreateFullscreenRui( $"ui/wraith_comms_hint.rpak" )

	RuiSetGameTime( file.activeQuickHint2, "startTime", Time() )
	RuiSetGameTime( file.activeQuickHint2, "endTime", 9999999 )
	RuiSetBool( file.activeQuickHint2, "commsMenuOpen", false )
	RuiSetString( file.activeQuickHint2, "msg", hintText )
}