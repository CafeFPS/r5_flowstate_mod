#if !UI
global function Sh_ChallengesByColombia_Init
#endif

global function InitializeSharedChallengeData
global function GetChallengeByClientScript
global function GetChallengesByCategoryName
global function GetAllChallengesFlattened
global function GetChallengeByLegacyServerId

global enum eChallengeNames
{
	CHALLENGE_1WALL6TARGETS,
	CHALLENGE_CLOSELONGSTRAFES,
	CHALLENGE_TILEFRENZY
}

global int AimTrainer_CHALLENGE_DURATION = 60
global int AimTrainer_AI_HEALTH = 100
global int AimTrainer_AI_SHIELDS_LEVEL = 0
global int AimTrainer_AI_COLOR = 5
global float AimTrainer_STRAFING_SPEED = 1
global float AimTrainer_STRAFING_SPEED_WAITTIME = 1
global float AimTrainer_SPAWN_DISTANCE = 1
global bool AimTrainer_INFINITE_CHALLENGE = false
global bool AimTrainer_INFINITE_AMMO = true
global bool AimTrainer_INFINITE_AMMO2 = false
global bool AimTrainer_INMORTAL_TARGETS = false
global bool AimTrainer_USER_WANNA_BE_A_DUMMY = false

// AIMTRAINER 2.0
// global float AimTrainer_TRACKING_HEIGHT = 200.0
global float AimTrainer_TRACKING_SPEED = 15.0

//Size of the scenario
global int AimTrainer_TRACKING_TILES_HORIZONTAL = 8  // Number of tiles horizontally (700 units each)
global int AimTrainer_TRACKING_TILES_VERTICAL = 4   // Number of tiles vertically (700 units each)
global int AimTrainer_TRACKING_TILES_DEPTH = 4      // Number of tiles depth (700 units each)

global float AimTrainer_TRACKING_TARGET_SCALE = 0.8 //not used rn

global bool AimTrainer_TRACKING_RANDOM_START = true

// Room positioning configuration
global float AimTrainer_TRACKING_PLAYER_WALL_OFFSET = 100.0  // Distance from front wall
global float AimTrainer_TRACKING_TARGET_WALL_OFFSET = 50.0  // Distance from back wall

// Middle Platform Configuration
global bool AimTrainer_MIDDLE_PLATFORM_ENABLED = false       // Enable middle platform for better positioning
global float AimTrainer_MIDDLE_PLATFORM_SIZE_RATIO = 0.6    // Platform size ratio (0.6 = 60% of room size)
global float AimTrainer_MIDDLE_PLATFORM_HEIGHT_RATIO = 0.5  // Platform height ratio (0.5 = middle of room)
global int AimTrainer_TRACKING_BALL_COUNT = 5  // Number of balls to spawn

// Ball movement constraints
global float AimTrainer_TRACKING_MIN_ANGLE_DEG = 20.0  // Minimum angle from horizontal/vertical (degrees)
global float AimTrainer_TRACKING_MAX_ANGLE_DEG = 70.0  // Maximum angle from horizontal/vertical (degrees)
global float AimTrainer_TRACKING_BALL_RADIUS = 55.0    // Ball radius for wall collision offset

// Patstrafe challenge settings
global float AimTrainer_PATSTRAFE_MAX_DISTANCE = 1000.0  // Maximum spawn distance from player
global float AimTrainer_PATSTRAFE_HEIGHT_OFFSET = 50.0   // Height offset above ground level
global float AimTrainer_PATSTRAFE_SPEED_MULTIPLIER = 300.0  // Speed multiplier for patstrafe target movement
global float AimTrainer_PATSTRAFE_DIRECTION_CHANGE_PROBABILITY = 0.1//0.8  // Probability of direction change per frame (0.0-1.0)

// Movement tracking and scoring
global bool AimTrainer_PATSTRAFE_ENABLE_MOVEMENT_TRACKING = true  // Enable movement tracking and scoring
global float AimTrainer_PATSTRAFE_MOVEMENT_SCORE_CAP = 1000.0    // Maximum movement score cap
global float AimTrainer_PATSTRAFE_DISTANCE_SCORE_MULTIPLIER = 0.1  // Scaling factor for distance scoring (lower = slower scoring)

