untyped

global function  Cl_ChallengesByColombia_Init

//Main menu and results UI
global function ServerCallback_SetDefaultMenuSettings
global function ServerCallback_OpenFRChallengesMenu
global function ServerCallback_OpenFRChallengesSettings
global function ServerCallback_OpenFRChallengesMainMenu
global function ServerCallback_OpenFRChallengesHistory
global function ServerCallback_CloseFRChallengesResults

//History
global function ServerCallback_HistoryUIAddNewChallenge

//Stats UI
global function ServerCallback_LiveStatsUIDummiesKilled
global function ServerCallback_LiveStatsUIAccuracyViaTotalShots
global function ServerCallback_LiveStatsUIAccuracyViaShotsHits
global function ServerCallback_LiveStatsUIDamageViaWeaponAttack
global function ServerCallback_LiveStatsUIDamageViaDummieDamaged
global function ServerCallback_LiveStatsUIHeadshot
global function ServerCallback_ResetLiveStatsUI
global function ServerCallback_CoolCameraOnMenu
global function ServerCallback_RestartChallenge
global function ServerCallback_CreateDistanceMarkerForGrenadesChallengeDummies
global function ServerCallback_ToggleDotForHitscanWeapons
global function ServerCallback_SetChallengeActivated
global function RefreshChallengeActivated

//Main menu buttons
global function StartChallenge1Client
global function StartChallenge2Client
global function StartChallenge3Client
global function StartChallenge4Client
global function StartChallenge5Client
global function StartChallenge6Client
global function StartChallenge7Client
global function StartChallenge8Client
global function StartChallenge1NewCClient
global function StartChallenge2NewCClient
global function StartChallenge3NewCClient
global function StartChallenge4NewCClient
global function StartChallenge5NewCClient
global function StartChallenge6NewCClient
global function StartChallenge7NewCClient
global function StartChallenge8NewCClient
global function StartChallenge9NewCClient
global function SkipButtonResultsClient
global function RestartButtonResultsClient

global function StartPatternTrackingScenarioClient
global function StartBouncingTrackingScenarioClient
global function StartMultiBallHealthTrackingClient
global function StartRandomSpeedTrackingClient
global function StartAntiMirrorStrafingClient
global function StartMirrorStrafingClient
global function StartPopcornPhysicsClient

// Kovaaks Scenarios Client Functions
global function Start1Wall6TargetsClient
global function StartCloseLongStrafesClient
global function StartTileFrenzyStrafingClient

//Settings
global function ChangeChallengeDurationClient
global function ChangeAimTrainer_AI_SHIELDS_LEVELClient
global function ChangeAimTrainer_AI_DUMMIES_COLORClient
global function ChangeAimTrainer_STRAFING_SPEEDClient
global function ChangeAimTrainer_AI_HEALTH
global function ChangeAimTrainer_AI_SPAWN_DISTANCE
global function ChangeRGB_HUDClient
global function ChangeAimTrainer_INFINITE_CHALLENGEClient
global function ChangeAimTrainer_INFINITE_AMMOClient
global function ChangeAimTrainer_INFINITE_AMMO2Client
global function ChangeAimTrainer_INMORTAL_TARGETSClient
global function ChangeAimTrainer_USER_WANNA_BE_A_DUMMYClient
global function UIToClient_MenuGiveWeapon
global function UIToClient_MenuGiveWeaponWithAttachments
global function OpenFRChallengesSettingsWpnSelector
global function CloseFRChallengesSettingsWpnSelector
global function ExitChallengeClient
global function WeaponSelectorClose
global function ClientLocalizeAndShortenNumber_Float
global function AimTrainer_QuickHint
global function StartUpdatingArmorSwapLastTime

global function SetWeaponSlot
global function CoolCameraOnMenu
global function ActuallyPutDefaultSettings

global function AimTrainer_LootRollerDamageRgb
global function AimTrainer_SetPatstrafeHudValues
global function CL_AimTrainer_RegisterNetworkFunctions

string DesiredSlot = "p"
bool EPIC_CAMERA_ENABLED = true //Toggle between old hardcoded camera and new epic exploration camera

struct{
	int totalShots
	int ShotsHits
	int damageDone
	int damagePossible
	var dot
	bool challengeActivatedLastValue = false
	
	//deathboxes
	float lastTime
	float bestTime
	float averageTime
	array<float> armorSwapTimes
	
	var activeQuickHint
	
	int dummiesKilled
	bool isInMainMenu
} file

global struct CameraLocationPair
{
    vector origin = <0, 0, 0>
    vector angles = <0, 0, 0>
}

global struct CinematicPath
{
	vector startPos = <0, 0, 0>
	vector endPos = <0, 0, 0>
	vector startAngles = <0, 0, 0>
	vector endAngles = <0, 0, 0>
	float duration = 8.0
	float fovStart = 100.0
	float fovEnd = 100.0
	int curveType = 0 //0=linear, 1=ease-in-out, 2=dramatic
	bool enableBanking = true
}

global struct DynamicCameraState
{
	vector position = <0, 0, 0>
	vector angles = <0, 0, 0>
	vector velocity = <0, 0, 0>
	vector targetPosition = <0, 0, 0>
	float speed = 200.0
	float fov = 100.0
	int explorationMode = 0 //0=traveling, 1=exploring, 2=investigating
	float modeTimer = 0.0
}

global struct ExplorationPoint
{
	vector position = <0, 0, 0>
	float interestLevel = 1.0
	float lastVisitTime = 0.0
	int visitCount = 0
	bool isUnderground = false
	bool isBuilding = false
	bool isScenic = false
}

void function Cl_ChallengesByColombia_Init()
{
	//Increase client command limit to 60
	SetConVarInt("cl_quota_stringCmdsPerSecond", 60)
	
	//main menu cameras thread end signal
	RegisterSignal("ChallengeStartRemoveCameras")
	RegisterSignal("StopArmorSwapStopwatch")
	//laser sight particle
	PrecacheParticleSystem($"P_wpn_lasercannon_aim_short_blue") 
	
	//2.0
	AddCreateCallback( "script_mover", AimTrainer_LootRollerSpawned )
	AddCreateCallback( "script_mover", AimTrainer_HealthBarSpawned )
	AddDestroyCallback( "script_mover", AimTrainer_HealthBar_OnDestroy )
	AddCreateCallback( "prop_physics", AimTrainer_LootRollerSpawned )
	AddCreateCallback( "prop_physics", AimTrainer_HealthBarSpawned )
	AddDestroyCallback( "prop_physics", AimTrainer_HealthBar_OnDestroy )
	
	AddCallback_EntitiesDidLoad( AimTrainer_OnEntitiesDidLoad )
	
	PrecacheParticleSystem( LOOT_ROLLER_EYE_FX )
	RegisterSignal( "RestartDamageRGB" )
	
	SetConVarFloat( "mat_sun_scale", 0.0 )
	
	AddCallback_UIScriptReset( Client_UIScriptReset )
}

void function CL_AimTrainer_RegisterNetworkFunctions()
{
	if ( IsLobby() )
		return
	
	RegisterNetworkedVariableChangeCallback_bool( "FS_PlayerIsMnk", FS_InputChanged )
}

void function Client_UIScriptReset()
{
	if( file.isInMainMenu )
	{
		entity player = GetLocalClientPlayer()
		thread CoolCameraOnMenu()
		DoF_SetFarDepth( 6000, 10000 )
		RunUIScript( "OpenFRChallengesMainMenu", file.dummiesKilled)
	}
}

table<entity, array<int> > ballFxs //each entity has its own array of fx

// Health bars for aim trainer targets - always visible
table<entity, entity> AimTrainer_TargetHealthBars

void function FS_InputChanged( entity player, bool old, bool new, bool actuallyChanged )
{
	entity localPlayer = GetLocalClientPlayer()
	
	if( player != localPlayer )
		return
	
	if( new )
		MG_MovementOverlay_toggle( true )
	else
		MG_MovementOverlay_toggle( false )
}

void function AimTrainer_LootRollerSpawned( entity ball )
{
	if ( ball.GetModelName() != $"mdl/props/loot_sphere/loot_sphere.rmdl" )
		return
	
	// Initialize array for this entity if it doesn't exist
	if ( !(ball in ballFxs) )
		ballFxs[ball] <- []
	
	int fxIdx = GetParticleSystemIndex( LOOT_ROLLER_EYE_FX )
	for( int i; i < NUM_LOOT_ROLLER_FX_ATTACH_POINTS; i++ )
	{
		int suffixIdx = i + 1
		string attachSuffix = string( suffixIdx )
		int attachIdx = ball.LookupAttachment( FX_ATTACH_ROOT_NAME + attachSuffix )
		int newFx = StartParticleEffectOnEntity( ball, fxIdx, FX_PATTACH_POINT_FOLLOW, attachIdx )
		ballFxs[ball].append( newFx )
		EffectSetControlPointColorById( newFx, 1, COLORID_FX_LOOT_TIER1 ) //RandomIntRangeInclusive( 50, 54 )
	}
}

void function AimTrainer_HealthBarSpawned( entity target )
{
	if ( target.GetModelName() != AIMTRAINER_TRACKING_MODEL )
		return
	
	// Only create health bars for targets with health > 0
	if ( target.GetMaxHealth() <= 0 )
	{
		// printw("[HEALTHBAR] Target spawned but has no health - MaxHealth:", target.GetMaxHealth())
		return
	}
		
	// printw("[HEALTHBAR] Creating health bar for target - MaxHealth:", target.GetMaxHealth(), "Current Health:", target.GetHealth())
	AimTrainer_StartHealthBarForTarget( target )
}

void function AimTrainer_HealthBar_OnDestroy( entity target )
{
	if ( target.GetModelName() != AIMTRAINER_TRACKING_MODEL )
		return
		
	// printw("[HEALTHBAR] Target destroyed, cleaning up health bar")
	AimTrainer_DestroyHealthBar( target )
}

void function AimTrainer_StartHealthBarForTarget( entity target )
{
	if( !IsValid(target) )
	{
		// printw("[HEALTHBAR] Cannot start health bar - target is invalid")
		return
	}
		
	if( !( target in AimTrainer_TargetHealthBars ) )
	{
		entity vgui = CreateClientsideVGuiScreen( "flowstate_health_bar", VGUI_SCREEN_PASS_WORLD, <0, 0, 0>, <0, 0, 0>, 8, 90 )
		vgui.kv.fadedist = 9999
		AimTrainer_TargetHealthBars[target] <- vgui
	}
		
	AimTrainer_CreateHealthBarForTarget( target )
}

void function AimTrainer_CreateHealthBarForTarget( entity target )
{
	entity vgui = AimTrainer_TargetHealthBars[target]
	
	// vgui.SetParent( target )
	// printw("[HEALTHBAR] Set VGui parent and starting health bar threads")
	thread AimTrainer_HealthBar_Think( target, vgui )
	thread AimTrainer_HealthBar_UpdateAngles( target, vgui )
}

