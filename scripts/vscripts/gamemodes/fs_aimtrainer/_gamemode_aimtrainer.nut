global function  _ChallengesByColombia_Init
global function StartFRChallenges
global function CreateMovementMapDummie
global function CreateMovementMapDummieFromMapLoad
global function CC_MenuGiveAimTrainerWeapon
global function CC_AimTrainer_SelectWeaponSlot
global function CC_AimTrainer_CloseWeaponSelector
global function CreateAimtrainerDeathbox


struct{
	array<entity> floor
	array<entity> dummies
	array<entity> props
} ChallengesEntities

struct
{
	float helmet_lv4 = 0.65
	
} settings 

struct
{
	// AntiMirrorStrafing persistent scoring variables
	float antiMirrorStrafingConditionalScore = 0.0
	float antiMirrorStrafingMirrorTime = 0.0
	float antiMirrorStrafingAntiMirrorTime = 0.0
	float antiMirrorStrafingTotalTime = 0.0
	
	// 1Wall6Targets occupied positions tracking
	array<vector> occupied1Wall6Positions = []
	
	// Challenge timing for duration validation
	float challengeStartTime = 0.0
	
	vector floorLocation
	vector floorLocationSky
	vector floorCenterForPlayer
	vector floorCenterForPlayerSky
	vector floorCenterForButton
	vector onGroundLocationPos
	vector onGroundLocationAngs
	vector onGroundDummyPos
	vector AimTrainer_startPos
	vector AimTrainer_startAngs
	
} file

table<int, array<ChallengeScore> > ChallengesData //implement this
table<int, int> ChallengesBestScores

//Challenge Registry for unified CC_StartChallenge command
struct ChallengeInfo
{
	void functionref(entity) challengeFunc
	void functionref(entity, bool) challengeFuncWithParam = null
	int challengeId
	bool requiresParameter = false
}

table<string, ChallengeInfo> challengeRegistry

//Wrapper functions to handle optional parameters properly
void function StartPopcornChallenge_Normal(entity player, bool variant)
{
	StartPopcornChallenge(player, variant)
}

void function StartAntiMirrorStrafingChallenge_Wrapper(entity player, bool isMirror)
{
	StartAntiMirrorStrafingChallenge(player, isMirror)
}

void function _ChallengesByColombia_Init()
{
	//Increase client command limit to 60
	SetConVarInt("sv_quota_stringCmdsPerSecond", 60)
	SetConVarInt("net_processTimeBudget", 0 )

	//Initialize challenge registry
	InitializeChallengeRegistry()
	
	//Unified challenge starter command - replaces all individual CC_Start* commands
	AddClientCommandCallback("CC_StartChallenge", CC_StartChallenge_Unified)
	
	//settings buttons
	AddClientCommandCallback("CC_Weapon_Selector_Open", CC_Weapon_Selector_Open)
	AddClientCommandCallback("CC_Weapon_Selector_Close", CC_Weapon_Selector_Close)
	AddClientCommandCallback("CC_ChangeChallengeDuration", CC_ChangeChallengeDuration)
	AddClientCommandCallback("CC_AimTrainer_AI_SHIELDS_LEVEL", CC_AimTrainer_AI_SHIELDS_LEVEL)
	AddClientCommandCallback("CC_AimTrainer_STRAFING_SPEED", CC_AimTrainer_STRAFING_SPEED)
	AddClientCommandCallback("CC_AimTrainer_SPAWN_DISTANCE", CC_AimTrainer_SPAWN_DISTANCE)
	AddClientCommandCallback("CC_AimTrainer_AI_HEALTH", CC_AimTrainer_AI_HEALTH)
	AddClientCommandCallback("CC_RGB_HUD", CC_RGB_HUD)
	AddClientCommandCallback("CC_AimTrainer_INFINITE_CHALLENGE", CC_AimTrainer_INFINITE_CHALLENGE)
	AddClientCommandCallback("CC_AimTrainer_INFINITE_AMMO", CC_AimTrainer_INFINITE_AMMO)
	AddClientCommandCallback("CC_AimTrainer_INFINITE_AMMO2", CC_AimTrainer_INFINITE_AMMO2)
	AddClientCommandCallback("CC_AimTrainer_INMORTAL_TARGETS", CC_AimTrainer_INMORTAL_TARGETS)
	AddClientCommandCallback("CC_AimTrainer_DUMMIES_COLOR", CC_AimTrainer_DUMMIES_COLOR)
	AddClientCommandCallback("CC_AimTrainer_USER_WANNA_BE_A_DUMMY", CC_AimTrainer_USER_WANNA_BE_A_DUMMY)
	AddClientCommandCallback("CC_MenuGiveAimTrainerWeapon", CC_MenuGiveAimTrainerWeapon) 
	AddClientCommandCallback("CC_ExitChallenge", CC_ExitChallenge)
	AddClientCommandCallback("CC_AimTrainer_SelectWeaponSlot", CC_AimTrainer_SelectWeaponSlot)
	AddClientCommandCallback("CC_AimTrainer_WeaponSelectorClose", CC_AimTrainer_CloseWeaponSelector)
	
	//tracking challenge settings
	AddClientCommandCallback("CC_AimTrainer_TRACKING_SPEED", CC_AimTrainer_TRACKING_SPEED)
	AddClientCommandCallback("CC_AimTrainer_TRACKING_TILES_HORIZONTAL", CC_AimTrainer_TRACKING_TILES_HORIZONTAL)
	AddClientCommandCallback("CC_AimTrainer_TRACKING_TILES_VERTICAL", CC_AimTrainer_TRACKING_TILES_VERTICAL)
	AddClientCommandCallback("CC_AimTrainer_TRACKING_TARGET_SCALE", CC_AimTrainer_TRACKING_TARGET_SCALE)
	AddClientCommandCallback("CC_AimTrainer_TRACKING_TILES_DEPTH", CC_AimTrainer_TRACKING_TILES_DEPTH)
	AddClientCommandCallback("CC_AimTrainer_TRACKING_RANDOM_START", CC_AimTrainer_TRACKING_RANDOM_START)
	
	//results menu skip and restart button callback
	AddClientCommandCallback("ChallengesSkipButton", CC_ChallengesSkipButton)
	AddClientCommandCallback("CC_RestartChallenge", CC_RestartChallenge)
	
	//on weapon attack callback so we can calculate stats for live stats and results menu
	AddCallback_OnWeaponAttack( OnWeaponAttackChallenges )

	AddCallback_OnClientConnected( StartFRChallenges )
		
	//arc stars on damage callback for arc stars practice challenge
	AddDamageCallbackSourceID( eDamageSourceId.damagedef_ticky_arc_blast, Arcstar_OnStick )
	AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_grenade_emp, Arcstar_OnStick )
	
	SurvivalFreefall_Init() //Enables freefall/skydive
	
	//required assets for different challenges
	PrecacheParticleSystem($"P_enemy_jump_jet_ON_trails")
	PrecacheParticleSystem( $"P_skydive_trail_CP" )
	PrecacheParticleSystem( FIRINGRANGE_ITEM_RESPAWN_PARTICLE )
	PrecacheModel($"mdl/imc_interior/imc_int_fusebox_01.rmdl")
	PrecacheModel($"mdl/barriers/shooting_range_target_02.rmdl")
	PrecacheModel($"mdl/thunderdome/thunderdome_cage_wall_256x256_01.rmdl")
	PrecacheModel($"mdl/thunderdome/thunderdome_cage_ceiling_256x256_06.rmdl")
	PrecacheModel( $"mdl/pipes/slum_pipe_large_yellow_256_02.rmdl" )
	PrecacheModel( AIMTRAINER_TRACKING_MODEL )
	PrecacheModel( $"mdl/flowstate_custom/cafe_floor.rmdl" )
	PrecacheWeapon( "mp_weapon_lightninggun_nomodel" )
	
	//death callback for player because some challenges can kill player
	AddDeathCallback( "player", OnPlayerDeathCallback )
	
	switch( MapName() )
	{
		case eMaps.mp_rr_desertlands_64k_x_64k:
		case eMaps.mp_rr_desertlands_64k_x_64k_nx:
		case eMaps.mp_rr_desertlands_64k_x_64k_tt:
		case eMaps.mp_rr_desertlands_mu1:
		case eMaps.mp_rr_desertlands_mu1_tt:
		case eMaps.mp_rr_desertlands_mu2:
		case eMaps.mp_rr_desertlands_holiday:
			file.floorLocation = <-10020.1543, -8643.02832, 5189.92578>
			file.floorLocationSky = <-10020.1543, -8643.02832, 50189.92578>
			
			file.onGroundLocationPos = <12891.2783, -2391.77124, -3121.60132>
			file.onGroundLocationAngs = <0, -157.629303, 0>
			file.AimTrainer_startPos = <10623.7773, 4953.48975, -4303.92041>
			file.AimTrainer_startAngs = <0, 143.031052, 0>	
		break

		case eMaps.mp_rr_canyonlands_staging:
			file.floorLocation = <35306.2344, -16956.5098, -27010.2539>
			file.floorLocationSky =  <35306.2344, -16956.5098, -27010.2539>
			
			file.onGroundLocationPos = <33946,-6511,-28859>
			file.onGroundLocationAngs = <0,-90,0>
			file.AimTrainer_startPos = <32645.04,-9575.77,-25911.94>
			file.AimTrainer_startAngs = <7.71,91.67,0.00>	
		break

		case eMaps.mp_rr_canyonlands_mu1:
		case eMaps.mp_rr_canyonlands_mu1_night:
		case eMaps.mp_rr_canyonlands_64k_x_64k:
		case eMaps.mp_rr_canyonlands_mu2:
		case eMaps.mp_rr_canyonlands_mu2_tt:
		case eMaps.mp_rr_canyonlands_mu2_mv:
		case eMaps.mp_rr_canyonlands_mu2_ufo:
			file.floorLocation = <-11964.7803, -8858.25098, 17252.25>
			file.floorLocationSky = <-11964.7803, -8858.25098, 17252.25>
			
			file.onGroundLocationPos = <-14599.2178, -7073.89551, 2703.93286>
			file.onGroundLocationAngs = <0,90,0>
			file.AimTrainer_startPos = <-16613.873, -487.12088, 3312.10791>
			file.AimTrainer_startAngs = <0, 144.184357, 0>
		break

		case eMaps.mp_rr_olympus:
		case eMaps.mp_rr_olympus_tt:
			file.floorLocation = <9857.08496, -7948.96631, -1000>
			file.floorLocationSky = <9857.08496, -7948.96631, -1000>
			
			file.onGroundLocationPos = <-13700.8594, 26238.1387, -6891.95508>
			file.onGroundLocationAngs = <0, 175.306152, 0>
			file.AimTrainer_startPos = <-34234.2148, 9426.86426, -5563.96875>
			file.AimTrainer_startAngs = <0, 69.2027512, 0>
		break
		
		default:
		// cutsceneSpawns.append(NewCameraPair(<-3096.13501, 632.377991, 1913.47217>, <0, -134.430405, 0> ))
		
		break
	}

	file.floorCenterForPlayer = <file.floorLocation.x+3840, file.floorLocation.y+3840, file.floorLocation.z+200>
	file.floorCenterForPlayerSky = <file.floorLocationSky.x+3840, file.floorLocationSky.y+3840, file.floorLocationSky.z+200>
	
	file.floorCenterForButton = <file.floorLocation.x+3840+200, file.floorLocation.y+3840, file.floorLocation.z+18>
	
	for(int i = 0; i<50; i++)
	{
		ChallengesData[i] <- []
		ChallengesBestScores[i] <- 0
	}	
	
	settings.helmet_lv4 = GetCurrentPlaylistVarFloat( "helmet_lv4", 0.65 )
	
	AddCallback_EntitiesDidLoad( _EntitiesDidLoad )
}


void function _EntitiesDidLoad()
{
	// entity clight = GetEnt( "env_cascade_light" )
	// clight.Destroy()
	SetConVarFloat( "mat_sun_scale", 0.0 )
}

void function StartFRChallenges(entity player)
{
	Remote_CallFunction_NonReplay(player, "ServerCallback_CoolCameraOnMenu")
	Remote_CallFunction_NonReplay(player, "ServerCallback_OpenFRChallengesMainMenu", 0)

	player.SetOrigin(file.AimTrainer_startPos)
	player.SetAngles(file.AimTrainer_startAngs)

	player.p.isChallengeActivated = false
	SetServerVar( "minimapState", eMinimapState.Hidden)
	printt( "Aimtrainer Start" )
	
	SetGameState( eGameState.Playing )
		
	StartInputDetectorForPlayer( player )
}

void function ResetChallengeStats(entity player)
{
	if(!player.IsPlayer()) return
	
	ChallengesEntities.dummies = []
	ChallengesEntities.floor = []
	ChallengesEntities.props = []
	
	player.p.storedWeapons.clear()
	if(!player.p.isRestartingLevel)
		player.p.challengeName = 0
	player.p.straferDummyKilledCount = 0
	player.p.straferShotsHit = 0
	player.p.straferTotalShots = 0
	player.p.straferChallengeDamage = 0
	player.p.straferCriticalShots = 0
	player.p.isChallengeActivated = false
	Remote_CallFunction_NonReplay(player, "ServerCallback_SetChallengeActivated", false)
	player.p.isNewBestScore = false
}

void function SetCommonDummyLines(entity dummy)
{
	dummy.SetTakeDamageType( DAMAGE_YES )
	dummy.SetDamageNotifications( true )
	dummy.SetDeathNotifications( true )
	dummy.SetValidHealthBarTarget( true )
	SetObjectCanBeMeleed( dummy, true )
	
	if( AimTrainer_STRAFING_SPEED == 0 )
	{
		dummy.EnableNPCFlag( NPC_IGNORE_ALL | NPC_DISABLE_SENSING)
		dummy.DisableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE | NPC_USE_SHOOTING_COVER )
	}
	
	if(AimTrainer_AI_COLOR == 5)
		dummy.SetSkin(RandomIntRangeInclusive(1,4))
	else
		dummy.SetSkin(AimTrainer_AI_COLOR)
	
	dummy.DisableHibernation()
}

vector function AimTrainerOriginToGround( vector origin )
{
	vector endOrigin         = <origin.x, origin.y, -MAX_WORLD_COORD_BUFFER >
	TraceResults traceResult = TraceLine( origin, endOrigin, [], TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_NONE )

	return traceResult.endPos
}

//CHALLENGE "Strafing dummies"
void function StartStraferDummyChallenge(entity player)
{
	if(!IsValid(player)) return
	player.SetOrigin(file.onGroundLocationPos)
	player.SetAngles(file.onGroundLocationAngs)
	
	EndSignal(player, "ChallengeTimeOver")
	OnThreadEnd(
		function() : ( player)
		{
			OnChallengeEnd(player)
		}
	)
	
	wait AimTrainer_PRE_START_TIME
	RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD_INSTANT )
	RemoveCinematicFlag( player, CE_FLAG_HIDE_PERMANENT_HUD)
	player.UnfreezeControlsOnServer()
	float endtime = Time() + AimTrainer_CHALLENGE_DURATION
	thread ChallengeWatcherThread(endtime, player)

	while(true){
		if(!AimTrainer_INFINITE_CHALLENGE && Time() > endtime) break
		vector dummypos = player.GetOrigin() + AnglesToForward(file.onGroundLocationAngs)*100*AimTrainer_SPAWN_DISTANCE
		entity dummy = CreateDummy( 99, AimTrainerOriginToGround( dummypos + Vector(0,0,10000)), Vector(0,0,0) )
		vector pos = dummy.GetOrigin()
		vector angles = dummy.GetAngles()
		StartParticleEffectInWorld( GetParticleSystemIndex( FIRINGRANGE_ITEM_RESPAWN_PARTICLE ), pos, angles )
		DispatchSpawn( dummy )
		
		dummy.SetOrigin(dummy.GetOrigin() + Vector(0,0,1))
		dummy.SetShieldHealthMax( ReturnShieldAmountForDesiredLevel() )
		dummy.SetShieldHealth( ReturnShieldAmountForDesiredLevel() )
		dummy.SetMaxHealth( AimTrainer_AI_HEALTH )
		dummy.SetHealth( AimTrainer_AI_HEALTH )
		
		SetCommonDummyLines(dummy)
		
		AddEntityCallback_OnDamaged(dummy, OnStraferDummyDamaged)
		AddEntityCallback_OnKilled(dummy, OnDummyKilled)
		
		if( AimTrainer_STRAFING_SPEED > 0 )
			waitthread StrafeMovement(dummy, player)
		else
			WaitSignal(dummy, "OnDeath")
		
		wait 0.2
	}
}

void function StrafeMovement(entity ai, entity player)
{
	ai.EndSignal("OnDeath")
	player.EndSignal("ChallengeTimeOver")
	
	OnThreadEnd(
		function() : ( ai )
		{
			if(IsValid(ai)) ai.Destroy()
			ChallengesEntities.dummies.removebyvalue(dummy)
		}
	)

	while(IsValid(ai))
	{
		ai.SetAngles(VectorToAngles( player.GetOrigin() - ai.GetOrigin()))
		
		int random = RandomIntRangeInclusive(1,10)
		if (random == 9 || random == 10){
			ai.Anim_ScriptedPlayActivityByName( "ACT_STAND", true, 0.1 )
			ai.Anim_SetPlaybackRate(AimTrainer_STRAFING_SPEED)
			wait RandomFloatRange(0.05,0.25)*(1/AimTrainer_STRAFING_SPEED_WAITTIME)
		}
		else
		{
			ai.Anim_ScriptedPlayActivityByName( "ACT_RUN_RIGHT", true, 0.1 )
			ai.Anim_SetPlaybackRate(AimTrainer_STRAFING_SPEED)
			wait RandomFloatRange(0.2,0.75)*(1/AimTrainer_STRAFING_SPEED_WAITTIME)
			ai.Anim_ScriptedPlayActivityByName( "ACT_RUN_LEFT", true, 0.1 )
			ai.Anim_SetPlaybackRate(AimTrainer_STRAFING_SPEED)
			wait RandomFloatRange(0.2,0.75)*(1/AimTrainer_STRAFING_SPEED_WAITTIME)
		}
	}
}

//CHALLENGE "Switching targets"
void function StartSwapFocusDummyChallenge(entity player)
{
	if(!IsValid(player)) return
	
	player.SetOrigin(file.onGroundLocationPos)
	player.SetAngles(file.onGroundLocationAngs)
	EndSignal(player, "ChallengeTimeOver")
	
	OnThreadEnd(
		function() : ( player)
		{
			OnChallengeEnd(player)
		}
	)
	
	array<vector> circleLocations

	wait AimTrainer_PRE_START_TIME
	RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD_INSTANT )
	RemoveCinematicFlag( player, CE_FLAG_HIDE_PERMANENT_HUD)
	player.UnfreezeControlsOnServer()
	float endtime = Time() + AimTrainer_CHALLENGE_DURATION
	thread ChallengeWatcherThread(endtime, player)

	while(true){
		circleLocations.clear()
		for(int i = 0; i < 20; i ++)
			{
				float r = float(i) / float(20) * 2 * PI
				vector origin2 = Vector(0,0,0) + player.GetOrigin() + 100 * AimTrainer_SPAWN_DISTANCE * <sin( r ), cos( r ), 0.0>
				circleLocations.append(origin2)
				
				foreach(dummy in GetNPCArray())
				{
					float distance = Distance(dummy.GetOrigin(), origin2)
					if(distance < 200)
						circleLocations.removebyvalue(origin2)
				}		
			}
		if(circleLocations.len() == 0) //fix for rare case
		{
			for(int i = 0; i < 20; i ++)
				{
					float r = float(i) / float(20) * 2 * PI
					vector origin2 = Vector(0,0,0) + player.GetOrigin() + 100 * AimTrainer_SPAWN_DISTANCE * <sin( r ), cos( r ), 0.0>
					circleLocations.append(origin2)
				}
		}
		circleLocations.randomize()
		
		if(!AimTrainer_INFINITE_CHALLENGE && Time() > endtime) break		
		if(ChallengesEntities.dummies.len()<5){

			vector circleoriginfordummy = FS_GetGoodPosForTSDummy( circleLocations )
			entity dummy = CreateDummy( 99, circleoriginfordummy, file.onGroundLocationAngs*-1 )
			vector pos = dummy.GetOrigin()
			vector angles = dummy.GetAngles()
			StartParticleEffectInWorld( GetParticleSystemIndex( FIRINGRANGE_ITEM_RESPAWN_PARTICLE ), pos, angles )
			SetSpawnOption_AISettings( dummy, "npc_dummie_combat_trainer" )
			DispatchSpawn( dummy )
			PutEntityInSafeSpot( dummy, null, null, dummy.GetOrigin() + AnglesToForward ( dummy.GetAngles() ) * 30, dummy.GetOrigin() )
			dummy.SetOrigin(dummy.GetOrigin() + Vector(0,0,5))
			
			//PutEntityInSafeSpot( dummy, null, null, dummy.GetOrigin() + dummy.GetUpVector()*2048 + dummy.GetForwardVector()*2048 , dummy.GetOrigin() )
	
			dummy.SetShieldHealthMax( ReturnShieldAmountForDesiredLevel() )
			dummy.SetShieldHealth( ReturnShieldAmountForDesiredLevel() )
			dummy.SetMaxHealth( AimTrainer_AI_HEALTH )
			dummy.SetHealth( AimTrainer_AI_HEALTH )
			SetCommonDummyLines(dummy)
			ChallengesEntities.dummies.append(dummy)

			AddEntityCallback_OnDamaged(dummy, OnStraferDummyDamaged)
			AddEntityCallback_OnKilled(dummy, OnDummyKilled)

			thread TargetSwitcthingWatcher(dummy, player)
		}
		WaitFrame()
	}
}

vector function FS_GetGoodPosForTSDummy( array<vector> circleLocations )
{
	foreach( pos in circleLocations )
	{
		if( !FS_PosCanContainDummy( pos ) )
		{
			// printt( pos, " didn't work" )
			continue
		}
		
		return pos
	}
	
	return circleLocations.getrandom()
}

bool function FS_PosCanContainDummy( vector origin )
{
	vector endpos = <origin.x, origin.y, -MAX_WORLD_COORD_BUFFER >

	TraceResults result = TraceHull( origin, endpos, <-16, -16, 0>, <16, 16, 150>, [], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER ) // dummy ocupa 72 pero probemos 150
	if ( result.startSolid || result.fraction >= 1 )
	{
		
		return true
	}
	
	return false
}

void function TargetSwitcthingWatcher(entity ai, entity player)
{
	ai.EndSignal("OnDeath")
	player.EndSignal("ChallengeTimeOver")
	
	OnThreadEnd(
		function() : ( ai )
		{
			if(IsValid(ai)) ai.Destroy()
			ChallengesEntities.dummies.removebyvalue(ai)
		}
	)
	WaitFrame()
	while(IsValid(ai))
    {
		ai.SetAngles(<0,VectorToAngles( player.GetOrigin() - ai.GetOrigin()).y,0>)
		
		if( Distance( ai.GetOrigin(), player.GetOrigin() ) > 3000 )
		{
			ai.Destroy()
			break
		}

		if(AimTrainer_STRAFING_SPEED == 0)
		{
			WaitFrame()
			continue
		}
		
        int random = RandomIntRangeInclusive(1,6)
        if(random == 1 || random == 2 || random == 3){
        //w s strafe
            ai.Anim_ScriptedPlayActivityByName( "ACT_SPRINT_RIGHT", true, 0.1 )
			ai.Anim_SetPlaybackRate(AimTrainer_STRAFING_SPEED)
            wait 0.4*(1/AimTrainer_STRAFING_SPEED_WAITTIME)
            ai.Anim_ScriptedPlayActivityByName( "ACT_SPRINT_LEFT", true, 0.1 )
			ai.Anim_SetPlaybackRate(AimTrainer_STRAFING_SPEED)
            wait 0.4*(1/AimTrainer_STRAFING_SPEED_WAITTIME)
        }
        else if(random == 4 || random == 5){
        //a d strafe
            ai.Anim_ScriptedPlayActivityByName( "ACT_SPRINT_FORWARD", true, 0.1 )
			ai.Anim_SetPlaybackRate(AimTrainer_STRAFING_SPEED)
            wait 0.4*(1/AimTrainer_STRAFING_SPEED_WAITTIME)
            ai.Anim_ScriptedPlayActivityByName( "ACT_SPRINT_BACKWARD", true, 0.1 )
			ai.Anim_SetPlaybackRate(AimTrainer_STRAFING_SPEED)
            wait 0.4*(1/AimTrainer_STRAFING_SPEED_WAITTIME)
        }
        else if (random == 6){
        //a d small crouch strafe
            ai.Anim_ScriptedPlayActivityByName( "ACT_STRAFE_TO_CROUCH_LEFT", true, 0.1 )
			ai.Anim_SetPlaybackRate(AimTrainer_STRAFING_SPEED)
            wait 0.4*(1/AimTrainer_STRAFING_SPEED_WAITTIME)
            ai.Anim_ScriptedPlayActivityByName( "ACT_STRAFE_TO_CROUCH_RIGHT", true, 0.1 )
			ai.Anim_SetPlaybackRate(AimTrainer_STRAFING_SPEED)
            wait 0.4*(1/AimTrainer_STRAFING_SPEED_WAITTIME)
        }
    }
}

//CHALLENGE "Floating target"
void function StartFloatingTargetChallenge(entity player)
{
	if(!IsValid(player)) return

	player.SetOrigin(file.floorCenterForPlayer)
	player.SetAngles(Vector(0,-90,0))
	EndSignal(player, "ChallengeTimeOver")
	ChallengesEntities.floor = CreateFloorAtOrigin(file.floorLocation, 30, 30)
	
	OnThreadEnd(
		function() : ( player)
		{
		OnChallengeEnd(player)
		}
	)
	
	wait AimTrainer_PRE_START_TIME
	RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD_INSTANT )
	RemoveCinematicFlag( player, CE_FLAG_HIDE_PERMANENT_HUD)
	player.UnfreezeControlsOnServer()
	float endtime = Time() + AimTrainer_CHALLENGE_DURATION	
	thread ChallengeWatcherThread(endtime, player)

	while(true){
		if(!AimTrainer_INFINITE_CHALLENGE && Time() > endtime) break	
		entity dummy = CreateDummy(99, player.GetOrigin() + AnglesToForward(player.GetAngles())* 100 * AimTrainer_SPAWN_DISTANCE, Vector(0,90,0))
		vector pos = dummy.GetOrigin()
		vector angles = dummy.GetAngles()
		StartParticleEffectInWorld( GetParticleSystemIndex( FIRINGRANGE_ITEM_RESPAWN_PARTICLE ), pos, angles )
		SetSpawnOption_AISettings( dummy, "npc_dummie_combat_trainer" )
		DispatchSpawn( dummy )	
		dummy.SetShieldHealthMax( ReturnShieldAmountForDesiredLevel() )
		dummy.SetShieldHealth( ReturnShieldAmountForDesiredLevel() )
		dummy.SetMaxHealth( AimTrainer_AI_HEALTH )
		dummy.SetHealth( AimTrainer_AI_HEALTH )
		SetCommonDummyLines(dummy)
		AddEntityCallback_OnDamaged(dummy, OnFloatingDummyDamaged)
		AddEntityCallback_OnKilled(dummy, OnDummyKilled)
		ChallengesEntities.dummies.append(dummy)
		
		array<string> attachments = [ "vent_left", "vent_right" ]
		foreach ( attachment in attachments )
			{
					int enemyID    = GetParticleSystemIndex( $"P_enemy_jump_jet_ON_trails" )
					entity enemyFX = StartParticleEffectOnEntity_ReturnEntity( dummy, enemyID, FX_PATTACH_POINT_FOLLOW, dummy.LookupAttachment( attachment ) )
			}
		
		WaitSignal(dummy, "OnDeath") //pero es inmortal
		wait 0.5
	}
}

//CHALLENGE "Popcorn targets"
void function StartPopcornChallenge(entity player, bool secondvariant = false)
{
	if(!IsValid(player)) return
	
	player.SetOrigin(file.floorCenterForPlayer)
	player.SetAngles(Vector(0,-90,0))
	ChallengesEntities.floor = CreateFloorAtOrigin(file.floorLocation, 30, 30)
	EndSignal(player, "ChallengeTimeOver")
	
	OnThreadEnd(
		function() : ( player)
		{
			OnChallengeEnd(player)
		}
	)
	
	wait AimTrainer_PRE_START_TIME
	RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD_INSTANT )
	RemoveCinematicFlag( player, CE_FLAG_HIDE_PERMANENT_HUD)
	player.UnfreezeControlsOnServer()
	float endtime = Time() + AimTrainer_CHALLENGE_DURATION
	thread ChallengeWatcherThread(endtime, player)
	
	if(secondvariant)
		thread MakePlayerBounce(player)
	
	while(true){
		if(!AimTrainer_INFINITE_CHALLENGE && Time() > endtime) break
		if(ChallengesEntities.dummies.len()<7)
				thread CreateDummyPopcornChallenge(player)
		WaitFrame()
	}
}

void function CreateDummyPopcornChallenge(entity player)
{
	float r = float(RandomInt(6)) / float(6) * 2 * PI
	entity dummy = CreateDummy( 99, player.GetOrigin() + 50 * AimTrainer_SPAWN_DISTANCE * <sin( r ), cos( r ), 0.0>, <0,90,0> )
	EndSignal(dummy, "OnDeath")

	StartParticleEffectInWorld( GetParticleSystemIndex( FIRINGRANGE_ITEM_RESPAWN_PARTICLE ), dummy.GetOrigin(), dummy.GetAngles() )
	SetSpawnOption_AISettings( dummy, "npc_dummie_combat_trainer" )
	DispatchSpawn( dummy )	
	dummy.SetShieldHealthMax( ReturnShieldAmountForDesiredLevel() )
	dummy.SetShieldHealth( ReturnShieldAmountForDesiredLevel() )
	dummy.SetMaxHealth( AimTrainer_AI_HEALTH )
	dummy.SetHealth( AimTrainer_AI_HEALTH )
	SetCommonDummyLines(dummy)
	AddEntityCallback_OnDamaged(dummy, OnStraferDummyDamaged)
	AddEntityCallback_OnKilled(dummy, OnDummyKilled)
	ChallengesEntities.dummies.append(dummy)
	
	int random = 1				
	if(CoinFlip()) random = -1
	entity ai = dummy //im lazy to change the copy paste from below ok
				
	array<string> attachments = [ "vent_left", "vent_right" ]
	foreach ( attachment in attachments )
		{
				int enemyID    = GetParticleSystemIndex( $"P_enemy_jump_jet_ON_trails" )
				entity enemyFX = StartParticleEffectOnEntity_ReturnEntity( dummy, enemyID, FX_PATTACH_POINT_FOLLOW, dummy.LookupAttachment( attachment ) )
		}
	
	while( IsValid(ai) )
	{
		WaitFrame()

		if( ai.GetOrigin().z - file.floorLocation.z < 50)
		{
			vector angles2 = VectorToAngles( Vector(player.GetOrigin().x, player.GetOrigin().y, file.floorCenterForPlayer.z) - ai.GetOrigin())
			ai.SetAngles(Vector(0, angles2.y, 0))

			if( Distance( player.GetOrigin(), ai.GetOrigin() ) > 1500)
			{
				ai.SetVelocity(AnglesToForward( angles2 ) * 500 + AnglesToUp(angles2)*RandomFloatRange(512,1024))
				EmitSoundOnEntity( ai, "JumpPad_LaunchPlayer_3p" )
				continue
			}
			
			if(CoinFlip())
				random = 1
			else
				random = -1

			int random2 = RandomIntRangeInclusive(1,5)
			if(random2 == 5 || random2 == 4)
				ai.SetVelocity(AnglesToForward( angles2 ) * 128 + AnglesToUp(angles2)*RandomFloatRange(512,1024))
			else
				ai.SetVelocity((AnglesToRight( angles2 ) * RandomFloatRange(128,256) * random ) + AnglesToUp(angles2)*RandomFloatRange(512,1024))
				
			EmitSoundOnEntity( ai, "JumpPad_LaunchPlayer_3p" )
		}
	}
}

