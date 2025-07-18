global function MpSpaceElevatorAbility_Init
global function OnProjectileCollision_lift
global function Lift_OnWeaponTossRelease

#if SERVER
global function CreateLiftAtOrigin
global function CreateLockoutLiftAtOrigin
#endif

//used
const float SPACEELEVATOR_TUNING_RADIUS = 70
const int SPACEELEVATOR_TUNING_HEIGHT = 1200
const float SPACEELEVATOR_TUNING_LIFETIME = 10
const float SPACEELEVATOR_TUNING_UP_SPEED = 340
const float SPACEELEVATOR_TUNING_HORIZ_SPEED = 170
const float SPACEELEVATOR_TUNING_EJECT_UP_SPEED = 450
const float SPACEELEVATOR_TUNING_EJECT_HORIZ_SPEED = 400
const float SPACEELEVATOR_TUNING_MAX_HOVER_TIME = 2.0
const float SPACEELEVATOR_TUNING_TO_CENTER_SPEED = 50
const float SPACEELEVATOR_TUNING_MAX_EJECT_TIME = 0.5
const float SPACEELEVATOR_TUNING_AWAY_FROM_CENTER_DIST = 40

const float SPACEELEVATOR_AIRSPEED = 80
const float SPACEELEVATOR_AIRACCEL = 800
//unused, implement at some point when we figure what they do lol
const float SPACEELEVATOR_TUNING_HORIZ_ACCEL = 2000
const float SPACEELEVATOR_TUNING_TO_CENTER_ACCEL = 0
const float SPACEELEVATOR_TUNING_INPUT_THRESHOLD = 0.2
const float SPACEELEVATOR_TUNING_PLAYER_VIEWPOINT_OFFSET = 33
const float SPACEELEVATOR_TUNING_HOVER_HEIGHT_PCT = 0.9
const float SPACEELEVATOR_TUNING_KEEP_ALIVE_MAX_TIME = 5

//Lockout
const int LOCKOUTLIFT_TUNING_HEIGHT = 500
const float LOCKOUTLIFT_TUNING_RADIUS = 70
const float LOCKOUTLIFT_TUNING_EJECT_UP_SPEED = 250
const float LOCKOUTLIFT_TUNING_EJECT_HORIZ_SPEED = 200

//maki script
array<entity> doubleCheck 
//maki script
void function MpSpaceElevatorAbility_Init()
{
	PrecacheParticleSystem( $"P_s2s_flap_wind" )
	PrecacheParticleSystem( $"P_wpn_BBunker_beam" )
	PrecacheParticleSystem( $"P_wpn_BBunker_beam_end" )
	
	RegisterSignal( "FS_ForceDestroyAllLifts" )
	RegisterSignal( "FS_EndGoingUpThreadForcedly" )
}

var function Lift_OnWeaponTossRelease( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	#if SERVER
	var result = Lift_OnWeaponToss( weapon, attackParams, 1.0 )
	return result
	#endif
}

int function Lift_OnWeaponToss( entity weapon, WeaponPrimaryAttackParams attackParams, float directionScale )
{
	weapon.EmitWeaponSound_1p3p( GetGrenadeThrowSound_1p( weapon ), GetGrenadeThrowSound_3p( weapon ) )
	bool projectilePredicted = PROJECTILE_PREDICTED
	bool projectileLagCompensated = PROJECTILE_LAG_COMPENSATED
#if SERVER
	if ( weapon.IsForceReleaseFromServer() )
	{
		projectilePredicted = false
		projectileLagCompensated = false
	}
#endif
	entity grenade = Lift_Launch( weapon, attackParams.pos, (attackParams.dir * directionScale), projectilePredicted, projectileLagCompensated )
	entity weaponOwner = weapon.GetWeaponOwner()
	weaponOwner.Signal( "ThrowGrenade" )

	PlayerUsedOffhand( weaponOwner, weapon, true, grenade ) // intentionally here and in Hack_DropGrenadeOnDeath - accurate for when cooldown actually begins

	if ( IsValid( grenade ) )
		grenade.proj.savedDir = weaponOwner.GetViewForward()

#if SERVER
	#if BATTLECHATTER_ENABLED
		TryPlayWeaponBattleChatterLine( weaponOwner, weapon )
	#endif
#endif

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}