void function AimTrainer_HealthBar_Think( entity target, entity vgui )
{
	EndSignal( target, "OnDestroy" )
	
	// printw("[HEALTHBAR] Starting health bar think thread")
	
	local foreground = HudElement( "ShieldsHealthBar_Foreground2", vgui.GetPanel() )// "HealthBar_Foreground", vgui.GetPanel() )
	local background = HudElement( "HealthBar_Background", vgui.GetPanel() )
	
	// printw("[HEALTHBAR] Got HUD elements - Foreground valid:", IsValid(foreground), "Background valid:", IsValid(background))
	
	local foregroundOg = HudElement( "HealthBar_Foreground", vgui.GetPanel() )
	foregroundOg.Hide()
	
	// Always show and position the health bar elements
	foreground.Show()
	background.Show()
	
	// We don't use shields here
	array< var > shields
	for( int i = 0; i<5; i++ )
		shields.append( HudElement( "ShieldsHealthBar_Foreground" + i, vgui.GetPanel() ) )
	
	foreach( shieldElement in shields )
	{
		shieldElement.Hide()
	}
	
	Hud_SetPos( foreground, 0, 0)
	Hud_SetPos( background, 0, 0)
	
	int frameCounter = 0
	
	// printw("[HEALTHBAR] Initial setup complete, starting update loop")
	
	while( true )
	{
		wait 0.01  // Use simple polling instead of signal wait
		frameCounter++
		
		if( !IsValid( target ) || !IsValid( vgui ) )
		{
			// printw("[HEALTHBAR] Target or VGui became invalid, breaking loop")
			break
		}
			
		if( !IsAlive( target ) )
		{
			if(frameCounter % 50 == 0)  // Debug every 5 seconds
				// printw("[HEALTHBAR] Target is not alive, hiding health bar")
			foreground.Hide()
			background.Hide()
			continue
		}
		
		// Always show and update health bar with proper calculation
		foreground.Show()
		background.Show()
		
		int baseHeight = 150  // Actually visual width
		int baseWidth = 500   // Actually visual height
		
		// Apply scaling to both elements
		background.SetHeight( baseHeight )
		background.SetWidth( baseWidth )
		
		// Calculate health percentage and apply to foreground
		int health = target.GetHealth()
		int maxHealth = target.GetMaxHealth()
		float healthWidth = float( health * baseHeight) / maxHealth
		foreground.SetHeight( healthWidth )
		foreground.SetWidth( baseWidth )
	}
	
	// printw("[HEALTHBAR] Health bar think thread ended")
}

void function AimTrainer_HealthBar_UpdateAngles( entity target, entity vgui )
{
	EndSignal( target, "OnDestroy" )
	
	while( true )
	{
		WaitFrame()
		
		if( !IsValid( target ) || !IsValid( vgui ) )
			break
		
		// Position above target and to the right from player's perspective
		vector playerRight = AnglesToRight(GetLocalViewPlayer().CameraAngles())
		float rightOffset = 53.0  // Distance to the right from player's view
		float heightOffset = 60.0  // Height above target
		
		vector healthBarPos = target.GetOrigin() + <0, 0, heightOffset> + (playerRight * rightOffset)
		vgui.SetOrigin( healthBarPos )
		
		// Keep horizontal - only adjust Y angle to face player
		vector closestPoint = GetClosestPointOnLine( GetLocalViewPlayer().CameraPosition(), 
			GetLocalViewPlayer().CameraPosition() + (AnglesToRight( GetLocalViewPlayer().CameraAngles() ) * 100.0), vgui.GetOrigin() )
		vector angles = VectorToAngles( vgui.GetOrigin() - closestPoint )
		vgui.SetAngles( Vector( -90, angles.y, 0 ) )  // Keep horizontal: X=0, only Y for facing, Z=0
	}
}

void function AimTrainer_DestroyHealthBar( entity target )
{
	if( !IsValid( target ) )
		return
		
	if( target in AimTrainer_TargetHealthBars )
	{
		target.Signal( "StopShowingHealthbars" )
		
		if( IsValid( AimTrainer_TargetHealthBars[target] ) )
			AimTrainer_TargetHealthBars[target].Destroy()
		delete AimTrainer_TargetHealthBars[target]
	}
}

void function AimTrainer_LootRollerDamageRgb(entity ball)
{
	thread function () : (ball)
	{
		if( !IsValid( ball ) )
			return
		
		EndSignal( ball, "OnDestroy" )
		Signal( ball, "RestartDamageRGB" )
		EndSignal( ball, "RestartDamageRGB" )
		
		float endtime = Time() + 0.1
		
		OnThreadEnd(
			function() : ( ball )
			{
				if( ball in ballFxs )
				{
					foreach( fx in ballFxs[ball]) 
						EffectSetControlPointColorById( fx, 1, COLORID_FX_LOOT_TIER1 )
				}
			}
		
		)
		while( Time() < endtime )
		{
			if( ball in ballFxs )
			{
				foreach( fx in ballFxs[ball]) 
					EffectSetControlPointColorById( fx, 1, COLORID_FX_LOOT_TIER5 ) //RandomIntRangeInclusive( 50, 54 ) )
			}
			
			wait 0.1
		}
	}()
}

void function AimTrainer_QuickHint( string hintText, bool blueText = false, int duration = 99)
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

void function SetWeaponSlot(int slot)
{
	entity player = GetLocalClientPlayer()
	switch(slot)
	{
		case 1:
			DesiredSlot = "p"
			break
		case 2:
			DesiredSlot = "s"
			break
		default:
			DesiredSlot = "p"
			break
	}
	
	player.ClientCommand("CC_AimTrainer_SelectWeaponSlot " + DesiredSlot)
}

void function WeaponSelectorClose()
{
	entity player = GetLocalClientPlayer()
	player.ClientCommand("CC_AimTrainer_WeaponSelectorClose")
}

void function AimTrainer_OnEntitiesDidLoad()
{
	ActuallyPutDefaultSettings()
	
	//Disables Sun Flare
	array<entity> fxEnts = GetClientEntArrayBySignifier( "info_particle_system" )
	foreach ( fxEnt in fxEnts )
	{
		if ( fxEnt.HasKey( "in_skybox" ) && fxEnt.GetValueForKey("in_skybox") == "0" )
			continue

		fxEnt.Destroy()
	}
}

void function ServerCallback_SetDefaultMenuSettings()
{
	thread ActuallyPutDefaultSettings()
}

void function ActuallyPutDefaultSettings()
{
	entity player = GetLocalClientPlayer()
	EndSignal( player, "OnDestroy" )

	player.ClientCommand("CC_AimTrainer_AI_SHIELDS_LEVEL " + GetConVarInt("fs_aimtrainer_dummies_shield").tostring())

	float speed
	switch( GetConVarInt("fs_aimtrainer_dummies_speed_selector") )
	{
		case 0:
			speed = 0
			break
		case 1:
			speed = 0.85
			break
		case 2:
			speed = 1
			break
		case 3:
			speed = 1.35
			break
		case 4:
			speed = 1.8
			break
	}
	player.ClientCommand("CC_AimTrainer_STRAFING_SPEED " + speed)
	player.ClientCommand("CC_RGB_HUD " + GetConVarInt("fs_aimtrainer_rgb_hud").tostring())
	player.ClientCommand("CC_AimTrainer_INFINITE_CHALLENGE " + GetConVarInt("fs_aimtrainer_infinite_training").tostring())
	player.ClientCommand("CC_AimTrainer_INFINITE_AMMO " + GetConVarInt("fs_aimtrainer_infinite_ammo").tostring())
	player.ClientCommand("CC_AimTrainer_INFINITE_AMMO2 " + GetConVarInt("fs_aimtrainer_autoreload_on_kill").tostring())	
	player.ClientCommand("CC_AimTrainer_INMORTAL_TARGETS " + GetConVarInt("fs_aimtrainer_dummies_are_inmortal").tostring())
	player.ClientCommand("CC_AimTrainer_USER_WANNA_BE_A_DUMMY " + GetConVarInt("fs_aimtrainer_use_dummy_model").tostring())
	player.ClientCommand("CC_AimTrainer_SPAWN_DISTANCE " + GetConVarInt("fs_aimtrainer_dummies_spawn_distance").tostring())		
	player.ClientCommand("CC_AimTrainer_AI_HEALTH " + GetConVarInt("fs_aimtrainer_dummies_health").tostring())
	player.ClientCommand("CC_AimTrainer_DUMMIES_COLOR " + GetConVarInt("fs_aimtrainer_dummies_color").tostring())
}


string function ReturnChallengeName(int index)
{
	string final
	switch(index){
		case 1:
			final = "STRAFING DUMMY"
			break		
		case 2:
			final = "TARGET SWITCHING"
			break
		case 3:
			final = "FLOATING TARGET"
			break
		case 4:
			final = "POPCORN TARGETS"
			break
		case 6:
			final = "FAST JUMPS STRAFES"
			break
		case 7:
			final = "ARC STARS PRACTICE"
			break
		case 8:
			final = "SHOOTING FROM LIFT"
			break
		case 9:
			final = "SHOOTING VALK'S ULT"
			break
		case 10:
			final = "TILE FRENZY"
			break
		case 11:
			final = "CLOSE FAST STRAFES"
			break
		case 12:
			final = "SMOOTHBOT"
			break
		case 13:
			final = "BOUNCES SIMULATOR"
			break
		case 14:
			final = "GRENADES PRACTICE"
			break
		case 15:
			final = "SKYDIVING TARGETS"
			break
		case 16:
			final = "RUNNING TARGETS"
			break
		case 17:
			final = "ARMOR SWAP"
			break
		case 18:
			final = "DROPSHIP DRILL"
			break
		case 0:
		default: 
			final = "CHALLENGE RESULTS"
	}
	return final
}

void function ServerCallback_OpenFRChallengesMenu(int challengeName, int shothits, int dummieskilled, float accuracy, int damagedone, int criticalshots, int shotshitrecord, bool isNewRecord)
{	
	string actualChallengeName = ReturnChallengeName(challengeName)
	DisableLiveStatsUI()
    RunUIScript( "UpdateResultsData", actualChallengeName, shothits, dummieskilled, accuracy, damagedone, criticalshots, shotshitrecord, isNewRecord )
	RunUIScript( "OpenFRChallengesMenu" )

    // thread UpdateUIRespawnTimer()
}

void function ServerCallback_OpenFRChallengesMainMenu(int dummiesKilled)
{
	entity player = GetLocalClientPlayer()
	RunUIScript( "OpenFRChallengesMainMenu", dummiesKilled)
	
	file.dummiesKilled = dummiesKilled
	file.isInMainMenu = true
}

void function ServerCallback_OpenFRChallengesHistory(int dummiesKilled)
{
	entity player = GetLocalClientPlayer()
	RunUIScript( "OpenFRChallengesHistory", dummiesKilled)
}

void function ServerCallback_OpenFRChallengesSettings()
{
	RunUIScript( "OpenFRChallengesSettings" )
}

void function ServerCallback_CloseFRChallengesResults()
{
	RunUIScript( "CloseFRChallengesMainMenu" )
}

void function ServerCallback_HistoryUIAddNewChallenge(int NameInt, int Score, entity Weapon, float Accuracy, int dummiesKilled, int Damage, int totalshots, int criticalshots)
{
	if(!IsValid(Weapon)) 
		return
	RunUIScript( "HistoryUI_AddNewChallenge", ReturnChallengeName(NameInt), Score, Weapon.GetWeaponClassName(), Accuracy, dummiesKilled, Damage, totalshots, criticalshots, AimTrainer_CHALLENGE_DURATION)
}

void function ServerCallback_LiveStatsUIDummiesKilled(int dummieskilled)
{
	Hud_SetText( HudElement( "ChallengesDummieskilledValue"), dummieskilled.tostring())
}