void function MakePlayerBounce(entity player)
{
	EndSignal(player, "ChallengeTimeOver")
	
	entity ai = player
	int random = 1				
	if(CoinFlip()) random = -1
	while(IsValid(ai)){		
		if( ai.GetOrigin().z - file.floorLocation.z < 50)
		{
			vector angles2 = player.GetAngles()
			
			if(CoinFlip())
				random = 1
			else
				random = -1

			int random2 = RandomIntRangeInclusive(1,5)
			if(random2 == 5)
				ai.SetVelocity(AnglesToForward( angles2 ) * 128 + AnglesToUp(angles2)*RandomFloatRange(512,1024))
			else
				ai.SetVelocity((AnglesToRight( angles2 ) * RandomFloatRange(128,256) * random ) + AnglesToUp(angles2)*RandomFloatRange(512,1024))
				
			EmitSoundOnEntity( ai, "JumpPad_LaunchPlayer_3p" )
		}
		WaitFrame()
	}	
}

//CHALLENGE "Shooting Valk's ult"
void function StartStraightUpChallenge(entity player)
{
	if(!IsValid(player)) return
	
	ChallengesEntities.floor = CreateFloorAtOrigin(file.floorLocation, 30, 30)
	player.SetOrigin(file.floorCenterForPlayer)
	player.SetAngles(Vector(0,180,0))
	EndSignal(player, "ChallengeTimeOver")
	
	OnThreadEnd(
		function() : ( player)
		{
			OnChallengeEnd(player)
		}
	)
	
	wait AimTrainer_PRE_START_TIME
	RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD_INSTANT )
	RemoveCinematicFlag( player, CE_FLAG_HIDE_PERMANENT_HUD)
	player.UnfreezeControlsOnServer()
	float endtime = Time() + AimTrainer_CHALLENGE_DURATION	
	thread ChallengeWatcherThread(endtime, player)
	
	while(true){
		if(!AimTrainer_INFINITE_CHALLENGE && Time() > endtime) break
		
		if(ChallengesEntities.dummies.len()<4){
				thread CreateDummyStraightUpChallenge(player)
				wait 2.5
			}
			WaitFrame()
	}
}

void function CreateDummyStraightUpChallenge(entity player)
{
	int random = 1
	if(CoinFlip()) random = -1
	
	int random2 = 1
	if(CoinFlip()) random2 = -1	
	
	entity dummy = CreateDummy( 99, player.GetOrigin() + AnglesToForward(player.GetAngles()) * RandomIntRange(100,500)* random * AimTrainer_SPAWN_DISTANCE + AnglesToRight(player.GetAngles())*RandomIntRange(100,900)*random2, Vector(0,180,0) )
	EndSignal(dummy, "OnDeath")
	EndSignal(player, "ChallengeTimeOver")
	
	OnThreadEnd(
		function() : ( dummy )
		{
			if(IsValid(dummy)) dummy.Destroy()
			ChallengesEntities.dummies.removebyvalue(dummy)
		}
	)
	
	StartParticleEffectInWorld( GetParticleSystemIndex( FIRINGRANGE_ITEM_RESPAWN_PARTICLE ), dummy.GetOrigin(), dummy.GetAngles())
	SetSpawnOption_AISettings( dummy, "npc_dummie_combat_trainer" )
	DispatchSpawn( dummy )	
	dummy.SetShieldHealthMax( ReturnShieldAmountForDesiredLevel() )
	dummy.SetShieldHealth( ReturnShieldAmountForDesiredLevel() )
	dummy.SetMaxHealth( AimTrainer_AI_HEALTH )
	dummy.SetHealth( AimTrainer_AI_HEALTH )
	SetCommonDummyLines(dummy)
	AddEntityCallback_OnDamaged(dummy, OnStraferDummyDamaged)
	AddEntityCallback_OnKilled(dummy, OnDummyKilled)
	ChallengesEntities.dummies.append(dummy)
	
	entity ai = dummy				
	array<string> attachments = [ "vent_left", "vent_right" ]
	foreach ( attachment in attachments )
		{
			int enemyID    = GetParticleSystemIndex( $"P_enemy_jump_jet_ON_trails" )
			entity enemyFX = StartParticleEffectOnEntity_ReturnEntity( dummy, enemyID, FX_PATTACH_POINT_FOLLOW, dummy.LookupAttachment( attachment ) )
		}
	EmitSoundOnEntity(dummy, "jumpjet_freefall_body_3p_enemy_OLD")
	
	int idk = 1348 //from retail
	float flyingTime = Time() + 5.0 //from retail
	while( Time() <= flyingTime )
	{
		dummy.SetVelocity( <dummy.GetVelocity().x, dummy.GetVelocity().y, idk> )
		WaitFrame()
	}
}

//CHALLENGE "Arcstars practice"
void function StartArcstarsChallenge(entity player)
{
	if(!IsValid(player)) return
	wait 0.1
	
	player.SetOrigin(file.onGroundLocationPos)
	player.SetAngles(file.onGroundLocationAngs)
	EndSignal(player, "ChallengeTimeOver")
	TakeAllWeapons(player)
	player.GiveWeapon( "mp_weapon_grenade_emp", WEAPON_INVENTORY_SLOT_PRIMARY_0, ["challenges_infinite_arcstars"] )
	player.SetActiveWeaponBySlot(eActiveInventorySlot.mainHand, WEAPON_INVENTORY_SLOT_PRIMARY_0)

	OnThreadEnd(
		function() : ( player)
		{
			TakeAllWeapons(player)
			GiveWeaponsFromStoredArray(player, player.p.storedWeapons)
			OnChallengeEnd(player)
		}
	)
	
	wait AimTrainer_PRE_START_TIME
	RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD_INSTANT )
	RemoveCinematicFlag( player, CE_FLAG_HIDE_PERMANENT_HUD)
	player.UnfreezeControlsOnServer()
	float endtime = Time() + AimTrainer_CHALLENGE_DURATION
	thread ChallengeWatcherThread(endtime, player)
	array<vector> circleLocations

	while(true){
		circleLocations.clear()
		for(int i = 0; i < 15; i ++)
			{
				float r = float(i) / float(15) * 2 * PI
				vector origin2 = Vector(0,0,0) + player.GetOrigin() + 100 * AimTrainer_SPAWN_DISTANCE * <sin( r ), cos( r ), 0.0>
				circleLocations.append(origin2)
			}
			
		if(!AimTrainer_INFINITE_CHALLENGE && Time() > endtime) break
		if(ChallengesEntities.dummies.len()<5){
			vector circleoriginfordummy = circleLocations.getrandom()
			entity dummy = CreateDummy( 99, AimTrainerOriginToGround( <circleoriginfordummy.x, circleoriginfordummy.y, 10000> ), file.onGroundLocationAngs*-1)
			StartParticleEffectInWorld( GetParticleSystemIndex( FIRINGRANGE_ITEM_RESPAWN_PARTICLE ), dummy.GetOrigin(), dummy.GetAngles() )
			SetSpawnOption_AISettings( dummy, "npc_dummie_combat_trainer" )
			DispatchSpawn( dummy )
			
			//PutEntityInSafeSpot( dummy, null, null, dummy.GetOrigin() + dummy.GetUpVector()*2048 + dummy.GetForwardVector()*2048 , dummy.GetOrigin() )

			dummy.SetMaxHealth( AimTrainer_AI_HEALTH )
			dummy.SetHealth( AimTrainer_AI_HEALTH )
			SetCommonDummyLines(dummy)
			SetTargetName(dummy, "arcstarChallengeDummy")
			ChallengesEntities.dummies.append(dummy)
			AddEntityCallback_OnDamaged(dummy, OnStraferDummyDamaged)
			thread ArcstarsChallengeMovementThink(dummy, player)
		}
		WaitFrame()
	}
}

void function ArcstarsChallengeMovementThink(entity ai, entity player)
{
	if(!IsValid(ai)) return
	if(!IsValid(player )) return
	
	ai.EndSignal("OnDeath")
	player.EndSignal("ChallengeTimeOver")
	
	OnThreadEnd(
		function() : ( ai )
		{
			if(IsValid(ai)) ai.Destroy()
			ChallengesEntities.dummies.removebyvalue(ai)
		}
	)
	
	int randomangle = RandomIntRange(-45,45)
	if(CoinFlip()) randomangle = RandomIntRange(-90,90)
	ai.SetAngles(ai.GetAngles() + Vector(0,randomangle,0))
	
	int random = RandomIntRangeInclusive(1,10)
	if(random == 1)
	{
		if(CoinFlip())
		{
			ai.Anim_ScriptedPlayActivityByName( "ACT_SPRINT_LEFT", true, 0.1 )
			ai.Anim_SetPlaybackRate(AimTrainer_STRAFING_SPEED)
		}
		else 
		{
			ai.Anim_ScriptedPlayActivityByName( "ACT_SPRINT_RIGHT", true, 0.1 )
			ai.Anim_SetPlaybackRate(AimTrainer_STRAFING_SPEED)
		}
	}
	else
	{
		random = RandomIntRangeInclusive(1,10)
		if(random == 1)
		{
			ai.Anim_ScriptedPlayActivityByName( "ACT_SPRINT_BACKWARD", true, 0.1 )
			ai.Anim_SetPlaybackRate(AimTrainer_STRAFING_SPEED)
		}
		else //this will happen most likely
		{
			ai.Anim_ScriptedPlayActivityByName( "ACT_SPRINT_FORWARD", true, 0.1 )
			ai.Anim_SetPlaybackRate(AimTrainer_STRAFING_SPEED)
			thread ArcstarDummyChangeAngles(ai, player)
		}
	}
	thread ClippingAIWorkaround(ai)
	wait 4
	if(!IsValid(ai)) return
	int smokeAttachID = ai.LookupAttachment( "CHESTFOCUS" )
	entity smokeTrailFX = StartParticleEffectOnEntityWithPos_ReturnEntity( ai, GetParticleSystemIndex( $"P_grenade_thermite_trail"), FX_PATTACH_ABSORIGIN_FOLLOW, smokeAttachID, <0,0,0>, VectorToAngles( <0,0,-1> ) )
	entity smokeTrailFX2 = StartParticleEffectOnEntityWithPos_ReturnEntity( ai, GetParticleSystemIndex( $"P_grenade_thermite_trail"), FX_PATTACH_ABSORIGIN_FOLLOW, smokeAttachID, <0,0,0>, VectorToAngles( <0,0,-1> ) )
	wait 2
	if(IsValid(smokeTrailFX)) smokeTrailFX.Destroy()
	if(IsValid(smokeTrailFX2)) smokeTrailFX2.Destroy()
}

void function ArcstarDummyChangeAngles(entity ai, entity player)
{
	while(IsValid(ai)){
		if(RandomFloatRange(0,10) <= 0.5) //5% chance of changing angles while running
		{
			int randomangle = RandomIntRange(-45,45)
			if(CoinFlip()) randomangle = RandomIntRange(-90,90)
			vector angles = ai.GetAngles() + Vector(0,randomangle,0)
			ai.SetAngles(Vector(0,angles.y,0) )
		}
		WaitFrame()
	}
}


//CHALLENGE "Vertical Grenades practice"
void function StartVerticalGrenadesChallenge(entity player)
{
	if(!IsValid(player)) return
	wait 0.1
	
	ChallengesEntities.floor = CreateFloorAtOrigin(file.floorLocation, 30, 30)
	player.SetOrigin(file.floorCenterForPlayer)
	player.SetAngles(Vector(0,180,0))
	EndSignal(player, "ChallengeTimeOver")
	TakeAllWeapons(player)
	player.GiveWeapon( "mp_weapon_frag_grenade", WEAPON_INVENTORY_SLOT_PRIMARY_0, ["challenges_infinite_grenades"] )
	player.SetActiveWeaponBySlot(eActiveInventorySlot.mainHand, WEAPON_INVENTORY_SLOT_PRIMARY_0)

	OnThreadEnd(
		function() : ( player)
		{
			player.MovementEnable()
			player.ClearInvulnerable()
			TakeAllWeapons(player)
			GiveWeaponsFromStoredArray(player, player.p.storedWeapons)
			OnChallengeEnd(player)
		}
	)
	
	wait AimTrainer_PRE_START_TIME
	RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD_INSTANT )
	RemoveCinematicFlag( player, CE_FLAG_HIDE_PERMANENT_HUD)
	player.MovementDisable()
	player.UnfreezeControlsOnServer()
	player.SetInvulnerable()
	float endtime = Time() + AimTrainer_CHALLENGE_DURATION
	thread ChallengeWatcherThread(endtime, player)
	array<vector> circleLocations
	circleLocations.clear()
	
	for(int i = 0; i < 15; i ++)
		{
			float r = float(i) / float(15) * 2 * PI
			vector origin2 = Vector(0,0,0) + player.GetOrigin() + 600 * <sin( r ), cos( r ), 0.0>
			circleLocations.append(origin2)
		}
	circleLocations.randomize()
	int i = 0
	
	while(true){
		if(!AimTrainer_INFINITE_CHALLENGE && Time() > endtime) break
		if(i == circleLocations.len()){
			circleLocations.randomize()
			i = 0
		}
		if(ChallengesEntities.dummies.len()<4){
			vector circlelocation = circleLocations[i]	
			entity dummy = CreateDummy( 99, circlelocation, file.onGroundLocationAngs*-1)
			StartParticleEffectInWorld( GetParticleSystemIndex( FIRINGRANGE_ITEM_RESPAWN_PARTICLE ), dummy.GetOrigin(), dummy.GetAngles() )
			SetSpawnOption_AISettings( dummy, "npc_dummie_combat_trainer" )
			DispatchSpawn( dummy )
			dummy.SetOrigin(dummy.GetOrigin() - dummy.GetForwardVector()*RandomIntRange(400,700))
			vector vec2 = player.GetOrigin() - dummy.GetOrigin()
			vector angles2 = VectorToAngles( vec2 )
			dummy.SetAngles(angles2)
			i++
			// entity pipe = CreatePropDynamic($"mdl/pipes/slum_pipe_large_yellow_256_02.rmdl", dummy.GetOrigin()-Vector(0,0,190), Vector(0,0,0), 6, -1)
			// pipe.kv.rendermode = 4
			// pipe.kv.renderamt = 150
			// pipe.SetParent(dummy)
			dummy.SetBehaviorSelector( "behavior_dummy_empty" )
			dummy.DisableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE | NPC_NEW_ENEMY_FROM_SOUND )
			//dummy.SetShieldHealthMax( ReturnShieldAmountForDesiredLevel() )
			//dummy.SetShieldHealth( ReturnShieldAmountForDesiredLevel() )
			dummy.SetMaxHealth( AimTrainer_AI_HEALTH )
			dummy.SetHealth( AimTrainer_AI_HEALTH )
			SetCommonDummyLines(dummy)
			SetTargetName(dummy, "GrenadesChallengeDummy")
			Remote_CallFunction_NonReplay(player, "ServerCallback_CreateDistanceMarkerForGrenadesChallengeDummies", dummy, player)
			ChallengesEntities.dummies.append(dummy)
			AddEntityCallback_OnDamaged(dummy, OnStraferDummyDamaged)
			AddEntityCallback_OnKilled(dummy, OnDummyKilled)
		}
		WaitFrame()
	}
}

//CHALLENGE "Lift up practice"
void function StartLiftUpChallenge(entity player)
{
	if(!IsValid(player)) return
	player.SetVelocity(Vector(0,0,0))
	player.SetOrigin(file.onGroundLocationPos)
	player.SetAngles(file.onGroundLocationAngs)
	EndSignal(player, "ChallengeTimeOver")

	entity weapon = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_0 )
	array<string> mods = weapon.GetMods()
	mods.append( "elevator_shooter" )
	try{weapon.SetMods( mods )} catch(e42069){printt(weapon.GetWeaponClassName() + " failed to put elevator_shooter mod. DEBUG THIS.")}
	
	OnThreadEnd(
		function() : ( player, mods, weapon)
		{
			SetConVarToDefault( "sv_gravity" ) //hack
			mods.removebyvalue("elevator_shooter")
			try{weapon.SetMods( mods )} catch(e42069){printt(weapon.GetWeaponClassName() + " failed to remove elevator_shooter mod. DEBUG THIS.")}
			OnChallengeEnd(player)
		}
	)
	wait AimTrainer_PRE_START_TIME
	array<vector> circleLocations = NavMesh_GetNeighborPositions( player.GetOrigin(), HULL_HUMAN, 40)
	RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD_INSTANT )
	RemoveCinematicFlag( player, CE_FLAG_HIDE_PERMANENT_HUD)
	float endtime = Time() + AimTrainer_CHALLENGE_DURATION	
	thread ChallengeWatcherThread(endtime, player)
	CreateLiftForChallenge(player.GetOrigin(), player)
	player.UnfreezeControlsOnServer()
	wait 0.05
	player.SetOrigin(player.GetOrigin() + player.GetForwardVector()*0.01) //workaround, so we execute onentertrigger callback instantly
	
	while(true){
		if(!AimTrainer_INFINITE_CHALLENGE && Time() > endtime) break	
		if(ChallengesEntities.dummies.len()<6){
			vector circleoriginfordummy = circleLocations.getrandom()
			entity dummy = CreateDummy( 99, AimTrainerOriginToGround( <circleoriginfordummy.x, circleoriginfordummy.y, 10000> ), file.onGroundLocationAngs*-1 )
			StartParticleEffectInWorld( GetParticleSystemIndex( FIRINGRANGE_ITEM_RESPAWN_PARTICLE ), dummy.GetOrigin(), dummy.GetAngles() )
			SetSpawnOption_AISettings( dummy, "npc_dummie_combat_trainer" )
			DispatchSpawn( dummy )
			dummy.UseSequenceBounds( false )
			dummy.SetShieldHealthMax( ReturnShieldAmountForDesiredLevel() )
			dummy.SetShieldHealth( ReturnShieldAmountForDesiredLevel() )
			dummy.SetMaxHealth( AimTrainer_AI_HEALTH )
			dummy.SetHealth( AimTrainer_AI_HEALTH )
			SetCommonDummyLines(dummy)
			ChallengesEntities.dummies.append(dummy)
			AddEntityCallback_OnDamaged(dummy, OnStraferDummyDamaged)
			AddEntityCallback_OnKilled(dummy, OnDummyKilled)
			thread LiftUpDummyMovementThink(dummy, player)
			thread ClippingAIWorkaround(dummy)
		}
		WaitFrame()
	}
}

void function LiftUpDummyMovementThink(entity ai, entity player)
{
	if(!IsValid(ai)) return
	if(!IsValid(player )) return
	
	ai.EndSignal("OnDeath")
	player.EndSignal("ChallengeTimeOver")
	
	OnThreadEnd(
		function() : ( ai )
		{
			if(!IsValid(ai)) return
			ai.Destroy()
			ChallengesEntities.dummies.removebyvalue(ai)
		}
	)
	
	ai.Anim_ScriptedPlayActivityByName( "ACT_SPRINT_FORWARD", true, 0.1 )
	ai.Anim_SetPlaybackRate(AimTrainer_STRAFING_SPEED)
	wait 0.5
	while(IsValid(ai)){
		if(RandomIntRangeInclusive(1,10) == 1) //10% chance of changing angles while running
		{
			int randomangle = RandomIntRange(-45,45)
			if(CoinFlip()) randomangle = RandomIntRange(-90,90)
			vector angles = ai.GetAngles() + Vector(0,randomangle,0)
			ai.SetAngles(Vector(0,angles.y,0) )
		}
		WaitFrame()
	}
}

void function CreateLiftForChallenge(vector pos, entity player)
{
	entity bottom = CreateEntity( "trigger_cylinder" )
	bottom.SetRadius( 70 )
	bottom.SetAboveHeight( 1200 )
	bottom.SetBelowHeight( 10 )
	bottom.SetOrigin( pos )
	bottom.SetLeaveCallback( BottomTriggerLeave )
	DispatchSpawn( bottom )

	entity top = CreateEntity( "trigger_cylinder" )
	top.SetRadius( 70 )
	top.SetAboveHeight( 250 )
	top.SetBelowHeight( 0 )
	top.SetOrigin( pos + <0, 0, 1200> )
	DispatchSpawn( top )
	
	ChallengesEntities.props.append(bottom)
	ChallengesEntities.props.append(top)
	
	thread LiftPlayerUp(bottom, top, pos, player)
	thread liftVisualsCreator(pos)
	//DebugDrawCylinder( pos, Vector(-90,0,0), 70, 1200, 100, 0, 0, true, float(AimTrainer_CHALLENGE_DURATION) )
}

void function liftVisualsCreator(vector pos)
{
	//Circle on ground FX
	entity circle = CreateEntity( "prop_script" )
	circle.SetValueForModelKey( $"mdl/weapons_r5/weapon_tesla_trap/mp_weapon_tesla_trap_ar_trigger_radius.rmdl" )
	circle.kv.fadedist = 30000
	circle.kv.renderamt = 0
	circle.kv.rendercolor = "240, 19, 19"
	circle.kv.modelscale = 0.27
	circle.kv.solid = 0
	circle.SetOrigin( pos + <0.0, 0.0, -25>)
	circle.SetAngles( <0, 0, 0> )
	circle.NotSolid()
	DispatchSpawn(circle)
	
	ChallengesEntities.props.append(circle)
}

void function BottomTriggerLeave( entity trigger, entity ent )
{
	if ( !ent.IsPlayer() || ent.IsPlayer() && ent.p.isRestartingLevel )
		return
	SetConVarToDefault( "sv_gravity" ) //hack
	vector forward = AnglesToForward( ent.GetAngles() )
	vector up = AnglesToUp( ent.GetAngles() )
	vector velocity = ent.GetVelocity()
	velocity += (forward * 400) + (up*450)
	ent.SetVelocity( velocity )
}

void function ForceToBeInLiftForChallenge( entity player )
{
	if(!player.IsPlayer()) return
	EndSignal(player, "ChallengeTimeOver")
	while(IsValid(player) && !player.p.isRestartingLevel)
	{
		player.SetVelocity(Vector(0,0,0))
		wait 5.5
		foreach(entity dummy in ChallengesEntities.dummies)
			if(IsValid(dummy)) dummy.Destroy()
		ChallengesEntities.dummies.clear()
		WaitFrame()
		player.p.touchingTopTrigger = false
		if(player.p.isRestartingLevel) break
		if(IsValid(player))
		{
			player.SetVelocity(Vector(0,0,0))
			player.SetOrigin(file.onGroundLocationPos)
		}
	}
}

void function LiftPlayerUp( entity bottom, entity top, vector pos, entity player)
{
	EndSignal(player, "ChallengeTimeOver")

	thread ForceToBeInLiftForChallenge(player)
	float PULL_RANGE = 300
	float PULL_STRENGTH_MAX = 50
	float UPVELOCITY
	float HORIZ_SPEED = 170
	
	while( true )
	{
		vector newVelocity
		if(top.IsTouching(player))
		{
			player.p.touchingTopTrigger = true
			SetConVarFloat( "sv_gravity", 0.01 ) //hack	
			UPVELOCITY = 25
			if(player.IsInputCommandHeld( IN_MOVERIGHT )) 
			{
				printt("lift top move right")
				newVelocity = AnglesToRight(player.GetAngles())*HORIZ_SPEED
				newVelocity.z = UPVELOCITY
			} else if(player.IsInputCommandHeld( IN_MOVELEFT ))
			{
				printt("lift top move left")
				newVelocity = AnglesToRight(player.GetAngles())*-HORIZ_SPEED
				newVelocity.z = UPVELOCITY
			} else if(player.IsInputCommandHeld( IN_FORWARD ))
			{
				printt("lift top move forward")
				newVelocity = AnglesToForward(player.GetAngles())*HORIZ_SPEED
				newVelocity.z = UPVELOCITY					
			} else if(player.IsInputCommandHeld( IN_BACK ))
			{
				printt("lift top move backward")
				newVelocity = AnglesToForward(player.GetAngles())*-HORIZ_SPEED
				newVelocity.z = UPVELOCITY					
			} else {
			vector enemyOrigin = player.GetOrigin()
			vector dir = Normalize( pos - player.GetOrigin() )
			float dist = Distance( enemyOrigin, pos )
			newVelocity = dir * GraphCapped( dist, 50, PULL_RANGE, 0, PULL_STRENGTH_MAX )
			newVelocity.z = UPVELOCITY
			}
			player.SetVelocity( newVelocity )
		}
		else if(bottom.IsTouching(player) && !player.p.touchingTopTrigger)
		{
			SetConVarFloat( "sv_gravity", 0.01 ) //hack
			UPVELOCITY = 340
			if(player.IsInputCommandHeld( IN_MOVERIGHT )) 
			{
				printt("lift move right")
				newVelocity = AnglesToRight(player.GetAngles())*HORIZ_SPEED
				newVelocity.z = UPVELOCITY
			} else if(player.IsInputCommandHeld( IN_MOVELEFT ))
			{
				printt("lift move left")
				newVelocity = AnglesToRight(player.GetAngles())*-HORIZ_SPEED
				newVelocity.z = UPVELOCITY
			} else if(player.IsInputCommandHeld( IN_FORWARD ))
			{
				printt("lift move forward")
				newVelocity = AnglesToForward(player.GetAngles())*HORIZ_SPEED
				newVelocity.z = UPVELOCITY					
			} else if(player.IsInputCommandHeld( IN_BACK ))
			{
				printt("lift move backward")
				newVelocity = AnglesToForward(player.GetAngles())*-HORIZ_SPEED
				newVelocity.z = UPVELOCITY					
			} else {
			vector enemyOrigin = player.GetOrigin()
			vector dir = Normalize( pos - player.GetOrigin() )
			float dist = Distance( enemyOrigin, pos )
			newVelocity = dir * GraphCapped( dist, 50, PULL_RANGE, 0, PULL_STRENGTH_MAX )
			newVelocity.z = UPVELOCITY
			}
			player.SetVelocity( newVelocity )
		}
		WaitFrame()
	}
}

//CHALLENGE "Tile Frenzy"
void function StartTileFrenzyChallenge(entity player)
{
	if(!IsValid(player)) return
	player.SetOrigin(file.floorCenterForPlayer)
	player.SetAngles(Vector(0,0,0))
	EndSignal(player, "ChallengeTimeOver")
	WaitFrame()
	ChallengesEntities.floor = CreateFloorAtOrigin(file.floorLocation, 30, 30)
	array<entity> Wall = CreateWallAtOrigin(player.GetOrigin()-Vector(0,0,200) + AnglesToForward(player.GetAngles())*580 + AnglesToRight(player.GetAngles())*1180, 9, 5, 90)
	foreach(entity wallprop in Wall)
		ChallengesEntities.floor.append(wallprop)
	
	//5x5?
	int ancho = 5
	int alto = 5
	vector pos = player.GetOrigin() + AnglesToForward(player.GetAngles())*400 + AnglesToRight(player.GetAngles())*100

	int x = int(pos.x)
	int y = int(pos.y)
	int z = int(pos.z+50)
	float modelscale = 0.2
	int offset = 0
	int step = int((offset+300)*modelscale)
	array<vector> locationsForTiles

	for(int i = y; i < y + (ancho * step); i += step)
	{
		for(int j = z; j < z + (alto * step); j += step)
		{
		locationsForTiles.append(<x, i, j>)
		}
	}
	WaitFrame()
	player.SetOrigin(player.GetOrigin() + Vector(0,0,100))
	ChallengesEntities.props.append(CreateFRProp( $"mdl/thunderdome/thunderdome_cage_ceiling_256x256_06.rmdl", player.GetOrigin(), <0,0,0>) )
	PutEntityInSafeSpot( player, null, null, player.GetOrigin() + player.GetUpVector()*128, player.GetOrigin() )
	locationsForTiles.randomize()
	
	OnThreadEnd(
		function() : ( player)
		{
			if(!IsValid(player)) return
			player.MovementEnable()
			OnChallengeEnd(player)
		}
	)
	
	wait AimTrainer_PRE_START_TIME
	if(!IsValid(player)) return
	RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD_INSTANT )
	RemoveCinematicFlag( player, CE_FLAG_HIDE_PERMANENT_HUD)
	player.MovementDisable()
	player.UnfreezeControlsOnServer()
	float endtime = Time() + AimTrainer_CHALLENGE_DURATION
	thread ChallengeWatcherThread(endtime, player)
	int locationindex = 1
	while(true){
		if(!AimTrainer_INFINITE_CHALLENGE && Time() > endtime) break

		if(locationindex == locationsForTiles.len()){
			locationsForTiles.randomize()
			locationindex = 1
		}			
		if(ChallengesEntities.props.len() < 4){
					
				entity target = CreateEntity( "script_mover" )
				target.kv.solid = 6
				target.SetValueForModelKey( FIRINGRANGE_FLICK_TARGET_ASSET )
				target.kv.SpawnAsPhysicsMover = 0
				target.SetOrigin( locationsForTiles[locationindex] )				
				vector vec2 = player.GetOrigin() -  locationsForTiles[locationindex]
				locationindex++
				vector angles2 = VectorToAngles( vec2 )	
				target.SetAngles( angles2 )
				DispatchSpawn( target )
				target.Hide()
				target.SetDamageNotifications( true )
				
				entity visual = CreatePropDynamic(FIRINGRANGE_BLUE_TARGET_ASSET, target.GetOrigin(), target.GetAngles(), 6, -1)
				visual.SetParent(target)
				visual.SetModelScale(0.45)
				visual.NotSolid()
				
				AddEntityCallback_OnDamaged(target, OnTilePropDamaged)
				ChallengesEntities.props.append(target)
		}
		WaitFrame()
	}
}