entity function Lift_Launch( entity weapon, vector attackPos, vector throwVelocity, bool isPredicted, bool isLagCompensated )
{
	//TEMP FIX while Deploy anim is added to sprint
	float currentTime = Time()
	if ( weapon.w.startChargeTime == 0.0 )
		weapon.w.startChargeTime = currentTime

	// Note that fuse time of 0 means the grenade won't explode on its own, instead it depends on OnProjectileCollision() functions to be defined and explode there.
	float fuseTime = weapon.GetGrenadeFuseTime()
	bool startFuseOnLaunch = bool( weapon.GetWeaponInfoFileKeyField( "start_fuse_on_launch" ) )

	if ( fuseTime > 0 && !startFuseOnLaunch )
	{
		fuseTime = fuseTime - ( currentTime - weapon.w.startChargeTime )
		if ( fuseTime <= 0 )
			fuseTime = 0.001
	}

	// NOTE: DO NOT apply randomness to angularVelocity, it messes up lag compensation
	// KNOWN ISSUE: angularVelocity is applied relative to the world, so currently the projectile spins differently based on facing angle
	vector angularVelocity = <10, -1600, 10>

	int damageFlags = weapon.GetWeaponDamageFlags()
	WeaponFireGrenadeParams fireGrenadeParams
	fireGrenadeParams.pos = attackPos
	fireGrenadeParams.vel = throwVelocity
	fireGrenadeParams.angVel = angularVelocity
	fireGrenadeParams.fuseTime = fuseTime
	fireGrenadeParams.scriptTouchDamageType = (damageFlags & ~DF_EXPLOSION) // when a grenade "bonks" something, that shouldn't count as explosive.explosive
	fireGrenadeParams.scriptExplosionDamageType = damageFlags
	fireGrenadeParams.clientPredicted = isPredicted
	fireGrenadeParams.lagCompensated = isLagCompensated
	fireGrenadeParams.useScriptOnDamage = true
	entity frag = weapon.FireWeaponGrenade( fireGrenadeParams )
	if ( frag == null )
		return null

	#if SERVER
		entity owner = weapon.GetWeaponOwner()
		if ( IsValid( owner ) )
		{
			if ( IsWeaponOffhand( weapon ) )
			{
				AddToUltimateRealm( owner, frag )
			}
			else
			{
				frag.RemoveFromAllRealms()
				frag.AddToOtherEntitysRealms( owner )
			}
		}

		//HolsterAndDisableWeapons( owner )
        //owner.ForceStand()
	#endif

	Lift_OnPlayerNPCTossGrenade_Common( weapon, frag )

	return frag
}

