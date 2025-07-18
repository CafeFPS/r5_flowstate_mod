//Made by @CafeFPS

global function MpWeaponEmoteProjector_Init
global function OnWeaponTossReleaseAnimEvent_WeaponEmoteProjector
global function OnWeaponAttemptOffhandSwitch_WeaponEmoteProjector
global function OnWeaponTossPrep_WeaponEmoteProjector
global function OnProjectileCollision_holospray

#if CLIENT
global function HoloSpray_OnUse
global function GetEmotesTable
global function GetLoyBadgesTable
#endif

global const int HOLO_PROJECTOR_INDEX = 6

const asset LIGHT_PARTICLE_TEST = $"P_BT_eye_proj_holo"

const vector EMOTE_ICON_TEXT_OFFSET = <0,0,60>

const float HOLO_EMOTE_LIFETIME = 999.0
const string SOUND_HOLOGRAM_LOOP = "Survival_Emit_RespawnChamber"

global const asset HOLO_SPRAY_BASE = $"mdl/props/holo_spray/holo_spray_base.rmdl"

struct
{
	#if SERVER
	
	#endif
	#if CLIENT
		table<int, array<asset> > emotes = {}
		
		table<int, array<asset> > loyBadges = {}
	#endif

} file

void function MpWeaponEmoteProjector_Init()
{
	#if CLIENT || SERVER
		PrecacheModel( HOLO_SPRAY_BASE )
		PrecacheParticleSystem(LIGHT_PARTICLE_TEST)
	#endif

	#if CLIENT
		var dataTable = GetDataTable( $"datatable/emotescustom.rpak" )
		
		for ( int i = 0; i < GetDatatableRowCount( dataTable ); i++ )
		{
			int id = GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "id" ) )
			string emote = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "asset" ) )
			if(id in file.emotes)
				file.emotes[id].append(CastStringToAsset(emote))
			else
				file.emotes[id] <- [CastStringToAsset(emote)]
			
		}

		// dataTable = GetDataTable( $"datatable/loybadges.rpak" )
		
		// for ( int i = 0; i < GetDatatableRowCount( dataTable ); i++ )
		// {
			// int id = GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "id" ) )
			// string emote = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "asset" ) )

			// if(id in file.loyBadges)
				// file.loyBadges[id].append(CastStringToAsset(emote))
			// else
				// file.loyBadges[id] <- [CastStringToAsset(emote)]
		// }
	
		// if( GetCurrentPlaylistVarBool( "is_practice_map", false ) || Playlist() == ePlaylists.survival_dev )
		// {
			// AddCreateCallback( "player", FS_LoyBadges_StartForPlayer )
		// }
		
		AddCallback_OnBuildMenuOptions( OnBuildMenuOptions )
	#endif
	
	#if SERVER
		AddClientCommandCallback( "HoloSpray_OnUse", ClientCommand_HoloSpray_OnUse )
		
		AddSpawnCallback_ScriptName( "flowstate_holo_spray", ShEHI_OnHoloSprayCreated )
		
		PrecacheWeapon( $"mp_ability_emote_projector" )
		AddCallback_OnClientConnected( FS_HoloSpray_OnClientConnected )
	#endif

}

#if SERVER
void function FS_HoloSpray_OnClientConnected( entity player )
{
	player.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
	player.GiveOffhandWeapon( "mp_ability_emote_projector", OFFHAND_EQUIPMENT )
}
#endif

#if CLIENT
table<int, array<asset> > function GetEmotesTable()
{
	return file.emotes
}

table<int, array<asset> > function GetLoyBadgesTable()
{
	return file.loyBadges
}
#endif