void function ServerCallback_LiveStatsUIAccuracyViaTotalShots(int pellets)
{
	file.totalShots += (1*pellets)
	float accuracy = float(file.ShotsHits)/float(file.totalShots)
	
	string final = file.ShotsHits.tostring() + "/" +  file.totalShots.tostring() + " | " + ClientLocalizeAndShortenNumber_Float(accuracy * 100, 3, 2) + "%"
	Hud_SetText( HudElement( "ChallengesAccuracyValue"), final.tostring())
}
void function ServerCallback_LiveStatsUIAccuracyViaShotsHits()
{
	file.ShotsHits++
	float accuracy = float(file.ShotsHits)/float(file.totalShots)
	
	string final = file.ShotsHits.tostring() + "/" +  file.totalShots.tostring() + " | " + ClientLocalizeAndShortenNumber_Float(accuracy * 100, 3, 2) + "%"
	Hud_SetText( HudElement( "ChallengesAccuracyValue"), final.tostring())
}

void function ServerCallback_LiveStatsUIDamageViaWeaponAttack(int damage, float damagePossible)
{
	file.damagePossible += int(damagePossible)
	float damageRatio = float(file.damageDone)/float(file.damagePossible)
	
	string final = file.damageDone.tostring() + "/" +  file.damagePossible.tostring() + " | " + ClientLocalizeAndShortenNumber_Float(damageRatio * 100, 3, 2) + "%"
	Hud_SetText( HudElement( "ChallengesDamageValue"), final.tostring())
}

void function ServerCallback_LiveStatsUIDamageViaDummieDamaged(int damage)
{
	file.damageDone += damage
	float damageRatio = float(file.damageDone)/float(file.damagePossible)
	
	string final = file.damageDone.tostring() + "/" +  file.damagePossible.tostring() + " | " + ClientLocalizeAndShortenNumber_Float(damageRatio * 100, 3, 2) + "%"
	Hud_SetText( HudElement( "ChallengesDamageValue"), final.tostring())
}

void function ServerCallback_LiveStatsUIHeadshot(int headshots)
{
	Hud_SetText( HudElement( "ChallengesHeadshotsValue"), headshots.tostring())
}

void function ServerCallback_CoolCameraOnMenu()
{
    thread CoolCameraOnMenu()
}

CameraLocationPair function NewCameraPair(vector origin, vector angles)
{
    CameraLocationPair locPair
    locPair.origin = origin
    locPair.angles = angles

    return locPair
}

CinematicPath function NewCinematicPath(vector startPos, vector endPos, vector startAngles, vector endAngles, float duration = 8.0, int curveType = 1, float fovStart = 100.0, float fovEnd = 100.0)
{
	CinematicPath path
	path.startPos = startPos
	path.endPos = endPos
	path.startAngles = startAngles
	path.endAngles = endAngles
	path.duration = duration
	path.curveType = curveType
	path.fovStart = fovStart
	path.fovEnd = fovEnd
	path.enableBanking = true
	return path
}

float function EaseInOutCubic(float t)
{
	return t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2
}

float function EaseInOutQuart(float t)
{
	return t < 0.5 ? 8 * t * t * t * t : 1 - pow(-2 * t + 2, 4) / 2
}

float function DramaticCurve(float t)
{
	//Slow start, fast middle, smooth end
	float phase1 = 0.15
	float phase2 = 0.85
	
	if(t < phase1)
		return pow(t / phase1, 2) * 0.1
	else if(t < phase2)
		return 0.1 + (t - phase1) * 0.8 / (phase2 - phase1)
	else
		return 0.9 + pow((t - phase2) / (1 - phase2), 0.5) * 0.1
		
	unreachable
}

vector function InterpolatePosition(CinematicPath path, float t)
{
	float curveT = t
	
	switch(path.curveType)
	{
		case 0: //Linear
			break
		case 1: //Ease-in-out
			curveT = EaseInOutCubic(t)
			break
		case 2: //Dramatic
			curveT = DramaticCurve(t)
			break
	}
	
	return path.startPos + (path.endPos - path.startPos) * curveT
}

vector function InterpolateAngles(CinematicPath path, float t)
{
	float curveT = t
	
	switch(path.curveType)
	{
		case 0: //Linear
			break
		case 1: //Ease-in-out
			curveT = EaseInOutCubic(t)
			break
		case 2: //Dramatic
			curveT = DramaticCurve(t)
			break
	}
	
	//Add banking based on movement direction
	vector baseAngles = path.startAngles + (path.endAngles - path.startAngles) * curveT
	
	if(path.enableBanking)
	{
		vector movement = path.endPos - path.startPos
		float bankingAmount = sin(t * PI) * 15.0 //Banking peaks at middle of movement
		
		if(movement.y > 0) //Moving in positive Y direction
			baseAngles.z += bankingAmount
		else if(movement.y < 0) //Moving in negative Y direction
			baseAngles.z -= bankingAmount
	}
	
	return baseAngles
}

float function InterpolateFOV(CinematicPath path, float t)
{
	return path.fovStart + (path.fovEnd - path.fovStart) * EaseInOutCubic(t)
}

//Dynamic Camera System Helper Functions
bool function IsObstacleInDirection(vector fromPos, vector direction, float distance)
{
	TraceResults trace = TraceLine(fromPos, fromPos + direction * distance, null, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE)
	return trace.fraction < 1.0
}

vector function GetAvoidanceDirection(vector currentPos, vector targetDir, float checkDistance)
{
	//Check multiple directions to find best path
	array<vector> directions = [
		targetDir,
		targetDir + <0, 0, 100>, //Up
		targetDir + <0, 0, -50>, //Down
		targetDir + AnglesToRight(<0, 45, 0>) * 100, //Right
		targetDir + AnglesToRight(<0, -45, 0>) * 100, //Left
		targetDir + AnglesToForward(<0, 30, 0>) * 100, //Right-forward
		targetDir + AnglesToForward(<0, -30, 0>) * 100  //Left-forward
	]
	
	foreach(dir in directions)
	{
		if(!IsObstacleInDirection(currentPos, Normalize(dir), checkDistance))
			return Normalize(dir)
	}
	
	//If all directions blocked, try going up
	return <0, 0, 1>
}

vector function GenerateRandomExplorationTarget(vector currentPos, float minDistance, float maxDistance)
{
	//Generate random target within map bounds
	float angle = RandomFloatRange(0.0, 360.0)
	float distance = RandomFloatRange(minDistance, maxDistance)
	float height = RandomFloatRange(-1000.0, 1000.0)
	
	vector dir = AnglesToForward(<0, angle, 0>)
	vector newTarget = currentPos + dir * distance + <0, 0, height>
	
	//Ensure target is not underground (basic check)
	if(newTarget.z < currentPos.z - 2000)
		newTarget.z = currentPos.z - 500
	
	return newTarget
}

float function CalculateInterestLevel(vector position)
{
	float interest = 1.0
	
	//Higher interest for elevated positions
	if(position.z > 0)
		interest += position.z / 1000.0
	
	//Check if near buildings (simplified)
	TraceResults traceDown = TraceLine(position, position + <0, 0, -500>, null, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE)
	if(traceDown.fraction < 0.8)
		interest += 0.5 //Near structures
	
	return interest
}

vector function SmoothVelocityToTarget(vector currentPos, vector targetPos, vector currentVel, float maxSpeed, float smoothing)
{
	vector toTarget = targetPos - currentPos
	float distance = Length(toTarget)
	
	if(distance < 50.0)
		return currentVel * 0.5 //Slow down when close
	
	vector desiredVel = Normalize(toTarget) * maxSpeed
	return currentVel + (desiredVel - currentVel) * smoothing
}

vector function CalculateDynamicAngles(vector position, vector velocity, int explorationMode)
{
	vector angles = VectorToAngles(velocity)
	
	switch(explorationMode)
	{
		case 0: //Traveling - look more downward
			angles.x = max(angles.x, -45.0)
			angles.x = min(angles.x, -15.0)
			break
		case 1: //Exploring - moderate downward look
			angles.x = max(angles.x, -30.0)
			angles.x = min(angles.x, -5.0)
			break
		case 2: //Investigating - look around more
			angles.x += sin(Time() * 2.0) * 10.0
			angles.y += cos(Time() * 1.5) * 5.0
			break
	}
	
	return angles
}

//Smart Location Management Functions
float function CalculateDistance(vector pos1, vector pos2)
{
	return Length(pos2 - pos1)
}

array<CameraLocationPair> function SortLocationsByDistance(array<CameraLocationPair> locations, vector fromPosition, array<int> visitedIndices)
{
	array<CameraLocationPair> unvisited
	array<float> distances
	array<int> originalIndices
	
	//Get unvisited locations
	for(int i = 0; i < locations.len(); i++)
	{
		bool isVisited = false
		foreach(visitedIndex in visitedIndices)
		{
			if(visitedIndex == i)
			{
				isVisited = true
				break
			}
		}
		
		if(!isVisited)
		{
			unvisited.append(locations[i])
			distances.append(CalculateDistance(fromPosition, locations[i].origin))
			originalIndices.append(i)
		}
	}
	
	//Sort by distance (bubble sort for simplicity)
	for(int i = 0; i < distances.len() - 1; i++)
	{
		for(int j = 0; j < distances.len() - i - 1; j++)
		{
			if(distances[j] > distances[j + 1])
			{
				//Swap distances
				float tempDist = distances[j]
				distances[j] = distances[j + 1]
				distances[j + 1] = tempDist
				
				//Swap locations
				CameraLocationPair tempLoc = unvisited[j]
				unvisited[j] = unvisited[j + 1]
				unvisited[j + 1] = tempLoc
				
				//Swap indices
				int tempIndex = originalIndices[j]
				originalIndices[j] = originalIndices[j + 1]
				originalIndices[j + 1] = tempIndex
			}
		}
	}
	
	return unvisited
}

int function FindLocationIndex(array<CameraLocationPair> allLocations, CameraLocationPair targetLocation)
{
	for(int i = 0; i < allLocations.len(); i++)
	{
		if(allLocations[i].origin.x == targetLocation.origin.x && 
		   allLocations[i].origin.y == targetLocation.origin.y && 
		   allLocations[i].origin.z == targetLocation.origin.z)
		{
			return i
		}
	}
	return -1
}

//Arc-Based Flight System
float function CalculateArcHeight(vector startPos, vector endPos, int mapId)
{
	float distance = CalculateDistance(startPos, endPos)
	float baseHeight = 1000.0 //Base clearance
	
	//Map-specific height adjustments
	switch(mapId)
	{
		case eMaps.mp_rr_desertlands_64k_x_64k:
		case eMaps.mp_rr_desertlands_64k_x_64k_nx:
		case eMaps.mp_rr_desertlands_64k_x_64k_tt:
		case eMaps.mp_rr_desertlands_mu1:
		case eMaps.mp_rr_desertlands_mu1_tt:
		case eMaps.mp_rr_desertlands_mu2:
		case eMaps.mp_rr_desertlands_holiday:
			baseHeight = 1200.0 //Kings Canyon has tall mountains
			break
		case eMaps.mp_rr_canyonlands_mu1:
		case eMaps.mp_rr_canyonlands_mu1_night:
		case eMaps.mp_rr_canyonlands_64k_x_64k:
		case eMaps.mp_rr_canyonlands_mu2:
		case eMaps.mp_rr_canyonlands_mu2_tt:
		case eMaps.mp_rr_canyonlands_mu2_mv:
		case eMaps.mp_rr_canyonlands_mu2_ufo:
			baseHeight = 1000.0 //Kings Canyon S2 moderate terrain
			break
		case eMaps.mp_rr_arena_empty:
		case eMaps.mp_rr_canyonlands_staging:
			baseHeight = 1500.0 //World's Edge has very tall structures
			break
		case eMaps.mp_rr_olympus:
		case eMaps.mp_rr_olympus_tt:
			baseHeight = 1300.0 //Olympus has tall buildings
			break
		default:
			baseHeight = 1000.0
			break
	}
	
	//Distance-based scaling
	float arcHeight = baseHeight + (distance / 3.0)
	
	//Ensure minimum and maximum heights
	if(arcHeight < 800.0)
		arcHeight = 800.0
	if(arcHeight > 2500.0)
		arcHeight = 2500.0
	
	return arcHeight
}