void function Lift_OnPlayerNPCTossGrenade_Common( entity weapon, entity frag )
{
	#if SERVER
		thread TrapExplodeOnDamage( frag, 20, 0.0, 0.0 )
		
		string projectileSound = GetGrenadeProjectileSound( weapon )
		if ( projectileSound != "" )
			EmitSoundOnEntity( frag, projectileSound )

		entity fxID = StartParticleEffectOnEntity_ReturnEntity( frag, GetParticleSystemIndex( $"P_ar_holopilot_trail" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
		entity fxID2 = StartParticleEffectOnEntity_ReturnEntity( frag, GetParticleSystemIndex( $"P_ar_holopilot_trail" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )

	#endif
}

void function OnProjectileCollision_lift( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	entity player = projectile.GetOwner()
	
	if ( IsValid(hitEnt) && hitEnt.IsPlayer() )
		return

	if ( projectile.GrenadeHasIgnited() )
		return

	table collisionParams =
	{
		pos = pos,
		normal = normal,
		hitEnt = hitEnt,
		hitbox = hitbox
	}

	#if SERVER
	bool result = PlantStickyEntityOnWorldThatBouncesOffWalls( projectile, collisionParams, 0.7 )
	
	projectile.proj.projectileBounceCount++
	
	if ( !result && projectile.proj.projectileBounceCount < 3 )
		return
	else
	{
		CreateLiftAtOrigin( pos, projectile )
	}
	#endif
}

#if SERVER
void function CreateLiftAtOrigin( vector pos, entity projectile = null, bool neverDies = false )
{
	entity bottom = CreateEntity( "trigger_cylinder" )
	bottom.SetRadius( SPACEELEVATOR_TUNING_RADIUS )
	bottom.SetAboveHeight( SPACEELEVATOR_TUNING_HEIGHT )
	bottom.SetBelowHeight( 0 )
	bottom.SetOrigin( pos )
	bottom.SetEnterCallback( BottomEnterCallback )
	bottom.SetLeaveCallback( BottomLeaveCallback )

	DispatchSpawn( bottom )
	bottom.SearchForNewTouchingEntity()

	entity top = CreateEntity( "trigger_cylinder" )
	top.SetRadius( SPACEELEVATOR_TUNING_RADIUS )
	top.SetAboveHeight( 256 )
	top.SetBelowHeight( 0 )
	top.SetOrigin( pos + <0, 0, SPACEELEVATOR_TUNING_HEIGHT*0.935> )
	top.SetEnterCallback( TopEnterCallback )
	DispatchSpawn( top )
	top.SearchForNewTouchingEntity()
	
	if(IsValid(projectile))
	{
		bottom.RemoveFromAllRealms()
		top.RemoveFromAllRealms()
		bottom.AddToOtherEntitysRealms( projectile )
		top.AddToOtherEntitysRealms( projectile )
		projectile.Destroy()
	}
	if(IsValid(bottom) && IsValid(top))
		thread LiftWatcher(bottom, top, pos, neverDies )
}

void function CreateLockoutLiftAtOrigin( vector pos, entity projectile = null, bool neverDies = false )
{
	entity bottom = CreateEntity( "trigger_cylinder" )
	bottom.SetRadius( LOCKOUTLIFT_TUNING_RADIUS )
	bottom.SetAboveHeight( LOCKOUTLIFT_TUNING_HEIGHT )
	bottom.SetBelowHeight( 0 )
	bottom.SetOrigin( pos )
	bottom.SetEnterCallback( Lockout_BottomEnterCallback )
	bottom.SetLeaveCallback( Lockout_BottomLeaveCallback )	
	DispatchSpawn( bottom )
	bottom.SearchForNewTouchingEntity()

	if(IsValid(projectile))
	{
		bottom.RemoveFromAllRealms()
		bottom.AddToOtherEntitysRealms( projectile )
		projectile.Destroy()
	}
	if( IsValid(bottom) )
		thread LockoutLiftWatcher(bottom, pos, neverDies )
}

void function TopEnterCallback(entity trigger, entity ent)
{
	if ( IsValid(ent) && !ent.IsPlayer() )
		return
	
	thread StartTopTriggerTimer(trigger, ent)

}

void function StartTopTriggerTimer(entity trigger, entity ent)
{
	float endTime = Time() + SPACEELEVATOR_TUNING_MAX_HOVER_TIME
	
	OnThreadEnd(
		function() : ( trigger, ent )
		{
			if(IsValid(trigger) && IsValid(ent) && trigger.IsTouching(ent) && ent.IsPlayer())
			{
				ent.p.ForceEject = true
				vector direction = AnglesToForward( ent.GetAngles() )
				
				if(ent.GetInputAxisForward() != 0 || ent.GetInputAxisRight() != 0)
				direction = AnglesToForward(ent.GetAngles())*signum(ent.GetInputAxisForward()) + AnglesToRight(ent.GetAngles())*signum(ent.GetInputAxisRight())

				vector up = AnglesToUp( ent.GetAngles() )
				vector velocity = (direction *  SPACEELEVATOR_TUNING_EJECT_HORIZ_SPEED) + (up*SPACEELEVATOR_TUNING_EJECT_UP_SPEED)
				FallTempAirControl(ent)	
				ent.SetVelocity( velocity )
			}
				
		}
	)
	
	while(Time() <= endTime && IsValid(ent) && IsValid(trigger))
		WaitFrame()

	wait SPACEELEVATOR_TUNING_MAX_EJECT_TIME
}

void function BottomEnterCallback( entity trigger, entity ent )
{
	if ( !ent.IsPlayer() )
		return

	ent.SetVelocity( Vector( 0,0,0 ) )
	ent.Zipline_Stop()
	ent.GrappleDetach()
	ent.ClearTraverse()

	//maki script
	if(!( doubleCheck.contains(ent)))
		doubleCheck.append(ent)
	//maki script
	entity weapon = ent.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_0 )
	if(IsValid(weapon))
	{
		array<string> mods = weapon.GetMods()	
		mods.append( "elevator_shooter" )
		try{weapon.SetMods( mods )} catch(e42069){printt(weapon.GetWeaponClassName() + " failed to remove elevator_shooter mod. DEBUG THIS.")}
	}
	
	entity weapon2 = ent.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_1 )
	if(IsValid(weapon2))
	{
		array<string> mods = weapon2.GetMods()	
		mods.append( "elevator_shooter" )
		try{weapon2.SetMods( mods )} catch(e42069){printt(weapon2.GetWeaponClassName() + " failed to remove elevator_shooter mod. DEBUG THIS.")}
	}
	thread PlayerOnLiftMovement(trigger, ent)
}

void function BottomLeaveCallback( entity trigger, entity ent )
{
	if ( !IsValid(ent) || !ent.IsPlayer() || ent.p.ForceEject )
		return

	Signal( ent, "FS_EndGoingUpThreadForcedly" )

	entity weapon = ent.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_0 )
	if(IsValid(weapon))
	{
		array<string> mods = weapon.GetMods()	
		mods.removebyvalue("elevator_shooter")
		try{weapon.SetMods( mods )} catch(e42069){printt(weapon.GetWeaponClassName() + " failed to remove elevator_shooter mod. DEBUG THIS.")}
	}
	
	entity weapon2 = ent.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_1 )
	if(IsValid(weapon2))
	{
		array<string> mods = weapon2.GetMods()	
		mods.removebyvalue("elevator_shooter")
		try{weapon2.SetMods( mods )} catch(e42069){printt(weapon2.GetWeaponClassName() + " failed to remove elevator_shooter mod. DEBUG THIS.")}
	}

	vector direction = AnglesToForward( ent.GetAngles() )
	
					
	if(ent.GetInputAxisForward() != 0 || ent.GetInputAxisRight() != 0)
		direction = AnglesToForward(ent.GetAngles())*signum(ent.GetInputAxisForward()) + AnglesToRight(ent.GetAngles())*signum(ent.GetInputAxisRight())

	vector up = AnglesToUp( ent.GetAngles() )
	vector velocity = (direction *  SPACEELEVATOR_TUNING_EJECT_HORIZ_SPEED) + (up*SPACEELEVATOR_TUNING_EJECT_UP_SPEED)
	FallTempAirControl(ent)
	ent.SetVelocity( velocity )
}