//Close fast strafes CHALLENGE
void function StartCloseFastStrafesChallenge(entity player)
{
	if(!IsValid(player)) return
	player.SetOrigin(file.floorCenterForPlayer)
	player.SetAngles(Vector(0,90,0))
	ChallengesEntities.floor = CreateFloorAtOrigin(file.floorLocation, 30, 30)
	file.onGroundDummyPos = player.GetOrigin() + AnglesToForward(file.onGroundLocationAngs)*100*AimTrainer_SPAWN_DISTANCE

	EndSignal(player, "ChallengeTimeOver")
	
	OnThreadEnd(
		function() : ( player)
		{
			OnChallengeEnd(player)
		}
	)
	wait AimTrainer_PRE_START_TIME
	RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD_INSTANT )
	RemoveCinematicFlag( player, CE_FLAG_HIDE_PERMANENT_HUD)
	player.UnfreezeControlsOnServer()

	float endtime = Time() + AimTrainer_CHALLENGE_DURATION
	thread ChallengeWatcherThread(endtime, player)

	while(true){
		if(!AimTrainer_INFINITE_CHALLENGE && Time() > endtime) break
		
		entity dummy = CreateDummy( 99, file.onGroundDummyPos, file.onGroundLocationAngs*-1 )
		StartParticleEffectInWorld( GetParticleSystemIndex( FIRINGRANGE_ITEM_RESPAWN_PARTICLE ), dummy.GetOrigin(), dummy.GetAngles() )
		SetSpawnOption_AISettings( dummy, "npc_dummie_combat_trainer" )
		DispatchSpawn( dummy )	
		dummy.SetBehaviorSelector( "behavior_dummy_empty" )
		dummy.SetShieldHealthMax( ReturnShieldAmountForDesiredLevel() )
		dummy.SetShieldHealth( ReturnShieldAmountForDesiredLevel() )
		dummy.SetMaxHealth( AimTrainer_AI_HEALTH )
		dummy.SetHealth( AimTrainer_AI_HEALTH )
		SetCommonDummyLines(dummy)
		
		AddEntityCallback_OnDamaged(dummy, OnStraferDummyDamaged)
		AddEntityCallback_OnKilled(dummy, OnDummyKilled)
		
		waitthread DummyFastCloseStrafeMovement(dummy, player)
		wait 0.5
	}
}

void function DummyFastCloseStrafeMovement(entity dummy, entity player)
{
	EndSignal(dummy, "OnDeath")

	vector angles2 = VectorToAngles( player.GetOrigin() - dummy.GetOrigin() )

	dummy.SetOrigin(player.GetOrigin() + AnglesToForward(player.GetAngles())*100*AimTrainer_SPAWN_DISTANCE)

	entity script_mover = CreateEntity( "script_mover" )
	script_mover.kv.solid = 0
	script_mover.SetValueForModelKey( $"mdl/dev/empty_model.rmdl" )
	script_mover.kv.SpawnAsPhysicsMover = 0	
	script_mover.SetOrigin( dummy.GetOrigin() )
	script_mover.SetAngles( dummy.GetAngles() )
	DispatchSpawn( script_mover )
	dummy.SetParent(script_mover)
	
	OnThreadEnd(
		function() : ( dummy, script_mover )
		{
			dummy.ClearParent()
			if(IsValid(script_mover)) script_mover.Destroy()
			if(IsValid(dummy)) dummy.Destroy()
			ChallengesEntities.dummies.removebyvalue(dummy)			
		}
	)	
	
	while(IsValid(dummy))
	{
		angles2 = VectorToAngles( player.GetOrigin() - dummy.GetOrigin() )
		
		int morerandomness = 1
		if(CoinFlip()) morerandomness = -1
		
		script_mover.NonPhysicsMoveTo( player.GetOrigin() + Normalize(player.GetRightVector())*RandomIntRange(50,80)*morerandomness*AimTrainer_SPAWN_DISTANCE + Normalize(player.GetForwardVector())*RandomIntRange(20,150)*AimTrainer_SPAWN_DISTANCE, 0.6*AimTrainer_SPAWN_DISTANCE, 0.0, 0.0 )
		script_mover.SetAngles(angles2)
		dummy.SetAngles(angles2)
		wait 0.25
	}
}

//Close fast jumps strafes CHALLENGE
void function StartTapyDuckStrafesChallenge(entity player)
{
	if(!IsValid(player)) return
	player.SetOrigin(file.floorCenterForPlayer)
	player.SetAngles(Vector(0,90,0))
	ChallengesEntities.floor = CreateFloorAtOrigin(file.floorLocation, 30, 30)
	file.onGroundDummyPos = player.GetOrigin() + AnglesToForward(Vector(0,-90,0))*400

	EndSignal(player, "ChallengeTimeOver")
	
	OnThreadEnd(
		function() : ( player)
		{
			OnChallengeEnd(player)
		}
	)
	wait AimTrainer_PRE_START_TIME
	RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD_INSTANT )
	RemoveCinematicFlag( player, CE_FLAG_HIDE_PERMANENT_HUD)
	player.UnfreezeControlsOnServer()	

	float endtime = Time() + AimTrainer_CHALLENGE_DURATION
	thread ChallengeWatcherThread(endtime, player)

	while(true){
		if(!AimTrainer_INFINITE_CHALLENGE && Time() > endtime) break
		
		entity dummy = CreateDummy( 99, file.onGroundDummyPos, file.onGroundLocationAngs )
		vector pos = dummy.GetOrigin()
		vector angles = dummy.GetAngles()
		StartParticleEffectInWorld( GetParticleSystemIndex( FIRINGRANGE_ITEM_RESPAWN_PARTICLE ), pos, angles )
		SetSpawnOption_AISettings( dummy, "npc_dummie_combat_trainer" )
		DispatchSpawn( dummy )
		dummy.SetBehaviorSelector( "behavior_dummy_empty" )
		dummy.SetShieldHealthMax( ReturnShieldAmountForDesiredLevel() )
		dummy.SetShieldHealth( ReturnShieldAmountForDesiredLevel() )
		dummy.SetMaxHealth( AimTrainer_AI_HEALTH )
		dummy.SetHealth( AimTrainer_AI_HEALTH )
		SetCommonDummyLines(dummy)
		
		AddEntityCallback_OnDamaged(dummy, OnStraferDummyDamaged)
		AddEntityCallback_OnKilled(dummy, OnDummyKilled)
		
		waitthread DummyTapyDuckStrafeMovement(dummy, player)
		wait 0.5
	}
}

void function DummyTapyDuckStrafeMovement(entity dummy, entity player)
{
	EndSignal(dummy, "OnDeath")

	vector angles2 = VectorToAngles( player.GetOrigin() - dummy.GetOrigin() )

	array<vector> circleLocations

	for(int i = 0; i < 100; i ++)
	{
		float r = float(i) / float(100) * 2 * PI
		vector origin2 = player.GetOrigin() + 300 * <sin( r ), cos( r ), 0.0>
		circleLocations.append(origin2)
	}

	int locationindex = 0	
	dummy.SetOrigin(circleLocations[locationindex])

	entity script_mover = CreateEntity( "script_mover" )
	script_mover.kv.solid = 0
	script_mover.SetValueForModelKey( $"mdl/dev/empty_model.rmdl" )
	script_mover.kv.SpawnAsPhysicsMover = 0	
	script_mover.SetOrigin( dummy.GetOrigin() )
	script_mover.SetAngles( dummy.GetAngles() )
	DispatchSpawn( script_mover )
	dummy.SetParent(script_mover)
	
	OnThreadEnd(
		function() : ( dummy, script_mover, circleLocations )
		{
			dummy.ClearParent()
			if(IsValid(script_mover)) script_mover.Destroy()
			if(IsValid(dummy)) dummy.Destroy()
			circleLocations.clear()
			ChallengesEntities.dummies.removebyvalue(dummy)			
		}
	)	
	
	int oldLocationindex = 0
	while(true){		
		if(!IsValid(dummy)) break
		dummy.Anim_Stop()
		int morerandomness = 1
		if(CoinFlip()) morerandomness = -1

		int morerandomness3 = RandomIntRangeInclusive(1,10)
		int morerandomness4 = RandomIntRangeInclusive(1,5)
		vector dummyoldorigin = dummy.GetOrigin()
		if(morerandomness3 >= 1 && morerandomness3 <= 9) //75% chance
		{
			if(morerandomness4 == 5) //25% chance
			{
				dummy.Anim_Stop()
				script_mover.NonPhysicsStop()						
				dummy.Anim_ScriptedPlayActivityByName( "ACT_STAND", true, 0.1 )
				wait 0.15
			}
			else if(morerandomness4 >= 1 && morerandomness3 <= 4)//75% chance
			{
				oldLocationindex = locationindex
		
				if(CoinFlip())
					locationindex++
				else 
					locationindex--

				if(locationindex < 0)
					locationindex =	circleLocations.len() + locationindex
				else if(locationindex >= circleLocations.len())
					locationindex =	locationindex - (circleLocations.len()-1)

				script_mover.NonPhysicsMoveTo( circleLocations[locationindex], 0.15, 0.0, 0.0 )
				if(oldLocationindex >= locationindex) dummy.Anim_PlayOnly( "ACT_RUN_RIGHT")
				else if(oldLocationindex < locationindex) dummy.Anim_PlayOnly( "ACT_RUN_LEFT")
				dummy.Anim_DisableUpdatePosition()
				wait 0.12
				dummy.Anim_Stop()
				script_mover.NonPhysicsStop()
			}
		}
		else if (morerandomness3 == 10)
		{
			int morerandomness2 = 1
			if(CoinFlip()) morerandomness2 = -1
						
			// printt("Ras strafing??")
			thread DummyJumpAnimThreaded(dummy)
			float startTime = Time()
			float endTime = startTime + 0.28
			vector moveTo = dummyoldorigin + Normalize(dummy.GetRightVector())*10*morerandomness + Normalize(dummy.GetForwardVector())*-10 + Normalize(dummy.GetUpVector())*20
			int randomnessRasStrafe = 1
			if(CoinFlip()) randomnessRasStrafe = -1
			int curvedamount = 50
			float moveXFrom = moveTo.x+curvedamount*randomnessRasStrafe
			float moveZFrom = moveTo.z+30
			while(true)
			{
				if(endTime-Time() <= 0) 
				{
					script_mover.NonPhysicsStop()
					startTime = Time()
					endTime = startTime + 0.28
					moveTo = circleLocations[locationindex]
					moveXFrom = moveTo.x+curvedamount*-randomnessRasStrafe	
					moveZFrom = moveTo.z				
					while(endTime-Time() > 0)
					{
						script_mover.NonPhysicsMoveTo( Vector(GraphCapped( Time(), startTime, endTime, moveXFrom, moveTo.x ), moveTo.y, GraphCapped( Time(), startTime, endTime, moveZFrom, moveTo.z )), endTime-Time(), 0.0, 0.0 )
						WaitFrame()
					}
					script_mover.NonPhysicsStop()
					break
				}
				script_mover.NonPhysicsMoveTo( Vector(GraphCapped( Time(), startTime, endTime, moveXFrom, moveTo.x ), moveTo.y, GraphCapped( Time(), startTime, endTime, moveZFrom, moveTo.z )), endTime-Time(), 0.0, 0.0 )
				WaitFrame()
			}				
			script_mover.NonPhysicsStop()
			// printt("Ras strafing?? END")
		}
		angles2 = VectorToAngles( player.GetOrigin() - dummy.GetOrigin() )
		script_mover.SetAngles(angles2)
		dummy.SetAngles(angles2)
	}
}

void function CreateMovementMapDummieFromMapLoad(vector pos, vector ang)
{
	FlagWait( "EntitiesDidLoad" )
	CreateMovementMapDummie(pos, ang)
}

entity function CreateMovementMapDummie(vector pos, vector ang)
{

	// while(true){ //!FIXME find a way to end the while when the "prop" is deteled with map_editor delete mode
		entity dummy = CreateNPC( "npc_dummie", 99, pos, ang )
		StartParticleEffectInWorld( GetParticleSystemIndex( FIRINGRANGE_ITEM_RESPAWN_PARTICLE ), pos, ang )
		SetSpawnOption_AISettings( dummy, "npc_dummie_combat_trainer" )
		DispatchSpawn( dummy )
		dummy.SetScriptName("editor_placed_prop")
		dummy.SetBehaviorSelector( "behavior_dummy_empty" )
		dummy.SetShieldHealthMax( 25 )
		dummy.SetShieldHealth( 25 )
		
		dummy.SetMaxHealth( 60 )
		dummy.SetHealth( 60 )
		dummy.SetTakeDamageType( DAMAGE_YES )
		dummy.SetDamageNotifications( true )
		dummy.SetDeathNotifications( true )
		dummy.SetValidHealthBarTarget( true )
		SetObjectCanBeMeleed( dummy, true )
		dummy.SetSkin(RandomIntRangeInclusive(1,4))
		dummy.DisableHibernation()
		
		thread MovementMapDummyMovement(dummy)
		
		return dummy
		// wait 0.5
	// }
}

void function MovementMapDummyMovement(entity dummy)
{
//new script_mover version of the strafing dummy challenge, so we can spawn these dummies in the air (no navmesh)

	EndSignal(dummy, "OnDeath")
	vector angles2 = dummy.GetAngles()
	
	array<vector> circleLocations
	array<vector> rightSteps
	array<vector> leftSteps
	
	entity script_mover = CreateEntity( "script_mover" )
	script_mover.kv.solid = 0
	script_mover.SetValueForModelKey( $"mdl/dev/empty_model.rmdl" )
	script_mover.kv.SpawnAsPhysicsMover = 0	
	script_mover.SetOrigin( dummy.GetOrigin() )
	script_mover.SetAngles( dummy.GetAngles() )
	DispatchSpawn( script_mover )
	dummy.SetParent(script_mover)
	
	OnThreadEnd(
		function() : ( dummy, script_mover, circleLocations )
		{
			dummy.ClearParent()
			if(IsValid(script_mover)) script_mover.Destroy()
			if(IsValid(dummy)) dummy.Destroy()	
		}
	)	
	
	vector maxRightLocation = dummy.GetOrigin() + AnglesToRight( dummy.GetAngles() )*80
	vector maxLeftLocation = dummy.GetOrigin() + AnglesToRight( dummy.GetAngles() )*-80
	while(true){		
		if(!IsValid(dummy)) break
		dummy.Anim_Stop()
		int morerandomness = 1
		if(CoinFlip()) morerandomness = -1

		int morerandomness3 = RandomIntRangeInclusive(1,10)
		int morerandomness4 = RandomIntRangeInclusive(1,10)
		vector dummyoldorigin = dummy.GetOrigin()
		// if(morerandomness3 >= 1 && morerandomness3 <= 9) //75% chance
		// {
			if(morerandomness4 == 10) //10% chance
			{
				dummy.Anim_Stop()
				script_mover.NonPhysicsStop()						
				dummy.Anim_PlayOnly( "ACT_STAND" )
				wait 0.15
			}
			else if(morerandomness4 >= 1 && morerandomness3 < 10)//90% chance
			{
				float duration = 0.25 //leave it like this in case we want to change it to a range, so it modifies mover duration and movement duration
				dummy.Anim_Stop()
				script_mover.NonPhysicsStop()
				
				if(CoinFlip() && Distance(dummy.GetOrigin(), maxRightLocation) > 10 )
				{
					dummy.Anim_PlayOnly( "ACT_RUN_RIGHT")
					script_mover.NonPhysicsMoveTo( dummy.GetOrigin() + AnglesToRight( dummy.GetAngles() )*25, duration, 0.0, 0.0 )
					wait duration
				}
				else if( Distance(dummy.GetOrigin(), maxLeftLocation) > 10 )
				{
					dummy.Anim_PlayOnly( "ACT_RUN_LEFT")
					script_mover.NonPhysicsMoveTo( dummy.GetOrigin() + AnglesToRight( dummy.GetAngles() )*-25, duration, 0.0, 0.0 )
					wait duration
				}				
			}
		// }
		// else if (morerandomness3 == 10)
		// {
			// int morerandomness2 = 1
			// if(CoinFlip()) morerandomness2 = -1
						
			// // printt("Ras strafing??")
			// thread DummyJumpAnimThreaded(dummy)
			// float startTime = Time()
			// float endTime = startTime + 0.28
			// vector moveTo = dummyoldorigin + Normalize(dummy.GetRightVector())*10*morerandomness + Normalize(dummy.GetForwardVector())*-10 + Normalize(dummy.GetUpVector())*20
			// int randomnessRasStrafe = 1
			// if(CoinFlip()) randomnessRasStrafe = -1
			// int curvedamount = 50
			// float moveXFrom = moveTo.x+curvedamount*randomnessRasStrafe
			// float moveZFrom = moveTo.z+30
			// while(true)
			// {
				// if(endTime-Time() <= 0) 
				// {
					// script_mover.NonPhysicsStop()
					// startTime = Time()
					// endTime = startTime + 0.28
					// moveTo = circleLocations[locationindex]
					// moveXFrom = moveTo.x+curvedamount*-randomnessRasStrafe	
					// moveZFrom = moveTo.z				
					// while(endTime-Time() > 0)
					// {
						// script_mover.NonPhysicsMoveTo( Vector(GraphCapped( Time(), startTime, endTime, moveXFrom, moveTo.x ), moveTo.y, GraphCapped( Time(), startTime, endTime, moveZFrom, moveTo.z )), endTime-Time(), 0.0, 0.0 )
						// WaitFrame()
					// }
					// script_mover.NonPhysicsStop()
					// break
				// }
				// script_mover.NonPhysicsMoveTo( Vector(GraphCapped( Time(), startTime, endTime, moveXFrom, moveTo.x ), moveTo.y, GraphCapped( Time(), startTime, endTime, moveZFrom, moveTo.z )), endTime-Time(), 0.0, 0.0 )
				// WaitFrame()
			// }				
			// script_mover.NonPhysicsStop()
			// // printt("Ras strafing?? END")
		// }
		// angles2 = VectorToAngles( player.GetOrigin() - dummy.GetOrigin() )
		// script_mover.SetAngles(angles2)
		// dummy.SetAngles(angles2)
	}
}

void function DummyJumpAnimThreaded(entity dummy)
{
	if(IsValid(dummy))
		dummy.Anim_ScriptedPlayActivityByName( "ACT_MP_JUMP_START", true, 0.1 )
	wait 0.2
	if(IsValid(dummy))
		dummy.Anim_ScriptedPlayActivityByName( "ACT_MP_JUMP_FLOAT", true, 0.1 )
	wait 0.1
	if(IsValid(dummy))
		dummy.Anim_ScriptedPlayActivityByName( "ACT_MP_JUMP_LAND", true, 0.1 )					
}

//Smoothbot CHALLENGE
void function StartSmoothbotChallenge(entity player)
{
	if(!IsValid(player)) return
	player.SetOrigin(file.floorCenterForPlayer)
	player.SetAngles(Vector(-25,90,0))
	ChallengesEntities.floor = CreateFloorAtOrigin(file.floorLocation, 30, 30)
	file.onGroundDummyPos = player.GetOrigin() + AnglesToForward(file.onGroundLocationAngs)*400

	EndSignal(player, "ChallengeTimeOver")

	OnThreadEnd(
		function() : ( player)
		{
			OnChallengeEnd(player)
		}
	)
	wait AimTrainer_PRE_START_TIME
	RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD_INSTANT )
	RemoveCinematicFlag( player, CE_FLAG_HIDE_PERMANENT_HUD)
	player.UnfreezeControlsOnServer()
	
	float endtime = Time() + AimTrainer_CHALLENGE_DURATION
	thread ChallengeWatcherThread(endtime, player)

	while(true){
		if(!AimTrainer_INFINITE_CHALLENGE && Time() > endtime) break
		
		entity dummy = CreateDummy( 99, file.onGroundDummyPos, file.onGroundLocationAngs*-1 )
		vector pos = dummy.GetOrigin()
		vector angles = dummy.GetAngles()
		StartParticleEffectInWorld( GetParticleSystemIndex( FIRINGRANGE_ITEM_RESPAWN_PARTICLE ), pos, angles )
		SetSpawnOption_AISettings( dummy, "npc_dummie_combat_trainer" )
		DispatchSpawn( dummy )
		dummy.SetBehaviorSelector( "behavior_dummy_empty" )
		// dummy.SetShieldHealthMax( ReturnShieldAmountForDesiredLevel() )
		// dummy.SetShieldHealth( ReturnShieldAmountForDesiredLevel() )
		dummy.SetMaxHealth( AimTrainer_AI_HEALTH )
		dummy.SetHealth( AimTrainer_AI_HEALTH )
		SetCommonDummyLines(dummy)
		SetTargetName(dummy, "CloseFastDummy")
		
		AddEntityCallback_OnDamaged(dummy, OnStraferDummyDamaged)
		AddEntityCallback_OnKilled(dummy, OnDummyKilled)
		
		waitthread DummySmoothbotMovement(dummy, player)
		wait 0.5
	}
}

void function DummySmoothbotMovement(entity dummy, entity player)
{
	EndSignal(dummy, "OnDeath")

	array<vector> circleLocations
	array<vector> circleLocations2
	
	for(int i = 0; i < 100; i ++)
	{
		float r = float(i) / float(100) * 2 * PI
		vector origin2 = Vector(0,0,500) + player.GetOrigin() + 1000 * <sin( r ), cos( r ), 0.0>
		circleLocations.append(origin2)
	}
	
	for(int i = 0; i < 100; i ++)
	{
		float r = float(i) / float(100) * 2 * PI
		vector origin2 = Vector(0,0,0) + player.GetOrigin() + 500 * <sin( r ), cos( r ), 0.0>
		circleLocations2.append(origin2)
	}

	int locationindex = 0	
	dummy.SetOrigin(circleLocations[locationindex])

	entity script_mover = CreateEntity( "script_mover" )
	script_mover.kv.solid = 0
	script_mover.SetValueForModelKey( $"mdl/dev/empty_model.rmdl" )
	script_mover.kv.SpawnAsPhysicsMover = 0	
	script_mover.SetOrigin( dummy.GetOrigin() )
	script_mover.SetAngles( dummy.GetAngles() )
	DispatchSpawn( script_mover )
	dummy.SetParent(script_mover)
	
	OnThreadEnd(
		function() : ( dummy, script_mover, circleLocations, circleLocations2 )
		{
			dummy.ClearParent()
			if(IsValid(script_mover)) script_mover.Destroy()
			if(IsValid(dummy)) dummy.Destroy()
			circleLocations.clear()
			circleLocations2.clear()
			ChallengesEntities.dummies.removebyvalue(dummy)			
		}
	)	

	bool viniendodeavance
	bool lowerpasses
	int nottoorandom = 1
	if(CoinFlip()) nottoorandom = -1
	int togroundcounter = 0
	while(true)
	{
		dummy.Anim_Stop()

		int morerandomness = 1
		if(CoinFlip()) morerandomness = -1
		
		if(nottoorandom == 1) nottoorandom = -1	
		else if(nottoorandom == -1) nottoorandom = 1
		
		if(viniendodeavance)
		{
			if(CoinFlip() || togroundcounter == 1)
			{
				lowerpasses = false
				waitthread CoolScriptMoverMovement(player, script_mover, circleLocations[locationindex], nottoorandom, viniendodeavance, lowerpasses) //to sky
				togroundcounter = 0
			}
			else 
			{
				togroundcounter++
				lowerpasses = true
				waitthread CoolScriptMoverMovement(player, script_mover, circleLocations2[locationindex], nottoorandom, viniendodeavance, lowerpasses) //to ground
			}
			
			viniendodeavance = false			
			locationindex += RandomIntRange(1,5)*morerandomness
			
			if(locationindex < 0)
				locationindex =	(circleLocations.len()-1) + locationindex
			else if(locationindex >= circleLocations.len())
				locationindex =	locationindex - (circleLocations.len()-1)
			
			printt(locationindex)
		}
		else
		{
			waitthread CoolScriptMoverMovement(player, script_mover, circleLocations[locationindex], nottoorandom, viniendodeavance, lowerpasses)
			viniendodeavance = true
			lowerpasses = false
		}
	}
}

void function CoolScriptMoverMovement(entity player, entity script_mover, vector endLocation, int nottoorandom, bool viniendodeavance, bool lowerpasses)
{
	script_mover.EndSignal("OnDestroy")
	
	int morerandomness2 = 1
	if(CoinFlip()) morerandomness2 = -1		
	
	float startTime = Time()
	float endTime = startTime + 3
	vector moveTo = player.GetOrigin() + player.GetForwardVector()*100 + player.GetRightVector()*RandomInt(150)*morerandomness2 + player.GetUpVector()*RandomInt(50)
	if(viniendodeavance)
		moveTo = endLocation
	
	float moveXFrom = moveTo.x+RandomFloatRange(200,500)*nottoorandom
	float moveZFrom = moveTo.z
	if(!lowerpasses && viniendodeavance) moveZFrom += 300
	while(Time() < endTime)
	{	
		vector angles2 = VectorToAngles( player.GetOrigin() - script_mover.GetOrigin() )
		script_mover.SetAngles(Vector(script_mover.GetAngles().x, angles2.y, script_mover.GetAngles().z))
		vector moveToFinal = Vector(GraphCapped( Time(), startTime, endTime, moveXFrom, moveTo.x ), moveTo.y, GraphCapped( Time(), startTime, endTime, moveZFrom, moveTo.z ))
		script_mover.NonPhysicsMoveTo( moveToFinal, endTime-Time(), 0.0, 0.0 )
		vector vel = script_mover.GetVelocity()
		if(Distance(script_mover.GetOrigin(), moveTo) < 150.0) { //avoid to speed up too much
			script_mover.NonPhysicsStop()
			break
		}
		WaitFrame()
	}
}

//Skydiving targets CHALLENGE
void function StartSkyDiveChallenge(entity player)
{
	if(!IsValid(player)) return
	player.SetOrigin(file.floorCenterForPlayer)
	player.SetAngles(Vector(0,90,0))
	ChallengesEntities.floor = CreateFloorAtOrigin(file.floorLocation, 30, 30)
	file.onGroundDummyPos = player.GetOrigin() + AnglesToForward(Vector(0,-90,0))*100*AimTrainer_SPAWN_DISTANCE 

	EndSignal(player, "ChallengeTimeOver")
		
	OnThreadEnd(
		function() : ( player)
		{
			OnChallengeEnd(player)
		}
	)
	wait AimTrainer_PRE_START_TIME
	RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD_INSTANT )
	RemoveCinematicFlag( player, CE_FLAG_HIDE_PERMANENT_HUD)
	player.UnfreezeControlsOnServer()	

	float endtime = Time() + AimTrainer_CHALLENGE_DURATION
	thread ChallengeWatcherThread(endtime, player)

	while(true){
		if(!AimTrainer_INFINITE_CHALLENGE && Time() > endtime) break
		
		if(ChallengesEntities.dummies.len()<4){	
			entity dummy = CreateDummy( 99, file.onGroundDummyPos, file.onGroundLocationAngs )
			SetSpawnOption_AISettings( dummy, "npc_training_dummy_trainer" )
			DispatchSpawn( dummy )	
			dummy.SetShieldHealthMax( ReturnShieldAmountForDesiredLevel() )
			dummy.SetShieldHealth( ReturnShieldAmountForDesiredLevel() )
			dummy.SetMaxHealth( AimTrainer_AI_HEALTH )
			dummy.SetHealth( AimTrainer_AI_HEALTH )
			SetCommonDummyLines(dummy)
			dummy.DisableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE | NPC_NEW_ENEMY_FROM_SOUND )
			dummy.EnableNPCFlag( NPC_IGNORE_ALL )
			dummy.SetNoTarget( true )
			dummy.EnableNPCFlag( NPC_DISABLE_SENSING )
			ChallengesEntities.dummies.append(dummy)
			array<string> attachments = [ "vent_left", "vent_right" ]
			
			foreach ( attachment in attachments )
				{
					int enemyID    = GetParticleSystemIndex( $"P_enemy_jump_jet_ON_trails" )
					entity enemyFX = StartParticleEffectOnEntity_ReturnEntity( dummy, enemyID, FX_PATTACH_POINT_FOLLOW, dummy.LookupAttachment( attachment ) )
				}
			//Skydive fx, visual clutter?
			// const array<vector> skydiveSmokeColors = [ <178,184,244>, <143,222,95>, <255,134,26>, <255,251,130>, <255,202,254> ]	
			// entity skydiveFx = StartParticleEffectOnEntity_ReturnEntity( dummy, GetParticleSystemIndex( $"P_skydive_trail_CP" ), FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "CHESTFOCUS" ) )
			// EffectSetControlPointVector( skydiveFx, 1, skydiveSmokeColors.getrandom())
			// ChallengesEntities.props.append(skydiveFx)
			
			AddEntityCallback_OnDamaged(dummy, OnStraferDummyDamaged)
			AddEntityCallback_OnKilled(dummy, OnDummyKilled)
			
			thread DummySkyDiveMovement(dummy, player)
		}
		WaitFrame()
	}
}

void function DummySkyDiveMovement(entity dummy, entity player)
{
	EndSignal(dummy, "OnDeath")
	EndSignal(dummy, "OnDestroy")

	array<vector> circleLocations
	array<vector> circleLocationsOnGround
	
	for(int i = 0; i < 50; i ++)
	{
		float r = float(i) / float(50) * 2 * PI
		vector origin2 = Vector(0,0,3000) + player.GetOrigin() + 200 * AimTrainer_SPAWN_DISTANCE  * <sin( r ), cos( r ), 0.0>
		circleLocations.append(origin2)
	}
	for(int i = 0; i < 50; i ++)
	{
		float r = float(i) / float(50) * 2 * PI
		vector origin2 = player.GetOrigin() + 400*AimTrainer_SPAWN_DISTANCE  * <sin( r ), cos( r ), 0.0>
		circleLocationsOnGround.append(origin2)
	}
	int locationindex = RandomInt(circleLocations.len())
	dummy.SetOrigin(circleLocations[locationindex])
	vector org1 = circleLocations[locationindex]
	vector org2 = dummy.GetOrigin()
	vector vec2 = org1 - org2
	vector angles2 = VectorToAngles( vec2 )
	dummy.SetAngles(angles2)
	
	StartParticleEffectInWorld( GetParticleSystemIndex( FIRINGRANGE_ITEM_RESPAWN_PARTICLE ), dummy.GetOrigin(), dummy.GetAngles())
	entity script_mover = CreateEntity( "script_mover" )
	script_mover.kv.solid = 0
	script_mover.SetValueForModelKey( $"mdl/dev/empty_model.rmdl" )
	script_mover.kv.SpawnAsPhysicsMover = 0	
	script_mover.SetOrigin( dummy.GetOrigin() )
	script_mover.SetAngles( dummy.GetAngles() )
	DispatchSpawn( script_mover )
	dummy.SetParent(script_mover)
	
	OnThreadEnd(
		function() : ( dummy, script_mover, circleLocations )
		{
			dummy.ClearParent()
			if(IsValid(script_mover)) script_mover.Destroy()
			if(IsValid(dummy)) dummy.Destroy()
			circleLocations.clear()
			ChallengesEntities.dummies.removebyvalue(dummy)			
		}
	)
	
	int oldLocationindex
	bool comingfromjump = false	
	EmitSoundOnEntity(dummy, "Survival_InGameFlight_Travel_3P")
	while(IsValid(dummy))
	{
		
		locationindex = RandomInt(circleLocationsOnGround.len())
		
		thread PlaySkyDiveAnims(dummy, circleLocationsOnGround, locationindex, script_mover)
		
		org1 = circleLocationsOnGround[locationindex]
		org2 = dummy.GetOrigin()
		vec2 = org1 - org2
		angles2 = VectorToAngles( vec2 )
			
		script_mover.SetAngles(angles2)
		dummy.SetAngles(angles2)
			
		script_mover.NonPhysicsMoveTo( circleLocationsOnGround[locationindex], 4.6, 0.0, 0.0 )	

		WaitForever()
		wait RandomFloatRange(0.2,1.0)
	}
}

