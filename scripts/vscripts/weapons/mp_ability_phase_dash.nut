global function OnWeaponPrimaryAttack_ability_phase_dash
global function PhaseDash_GetDirectionFromInput
#if SERVER
global function OnWeaponNPCPrimaryAttack_ability_phase_dash
#endif

const float PHASE_DASH_SPEED_GROUND = 832.5
const float PHASE_DASH_SPEED_AIR = 500
const float PHASE_DASH_SPEED_POST_DASH = 90
const float PHASE_DASH_TIME = 0.4

var function OnWeaponPrimaryAttack_ability_phase_dash( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	//PlayWeaponSound( "fire" )
	entity player = weapon.GetWeaponOwner()

	float shiftTime = PHASE_DASH_TIME

	if ( IsAlive( player ) )
	{
		if ( player.IsPlayer() )
		{
			PlayerUsedOffhand( player, weapon )

			#if SERVER
				EmitSoundOnEntityExceptToPlayer( player, player, "Stryder.Dash" )
				thread PhaseDash( weapon, player )

				float fade = 0.125
				StatusEffect_AddTimed( player, eStatusEffect.move_slow, 0.6, shiftTime + fade, fade )
				StatusEffect_AddTimed( player, eStatusEffect.turn_slow, 1.0, shiftTime + fade, fade )

				thread PhaseDash_PostDashCleanUp( player, shiftTime + fade )
			#elseif CLIENT
				float xAxis = InputGetAxis( ANALOG_LEFT_X )
				float yAxis = InputGetAxis( ANALOG_LEFT_Y ) * -1
				vector angles = player.EyeAngles()
				vector directionForward = PhaseDash_GetDirectionFromInput( angles, xAxis, yAxis )
				if ( IsFirstTimePredicted() )
				{
					EmitSoundOnEntity( player, "Stryder.Dash" )
				}
			#endif
		}
		PhaseShift( player, 0, shiftTime, eShiftStyle.Dash )
	}
	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}

#if SERVER
var function OnWeaponNPCPrimaryAttack_ability_phase_dash( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return OnWeaponPrimaryAttack_ability_phase_dash( weapon, attackParams )
}

void function PhaseDash( entity weapon, entity player )
{
	float movestunEffect = 1.0 - StatusEffect_GetSeverity( player, eStatusEffect.dodge_speed_slow )
	float dashSpeed = player.IsOnGround() ? PHASE_DASH_SPEED_GROUND : PHASE_DASH_SPEED_AIR
	float moveSpeed = dashSpeed * movestunEffect
	PhaseDash_SetPlayerVelocityFromInput( player, moveSpeed, <0,0,200> )
}

void function PhaseDash_SetPlayerVelocityFromInput( entity player, float scale, vector baseVel = <0,0,0> )
{
	vector angles = player.EyeAngles()
	float xAxis = player.GetInputAxisRight()
	float yAxis = player.GetInputAxisForward()
	vector directionForward = PhaseDash_GetDirectionFromInput( angles, xAxis, yAxis )

	player.SetVelocity( directionForward * scale + baseVel )
}

void function PhaseDash_PostDashCleanUp( entity player, float duration )
{
	Assert( IsNewThread(), "Must be threaded off." )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )

	TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITIES_PHASE_DASH_START, player, player.GetOrigin(), player.GetTeam(), player )
	wait duration
	TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITIES_PHASE_DASH_STOP, player, player.GetOrigin(), player.GetTeam(), player )

	vector velNorm = Normalize( player.GetVelocity() )
	player.SetVelocity( velNorm * PHASE_DASH_SPEED_POST_DASH )
	player.SetCanBeAimAssistTrackedWhilePhased( false )

}
#endif

vector function PhaseDash_GetDirectionFromInput( vector playerAngles, float xAxis, float yAxis )
{
	playerAngles.x = 0
	playerAngles.z = 0
	vector forward = AnglesToForward( playerAngles )
	vector right = AnglesToRight( playerAngles )

	vector directionVec = <0,0,0>
	directionVec += right * xAxis
	directionVec += forward * yAxis

	vector directionAngles = directionVec == <0,0,0> ? playerAngles : VectorToAngles( directionVec )
	vector directionForward = AnglesToForward( directionAngles )

	return directionForward
}