void function Lockout_BottomEnterCallback( entity trigger, entity ent )
{
	if ( !ent.IsPlayer() )
		return

	thread LockoutPlayerOnLiftMovement(trigger, ent)
}

void function Lockout_BottomLeaveCallback( entity trigger, entity ent )
{
	if ( !IsValid(ent) || !ent.IsPlayer() )
		return

	vector direction = AnglesToForward( ent.GetAngles() )

	if(ent.GetInputAxisForward() != 0 || ent.GetInputAxisRight() != 0)
		direction = AnglesToForward(ent.GetAngles())*signum(ent.GetInputAxisForward()) + AnglesToRight(ent.GetAngles())*signum(ent.GetInputAxisRight())

	vector up = AnglesToUp( ent.GetAngles() )
	vector velocity = (direction *  LOCKOUTLIFT_TUNING_EJECT_HORIZ_SPEED) + (up*LOCKOUTLIFT_TUNING_EJECT_UP_SPEED)
	//FallTempAirControl(ent)
	ent.SetVelocity( velocity )
}

void function LiftWatcher( entity bottom, entity top, vector pos, bool neverDies = false )
{
	float UPVELOCITY
	float endTime = Time() + SPACEELEVATOR_TUNING_LIFETIME
	EndSignal( svGlobal.levelEnt, "FS_ForceDestroyAllLifts" )

	array<entity> visuals
	
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
	visuals.append(circle)

	for(int i=0; i<1200-128; i+=128)
	{
		entity fx = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( $"P_s2s_flap_wind" ), pos + <0, 0, i>, Vector(-90,0,0) )
		visuals.append(fx)
		EmitSoundOnEntity(fx, "HoverTank_Emit_EdgeWind") //!FIXME
		WaitFrame()
	}
	//DebugDrawCylinder( pos, Vector(-90,0,0), 70, 1200, 100, 0, 0, true, SPACEELEVATOR_TUNING_LIFETIME)

	OnThreadEnd(
		function() : ( bottom, top, visuals )
		{
			foreach(ent in bottom.GetTouchingEntities())
				{
					if( !IsValid(ent) || IsValid(ent) && !ent.IsPlayer() ) continue
					
					ent.p.ForceEject = true
					vector direction = AnglesToForward( ent.GetAngles() )
					
					if(ent.GetInputAxisForward() != 0 || ent.GetInputAxisRight() != 0)
					direction = AnglesToForward(ent.GetAngles())*signum(ent.GetInputAxisForward()) + AnglesToRight(ent.GetAngles())*signum(ent.GetInputAxisRight())

					vector up = AnglesToUp( ent.GetAngles() )
					vector velocity = (direction *  SPACEELEVATOR_TUNING_EJECT_HORIZ_SPEED) + (up*SPACEELEVATOR_TUNING_EJECT_UP_SPEED)
					FallTempAirControl(ent)
					ent.SetVelocity( velocity )					
				}

			foreach(ent in visuals)			
			{
				if(IsValid(ent))
					{
					//maki script
					foreach (player in doubleCheck)
					{
						if(!IsValid(player)) continue
						player.kv.gravity = 1.0
						player.kv.airSpeed = 80 //horizon value
						player.kv.airAcceleration = 800 //horizon value
						RemovePlayerMovementEventCallback( player, ePlayerMovementEvents.TOUCH_GROUND, OnPlayerTouchGround )
						AddPlayerMovementEventCallback( player, ePlayerMovementEvents.TOUCH_GROUND, OnPlayerTouchGround )
						player.p.ForceEject = false
					}
					//maki script
					ent.Destroy()
					}
			}
			if(IsValid(bottom)) bottom.Destroy()
			if(IsValid(top)) top.Destroy()
		}
	)
	
	if( neverDies )
	{
		while( IsValid(bottom) )
			WaitFrame()
	} else
	{
		while( Time() <= endTime && IsValid(bottom) )
			WaitFrame()
	}
}