void function PlaySkyDiveAnims(entity dummy, array<vector> ground, int locationindex , entity script_mover)
{
	float startingTime = Time()
	float movingTime = startingTime + 4.5
	vector locationEnd = ground[locationindex]
	
	while(IsValid(dummy))
	{
		dummy.Anim_PlayOnly( "animseq/humans/class/medium/pilot_medium_bloodhound/mp_pilot_freefall_dive.rseq")
		
		float distance = dummy.GetOrigin().z - locationEnd.z //Tracking the distance dummy is to the ground

		if( distance > 500 && distance <= 750)
		{		
			dummy.Anim_ScriptedPlayActivityByName( "ACT_MP_FREEFALL_TRANSITION_TO_ANTICIPATE", true, 0.1 )
			StopSoundOnEntity(dummy, "Survival_InGameFlight_Travel_3P")
			EmitSoundOnEntity(dummy, "Survival_InGameFlight_Land_Stop_3P")
		}
		else if( distance > 50 && distance <= 500)
		{
			dummy.Anim_ScriptedPlayActivityByName( "ACT_MP_FREEFALL_ANTICIPATE", true, 0.1 )
		}
		else if( distance <= 50)
		{
			StartParticleEffectInWorld( GetParticleSystemIndex( FIRINGRANGE_ITEM_RESPAWN_PARTICLE ), dummy.GetOrigin(), dummy.GetAngles() )
			if(IsValid(dummy))
				dummy.Destroy()
		}
		WaitFrame()	
	}
}
//CHALLENGE "Long Range Practice"
void function StartRunningTargetsChallenge(entity player)
{
	if(!IsValid(player)) return
	player.SetOrigin(file.onGroundLocationPos)
	player.SetAngles(file.onGroundLocationAngs)
	EndSignal(player, "ChallengeTimeOver")

	OnThreadEnd(
		function() : ( player)
		{
			OnChallengeEnd(player)
		}
	)
	wait AimTrainer_PRE_START_TIME
	RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD_INSTANT )
	RemoveCinematicFlag( player, CE_FLAG_HIDE_PERMANENT_HUD)
	player.UnfreezeControlsOnServer()
	
	array<vector> circleLocations = NavMesh_RandomPositions( player.GetOrigin(), HULL_HUMAN, 40, 200*AimTrainer_SPAWN_DISTANCE, 300*AimTrainer_SPAWN_DISTANCE  )
	
	if( circleLocations.len() == 0 )
	{
		Message( player, "no navmesh restart game" )
		return
	}

	float endtime = Time() + AimTrainer_CHALLENGE_DURATION
	thread ChallengeWatcherThread(endtime, player)

	WaitFrame()
	while(true){
		array<vector> NewcircleLocations = NavMesh_RandomPositions( AimTrainerOriginToGround( <player.GetOrigin().x, player.GetOrigin().y, 10000> ), HULL_HUMAN, 40, 200*AimTrainer_SPAWN_DISTANCE, 300*AimTrainer_SPAWN_DISTANCE  )
		if(NewcircleLocations.len() > 0 ) 
		{
			circleLocations.clear()
			circleLocations = NewcircleLocations
		}
		if(!AimTrainer_INFINITE_CHALLENGE && Time() > endtime) break	
		if(ChallengesEntities.dummies.len()<25){
			vector org1 = player.GetOrigin()
			int locationindex = RandomInt(circleLocations.len())
			vector org2 = circleLocations[locationindex]
			vector vec2 = org1 - org2
			int random = 1
			if(CoinFlip()) random = -1
			vector angles2 = AnglesToRight(VectorToAngles(vec2))*90*random
			vector circleoriginfordummy = circleLocations[locationindex]
			entity dummy = CreateDummy( 99, AimTrainerOriginToGround( <circleoriginfordummy.x, circleoriginfordummy.y, 10000> ), Vector(0,angles2.y,0) )
			SetSpawnOption_AISettings( dummy, "npc_dummie_combat_trainer" )
			DispatchSpawn( dummy )
			
			// PutEntityInSafeSpot( dummy, null, null, dummy.GetOrigin() + dummy.GetUpVector()*2048 + dummy.GetForwardVector()*2048 , dummy.GetOrigin() )
		
			dummy.SetShieldHealthMax( ReturnShieldAmountForDesiredLevel() )
			dummy.SetShieldHealth( ReturnShieldAmountForDesiredLevel() )
			dummy.SetMaxHealth( AimTrainer_AI_HEALTH )
			dummy.SetHealth( AimTrainer_AI_HEALTH )
			SetCommonDummyLines(dummy)
			ChallengesEntities.dummies.append(dummy)
			AddEntityCallback_OnDamaged(dummy, OnStraferDummyDamaged)
			AddEntityCallback_OnKilled(dummy, OnDummyKilled)
			
			thread DummyRunningTargetsMovement(dummy, player)
			thread ClippingAIWorkaround(dummy)
			wait 0.2
		}
		WaitFrame()
	}
}

void function DummyRunningTargetsMovement(entity ai, entity player)
{
	if(!IsValid(ai)) return
	if(!IsValid(player )) return
	
	ai.EndSignal("OnDeath")
	player.EndSignal("ChallengeTimeOver")
	
	OnThreadEnd(
		function() : ( ai )
		{
			if(IsValid(ai)) ai.Destroy()
			ChallengesEntities.dummies.removebyvalue(ai)
		}
	)
	
	WaitFrame()

	ai.Anim_ScriptedPlayActivityByName( "ACT_SPRINT_FORWARD", true, 0.1 )
	ai.Anim_SetPlaybackRate(AimTrainer_STRAFING_SPEED)
	wait 0.5
	while(IsValid(ai)){
		float distance = Distance(ai.GetOrigin(), player.GetOrigin()) //Tracking the distance dummy is to the player
		int random = RandomIntRangeInclusive(1,10)
		if(random == 1 && distance >= 500 || random == 2 && distance >= 500 || random == 3 && distance >= 500)
		{
			int randomangle = RandomIntRange(-45,45)
			if(CoinFlip()) randomangle = RandomIntRange(-90,90)
			vector angles = ai.GetAngles() + Vector(0,randomangle,0)
			ai.SetAngles(Vector(0,angles.y,0) )
		}
		if(distance <= 100*AimTrainer_SPAWN_DISTANCE) //avoid being too close to player
		{ 
			vector vec = player.GetOrigin() - ai.GetOrigin()
			vector angles2 = VectorToAngles( vec )
			ai.SetAngles(Vector(0,angles2.y*-1,0) )
			wait 0.5
		}
		else if(distance >= 3000)
		{ 
			ai.Destroy()
			break
		}
		WaitFrame()
	}
}

//CHALLENGE ArmorSwap
void function StartArmorSwapChallenge(entity player)
{
	if(!IsValid(player)) return
	
	if( MapName() == eMaps.mp_rr_desertlands_64k_x_64k || MapName() == eMaps.mp_rr_desertlands_64k_x_64k_nx || MapName() == eMaps.mp_rr_desertlands_64k_x_64k_tt ||
	 MapName() == eMaps.mp_rr_desertlands_mu1 || MapName() == eMaps.mp_rr_desertlands__mu1_tt || MapName() == eMaps.mp_rr_desertlands_mu2 || MapName() == eMaps.mp_rr_desertlands_holiday )
		player.SetOrigin(<10377.2695, 6253.86523, -4303.90625>)
	else
		player.SetOrigin(file.onGroundLocationPos)
	
	player.SetAngles(file.onGroundLocationAngs)
	EndSignal(player, "ChallengeTimeOver")

	OnThreadEnd(
		function() : ( player)
		{
			OnChallengeEnd(player)
		}
	)
	wait AimTrainer_PRE_START_TIME
	RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD_INSTANT )
	RemoveCinematicFlag( player, CE_FLAG_HIDE_PERMANENT_HUD)
	player.UnfreezeControlsOnServer()
	
	array<vector> circleLocations = NavMesh_RandomPositions( player.GetOrigin(), HULL_HUMAN, 10, 20*AimTrainer_SPAWN_DISTANCE, 50*AimTrainer_SPAWN_DISTANCE  )

	while(true){
		WaitFrame()
		array<vector> NewcircleLocations = NavMesh_RandomPositions( AimTrainerOriginToGround( <player.GetOrigin().x, player.GetOrigin().y, 10000> ), HULL_HUMAN, 10, 20*AimTrainer_SPAWN_DISTANCE, 50*AimTrainer_SPAWN_DISTANCE  )
		if(NewcircleLocations.len() > 0 ) 
		{
			circleLocations.clear()			
		}
		
		circleLocations = NewcircleLocations	
		
		if(circleLocations.len() == 0)
			continue
		
		foreach(deathbox in ChallengesEntities.dummies)
			if(!IsValid(deathbox)) 
				ChallengesEntities.dummies.removebyvalue(deathbox)
		
		while(ChallengesEntities.dummies.len()<4){
			vector org1 = player.GetOrigin()
			
			int locationindex = RandomInt(circleLocations.len())

			vector circleoriginfordeathbox = circleLocations[locationindex]
			
			NewcircleLocations.removebyvalue( circleoriginfordeathbox )
			
			entity deathbox = CreateAimtrainerDeathbox( player, circleoriginfordeathbox)
			ChallengesEntities.dummies.append(deathbox)
			
			thread CheckDistanceFromDeathboxes(player, deathbox)
			thread EnableDeathboxMantleAfterSomeTime(deathbox)
			
			wait 0.2
		}		
	}
}


//PATTERN TRACKING CHALLENGE
void function StartPatternTrackingChallenge(entity player)
{
	printw( "StartPatternTrackingChallenge" )
	
	if(!IsValid(player)) return
	
	// Calculate box dimensions based on tracking area configuration  
	// Ball moves in Y-Z plane, so swap width and depth to match movement
	float boxWidth = AimTrainer_TRACKING_TILES_DEPTH * 700.0       // X dimension (front to back)
	float boxHeight = AimTrainer_TRACKING_TILES_VERTICAL * 700.0   // Z dimension (vertical)
	float boxDepth = AimTrainer_TRACKING_TILES_HORIZONTAL * 700.0  // Y dimension (left to right)
	
	// Calculate room center position (independent of player)
	vector roomCenter = file.floorCenterForPlayerSky + Vector(0, 0, boxHeight/2)
	
	// Position player against back wall (X positive direction), centered in Y, at mid height (Z)
	vector playerPos = roomCenter + Vector(boxWidth/2 - AimTrainer_TRACKING_PLAYER_WALL_OFFSET, 0, 0)
	player.SetOrigin(playerPos)
	player.SetAngles(Vector(0, 180, 0)) // Face toward front wall (negative X direction)
	
	EndSignal(player, "ChallengeTimeOver")
	
	// Position target center close to front wall (X negative direction)
	vector targetCenter = roomCenter + Vector(-boxWidth/2 + AimTrainer_TRACKING_TARGET_WALL_OFFSET, 0, 0)
	
	// Create complete tracking box with cafe_floor.rmdl props (includes floor, walls, and ceiling)
	ChallengesEntities.floor = CreateTrackingBox(roomCenter, boxWidth, boxHeight, boxDepth)
	
	// Create small platform (1 tile) for player to stand on at mid-height, positioned as border behind player
	vector platformPos = playerPos + Vector(700, 0, 300) // Move platform toward back wall (behind player)
	array<entity> platform = CreateMiddlePlatform(platformPos, 700.0, 700.0, 1.0, 0.0)
	ChallengesEntities.floor.extend(platform)
	
	OnThreadEnd(
		function() : ( player)
		{
			OnChallengeEnd(player)
			// player.MovementEnable()
		}
	)
	
	wait AimTrainer_PRE_START_TIME
	RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD_INSTANT )
	RemoveCinematicFlag( player, CE_FLAG_HIDE_PERMANENT_HUD)
	player.UnfreezeControlsOnServer()
	
	// player.MovementDisable()
	
	float endtime = Time() + AimTrainer_CHALLENGE_DURATION
	thread ChallengeWatcherThread(endtime, player)
	
	// Spawn single ball for pattern movement
	entity target = CreateTrackingTarget(player, targetCenter)
	if(IsValid(target))
	{
		ChallengesEntities.props.append(target)
		thread PatternMovement(player, target, targetCenter)
		thread PatternMovement_FixTargetAngles(player, target)
	}
	
	WaitForever()
}

//BOUNCING TRACKING CHALLENGE
void function StartBouncingTrackingChallenge(entity player)
{
	printw( "StartBouncingTrackingChallenge" )
	
	if(!IsValid(player)) return
	
	// Calculate box dimensions based on tracking area configuration  
	// Ball moves in Y-Z plane, so swap width and depth to match movement
	float boxWidth = AimTrainer_TRACKING_TILES_DEPTH * 700.0       // X dimension (front to back)
	float boxHeight = AimTrainer_TRACKING_TILES_VERTICAL * 700.0   // Z dimension (vertical)
	float boxDepth = AimTrainer_TRACKING_TILES_HORIZONTAL * 700.0  // Y dimension (left to right)
	
	// Calculate room center position (independent of player)
	vector roomCenter = file.floorCenterForPlayerSky + Vector(0, 0, boxHeight/2)
	
	// Position player against back wall (X positive direction), centered in Y, at mid height (Z)
	vector playerPos = roomCenter + Vector(boxWidth/2 - AimTrainer_TRACKING_PLAYER_WALL_OFFSET, 0, 0)
	player.SetOrigin(playerPos)
	player.SetAngles(Vector(0, 180, 0)) // Face toward front wall (negative X direction)
	
	EndSignal(player, "ChallengeTimeOver")
	
	// Position target center close to front wall (X negative direction)
	vector targetCenter = roomCenter + Vector(-boxWidth/2 + AimTrainer_TRACKING_TARGET_WALL_OFFSET, 0, 0)
	
	// Create complete tracking box with cafe_floor.rmdl props (includes floor, walls, and ceiling)
	ChallengesEntities.floor = CreateTrackingBox(roomCenter, boxWidth, boxHeight, boxDepth)
	
	// Create small platform (1 tile) for player to stand on at mid-height, positioned as border behind player
	vector platformPos = playerPos + Vector(700, 0, 300) // Move platform toward back wall (behind player)
	array<entity> platform = CreateMiddlePlatform(platformPos, 700.0, 700.0, 1.0, 0.0)
	ChallengesEntities.floor.extend(platform)
	
	OnThreadEnd(
		function() : ( player)
		{
			OnChallengeEnd(player)
			// player.MovementEnable()
		}
	)
	
	wait AimTrainer_PRE_START_TIME
	RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD_INSTANT )
	RemoveCinematicFlag( player, CE_FLAG_HIDE_PERMANENT_HUD)
	player.UnfreezeControlsOnServer()
	
	// player.MovementDisable()
	
	float endtime = Time() + AimTrainer_CHALLENGE_DURATION
	thread ChallengeWatcherThread(endtime, player)
	
	for(int i = 0; i < 1; i++) //AimTrainer_TRACKING_BALL_COUNT
	{
		vector ballStartPos = targetCenter
		if(AimTrainer_TRACKING_RANDOM_START)
		{
			float halfWidth = (AimTrainer_TRACKING_TILES_HORIZONTAL * 700.0) / 2
			float halfHeight = (AimTrainer_TRACKING_TILES_VERTICAL * 700.0) / 2
			float randX = RandomFloatRange(-halfWidth, halfWidth)
			float randZ = RandomFloatRange(-halfHeight, halfHeight)
			ballStartPos = targetCenter + Vector(0, randX, randZ)
		}
		
		entity target = CreateTrackingTarget(player, ballStartPos)
		if(IsValid(target))
		{
			ChallengesEntities.props.append(target)
			thread BounceMovement(player, target, targetCenter)
			thread PatternMovement_FixTargetAngles(player, target)
		}
	}
	
	WaitForever()
}

//MULTI-BALL HEALTH TRACKING CHALLENGE
void function StartMultiBallHealthTrackingChallenge(entity player)
{
	printw( "StartMultiBallHealthTrackingChallenge" )
	
	if(!IsValid(player)) return
	
	// Calculate box dimensions based on tracking area configuration  
	float boxWidth = AimTrainer_TRACKING_TILES_DEPTH * 700.0       // X dimension (front to back)
	float boxHeight = AimTrainer_TRACKING_TILES_VERTICAL * 700.0   // Z dimension (vertical)
	float boxDepth = AimTrainer_TRACKING_TILES_HORIZONTAL * 700.0  // Y dimension (left to right)
	
	// Calculate room center position (independent of player)
	vector roomCenter = file.floorCenterForPlayerSky + Vector(0, 0, boxHeight/2)
	
	// Position player against back wall (X positive direction), centered in Y, at mid height (Z)
	vector playerPos = roomCenter + Vector(boxWidth/2 - AimTrainer_TRACKING_PLAYER_WALL_OFFSET, 0, 0)
	player.SetOrigin(playerPos)
	player.SetAngles(Vector(0, 180, 0)) // Face toward front wall (negative X direction)
	
	EndSignal(player, "ChallengeTimeOver")
	
	// Position target center close to front wall (X negative direction)
	vector targetCenter = roomCenter + Vector(-boxWidth/2 + AimTrainer_TRACKING_TARGET_WALL_OFFSET, 0, 0)
	
	// Create complete tracking box with cafe_floor.rmdl props (includes floor, walls, and ceiling)
	ChallengesEntities.floor = CreateTrackingBox(roomCenter, boxWidth, boxHeight, boxDepth)
	
	// Create small platform (1 tile) for player to stand on at mid-height, positioned as border behind player
	vector platformPos = playerPos + Vector(700, 0, 300) // Move platform toward back wall (behind player)
	array<entity> platform = CreateMiddlePlatform(platformPos, 700.0, 700.0, 1.0, 0.0)
	ChallengesEntities.floor.extend(platform)
	
	OnThreadEnd(
		function() : ( player)
		{
			OnChallengeEnd(player)
			player.MovementEnable()
		}
	)
	
	wait AimTrainer_PRE_START_TIME
	RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD_INSTANT )
	RemoveCinematicFlag( player, CE_FLAG_HIDE_PERMANENT_HUD)
	player.UnfreezeControlsOnServer()
	player.MovementDisable()
	
	float endtime = Time() + AimTrainer_CHALLENGE_DURATION
	thread ChallengeWatcherThread(endtime, player)
	
	// Start with 5 balls initially
	int initialBallCount = 5
	
	for(int i = 0; i < initialBallCount; i++)
	{
		thread SpawnHealthBall(player, targetCenter, i * 0.2) // Stagger spawning slightly
	}
	
	WaitForever()
}

void function SpawnHealthBall(entity player, vector targetCenter, float delay = 0.0)
{
	printw( "Spawning ball" )

	if(delay > 0.0)
		wait delay
		
	if(!IsValid(player))
		return
		
	// Random starting position within the tracking area
	float halfWidth = (AimTrainer_TRACKING_TILES_HORIZONTAL * 700.0) / 2
	float halfHeight = (AimTrainer_TRACKING_TILES_VERTICAL * 700.0) / 2
	float randX = RandomFloatRange(-halfWidth, halfWidth)
	float randZ = RandomFloatRange(-halfHeight, halfHeight)
	vector ballStartPos = targetCenter + Vector(0, randX, randZ)
	
	entity target = CreateHealthTrackingTarget(player, ballStartPos)
	if(IsValid(target))
	{
		ChallengesEntities.props.append(target)
		thread BounceMovement(player, target, targetCenter)
		thread PatternMovement_FixTargetAngles(player, target)
		thread HealthBallWatcher(player, target, targetCenter)
	}
}

void function HealthBallWatcher(entity player, entity target, vector targetCenter)
{
	if(!IsValid(player) || !IsValid(target))
		return
		
	// target.EndSignal("OnDestroy")
	player.EndSignal("ChallengeTimeOver")
	
	while(IsValid(target) && target.GetHealth() > 0)
	{
		WaitFrame()
	}
	
	// Ball was killed, spawn a new one after a short delay
	// wait 1.0
	player.p.straferDummyKilledCount++
	Remote_CallFunction_NonReplay(player, "ServerCallback_LiveStatsUIDummiesKilled", player.p.straferDummyKilledCount)
	
	if(IsValid(player))
		thread SpawnHealthBall(player, targetCenter)
}

entity function CreateHealthTrackingTarget(entity player, vector centerPos)
{
	entity target = CreateEntity( "script_mover" )
	target.SetValueForModelKey( AIMTRAINER_TRACKING_MODEL )
	target.kv.fadedist = -1
	target.kv.renderamt = 255
	target.kv.rendercolor = "255 255 255"
	target.kv.solid = 6 // SOLID_BBOX
	target.kv.SpawnAsPhysicsMover = 0
	target.SetOrigin( centerPos )
	target.SetAngles( Vector( 0, 0, 0 ) )
	target.SetModelScale( AimTrainer_TRACKING_TARGET_SCALE )
	
	DispatchSpawn( target )

	target.SetMaxHealth( 100 ) // Give balls 100 health instead of just resetting
	target.SetHealth( 100 )
	target.SetTakeDamageType( DAMAGE_YES )
	target.SetDamageNotifications( true )
	target.SetAimAssistAllowed( true )
	
	AddEntityCallback_OnDamaged( target, OnHealthTrackingTargetDamaged )
	
	EmitSoundOnEntityOnlyToPlayer( player, player, "player_hitbeep_headshot_kill_android_3p_vs_1p" )
			
			// //Required for Aim Assist?
			// entity dummy = CreateDummy( 99, target.GetOrigin(), target.GetAngles() )
			// SetSpawnOption_AISettings( dummy, "npc_training_dummy_trainer_target" )
			// DispatchSpawn( dummy )
			// dummy.SetParent( target )
			// dummy.SetAimAssistAllowed( true )
			
	return target
}

void function OnHealthTrackingTargetDamaged( entity target, var damageInfo )
{
	if ( !IsValid( target ) )
		return
		
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( !IsValid( attacker ) || !attacker.IsPlayer() )
		return

	float damage = DamageInfo_GetDamage( damageInfo )
	target.SetHealth( max(0, target.GetHealth() - int(damage)) )
	
	// Play hit sound and visual effect
	EmitSoundOnEntityOnlyToPlayer( attacker, attacker, "player_hitbeep" )
	
	Remote_CallFunction_NonReplay(attacker, "ServerCallback_LiveStatsUIAccuracyViaShotsHits")
	Remote_CallFunction_NonReplay(attacker, "ServerCallback_LiveStatsUIDamageViaDummieDamaged", int(damage))
	Remote_CallFunction_NonReplay(attacker, "AimTrainer_LootRollerDamageRgb", target)
	
	if ( target.GetHealth() <= 0 )
	{
		// Ball killed, award points and clean up
		attacker.p.straferDummyKilledCount++
		Remote_CallFunction_NonReplay(attacker, "ServerCallback_LiveStatsUIDummiesKilled", attacker.p.straferDummyKilledCount)
		
		// Remove from props array
		if ( ChallengesEntities.props.contains( target ) )
		{
			ChallengesEntities.props.removebyvalue( target )
		}
		
		target.Destroy()
	}
}

//RANDOM SPEED TRACKING CHALLENGE
void function StartRandomSpeedTrackingChallenge(entity player)
{
	printw( "StartRandomSpeedTrackingChallenge" )
	
	if(!IsValid(player)) return
	
	// Calculate box dimensions based on tracking area configuration  
	float boxWidth = AimTrainer_TRACKING_TILES_DEPTH * 700.0       // X dimension (front to back)
	float boxHeight = AimTrainer_TRACKING_TILES_VERTICAL * 700.0   // Z dimension (vertical)
	float boxDepth = AimTrainer_TRACKING_TILES_HORIZONTAL * 700.0  // Y dimension (left to right)
	
	// Calculate room center position (independent of player)
	vector roomCenter = file.floorCenterForPlayerSky + Vector(0, 0, boxHeight/2)
	
	// Position player against back wall (X positive direction), centered in Y, at mid height (Z)
	vector playerPos = roomCenter + Vector(boxWidth/2 - AimTrainer_TRACKING_PLAYER_WALL_OFFSET, 0, 0)
	player.SetOrigin(playerPos)
	player.SetAngles(Vector(0, 180, 0)) // Face toward front wall (negative X direction)
	
	EndSignal(player, "ChallengeTimeOver")
	
	// Position target center close to front wall (X negative direction)
	vector targetCenter = roomCenter + Vector(-boxWidth/2 + AimTrainer_TRACKING_TARGET_WALL_OFFSET, 0, 0)
	
	// Create complete tracking box with cafe_floor.rmdl props (includes floor, walls, and ceiling)
	ChallengesEntities.floor = CreateTrackingBox(roomCenter, boxWidth, boxHeight, boxDepth)
	
	// Create small platform (1 tile) for player to stand on at mid-height, positioned as border behind player
	vector platformPos = playerPos + Vector(700, 0, 300) // Move platform toward back wall (behind player)
	array<entity> platform = CreateMiddlePlatform(platformPos, 700.0, 700.0, 1.0, 0.0)
	ChallengesEntities.floor.extend(platform)
	
	OnThreadEnd(
		function() : ( player)
		{
			OnChallengeEnd(player)
			player.MovementEnable()
		}
	)
	
	wait AimTrainer_PRE_START_TIME
	RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD_INSTANT )
	RemoveCinematicFlag( player, CE_FLAG_HIDE_PERMANENT_HUD)
	player.UnfreezeControlsOnServer()
	player.MovementDisable()
	
	float endtime = Time() + AimTrainer_CHALLENGE_DURATION
	thread ChallengeWatcherThread(endtime, player)
	
	// Start with 5 balls initially
	int initialBallCount = 5
	
	for(int i = 0; i < initialBallCount; i++)
	{
		thread SpawnRandomSpeedBall(player, targetCenter, i * 0.2) // Stagger spawning slightly
	}
	
	WaitForever()
}

void function SpawnRandomSpeedBall(entity player, vector targetCenter, float delay = 0.0)
{
	if(delay > 0.0)
		wait delay
		
	if(!IsValid(player))
		return
		
	// Random starting position within the tracking area
	float halfWidth = (AimTrainer_TRACKING_TILES_HORIZONTAL * 700.0) / 2
	float halfHeight = (AimTrainer_TRACKING_TILES_VERTICAL * 700.0) / 2
	float randX = RandomFloatRange(-halfWidth, halfWidth)
	float randZ = RandomFloatRange(-halfHeight, halfHeight)
	vector ballStartPos = targetCenter + Vector(0, randX, randZ)
	
	// Generate random speed for this ball
	float randomSpeedMultiplier = RandomFloatRange(0.5, 1.5)
	
	entity target = CreateHealthTrackingTarget(player, ballStartPos)
	
	if(IsValid(target))
	{
		ChallengesEntities.props.append(target)
		thread RandomSpeedBounceMovement(player, target, targetCenter, randomSpeedMultiplier)
		thread PatternMovement_FixTargetAngles(player, target)
		thread RandomSpeedBallWatcher(player, target, targetCenter)
	}
}

void function RandomSpeedBallWatcher(entity player, entity target, vector targetCenter)
{
	if(!IsValid(player) || !IsValid(target))
		return
		
	// target.EndSignal("OnDestroy")
	player.EndSignal("ChallengeTimeOver")
	
	while(IsValid(target) && target.GetHealth() > 0)
	{
		WaitFrame()
	}
	
	// Ball was killed, spawn a new one after a short delay
	// wait 1.0
	player.p.straferDummyKilledCount++
	Remote_CallFunction_NonReplay(player, "ServerCallback_LiveStatsUIDummiesKilled", player.p.straferDummyKilledCount)
	
	if(IsValid(player))
		thread SpawnRandomSpeedBall(player, targetCenter)
}

void function SpawnAntiMirrorStrafingHealthBall(entity player, vector targetCenter, bool isMirror = false )
{
	if(!IsValid(player))
		return
		
	player.EndSignal("ChallengeTimeOver")
	
	// Get player position and view direction
	vector playerPos = player.GetOrigin()
	vector playerAngles = player.GetAngles()
	
	// Use player's actual view direction (EyeAngles for better accuracy)
	vector eyeAngles = player.EyeAngles()
	float playerYaw = eyeAngles.y
	
	// Spawn within narrower field of view (±30° from center) to ensure visibility
	float spawnDistance = RandomFloatRange(500.0, 900.0)  // Closer distance for better visibility
	float viewOffsetDeg = RandomFloatRange(-60.0, 60.0)  // ±60° from center view
	float finalYaw = playerYaw + viewOffsetDeg
	float finalYawRad = finalYaw * (PI / 180.0)
	
	// Calculate forward direction vector from yaw
	vector forwardDir = Vector(
		cos(finalYawRad),  // X component
		sin(finalYawRad),  // Y component
		0.0
	)
	
	vector ballStartPos = Vector(
		playerPos.x + forwardDir.x * spawnDistance,
		playerPos.y + forwardDir.y * spawnDistance,
		playerPos.z + AimTrainer_PATSTRAFE_HEIGHT_OFFSET  // Height offset above ground
	)
	
	entity target = CreateHealthTrackingTarget(player, ballStartPos)
	
	target.SetMaxHealth( 150 ) // Give balls 100 health instead of just resetting
	target.SetHealth( 150 )
	
	if(IsValid(target))
	{
		ChallengesEntities.props.append(target)
		thread AntiMirrorStrafingMovement(player, target, targetCenter, isMirror)
		thread PatternMovement_FixTargetAngles(player, target, true)
		thread AntiMirrorStrafingHealthBallWatcher(player, target, targetCenter)
	}
}

void function AntiMirrorStrafingHealthBallWatcher(entity player, entity target, vector targetCenter)
{
	if(!IsValid(player) || !IsValid(target))
		return
		
	player.EndSignal("ChallengeTimeOver")
	
	while(IsValid(target) && target.GetHealth() > 0)
	{
		WaitFrame()
	}
	
	// Ball was killed, spawn a new one
	player.p.straferDummyKilledCount++
	Remote_CallFunction_NonReplay(player, "ServerCallback_LiveStatsUIDummiesKilled", player.p.straferDummyKilledCount)
	
	if(IsValid(player))
		thread SpawnAntiMirrorStrafingHealthBall(player, targetCenter)
}

void function RandomSpeedBounceMovement(entity player, entity target, vector centerPos, float speedMultiplier)
{
	if(!IsValid(player) || !IsValid(target))
		return
	
	target.EndSignal("OnDestroy")
	player.EndSignal("ChallengeTimeOver")
	
	// Generate constrained initial velocity with random speed
	vector velocity = GenerateConstrainedVelocity()
	velocity = Normalize(velocity) * (100 * AimTrainer_TRACKING_SPEED * speedMultiplier)
	
	// Get room boundaries (same as the tracking area)
	float boxHeight = AimTrainer_TRACKING_TILES_VERTICAL * 700.0
	float halfWidth = (AimTrainer_TRACKING_TILES_HORIZONTAL * 700.0) / 2
	float halfHeight = boxHeight / 2
	
	float floorZ = file.floorCenterForPlayer.z
	float ceilingZ = floorZ + boxHeight
	
	OnThreadEnd(
		function() : ( target )
		{
			if(IsValid(target))
				target.Destroy()
		}
	)
	
	while(true)
	{
		if(!IsValid(target))
			break
			
		vector currentPos = target.GetOrigin()
		vector nextPos = currentPos + velocity * 0.1
		
		// Check Y bounds (left/right walls) and bounce - account for ball radius
		if(nextPos.y < centerPos.y - halfWidth + AimTrainer_TRACKING_BALL_RADIUS || 
		   nextPos.y > centerPos.y + halfWidth - AimTrainer_TRACKING_BALL_RADIUS)
		{
			velocity.y *= -1
			nextPos = currentPos + velocity * 0.1  // Recalculate with new velocity
		}
		
		// Check Z bounds (floor/ceiling) and bounce - allow balls to reach floor completely
		if(nextPos.z < floorZ || 
		   nextPos.z > ceilingZ - AimTrainer_TRACKING_BALL_RADIUS)
		{
			velocity.z *= -1
			nextPos = currentPos + velocity * 0.1  // Recalculate with new velocity
		}
		
		target.NonPhysicsMoveTo(nextPos, 0.1, 0.0, 0.0)
		wait 0.01
	}
}

