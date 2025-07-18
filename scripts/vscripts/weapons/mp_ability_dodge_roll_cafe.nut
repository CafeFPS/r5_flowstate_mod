//S0 Dev Proto
//modified by @CafeFPS

global function OnWeaponAttemptOffhandSwitch_ability_dodge_roll_v2
global function OnWeaponPrimaryAttack_ability_dodge_roll_v2

const float DODGE_ROLL_SPEED_GROUND = 650
const float DODGE_ROLL_SPEED_AIR = 500
const float DODGE_ROLL_SPEED_POST_DASH = 90
const float DODGE_ROLL_TIME = 0.5
const float DODGE_ROLL_CLOAK_TIME = 1.0

bool function OnWeaponAttemptOffhandSwitch_ability_dodge_roll_v2( entity weapon )
{
	int ammoReq  = weapon.GetAmmoPerShot()
	int currAmmo = weapon.GetWeaponPrimaryClipCount()
	if ( currAmmo < ammoReq )
		return false

	entity player = weapon.GetWeaponOwner()

	if ( !IsValid( player ) )
		return false

	//Can't roll in air
	//if ( !player.IsOnGround() )
	//	return false

	return true
}

var function OnWeaponPrimaryAttack_ability_dodge_roll_v2( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	//PlayWeaponSound( "fire" )
	entity player = weapon.GetWeaponOwner()

	if ( IsAlive( player ) )
	{
		if ( player.IsPlayer() )
		{
			PlayerUsedOffhand( player, weapon )

			#if SERVER
				EmitSoundOnEntityExceptToPlayer( player, player, "titan_phasedash_end_3p" )
				thread DodgeRoll_Attempt( weapon, player )
			#elseif CLIENT
				float xAxis = InputGetAxis( ANALOG_LEFT_X )
				float yAxis = InputGetAxis( ANALOG_LEFT_Y ) * -1
				vector angles = player.EyeAngles()
				vector directionForward = PhaseDash_GetDirectionFromInput( angles, xAxis, yAxis )
				if ( IsFirstTimePredicted() )
				{
					EmitSoundOnEntity( player, "titan_phasedash_end_3p" )
				}
			#endif
		}
	}
	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}

#if SERVER
void function DodgeRoll_Attempt( entity weapon, entity player )
{
	float dashSpeed = player.IsOnGround() ? DODGE_ROLL_SPEED_GROUND : DODGE_ROLL_SPEED_AIR
	float moveSpeed = dashSpeed
	DodgeRoll_SetPlayerVelocityFromInput( player, moveSpeed, <0,0,200> )
}

void function DodgeRoll_SetPlayerVelocityFromInput( entity player, float scale, vector baseVel = <0,0,0> )
{
	vector angles = player.EyeAngles()
	float xAxis = player.GetInputAxisRight()
	float yAxis = player.GetInputAxisForward()
	vector directionForward = PhaseDash_GetDirectionFromInput( angles, xAxis, yAxis )

	thread DodgeRoll_PostRollCleanUp( player, DODGE_ROLL_TIME )
	player.SetVelocity( directionForward * scale + baseVel )
}

void function DodgeRoll_PostRollCleanUp( entity player, float duration )
{
	Assert( IsNewThread(), "Must be threaded off." )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )

	// player.HolsterWeapon()
	if( !player.IsInputCommandHeld( IN_DUCK ) )
		player.ForceCrouch()
	
	// if( !IsCloaked( player ) )
		// player.SetCloakDuration( 0.0, duration, 0.0 )
	
	PhaseShift( player, 0, 0.5 )
	
	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid( player ) )
			{
				// player.DeployWeapon()
				player.UnforceCrouch()
				player.UnforceStand()
				StatusEffect_StopAllOfType( player, eStatusEffect.move_slow )
			}
		}
	)

	bool wasStanding = player.IsStanding()

	wait duration

	// if ( player.IsOnGround() )
	// {
		// vector velNorm = Normalize( player.GetVelocity() )
		// player.SetVelocity( velNorm * DODGE_ROLL_SPEED_POST_DASH )
	// }

	// player.SetCanBeAimAssistTrackedWhilePhased( true )

	if ( wasStanding && !player.IsInputCommandHeld( IN_DUCK ) )
		player.ForceStand()

	WaitFrame()

}
#endif