void function LockoutLiftWatcher( entity bottom, vector pos, bool neverDies = false )
{
	float UPVELOCITY
	float endTime = Time() + SPACEELEVATOR_TUNING_LIFETIME
	EndSignal( svGlobal.levelEnt, "FS_ForceDestroyAllLifts" )

	array<entity> visuals
	
	//Circle on ground FX
	entity circle = CreateEntity( "prop_script" )
	circle.SetValueForModelKey( $"mdl/weapons_r5/weapon_tesla_trap/mp_weapon_tesla_trap_ar_trigger_radius.rmdl" )
	circle.kv.fadedist = 30000
	circle.kv.renderamt = 0
	circle.kv.rendercolor = "34, 27, 245"
	circle.kv.modelscale = 0.20
	circle.kv.solid = 0
	circle.SetOrigin( pos + <0.0, 0.0, -25>)
	circle.SetAngles( <0, 0, 0> )
	circle.NotSolid()
	DispatchSpawn(circle)
	visuals.append(circle)

	for(int i=0; i<LOCKOUTLIFT_TUNING_HEIGHT-128; i+=128)
	{
		entity fx = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( $"P_s2s_flap_wind" ), pos + <0, 0, i>, Vector(-90,0,0) )
		visuals.append(fx)
		EmitSoundOnEntity(fx, "HoverTank_Emit_EdgeWind") //!FIXME
		WaitFrame()
	}
	//DebugDrawCylinder( pos, Vector(-90,0,0), 70, 1200, 100, 0, 0, true, SPACEELEVATOR_TUNING_LIFETIME)

	OnThreadEnd(
		function() : ( bottom, visuals )
		{
			foreach(ent in bottom.GetTouchingEntities())
				{
					if( !IsValid(ent) || IsValid(ent) && !ent.IsPlayer() ) continue
					
					ent.p.ForceEject = true
					vector direction = AnglesToForward( ent.GetAngles() )
					
					if(ent.GetInputAxisForward() != 0 || ent.GetInputAxisRight() != 0)
					direction = AnglesToForward(ent.GetAngles())*signum(ent.GetInputAxisForward()) + AnglesToRight(ent.GetAngles())*signum(ent.GetInputAxisRight())

					vector up = AnglesToUp( ent.GetAngles() )
					vector velocity = (direction *  SPACEELEVATOR_TUNING_EJECT_HORIZ_SPEED) + (up*SPACEELEVATOR_TUNING_EJECT_UP_SPEED)
					FallTempAirControl(ent)
					ent.SetVelocity( velocity )					
				}

			foreach(ent in visuals)			
			{
				if(IsValid(ent))
					{
					//maki script
					foreach (player in doubleCheck)
					{
						if(!IsValid(player)) continue
						player.kv.gravity = 1.0
						player.kv.airSpeed = SPACEELEVATOR_AIRSPEED //horizon value
						player.kv.airAcceleration = SPACEELEVATOR_AIRACCEL //horizon value
						RemovePlayerMovementEventCallback( player, ePlayerMovementEvents.TOUCH_GROUND, OnPlayerTouchGround )
						AddPlayerMovementEventCallback( player, ePlayerMovementEvents.TOUCH_GROUND, OnPlayerTouchGround )
						player.p.ForceEject = false
					}
					//maki script
					ent.Destroy()
					}
			}
			if(IsValid(bottom)) bottom.Destroy()
		}
	)
	
	if( neverDies )
	{
		while( IsValid(bottom) )
			WaitFrame()
	} else
	{
		while( Time() <= endTime && IsValid(bottom) )
			WaitFrame()
	}
}