//ANTIMIRRORSTRAFING CHALLENGE
void function StartAntiMirrorStrafingChallenge(entity player, bool isMirror = false )
{
	printw( "StartAntiMirrorStrafingChallenge" )
	
	if(!IsValid(player)) return
	
	// Initialize AntiMirrorStrafing scoring variables
	file.antiMirrorStrafingConditionalScore = 0.0
	file.antiMirrorStrafingMirrorTime = 0.0
	file.antiMirrorStrafingAntiMirrorTime = 0.0
	file.antiMirrorStrafingTotalTime = 0.0
	
	// Calculate box dimensions based on tracking area configuration  
	float boxWidth = AimTrainer_TRACKING_TILES_DEPTH * 700.0       // X dimension (front to back)
	float boxHeight = AimTrainer_TRACKING_TILES_VERTICAL * 700.0   // Z dimension (vertical)
	float boxDepth = AimTrainer_TRACKING_TILES_HORIZONTAL * 700.0  // Y dimension (left to right)
	
	// Calculate room center position (independent of player)
	vector roomCenter = file.floorCenterForPlayerSky + Vector(0, 0, boxHeight/2)
	
	// Position player at ground level in center of room
	vector playerPos = Vector(roomCenter.x, roomCenter.y, file.floorCenterForPlayer.z)
	player.SetOrigin(playerPos)
	player.SetAngles(Vector(0, 0, 0)) // Face forward initially
	
	EndSignal(player, "ChallengeTimeOver")
	
	// Target will move around the player in 3D space
	vector targetCenter = roomCenter
	
	// Create complete tracking box with cafe_floor.rmdl props (includes floor, walls, and ceiling)
	ChallengesEntities.floor = CreateTrackingBox(roomCenter, boxWidth, boxHeight, boxDepth)
	
	OnThreadEnd(
		function() : ( player)
		{
			OnChallengeEnd(player)
		}
	)
	
	wait AimTrainer_PRE_START_TIME
	RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD_INSTANT )
	RemoveCinematicFlag( player, CE_FLAG_HIDE_PERMANENT_HUD)
	player.UnfreezeControlsOnServer()
	
	float endtime = Time() + AimTrainer_CHALLENGE_DURATION
	thread ChallengeWatcherThread(endtime, player)
	
	// Create single health-based target for AntiMirrorStrafing challenge
	thread SpawnAntiMirrorStrafingHealthBall(player, targetCenter, isMirror )
	
	WaitForever()
}

//POPCORN PHYSICS CHALLENGE
void function StartPopcornPhysicsChallenge(entity player)
{
	printw("StartPopcornPhysicsChallenge")
	
	if(!IsValid(player)) return
	
	// Calculate room dimensions
	float boxWidth = AimTrainer_TRACKING_TILES_DEPTH * 700.0
	float boxHeight = AimTrainer_TRACKING_TILES_VERTICAL * 700.0  
	float boxDepth = AimTrainer_TRACKING_TILES_HORIZONTAL * 700.0
	
	// Calculate room center and player position (same as AntiMirrorStrafing challenge)
	vector roomCenter = file.floorCenterForPlayerSky + Vector(0, 0, boxHeight/2)
	// Position player at ground level in center of room (inside the box)
	vector playerPos = Vector(roomCenter.x, roomCenter.y, file.floorCenterForPlayer.z)
	vector playerAngles = Vector(0, 0, 0)
	
	player.SetOrigin(playerPos)
	player.SetAngles(playerAngles)
	
	EndSignal(player, "ChallengeTimeOver")
	
	// Create room structure
	ChallengesEntities.floor = CreateTrackingBox(roomCenter, boxWidth, boxHeight, boxDepth)
	
	// Cleanup handler
	OnThreadEnd(
		function() : (player)
		{
			OnChallengeEnd(player)
		}
	)
	
	// Pre-start wait and setup
	wait AimTrainer_PRE_START_TIME
	RemoveCinematicFlag(player, CE_FLAG_HIDE_MAIN_HUD_INSTANT)
	RemoveCinematicFlag(player, CE_FLAG_HIDE_PERMANENT_HUD)
	player.UnfreezeControlsOnServer()
	
	// Challenge timing
	float endtime = Time() + AimTrainer_CHALLENGE_DURATION
	thread ChallengeWatcherThread(endtime, player)
	
	// Spawn initial physics targets
	for(int i = 0; i < AimTrainer_POPCORN_PHYSICS_TARGET_COUNT; i++)
	{
		thread SpawnPopcornPhysicsTarget(player, roomCenter, 0.1 * i) // Stagger spawn slightly
	}
	
	WaitForever()
}

void function SpawnPopcornPhysicsTarget(entity player, vector roomCenter, float delay = 0.0)
{
	if(delay > 0.0)
		wait delay
		
	if(!IsValid(player))
		return
		
	// Generate random spawn position at specified distance from player
	float boxWidth = AimTrainer_TRACKING_TILES_DEPTH * 700.0
	float boxHeight = AimTrainer_TRACKING_TILES_VERTICAL * 700.0  
	float boxDepth = AimTrainer_TRACKING_TILES_HORIZONTAL * 700.0
	
	// Player position for distance calculation
	vector playerPos = Vector(roomCenter.x, roomCenter.y, file.floorCenterForPlayer.z)
	
	// Generate spawn position at random distance from player within bounds
	vector spawnPos
	int attempts = 0
	do {
		// Generate random direction and distance
		float spawnDistance = RandomFloatRange(AimTrainer_POPCORN_PHYSICS_SPAWN_DISTANCE_MIN, AimTrainer_POPCORN_PHYSICS_SPAWN_DISTANCE_MAX)
		float angle = RandomFloatRange(0, 2 * PI)
		float elevation = RandomFloatRange(-0.5, 0.5) // Slight vertical variation
		
		// Calculate spawn position
		vector direction = Vector(cos(angle), sin(angle), elevation)
		spawnPos = playerPos + Normalize(direction) * spawnDistance
		
		// Ensure spawn position is within training box boundaries with safety margins
		spawnPos.x = max(roomCenter.x - boxDepth/2 + 150, min(roomCenter.x + boxDepth/2 - 150, spawnPos.x))
		spawnPos.y = max(roomCenter.y - boxWidth/2 + 150, min(roomCenter.y + boxWidth/2 - 150, spawnPos.y))
		spawnPos.z = max(roomCenter.z - boxHeight/2 + 150, min(roomCenter.z + boxHeight/2 - 150, spawnPos.z))
		
		attempts++
	} while (Distance(playerPos, spawnPos) < AimTrainer_POPCORN_PHYSICS_SPAWN_DISTANCE_MIN && attempts < 10)
	
	entity target = CreateEntity("prop_physics")
	target.kv.solid = 0
	target.SetValueForModelKey(AIMTRAINER_TRACKING_MODEL)
	target.SetOrigin(spawnPos)
	target.SetAngles(VectorToAngles(player.GetOrigin() - spawnPos))

	target.kv.minhealthdmg = 9999
	target.kv.nodamageforces = 1	
	target.kv.inertiaScale = 1.0
	
	DispatchSpawn(target)
	// target.Hide()
	
	// Health system
	target.SetMaxHealth(AimTrainer_POPCORN_PHYSICS_TARGET_HEALTH)
	target.SetHealth(AimTrainer_POPCORN_PHYSICS_TARGET_HEALTH)
	target.SetTakeDamageType(DAMAGE_YES)
	target.SetDamageNotifications(true)
		
	// entity targetVisual = CreateHealthTrackingTarget(player, spawnPos)
	// targetVisual.SetMaxHealth( AimTrainer_POPCORN_PHYSICS_TARGET_HEALTH ) // Give balls 100 health instead of just resetting
	// targetVisual.SetHealth( AimTrainer_POPCORN_PHYSICS_TARGET_HEALTH )
	// targetVisual.SetParent( target )
	
	// Apply random initial velocity for physics movement
	vector initialVelocity = Vector(
		RandomFloatRange(-AimTrainer_POPCORN_PHYSICS_VELOCITY_MAX, AimTrainer_POPCORN_PHYSICS_VELOCITY_MAX),
		RandomFloatRange(-AimTrainer_POPCORN_PHYSICS_VELOCITY_MAX, AimTrainer_POPCORN_PHYSICS_VELOCITY_MAX),
		RandomFloatRange(AimTrainer_POPCORN_PHYSICS_UPWARD_VELOCITY_MIN, AimTrainer_POPCORN_PHYSICS_UPWARD_VELOCITY_MAX)
	)
	target.SetVelocity(initialVelocity)
	
	if(IsValid(target))
	{
		ChallengesEntities.props.append(target)
		AddEntityCallback_OnDamaged(target, OnPopcornPhysicsTargetDamaged)
		thread PopcornPhysicsTargetWatcher(player, target, roomCenter)
		thread PopcornPhysicsMovement(player, target, roomCenter)
	}
}

void function PopcornPhysicsTargetWatcher(entity player, entity target, vector roomCenter)
{
	if(!IsValid(player) || !IsValid(target))
		return
		
	player.EndSignal("ChallengeTimeOver")
	
	while(IsValid(target) && target.GetHealth() > 0)
	{
		WaitFrame()
	}
	
	//Award 1 kill
	player.p.straferDummyKilledCount++
	Remote_CallFunction_NonReplay(player, "ServerCallback_LiveStatsUIDummiesKilled", player.p.straferDummyKilledCount)
	
	// Respawn new target after delay
	if(IsValid(player))
		thread SpawnPopcornPhysicsTarget(player, roomCenter, AimTrainer_POPCORN_PHYSICS_RESPAWN_DELAY)
}

void function PopcornPhysicsMovement(entity player, entity target, vector roomCenter)
{
	target.EndSignal("OnDestroy")
	player.EndSignal("ChallengeTimeOver")
	
	while(IsValid(target) && target.GetHealth() > 0)
	{
		// Check if target hits ground (same logic as old popcorn)
		if(target.GetOrigin().z - file.floorCenterForPlayer.z < 50)
		{
			// Calculate direction toward player
			vector angles2 = VectorToAngles(Vector(player.GetOrigin().x, player.GetOrigin().y, file.floorCenterForPlayer.z) - target.GetOrigin())
			target.SetAngles(Vector(0, angles2.y, 0))
			
			// Random direction modifier
			int random = CoinFlip() ? 1 : -1
			
			int random2 = RandomIntRangeInclusive(1, 5)
			if(random2 == 5 || random2 == 4) // 40% chance
			{
				// Move toward player + upward bounce
				target.SetVelocity(AnglesToForward(angles2) * AimTrainer_POPCORN_PHYSICS_VELOCITY_MIN + AnglesToUp(angles2) * RandomFloatRange(AimTrainer_POPCORN_PHYSICS_UPWARD_VELOCITY_MIN, AimTrainer_POPCORN_PHYSICS_UPWARD_VELOCITY_MAX))
			}
			else // 60% chance
			{
				// Move sideways relative to player + upward bounce
				target.SetVelocity((AnglesToRight(angles2) * RandomFloatRange(AimTrainer_POPCORN_PHYSICS_VELOCITY_MIN, AimTrainer_POPCORN_PHYSICS_VELOCITY_MAX) * random) + AnglesToUp(angles2) * RandomFloatRange(AimTrainer_POPCORN_PHYSICS_UPWARD_VELOCITY_MIN, AimTrainer_POPCORN_PHYSICS_UPWARD_VELOCITY_MAX))
			}
			
			EmitSoundOnEntity(target, "JumpPad_LaunchPlayer_3p")
		}
		
		WaitFrame()
	}
}

void function OnPopcornPhysicsTargetDamaged(entity target, var damageInfo)
{
	entity attacker = DamageInfo_GetAttacker(damageInfo)
	float damage = DamageInfo_GetDamage(damageInfo)
	
	target.SetHealth(max(0, target.GetHealth() - int(damage)))
	
	// Visual/audio feedback
	EmitSoundOnEntityOnlyToPlayer(attacker, attacker, "player_hitbeep")
	Remote_CallFunction_NonReplay(attacker, "AimTrainer_LootRollerDamageRgb", target)
	
	// Update stats
	Remote_CallFunction_NonReplay(attacker, "ServerCallback_LiveStatsUIAccuracyViaShotsHits")
	Remote_CallFunction_NonReplay(attacker, "ServerCallback_LiveStatsUIDamageViaDummieDamaged", int(damage))
}

entity function CreateTrackingTarget(entity player, vector centerPos)
{
	entity target = CreateEntity( "script_mover" )
	target.kv.solid = 6
	target.SetValueForModelKey( AIMTRAINER_TRACKING_MODEL )
	target.kv.SpawnAsPhysicsMover = 0
	
	vector startPos = centerPos
	
	target.SetOrigin( startPos )
	target.SetAngles( VectorToAngles( player.GetOrigin() - startPos ) )
	DispatchSpawn( target )
	// target.Hide()
	target.SetDamageNotifications( true )
	
	// entity visual = CreatePropDynamic( $"mdl/barriers/shooting_range_target_02.rmdl", target.GetOrigin(), target.GetAngles(), 6, -1)
	// visual.SetParent(target)
	// visual.SetModelScale(AimTrainer_TRACKING_TARGET_SCALE)
	// visual.NotSolid()
	// printw( "visual spawned at", visual.GetOrigin() )
	// visual.SetDamageNotifications( true )
	// visual.SetPassDamageToParent( true )
	
	AddEntityCallback_OnDamaged(target, OnTrackingTargetDamaged)
	
	// StartParticleEffectInWorld( GetParticleSystemIndex( $"P_wpn_lasercannon_aim_short_blue" ), startPos, VectorToAngles( player.GetOrigin() - startPos ) )
	
	// #if DEVELOPER
	// gp()[0].SetParent( target )
	// #endif
	return target
}

// Generate player-view-relative movement vector for tactical strafing
vector function GeneratePlayerRelativeMovement(vector playerRight, vector playerForward, float speed, bool outsideView = false)
{
	vector movement = <0, 0, 0>

	// Generate movement based on probability patterns
	float movementType = RandomFloat(1.0)
	
	if(movementType < AimTrainer_PATSTRAFE_HORIZONTAL_STRAFE_PROBABILITY)
	{
		// Pure horizontal strafing (left/right relative to player)
		movement = playerRight * RandomFloatRange(-1.0, 1.0)
		// if(AimTrainer_PATSTRAFE_ENABLE_DEBUG_PRINTS)
			// printw("[ANTIMIRRORSTRAFING] Pure horizontal strafe")
	}
	else if(movementType < AimTrainer_PATSTRAFE_HORIZONTAL_STRAFE_PROBABILITY + AimTrainer_PATSTRAFE_DIAGONAL_MOVEMENT_PROBABILITY)
	{
		// Diagonal movement (forward/back + left/right)
		movement = playerRight * RandomFloatRange(-0.8, 0.8)
		movement = movement + (playerForward * RandomFloatRange(-0.6, 0.6))
		// if(AimTrainer_PATSTRAFE_ENABLE_DEBUG_PRINTS)
			// printw("[ANTIMIRRORSTRAFING] Diagonal movement")
	}
	else
	{
		// Forward/backward movement
		movement = playerForward * RandomFloatRange(-1.0, 1.0)
		// if(AimTrainer_PATSTRAFE_ENABLE_DEBUG_PRINTS)
			// printw("[ANTIMIRRORSTRAFING] Forward/backward movement")
	}
	
	// Ensure Z component is always 0 (horizontal only)
	movement.z = 0.0
	
	// Normalize and apply speed
	if(Length(movement) > 0.0)
		movement = Normalize(movement) * speed
	else
		movement = playerRight * speed  // Default fallback
	
	return movement
}

void function AntiMirrorStrafingMovement(entity player, entity target, vector centerPos, bool scoreMirrorMovement = false)
{
	target.EndSignal("OnDestroy")
	player.EndSignal("ChallengeTimeOver")
	
	// Ultra fast unpredictable movement settings
	float baseSpeed = AimTrainer_TRACKING_SPEED * AimTrainer_PATSTRAFE_SPEED_MULTIPLIER  // Configurable speed
	float changeDirectionProbability = AimTrainer_PATSTRAFE_DIRECTION_CHANGE_PROBABILITY  // Configurable direction change rate
	float minDistance = 300.0  // Minimum distance from player
	float maxDistance = AimTrainer_PATSTRAFE_MAX_DISTANCE // Maximum distance from player
	
	// Movement tracking variables for conditional distance scoring
	vector previousPlayerPos = player.GetOrigin()
	vector previousBotPos = target.GetOrigin()
	// Note: conditionalDistanceScore, mirrorTime, antiMirrorTime, totalTime now use file.antiMirrorStrafingXXX for persistence
	int frameCount = 0
	
	// Fixed speed per movement variables
	float currentFixedSpeed = baseSpeed
	bool directionChanged = false
	
	// Room boundaries
	float halfWidth = (AimTrainer_TRACKING_TILES_HORIZONTAL * 700.0) / 2 - AimTrainer_TRACKING_BALL_RADIUS
	float halfHeight = (AimTrainer_TRACKING_TILES_VERTICAL * 700.0) / 2 - AimTrainer_TRACKING_BALL_RADIUS
	float halfDepth = (AimTrainer_TRACKING_TILES_DEPTH * 700.0) / 2 - AimTrainer_TRACKING_BALL_RADIUS
	
	// Initialize player-view-relative velocity
	vector playerAngles = player.EyeAngles()
	vector playerRight = AnglesToRight(playerAngles)
	vector playerForward = AnglesToForward(playerAngles)
	
	// Start with horizontal strafing movement
	vector velocity = GeneratePlayerRelativeMovement(playerRight, playerForward, baseSpeed)
	
	// Use current target position (set by SpawnAntiMirrorStrafingHealthBall)
	vector currentPos = target.GetOrigin()
	
	if(AimTrainer_PATSTRAFE_ENABLE_MOVEMENT_TRACKING && AimTrainer_PATSTRAFE_ENABLE_DEBUG_PRINTS)
		printw("[ANTIMIRRORSTRAFING] Movement tracking enabled. Score cap:", AimTrainer_PATSTRAFE_MOVEMENT_SCORE_CAP)
	
	while(true)
	{
		if(!IsValid(target))
			break
		
		// Randomly change direction with player-view-relative movement
		if(RandomFloat(1.0) < changeDirectionProbability)
		{
			directionChanged = true
			
			// Update player angles for current view direction
			playerAngles = player.EyeAngles()
			playerRight = AnglesToRight(playerAngles)
			playerForward = AnglesToForward(playerAngles)
			
			// Check if target is outside player's field of view
			vector currentPlayerPos = player.GetOrigin()
			vector playerToTarget = Normalize(currentPos - currentPlayerPos)
			float dotProduct = DotProduct(playerForward, playerToTarget)
			bool outsideView = dotProduct < 0.0  // Behind player or very far to sides
			
			// Generate player-view-relative movement
			velocity = GeneratePlayerRelativeMovement(playerRight, playerForward, baseSpeed, outsideView)
			
			// Apply speed settings
			if(AimTrainer_PATSTRAFE_FIXED_SPEED_PER_MOVEMENT)
			{
				currentFixedSpeed = AimTrainer_PATSTRAFE_FIXED_SPEED
				velocity = Normalize(velocity) * currentFixedSpeed
				if(AimTrainer_PATSTRAFE_ENABLE_DEBUG_PRINTS)
					printw("[ANTIMIRRORSTRAFING] Bot direction change - Using fixed speed:", currentFixedSpeed)
			}
			else
			{
				currentFixedSpeed = RandomFloatRange(AimTrainer_PATSTRAFE_MIN_VARIABLE_SPEED, AimTrainer_PATSTRAFE_MAX_VARIABLE_SPEED)
				velocity = Normalize(velocity) * currentFixedSpeed
				if(AimTrainer_PATSTRAFE_ENABLE_DEBUG_PRINTS)
					printw("[ANTIMIRRORSTRAFING] Bot direction change - Using variable speed:", currentFixedSpeed)
			}
		}
		
		// Calculate next position
		vector nextPos = currentPos + velocity * 0.01
		
		// Get distance from player center
		vector playerPos = player.GetOrigin()
		float distanceFromPlayer = Distance2D(nextPos, playerPos)
		
		// Enhanced distance management with strafing preference
		if(distanceFromPlayer > maxDistance)
		{
			// Pull back toward player with strafing approach
			vector dirToPlayer = Normalize(playerPos - nextPos)
			// Mix direct approach with horizontal strafing (70% direct, 30% strafe)
			float strafeComponent = 0.3
			playerAngles = player.EyeAngles()
			playerRight = AnglesToRight(playerAngles)
			vector strafeDir = playerRight * (RandomFloatRange(-1.0, 1.0))
			velocity = Normalize((dirToPlayer * (1.0 - strafeComponent)) + (strafeDir * strafeComponent)) * baseSpeed
		}
		else if(distanceFromPlayer < minDistance)
		{
			// Push away from player with strafing approach
			vector dirFromPlayer = Normalize(nextPos - playerPos)
			// Mix direct retreat with horizontal strafing
			float strafeComponent = 0.4
			playerAngles = player.EyeAngles()
			playerRight = AnglesToRight(playerAngles)
			vector strafeDir = playerRight * (RandomFloatRange(-1.0, 1.0))
			velocity = Normalize((dirFromPlayer * (1.0 - strafeComponent)) + (strafeDir * strafeComponent)) * baseSpeed
		}
		else if(distanceFromPlayer < AimTrainer_PATSTRAFE_OPTIMAL_DISTANCE_MIN || distanceFromPlayer > AimTrainer_PATSTRAFE_OPTIMAL_DISTANCE_MAX)
		{
			// Adjust to optimal distance range with subtle bias
			float optimalMid = (AimTrainer_PATSTRAFE_OPTIMAL_DISTANCE_MIN + AimTrainer_PATSTRAFE_OPTIMAL_DISTANCE_MAX) / 2.0
			if(distanceFromPlayer < optimalMid)
			{
				// Slightly move away
				vector dirFromPlayer = Normalize(nextPos - playerPos)
				velocity = velocity + (dirFromPlayer * baseSpeed * 0.1)  // Subtle bias
			}
			else
			{
				// Slightly move closer
				vector dirToPlayer = Normalize(playerPos - nextPos)
				velocity = velocity + (dirToPlayer * baseSpeed * 0.1)  // Subtle bias
			}
		}
		
		// Add tactical counter-strafing behavior
		if(RandomFloat(1.0) < AimTrainer_PATSTRAFE_COUNTER_STRAFE_PROBABILITY)
		{
			// Analyze player movement and potentially counter-strafe
			vector currentPlayerPos = player.GetOrigin()
			if(Distance2D(currentPlayerPos, previousPlayerPos) > 2.0)  // Player is moving
			{
				vector playerMoveDir = Normalize(currentPlayerPos - previousPlayerPos)
				playerAngles = player.EyeAngles()
				playerRight = AnglesToRight(playerAngles)
				
				// Calculate if player is strafing left or right
				float playerStrafeComponent = DotProduct(playerMoveDir, playerRight)
				
				if(fabs(playerStrafeComponent) > 0.3)  // Player is strafing significantly
				{
					// Counter-strafe: move opposite to player's strafe direction
					vector counterStrafeDir = playerRight * (-playerStrafeComponent)
					velocity = velocity + (counterStrafeDir * baseSpeed * 0.2)  // Add counter-strafe component
					if(AimTrainer_PATSTRAFE_ENABLE_DEBUG_PRINTS)
						printw("[ANTIMIRRORSTRAFING] Counter-strafing player movement")
				}
			}
		}
		
		// Check horizontal room boundaries and bounce (X and Y only)
		if(nextPos.x > centerPos.x + halfDepth)
		{
			velocity.x = -fabs(velocity.x)
			nextPos.x = centerPos.x + halfDepth
		}
		else if(nextPos.x < centerPos.x - halfDepth)
		{
			velocity.x = fabs(velocity.x)
			nextPos.x = centerPos.x - halfDepth
		}
		
		if(nextPos.y > centerPos.y + halfWidth)
		{
			velocity.y = -fabs(velocity.y)
			nextPos.y = centerPos.y + halfWidth
		}
		else if(nextPos.y < centerPos.y - halfWidth)
		{
			velocity.y = fabs(velocity.y)
			nextPos.y = centerPos.y - halfWidth
		}
		
		// Lock Z position to configured height offset (no vertical movement)
		nextPos.z = player.GetOrigin().z + AimTrainer_PATSTRAFE_HEIGHT_OFFSET
		
		// Update position
		currentPos = nextPos
		target.NonPhysicsMoveTo(nextPos, 0.01, 0.0, 0.0)
		
		// Movement tracking and analysis
		if(AimTrainer_PATSTRAFE_ENABLE_MOVEMENT_TRACKING)
		{
			vector currentPlayerPos = player.GetOrigin()
			vector currentBotPos = nextPos
			
			// Calculate distances moved
			float playerMoveDist = Distance2D(currentPlayerPos, previousPlayerPos)
			float botMoveDist = Distance2D(currentBotPos, previousBotPos)
			
			file.antiMirrorStrafingTotalTime += 0.01
			frameCount++
			
			// Kovaak's Conditional Distance Scoring: Only count distance when NOT mirroring
			bool isMirroring = false
			
			// Calculate movement directions (if significant movement)
			if(playerMoveDist > 1.0 && botMoveDist > 1.0)
			{
				vector playerMoveDir = Normalize(currentPlayerPos - previousPlayerPos)
				vector botMoveDir = Normalize(currentBotPos - previousBotPos)
				
				// Calculate dot product to determine movement correlation
				float dotProduct = DotProduct(playerMoveDir, botMoveDir)
				
				// Check if player is mirroring bot (nearly same direction)
				if(dotProduct > 0.9)  // Nearly perfect mirroring (100% mirror threshold)
				{
					isMirroring = true
					file.antiMirrorStrafingMirrorTime += 0.01  // For debug tracking
				}
				else if(dotProduct < -0.7)  // Anti-mirroring
				{
					file.antiMirrorStrafingAntiMirrorTime += 0.01  // For debug tracking
				}
			}
			
			// Conditional Distance Scoring based on mirror parameter
			bool shouldScore = scoreMirrorMovement ? isMirroring : !isMirroring
			if(shouldScore && playerMoveDist > 0.5)  // Minimum movement threshold
			{
				file.antiMirrorStrafingConditionalScore += (playerMoveDist * AimTrainer_PATSTRAFE_DISTANCE_SCORE_MULTIPLIER)
			}
			
			// Cap score at 1000 (Kovaak's standard)
			float finalMovementScore = min(file.antiMirrorStrafingConditionalScore, AimTrainer_PATSTRAFE_MOVEMENT_SCORE_CAP)
			
			// Calculate percentages for debug display
			float mirrorPercentage = (file.antiMirrorStrafingMirrorTime / file.antiMirrorStrafingTotalTime) * 100.0
			float antiMirrorPercentage = (file.antiMirrorStrafingAntiMirrorTime / file.antiMirrorStrafingTotalTime) * 100.0
			float variedPercentage = 100.0 - mirrorPercentage - antiMirrorPercentage
			
			// Calculate Total Score (KovaaK's style: Movement + Accuracy + Kills)
			float currentAccuracy = player.p.straferTotalShots > 0 ? (float(player.p.straferShotsHit) / float(player.p.straferTotalShots)) : 0.0
			float accuracyBonus = currentAccuracy * 300.0  // Linear scaling, max 300 points at 100% accuracy
			float killBonus = float(player.p.straferDummyKilledCount) * 25.0  // 25 points per kill
			float totalScore = finalMovementScore + accuracyBonus + killBonus
			
			Remote_CallFunction_NonReplay(player, "AimTrainer_SetPatstrafeHudValues", finalMovementScore, mirrorPercentage, antiMirrorPercentage, totalScore, scoreMirrorMovement )
			
			printw("[TOTAL_SCORE] Total:", totalScore)
			
			// Debug prints every 20 frames (1 second at 20 TPS)
			if(frameCount % 20 == 0 && AimTrainer_PATSTRAFE_ENABLE_DEBUG_PRINTS)
			{
				printw("[ANTIMIRRORSTRAFING] Frame:", frameCount, "| Conditional Distance Score:", finalMovementScore, "| Raw Distance:", file.antiMirrorStrafingConditionalScore)
				printw("[ANTIMIRRORSTRAFING] Movement - Mirror:", mirrorPercentage, "% | Anti-Mirror:", antiMirrorPercentage, "% | Varied:", variedPercentage, "%")
				printw("[ANTIMIRRORSTRAFING] Current Mirroring:", isMirroring, "| Distance from player:", distanceFromPlayer)
				
				
				// if(directionChanged)
				// {
					// if(AimTrainer_PATSTRAFE_FIXED_SPEED_PER_MOVEMENT)
						// printw("[ANTIMIRRORSTRAFING] Bot using fixed speed:", currentFixedSpeed)
					// else
						// printw("[ANTIMIRRORSTRAFING] Bot using variable speed")
				// }
			}
			
			// Update previous positions
			previousPlayerPos = currentPlayerPos
			previousBotPos = currentBotPos
			directionChanged = false
		}
		
		wait 0.01
	}
}

void function PatternMovement_FixTargetAngles(entity player, entity target, bool isMirrorOrAntimirrorChallenge = false )
{
	target.EndSignal("OnDestroy")
	
	vector previousPos = target.GetOrigin()
	float rotationY = 0.0
	float rotationX = 0.0
	
	while( true )
	{
		if( AIMTRAINER_TRACKING_MODEL != $"mdl/barriers/shooting_range_target_02.rmdl" )
		{
			// For sphere model: rotate based on movement direction
			vector currentPos = target.GetOrigin()
			vector movementDir = currentPos - previousPos
			
			// Only update rotation if ball is moving significantly
			if( Length(movementDir) > 0.1 )
			{
				// Calculate rotation based on movement direction
				// Convert 2D movement (Y-Z plane) to rotation angles
				float yMovement = movementDir.y
				float zMovement = movementDir.z
				
				// Calculate rotation speeds based on movement direction
				float rotationSpeedY = yMovement * 10.0  // Rolling around Y-axis from left/right movement
				float rotationSpeedX = zMovement * 10.0  // Rolling around X-axis from up/down movement
				
				if( isMirrorOrAntimirrorChallenge ) // Fixed rotation speed for mirror/antimirror challenges
				{
					rotationSpeedY = 100
				}
				
				// Update rotation angles with proper clamping
				rotationY += rotationSpeedY
				while( rotationY >= 360.0 ) rotationY -= 360.0
				while( rotationY < -360.0 ) rotationY += 360.0
				
				rotationX += rotationSpeedX
				while( rotationX >= 360.0 ) rotationX -= 360.0
				while( rotationX < -360.0 ) rotationX += 360.0
				
				target.SetAngles( Vector(rotationX, rotationY, 0) )
			}
			
			// Update previous position for next frame
			previousPos = currentPos
		}
		else
		{
			// For shooting range target: face the player
			target.SetAngles( VectorToAngles( player.GetOrigin() - target.GetOrigin() ) )
		}
		
		wait 0.01
	}
}