void function OnProjectileCollision_holospray( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	if( !IsValid(projectile) || !IsValid(projectile.GetOwner()) ) return
	entity player = projectile.GetOwner()
	
	if ( IsValid(hitEnt) && hitEnt.IsPlayer() )
		return
	
	table collisionParams =
	{
		pos = pos,
		normal = normal,
		hitEnt = hitEnt,
		hitbox = hitbox
	}

	bool result = PlantStickyEntityOnWorldThatBouncesOffWalls( projectile, collisionParams, 0.7 )
	
	#if DEVELOPER
		printt( "collision, result: ", result )
	#endif

	if(result && IsValid(projectile))
	{
		vector GoodAngles = AnglesOnSurface(normal, -AnglesToRight(player.EyeAngles()))	
		vector origin = projectile.GetOrigin()

		#if SERVER
		entity prop = CreatePropScript_NoDispatchSpawn( HOLO_SPRAY_BASE, origin, GoodAngles, 6 )

		if( projectile.GetParent() && projectile.GetParent().GetScriptName() != "editor_placed_prop" ) // Parent to moving ents like train
		{
			#if DEVELOPER
				printt( "Holo spray parented to moving ent" )
			#endif

			entity parentPoint = CreateEntity( "script_mover_lightweight" )
			parentPoint.kv.solid = 0
			parentPoint.SetValueForModelKey( prop.GetModelName() )
			parentPoint.kv.SpawnAsPhysicsMover = 0
			parentPoint.SetOrigin( origin )
			parentPoint.SetAngles( GoodAngles )
			DispatchSpawn( parentPoint )
			parentPoint.SetParent( projectile.GetParent() )
			parentPoint.Hide()
			prop.SetParent(parentPoint)
		}

		prop.SetScriptName( "flowstate_holo_spray" )
		
		entity fx = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( LIGHT_PARTICLE_TEST ), origin, Vector(-90,0,0) )

		DispatchSpawn( prop )
		
		fx.SetParent( prop )

		prop.e.holoSpraysFX.append(fx)
		player.p.holoSpraysBase.append(prop)

		bool shouldDestroyFirstHolo = false
		
		if(player.p.holoSpraysBase.len() == 3)
			shouldDestroyFirstHolo = true

		if(shouldDestroyFirstHolo)
		{
			entity holoToDestroy = player.p.holoSpraysBase[0]
			player.p.holoSpraysBase.removebyvalue(holoToDestroy)
			
			if(IsValid(holoToDestroy))
			{
				foreach(Fx in holoToDestroy.e.holoSpraysFX)
					if(IsValid(Fx))
						Fx.Destroy()
				holoToDestroy.Destroy()
				
				if( IsValid( holoToDestroy.GetParent() ) )
					holoToDestroy.GetParent().Destroy()
			}
		}
		
		foreach ( sPlayer in GetPlayerArray() )
			Remote_CallFunction_NonReplay( sPlayer, "HoloSpray_OnUse", prop.GetEncodedEHandle(), player.p.holosprayChoice)

		projectile.Destroy()
		#endif
	}
}

bool function OnWeaponAttemptOffhandSwitch_WeaponEmoteProjector( entity weapon )
{
	return true
}

var function OnWeaponTossReleaseAnimEvent_WeaponEmoteProjector( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	#if CLIENT
	if ( !weapon.ShouldPredictProjectiles() )
		return 0
	#endif

	int ammoReq = weapon.GetAmmoPerShot()
	weapon.EmitWeaponSound_1p3p( GetGrenadeThrowSound_1p( weapon ), GetGrenadeThrowSound_3p( weapon ) )
	
	entity player = weapon.GetWeaponOwner()
	int damageFlags = weapon.GetWeaponDamageFlags()
	WeaponFireBoltParams fireBoltParams
	fireBoltParams.pos = attackParams.pos
	fireBoltParams.dir = attackParams.dir
	fireBoltParams.speed = 500
	fireBoltParams.scriptTouchDamageType = damageFlags
	fireBoltParams.scriptExplosionDamageType = damageFlags
	fireBoltParams.clientPredicted = false
	fireBoltParams.additionalRandomSeed = 0
	entity bullet = weapon.FireWeaponBoltAndReturnEntity( fireBoltParams )

	return ammoReq
}

void function OnWeaponTossPrep_WeaponEmoteProjector( entity weapon, WeaponTossPrepParams prepParams )
{
	weapon.EmitWeaponSound_1p3p( GetGrenadeDeploySound_1p( weapon ), GetGrenadeDeploySound_3p( weapon ) )
}