void function PlayerOnLiftMovement(entity bottom, entity player)
{
	EndSignal( player, "OnDeath" )
	EndSignal( bottom, "OnDestroy")
	EndSignal( player, "FS_EndGoingUpThreadForcedly" )

	OnThreadEnd(
		function() : ( player )
		{
			IsValid( player )
			{
				player.kv.gravity = 1
			}
		}
	)

	while( IsValid(bottom) && IsValid(player) && bottom.IsTouching(player)  )
	{
		player.kv.gravity = 0.00001
		float UPVELOCITY

		if(GetPlayerElevatorProgress(bottom, player) <= 0.935)
			UPVELOCITY = SPACEELEVATOR_TUNING_UP_SPEED
		else
			UPVELOCITY = SPACEELEVATOR_TUNING_AWAY_FROM_CENTER_DIST

		vector newVelocity
		
		if(player.GetInputAxisForward() != 0 || player.GetInputAxisRight() != 0)
			newVelocity = (AnglesToForward(player.GetAngles())*signum(player.GetInputAxisForward()) + AnglesToRight(player.GetAngles())*signum(player.GetInputAxisRight()))*SPACEELEVATOR_TUNING_HORIZ_SPEED
		else
		{
			vector enemyOrigin = player.GetOrigin()
			vector dir = Normalize( bottom.GetOrigin() - player.GetOrigin() )
			float dist = Distance( enemyOrigin, bottom.GetOrigin() )
			newVelocity = dir * GraphCapped( dist, SPACEELEVATOR_TUNING_RADIUS, SPACEELEVATOR_TUNING_RADIUS, 0, SPACEELEVATOR_TUNING_TO_CENTER_SPEED )
		}
			
		newVelocity.z = UPVELOCITY
		player.SetVelocity( newVelocity )
		
		#if DEVELOPER
			printt( "player going up" )
		#endif 
		
		WaitFrame()
	}
	
}