void function PatternMovement(entity player, entity target, vector centerPos)
{
	target.EndSignal("OnDestroy")
	
	float halfWidth = (AimTrainer_TRACKING_TILES_HORIZONTAL * 700.0) / 2
	float halfHeight = (AimTrainer_TRACKING_TILES_VERTICAL * 700.0) / 2
	
	// Apply ball radius offset to prevent wall clipping
	float adjustedHalfWidth = halfWidth - AimTrainer_TRACKING_BALL_RADIUS
	float adjustedHalfHeight = halfHeight - AimTrainer_TRACKING_BALL_RADIUS
	
	array<vector> corners = [
		centerPos + Vector(0, -adjustedHalfWidth, adjustedHalfHeight),  // left top
		centerPos + Vector(0, adjustedHalfWidth, -adjustedHalfHeight),  // right bottom
		centerPos + Vector(0, adjustedHalfWidth, adjustedHalfHeight),   // right top
		centerPos + Vector(0, -adjustedHalfWidth, -adjustedHalfHeight)  // left bottom
	]
	
	int currentCorner = 0
	
	while( true )
	{
		vector targetPos = corners[currentCorner]
		float distance = Distance(target.GetOrigin(), targetPos)
		float moveTime = distance / (100 * AimTrainer_TRACKING_SPEED)
		
		target.SetAngles( VectorToAngles( player.GetOrigin() - target.GetOrigin() ) )
		
		target.NonPhysicsMoveTo(targetPos, moveTime, 0.0, 0.0)
		wait moveTime
		
		currentCorner = (currentCorner + 1) % corners.len()
	}
}

vector function GenerateConstrainedVelocity()
{
	// Convert degrees to radians
	float minAngleRad = AimTrainer_TRACKING_MIN_ANGLE_DEG * PI / 180.0
	float maxAngleRad = AimTrainer_TRACKING_MAX_ANGLE_DEG * PI / 180.0
	
	// Generate random angle between min and max constraints
	float angle = RandomFloatRange(minAngleRad, maxAngleRad)
	
	// Randomly choose if we start with horizontal or vertical bias
	bool horizontalBias = CoinFlip()
	
	float y, z
	if(horizontalBias)
	{
		// More horizontal movement (Y dominant)
		y = cos(angle)
		z = sin(angle)
	}
	else
	{
		// More vertical movement (Z dominant)  
		y = sin(angle)
		z = cos(angle)
	}
	
	// Apply random direction signs
	if(CoinFlip()) y *= -1
	if(CoinFlip()) z *= -1
	
	return Vector(0, y, z)
}

void function BounceMovement(entity player, entity target, vector centerPos)
{
	target.EndSignal("OnDestroy")
	
	float halfWidth = (AimTrainer_TRACKING_TILES_HORIZONTAL * 700.0) / 2
	float boxHeight = AimTrainer_TRACKING_TILES_VERTICAL * 700.0
	
	// Calculate floor and ceiling positions - floor is at file.floorCenterForPlayer level
	float floorZ = file.floorCenterForPlayer.z
	float ceilingZ = floorZ + boxHeight
	
	// Generate velocity with angle constraints to avoid too horizontal/vertical movement
	vector velocity = GenerateConstrainedVelocity()
	velocity = Normalize(velocity) * 100 * AimTrainer_TRACKING_SPEED
	
	while( true )
	{
		vector currentPos = target.GetOrigin()
		vector nextPos = currentPos + velocity * 0.1
		
		// Check Y bounds (left/right walls) and bounce - account for ball radius
		if(nextPos.y < centerPos.y - halfWidth + AimTrainer_TRACKING_BALL_RADIUS || 
		   nextPos.y > centerPos.y + halfWidth - AimTrainer_TRACKING_BALL_RADIUS)
		{
			velocity.y *= -1
			nextPos = currentPos + velocity * 0.1  // Recalculate with new velocity
		}
		
		// Check Z bounds (floor/ceiling) and bounce - allow balls to reach floor completely
		if(nextPos.z < floorZ || 
		   nextPos.z > ceilingZ - AimTrainer_TRACKING_BALL_RADIUS)
		{
			velocity.z *= -1
			nextPos = currentPos + velocity * 0.1  // Recalculate with new velocity
		}
		
		target.NonPhysicsMoveTo(nextPos, 0.1, 0.0, 0.0)
		wait 0.01
	}
}

void function OnTrackingTargetDamaged( entity target, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker(damageInfo)
	float damage = DamageInfo_GetDamage( damageInfo )
	
	if(!attacker.IsPlayer()) return
	
	// Reset target health to max instead of destroying
	if( IsValid( target ) )
		target.SetHealth(target.GetMaxHealth())
	
	// Play hit sound
	EmitSoundOnEntityOnlyToPlayer( attacker, attacker, "player_hitbeep" )
	
	if( IsValid( target ) )
		Remote_CallFunction_NonReplay( attacker, "AimTrainer_LootRollerDamageRgb", target )

	Remote_CallFunction_NonReplay(attacker, "ServerCallback_LiveStatsUIDamageViaDummieDamaged", int(damage))
	Remote_CallFunction_NonReplay(attacker, "ServerCallback_LiveStatsUIAccuracyViaShotsHits")
	
	// Optional: Add hit particle effect
	// StartParticleEffectInWorld( GetParticleSystemIndex( $"P_wpn_lasercannon_aim_short_blue" ), target.GetOrigin(), target.GetAngles() )
}

void function CheckDistanceFromDeathboxes(entity player, entity deathbox)
{
	while( IsValid(deathbox) )
	{
		if( Distance( player.GetOrigin(), deathbox.GetOrigin() ) > 500)
		{
			deathbox.Destroy()
			break
		}
	
		WaitFrame()
	}
}

void function EnableDeathboxMantleAfterSomeTime(entity deathbox)
{
	wait 1
	if( IsValid(deathbox) )
		deathbox.AllowMantle()
}

entity function CreateAimtrainerDeathbox( entity player, vector origin)
{
	entity deathBox = FlowState_CreateDeathBox( player, origin)
	
	int weaponcount
	foreach ( invItem in AimTrainer_FillDeathbox( player ) )
	{
		LootData data = SURVIVAL_Loot_GetLootDataByIndex( invItem.type )
		
		if( data.lootType == eLootType.MAINWEAPON && weaponcount == 2 )
		{
			continue
		}
		
		if( data.lootType == eLootType.MAINWEAPON )
		{
			weaponcount++
		}
		entity loot = SpawnGenericLoot( data.ref, deathBox.GetOrigin(), deathBox.GetAngles(), invItem.count )
		AddToDeathBox( loot, deathBox )
	}

	UpdateDeathBoxHighlight( deathBox )

	foreach ( func in svGlobal.onDeathBoxSpawnedCallbacks )
		func( deathBox, null, 0 )
		
	return deathBox
}

entity function FlowState_CreateDeathBox( entity player, vector origin)
{
	int randomyaw = RandomIntRange(-360,360)
	entity box = CreatePropDeathBox_NoDispatchSpawn( DEATH_BOX, origin, <0, randomyaw, 0>, 6 )
	
	box.kv.fadedist = 10000
	SetTargetName( box, DEATH_BOX_TARGETNAME )
	DispatchSpawn( box )

	box.Solid()
	box.SetUsable()
	box.SetUsableValue( USABLE_BY_ALL | USABLE_CUSTOM_HINTS )
	// box.SetOwner( player )
	// box.SetNetInt( "ownerEHI", player.GetEncodedEHandle() )
	
	box.SetNetBool( "overrideRUI", true )
	
	array<string> coolDevs = [
		"R5R_CafeFPS",
		"R5R_DEAFPS",
		"R5R_AyeZee",
		"R5R_Makimakima",
		"R5R_Endergreen12",
		"R5R_Zer0Bytes",
		"R5R_Julefox",
		"R5R_AmosMods",
		"R5R_Rexx",
		"R5R_IcePixelx", 
		"R5R_LorryLeKral",
		"R5R_sal"
	]

	box.SetCustomOwnerName( coolDevs.getrandom() )
	box.SetNetInt( "characterIndex", RandomInt(10) )

	Highlight_SetNeutralHighlight( box, "sp_objective_entity" )
	Highlight_ClearNeutralHighlight( box )

	vector restPos = box.GetOrigin()
	vector fallPos = restPos + < 0, 0, 54 >

	thread function() : (box , restPos , fallPos, randomyaw) 
	{
		entity mover = CreateScriptMover( restPos, box.GetAngles(), 0 )
		if ( IsValid( box ) )
			{
			box.SetParent( mover, "", true )
			mover.NonPhysicsMoveTo( fallPos, 0.5, 0.0, 0.5 )
			}
		wait 0.5
		if ( IsValid( box ) )
			mover.NonPhysicsMoveTo( restPos, 0.5, 0.5, 0.0 )
		wait 0.5
		// mover.NonPhysicsRotateTo( Vector(0, randomyaw, anglesonground.z), 0.5, 0.5, 0.0 )
		// wait 0.5
		if ( IsValid( box ) )
			box.ClearParent()
		if ( IsValid( mover ) )
			mover.Destroy()
	} ()
		
	return box
}

array<ConsumableInventoryItem> function AimTrainer_FillDeathbox( entity player )
{
	array<ConsumableInventoryItem> final = []
	array<string> newRefs

	array<string> swaps =
	[
		"armor_pickup_lv4_all_fast",
		"armor_pickup_lv3", 
		"armor_pickup_lv2"
	]

	newRefs.append("mp_weapon_wingman")
	newRefs.append("mp_weapon_r97")
	newRefs.append("helmet_pickup_lv1")
	newRefs.append("incapshield_pickup_lv1")
	newRefs.append("backpack_pickup_lv1")
	newRefs.append( swaps.getrandom() )
	
	foreach(ref in newRefs)
	{
		LootData attachmentData = SURVIVAL_Loot_GetLootDataByRef( ref )

		ConsumableInventoryItem fsItem

		fsItem.type = attachmentData.index
		fsItem.count = 1

		final.append( fsItem )
	}

	return final
}

//Challenges related end functions
void function OnChallengeEnd(entity player)
{
	if(!IsValid(player)) return
	
	player.p.isChallengeActivated = false
	Remote_CallFunction_NonReplay(player, "ServerCallback_SetChallengeActivated", false)
	
	//Calculate challenge duration for validation
	float challengeDuration = Time() - file.challengeStartTime
	
	//Get shared Challenge data using legacy server ID 
	Challenge ornull challengeData = GetChallengeByLegacyServerId(player.p.challengeName)
	
	ChallengeScore ThisChallengeData
	ThisChallengeData.straferDummyKilledCount = player.p.straferDummyKilledCount
	ThisChallengeData.straferChallengeDamage = player.p.straferChallengeDamage
	ThisChallengeData.straferCriticalShots = player.p.straferCriticalShots
	ThisChallengeData.straferShotsHit = player.p.straferShotsHit
	ThisChallengeData.straferTotalShots = player.p.straferTotalShots
	ThisChallengeData.straferAccuracy = float(player.p.straferShotsHit) / float(player.p.straferTotalShots)
	
	// Calculate final total score using the same formula as real-time calculation
	float finalMovementScore = min(file.antiMirrorStrafingConditionalScore, AimTrainer_PATSTRAFE_MOVEMENT_SCORE_CAP)
	float accuracyBonus = ThisChallengeData.straferAccuracy * 300.0
	float killBonus = float(ThisChallengeData.straferDummyKilledCount) * 25.0
	float totalScore = finalMovementScore + accuracyBonus + killBonus
	
	//Update max score convar if duration >= 60 seconds and challenge data found
	if(challengeDuration >= 60.0 && challengeData != null)
	{
		expect Challenge(challengeData)
		int currentMaxScore = GetConVarInt(challengeData.maxScoreConVar)
		int finalScore = ThisChallengeData.straferShotsHit //Use shots hit as the score metric
		
		if(finalScore > currentMaxScore)
		{
			SetConVarInt(challengeData.maxScoreConVar, finalScore)
			
			#if DEVELOPER
			printt("[CHALLENGE] Updated max score for " + challengeData.name + ": " + finalScore + " (duration: " + challengeDuration + "s)")
			#endif
		}
		else
		{
			#if DEVELOPER
			printt("[CHALLENGE] Score " + finalScore + " did not exceed max " + currentMaxScore + " for " + challengeData.name)
			#endif
		}
	}
	else if(challengeDuration < 60.0)
	{
		#if DEVELOPER
		printt("[CHALLENGE] Challenge duration " + challengeDuration + "s < 60s required - score not saved")
		#endif
	}
	
	ChallengesData[player.p.challengeName].append(ThisChallengeData)

	printt("===========================================")
	printt("FLOWSTATE AIM TRAINER CHALLENGE RESULTS:")
	printt(" -Killed dummies: " + ThisChallengeData.straferDummyKilledCount)
	printt(" -Accuracy: " + ThisChallengeData.straferAccuracy)
	printt(" -Shots hit: " + ThisChallengeData.straferShotsHit)
	printt(" -Damage done: " + ThisChallengeData.straferChallengeDamage)
	printt(" -Crit. shots: " + ThisChallengeData.straferCriticalShots)
	printt(" -Movement Score: " + finalMovementScore)
	printt(" -Total Score: " + totalScore + " (Movement: " + finalMovementScore + " + Accuracy: " + accuracyBonus + " + Kills: " + killBonus + ")")
	printt("===========================================")
	
	if(ThisChallengeData.straferShotsHit > ChallengesBestScores[player.p.challengeName]) 
	{		
		ChallengesBestScores[player.p.challengeName] = ThisChallengeData.straferShotsHit
		player.p.isNewBestScore = true
	} else
		player.p.isNewBestScore = false
		
	if(!player.p.isRestartingLevel)
		Remote_CallFunction_NonReplay(player, "ServerCallback_OpenFRChallengesMenu", player.p.challengeName, ThisChallengeData.straferShotsHit, ThisChallengeData.straferDummyKilledCount, ThisChallengeData.straferAccuracy, ThisChallengeData.straferChallengeDamage, ThisChallengeData.straferCriticalShots,ChallengesBestScores[player.p.challengeName], player.p.isNewBestScore)
	
	Remote_CallFunction_NonReplay(player, "ServerCallback_HistoryUIAddNewChallenge", player.p.challengeName, ThisChallengeData.straferShotsHit, player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_0 ), ThisChallengeData.straferAccuracy, ThisChallengeData.straferDummyKilledCount, ThisChallengeData.straferChallengeDamage, ThisChallengeData.straferTotalShots, ThisChallengeData.straferCriticalShots)
	thread ChallengesStartAgain(player)
}

void function ChallengesStartAgain(entity player)
{	
	EndSignal(player, "ForceResultsEnd_SkipButton")
	
	OnThreadEnd(
		function() : ( player )
		{
			if(IsValid(player))
			{
				player.FreezeControlsOnServer()
				player.SetVelocity(Vector(0,0,0))
				if(!player.p.isRestartingLevel)
					player.SetOrigin(file.AimTrainer_startPos)
				player.SetVelocity(Vector(0,0,0))
				if(!player.p.isRestartingLevel)
					player.SetAngles(file.AimTrainer_startAngs)
				
				//entities cleanup
				foreach(entity floor in ChallengesEntities.floor)
					if(IsValid(floor))
						floor.Destroy()
					
				foreach(entity dummie in ChallengesEntities.dummies)
					if(IsValid(dummie))
						dummie.Destroy()
				
				foreach(entity prop2 in ChallengesEntities.props)
					if(IsValid(prop2))			
						prop2.Destroy()
				
				player.p.dummieKilled += player.p.straferDummyKilledCount
				
				ResetChallengeStats(player)
				
				Remote_CallFunction_NonReplay(player, "ServerCallback_ResetLiveStatsUI")
				
				if(!player.p.isRestartingLevel)
				{
					Remote_CallFunction_NonReplay(player, "ServerCallback_CoolCameraOnMenu")
					Remote_CallFunction_NonReplay(player, "ServerCallback_OpenFRChallengesMainMenu", player.p.dummieKilled)
				} else				
					Remote_CallFunction_NonReplay(player, "ServerCallback_CloseFRChallengesResults")
				
				if(player.p.isRestartingLevel)
				{
					player.p.isRestartingLevel = false
					Remote_CallFunction_NonReplay(player, "ServerCallback_RestartChallenge", player.p.challengeName)
				}
			}
		}
	)
	//wait AimTrainer_RESULTS_TIME //should be the same as the while loop in CreateTimerRUI in cl file.
	if(!player.p.isRestartingLevel){
		WaitForever()
	}
}

void function ChallengeWatcherThread(float endtime, entity player)
{
	EndSignal(player, "ForceResultsEnd_SkipButton")
	EndSignal(player, "ChallengeTimeOver")
	
	OnThreadEnd(
		function() : ( player )
		{
			Signal(player, "ChallengeTimeOver")
		}
	)
	
	while(true){
		if(!AimTrainer_INFINITE_CHALLENGE) 
			if(Time() > endtime) break
		WaitFrame()
	}
}

//Callbacks functions
void function OnStraferDummyDamaged( entity dummy, var damageInfo )
{
	entity ent = dummy	
	entity attacker = DamageInfo_GetAttacker(damageInfo)
	if(!attacker.IsPlayer()) return
	
	if(dummy.GetTargetName() == "GrenadesChallengeDummy" )
	{
		// Damage from the grenade explosion does not register as a weapon, so we can assume this damage should not be registered
		if(DamageInfo_GetWeapon(damageInfo) != null)
		{
			return
		}
	}

	float damage = DamageInfo_GetDamage( damageInfo )
	
	//fake helmet
	float headshotMultiplier = GetHeadshotDamageMultiplierFromDamageInfo(damageInfo)
	float basedamage = DamageInfo_GetDamage(damageInfo)/headshotMultiplier
	
	if(IsValidHeadShot( damageInfo, dummy ))
	{
		int headshot = int(basedamage*(settings.helmet_lv4+(1-settings.helmet_lv4)*headshotMultiplier))
		DamageInfo_SetDamage( damageInfo, headshot)
		if(headshot > dummy.GetHealth() + dummy.GetShieldHealth()) 
		{
			printt(dummy.GetHealth() + " " + headshot)
			OnDummyKilled(dummy, damageInfo)
			attacker.p.straferDummyKilledCount++
			Remote_CallFunction_NonReplay(attacker, "ServerCallback_LiveStatsUIDummiesKilled", attacker.p.straferDummyKilledCount)
			ChallengesEntities.dummies.removebyvalue(ent)
		}
	} else if (damage > dummy.GetHealth() + dummy.GetShieldHealth() && dummy.GetShieldHealth() > 0)
	{
		attacker.p.straferDummyKilledCount++
		Remote_CallFunction_NonReplay(attacker, "ServerCallback_LiveStatsUIDummiesKilled", attacker.p.straferDummyKilledCount)
		ChallengesEntities.dummies.removebyvalue(ent)		
	}
	
	if(!attacker.IsPlayer() ) return
	
	//add the damage
	attacker.p.straferChallengeDamage += int(damage)
	Remote_CallFunction_NonReplay(attacker, "ServerCallback_LiveStatsUIDamageViaDummieDamaged", int(damage))
	Remote_CallFunction_NonReplay(attacker, "ServerCallback_LiveStatsUIAccuracyViaShotsHits")
	
	//infinite ammo
	if(AimTrainer_INFINITE_AMMO) attacker.RefillAllAmmo()
		
	//Inmortal target
	if(AimTrainer_INMORTAL_TARGETS || dummy.GetTargetName() == "CloseFastDummy") 
	{
		dummy.SetShieldHealth(dummy.GetShieldHealthMax())
		dummy.SetHealth(dummy.GetMaxHealth())
	}
	//add 1 hit
	attacker.p.straferShotsHit++
	if(attacker.p.straferShotsHit > attacker.p.straferShotsHitRecord) 
	{
		attacker.p.straferShotsHitRecord = attacker.p.straferShotsHit
		attacker.p.isNewBestScore = true
	}

	//was critical?
	bool isValidHeadShot = IsValidHeadShot( damageInfo, dummy )
	if(isValidHeadShot) 
	{
		attacker.p.straferCriticalShots++
		Remote_CallFunction_NonReplay(attacker, "ServerCallback_LiveStatsUIHeadshot", attacker.p.straferCriticalShots)
	}
	
	if(dummy.GetTargetName() == "arcstarChallengeDummy" ) OnDummyKilled(dummy, damageInfo)
}

void function OnFloatingDummyDamaged( entity dummy, var damageInfo )
{
	//fake helmet
	float headshotMultiplier = GetHeadshotDamageMultiplierFromDamageInfo(damageInfo)
	float basedamage = DamageInfo_GetDamage(damageInfo)/headshotMultiplier
	if(IsValidHeadShot( damageInfo, dummy )) DamageInfo_SetDamage( damageInfo, basedamage*(settings.helmet_lv4+(1-settings.helmet_lv4)*headshotMultiplier))
	
	entity player = DamageInfo_GetAttacker(damageInfo)
	float damage = DamageInfo_GetDamage( damageInfo )
	
	if (!IsValid(player)) return
	//add the damage
	player.p.straferChallengeDamage += int(damage)
	Remote_CallFunction_NonReplay(player, "ServerCallback_LiveStatsUIDamageViaDummieDamaged", int(damage))
	Remote_CallFunction_NonReplay(player, "ServerCallback_LiveStatsUIAccuracyViaShotsHits")
	//was critical?
	bool isValidHeadShot = IsValidHeadShot( damageInfo, dummy )
	if(isValidHeadShot) 
	{
		player.p.straferCriticalShots++
		Remote_CallFunction_NonReplay(player, "ServerCallback_LiveStatsUIHeadshot", player.p.straferCriticalShots)
	}
	
	if (!dummy.IsOnGround()) player.p.straferShotsHit++
	// else player.p.straferShotsHit = 1 //revisit this
	
	if(player.p.straferShotsHit > player.p.straferShotsHitRecord) 
	{
		player.p.straferShotsHitRecord = player.p.straferShotsHit
		player.p.isNewBestScore = true
	}
	//Infinite ammo
	if(AimTrainer_INFINITE_AMMO) player.RefillAllAmmo()
	
	//Inmortal target
	//if(AimTrainer_INMORTAL_TARGETS) //they should be always inmortal
		dummy.SetHealth(dummy.GetMaxHealth())

	// Move target in a random direction
	int side = 1
	if(CoinFlip()) side = -1
	
	vector org1 = player.GetOrigin()
	vector org2 = dummy.GetOrigin()
	vector vec2 = org1 - org2
	vector angles2 = VectorToAngles( vec2 )

	int random2 = RandomIntRangeInclusive(1,5)
	if(random2 == 1 || random2 == 2 || random2 == 3)
		dummy.SetVelocity((AnglesToRight(angles2 ) * RandomFloatRange(128,425) * side ) + <0, 0, RandomFloatRange(250,425) + DamageInfo_GetDamage(damageInfo) * 3>)
	else
		dummy.SetVelocity((AnglesToForward(angles2) * RandomFloatRange(128,256)) + <0, 0, RandomFloatRange(250,425) + DamageInfo_GetDamage(damageInfo) * 3>)

	// dummy.SetAngles(angles2)
}

//Callbacks functions
void function OnTilePropDamaged( entity dummy, var damageInfo )
{
	entity ent = dummy

	entity attacker = DamageInfo_GetAttacker(damageInfo)
	float damage = DamageInfo_GetDamage( damageInfo )

	EmitSoundOnEntityOnlyToPlayer( attacker, attacker, FIRINGRANGE_FLICK_TARGET_SOUND )

	if(!attacker.IsPlayer() ) return
		
	//add the damage
	attacker.p.straferChallengeDamage += int(damage)
	Remote_CallFunction_NonReplay(attacker, "ServerCallback_LiveStatsUIDamageViaDummieDamaged", int(damage))
	Remote_CallFunction_NonReplay(attacker, "ServerCallback_LiveStatsUIAccuracyViaShotsHits")
	
	//infinite ammo
	if(AimTrainer_INFINITE_AMMO) attacker.RefillAllAmmo()

	//add 1 hit
	attacker.p.straferShotsHit++
	if(attacker.p.straferShotsHit > attacker.p.straferShotsHitRecord) 
	{
		attacker.p.straferShotsHitRecord = attacker.p.straferShotsHit
		attacker.p.isNewBestScore = true
	}
	
	attacker.p.straferDummyKilledCount++
	Remote_CallFunction_NonReplay(attacker, "ServerCallback_LiveStatsUIDummiesKilled", attacker.p.straferDummyKilledCount)
	ChallengesEntities.dummies.removebyvalue(ent)

	ent.Destroy()
	ChallengesEntities.props.removebyvalue(ent)
}

void function OnDummyKilled(entity ent, var damageInfo)
{
	entity attacker = DamageInfo_GetAttacker(damageInfo)
	if(!attacker.IsPlayer() ) return
	if(AimTrainer_INFINITE_AMMO2) attacker.RefillAllAmmo()
	if ( IsValidHeadShot( damageInfo, ent )) return
	if(ent.GetTargetName() == "BubbleFightDummy") 
	{
		entity player = attacker
		if(player.GetHealth() < player.GetMaxHealth() && IsValid(player))
			player.SetHealth(min(player.GetHealth() + 10, player.GetMaxHealth()))
		else if(player.GetShieldHealth() < player.GetShieldHealthMax() && player.GetHealth() == player.GetMaxHealth() && IsValid(player))
			player.SetShieldHealth(min(player.GetShieldHealthMax(),player.GetShieldHealth()+10))
		
	}
	attacker.p.straferDummyKilledCount++
	Remote_CallFunction_NonReplay(attacker, "ServerCallback_LiveStatsUIDummiesKilled", attacker.p.straferDummyKilledCount)
	ChallengesEntities.dummies.removebyvalue(ent)
}

void function OnWeaponAttackChallenges( entity player, entity weapon, string weaponName, int ammoUsed, vector attackOrigin, vector attackDir )
{
	if(weapon.GetWeaponClassName() == "mp_weapon_lightninggun") return
	if(!player.p.isChallengeActivated) return
	int basedamage = weapon.GetWeaponSettingInt( eWeaponVar.damage_near_value )
	int ornull projectilespershot = weapon.GetWeaponSettingInt( eWeaponVar.projectiles_per_shot )
	int pellets = 1
	if(projectilespershot != null)
	{
		pellets = expect int(projectilespershot)
		player.p.totalPossibleDamage += (basedamage * pellets)
	}
	else 
		player.p.totalPossibleDamage += basedamage
	
	//add 1 hit to total hits
	player.p.straferTotalShots += (1*pellets)
	
	Remote_CallFunction_NonReplay(player, "ServerCallback_LiveStatsUIDamageViaWeaponAttack", basedamage, basedamage * pellets)
	Remote_CallFunction_NonReplay(player, "ServerCallback_LiveStatsUIAccuracyViaTotalShots", pellets)
}

void function Arcstar_OnStick( entity ent, var damageInfo )
{
	thread Arcstar_OnStick2(ent, damageInfo)
}
void function Arcstar_OnStick2( entity ent, var damageInfo )
{
	entity player = DamageInfo_GetAttacker( damageInfo )

	if( !IsValid( player ) || ent == player )
		return
	
	printt("Stick! +1 point.")
	EmitSoundOnEntity(player, "UI_PostGame_TitanPointIncrease")
	ChallengesEntities.dummies.removebyvalue(ent)
	WaitFrame()
	if(IsValid(ent)) ent.Destroy()
}
//UTILITY
void function OnPlayerDeathCallback(entity player, var damageInfo)
{
	thread OnPlayerDeathCallbackThread(player)
}

void function OnPlayerDeathCallbackThread( entity player )
{
	if( !player.p.isChallengeActivated )
		return
		
	EndSignal( player, "OnDestroy" )

	wait 1
	
	Signal(player, "ChallengeTimeOver")
	thread SetupPlayer( player )
}

int function ReturnShieldAmountForDesiredLevel()
{
	switch(AimTrainer_AI_SHIELDS_LEVEL){
		case 0:
			return 0
		case 1:
			return 50
		case 2:
			return 75
		case 3:
			return 100
		case 4:
			return 125
	}
	unreachable
}

array<entity> function CreateFloorAtOrigin(vector origin, int width, int length)
{
	int x = int(origin.x)
	int y = int(origin.y)
	int z = int(origin.z)
	int i
	int j
	int propWidth = 700
	int propLength = 700
	
	array<entity> arr
	for(i = y; i <= y + (length * propLength); i += propLength)
	{
		for(j = x; j <= x + (width * propWidth); j += propWidth)
		{
			arr.append( CreatePropDynamic( $"mdl/flowstate_custom/cafe_floor.rmdl", <j, i, z>, <180,0,0>, SOLID_VPHYSICS, -1) ) //$"mdl/thunderdome/thunderdome_cage_ceiling_256x256_06.rmdl"
		}
    }
	return arr
}

array<entity> function CreateWallAtOrigin(vector origin, int length, int height, int angle)
{
	int x = int(origin.x)
	int y = int(origin.y)
	int z = int(origin.z)
    int i;
    int j;
	array<entity> arr
    // angle MUST be 0 or 90
    // assert(angle == 90 | angle == 0)

    int start = (angle == 90) ? y : x
    int end = start + (length * 256)
    for(i = start; i <= end; i += 256)
    {
        for(j = z; j <= z + (height * 256); j += 256)
        {
            if(angle == 90) arr.append(CreateFRProp( $"mdl/thunderdome/thunderdome_cage_wall_256x256_01.rmdl", <x, i, j>, <0,90,0>))
            else if (angle == 0) arr.append(CreateFRProp( $"mdl/thunderdome/thunderdome_cage_wall_256x256_01.rmdl", <i, y, j>, <0,0,0>))
        }
	}
	return arr
}

// Create middle platform for better player positioning
array<entity> function CreateMiddlePlatform(vector centerPos, float width, float depth, float sizeRatio, float heightRatio)
{
	array<entity> platformProps = []
	
	// Calculate platform dimensions
	float platformWidth = width * sizeRatio
	float platformDepth = depth * sizeRatio
	
	// Calculate platform position (at specified height ratio)
	float platformHeight = heightRatio * 700.0 // Use one tile thickness for platform
	vector platformCenter = centerPos + Vector(0, 0, platformHeight - (700.0/2)) // Position platform at height
	
	// Calculate number of tiles needed for platform dimensions (700 units per tile)
	int tilesWidth = int(ceil(platformWidth / 700.0))
	int tilesDepth = int(ceil(platformDepth / 700.0))
	
	// Ensure minimum platform size (at least 2x2 tiles)
	tilesWidth = int(max(tilesWidth, 2))
	tilesDepth = int(max(tilesDepth, 2))
	
	// Create platform tiles (horizontal surface like floor)
	float halfWidth = (tilesWidth * 700.0) / 2
	float halfDepth = (tilesDepth * 700.0) / 2
	
	// Platform surface (facing up like floor)
	for(int x = 0; x < tilesWidth; x++)
	{
		for(int y = 0; y < tilesDepth; y++)
		{
			vector pos = platformCenter + Vector(-halfWidth + (x * 700) + 350, -halfDepth + (y * 700) + 350, 0)
			platformProps.append(CreatePropDynamic($"mdl/flowstate_custom/cafe_floor.rmdl", pos, <180,0,0>, SOLID_VPHYSICS, -1))
		}
	}
	
	return platformProps
}