// Speed control per movement
global bool AimTrainer_PATSTRAFE_FIXED_SPEED_PER_MOVEMENT = true  // Use fixed speed for each movement change
global float AimTrainer_PATSTRAFE_FIXED_SPEED = 4000.0             // Fixed speed value when fixed mode enabled
global float AimTrainer_PATSTRAFE_MIN_VARIABLE_SPEED = 2000.0 //200.0      // Minimum variable speed when fixed mode disabled
global float AimTrainer_PATSTRAFE_MAX_VARIABLE_SPEED = 4000.0 //500.0      // Maximum variable speed when fixed mode disabled

// Player-view-relative strafing settings
global float AimTrainer_PATSTRAFE_HORIZONTAL_STRAFE_PROBABILITY = 0.9//0.7  // Probability of pure horizontal strafing (0.0-1.0)
global float AimTrainer_PATSTRAFE_DIAGONAL_MOVEMENT_PROBABILITY = 0.1//0.2   // Probability of diagonal movement (0.0-1.0)
global float AimTrainer_PATSTRAFE_OPTIMAL_DISTANCE_MIN = 400.0          // Minimum optimal distance from player
global float AimTrainer_PATSTRAFE_OPTIMAL_DISTANCE_MAX = 800.0         // Maximum optimal distance from player
global float AimTrainer_PATSTRAFE_COUNTER_STRAFE_PROBABILITY = 0.1//0.3      // Probability of counter-strafing player movement

// Debug settings
global bool AimTrainer_PATSTRAFE_ENABLE_DEBUG_PRINTS = false       // Enable/disable patstrafe debug console prints

// Popcorn Physics Challenge settings
global int AimTrainer_POPCORN_PHYSICS_TARGET_COUNT = 10//10             // Number of physics targets to spawn
global float AimTrainer_POPCORN_PHYSICS_VELOCITY_MIN = 400.0        // Minimum initial velocity
global float AimTrainer_POPCORN_PHYSICS_VELOCITY_MAX = 500.0        // Maximum initial velocity
global float AimTrainer_POPCORN_PHYSICS_UPWARD_VELOCITY_MIN = 1100.0 // Minimum upward velocity component
global float AimTrainer_POPCORN_PHYSICS_UPWARD_VELOCITY_MAX = 1400.0 // Maximum upward velocity component
global int AimTrainer_POPCORN_PHYSICS_TARGET_HEALTH = 100            // Health per physics target
global float AimTrainer_POPCORN_PHYSICS_RESPAWN_DELAY = 0.0 //5         // Delay before respawning killed target
global float AimTrainer_POPCORN_PHYSICS_SPAWN_DISTANCE_MIN = 800.0   // Minimum spawn distance from player
global float AimTrainer_POPCORN_PHYSICS_SPAWN_DISTANCE_MAX = 1000.0   // Maximum spawn distance from player

// 1Wall6Targets Challenge settings
global int AimTrainer_1WALL6TARGETS_TARGET_COUNT = 6               // Number of targets to keep spawned simultaneously

global const asset AIMTRAINER_TRACKING_MODEL = $"mdl/props/loot_sphere/loot_sphere.rmdl"//$"mdl/barriers/shooting_range_target_02.rmdl"

global const int AimTrainer_RESULTS_TIME = 10
global const float AimTrainer_PRE_START_TIME = 3.0 //description time

//Shared Challenge System - synchronized across all VMs
global struct Challenge
{
	int id
	string name
	string category
	int bestScore
	string clientScript
	asset videoAsset
	bool isNew
	string maxScoreConVar
}

//Global challenge arrays - accessible by all VMs
global array<Challenge> clickingChallenges
global array<Challenge> trackingChallenges
global array<Challenge> switchingChallenges
global array<Challenge> movementChallenges
global array<Challenge> allChallengesFlattened

#if !UI
void function Sh_ChallengesByColombia_Init()
{
	// Time Over signal
	RegisterSignal("ChallengeTimeOver")
	RegisterSignal("ForceResultsEnd_SkipButton")
	
	PrecacheParticleSystem($"P_wpn_lasercannon_aim_short_blue")
	
	//Initialize shared challenge data
	InitializeSharedChallengeData()
}
#endif