vector function InterpolateArcPosition(vector startPos, vector endPos, float t, float arcHeight)
{
	//Use ease-in-out curve for smoother position interpolation
	float easedT = EaseInOutCubic(t)
	vector linearPos = startPos + (endPos - startPos) * easedT
	
	//Calculate arc height using modified parabolic formula with smoother ending
	//Height peaks at t=0.5, goes to 0 at t=0 and t=1
	float heightMultiplier = 4.0 * t * (1.0 - t) //Parabolic curve
	
	//Add extra smoothing at the end for better arrival
	if(t > 0.8)
	{
		float endT = (t - 0.8) / 0.2 //Normalize last 20% to 0-1
		heightMultiplier *= (1.0 - (endT * endT)) //Smooth fade to zero
	}
	
	float currentArcHeight = heightMultiplier * arcHeight
	
	//Add arc height to linear position
	return linearPos + <0, 0, currentArcHeight>
}

vector function CalculateArcAngles(vector startAngles, vector currentActualAngles, vector endAngles, vector currentPos, vector nextPos, float t)
{
	//Three-phase angle system for smooth transitions
	vector groundAngles = <35.0, startAngles.y, 0>
	
	if(t < 0.2)
	{
		//Phase 1: Smooth transition from current angles to ground-looking angles (0-20%)
		float phaseT = t / 0.2 //Normalize to 0-1 for first 20%
		
		//Smooth interpolation from start to end angles
		vector angles = startAngles + (groundAngles - startAngles) * EaseInOutCubic(phaseT)
		
		//Add slight banking based on movement direction
		vector velocity = nextPos - currentPos
		if(Length(velocity) > 0)
		{
			vector normalized = Normalize(velocity)
			angles.z = normalized.y * 6.0 * phaseT //Gradually add banking
		}
		
		return angles
	}
	else if(t < 0.7)
	{
	  //Phase 2: Stable ground-viewing phase (20-70%)
	  vector angles = groundAngles//currentActualAngles

	  //Maintain consistent banking during stable viewing
	  vector velocity = nextPos - currentPos
	  if(Length(velocity) > 0)
	  {
		vector normalized = Normalize(velocity)
		angles.z = normalized.y * 8.0 //Full banking during stable flight
	  }

	  return angles
	}
	else
	{
		//Phase 3: Smooth transition from ground-looking to destination angles (70-100%)
		float phaseT = (t - 0.7) / 0.3 //Normalize to 0-1 for last 30%
		
		//Smooth transition to destination angles
		vector angles = groundAngles + (endAngles - groundAngles) * EaseInOutCubic(phaseT)
		
		//Gradually reduce banking as we approach destination
		vector velocity = nextPos - currentPos
		if(Length(velocity) > 0)
		{
			vector normalized = Normalize(velocity)
			angles.z = normalized.y * 8.0 * (1.0 - phaseT) //Reduce banking towards destination
		}
		
		return angles
	}
	
	unreachable
}

void function EpicCinematicCamera()
{
	entity player = GetLocalClientPlayer()
	player.EndSignal("ChallengeStartRemoveCameras")
	array<CameraLocationPair> cutsceneSpawns
	array<int> visitedLocations
	
	if(!IsValid(player)) return
	
	//Use original cutscene spawn locations for each map
	switch( MapName() )
	{
		case eMaps.mp_rr_desertlands_64k_x_64k:
		case eMaps.mp_rr_desertlands_64k_x_64k_nx:
		case eMaps.mp_rr_desertlands_64k_x_64k_tt:
		case eMaps.mp_rr_desertlands_mu1:
		case eMaps.mp_rr_desertlands_mu1_tt:
		case eMaps.mp_rr_desertlands_mu2:
		case eMaps.mp_rr_desertlands_holiday:
			cutsceneSpawns.append(NewCameraPair(<10881.2295, 5903.09863, -3176.7959>, <0, -143.321213, 0>)) 
			cutsceneSpawns.append(NewCameraPair(<9586.79199, 24404.5898, -2019.6366>, <0, -52.6216431, 0>)) 
			cutsceneSpawns.append(NewCameraPair(<630.249573, 13375.9219, -2736.71948>, <0, -43.2706299, 0>))
			cutsceneSpawns.append(NewCameraPair(<16346.3076, -34468.9492, -1109.32153>, <0, -44.3879509, 0>))
			cutsceneSpawns.append(NewCameraPair(<1133.25562, -20102.9648, -2488.08252>, <0, -24.9140873, 0>))
			cutsceneSpawns.append(NewCameraPair(<17434.8613, 31441.5469, -3287.58472> , <0, -73.2149734, 0>))
			cutsceneSpawns.append(NewCameraPair(<-15754.7705, 28475.4199, -1825.63904> , <0, -33.5749741, 0>))
			cutsceneSpawns.append(NewCameraPair(<-26765.0313, 12633.0166, -2310.10376> , <0, -122.493965, 0>))
			cutsceneSpawns.append(NewCameraPair(<-20192.2207, 14467.7178, -2427.99756> , <0, -90.6194687, 0>))
			cutsceneSpawns.append(NewCameraPair(<-23315.9023, -1703.98547, -2398.66748> , <0, -132.315002, 0>))
			cutsceneSpawns.append(NewCameraPair(<-16714.9688, -10806.3818, -2243.14551> , <0, 95.1944809, 0>))
			cutsceneSpawns.append(NewCameraPair(<-16572.2891, -21977.0254, -3007.99854> , <0, 158.171997, 0>))
			cutsceneSpawns.append(NewCameraPair(<-8895.37598, -31398.3008, -2265.09766> , <0, 19.2363491, 0>))
			cutsceneSpawns.append(NewCameraPair(<28299.0723, -24929.7754, -2625.38989> , <0, -153.469131, 0>))
			cutsceneSpawns.append(NewCameraPair(<22734.1094, -9516.63574, -3728.41479> , <0, -167.168518, 0>))
			cutsceneSpawns.append(NewCameraPair(<22825.0996, 2085.24829, -3495.45166> , <0, -175.991135, 0>))
			
		break
		
		case eMaps.mp_rr_arena_empty:
		case eMaps.mp_rr_canyonlands_staging:
			cutsceneSpawns.append(NewCameraPair(<32645.04,-9575.77,-25911.94>, <7.71,91.67,0>)) 
			cutsceneSpawns.append(NewCameraPair(<49180.1055, -6836.14502, -23461.8379>, <0, -55.7723808, 0>)) 
			cutsceneSpawns.append(NewCameraPair(<43552.3203, -1023.86182, -25270.9766>, <0, 20.9528542, 0>))
			cutsceneSpawns.append(NewCameraPair(<30038.0254, -1036.81982, -23369.6035>, <55, -24.2035522, 0>))
		break

		case eMaps.mp_rr_canyonlands_mu1:
		case eMaps.mp_rr_canyonlands_mu1_night:
		case eMaps.mp_rr_canyonlands_64k_x_64k:
		case eMaps.mp_rr_canyonlands_mu2:
		case eMaps.mp_rr_canyonlands_mu2_tt:
		case eMaps.mp_rr_canyonlands_mu2_mv:
		case eMaps.mp_rr_canyonlands_mu2_ufo:
			cutsceneSpawns.append(NewCameraPair(<-7984.68408, -16770.2031, 3972.28271>, <0, -158.605301, 0>)) 
			cutsceneSpawns.append(NewCameraPair(<-19691.1621, 5229.45264, 4238.53125>, <0, -54.6054993, 0>))
			cutsceneSpawns.append(NewCameraPair(<13270.0576, -20413.9023, 2999.29468>, <0, 98.6180649, 0>))
			cutsceneSpawns.append(NewCameraPair(<-25250.0391, -723.554199, 3427.51831>, <0, -55.5126762, 0>))
		break

		case eMaps.mp_rr_olympus:
		case eMaps.mp_rr_olympus_tt:
			cutsceneSpawns.append(NewCameraPair(<-34747.9766, 16697.9922, -3418.06567>, <0, -25, 0>))
			cutsceneSpawns.append(NewCameraPair(<-22534.2168, 3191.64282, -4614.2583>, <0, -96.9278641, 0>))
			cutsceneSpawns.append(NewCameraPair(<-43278.6406, -13421.3818, -2568.48071>, <0, 60.0252533, 0>))
			cutsceneSpawns.append(NewCameraPair(<-227.150497, -15917.8672, -3549.59814>, <0, -8.99629879, 0>))
			cutsceneSpawns.append(NewCameraPair(<23119.459, -19445.4551, -3955.37915>, <0, 59.2959213, 0>))
			cutsceneSpawns.append(NewCameraPair(<11381.1982, -3206.40552, -3129.646>, <0, 19.5211906, 0>))
			cutsceneSpawns.append(NewCameraPair(<-11880.9453, 13690.4688, -3865.60645>, <0, -78.4126205, 0>))
			cutsceneSpawns.append(NewCameraPair(<7088.45898, 25559.4492, -40.745079>, <0, -40.4022217, 0>))
			cutsceneSpawns.append(NewCameraPair(<-19851.1211, 16372.2002, -5309.15869>, <0, -169.298721, 0>))
		break
		
		default:
			cutsceneSpawns.append(NewCameraPair(<0, 0, 2000>, <0, 0, 0>))
		break
	}
	
	//Randomize locations array only once at map load
	cutsceneSpawns.randomize()
	
	//Pick random starting location
	int randomStartIndex = RandomIntRange(0, cutsceneSpawns.len())
	int currentLocationIndex = randomStartIndex
	vector currentCameraPos = cutsceneSpawns[randomStartIndex].origin
	vector currentCameraAng = cutsceneSpawns[randomStartIndex].angles
	visitedLocations.append(randomStartIndex)
	
	//Setup camera at starting location
	entity camera = CreateClientSidePointCamera(currentCameraPos, currentCameraAng, 17)
	camera.SetFOV(100)
	entity cutsceneMover = CreateClientsideScriptMover($"mdl/dev/empty_model.rmdl", currentCameraPos, currentCameraAng)
	camera.SetParent(cutsceneMover)
	GetLocalClientPlayer().SetMenuCameraEntity( camera )
	DoF_SetFarDepth( 6000, 10000 )
	
	OnThreadEnd(
		function() : ( player, cutsceneMover, camera )
		{
			GetLocalClientPlayer().ClearMenuCameraEntity()
			if(IsValid(cutsceneMover))
				cutsceneMover.Destroy()
			if(IsValid(camera))
				camera.Destroy()
			DoF_SetNearDepthToDefault()
			DoF_SetFarDepthToDefault()
		}
	)
	
	while(true)
	{
		//Check if all locations visited
		if(visitedLocations.len() >= cutsceneSpawns.len())
		{
			//Reset for new cycle - keep same location order, but exclude current location
			visitedLocations.clear()
			visitedLocations.append(currentLocationIndex) //Exclude current location from next selection
		}
		
		//Get sorted locations by distance from current position
		array<CameraLocationPair> sortedLocations = SortLocationsByDistance(cutsceneSpawns, currentCameraPos, visitedLocations)
		
		if(sortedLocations.len() == 0)
		{
			//This shouldn't happen, but just in case
			visitedLocations.clear()
			continue
		}
		
		//Pick nearest location
		CameraLocationPair targetLocation = sortedLocations[0]
		vector targetPos = targetLocation.origin
		vector targetAngles = targetLocation.angles
		
		//Mark this location as visited and update current location
		int targetIndex = FindLocationIndex(cutsceneSpawns, targetLocation)
		if(targetIndex != -1)
		{
			visitedLocations.append(targetIndex)
			currentLocationIndex = targetIndex //Update current location index
		}
		
		//Calculate arc flight parameters
		float flightDistance = CalculateDistance(currentCameraPos, targetPos)
		float flightDuration = max(6.0, flightDistance / 800.0) //Dynamic duration based on distance
		float arcHeight = CalculateArcHeight(currentCameraPos, targetPos, MapName())
		
		//Execute arc-based flight to location
		float startTime = Time()
		float duration = flightDuration
		
		while(Time() - startTime < duration)
		{
			float t = (Time() - startTime) / duration
			
			//Calculate arc position and angles
			vector pos = InterpolateArcPosition(currentCameraPos, targetPos, t, arcHeight)
			vector angles = CalculateArcAngles(currentCameraAng, camera.GetAngles(), targetAngles, currentCameraPos, targetPos, t)
			
			//Dynamic FOV based on arc phase
			float fov = 100.0
			if(t < 0.5)
				fov = 100.0 + (t * 2.0) * 15.0 //Wider FOV when ascending (100-115)
			else
				fov = 115.0 - ((t - 0.5) * 2.0) * 10.0 //Narrower FOV when descending (115-105)
			
			cutsceneMover.SetOrigin(pos)
			cutsceneMover.SetAngles(angles)
			camera.SetOrigin(pos)
			camera.SetAngles(angles)
			// camera.SetFOV(fov)
			
			wait 0.01 //Faster updates
		}
		
		// wait 2
		//At destination - slow rightward drift
		vector rightVector = AnglesToRight(cutsceneMover.GetAngles())
		vector driftEndPos = cutsceneMover.GetOrigin() + rightVector * 200
		
		//Create slow drift path
		CinematicPath driftPath = NewCinematicPath(targetPos, driftEndPos, targetAngles, targetAngles, 4.0, 0, 110, 95)
		
		//Execute slow drift
		startTime = Time()
		duration = driftPath.duration
		
		while(Time() - startTime < duration)
		{
			float t = (Time() - startTime) / duration
			
			//Update position and angles
			vector pos = InterpolatePosition(driftPath, t)
			// vector angles = InterpolateAngles(driftPath, t)
			// float fov = InterpolateFOV(driftPath, t)
			
			cutsceneMover.SetOrigin(pos)
			// cutsceneMover.SetAngles(angles)
			camera.SetOrigin(pos)
			// camera.SetAngles(angles)
			// camera.SetFOV(fov)
			
			wait 0.01 //Faster updates
		}
		
		//Update current position to drift end for next iteration
		currentCameraPos = cutsceneMover.GetOrigin() //driftEndPos
		currentCameraAng = cutsceneMover.GetAngles() //targetAngles
	}
}