array<entity> function CreateTrackingBox(vector centerPos, float width, float height, float depth, bool includeMiddlePlatform = false)
{
	array<entity> boxProps = []
	
	// Calculate number of tiles needed for each dimension (700 units per tile)
	int tilesWidth = int(ceil(width / 700.0))
	int tilesHeight = int(ceil(height / 700.0))
	int tilesDepth = int(ceil(depth / 700.0))
	
	// Calculate actual dimensions based on tile count
	float actualWidth = tilesWidth * 700.0
	float actualHeight = tilesHeight * 700.0
	float actualDepth = tilesDepth * 700.0
	
	// Calculate half dimensions for positioning
	float halfWidth = actualWidth / 2
	float halfHeight = actualHeight / 2
	float halfDepth = actualDepth / 2
	
	// Floor (bottom face) - Using existing working floor angle from CreateFloorAtOrigin
	vector floorCenter = centerPos + Vector(0, 0, -halfHeight)
	for(int x = 0; x < tilesWidth; x++)
	{
		for(int y = 0; y < tilesDepth; y++)
		{
			vector pos = floorCenter + Vector(-halfWidth + (x * 700) + 350, -halfDepth + (y * 700) + 350, 0)
			boxProps.append(CreatePropDynamic($"mdl/flowstate_custom/cafe_floor.rmdl", pos, <180,0,0>, SOLID_VPHYSICS, -1))
		}
	}
	
	// Ceiling (top face) - Opposite of floor
	vector ceilingCenter = centerPos + Vector(0, 0, halfHeight)
	for(int x = 0; x < tilesWidth; x++)
	{
		for(int y = 0; y < tilesDepth; y++)
		{
			vector pos = ceilingCenter + Vector(-halfWidth + (x * 700) + 350, -halfDepth + (y * 700) + 350, 0)
			boxProps.append(CreatePropDynamic($"mdl/flowstate_custom/cafe_floor.rmdl", pos, <0,0,0>, SOLID_VPHYSICS, -1))
		}
	}
	
	vector frontCenter = centerPos + Vector(0, -halfDepth, 0)
	for(int x = 0; x < tilesWidth; x++)
	{
		for(int z = 0; z < tilesHeight; z++)
		{
			vector pos = frontCenter + Vector(-halfWidth + (x * 700) + 350, 0, -halfHeight + (z * 700) + 350)
			boxProps.append(CreatePropDynamic($"mdl/flowstate_custom/cafe_floor.rmdl", pos, <90,90,0>, SOLID_VPHYSICS, -1))
		}
	}
	
	vector backCenter = centerPos + Vector(0, halfDepth, 0)
	for(int x = 0; x < tilesWidth; x++)
	{
		for(int z = 0; z < tilesHeight; z++)
		{
			vector pos = backCenter + Vector(-halfWidth + (x * 700) + 350, 0, -halfHeight + (z * 700) + 350)
			boxProps.append(CreatePropDynamic($"mdl/flowstate_custom/cafe_floor.rmdl", pos, <90,-90,0>, SOLID_VPHYSICS, -1))
		}
	}
	
	vector leftCenter = centerPos + Vector(-halfWidth, 0, 0)
	for(int y = 0; y < tilesDepth; y++)
	{
		for(int z = 0; z < tilesHeight; z++)
		{
			vector pos = leftCenter + Vector(0, -halfDepth + (y * 700) + 350, -halfHeight + (z * 700) + 350)
			boxProps.append(CreatePropDynamic($"mdl/flowstate_custom/cafe_floor.rmdl", pos, <90,180,0>, SOLID_VPHYSICS, -1))
		}
	}
	
	vector rightCenter = centerPos + Vector(halfWidth, 0, 0)
	for(int y = 0; y < tilesDepth; y++)
	{
		for(int z = 0; z < tilesHeight; z++)
		{
			vector pos = rightCenter + Vector(0, -halfDepth + (y * 700) + 350, -halfHeight + (z * 700) + 350)
			boxProps.append(CreatePropDynamic($"mdl/flowstate_custom/cafe_floor.rmdl", pos, <90,-180,0>, SOLID_VPHYSICS, -1))
		}
	}

	return boxProps
}

void function ClippingAIWorkaround(entity dummy)
{
	dummy.EndSignal("OnDeath")
	
	while( IsValid(dummy) )
	{
		vector traceStart = dummy.EyePosition()
		vector traceDir   = dummy.GetForwardVector()
		vector traceEnd   = traceStart + (traceDir * 50000)
		TraceResults results = TraceLine( traceStart, traceEnd, dummy )
		
		if( Distance(dummy.GetOrigin(), results.endPos) <= 150 )
			dummy.SetAngles( Vector( 0, AnglesCompose( dummy.GetAngles(), <0, 180, 0> ).y, 0 ) ) //Vector(dummy.GetAngles().x, dummy.GetAngles().y*-1, dummy.GetAngles().z) )

		if( !FS_PosCanContainDummy( dummy.GetOrigin()) )
		{
			PutEntityInSafeSpot( dummy, null, null, dummy.GetOrigin() + AnglesToForward ( dummy.GetAngles() ) * 30, dummy.GetOrigin() )
		}
		
		vector velocity = dummy.GetVelocity()
		printt( "running dummy vel: ", velocity.Length() )
		WaitFrame()
	}	
}

//CLIENT COMMANDS
void function PreChallengeStart(entity player, int challenge)
{
	thread function() : (player, challenge)
	{
		if( IsAlive( player ) )
			player.Die( null, null, { damageSourceId = eDamageSourceId.damagedef_despawn } )
		
		waitthread SetupPlayer( player )
		player.FreezeControlsOnServer()

		player.p.storedWeapons = StoreWeapons(player)
		AddCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD_INSTANT )
		AddCinematicFlag( player, CE_FLAG_HIDE_PERMANENT_HUD)
		player.p.challengeName = challenge
		file.challengeStartTime = Time() //Track challenge start time for duration validation

		player.p.isChallengeActivated = true
		Remote_CallFunction_NonReplay(player, "ServerCallback_SetChallengeActivated", true)
	
	}()
}

//Initialize Challenge Registry - maps challenge identifiers to their functions and IDs
void function InitializeChallengeRegistry()
{
	//Original Challenge Series (1-8)
	ChallengeInfo challenge1; challenge1.challengeFunc = StartStraferDummyChallenge; challenge1.challengeId = 1
	challengeRegistry["1"] <- challenge1
	ChallengeInfo challenge2; challenge2.challengeFunc = StartSwapFocusDummyChallenge; challenge2.challengeId = 2
	challengeRegistry["2"] <- challenge2
	ChallengeInfo challenge3; challenge3.challengeFunc = StartFloatingTargetChallenge; challenge3.challengeId = 3
	challengeRegistry["3"] <- challenge3
	ChallengeInfo challenge4; challenge4.challengeFuncWithParam = StartPopcornChallenge_Normal; challenge4.challengeId = 4; challenge4.requiresParameter = true
	challengeRegistry["4"] <- challenge4
	ChallengeInfo challenge5; challenge5.challengeFunc = StartTileFrenzyChallenge; challenge5.challengeId = 10
	challengeRegistry["5"] <- challenge5
	ChallengeInfo challenge6; challenge6.challengeFunc = StartCloseFastStrafesChallenge; challenge6.challengeId = 11
	challengeRegistry["6"] <- challenge6
	ChallengeInfo challenge7; challenge7.challengeFunc = StartSmoothbotChallenge; challenge7.challengeId = 12
	challengeRegistry["7"] <- challenge7
	ChallengeInfo challenge8; challenge8.challengeFuncWithParam = StartPopcornChallenge_Normal; challenge8.challengeId = 13; challenge8.requiresParameter = true
	challengeRegistry["8"] <- challenge8
	
	//New Challenge Series (1NewC-8NewC)
	ChallengeInfo challenge1newc; challenge1newc.challengeFunc = StartTapyDuckStrafesChallenge; challenge1newc.challengeId = 6
	challengeRegistry["1newc"] <- challenge1newc
	ChallengeInfo challenge2newc; challenge2newc.challengeFunc = StartArcstarsChallenge; challenge2newc.challengeId = 7
	challengeRegistry["2newc"] <- challenge2newc
	ChallengeInfo challenge3newc; challenge3newc.challengeFunc = StartVerticalGrenadesChallenge; challenge3newc.challengeId = 14
	challengeRegistry["3newc"] <- challenge3newc
	ChallengeInfo challenge4newc; challenge4newc.challengeFunc = StartStraightUpChallenge; challenge4newc.challengeId = 9
	challengeRegistry["4newc"] <- challenge4newc
	ChallengeInfo challenge5newc; challenge5newc.challengeFunc = StartLiftUpChallenge; challenge5newc.challengeId = 8
	challengeRegistry["5newc"] <- challenge5newc
	ChallengeInfo challenge6newc; challenge6newc.challengeFunc = StartSkyDiveChallenge; challenge6newc.challengeId = 15
	challengeRegistry["6newc"] <- challenge6newc
	ChallengeInfo challenge7newc; challenge7newc.challengeFunc = StartRunningTargetsChallenge; challenge7newc.challengeId = 16
	challengeRegistry["7newc"] <- challenge7newc
	ChallengeInfo challenge8newc; challenge8newc.challengeFunc = StartArmorSwapChallenge; challenge8newc.challengeId = 17
	challengeRegistry["8newc"] <- challenge8newc
	
	//Tracking Challenges
	ChallengeInfo patternTracking; patternTracking.challengeFunc = StartPatternTrackingChallenge; patternTracking.challengeId = 18
	challengeRegistry["pattern_tracking"] <- patternTracking
	ChallengeInfo bouncingTracking; bouncingTracking.challengeFunc = StartBouncingTrackingChallenge; bouncingTracking.challengeId = 19
	challengeRegistry["bouncing_tracking"] <- bouncingTracking
	ChallengeInfo multiBallHealth; multiBallHealth.challengeFunc = StartMultiBallHealthTrackingChallenge; multiBallHealth.challengeId = 22
	challengeRegistry["multiball_health"] <- multiBallHealth
	ChallengeInfo randomSpeed; randomSpeed.challengeFunc = StartRandomSpeedTrackingChallenge; randomSpeed.challengeId = 23
	challengeRegistry["random_speed"] <- randomSpeed
	ChallengeInfo antiMirror; antiMirror.challengeFuncWithParam = StartAntiMirrorStrafingChallenge_Wrapper; antiMirror.challengeId = 24; antiMirror.requiresParameter = true
	challengeRegistry["anti_mirror"] <- antiMirror
	ChallengeInfo mirror; mirror.challengeFuncWithParam = StartAntiMirrorStrafingChallenge_Wrapper; mirror.challengeId = 25; mirror.requiresParameter = true
	challengeRegistry["mirror"] <- mirror
	ChallengeInfo popcornPhysics; popcornPhysics.challengeFunc = StartPopcornPhysicsChallenge; popcornPhysics.challengeId = 25
	challengeRegistry["popcorn_physics"] <- popcornPhysics
	
	//Kovaaks Scenarios
	ChallengeInfo oneWall6Targets; oneWall6Targets.challengeFunc = Start1Wall6TargetsChallenge; oneWall6Targets.challengeId = 20
	challengeRegistry["1wall6targets"] <- oneWall6Targets
	ChallengeInfo closeLongStrafes; closeLongStrafes.challengeFunc = StartCloseLongStrafesChallenge; closeLongStrafes.challengeId = 21
	challengeRegistry["close_long_strafes"] <- closeLongStrafes
	ChallengeInfo tileFrenzy; tileFrenzy.challengeFunc = StartTileFrenzyStrafingChallenge; tileFrenzy.challengeId = 22
	challengeRegistry["tile_frenzy"] <- tileFrenzy
}

//Unified Challenge Starter - replaces all individual CC_Start* commands
bool function CC_StartChallenge_Unified(entity player, array<string> args)
{
	if(args.len() < 1)
	{
#if DEVELOPER
		printt("[AimTrainer] CC_StartChallenge_Unified: No challenge identifier provided")
#endif
		return false
	}
	
	string challengeId = args[0].tolower()
	
	if(!(challengeId in challengeRegistry))
	{
#if DEVELOPER
		printt("[AimTrainer] CC_StartChallenge_Unified: Unknown challenge identifier '" + challengeId + "'")
#endif
		return false
	}
	
	ChallengeInfo challengeInfo = challengeRegistry[challengeId]
	
	//Start the challenge using PreChallengeStart and the appropriate function
	PreChallengeStart(player, challengeInfo.challengeId)
	
	if(challengeInfo.requiresParameter && challengeInfo.challengeFuncWithParam != null)
	{
		//Special challenges that need a boolean parameter
		bool param = false
		if(challengeId == "4")
			param = false //StartPopcornChallenge(player, false) - normal variant
		else if(challengeId == "8")
			param = true //StartPopcornChallenge(player, true) - second variant
		else if(challengeId == "anti_mirror")
			param = false //StartAntiMirrorStrafingChallenge(player, false) - anti-mirror mode
		else if(challengeId == "mirror")
			param = true //StartAntiMirrorStrafingChallenge(player, true) - mirror mode
		thread challengeInfo.challengeFuncWithParam(player, param)
	}
	else if(challengeInfo.challengeFunc != null)
	{
		thread challengeInfo.challengeFunc(player)
	}
	
	return false
}

bool function CC_ChallengesSkipButton( entity player, array<string> args )
{
	Signal(player, "ForceResultsEnd_SkipButton")
	return false
}

bool function CC_ChangeChallengeDuration( entity player, array<string> args )
{
	if(args.len() == 0 ) return false

	int desiredTime = int(args[0])
	AimTrainer_CHALLENGE_DURATION = desiredTime
	return false
}

bool function CC_AimTrainer_AI_SHIELDS_LEVEL( entity player, array<string> args )
{
	int desiredShieldLevel = int(args[0])
	AimTrainer_AI_SHIELDS_LEVEL = desiredShieldLevel
	return false
}

bool function CC_AimTrainer_STRAFING_SPEED( entity player, array<string> args )
{
	float desiredSpeed = float(args[0])
	AimTrainer_STRAFING_SPEED = desiredSpeed
	return false
}

bool function CC_AimTrainer_SPAWN_DISTANCE( entity player, array<string> args )
{
	float desiredDistance = float(args[0])
	AimTrainer_SPAWN_DISTANCE = desiredDistance
	return false
}

bool function CC_AimTrainer_AI_HEALTH( entity player, array<string> args )
{
	int desiredHealth = int(args[0])
	AimTrainer_AI_HEALTH = desiredHealth
	return false
}

bool function CC_RGB_HUD( entity player, array<string> args )
{
	// if(args[0] == "0")
		// RGB_HUD = false
	// else if(args[0] == "1")
		// RGB_HUD = true
	
	return false
}

bool function CC_AimTrainer_INFINITE_CHALLENGE( entity player, array<string> args )
{
	if(args[0] == "0")
		AimTrainer_INFINITE_CHALLENGE = false
	else if(args[0] == "1")
		AimTrainer_INFINITE_CHALLENGE = true

	return false
}

bool function CC_AimTrainer_INFINITE_AMMO( entity player, array<string> args )
{
	if(args[0] == "0")
		AimTrainer_INFINITE_AMMO = false
	else if(args[0] == "1")
		AimTrainer_INFINITE_AMMO = true

	return false
}

bool function CC_AimTrainer_INFINITE_AMMO2( entity player, array<string> args )
{
	if(args[0] == "0")
		AimTrainer_INFINITE_AMMO2 = false
	else if(args[0] == "1")
		AimTrainer_INFINITE_AMMO2 = true

	return false
}

bool function CC_AimTrainer_INMORTAL_TARGETS( entity player, array<string> args )
{
	if(args[0] == "0")
		AimTrainer_INMORTAL_TARGETS = false
	else if(args[0] == "1")
		AimTrainer_INMORTAL_TARGETS = true

	return false
}

bool function CC_AimTrainer_USER_WANNA_BE_A_DUMMY( entity player, array<string> args )
{
	if(args[0] == "2")
	{
		AimTrainer_USER_WANNA_BE_A_DUMMY = false
		player.SetBodyModelOverride( $"" )
		player.SetArmsModelOverride( $"" )
	}
	else if(args[0] == "3")
	{
		AimTrainer_USER_WANNA_BE_A_DUMMY = true
		player.SetBodyModelOverride( $"mdl/humans/class/medium/pilot_medium_generic.rmdl" )
		player.SetArmsModelOverride( $"mdl/humans/class/medium/pilot_medium_generic.rmdl" )
		player.SetSkin(RandomIntRange(1,5))
	}
	return false
}

bool function CC_AimTrainer_DUMMIES_COLOR( entity player, array<string> args )
{
	int desiredColor = int(args[0])
	AimTrainer_AI_COLOR = desiredColor
	return false
}

bool function CC_AimTrainer_TRACKING_SPEED( entity player, array<string> args )
{
	float desiredSpeed = float(args[0])
	AimTrainer_TRACKING_SPEED = desiredSpeed
	return false
}

bool function CC_AimTrainer_TRACKING_TILES_HORIZONTAL( entity player, array<string> args )
{
	int desiredTiles = int(args[0])
	AimTrainer_TRACKING_TILES_HORIZONTAL = desiredTiles
	return false
}

bool function CC_AimTrainer_TRACKING_TILES_VERTICAL( entity player, array<string> args )
{
	int desiredTiles = int(args[0])
	AimTrainer_TRACKING_TILES_VERTICAL = desiredTiles
	return false
}

bool function CC_AimTrainer_TRACKING_TARGET_SCALE( entity player, array<string> args )
{
	float desiredScale = float(args[0])
	AimTrainer_TRACKING_TARGET_SCALE = desiredScale
	return false
}

bool function CC_AimTrainer_TRACKING_TILES_DEPTH( entity player, array<string> args )
{
	int desiredTiles = int(args[0])
	AimTrainer_TRACKING_TILES_DEPTH = desiredTiles
	return false
}


bool function CC_AimTrainer_TRACKING_RANDOM_START( entity player, array<string> args )
{
	bool desiredRandom = bool(int(args[0]))
	AimTrainer_TRACKING_RANDOM_START = desiredRandom
	return false
}

bool function CC_AimTrainer_SelectWeaponSlot(entity player, array<string> args )
{
	if(!IsValid(player) || args.len() > 1) return false
	
	string slot = args[0]
	int actualslot = WEAPON_INVENTORY_SLOT_PRIMARY_0
	
	if(slot == "p")
		actualslot = WEAPON_INVENTORY_SLOT_PRIMARY_0
	else if(slot == "s")
		actualslot = WEAPON_INVENTORY_SLOT_PRIMARY_1
	
	player.FreezeControlsOnServer()
	player.SetActiveWeaponBySlot( eActiveInventorySlot.mainHand, actualslot )
	return true
}

bool function CC_AimTrainer_CloseWeaponSelector(entity player, array<string> args )
{
	if(!IsValid(player)) return false

	player.UnfreezeControlsOnServer()
	return true
}

bool function CC_MenuGiveAimTrainerWeapon( entity player, array<string> args )
{
	if(!IsValid(player) || args.len() < 2) return false
	
	string weapon = args[0]
	
	bool bIs1v1 = g_bIs1v1GameType() //idc, conditional.	
	if( Gamemode() != eGamemodes.fs_aimtrainer && !ValidateWeaponTgiveSettings( player, args[0] ) || Gamemode() == eGamemodes.WINTEREXPRESS && !player.GetPlayerNetBool( "WinterExpress_IsPlayerAllowedLegendChange" ) )
		return true
	
	if( Gamemode() != eGamemodes.fs_aimtrainer && GetWhiteListedWeapons().len() && GetWhiteListedWeapons().find(weapon) != -1)
	{
		Message(player, "WEAPON NOT WHITELISTED")
		return false
	}

	if( Gamemode() != eGamemodes.fs_aimtrainer && GetWhiteListedAbilities().len() && GetWhiteListedAbilities().find(weapon) != -1 )
	{
		Message(player, "ABILITY NOT WHITELISTED")
		return false
	}

    string slot = args[1]
	int actualslot = WEAPON_INVENTORY_SLOT_PRIMARY_0
	
	if(slot == "p")
		actualslot = WEAPON_INVENTORY_SLOT_PRIMARY_0
	else if(slot == "s")
		actualslot = WEAPON_INVENTORY_SLOT_PRIMARY_1
	
	entity actualweapon = player.GetNormalWeapon( actualslot )
	if ( IsValid(actualweapon) )
		player.TakeWeaponByEntNow( actualweapon )

	entity weaponent
	array<string> finalargs
	if (args.len() > 2 && weapon != "mp_weapon_lightninggun" ) //from attachments buy box
	{
		string optic = "none"
		string barrel = "none"
		string stock = "none"
		string shotgunbolt = "none"
		string mag = "none"

		// printt("DEBUG BEFORE CONVERT: " + args[2], args[3], args[4], args[5], args[6], args[7])

		switch( args[2] ){
			case "0":
				optic = "none"
				break
			case "1":
				optic = "optic_cq_hcog_classic"
				break
			case "2":
				optic = "optic_cq_holosight"
				break
			case "3":
				optic = "optic_cq_threat"
				break
			case "4":
				optic = "optic_cq_holosight_variable"
				break
			case "5":	
				optic = "optic_cq_hcog_bruiser"
				break
		}

		if( args[6] == "smg" || weapon == "mp_weapon_autopistol" )
		{
			switch( args[3] ){
				case "0":
					barrel = "none"
					break
				case "1":
					barrel = "laser_sight_l1"
					break
				case "2":
					barrel = "laser_sight_l2"
					break
				case "3":
					barrel = "laser_sight_l3"
					break
			}
		}
		else
		{
			switch( args[3] ){
				case "0":
					barrel = "none"
					break
				case "1":
					barrel = "barrel_stabilizer_l1"
					break
				case "2":
					barrel = "barrel_stabilizer_l2"
					break
				case "3":
					barrel = "barrel_stabilizer_l3"
					break
			}
		}

		switch(args[4]){
				case "0":
					stock = "none"
					break
				case "1":
					stock = "stock_tactical_l1"
					break
				case "2":
					stock = "stock_tactical_l2"
					break
				case "3":
					stock = "stock_tactical_l3"
					break
			}
		
		if( args[6] == "sniper" || args[6] == "sniper2" || args[6] == "marksman" || args[6] == "marksman2")
			switch(args[4]){
				case "0":
					stock = "none"
					break
				case "1":
					stock = "stock_sniper_l1"
					break
				case "2":
					stock = "stock_sniper_l2"
					break
				case "3":
					stock = "stock_sniper_l3"
					break
			}		
		
		switch(args[5]){
				case "0":
					shotgunbolt = "none"
					break
				case "1":
					shotgunbolt = "shotgun_bolt_l1"
					break
				case "2":
					shotgunbolt = "shotgun_bolt_l2"
					break
				case "3":
					shotgunbolt = "shotgun_bolt_l3"
					break
			}
			
		if(weapon == "mp_weapon_energy_ar" || weapon == "mp_weapon_esaw")
		{
			switch(args[5]){
				case "0":
					shotgunbolt = "."
					break
				case "1":
					shotgunbolt = "hopup_turbocharger"
					break
			}
		}else if(weapon == "mp_weapon_g2")
		{
			switch(args[5]){
				case "0":
					shotgunbolt = "."
					break
				case "1":
					shotgunbolt = "hopup_double_tap"
					break
			}	
		}else if(weapon == "mp_weapon_doubletake")
		{
			switch(args[5]){
				case "0":
					shotgunbolt = "."
					break
				case "1":
					shotgunbolt = "hopup_energy_choke"
					break
			}			
		}
		
		if(args[6] == "ar" || args[6] == "ar2" || args[6] == "lmg" || args[6] == "lmg2" || args[6] == "sniper" || args[6] == "sniper2" || args[6] == "marksman" || args[6] == "marksman2")
		switch(args[2]){
			case "0":
				optic = "none"
				break
			case "1":
				optic = "optic_cq_hcog_classic"
				break
			case "2":
				optic = "optic_cq_holosight"
				break
			case "3":
				optic = "optic_cq_holosight_variable"
				break
			case "4":
				optic = "optic_cq_hcog_bruiser"
				break
			case "5":	
				optic = "optic_ranged_hcog"
				break
			case "6":	
				optic = "optic_ranged_aog_variable"
				break
			case "7":	
				optic = "optic_sniper"
				break
			case "8":	
				optic = "optic_sniper_variable"
				break
			case "9":	
				optic = "optic_sniper_threat"
				break
		}

		switch(args[7]){
				case "0":
					mag = "none"
					break
				case "1":
					if(args[8] == "bullet")
						mag = "bullets_mag_l1"
					else if(args[8] == "highcal")
						mag = "highcal_mag_l1"
					else if(args[8] == "special")
						mag = "energy_mag_l1"
					else if(args[8] == "sniper")
						mag = "sniper_mag_l1"
					break
				case "2":
					if(args[8] == "bullet")
						mag = "bullets_mag_l2"
					else if(args[8] == "highcal")
						mag = "highcal_mag_l2"
					else if(args[8] == "special")
						mag = "energy_mag_l2"
					else if(args[8] == "sniper")
						mag = "sniper_mag_l2"
					break
				case "3":
					if(args[8] == "bullet")
						mag = "bullets_mag_l3"
					else if(args[8] == "highcal")
						mag = "highcal_mag_l3"
					else if(args[8] == "special")
						mag = "energy_mag_l3"
					else if(args[8] == "sniper")
						mag = "sniper_mag_l3"
					break
			}

		// printt( "DEBUG AFTER CONVERT: " + optic, barrel, stock, shotgunbolt, args[6], mag )

		switch(args[6])
		{
			case "smg":
				if(optic != "none") finalargs.append(optic)
				if(barrel != "none") finalargs.append(barrel)
				if(stock != "none") finalargs.append(stock)
				if(mag != "none") finalargs.append(mag)	
				
				break
			case "pistol":
				if(optic != "none") finalargs.append(optic)
				if(barrel != "none") finalargs.append(barrel)
				if(mag != "none") finalargs.append(mag)
				break
			case "pistol2":
				if(optic != "none") finalargs.append(optic)
				if(mag != "none") finalargs.append(mag)
				break
			case "shotgun":
				if(optic != "none") finalargs.append(optic)
				if(shotgunbolt != "none") finalargs.append(shotgunbolt)
				break
			case "lmg2":
			case "ar":
				if(optic != "none") finalargs.append(optic)
				if(barrel != "none") finalargs.append(barrel)
				if(stock != "none") finalargs.append(stock)
				if(shotgunbolt != "." && weapon == "mp_weapon_esaw") finalargs.append(shotgunbolt)
				if(mag != "none") finalargs.append(mag)
				break
			case "ar2":
				if(optic != "none") finalargs.append(optic)
				if(stock != "none") finalargs.append(stock)
				if(shotgunbolt != "." && weapon == "mp_weapon_energy_ar") finalargs.append(shotgunbolt)
				if(mag != "none") finalargs.append(mag)				
				break
			case "marksman":
				if(optic != "none") finalargs.append(optic)
				if(barrel != "none") finalargs.append(barrel)
				if(stock != "none") finalargs.append(stock)
				if(shotgunbolt != "." ) finalargs.append(shotgunbolt)
				if(mag != "none") finalargs.append(mag)
				break
			case "marksman2":
				if(optic != "none") finalargs.append(optic)
				if(stock != "none") finalargs.append(stock)
				if(shotgunbolt != "." ) finalargs.append(shotgunbolt)
				if(mag != "none") finalargs.append(mag)
				break
			case "marksman3":
				if(optic != "none") finalargs.append(optic)
				if(stock != "none") finalargs.append(stock)
				if(mag != "none") finalargs.append(mag)	
				break
			case "sniper":
				if(optic != "none") finalargs.append(optic)
				if(barrel != "none") finalargs.append(barrel)
				if(stock != "none") finalargs.append(stock)
				if(mag != "none") finalargs.append(mag)
				break
			case "sniper2":
				if(optic != "none") finalargs.append(optic)
				if(stock != "none") finalargs.append(stock)
				break
		}
	}

	bool autonoauto = false
	if( weapon == "mp_weapon_lightninggun" )
	{
		autonoauto = true
	} else if( weapon == "mp_weapon_lightninggun_auto" )
	{
		weapon = "mp_weapon_lightninggun"
		autonoauto = false
	}
		
	weaponent = player.GiveWeapon_NoDeploy( weapon, actualslot, finalargs, false )

	if( weapon == "mp_weapon_lightninggun" && autonoauto )
	{
		weaponent.AddMod( "noauto" )
		finalargs.append( "noauto" )
		printt( "lightning gun - added no auto mod" )
	}

	if(!IsValid(actualweapon)) player.SetActiveWeaponBySlot( eActiveInventorySlot.mainHand, actualslot )

	if(!IsValid(weaponent)) return true

	if( IsAlive( player ) ) // This is for TDM
	{
		string weapon1
		string weapon2
		string optics1
		string optics2
		array<string> mods1 
		array<string> mods2 
		string weaponname1
		string weaponname2

		weapon1 = SURVIVAL_GetWeaponBySlot( player, WEAPON_INVENTORY_SLOT_PRIMARY_0 ) // This function returns weapon class name if there's weapon, otherwise returns empty string
		weapon2 = SURVIVAL_GetWeaponBySlot( player, WEAPON_INVENTORY_SLOT_PRIMARY_1 )
		
		if( weapon1 != "" ) // Primary slot
		{
			mods1 = GetWeaponMods( player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_0 ) )
			foreach (mod in mods1)
				optics1 = mod + " " + optics1
			
			weaponname1 = "tgive p " + weapon1 + " " + optics1 + ( bIs1v1 ? "" : "; " )		
		}
		
		if( weapon2 != "" ) // Secondary Slot
		{
			mods2 = GetWeaponMods( player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_1 ) )
			foreach (mod in mods2)
				optics2 = mod + " " + optics2
		
			weaponname2 = "tgive s " + weapon2 + " " + optics2
		}

		if( bIs1v1 ) 
		{			
			array<string> wep1Array = split( weaponname1, " " )
		
			if( args[1] == "p" )
			{
				ResetRate( player )	//todo track down need		
			
					wep1Array[0] = "wepmenu"; //print_string_array( wep1Array )
				
						ClientCommand_GiveWeapon( player, wep1Array )
							
							return true
			}
			else
			{		
				array<string> wep2Array = split( weaponname2, " " )
				
				if ( wep2Array[1] == "s" )
				{
					ResetRate( player )	//todo track down need	
				
						wep2Array[0] = "wepmenu"; //print_string_array( wep2Array )	
					
							ClientCommand_GiveWeapon( player, wep2Array )	
								
								return true
				}
			}
		}
		else 
		{
			weaponlist[ player.GetPlayerName() ] <- weaponname1 + weaponname2
		}
	}

	int weaponSkin = -1
	int weaponModelIndex = -1

	if( InfiniteAmmoEnabled() )
		SetupInfiniteAmmoForWeapon( player, weaponent )
	else if( GetCurrentPlaylistVarInt( "give_weapon_stack_count_amount", 0 ) != 0 )
	{	
		player.AmmoPool_SetCapacity( SURVIVAL_MAX_AMMO_PICKUPS )

		SetupPlayerReserveAmmo( player, weaponent )

		player.ClearFirstDeployForAllWeapons()
		player.DeployWeapon()

		if( weaponent.UsesClipsForAmmo() )
			weaponent.SetWeaponPrimaryClipCount( weaponent.GetWeaponPrimaryClipCountMax() )	
	}
	
	if(slot == "p")
	{
		player.p.weapon = weapon
		player.p.mods = finalargs
		if( weaponModelIndex > -1 )
		{
			weaponent.SetLegendaryModelIndex( weaponModelIndex )
			player.p.weaponModelIndex = weaponModelIndex
		} else {
			player.p.weaponModelIndex = -1
		}

		if( weaponSkin > -1 )
		{
			weaponent.SetSkin( weaponSkin )
			player.p.weaponSkin = weaponSkin
		} else {
			player.p.weaponSkin = -1
		}
	}
	else if(slot == "s")
	{
		player.p.weapon2 = weapon
		player.p.mods2 = finalargs
		if( weaponModelIndex > -1 )
		{
			weaponent.SetLegendaryModelIndex( weaponModelIndex )
			player.p.weaponModelIndex2 = weaponModelIndex
		} else {
			player.p.weaponModelIndex2 = -1
		}

		if( weaponSkin > -1 )
		{
			weaponent.SetSkin( weaponSkin )
			player.p.weaponSkin2 = weaponSkin
		} else {
			player.p.weaponSkin2 = -1
		}
	}

	if( GetCurrentPlaylistVarBool( "flowstate_giveskins_weapons", false ) )
	{
		ItemFlavor ornull weaponSkinOrNull = null
		array<string> fsCharmsToUse = [ "SAID00701640565", "SAID01451752993", "SAID01334887835", "SAID01993399691", "SAID00095078608", "SAID01439033541", "SAID00510535756", "SAID00985605729" ]
		int chosenCharm = ConvertItemFlavorGUIDStringToGUID( fsCharmsToUse.getrandom() )
		ItemFlavor ornull weaponCharmOrNull = GetCurrentPlaylistVarBool( "flowstate_givecharms_weapons", false ) == false ? null : GetItemFlavorByGUID( chosenCharm )
		ItemFlavor ornull weaponFlavor = GetWeaponItemFlavorByClass( weapon )

		if( weaponFlavor != null )
		{
			array<int> weaponLegendaryIndexMap = FS_ReturnLegendaryModelMapForWeaponFlavor( expect ItemFlavor( weaponFlavor ) )
			if( weaponLegendaryIndexMap.len() > 1 && GetCurrentPlaylistVarBool( "flowstate_giveskins_weapons", false ) )
				weaponSkinOrNull = GetItemFlavorByGUID( weaponLegendaryIndexMap[RandomIntRangeInclusive(1,weaponLegendaryIndexMap.len()-1)] )
		}

		WeaponCosmetics_Apply( weaponent, weaponSkinOrNull, weaponCharmOrNull )
	}
	
	return true
}