void function InitializeSharedChallengeData()
{
	//Clear existing data
	trackingChallenges.clear()
	clickingChallenges.clear()
	switchingChallenges.clear()
	movementChallenges.clear()
	allChallengesFlattened.clear()
	
	//Tracking challenges
	Challenge challenge1
	challenge1.id = 0
	challenge1.name = "Strafing Dummy"
	challenge1.category = "TrackingChallenges" 
	challenge1.bestScore = 0
	challenge1.clientScript = "StartChallenge1Client"
	challenge1.videoAsset = $"media/flowstate/aimtrainer/strafingdummy.bik"
	challenge1.isNew = false
	challenge1.maxScoreConVar = "fs_aimtrainer_challenge_max_score_strafingdummy"
	trackingChallenges.append(challenge1)
	
	Challenge challenge2
	challenge2.id = 1
	challenge2.name = "Shooting Valk's Ult"
	challenge2.category = "TrackingChallenges"
	challenge2.bestScore = 0
	challenge2.clientScript = "StartChallenge4NewCClient"
	challenge2.videoAsset = $"media/flowstate/aimtrainer/shootingvalksult.bik"
	challenge2.isNew = false
	challenge2.maxScoreConVar = "fs_aimtrainer_challenge_max_score_shootingvalksult"
	trackingChallenges.append(challenge2)
	
	Challenge challenge3
	challenge3.id = 2
	challenge3.name = "Close Fast Strafes"
	challenge3.category = "TrackingChallenges"
	challenge3.bestScore = 0
	challenge3.clientScript = "StartChallenge6Client"
	challenge3.videoAsset = $"media/flowstate/aimtrainer/closefaststrafes.bik"
	challenge3.isNew = false
	challenge3.maxScoreConVar = "fs_aimtrainer_challenge_max_score_closefaststrafes"
	trackingChallenges.append(challenge3)
	
	Challenge challenge4
	challenge4.id = 3
	challenge4.name = "Skydiving Targets"
	challenge4.category = "TrackingChallenges"
	challenge4.bestScore = 0
	challenge4.clientScript = "StartChallenge6NewCClient"
	challenge4.videoAsset = $"media/flowstate/aimtrainer/skydivingtargets.bik"
	challenge4.isNew = false
	challenge4.maxScoreConVar = "fs_aimtrainer_challenge_max_score_skydivingtargets"
	trackingChallenges.append(challenge4)
	
	Challenge challenge5
	challenge5.id = 4
	challenge5.name = "Smoothbot"
	challenge5.category = "TrackingChallenges"
	challenge5.bestScore = 0
	challenge5.clientScript = "StartChallenge7Client"
	challenge5.videoAsset = $"media/flowstate/aimtrainer/smoothbot.bik"
	challenge5.isNew = false
	challenge5.maxScoreConVar = "fs_aimtrainer_challenge_max_score_smoothbot"
	trackingChallenges.append(challenge5)
	
	Challenge challenge6
	challenge6.id = 5
	challenge6.name = "Running Targets"
	challenge6.category = "TrackingChallenges"
	challenge6.bestScore = 0
	challenge6.clientScript = "StartChallenge7NewCClient"
	challenge6.videoAsset = $"media/flowstate/aimtrainer/runningtargets.bik"
	challenge6.isNew = false
	challenge6.maxScoreConVar = "fs_aimtrainer_challenge_max_score_runningtargets"
	trackingChallenges.append(challenge6)
	
	Challenge challenge7
	challenge7.id = 6
	challenge7.name = "Popcorn Targets"
	challenge7.category = "TrackingChallenges"
	challenge7.bestScore = 0
	challenge7.clientScript = "StartChallenge4Client"
	challenge7.videoAsset = $"media/flowstate/aimtrainer/popcorntargets.bik"
	challenge7.isNew = false
	challenge7.maxScoreConVar = "fs_aimtrainer_challenge_max_score_popcorntargets"
	trackingChallenges.append(challenge7)
	
	Challenge challenge19
	challenge19.id = 7
	challenge19.name = "Pattern 2D Tracking"
	challenge19.category = "TrackingChallenges"
	challenge19.bestScore = 0
	challenge19.clientScript = "StartPatternTrackingScenarioClient"
	challenge19.videoAsset = $"media/flowstate/aimtrainer/pattern2dtracking.bik"
	challenge19.isNew = true
	challenge19.maxScoreConVar = "fs_aimtrainer_challenge_max_score_pattern2dtracking"
	trackingChallenges.append(challenge19)
	
	Challenge challenge20
	challenge20.id = 8
	challenge20.name = "Bouncing 2D Tracking"
	challenge20.category = "TrackingChallenges"
	challenge20.bestScore = 0
	challenge20.clientScript = "StartBouncingTrackingScenarioClient"
	challenge20.videoAsset = $"media/flowstate/aimtrainer/bouncing2dtracking.bik"
	challenge20.isNew = true
	challenge20.maxScoreConVar = "fs_aimtrainer_challenge_max_score_bouncing2dtracking"
	trackingChallenges.append(challenge20)
	
	Challenge challenge21
	challenge21.id = 9
	challenge21.name = "Horizontal Ball Tracking"
	challenge21.category = "TrackingChallenges"
	challenge21.bestScore = 0
	challenge21.clientScript = "StartCloseLongStrafesClient"
	challenge21.videoAsset = $"media/flowstate/aimtrainer/horizontalballtracking.bik"
	challenge21.isNew = true
	challenge21.maxScoreConVar = "fs_aimtrainer_challenge_max_score_horizontalballtracking"
	trackingChallenges.append(challenge21)
	
	//Clicking challenges
	Challenge challenge8
	challenge8.id = 0
	challenge8.name = "Arc Stars Practice"
	challenge8.category = "ClickingChallenges"
	challenge8.bestScore = 0
	challenge8.clientScript = "StartChallenge2NewCClient"
	challenge8.videoAsset = $"media/flowstate/aimtrainer/arcstarspractice.bik"
	challenge8.isNew = false
	challenge8.maxScoreConVar = "fs_aimtrainer_challenge_max_score_arcstarspractice"
	clickingChallenges.append(challenge8)
	
	Challenge challenge9
	challenge9.id = 1
	challenge9.name = "Grenades Practice"
	challenge9.category = "ClickingChallenges"
	challenge9.bestScore = 0
	challenge9.clientScript = "StartChallenge3NewCClient"
	challenge9.videoAsset = $"media/flowstate/aimtrainer/grenadespractice.bik"
	challenge9.isNew = false
	challenge9.maxScoreConVar = "fs_aimtrainer_challenge_max_score_grenadespractice"
	clickingChallenges.append(challenge9)
	
	Challenge challenge10
	challenge10.id = 2
	challenge10.name = "Tile Frenzy"
	challenge10.category = "ClickingChallenges"
	challenge10.bestScore = 0
	challenge10.clientScript = "StartChallenge5Client"
	challenge10.videoAsset = $"media/flowstate/aimtrainer/tilefrenzy.bik"
	challenge10.isNew = false
	challenge10.maxScoreConVar = "fs_aimtrainer_challenge_max_score_tilefrenzy"
	clickingChallenges.append(challenge10)
	
	Challenge challenge11
	challenge11.id = 3
	challenge11.name = "Floating Target"
	challenge11.category = "ClickingChallenges"
	challenge11.bestScore = 0
	challenge11.clientScript = "StartChallenge3Client"
	challenge11.videoAsset = $"media/flowstate/aimtrainer/floatingtarget.bik"
	challenge11.isNew = false
	challenge11.maxScoreConVar = "fs_aimtrainer_challenge_max_score_floatingtarget"
	clickingChallenges.append(challenge11)
	
	Challenge challenge17
	challenge17.id = 4
	challenge17.name = "1 Wall 6 Targets"
	challenge17.category = "ClickingChallenges"
	challenge17.bestScore = 0
	challenge17.clientScript = "Start1Wall6TargetsClient"
	challenge17.videoAsset = $"media/flowstate/aimtrainer/1wall6targets.bik"
	challenge17.isNew = true
	challenge17.maxScoreConVar = "fs_aimtrainer_challenge_max_score_1wall6targets"
	clickingChallenges.append(challenge17)
	
	Challenge challenge18
	challenge18.id = 5
	challenge18.name = "Tile Frenzy 3D"
	challenge18.category = "ClickingChallenges"
	challenge18.bestScore = 0
	challenge18.clientScript = "StartTileFrenzyStrafingClient"
	challenge18.videoAsset = $"media/flowstate/aimtrainer/tilefrenzy3d.bik"
	challenge18.isNew = true
	challenge18.maxScoreConVar = "fs_aimtrainer_challenge_max_score_tilefrenzy3d"
	clickingChallenges.append(challenge18)
	
	//Switching challenges
	Challenge challenge12
	challenge12.id = 0
	challenge12.name = "Target Switching"
	challenge12.category = "SwitchingChallenges"
	challenge12.bestScore = 0
	challenge12.clientScript = "StartChallenge2Client"
	challenge12.videoAsset = $"media/flowstate/aimtrainer/targetswitching.bik"
	challenge12.isNew = false
	challenge12.maxScoreConVar = "fs_aimtrainer_challenge_max_score_targetswitching"
	switchingChallenges.append(challenge12)
	
	Challenge challenge13
	challenge13.id = 1
	challenge13.name = "Armor Swap Trainer"
	challenge13.category = "SwitchingChallenges"
	challenge13.bestScore = 0
	challenge13.clientScript = "StartChallenge8NewCClient"
	challenge13.videoAsset = $"media/flowstate/aimtrainer/armorswaptrainer.bik"
	challenge13.isNew = false
	challenge13.maxScoreConVar = "fs_aimtrainer_challenge_max_score_armorswaptrainer"
	switchingChallenges.append(challenge13)
	
	Challenge challenge22
	challenge22.id = 2
	challenge22.name = "MultiBall Switching"
	challenge22.category = "SwitchingChallenges"
	challenge22.bestScore = 0
	challenge22.clientScript = "StartMultiBallHealthTrackingClient"
	challenge22.videoAsset = $"media/flowstate/aimtrainer/multiballhealthswitching.bik"
	challenge22.isNew = true
	challenge22.maxScoreConVar = "fs_aimtrainer_challenge_max_score_multiballswitching"
	switchingChallenges.append(challenge22)
	
	Challenge challenge23
	challenge23.id = 3
	challenge23.name = "MultiBall Switching Random Speed"
	challenge23.category = "SwitchingChallenges"
	challenge23.bestScore = 0
	challenge23.clientScript = "StartRandomSpeedTrackingClient"
	challenge23.videoAsset = $"media/flowstate/aimtrainer/randomspeedballhealthswitching.bik"
	challenge23.isNew = true
	challenge23.maxScoreConVar = "fs_aimtrainer_challenge_max_score_multiballswitchingrandomspeed"
	switchingChallenges.append(challenge23)
	
	//Movement challenges
	Challenge challenge14
	challenge14.id = 0
	challenge14.name = "Fast Jumps Strafes"
	challenge14.category = "MovementChallenges"
	challenge14.bestScore = 0
	challenge14.clientScript = "StartChallenge1NewCClient"
	challenge14.videoAsset = $"media/flowstate/aimtrainer/fastjumpsstrafes.bik"
	challenge14.isNew = false
	challenge14.maxScoreConVar = "fs_aimtrainer_challenge_max_score_fastjumpsstrafes"
	movementChallenges.append(challenge14)
	
	Challenge challenge15
	challenge15.id = 1
	challenge15.name = "Shooting From Lift"
	challenge15.category = "MovementChallenges"
	challenge15.bestScore = 0
	challenge15.clientScript = "StartChallenge5NewCClient"
	challenge15.videoAsset = $"media/flowstate/aimtrainer/shootingfromlift.bik"
	challenge15.isNew = false
	challenge15.maxScoreConVar = "fs_aimtrainer_challenge_max_score_shootingfromlift"
	movementChallenges.append(challenge15)
	
	Challenge challenge16
	challenge16.id = 2
	challenge16.name = "Bounces Simulator"
	challenge16.category = "MovementChallenges"
	challenge16.bestScore = 0
	challenge16.clientScript = "StartChallenge8Client"
	challenge16.videoAsset = $"media/flowstate/aimtrainer/bouncessimulator.bik"
	challenge16.isNew = false
	challenge16.maxScoreConVar = "fs_aimtrainer_challenge_max_score_bouncessimulator"
	movementChallenges.append(challenge16)
	
	Challenge challenge24
	challenge24.id = 3
	challenge24.name = "AntiMirror Strafing"
	challenge24.category = "MovementChallenges"
	challenge24.bestScore = 0
	challenge24.clientScript = "StartAntiMirrorStrafingClient"
	challenge24.videoAsset = $"media/flowstate/aimtrainer/antimirrorstrafing.bik"
	challenge24.isNew = true
	challenge24.maxScoreConVar = "fs_aimtrainer_challenge_max_score_antimirrorstrafing"
	movementChallenges.append(challenge24)
	
	Challenge challenge25
	challenge25.id = 4
	challenge25.name = "Mirror Strafing"
	challenge25.category = "MovementChallenges"
	challenge25.bestScore = 0
	challenge25.clientScript = "StartMirrorStrafingClient"
	challenge25.videoAsset = $"media/flowstate/aimtrainer/mirrorstrafing.bik"
	challenge25.isNew = true
	challenge25.maxScoreConVar = "fs_aimtrainer_challenge_max_score_mirrorstrafing"
	movementChallenges.append(challenge25)
}

