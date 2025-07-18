global function Sh_ChallengesByColombia_Init

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

void function Sh_ChallengesByColombia_Init()
{
	// Time Over signal
	RegisterSignal("ChallengeTimeOver")
	RegisterSignal("ForceResultsEnd_SkipButton")
	PrecacheParticleSystem($"P_wpn_lasercannon_aim_short_blue")
}