void function CoolCameraOnMenu()
//based on sal's tdm
{
	if(EPIC_CAMERA_ENABLED)
	{
		thread EpicCinematicCamera()
		return
	}
	
	//Original camera system
    entity player = GetLocalClientPlayer()
	player.EndSignal("ChallengeStartRemoveCameras")
	array<CameraLocationPair> cutsceneSpawns
	
    if(!IsValid(player)) return
	
	switch( MapName() )
	{
		case eMaps.mp_rr_desertlands_64k_x_64k:
		case eMaps.mp_rr_desertlands_64k_x_64k_nx:
		case eMaps.mp_rr_desertlands_64k_x_64k_tt:
		case eMaps.mp_rr_desertlands_mu1:
		case eMaps.mp_rr_desertlands_mu1_tt:
		case eMaps.mp_rr_desertlands_mu2:
		case eMaps.mp_rr_desertlands_holiday:
			cutsceneSpawns.append(NewCameraPair(<10881.2295, 5903.09863, -3176.7959>, <0, -143.321213, 0>)) 
			cutsceneSpawns.append(NewCameraPair(<9586.79199, 24404.5898, -2019.6366>, <0, -52.6216431, 0>)) 
			cutsceneSpawns.append(NewCameraPair(<630.249573, 13375.9219, -2736.71948>, <0, -43.2706299, 0>))
			cutsceneSpawns.append(NewCameraPair(<16346.3076, -34468.9492, -1109.32153>, <0, -44.3879509, 0>))
			cutsceneSpawns.append(NewCameraPair(<1133.25562, -20102.9648, -2488.08252>, <0, -24.9140873, 0>))
		break
		
		case eMaps.mp_rr_arena_empty:
		case eMaps.mp_rr_canyonlands_staging:
			cutsceneSpawns.append(NewCameraPair(<32645.04,-9575.77,-25911.94>, <7.71,91.67,0.00>)) 
			cutsceneSpawns.append(NewCameraPair(<49180.1055, -6836.14502, -23461.8379>, <0, -55.7723808, 0>)) 
			cutsceneSpawns.append(NewCameraPair(<43552.3203, -1023.86182, -25270.9766>, <0, 20.9528542, 0>))
			cutsceneSpawns.append(NewCameraPair(<30038.0254, -1036.81982, -23369.6035>, <55, -24.2035522, 0>))
		break

		case eMaps.mp_rr_canyonlands_mu1:
		case eMaps.mp_rr_canyonlands_mu1_night:
		case eMaps.mp_rr_canyonlands_64k_x_64k:
		case eMaps.mp_rr_canyonlands_mu2:
		case eMaps.mp_rr_canyonlands_mu2_tt:
		case eMaps.mp_rr_canyonlands_mu2_mv:
		case eMaps.mp_rr_canyonlands_mu2_ufo:
			cutsceneSpawns.append(NewCameraPair(<-7984.68408, -16770.2031, 3972.28271>, <0, -158.605301, 0>)) 
			cutsceneSpawns.append(NewCameraPair(<-19691.1621, 5229.45264, 4238.53125>, <0, -54.6054993, 0>))
			cutsceneSpawns.append(NewCameraPair(<13270.0576, -20413.9023, 2999.29468>, <0, 98.6180649, 0>))
			cutsceneSpawns.append(NewCameraPair(<-25250.0391, -723.554199, 3427.51831>, <0, -55.5126762, 0>))
		break

		case eMaps.mp_rr_olympus:
		case eMaps.mp_rr_olympus_tt:
			cutsceneSpawns.append(NewCameraPair(<-34747.9766, 16697.9922, -3418.06567>, <0, -25, 0>))
			cutsceneSpawns.append(NewCameraPair(<-22534.2168, 3191.64282, -4614.2583>, <0, -96.9278641, 0>))
			cutsceneSpawns.append(NewCameraPair(<-43278.6406, -13421.3818, -2568.48071>, <0, 60.0252533, 0>))
			cutsceneSpawns.append(NewCameraPair(<-227.150497, -15917.8672, -3549.59814>, <0, -8.99629879, 0>))
			cutsceneSpawns.append(NewCameraPair(<23119.459, -19445.4551, -3955.37915>, <0, 59.2959213, 0>))
			cutsceneSpawns.append(NewCameraPair(<11381.1982, -3206.40552, -3129.646>, <0, 19.5211906, 0>))
			cutsceneSpawns.append(NewCameraPair(<-11880.9453, 13690.4688, -3865.60645>, <0, -78.4126205, 0>))
			cutsceneSpawns.append(NewCameraPair(<7088.45898, 25559.4492, -40.745079>, <0, -40.4022217, 0>))
			cutsceneSpawns.append(NewCameraPair(<-19851.1211, 16372.2002, -5309.15869>, <0, -169.298721, 0>))
		break
		default:
		// cutsceneSpawns.append(NewCameraPair(<-3096.13501, 632.377991, 1913.47217>, <0, -134.430405, 0> ))
		
		break
	}


    //EmitSoundOnEntity( player, "music_skyway_04_smartpistolrun" )

    float playerFOV = player.GetFOV()
	
	cutsceneSpawns.randomize()
	int locationindex = 0
	vector randomcameraPos = cutsceneSpawns[0].origin
	vector randomcameraAng = cutsceneSpawns[0].angles
    entity camera = CreateClientSidePointCamera(randomcameraPos, randomcameraAng, 17)
    camera.SetFOV(100)
    entity cutsceneMover = CreateClientsideScriptMover($"mdl/dev/empty_model.rmdl", randomcameraPos, randomcameraAng)
    camera.SetParent(cutsceneMover)
	GetLocalClientPlayer().SetMenuCameraEntity( camera )
	DoF_SetFarDepth( 6000, 10000 )	
	
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
		}
	)
	
	while(true){
		if(locationindex == cutsceneSpawns.len()){
			locationindex = 0
		}	
	    randomcameraPos = cutsceneSpawns[locationindex].origin
		randomcameraAng = cutsceneSpawns[locationindex].angles
		locationindex++
		cutsceneMover.SetOrigin(randomcameraPos)
		cutsceneMover.SetAngles(randomcameraAng)
		camera.SetOrigin(randomcameraPos)
		camera.SetAngles(randomcameraAng)
		cutsceneMover.NonPhysicsMoveTo(randomcameraPos + AnglesToRight(randomcameraAng) * 700, 15, 0, 0)
		wait 6 
	}
}
void function DisableLiveStatsUI()
{
	Hud_SetVisible(HudElement( "Countdown" ), false)
	Hud_SetVisible(HudElement( "CountdownFrame" ), false)
	
	Hud_SetVisible(HudElement( "ChallengesStatsFrame" ), false)
	Hud_SetVisible(HudElement( "TitleStats" ), false)
	Hud_SetVisible(HudElement( "ScreenBlur" ), false)
	Hud_SetVisible(HudElement( "ChallengesDummieskilled" ), false)
	Hud_SetVisible(HudElement( "ChallengesDummieskilledValue" ), false)
	Hud_SetVisible(HudElement( "ChallengesAccuracy" ), false)
	Hud_SetVisible(HudElement( "ChallengesAccuracyValue" ), false)
	Hud_SetVisible(HudElement( "ChallengesDamage" ), false)
	Hud_SetVisible(HudElement( "ChallengesDamageValue" ), false)
	Hud_SetVisible(HudElement( "ChallengesHeadshots" ), false)
	Hud_SetVisible(HudElement( "ChallengesHeadshotsValue" ), false)	
	
	ToggleArmorSwapUI( false )
}

void function ToggleArmorSwapUI(bool toggle)
{
	Hud_SetVisible(HudElement( "ArmorSwapStatsFrame" ), toggle)
	Hud_SetVisible(HudElement( "ArmorSwapStatsTitle" ), toggle)
	Hud_SetVisible(HudElement( "LastTime" ), toggle)
	Hud_SetVisible(HudElement( "LastTimeValue" ), toggle)
	Hud_SetVisible(HudElement( "BestTime" ), toggle)
	Hud_SetVisible(HudElement( "BestTimeValue" ), toggle)
	Hud_SetVisible(HudElement( "AverageTime" ), toggle)
	Hud_SetVisible(HudElement( "AverageTimeValue" ), toggle)
	
	if(toggle)
	{
		thread function():()
		{
			wait 3
			AimTrainer_QuickHint( "Move to spawn new deathboxes", true, 15 )
		}()	
	}
}

