global function MpWeaponRapidPistol_Init
global function OnWeaponActivate_weapon_rapidpistol
global function OnWeaponDeactivate_weapon_rapidpistol
global function OnWeaponPrimaryAttack_weapon_rapidpistol

//Rapid Pistol charge constants
const float RAPIDPISTOL_CHARGE_PER_MAG = 0.20		//20% charge per magazine (5 mags = 100%)
const float RAPIDPISTOL_DECAY_DELAY = 8.0			//8 seconds before decay starts
const float RAPIDPISTOL_DECAY_RATE = 0.15			//15% per second decay rate
const float RAPIDPISTOL_FULL_CHARGE = 1.0			//100% charge
const float RAPIDPISTOL_CHARGE_EPSILON = 0.01		//Small value for float comparison
const int RAPIDPISTOL_SHOTS_PER_CHARGE = 20		//Shots needed per charge level (one magazine)

//Charge level thresholds and corresponding mods (5 levels)
const array<float> RAPIDPISTOL_CHARGE_THRESHOLDS = [0.20, 0.40, 0.60, 0.80, 1.0]
const array<string> RAPIDPISTOL_CHARGE_MODS = ["rapidpistol_charge_1", "rapidpistol_charge_2", "rapidpistol_charge_3", "rapidpistol_charge_4", "rapidpistol_charge_5"]

struct RapidPistolData
{
	float chargeLevel = 0.0
	float lastFireTime = 0.0
	int currentChargeMod = -1
	int shotsForCharging = 0
	bool decayThreadRunning = false
}

struct{
	table<entity, RapidPistolData> rapidPistolDataTable
} file

void function MpWeaponRapidPistol_Init()
{
	#if DEVELOPER
		printt("[RAPIDPISTOL] Rapid Pistol weapon system initialized")
	#endif
}

void function OnWeaponActivate_weapon_rapidpistol( entity weapon )
{
	#if DEVELOPER
		printt("[RAPIDPISTOL] Weapon activated")
	#endif
	
	//Initialize rapid pistol data if not already present (preserves charge on re-equip)
	if ( !(weapon in file.rapidPistolDataTable) )
	{
		RapidPistolData rapidPistolData
		file.rapidPistolDataTable[weapon] <- rapidPistolData
	}
	
	//Start charge decay monitoring (SERVER ONLY, once per weapon)
	#if SERVER
	RapidPistolData rapidPistolData = file.rapidPistolDataTable[weapon]
	if ( !rapidPistolData.decayThreadRunning )
	{
		RemoveAllChargeMods( weapon ) //Required to avoid crash if charge mods were transferred to a dropped weapon
		
		rapidPistolData.decayThreadRunning = true
		thread RapidPistolChargeDecayThink( weapon )
	}
	#endif
}

void function OnWeaponDeactivate_weapon_rapidpistol( entity weapon )
{
	#if DEVELOPER
		printt("[RAPIDPISTOL] Weapon deactivated")
	#endif
	
	//Shouldn't remove the charges on weapon deactivate, it should be only on decay
	//RemoveAllChargeMods( weapon )
}

var function OnWeaponPrimaryAttack_weapon_rapidpistol( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity owner = weapon.GetOwner()
	if ( !IsValid(owner) )
		return 0
	
	//Get rapid pistol data from table
	if ( !(weapon in file.rapidPistolDataTable) )
		return 0
	
	RapidPistolData rapidPistolData = file.rapidPistolDataTable[weapon]
	
	//Increment shot counter for charging
	rapidPistolData.shotsForCharging++
	rapidPistolData.lastFireTime = Time()
	
	#if DEVELOPER
		printt("[RAPIDPISTOL] Shot fired, shots for charging:", rapidPistolData.shotsForCharging, "charge level:", rapidPistolData.chargeLevel)
	#endif
	
	weapon.FireWeapon_Default( attackParams.pos, attackParams.dir, 1.0, 1.0, false )
	
	//Check if we should add charge (SERVER ONLY for charge calculation)
	#if SERVER
	if ( rapidPistolData.shotsForCharging >= RAPIDPISTOL_SHOTS_PER_CHARGE )
	{
		//Add charge every magazine (20 shots)
		float oldCharge = rapidPistolData.chargeLevel
		rapidPistolData.chargeLevel += RAPIDPISTOL_CHARGE_PER_MAG
		
		//Cap at maximum charge
		if ( rapidPistolData.chargeLevel > RAPIDPISTOL_FULL_CHARGE )
			rapidPistolData.chargeLevel = RAPIDPISTOL_FULL_CHARGE
		
		//Reset shot counter
		rapidPistolData.shotsForCharging = 0
		
		#if DEVELOPER
			printt("[RAPIDPISTOL] Charge added:", oldCharge, "->", rapidPistolData.chargeLevel)
		#endif
		
		//Update charge mod
		UpdateChargeMod( weapon )
	}
	#endif // SERVER
	
	//Use default attack behavior
	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}