//Challenge lookup functions for server/UI synchronization
Challenge ornull function GetChallengeByClientScript(string clientScript)
{
	//Search through all challenge arrays
	foreach(Challenge challenge in trackingChallenges)
	{
		if(challenge.clientScript == clientScript)
			return challenge
	}
	
	foreach(Challenge challenge in clickingChallenges)
	{
		if(challenge.clientScript == clientScript)
			return challenge
	}
	
	foreach(Challenge challenge in switchingChallenges)
	{
		if(challenge.clientScript == clientScript)
			return challenge
	}
	
	foreach(Challenge challenge in movementChallenges)
	{
		if(challenge.clientScript == clientScript)
			return challenge
	}
	
	return null
}

array<Challenge> function GetChallengesByCategoryName(string categoryName)
{
	switch(categoryName)
	{
		case "TrackingChallenges":
			return trackingChallenges
		case "ClickingChallenges":
			return clickingChallenges
		case "SwitchingChallenges":
			return switchingChallenges
		case "MovementChallenges":
			return movementChallenges
		case "AllChallenges":
			return GetAllChallengesFlattened()
		default:
			return []
	}
	
	unreachable
}

array<Challenge> function GetAllChallengesFlattened()
{
	//Update flattened array and return it
	allChallengesFlattened.clear()
	allChallengesFlattened.extend(trackingChallenges)
	allChallengesFlattened.extend(clickingChallenges)
	allChallengesFlattened.extend(switchingChallenges)
	allChallengesFlattened.extend(movementChallenges)
	return allChallengesFlattened
}