#if CLIENT
CommsMenuOptionData function MakeOption_HoloSpray( int index, asset Asset)
{
	CommsMenuOptionData op
	op.optionType = eOptionType.HOLOSPRAY
	op.emote = null
	op.healType = index
	op.Asset = Asset
	
	return op
}

void function OnBuildMenuOptions( array<CommsMenuOptionData> results, int quipsInWheel )
{
	//Holo sprays
	foreach(id, emotes in GetEmotesTable())
	{
		if(quipsInWheel == MAX_QUIPS_EQUIPPED) break
		
		results.append( MakeOption_HoloSpray( id+1, emotes[0] ) ) //+1 cuz "Nice" quip, FIX ME
		quipsInWheel++
	}
}


//Test Player Badges
void function FS_LoyBadges_StartForPlayer( entity player )
{
	if( player == GetLocalViewPlayer() || player == GetLocalClientPlayer() )
		return
	
	int badge = 0 //Get var from server, make networked int for player, and use change callback instead of create callback. Cafe
	
	LoyBadge_ShowOnPlayer( player, badge )
}

void function LoyBadge_ShowOnPlayer( entity player, int choice )
{
	thread function () : ( player, choice )
	{
		// while ( !EHIHasValidScriptStruct( playerEHandle ) )
			// WaitFrame()
		
		// while( !IsValid( GetEntityFromEncodedEHandle( playerEHandle ) ) )
			// WaitFrame()

		// entity player = GetEntityFromEncodedEHandle( playerEHandle )

		while( player.LookupAttachment( "HEADSHOT" ) <= 0 )
			WaitFrame()
		
		vector origin = player.GetAttachmentOrigin( player.LookupAttachment( "HEADSHOT" ) )
		vector angles =  VectorToAngles( origin - GetLocalViewPlayer().GetOrigin() )

		var topo = CreateRUITopology_Worldspace( origin, Vector(0,angles.y,0), 20, 20 )
		var rui = RuiCreate( $"ui/basic_image.rpak", topo, RUI_DRAW_WORLD, 32767 )
		
		RuiSetFloat(rui, "basicImageAlpha", 0.8)

		thread LoyBadgePlayAsset( player, rui, choice )
		thread LoyBadgesEmoteSetAngles( player, rui, topo )
	}()
}
//End test loy badges

void function HoloSpray_OnUse( int propEhandle, int choice )
{
	thread function () : ( propEhandle, choice )
	{
		while ( !EHIHasValidScriptStruct( propEhandle ) )
			WaitFrame()
		
		while( !IsValid( GetEntityFromEncodedEHandle( propEhandle ) ) )
			WaitFrame()

		entity prop = GetEntityFromEncodedEHandle( propEhandle )
		
		vector origin = prop.GetOrigin()
		vector angles =  VectorToAngles( prop.GetOrigin() - GetLocalViewPlayer().GetOrigin() )
		float width = 40
		float height = 40
		
		origin += (AnglesToUp( angles )*-1) * (height*0.5)
		origin.z += 110
		
		var topo = CreateRUITopology_Worldspace( origin, Vector(0,angles.y,0), width, height )
		var rui = RuiCreate( $"ui/basic_image.rpak", topo, RUI_DRAW_WORLD, 32767 )
		
		RuiSetFloat(rui, "basicImageAlpha", 0.8)

		thread EmotePlayAsset( prop, rui, choice )
		thread EmoteSetAngles( prop, topo, origin )
	}()
}

void function EmotePlayAsset( entity prop, var rui, int index )
{
	array<asset> assetsToPlay = file.emotes[index]
	
	if( assetsToPlay.len() == 1 ) //is static
	{
		RuiSetImage( rui, "basicImage", assetsToPlay[0])
		thread PlayAnimatedEmote(prop, rui, assetsToPlay, true)
	}
	else if( assetsToPlay.len() > 1 ) //is gif?
		thread PlayAnimatedEmote(prop, rui, assetsToPlay)
}

void function LoyBadgePlayAsset( entity prop, var rui, int index )
{
	array<asset> assetsToPlay = file.loyBadges[index]
	
	if( assetsToPlay.len() == 1 ) //is static
	{
		RuiSetImage( rui, "basicImage", assetsToPlay[0])
		thread PlayAnimatedEmote(prop, rui, assetsToPlay, true)
	}
	else if( assetsToPlay.len() > 1 ) //is gif?
		thread PlayAnimatedEmote(prop, rui, assetsToPlay)
}