void function StartUpdatingArmorSwapLastTime() //create a new struct and function to calculate the elapsed times
{
	entity player = GetLocalClientPlayer()
	
	float startTime = Time()
	
	EndSignal(player, "ForceResultsEnd_SkipButton")
	EndSignal(player, "ChallengeTimeOver")
	EndSignal(player, "StopArmorSwapStopwatch")

	OnThreadEnd(
		function() : ( player )
		{
			file.armorSwapTimes.append( file.lastTime )
			
			file.armorSwapTimes.sort()
			
			float bestTime = file.armorSwapTimes[0]
			
			// extract hours
			int hourSeconds = int(bestTime) % SECONDS_PER_DAY
			int hours = int( floor( hourSeconds / SECONDS_PER_HOUR ) )

			// extract minutes
			int elapsedMinutes = hourSeconds % SECONDS_PER_HOUR
			int minutes = int( floor( elapsedMinutes / SECONDS_PER_MINUTE ) )

			// extract seconds
			int elapsedSeconds = elapsedMinutes % SECONDS_PER_MINUTE
			int seconds = int( ceil( elapsedSeconds ) )

			// extract milliseconds
			int milliseconds = int( ceil ( (bestTime - int(bestTime)) * 100 ) )

			Hud_SetText( HudElement( "BestTimeValue" ), format( "%.2d:%.2d:%.2d", minutes, seconds, milliseconds ) )
			
			float averageTime
			float sum
			
			foreach(value in file.armorSwapTimes)
				sum+=value
				
			averageTime = sum/file.armorSwapTimes.len()
			
			// extract hours
			hourSeconds = int( averageTime ) % SECONDS_PER_DAY
			hours = int( floor( hourSeconds / SECONDS_PER_HOUR ) )

			// extract minutes
			elapsedMinutes = hourSeconds % SECONDS_PER_HOUR
			minutes = int( floor( elapsedMinutes / SECONDS_PER_MINUTE ) )

			// extract seconds
			elapsedSeconds = elapsedMinutes % SECONDS_PER_MINUTE
			seconds = int( ceil( elapsedSeconds ) )

			// extract milliseconds
			milliseconds = int( ceil ( (averageTime - int(averageTime)) * 100 ) )

			Hud_SetText( HudElement( "AverageTimeValue" ), format( "%.2d:%.2d:%.2d", minutes, seconds, milliseconds ) )

		}
	)
	
	while(true)
    {
		file.lastTime = Time() - startTime

		// extract hours
		int hourSeconds = int(file.lastTime) % SECONDS_PER_DAY
		int hours = int( floor( hourSeconds / SECONDS_PER_HOUR ) )

		// extract minutes
		int elapsedMinutes = hourSeconds % SECONDS_PER_HOUR
		int minutes = int( floor( elapsedMinutes / SECONDS_PER_MINUTE ) )

		// extract seconds
		int elapsedSeconds = elapsedMinutes % SECONDS_PER_MINUTE
		int seconds = int( ceil( elapsedSeconds ) )

		// extract milliseconds
		int milliseconds = int( ceil ( (file.lastTime - int(file.lastTime)) * 100 ) )

		Hud_SetText( HudElement( "LastTimeValue" ), format( "%.2d:%.2d:%.2d", minutes, seconds, milliseconds ) )

		WaitFrame()
    }
}

void function ServerCallback_ResetLiveStatsUI()
{
	Hud_SetText( HudElement( "ChallengesDummieskilledValue"), "0")
	Hud_SetText( HudElement( "ChallengesAccuracyValue"), "0/0 | 0")
	Hud_SetText( HudElement( "ChallengesDamageValue"), "0/0 | 0")
	Hud_SetText( HudElement( "ChallengesHeadshotsValue"), "0")
	file.totalShots = 0
	file.ShotsHits = 0
	file.damageDone = 0
	file.damagePossible = 0
	
	file.lastTime = 0
	file.bestTime = 0
	file.averageTime = 0
	file.armorSwapTimes.clear()
	
	Hud_SetText( HudElement( "BestTimeValue" ), "00:00:00" )
	Hud_SetText( HudElement( "AverageTimeValue" ), "00:00:00" )
	Hud_SetText( HudElement( "LastTimeValue" ), "00:00:00" )
}

void function UpdateUIRespawnTimer()
{
	entity player = GetLocalClientPlayer() 
	int time = AimTrainer_RESULTS_TIME
	EndSignal(player, "ForceResultsEnd_SkipButton")
	
    while(time > -1)
    {
        RunUIScript( "UpdateFRChallengeResultsTimer", time)
        time--
        wait 1
    }
}

void function CreateDescriptionRUI(string description)
{
	file.isInMainMenu = false
	
	entity player = GetLocalClientPlayer()
	player.Signal("ChallengeStartRemoveCameras")
	EndSignal(player, "ForceResultsEnd_SkipButton")
	EndSignal(player, "ChallengeTimeOver")
	WaitFrame()	
	UISize screenSize = GetScreenSize()
    var topo = RuiTopology_CreatePlane( <( screenSize.width * 0),( screenSize.height * -0.1 ), 0>, <float( screenSize.width ), 0, 0>, <0, float( screenSize.height ), 0>, false )
	var rui = RuiCreate( $"ui/id_dev_text.rpak", topo, RUI_DRAW_HUD, 0 )
	
	OnThreadEnd(
		function() : (rui)
		{
			RuiDestroyIfAlive( rui )
		}
	)	
	
	RuiSetFloat( rui, "startTime", Time() )
	RuiSetString( rui, "speaker","")
	RuiSetString( rui, "text", description )
	RuiSetFloat( rui, "duration", AimTrainer_PRE_START_TIME-0.01 )
	RuiSetResolutionToScreenSize( rui )
	wait AimTrainer_PRE_START_TIME-0.01
}