//Map server's legacy challenge IDs to shared Challenge structs
Challenge ornull function GetChallengeByLegacyServerId(int legacyId)
{
	switch(legacyId)
	{
		//Original Challenge Series (1-8)
		case 1: return trackingChallenges[0] // "Strafing Dummy"
		case 2: return switchingChallenges[0] // "Target Switching" 
		case 3: return clickingChallenges[3] // "Floating Target"
		case 4: return trackingChallenges[6] // "Popcorn Targets"
		case 10: return clickingChallenges[2] // "Tile Frenzy"
		case 11: return trackingChallenges[2] // "Close Fast Strafes"
		case 12: return trackingChallenges[4] // "Smoothbot"
		case 13: return trackingChallenges[6] // "Popcorn Targets" (variant)
		
		//New Challenge Series (1NewC-8NewC)
		case 6: return movementChallenges[0] // "Fast Jumps Strafes"
		case 7: return clickingChallenges[0] // "Arc Stars Practice"
		case 14: return clickingChallenges[1] // "Grenades Practice"
		case 9: return trackingChallenges[1] // "Shooting Valk's Ult"
		case 8: return movementChallenges[1] // "Shooting From Lift"
		case 15: return trackingChallenges[3] // "Skydiving Targets"
		case 16: return trackingChallenges[5] // "Running Targets"
		case 17: return switchingChallenges[1] // "Armor Swap Trainer"
		
		//Tracking Challenges (2025)
		case 18: return trackingChallenges[7] // "Pattern 2D Tracking"
		case 19: return trackingChallenges[8] // "Bouncing 2D Tracking"
		case 22: return switchingChallenges[2] // "MultiBall Switching"
		case 23: return switchingChallenges[3] // "MultiBall Switching Random Speed"
		case 24: return movementChallenges[3] // "AntiMirror Strafing"
		case 25: return movementChallenges[4] // "Mirror Strafing" or "Popcorn Physics"
		
		//Kovaaks Scenarios
		case 20: return clickingChallenges[4] // "1 Wall 6 Targets"
		case 21: return trackingChallenges[9] // "Horizontal Ball Tracking"
		//case 22: return clickingChallenges[5] // "Tile Frenzy 3D" - conflicts with MultiBall above
		
		default:
			return null
	}
	
	unreachable
}