void function PlayAnimatedEmote( entity prop, var rui, array<asset> assetsToPlay, bool watchNotAnimated = false )
{
	OnThreadEnd(
		function() : ( rui ) {
			if( rui != null )
				RuiDestroyIfAlive(rui)
		}
	)
	
	if( watchNotAnimated )
	{
		WaitSignal(prop, "OnDestroy")
	} else 
	{
		while( IsValid(prop) )
		{
			foreach(Asset in assetsToPlay)
			{
				if( !IsValid(prop) ) break
				RuiSetImage( rui, "basicImage", Asset)
				wait 0.05
			}
			WaitFrame()
		}
	}
}

void function LoyBadgesEmoteSetAngles(entity player, var rui, var topo)
{
	vector angles
	
	OnThreadEnd(
		function() : ( topo ) {
			if(topo != null)
				RuiTopology_Destroy( topo )
		}
	)
	
	while( IsValid(player) )
	{
		WaitFrame()
		
		if( !IsValid( player ) )
			break
		
		//watcher, hide rui
			// player.LookupAttachment( "HEADSHOT" ) == 0
				// if( !IsAlive( player ) ||
			// !player.DoesShareRealms( GetLocalViewPlayer() ) ||
			// player == GetLocalViewPlayer() ||
			// GetGameState() != eGameState.Playing ||
			// ( Playlist() == ePlaylists.fs_lgduels_1v1 ||
			// Playlist() == ePlaylists.fs_1v1 ) && !player.GetPlayerNetEnt( "FSDM_1v1_Enemy" ) ||
			// player.GetTeam() == GetLocalClientPlayer().GetTeam() )
		// {
		
		vector origin = player.GetAttachmentOrigin( player.LookupAttachment( "HEADSHOT" ) )

		entity viewPlayer = GetLocalViewPlayer()
		vector camPos = viewPlayer.CameraPosition()
		vector camAng = viewPlayer.CameraAngles()
		
		origin.z += 20
		
		vector closestPoint    = GetClosestPointOnLine( camPos, camPos + (AnglesToRight( camAng ) * 100.0), origin )		
		angles = VectorToAngles( origin - closestPoint )

		UpdateOrientedTopologyPos(topo, origin, Vector(0,angles.y,0), 20, 20)
	}
}

void function EmoteSetAngles(entity prop, var topo, vector origin)
{
	vector angles
	
	OnThreadEnd(
		function() : ( topo ) {
			if(topo != null)
				RuiTopology_Destroy( topo )
		}
	)
	
	while( IsValid(prop) )
	{
		WaitFrame()
		
		if( !IsValid( prop ) )
			break

		entity player = GetLocalViewPlayer()
		vector camPos = player.CameraPosition()
		vector camAng = player.CameraAngles()
		vector closestPoint    = GetClosestPointOnLine( camPos, camPos + (AnglesToRight( camAng ) * 100.0), origin )		
		angles = VectorToAngles( origin - closestPoint )
		
		float width = 40
		float height = 40
		
		origin = prop.GetOrigin() + (AnglesToUp( angles )*-1) * (height*0.5)
		origin.z += 110
	
		if (  player.GetAdsFraction() > 0.99 ) //player adsing? hide it
		{
			UpdateOrientedTopologyPos(topo, origin, Vector( 90 * ( player.GetAdsFraction() - 0.1), angles.y, 0), 60, 60)
			continue
		}
		
		UpdateOrientedTopologyPos(topo, origin, Vector(0,angles.y,0), 60, 60)
	}
}
#endif

#if SERVER

bool function ClientCommand_HoloSpray_OnUse( entity player, array<string> args )
{
	if ( !IsValid( player ) || !IsAlive( player ) )
		return true

	if ( args.len() < 1 )
		return true

	player.Signal( "PhaseTunnel_EndPlacement" )
	player.p.holosprayChoice = int( args[0] )

	return true
}

#endif