void function ServerCallback_ToggleDotForHitscanWeapons(bool visible)
{
	entity player = GetLocalClientPlayer()
	if(visible && file.dot == null)
		file.dot = RuiCreate( $"ui/crosshair_dot.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 0 )
	else if (!visible && file.dot != null)
	{
		RuiDestroyIfAlive( file.dot )
		file.dot = null
	}
}

void function ServerCallback_SetChallengeActivated(bool activated)
{
	RunUIScript("SetAimTrainerSessionEnabled", activated)
	file.challengeActivatedLastValue = activated
}

void function RefreshChallengeActivated()
{
	RunUIScript("SetAimTrainerSessionEnabled", file.challengeActivatedLastValue)
}

void function CreateTimerRUIandSTATS(bool crosshair = false) //and stats
{
	entity player = GetLocalClientPlayer()
	int time = AimTrainer_CHALLENGE_DURATION
	EndSignal(player, "ForceResultsEnd_SkipButton")
	EndSignal(player, "ChallengeTimeOver")

	wait AimTrainer_PRE_START_TIME
	
	OnThreadEnd(
		function() : ( crosshair )
		{
		DisableLiveStatsUI()
		EnableApexvaaksNewHud( false )
		}
	)

	Hud_SetVisible(HudElement( "ChallengesStatsFrame" ), true)
	Hud_SetVisible(HudElement( "TitleStats" ), true)
	Hud_SetVisible(HudElement( "ScreenBlur" ), true)
	Hud_SetVisible(HudElement( "ChallengesDummieskilled" ), true)
	Hud_SetVisible(HudElement( "ChallengesDummieskilledValue" ), true)
	Hud_SetVisible(HudElement( "ChallengesAccuracy" ), true)
	Hud_SetVisible(HudElement( "ChallengesAccuracyValue" ), true)
	Hud_SetVisible(HudElement( "ChallengesDamage" ), true)
	Hud_SetVisible(HudElement( "ChallengesDamageValue" ), true)
	Hud_SetVisible(HudElement( "ChallengesHeadshots" ), true)
	Hud_SetVisible(HudElement( "ChallengesHeadshotsValue" ), true)
	
	if(!AimTrainer_INFINITE_CHALLENGE){
	Hud_SetVisible(HudElement( "Countdown" ), true)
	Hud_SetVisible(HudElement( "CountdownFrame" ), true)
	Hud_SetText( HudElement( "Countdown" ), AimTrainer_CHALLENGE_DURATION.tostring())}
	
	while(true)
    {
		if(!AimTrainer_INFINITE_CHALLENGE)
			Hud_SetText( HudElement( "Countdown" ), time.tostring())
        time--
		wait 1
    }
}
void function RefreshHUD()
{
	WaitFrame()
	//refresh
	entity player = GetLocalViewPlayer()
	entity weapon = player.GetSelectedWeapon( eActiveInventorySlot.mainHand )
	if ( !IsValid( weapon ) )
		weapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	UpdateHudDataForMainWeapons( player, weapon )
	
	//refresh
	thread InitSurvivalHealthBar()
}

void function ServerCallback_RestartChallenge(int challenge)
{
	printt(challenge)
	switch(challenge)
	{
		case 1:
			StartChallenge1Client()
			break
		case 2:
			StartChallenge2Client()
			break
		case 3:
			StartChallenge3Client()
			break
		case 4:
			StartChallenge4Client()
			break
		case 10:
			StartChallenge5Client()
			break
		case 11:
			StartChallenge6Client()
			break
		case 12:
			StartChallenge7Client()
			break
		case 13:
			StartChallenge8Client()
			break
		case 6:
			StartChallenge1NewCClient()
			break
		case 7:
			StartChallenge2NewCClient()
			break
		case 14:
			StartChallenge3NewCClient()
			break
		case 9:
			StartChallenge4NewCClient()
			break
		case 8:
			StartChallenge5NewCClient()
			break
		case 15:
			StartChallenge6NewCClient()
			break
		case 16:
			StartChallenge7NewCClient()
			break
		case 17:
			StartChallenge8NewCClient()
			break	
		case 18:
			StartChallenge9NewCClient()
			break	
	}
}

void function StartChallenge1Client()
{
	entity player = GetLocalClientPlayer()
	ScreenFade( player, 0, 0, 0, 255, 1, 1, FFADE_IN | FFADE_PURGE )
	thread CreateDescriptionRUI("Hit the strafing dummy to get points.")
	thread CreateTimerRUIandSTATS()	
	player.ClientCommand("CC_StartChallenge 1")
}

void function StartChallenge2Client()
{
	entity player = GetLocalClientPlayer()
	ScreenFade( player, 0, 0, 0, 255, 1, 1, FFADE_IN | FFADE_PURGE )
	thread CreateDescriptionRUI("Transfers practice with easy strafe.")
	thread CreateTimerRUIandSTATS()
	player.ClientCommand("CC_StartChallenge 2")
}

void function StartChallenge3Client()
{
	entity player = GetLocalClientPlayer()
	ScreenFade( player, 0, 0, 0, 255, 1, 1, FFADE_IN | FFADE_PURGE )
	thread CreateDescriptionRUI("Don't let dummy touch ground to get streak points.")
	thread CreateTimerRUIandSTATS()
	player.ClientCommand("CC_StartChallenge 3")
}

void function StartChallenge4Client()
{
	entity player = GetLocalClientPlayer()
	ScreenFade( player, 0, 0, 0, 255, 1, 1, FFADE_IN | FFADE_PURGE )
	thread CreateDescriptionRUI("Tracking practice. Hit the dummies to get points.")
	thread CreateTimerRUIandSTATS()
	player.ClientCommand("CC_StartChallenge 4")
}

void function StartChallenge5Client()
{
	entity player = GetLocalClientPlayer()
	ScreenFade( player, 0, 0, 0, 255, 1, 1, FFADE_IN | FFADE_PURGE )
	thread CreateDescriptionRUI("Hitscan weapon recommended. Hit as many targets as possible.")
	thread CreateTimerRUIandSTATS()
	player.ClientCommand("CC_StartChallenge 5")
}
void function StartChallenge6Client()
{
	entity player = GetLocalClientPlayer()
	ScreenFade( player, 0, 0, 0, 255, 1, 1, FFADE_IN | FFADE_PURGE )
	thread CreateDescriptionRUI("Hitscan auto weapon recommended. Hit the dummies to get points.")
	thread CreateTimerRUIandSTATS()
	player.ClientCommand("CC_StartChallenge 6")
}
void function StartChallenge7Client()
{
	entity player = GetLocalClientPlayer()
	ScreenFade( player, 0, 0, 0, 255, 1, 1, FFADE_IN | FFADE_PURGE )
	thread CreateDescriptionRUI("Hitscan auto weapon recommended. Hit the dummies to get points.")
	thread CreateTimerRUIandSTATS()
	player.ClientCommand("CC_StartChallenge 7")
}
void function StartChallenge8Client()
{
	entity player = GetLocalClientPlayer()
	ScreenFade( player, 0, 0, 0, 255, 1, 1, FFADE_IN | FFADE_PURGE )
	thread CreateDescriptionRUI("Hit the dummies to get points.")
	thread CreateTimerRUIandSTATS()
	player.ClientCommand("CC_StartChallenge 8")
}
void function StartChallenge1NewCClient()
{
	entity player = GetLocalClientPlayer()
	ScreenFade( player, 0, 0, 0, 255, 1, 1, FFADE_IN | FFADE_PURGE )
	thread CreateDescriptionRUI("Avoid death by killing dummy.")
	thread CreateTimerRUIandSTATS()
	player.ClientCommand("CC_StartChallenge 1newc")
}

void function StartChallenge2NewCClient()
{
	entity player = GetLocalClientPlayer()
	ScreenFade( player, 0, 0, 0, 255, 1, 1, FFADE_IN | FFADE_PURGE )
	thread CreateDescriptionRUI("Only sticks count, shields are disabled.")
	thread CreateTimerRUIandSTATS()
	player.ClientCommand("CC_StartChallenge 2newc")
}

void function StartChallenge3NewCClient()
{
	entity player = GetLocalClientPlayer()
	ScreenFade( player, 0, 0, 0, 255, 1, 1, FFADE_IN | FFADE_PURGE )
	thread CreateDescriptionRUI("This challenge is in beta version. Vertical grenades practice.")
	thread CreateTimerRUIandSTATS()
	player.ClientCommand("CC_StartChallenge 3newc")
}

void function StartChallenge4NewCClient()
{
	entity player = GetLocalClientPlayer()
	ScreenFade( player, 0, 0, 0, 255, 1, 1, FFADE_IN | FFADE_PURGE )
	thread CreateDescriptionRUI("Valk ultimate tracking simulation.")
	thread CreateTimerRUIandSTATS()
	player.ClientCommand("CC_StartChallenge 4newc")
}

void function StartChallenge5NewCClient()
{
	entity player = GetLocalClientPlayer()
	ScreenFade( player, 0, 0, 0, 255, 1, 1, FFADE_IN | FFADE_PURGE )
	thread CreateDescriptionRUI("Tracking from gravity lift simulation.")
	thread CreateTimerRUIandSTATS()
	player.ClientCommand("CC_StartChallenge 5newc")
}
	
void function StartChallenge6NewCClient()
{
	entity player = GetLocalClientPlayer()
	ScreenFade( player, 0, 0, 0, 255, 1, 1, FFADE_IN | FFADE_PURGE )
	thread CreateDescriptionRUI("This challenge is in beta version. Hit the skydiving dummies to get points.")
	thread CreateTimerRUIandSTATS()
	player.ClientCommand("CC_StartChallenge 6newc")
}

void function StartChallenge7NewCClient()
{
	entity player = GetLocalClientPlayer()
	ScreenFade( player, 0, 0, 0, 255, 1, 1, FFADE_IN | FFADE_PURGE )
	thread CreateDescriptionRUI("Hit the running dummies to get points.")
	thread CreateTimerRUIandSTATS()
	player.ClientCommand("CC_StartChallenge 7newc")
}

void function StartChallenge8NewCClient()
{
	entity player = GetLocalClientPlayer()
	ScreenFade( player, 0, 0, 0, 255, 1, 1, FFADE_IN | FFADE_PURGE )
	thread CreateDescriptionRUI("Swap armor as fast as you can")
	
	//thread CreateTimerRUIandSTATS()
	player.ClientCommand("CC_StartChallenge 8newc")
	
	DisableLiveStatsUI()
	
	ToggleArmorSwapUI(true)
}

void function StartChallenge9NewCClient()
{
	entity player = GetLocalClientPlayer()
	ScreenFade( player, 0, 0, 0, 255, 1, 1, FFADE_IN | FFADE_PURGE )
	thread CreateDescriptionRUI("Practice dropship scenario")
	thread CreateTimerRUIandSTATS()
	player.ClientCommand("CC_StartChallenge9NewC")
}
void function SkipButtonResultsClient()
{
	entity player = GetLocalClientPlayer()
	Signal(player, "ForceResultsEnd_SkipButton")
	player.ClientCommand("ChallengesSkipButton")
}

void function RestartButtonResultsClient()
{
	entity player = GetLocalClientPlayer()
	Signal(player, "ChallengeTimeOver")
	player.ClientCommand("CC_RestartChallenge")
}
//settings
void function ChangeChallengeDurationClient(string time)
{
	if (time == "" || time == "0") return
	entity player = GetLocalClientPlayer()
	AimTrainer_CHALLENGE_DURATION = int(time)
	player.ClientCommand("CC_ChangeChallengeDuration " + time)
}

void function ChangeAimTrainer_AI_SHIELDS_LEVELClient(string desiredShieldLevel)
{
	entity player = GetLocalClientPlayer()
	AimTrainer_AI_SHIELDS_LEVEL = int(desiredShieldLevel)
	player.ClientCommand("CC_AimTrainer_AI_SHIELDS_LEVEL " + desiredShieldLevel)
}

void function ChangeAimTrainer_AI_DUMMIES_COLORClient(string desiredColor)
{
	entity player = GetLocalClientPlayer()
	AimTrainer_AI_COLOR = int(desiredColor)
	player.ClientCommand("CC_AimTrainer_DUMMIES_COLOR " + desiredColor)
}

void function ChangeAimTrainer_STRAFING_SPEEDClient(string desiredSpeed)
{
	entity player = GetLocalClientPlayer()
	
	float speed
	
	switch( int(desiredSpeed) )
	{
		case 0:
			speed = 0
			break
		case 1:
			speed = 0.85
			break
		case 2:
			speed = 1
			break
		case 3:
			speed = 1.35
			break
		case 4:
			speed = 1.8
			break
	}
	
	AimTrainer_STRAFING_SPEED = speed
	if(AimTrainer_STRAFING_SPEED != 1.8)
		AimTrainer_STRAFING_SPEED_WAITTIME = speed
	else
		AimTrainer_STRAFING_SPEED_WAITTIME = 1
	player.ClientCommand("CC_AimTrainer_STRAFING_SPEED " + speed)	
}

void function ChangeAimTrainer_AI_SPAWN_DISTANCE(string desiredSpawnDistance)
{
	entity player = GetLocalClientPlayer()	
	player.ClientCommand("CC_AimTrainer_SPAWN_DISTANCE " + desiredSpawnDistance)		
}

void function ChangeAimTrainer_AI_HEALTH(string desiredHealth)
{
	entity player = GetLocalClientPlayer()	
	player.ClientCommand("CC_AimTrainer_AI_HEALTH " + desiredHealth)		
}

void function ChangeRGB_HUDClient(string isabool)
{
	entity player = GetLocalClientPlayer()
	if(isabool == "0")
		RGB_HUD = false
	else if(isabool == "1")
		RGB_HUD = true
	
	thread RefreshHUD()
	player.ClientCommand("CC_RGB_HUD " + isabool)
}

void function ChangeAimTrainer_INFINITE_CHALLENGEClient(string isabool)
{
	entity player = GetLocalClientPlayer()
	if(isabool == "0")
		AimTrainer_INFINITE_CHALLENGE = false
	else if(isabool == "1")
		AimTrainer_INFINITE_CHALLENGE = true
	
	player.ClientCommand("CC_AimTrainer_INFINITE_CHALLENGE " + isabool)
}

void function ChangeAimTrainer_INFINITE_AMMOClient(string isabool)
{
	entity player = GetLocalClientPlayer()
	if(isabool == "0")
		AimTrainer_INFINITE_AMMO = false
	else if(isabool == "1")
		AimTrainer_INFINITE_AMMO = true
	
	player.ClientCommand("CC_AimTrainer_INFINITE_AMMO " + isabool)
}

void function ChangeAimTrainer_INFINITE_AMMO2Client(string isabool)
{
	entity player = GetLocalClientPlayer()
	if(isabool == "0")
		AimTrainer_INFINITE_AMMO2 = false
	else if(isabool == "1")
		AimTrainer_INFINITE_AMMO2 = true
	
	player.ClientCommand("CC_AimTrainer_INFINITE_AMMO2 " + isabool)
}

void function ChangeAimTrainer_INMORTAL_TARGETSClient(string isabool)
{
	entity player = GetLocalClientPlayer()
	if(isabool == "0")
		AimTrainer_INMORTAL_TARGETS = false
	else if(isabool == "1")
		AimTrainer_INMORTAL_TARGETS = true
	
	player.ClientCommand("CC_AimTrainer_INMORTAL_TARGETS " + isabool)
}

void function ChangeAimTrainer_USER_WANNA_BE_A_DUMMYClient(string isabool)
{
	entity player = GetLocalClientPlayer()
	if(isabool == "2")
		AimTrainer_USER_WANNA_BE_A_DUMMY = false
	else if(isabool == "3")
		AimTrainer_USER_WANNA_BE_A_DUMMY = true
	
	player.ClientCommand("CC_AimTrainer_USER_WANNA_BE_A_DUMMY " + isabool)
}

void function UIToClient_MenuGiveWeapon(string weapon)
{
	entity player = GetLocalClientPlayer()
	player.ClientCommand("CC_MenuGiveAimTrainerWeapon " + weapon + " " + DesiredSlot)
}

void function UIToClient_MenuGiveWeaponWithAttachments(string weapon, int desiredoptic, int desiredbarrel, int desiredstock, int desiredshotgunbolt, string weapontype, int desiredMag, string ammotype)
{
	entity player = GetLocalClientPlayer()

	// printt("DEBUG: desiredOptic: " + desiredoptic, " desiredBarrel: " + desiredbarrel, " desiredStock: " + desiredstock)
	player.ClientCommand("CC_MenuGiveAimTrainerWeapon " + weapon + " " + DesiredSlot + " " + desiredoptic + " " + desiredbarrel + " " + desiredstock + " " + desiredshotgunbolt + " " + weapontype + " " + desiredMag + " " + ammotype )
}

void function OpenFRChallengesSettingsWpnSelector()
{
	entity player = GetLocalClientPlayer()
    player.ClientCommand("CC_Weapon_Selector_Open")
	player.Signal("ChallengeStartRemoveCameras")
	DoF_SetFarDepth( 1, 300 )
	RunUIScript("OpenFRChallengesSettingsWpnSelector")
}

void function CloseFRChallengesSettingsWpnSelector()
{
	entity player = GetLocalClientPlayer()
	thread CoolCameraOnMenu()
	DoF_SetFarDepth( 6000, 10000 )
    player.ClientCommand("CC_Weapon_Selector_Close")
}

void function ExitChallengeClient()
{
	entity player = GetLocalClientPlayer()
	Signal(player, "ChallengeTimeOver")
    player.ClientCommand("CC_ExitChallenge")
}

string function ClientLocalizeAndShortenNumber_Float( float number, int maxDisplayIntegral = 3, int maxDisplayDecimal = 0 )
{
	if ( number == 0.0 )
		return "0"

	string thousandsSeparator = ""
	string decimalSeparator = "."
	string integralString = ""
	string integralSuffix = ""

	float integral = floor( number )
	int digits = int( floor( log10( integral ) + 1 ) )

	if ( digits > maxDisplayIntegral )
	{
	
		float displayIntegral = integral / pow( 10, (digits - 3) )
		displayIntegral = floor( displayIntegral )
		integralString = format( "%0.0f", displayIntegral )

		if ( digits/16 >= 1 )
			integralSuffix = Localize( "#STATS_VALUE_QUADRILLIONS" )
		else if ( digits/13 >= 1 )
			integralSuffix = Localize( "#STATS_VALUE_TRILLIONS" )
		else if ( digits/10 >= 1 )
			integralSuffix = Localize( "#STATS_VALUE_BILLIONS" )
		else if ( digits/7 >= 1 )
			integralSuffix = Localize( "#STATS_VALUE_MILLIONS" )
		else if ( digits/4 >= 1 )
			integralSuffix = Localize( "#STATS_VALUE_THOUSANDS" )
	}
	else
	{
		integralString = format( "%0.0f", integral )
	}

	if ( integralString.len() > 3 )
	{
		string separatedIntegralString = ""
		int integralsAdded = 0

	
		for ( int i = integralString.len(); i > 0; i-- )
		{
			string num = integralString.slice( i-1, i )
			if ( (separatedIntegralString.len() - integralsAdded) % 3 == 0 && separatedIntegralString.len() > 0 )
			{
				integralsAdded++
				separatedIntegralString = num + thousandsSeparator + separatedIntegralString
			}
			else
			{
				separatedIntegralString = num + separatedIntegralString
			}

		}

		integralString = separatedIntegralString
	}

	if ( integralString.len() <= 3 && integralString != "0" && digits > 3 )
	{
		int separatorPos
		if ( maxDisplayIntegral == 3 )
			separatorPos = (digits - maxDisplayIntegral) % 3
		else
			separatorPos = ((digits - maxDisplayIntegral) % 3) + 1

		if( separatorPos != 0 && separatorPos != 3 )
			integralString = integralString.slice( 0, separatorPos ) + decimalSeparator + integralString.slice( separatorPos, integralString.len() ) + integralSuffix
		else
			integralString += integralSuffix
	}

	float decimal = 0.0
	string decimalString = ""

	decimal = number % 1
	decimalString = string( decimal )

	if ( decimalString.find( "0." ) != -1 )
		decimalString = decimalString.slice( 2 )

	if ( decimalString.len() > maxDisplayDecimal )
		decimalString = decimalString.slice( 0, maxDisplayDecimal )

	string finalDisplayNumber = integralString

	if ( maxDisplayDecimal > 0 && decimal != 0.0 )
	{
		finalDisplayNumber += decimalSeparator + decimalString
	}

	return finalDisplayNumber
}

void function ServerCallback_CreateDistanceMarkerForGrenadesChallengeDummies(entity dummy, entity player)
{
	var rui = AddOverheadIcon( dummy, $"", true, $"ui/overhead_icon_generic.rpak" )
	RuiSetFloat2( rui, "iconSize", <10,10,0> )
	RuiSetFloat( rui, "distanceFade", 9000 )
	RuiSetBool( rui, "adsFade", false )
	RuiSetString( rui, "hint", ClientLocalizeAndShortenNumber_Float(Distance(dummy.GetOrigin(), player.GetOrigin())*0.03, 4, 0) + "m" )
}

// AIM TRAINER 2.0
// BY CAFEFPS

// ApexVaaks Scenarios Client Functions

//fix no auto weapon
//script_ui CloseAllMenus();script_client Start1Wall6TargetsClient()
void function Start1Wall6TargetsClient()
{
	entity player = GetLocalClientPlayer()
	ScreenFade( player, 0, 0, 0, 255, 1, 1, FFADE_IN | FFADE_PURGE )
	thread CreateDescriptionRUI("Click 6 static targets arranged on the front wall as fast as possible.")
	thread CreateTimerRUIandSTATS()	
	player.ClientCommand("CC_StartChallenge 1wall6targets")
}

//script_ui CloseAllMenus();script_client StartCloseLongStrafesClient()
void function StartCloseLongStrafesClient()
{
	entity player = GetLocalClientPlayer()
	ScreenFade( player, 0, 0, 0, 255, 1, 1, FFADE_IN | FFADE_PURGE )
	thread CreateDescriptionRUI("Track a single target moving horizontally across the full room width.")
	thread CreateTimerRUIandSTATS()	
	player.ClientCommand("CC_StartChallenge close_long_strafes")
}

//like 1Wall6Targets but 3d space
//fix no auto weapon
//script_ui CloseAllMenus();script_client StartTileFrenzyStrafingClient()
void function StartTileFrenzyStrafingClient()
{
	entity player = GetLocalClientPlayer()
	ScreenFade( player, 0, 0, 0, 255, 1, 1, FFADE_IN | FFADE_PURGE )
	thread CreateDescriptionRUI("Move with WASD and click targets spawning randomly across the tile grid.")
	thread CreateTimerRUIandSTATS()	
	player.ClientCommand("CC_StartChallenge tile_frenzy")
}

//script_ui CloseAllMenus();script_client StartPatternTrackingScenarioClient()
void function StartPatternTrackingScenarioClient()
{
	entity player = GetLocalClientPlayer()
	ScreenFade( player, 0, 0, 0, 255, 1, 1, FFADE_IN | FFADE_PURGE )
	thread CreateDescriptionRUI("Track the single ball following a predictable corner-to-corner pattern.")
	thread CreateTimerRUIandSTATS()	
	player.ClientCommand("CC_StartChallenge pattern_tracking")
}

//script_ui CloseAllMenus();script_client StartBouncingTrackingScenarioClient()
void function StartBouncingTrackingScenarioClient()
{
	entity player = GetLocalClientPlayer()
	ScreenFade( player, 0, 0, 0, 255, 1, 1, FFADE_IN | FFADE_PURGE )
	thread CreateDescriptionRUI("Track a ball with bouncing physics.")
	thread CreateTimerRUIandSTATS()	
	player.ClientCommand("CC_StartChallenge bouncing_tracking")
}

//script_ui CloseAllMenus();script_client StartMultiBallHealthTrackingClient()
void function StartMultiBallHealthTrackingClient()
{
	entity player = GetLocalClientPlayer()
	ScreenFade( player, 0, 0, 0, 255, 1, 1, FFADE_IN | FFADE_PURGE )
	thread CreateDescriptionRUI("Track and kill the balls with fixed speed. New balls spawn when killed.")
	thread CreateTimerRUIandSTATS()	
	player.ClientCommand("CC_StartChallenge multiball_health")
}

//script_ui CloseAllMenus();script_client StartRandomSpeedTrackingClient()
void function StartRandomSpeedTrackingClient()
{
	entity player = GetLocalClientPlayer()
	ScreenFade( player, 0, 0, 0, 255, 1, 1, FFADE_IN | FFADE_PURGE )
	thread CreateDescriptionRUI("Track and kill the balls with random speed. New balls spawn when killed.")
	thread CreateTimerRUIandSTATS()	
	player.ClientCommand("CC_StartChallenge random_speed")
}

//script_ui CloseAllMenus();script_client StartAntiMirrorStrafingClient()
void function StartAntiMirrorStrafingClient()
{
	entity player = GetLocalClientPlayer()
	ScreenFade( player, 0, 0, 0, 255, 1, 1, FFADE_IN | FFADE_PURGE )
	thread CreateDescriptionRUI("Track the target with fast, unpredictable strafing movement around you. Score only while anti-mirroring the target's movement.")
	thread CreateTimerRUIandSTATS()
	
	// EnableApexvaaksNewHud( true )
	
	player.ClientCommand("CC_StartChallenge anti_mirror")
}

//script_ui CloseAllMenus();script_client StartMirrorStrafingClient()
void function StartMirrorStrafingClient()
{
	entity player = GetLocalClientPlayer()
	ScreenFade( player, 0, 0, 0, 255, 1, 1, FFADE_IN | FFADE_PURGE )
	thread CreateDescriptionRUI("Track the target with fast, unpredictable strafing movement around you. Score only while mirroring the target's movement.")
	thread CreateTimerRUIandSTATS()
	
	// EnableApexvaaksNewHud( true )
	
	player.ClientCommand("CC_StartChallenge mirror")
}

void function EnableApexvaaksNewHud( bool show )
{
	array<var> elements
	elements.append( HudElement( "FS_AimTrainer2_Score" ) )
	elements.append( HudElement( "FS_AimTrainer2_Mirror" ) )
	elements.append( HudElement( "FS_AimTrainer2_AntiMirror" ) )
	elements.append( HudElement( "FS_AimTrainer2_TotalScore" ) )
	
	foreach( elem in elements )
		if( show )
			elem.Show()
		else
			elem.Hide()
}

void function AimTrainer_SetPatstrafeHudValues( float score, float mirror, float antimirror, float totalscore, bool isMirroring )
{
	EnableApexvaaksNewHud( true )
	
	string scoreText = isMirroring ? "Mirror Distance Score: " : "Anti-Mirror Distance Score: "
	Hud_SetText( HudElement( "FS_AimTrainer2_Score" ), scoreText + Round( score, 2 ).tostring() )
	Hud_SetText( HudElement( "FS_AimTrainer2_Mirror" ), "Mirror: " + Round( mirror, 2 ).tostring() + " %" )
	Hud_SetText( HudElement( "FS_AimTrainer2_AntiMirror" ), "Anti-Mirror: " + Round( antimirror, 2 ).tostring() + " %" )
	Hud_SetText( HudElement( "FS_AimTrainer2_TotalScore" ), "Total Score: " + Round( totalscore, 2 ).tostring() )
}

//script_ui CloseAllMenus();script_client StartPopcornPhysicsClient()
void function StartPopcornPhysicsClient()
{
	entity player = GetLocalClientPlayer()
	ScreenFade( player, 0, 0, 0, 255, 1, 1, FFADE_IN | FFADE_PURGE )
	thread CreateDescriptionRUI("Physics-based popcorn targets bounce around the room with realistic movement.")
	thread CreateTimerRUIandSTATS()	
	player.ClientCommand("CC_StartChallenge popcorn_physics")
}