void function LockoutPlayerOnLiftMovement(entity bottom, entity player)
{
	EndSignal(player, "OnDeath")
	EndSignal(bottom, "OnDestroy")

	OnThreadEnd(
		function() : ( player )
		{
			IsValid( player )
			{
				player.kv.gravity = 1
			}
		}
	)
	
	while( IsValid(bottom) && IsValid(player) && bottom.IsTouching(player)  )
	{
		player.kv.gravity = 0.00001
		float UPVELOCITY

		// if(GetPlayerElevatorProgress(bottom, player) <= 0.935)
			UPVELOCITY = SPACEELEVATOR_TUNING_UP_SPEED
		// else
			// UPVELOCITY = SPACEELEVATOR_TUNING_AWAY_FROM_CENTER_DIST

		vector newVelocity
		
		if(player.GetInputAxisForward() != 0 || player.GetInputAxisRight() != 0)
			newVelocity = (AnglesToForward(player.GetAngles())*signum(player.GetInputAxisForward()) + AnglesToRight(player.GetAngles())*signum(player.GetInputAxisRight()))*SPACEELEVATOR_TUNING_HORIZ_SPEED
		else
		{
			vector enemyOrigin = player.GetOrigin()
			vector dir = Normalize( bottom.GetOrigin() - player.GetOrigin() )
			float dist = Distance( enemyOrigin, bottom.GetOrigin() )
			newVelocity = dir * GraphCapped( dist, SPACEELEVATOR_TUNING_RADIUS, SPACEELEVATOR_TUNING_RADIUS, 0, SPACEELEVATOR_TUNING_TO_CENTER_SPEED )
		}
			
		newVelocity.z = UPVELOCITY
		player.SetVelocity( newVelocity )
		
		WaitFrame()
	}
	
}

float function GetPlayerElevatorProgress( entity elevator, entity player )
{
	float progress = 1.0
	if ( IsValid( player ) )
	{
		vector playerPos = player.GetOrigin()

		vector elevatorPos = elevator.GetOrigin()

		vector triggerToPlayer = playerPos - elevatorPos

		vector elevatorDirection = elevator.GetUpVector()
		float distanceAlongLine  = DotProduct( triggerToPlayer, elevatorDirection )

		progress = distanceAlongLine / SPACEELEVATOR_TUNING_HEIGHT
		return progress
	}
	return progress
}

void function FallTempAirControl( entity player )
{
	if ( !IsValid(player) || !player.IsPlayer() || player.IsOnGround() )
		return
	thread fixStun(player)
	StopSoundOnEntity( player, "JumpPad_AirborneMvmt_3p" )
	EmitSoundOnEntityExceptToPlayer( player, player, "JumpPad_AirborneMvmt_3p" )
	player.kv.gravity = 1.0
	player.kv.airSpeed = SPACEELEVATOR_AIRSPEED //horizon value
	player.kv.airAcceleration = SPACEELEVATOR_AIRACCEL //horizon value
	RemovePlayerMovementEventCallback( player, ePlayerMovementEvents.TOUCH_GROUND, OnPlayerTouchGround )
	AddPlayerMovementEventCallback( player, ePlayerMovementEvents.TOUCH_GROUND, OnPlayerTouchGround )
	player.kv.landslowdownduration = 0//doesn't work
	player.kv.landslowdownpower = 0//doesn't work
	player.p.ForceEject = false
}
void function fixStun(entity player)
{
	vector testOrg = <player.GetOrigin().x,player.GetOrigin().y,player.GetOrigin().z>
	int solidMask = TRACE_MASK_PLAYERSOLID
	vector mins
	vector maxs
	int collisionGroup = TRACE_COLLISION_GROUP_PLAYER
	array<entity> ignoreEnts = [ player ]

	TraceResults result

	mins = player.GetPlayerMins()
	maxs = player.GetPlayerMaxs()
	while(IsValid(player))
	{	
		
		testOrg = player.GetOrigin()
		result = TraceHull( testOrg, testOrg + < 0, 0, -150 >, mins, maxs, ignoreEnts, solidMask, collisionGroup )
		if (result.hitEnt)
		{
			// printt(result.hitEnt)
			vector tempV = player.GetVelocity()
			if(tempV.z < -650)
				tempV.z = -650

			player.SetVelocity(tempV)
			break
		}
		// WaitFrame()
		wait 0.00000001
	}
	
}
void function OnPlayerTouchGround( entity player )
{
	StopSoundOnEntity( player, "JumpPad_AirborneMvmt_3p" )
	RemovePlayerMovementEventCallback( player, ePlayerMovementEvents.TOUCH_GROUND, OnPlayerTouchGround )
	player.kv.airSpeed = player.GetPlayerSettingFloat( "airSpeed" )
	player.kv.airAcceleration = player.GetPlayerSettingFloat( "airAcceleration" )
}
#endif