void function SetupPlayer( entity player, bool fromSelector = false )
{
	EndSignal( player, "OnDestroy" )
	WaitEndFrame() //has to wait until player dies
	
	DecideRespawnPlayer( player, false )

	Inventory_SetPlayerEquipment(player, "armor_pickup_lv1", "armor")
	player.SetShieldHealthMax(50)
	player.SetShieldHealth(50)

	TakeAllWeapons( player )
	
	FS_GiveRandomMelee( player )
	
	entity weapon = player.GiveWeapon_NoDeploy( player.p.weapon, WEAPON_INVENTORY_SLOT_PRIMARY_0, player.p.mods )

	if( !fromSelector )
	{
		SetupInfiniteAmmoForWeapon( player, weapon )
	} else
	{
		int ammoType = weapon.GetWeaponAmmoPoolType()
		player.AmmoPool_SetCapacity( 65535 )
		player.AmmoPool_SetCount( ammoType, 0 )
	}

	if( player.p.weaponModelIndex > -1 )
		weapon.SetLegendaryModelIndex( player.p.weaponModelIndex )
	
	if( player.p.weaponSkin > -1 )
		weapon.SetSkin( player.p.weaponSkin )
	
	if(player.p.weapon2 == "") 
	{
		player.ClearFirstDeployForAllWeapons()
		player.SetActiveWeaponBySlot( eActiveInventorySlot.mainHand, WEAPON_INVENTORY_SLOT_PRIMARY_0 )
		return
	}
	
	entity weapon2 = player.GiveWeapon_NoDeploy( player.p.weapon2, WEAPON_INVENTORY_SLOT_PRIMARY_1, player.p.mods2 )

	if( !fromSelector )
	{
		SetupInfiniteAmmoForWeapon( player, weapon2 )

		if(weapon2.UsesClipsForAmmo())
			weapon2.SetWeaponPrimaryClipCount( weapon2.GetWeaponPrimaryClipCountMax() )
	} else
	{
		int ammoType = weapon.GetWeaponAmmoPoolType()
		player.AmmoPool_SetCapacity( 65535 )
		player.AmmoPool_SetCount( ammoType, 0 )
	}

	if( player.p.weaponModelIndex2 > -1 )
		weapon2.SetLegendaryModelIndex( player.p.weaponModelIndex2 )
	
	if( player.p.weaponSkin2 > -1 )
		weapon2.SetSkin( player.p.weaponSkin2 )

	player.ClearFirstDeployForAllWeapons()
	player.SetActiveWeaponBySlot( eActiveInventorySlot.mainHand, WEAPON_INVENTORY_SLOT_PRIMARY_0 )
}

bool function CC_Weapon_Selector_Open( entity player, array<string> args )
{
	thread SetupPlayer( player, true )

	player.SetOrigin(file.AimTrainer_startPos)
	player.SetAngles(file.AimTrainer_startAngs)
	return false
}
bool function CC_Weapon_Selector_Close( entity player, array<string> args )
{
	TakeAllWeapons( player )
	return false
}

bool function CC_ExitChallenge( entity player, array<string> args )
{
	Signal(player, "ChallengeTimeOver")
	return false
}

bool function CC_RestartChallenge( entity player, array<string> args )
{
	player.p.isRestartingLevel = true
	OnChallengeEnd(player)
	return false
}

bool function CC_AimTrainer_PLATFORM_SIZE( entity player, array<string> args )
{
	if(args.len() < 1) 
	{
		return false
	}
	
	float newSize = args[0].tofloat()
	if(newSize < 0.2) newSize = 0.2  // Minimum 20% size
	if(newSize > 1.0) newSize = 1.0  // Maximum 100% size
	
	AimTrainer_MIDDLE_PLATFORM_SIZE_RATIO = newSize
	
	return false
}

bool function CC_AimTrainer_PLATFORM_HEIGHT( entity player, array<string> args )
{
	if(args.len() < 1) 
	{
		return false
	}
	
	float newHeight = args[0].tofloat()
	if(newHeight < 0.1) newHeight = 0.1  // Minimum 10% height
	if(newHeight > 0.9) newHeight = 0.9  // Maximum 90% height
	
	AimTrainer_MIDDLE_PLATFORM_HEIGHT_RATIO = newHeight
	
	return false
}

// 1Wall6Targets Challenge - Priority 1: Static Clicking
void function Start1Wall6TargetsChallenge(entity player)
{
	if(!IsValid(player)) return
	
	// Set challenge name for scoring
	// player.p.challengeName = eChallengeNames.CHALLENGE_1WALL6TARGETS
	player.p.isChallengeActivated = true
	
	// Clear occupied positions for this challenge
	file.occupied1Wall6Positions.clear()
	
	// Calculate box dimensions based on tracking area configuration
	float boxWidth = AimTrainer_TRACKING_TILES_DEPTH * 700.0
	float boxHeight = AimTrainer_TRACKING_TILES_VERTICAL * 700.0
	float boxDepth = AimTrainer_TRACKING_TILES_HORIZONTAL * 700.0
	
	// Calculate room center position
	vector roomCenter = file.floorCenterForPlayerSky + Vector(0, 0, boxHeight/2)
	
	// Position player against back wall on platform (same as bouncing tracking scenario)
	vector playerPos = roomCenter + Vector(boxWidth/2 - AimTrainer_TRACKING_PLAYER_WALL_OFFSET, 0, 0)
	player.SetOrigin(playerPos)
	player.SetAngles(Vector(0, 180, 0))
	
	EndSignal(player, "ChallengeTimeOver")
	
	// Create tracking box room
	ChallengesEntities.floor = CreateTrackingBox(roomCenter, boxWidth, boxHeight, boxDepth)
	
	// Create small platform (1 tile) for player to stand on at mid-height, positioned as border behind player
	vector platformPos = playerPos + Vector(700, 0, 300) // Move platform toward back wall (behind player)
	array<entity> platform = CreateMiddlePlatform(platformPos, 700.0, 700.0, 1.0, 0.0)
	ChallengesEntities.floor.extend(platform)
	
	OnThreadEnd(
		function() : (player)
		{
			OnChallengeEnd(player)
		}
	)
	
	// Challenge setup
	AddCinematicFlag(player, CE_FLAG_HIDE_MAIN_HUD_INSTANT)
	AddCinematicFlag(player, CE_FLAG_HIDE_PERMANENT_HUD)
	player.FreezeControlsOnServer()
	Remote_CallFunction_NonReplay(player, "ServerCallback_SetChallengeActivated", true)
	
	// Disable auto weapon mod for lightning gun if equipped
	entity weapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if(IsValid(weapon) && weapon.GetWeaponClassName() == "mp_weapon_lightninggun_nomodel")
	{
		try{weapon.AddMod("noauto")} catch(e42069){printt("lightning gun failed to add noauto mod. DEBUG THIS.")}
	}
	
	wait AimTrainer_PRE_START_TIME
	RemoveCinematicFlag(player, CE_FLAG_HIDE_MAIN_HUD_INSTANT)
	RemoveCinematicFlag(player, CE_FLAG_HIDE_PERMANENT_HUD)
	player.UnfreezeControlsOnServer()
	
	float endtime = Time() + AimTrainer_CHALLENGE_DURATION
	thread ChallengeWatcherThread(endtime, player)
	
	// Create high-density grid with holes for 1Wall6Targets scenario
	vector frontWallCenter = roomCenter + Vector(-boxWidth/2 + AimTrainer_TRACKING_TARGET_WALL_OFFSET, 0, 0)
	
	// Calculate grid dimensions based on 50x50 target size within 700x700 tiles
	float targetSpacing = 60.0  // 50 unit targets + 10 unit spacing
	int gridCols = int((boxDepth * 0.9) / targetSpacing) // Use 90% of wall width
	int gridRows = int((boxHeight * 0.9) / targetSpacing) // Use 90% of wall height
	
	// Ensure we have a substantial grid (minimum 20x15 for good density)
	gridCols = int(max(gridCols, 20))
	gridRows = int(max(gridRows, 15))
	
	// Create dense grid with strategic holes (skip some positions for realistic 1Wall6Targets feel)
	array<vector> targetPositions = []
	for(int row = 0; row < gridRows; row++)
	{
		for(int col = 0; col < gridCols; col++)
		{
			// Create holes with multiple patterns for variety
			bool isHole = false
			
			// Pattern 1: Regular grid holes every 4th position
			if((row % 4 == 0 && col % 4 == 0) || 
			   (row % 4 == 2 && col % 4 == 2))
				isHole = true
			
			// Pattern 2: Diagonal strips
			if((row + col) % 7 == 0)
				isHole = true
			
			// Pattern 3: Random holes (about 15% chance)
			if(RandomFloat(1.0) < 0.15)
				isHole = true
			
			if(isHole)
				continue // Skip this position to create holes
			
			// Calculate position on the front wall
			float yStart = -(boxDepth * 0.45) // Start from left edge (45% from center)
			float zStart = -(boxHeight * 0.45) // Start from bottom edge (45% from center)
			
			float yPos = yStart + (col * targetSpacing)
			float zPos = zStart + (row * targetSpacing)
			
			vector targetPos = frontWallCenter + Vector(0, yPos, zPos)
			targetPositions.append(targetPos)
		}
	}
	
	// Spawn initial targets randomly spread across the wall
	int targetsToSpawn = int(min(targetPositions.len(), AimTrainer_1WALL6TARGETS_TARGET_COUNT))
	
	// Shuffle the target positions for random distribution
	array<vector> shuffledPositions = clone targetPositions
	for(int i = shuffledPositions.len() - 1; i > 0; i--)
	{
		int j = RandomInt(i + 1)
		vector temp = shuffledPositions[i]
		shuffledPositions[i] = shuffledPositions[j]
		shuffledPositions[j] = temp
	}
	
	for(int i = 0; i < targetsToSpawn; i++)
	{
		entity target = CreateStaticTarget(player, shuffledPositions[i])
		if(IsValid(target))
		{
			ChallengesEntities.props.append(target)
			// Track this position as occupied
			file.occupied1Wall6Positions.append(shuffledPositions[i])
		}
	}
	
	WaitForever()
}

// Function to spawn new target for 1Wall6Targets challenge
void function SpawnNew1Wall6Target(entity player)
{
	if(!IsValid(player)) return
	
	// Check if we already have enough targets
	int currentTargetCount = 0
	foreach(entity prop in ChallengesEntities.props)
	{
		if(IsValid(prop) && prop.GetMaxHealth() == 1) // Count 1Wall6Targets targets only
			currentTargetCount++
	}
	
	if(currentTargetCount >= AimTrainer_1WALL6TARGETS_TARGET_COUNT)
		return // Don't spawn more than the target count
	
	wait 0.1 // Brief delay for visual feedback
	
	// Calculate same dimensions as challenge setup
	float boxWidth = AimTrainer_TRACKING_TILES_DEPTH * 700.0
	float boxHeight = AimTrainer_TRACKING_TILES_VERTICAL * 700.0
	float boxDepth = AimTrainer_TRACKING_TILES_HORIZONTAL * 700.0
	
	vector roomCenter = file.floorCenterForPlayerSky + Vector(0, 0, boxHeight/2)
	vector frontWallCenter = roomCenter + Vector(-boxWidth/2 + AimTrainer_TRACKING_TARGET_WALL_OFFSET, 0, 0)
	
	// Calculate grid dimensions based on 50x50 target size within 700x700 tiles (same as original spawn)
	float targetSpacing = 60.0  // 50 unit targets + 10 unit spacing
	int gridCols = int((boxDepth * 0.9) / targetSpacing) // Use 90% of wall width
	int gridRows = int((boxHeight * 0.9) / targetSpacing) // Use 90% of wall height
	
	// Ensure we have a substantial grid (minimum 20x15 for good density)
	gridCols = int(max(gridCols, 20))
	gridRows = int(max(gridRows, 15))
	
	// Generate all valid grid positions (excluding holes)
	array<vector> validPositions = []
	for(int row = 0; row < gridRows; row++)
	{
		for(int col = 0; col < gridCols; col++)
		{
			// Create holes with multiple patterns for variety (same as original)
			bool isHole = false
			
			// Pattern 1: Regular grid holes every 4th position
			if((row % 4 == 0 && col % 4 == 0) || 
			   (row % 4 == 2 && col % 4 == 2))
				isHole = true
			
			// Pattern 2: Diagonal strips
			if((row + col) % 7 == 0)
				isHole = true
			
			// Pattern 3: Random holes (about 15% chance)
			if(RandomFloat(1.0) < 0.15)
				isHole = true
			
			if(isHole)
				continue // Skip this position to create holes
			
			// Calculate position on the front wall
			float yStart = -(boxDepth * 0.45) // Start from left edge (45% from center)
			float zStart = -(boxHeight * 0.45) // Start from bottom edge (45% from center)
			
			float yPos = yStart + (col * targetSpacing)
			float zPos = zStart + (row * targetSpacing)
			
			vector targetPos = frontWallCenter + Vector(0, yPos, zPos)
			
			// Check if this position is already occupied
			bool isOccupied = false
			foreach(vector occupiedPos in file.occupied1Wall6Positions)
			{
				if(Distance(occupiedPos, targetPos) < 30.0) // Close enough to be considered same position
				{
					isOccupied = true
					break
				}
			}
			
			if(!isOccupied)
				validPositions.append(targetPos)
		}
	}
	
	// Pick random position from valid positions
	if(validPositions.len() > 0)
	{
		vector spawnPos = validPositions[RandomInt(validPositions.len())]
		entity newTarget = CreateStaticTarget(player, spawnPos)
		if(IsValid(newTarget))
		{
			ChallengesEntities.props.append(newTarget)
			// Track this position as occupied
			file.occupied1Wall6Positions.append(spawnPos)
		}
	}
}

// Close Long Strafes Challenge - Priority 2: Advanced Tracking
void function StartCloseLongStrafesChallenge(entity player)
{
	if(!IsValid(player)) return
	
	// Set challenge name for scoring
	// player.p.challengeName = eChallengeNames.CHALLENGE_CLOSELONGSTRAFES
	player.p.isChallengeActivated = true
	
	// Calculate box dimensions
	float boxWidth = AimTrainer_TRACKING_TILES_DEPTH * 700.0
	float boxHeight = AimTrainer_TRACKING_TILES_VERTICAL * 700.0
	float boxDepth = AimTrainer_TRACKING_TILES_HORIZONTAL * 700.0
	
	// Calculate room center position
	vector roomCenter = file.floorCenterForPlayerSky + Vector(0, 0, boxHeight/2)
	
	// Position player against back wall on platform (same as 1Wall6Targets scenario)
	vector playerPos = roomCenter + Vector(boxWidth/2 - AimTrainer_TRACKING_PLAYER_WALL_OFFSET, 0, 0)
	player.SetOrigin(playerPos)
	player.SetAngles(Vector(0, 180, 0))
	
	EndSignal(player, "ChallengeTimeOver")
	
	// Create tracking box room
	ChallengesEntities.floor = CreateTrackingBox(roomCenter, boxWidth, boxHeight, boxDepth)
	
	// Create small platform (1 tile) for player to stand on at target center level
	vector platformPos = playerPos + Vector(700, 0, 300) // Move platform toward back wall and align with target center
	array<entity> platform = CreateMiddlePlatform(platformPos, 700.0, 700.0, 1.0, 0.0)
	ChallengesEntities.floor.extend(platform)
	
	OnThreadEnd(
		function() : (player)
		{
			OnChallengeEnd(player)
		}
	)
	
	// Challenge setup
	AddCinematicFlag(player, CE_FLAG_HIDE_MAIN_HUD_INSTANT)
	AddCinematicFlag(player, CE_FLAG_HIDE_PERMANENT_HUD)
	player.FreezeControlsOnServer()
	Remote_CallFunction_NonReplay(player, "ServerCallback_SetChallengeActivated", true)
	
	wait AimTrainer_PRE_START_TIME
	RemoveCinematicFlag(player, CE_FLAG_HIDE_MAIN_HUD_INSTANT)
	RemoveCinematicFlag(player, CE_FLAG_HIDE_PERMANENT_HUD)
	player.UnfreezeControlsOnServer()
	
	float endtime = Time() + AimTrainer_CHALLENGE_DURATION
	thread ChallengeWatcherThread(endtime, player)
	
	// Position target center close to front wall
	vector targetCenter = roomCenter + Vector(-boxWidth/2 + AimTrainer_TRACKING_TARGET_WALL_OFFSET, 0, 0)
	
	// Spawn single target for long horizontal strafe
	entity target = CreateTrackingTarget(player, targetCenter)
	if(IsValid(target))
	{
		ChallengesEntities.props.append(target)
		thread HorizontalStrafingMovement(player, target, targetCenter, boxDepth)
		thread PatternMovement_FixTargetAngles(player, target)
	}
	
	WaitForever()
}

// Tile Frenzy Strafing Challenge - Priority 3: Movement + Clicking
void function StartTileFrenzyStrafingChallenge(entity player)
{
	if(!IsValid(player)) return
	
	// Set challenge name for scoring
	// player.p.challengeName = eChallengeNames.CHALLENGE_TILEFRENZY
	player.p.isChallengeActivated = true
	
	// Calculate box dimensions
	float boxWidth = AimTrainer_TRACKING_TILES_DEPTH * 700.0
	float boxHeight = AimTrainer_TRACKING_TILES_VERTICAL * 700.0
	float boxDepth = AimTrainer_TRACKING_TILES_HORIZONTAL * 700.0
	
	// Calculate room center position
	vector roomCenter = file.floorCenterForPlayerSky + Vector(0, 0, boxHeight/2)
	
	// Position player on middle platform (for better movement)
	float platformHeight = AimTrainer_MIDDLE_PLATFORM_HEIGHT_RATIO * boxHeight
	vector playerPos = roomCenter + Vector(0, 0, platformHeight - boxHeight/2 + 50) // 50 units above platform for clearance
	player.SetOrigin(playerPos)
	player.SetAngles(Vector(0, 0, 0))
	
	EndSignal(player, "ChallengeTimeOver")
	
	// Create tracking box room with middle platform enabled
	ChallengesEntities.floor = CreateTrackingBox(roomCenter, boxWidth, boxHeight, boxDepth, true)
	
	OnThreadEnd(
		function() : (player)
		{
			OnChallengeEnd(player)
		}
	)
	
	// Challenge setup
	AddCinematicFlag(player, CE_FLAG_HIDE_MAIN_HUD_INSTANT)
	AddCinematicFlag(player, CE_FLAG_HIDE_PERMANENT_HUD)
	player.FreezeControlsOnServer()
	Remote_CallFunction_NonReplay(player, "ServerCallback_SetChallengeActivated", true)
	
	wait AimTrainer_PRE_START_TIME
	RemoveCinematicFlag(player, CE_FLAG_HIDE_MAIN_HUD_INSTANT)
	RemoveCinematicFlag(player, CE_FLAG_HIDE_PERMANENT_HUD)
	player.UnfreezeControlsOnServer()
	
	// ENABLE MOVEMENT for this challenge (key difference from other scenarios)
	// player.MovementEnable() // Keep movement enabled
	
	float endtime = Time() + AimTrainer_CHALLENGE_DURATION
	thread ChallengeWatcherThread(endtime, player)
	
	// Spawn initial targets at random tile positions
	int numTargets = 6 // Start with 6 targets like original scenarios
	for(int i = 0; i < numTargets; i++)
	{
		// Generate random tile position
		int randomY = RandomInt(AimTrainer_TRACKING_TILES_HORIZONTAL)
		int randomZ = RandomInt(AimTrainer_TRACKING_TILES_VERTICAL)
		int randomX = RandomInt(AimTrainer_TRACKING_TILES_DEPTH)
		
		float tileY = (randomY * 700.0) - (boxDepth/2) + 350
		float tileZ = (randomZ * 700.0) - (boxHeight/2) + 350  
		float tileX = (randomX * 700.0) - (boxWidth/2) + 350
		
		vector targetPos = roomCenter + Vector(tileX, tileY, tileZ)
		
		entity target = CreateStaticTarget(player, targetPos)
		if(IsValid(target))
		{
			ChallengesEntities.props.append(target)
		}
	}
	
	WaitForever()
}

// Helper function to create static targets for clicking scenarios
entity function CreateStaticTarget(entity player, vector pos)
{
	entity target = CreateEntity("script_mover")
	target.kv.solid = 6
	target.SetValueForModelKey(AIMTRAINER_TRACKING_MODEL)
	target.kv.SpawnAsPhysicsMover = 0
	
	target.SetOrigin(pos)
	target.SetAngles(VectorToAngles(player.GetOrigin() - pos))
	DispatchSpawn(target)
	target.SetDamageNotifications(true)
	
	// Set health to 1 for insta-kill behavior
	target.SetMaxHealth(1)
	target.SetHealth(1)
	target.SetTakeDamageType(DAMAGE_YES)
	
	AddEntityCallback_OnDamaged(target, OnStaticTargetDamaged)
	
	// Play sound effect on target creation
	EmitSoundOnEntityOnlyToPlayer( player, player, "player_hitbeep_headshot_kill_android_3p_vs_1p" )
	
	return target
}

// Helper function for horizontal strafing movement
void function HorizontalStrafingMovement(entity player, entity target, vector centerPos, float maxWidth)
{
	if(!IsValid(player) || !IsValid(target)) return
	
	EndSignal(player, "ChallengeTimeOver")
	target.EndSignal("OnDeath")
	
	float halfWidth = maxWidth / 2 - 100  // Leave some margin from walls
	bool movingRight = true
	
	while(true)
	{
		vector targetPos = centerPos + Vector(0, movingRight ? halfWidth : -halfWidth, 0)
		float distance = Distance(target.GetOrigin(), targetPos)
		float time = distance / (AimTrainer_TRACKING_SPEED * 50)
		
		target.NonPhysicsMoveTo(targetPos, time, 0, 0)
		wait time
		
		movingRight = !movingRight
	}
}

// Damage callback for static targets with respawning
void function OnStaticTargetDamaged(entity target, var damageInfo)
{
	entity attacker = DamageInfo_GetAttacker(damageInfo)
	float damage = DamageInfo_GetDamage(damageInfo)
	
	if(!attacker.IsPlayer()) return
	
	// For 1Wall6Targets challenge, destroy target and respawn a new one
	if(target.GetMaxHealth() == 1) // Insta-kill targets
	{
		// Ball killed, award points and clean up
		attacker.p.straferDummyKilledCount++
		Remote_CallFunction_NonReplay(attacker, "ServerCallback_LiveStatsUIDummiesKilled", attacker.p.straferDummyKilledCount)
		
		// Play hit sound
		EmitSoundOnEntityOnlyToPlayer( attacker, attacker, "player_hitbeep" )
		
		// Update UI stats
		Remote_CallFunction_NonReplay(attacker, "ServerCallback_LiveStatsUIDamageViaDummieDamaged", 1)
		Remote_CallFunction_NonReplay(attacker, "ServerCallback_LiveStatsUIAccuracyViaShotsHits")
		
		// Remove from props array and occupied positions
		ChallengesEntities.props.removebyvalue(target)
		vector targetPos = target.GetOrigin()
		
		// Remove this position from occupied list
		for(int i = file.occupied1Wall6Positions.len() - 1; i >= 0; i--)
		{
			if(Distance(file.occupied1Wall6Positions[i], targetPos) < 30.0) // Close enough match
			{
				file.occupied1Wall6Positions.remove(i)
				break
			}
		}
		
		target.Destroy()
		
		// Spawn new target immediately at position farthest from existing targets
		thread SpawnNew1Wall6Target(attacker)
	}
	else
	{
		// Reset target health instead of destroying (for continuous gameplay)
		target.SetHealth(target.GetMaxHealth())
		
		// Play hit sound
		EmitSoundOnEntityOnlyToPlayer( attacker, attacker, "player_hitbeep" )
		
		// Update UI stats
		Remote_CallFunction_NonReplay(attacker, "ServerCallback_LiveStatsUIDamageViaDummieDamaged", int(damage))
		Remote_CallFunction_NonReplay(attacker, "ServerCallback_LiveStatsUIAccuracyViaShotsHits")
		
		// Respawn target at new location based on challenge type
		thread RespawnStaticTarget(attacker, target)
	}
}

// Respawn function for static targets
void function RespawnStaticTarget(entity player, entity target)
{
	if(!IsValid(player) || !IsValid(target)) return
	
	wait 0.1 // Brief delay for visual feedback
	
	// Determine challenge type and respawn accordingly
	if(player.p.challengeName == eChallengeNames.CHALLENGE_1WALL6TARGETS)
	{
		// Respawn at one of the 6 wall positions
		Respawn1Wall6Targets(player, target)
	}
	else if(player.p.challengeName == eChallengeNames.CHALLENGE_TILEFRENZY)
	{
		// Respawn at random tile intersection
		RespawnTileFrenzy(player, target)
	}
}

// Respawn for 1Wall6Targets - reposition to one of the 6 wall spots
void function Respawn1Wall6Targets(entity player, entity target)
{
	if(!IsValid(player) || !IsValid(target)) return
	
	// Calculate box dimensions
	float boxWidth = AimTrainer_TRACKING_TILES_DEPTH * 700.0
	float boxHeight = AimTrainer_TRACKING_TILES_VERTICAL * 700.0
	float boxDepth = AimTrainer_TRACKING_TILES_HORIZONTAL * 700.0
	
	vector roomCenter = file.floorCenterForPlayerSky + Vector(0, 0, boxHeight/2)
	vector frontWallCenter = roomCenter + Vector(-boxWidth/2 + AimTrainer_TRACKING_TARGET_WALL_OFFSET, 0, 0)
	
	// Same 6 positions as original spawn
	array<vector> targetPositions = [
		frontWallCenter + Vector(0, -boxDepth/4, boxHeight/4),   // Top Left
		frontWallCenter + Vector(0, 0, boxHeight/4),             // Top Center
		frontWallCenter + Vector(0, boxDepth/4, boxHeight/4),    // Top Right
		frontWallCenter + Vector(0, -boxDepth/4, -boxHeight/4),  // Bottom Left
		frontWallCenter + Vector(0, 0, -boxHeight/4),            // Bottom Center
		frontWallCenter + Vector(0, boxDepth/4, -boxHeight/4)    // Bottom Right
	]
	
	// Pick random position
	vector newPos = targetPositions[RandomInt(targetPositions.len())]
	target.SetOrigin(newPos)
	target.SetAngles(VectorToAngles(player.GetOrigin() - newPos))
}

// Respawn for Tile Frenzy - spawn at random tile intersections
void function RespawnTileFrenzy(entity player, entity target)
{
	if(!IsValid(player) || !IsValid(target)) return
	
	// Calculate box dimensions
	float boxWidth = AimTrainer_TRACKING_TILES_DEPTH * 700.0
	float boxHeight = AimTrainer_TRACKING_TILES_VERTICAL * 700.0
	float boxDepth = AimTrainer_TRACKING_TILES_HORIZONTAL * 700.0
	
	vector roomCenter = file.floorCenterForPlayerSky + Vector(0, 0, boxHeight/2)
	
	// Generate random tile position
	int randomY = RandomInt(AimTrainer_TRACKING_TILES_HORIZONTAL)
	int randomZ = RandomInt(AimTrainer_TRACKING_TILES_VERTICAL)
	int randomX = RandomInt(AimTrainer_TRACKING_TILES_DEPTH)
	
	float tileY = (randomY * 700.0) - (boxDepth/2) + 350
	float tileZ = (randomZ * 700.0) - (boxHeight/2) + 350
	float tileX = (randomX * 700.0) - (boxWidth/2) + 350
	
	vector newPos = roomCenter + Vector(tileX, tileY, tileZ)
	target.SetOrigin(newPos)
	target.SetAngles(VectorToAngles(player.GetOrigin() - newPos))
}