#if SERVER
void function RapidPistolChargeDecayThink( entity weapon )
{
	weapon.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( weapon )
		{
			if ( weapon in file.rapidPistolDataTable )
				delete file.rapidPistolDataTable[weapon]
		}
	)

	while ( IsValid(weapon) )
	{
		//Check if weapon is still in the table
		if ( !(weapon in file.rapidPistolDataTable) )
		{
			WaitFrame()
			continue
		}
		
		RapidPistolData rapidPistolData = file.rapidPistolDataTable[weapon]
		
		//Check if enough time has passed since last fire for decay to start
		float timeSinceLastFire = Time() - rapidPistolData.lastFireTime
		
		if ( timeSinceLastFire >= RAPIDPISTOL_DECAY_DELAY && rapidPistolData.chargeLevel > 0.0 )
		{
			float oldCharge = rapidPistolData.chargeLevel
			
			//Decay charge at 15% per second
			float decayAmount = RAPIDPISTOL_DECAY_RATE * 1.0	//1 second frame
			rapidPistolData.chargeLevel -= decayAmount
			
			//Don't go below 0
			if ( rapidPistolData.chargeLevel < 0.0 )
				rapidPistolData.chargeLevel = 0.0
			
			#if DEVELOPER
				if ( oldCharge != rapidPistolData.chargeLevel )
					printt("[RAPIDPISTOL] Charge decayed:", oldCharge, "->", rapidPistolData.chargeLevel)
			#endif
			
			//Update charge mod if charge level changed significantly
			if ( fabs(oldCharge - rapidPistolData.chargeLevel) > RAPIDPISTOL_CHARGE_EPSILON )
				UpdateChargeMod( weapon )
		}
		
		wait 1.0	//Check every second for decay
	}
}

void function UpdateChargeMod( entity weapon )
{
	if ( !IsValid(weapon) )
		return
	
	//Get rapid pistol data from table
	if ( !(weapon in file.rapidPistolDataTable) )
		return
	
	RapidPistolData rapidPistolData = file.rapidPistolDataTable[weapon]
	int newChargeMod = GetChargeModIndex( rapidPistolData.chargeLevel )
	
	//Only update if charge mod changed
	if ( newChargeMod != rapidPistolData.currentChargeMod )
	{
		//Remove old charge mod
		if ( rapidPistolData.currentChargeMod >= 0 && rapidPistolData.currentChargeMod < RAPIDPISTOL_CHARGE_MODS.len() )
		{
			string oldMod = RAPIDPISTOL_CHARGE_MODS[rapidPistolData.currentChargeMod]
			if ( weapon.HasMod(oldMod) )
			{
				weapon.RemoveMod( oldMod )
				#if DEVELOPER
					printt("[RAPIDPISTOL] Removed charge mod:", oldMod)
				#endif
			}
		}
		
		//Apply new charge mod
		if ( newChargeMod >= 0 && newChargeMod < RAPIDPISTOL_CHARGE_MODS.len() )
		{
			string newMod = RAPIDPISTOL_CHARGE_MODS[newChargeMod]
			weapon.AddMod( newMod )
			
			#if DEVELOPER
				printt("[RAPIDPISTOL] Applied charge mod:", newMod, "at charge level:", rapidPistolData.chargeLevel)
			#endif
		}
		
		rapidPistolData.currentChargeMod = newChargeMod
	}
}

int function GetChargeModIndex( float chargeLevel )
{
	//Return -1 for no mod (base state)
	if ( chargeLevel < RAPIDPISTOL_CHARGE_THRESHOLDS[0] )
		return -1
	
	//Find the appropriate charge mod based on charge level
	for ( int i = RAPIDPISTOL_CHARGE_THRESHOLDS.len() - 1; i >= 0; i-- )
	{
		if ( chargeLevel >= RAPIDPISTOL_CHARGE_THRESHOLDS[i] )
			return i
	}
	
	return -1
}

void function RemoveAllChargeMods( entity weapon )
{
	if ( !IsValid(weapon) )
		return
	
	foreach ( string mod in RAPIDPISTOL_CHARGE_MODS )
	{
		if ( weapon.HasMod(mod) )
		{
			weapon.RemoveMod( mod )
			#if DEVELOPER
				printt("[RAPIDPISTOL] Removed charge mod during cleanup:", mod)
			#endif
		}
	}
}
#endif