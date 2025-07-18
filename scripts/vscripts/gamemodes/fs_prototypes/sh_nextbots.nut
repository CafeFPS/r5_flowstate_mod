//fix evac ship script, modified a little bit so it works

untyped

global function MpNextBots_Init

#if SERVER
global function TEST_CreateNextbotNearbyPlayer
#endif

const string AUDIO_LOOP = "ShadowLegend_Shadow_Loop_3P"
const string AUDIO_PLAYER_KILLED = "pilot_killed_indicator_BU"
const string AUDIO_AI_SCREAM = "AI_Flyer_AttackScream_Cage_3P"

const float DISTANCE_TO_INSTAGIB = 100.0

struct NextbotAsset
{
	asset name
	int width
	int height
}

struct
{
	#if SERVER
	
	#endif
	
	#if CLIENT
		table< int, array<NextbotAsset> > emotes = {}
	#endif

} file

array<int> mehList = [ 0, 5, 6, 7 ] // Para quitar algunos holosprays

void function MpNextBots_Init()
{
	#if CLIENT
		AddCreateCallback( "npc_dummie", OnNextbotSpawned )

		//From holosprays
		{
			var dataTable = GetDataTable( $"datatable/emotescustom.rpak" )
			
			for ( int i = 0; i < GetDatatableRowCount( dataTable ); i++ )
			{
				int id = GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "id" ) )
				string emote = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "asset" ) )
				
				NextbotAsset newasset
				newasset.name = CastStringToAsset(emote)
				newasset.width = 350 //holosprays have hardcoded squared size
				newasset.height = 350 //holosprays have hardcoded squared size
				
				if(id in file.emotes)
					file.emotes[id].append( newasset )
				else
					file.emotes[id] <- [ newasset ]
			}
		}

		//Nextbots
		{
			var dataTable = GetDataTable( $"datatable/nextbots.rpak" )
			int elIdQueSigue = file.emotes.len() - 1
			
			for ( int i = 0; i < GetDatatableRowCount( dataTable ); i++ )
			{
				int newid = elIdQueSigue + GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "id" ) )
				string emote = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "asset" ) )
				int width = GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "width" ) )
				int height = GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "height" ) )

				NextbotAsset newasset
				newasset.name = CastStringToAsset(emote)
				newasset.width = width
				newasset.height = height
				
				if(newid in file.emotes)
					file.emotes[newid].append( newasset )
				else
					file.emotes[newid] <- [ newasset ]
			}
		}
		
		//Debug
		// foreach( int i, array<NextbotAsset> item in file.emotes )
		// {
			// foreach( unAsset in item )
				// printt( i, unAsset.name, unAsset.width, unAsset.height )
		// }
	#endif
}

#if SERVER
void function TEST_CreateNextbotNearbyPlayer( int amount )
{
	entity player = gp()[0]
	array<vector> navmeshPositions = NavMesh_RandomPositions_LargeArea( player.GetOrigin(), HULL_HUMAN, amount, 5000, 50000  )
	
	if( navmeshPositions.len() == 0 )
	{
		Message_New( player, "No Navmesh sorry, build one first :P" )
		return
	}
	
	float distance = 0
	vector maslejos
	foreach( i, org in navmeshPositions )
	{
		if( Distance( org, player.GetOrigin() ) > distance )
		{
			distance = Distance( org, player.GetOrigin() )
			maslejos = org
		}
	}
	Message_New( player, "%$rui/menu/store/feature_timer% Get to the EVAC to survive the nextbots %$rui/menu/store/feature_timer%", 10 )
	CharacterSelect_AssignCharacter( ToEHI( player ), GetAllCharacters()[7] )
	FS_GiveRandomMelee(player)
	
	player.TakeOffhandWeapon(OFFHAND_ULTIMATE)
	player.GiveOffhandWeapon("mp_ability_cloak", OFFHAND_ULTIMATE)	
	
	// Nextbots_CreateSafeZone( player, player.GetOrigin() )
	
	CreateEvacShipSequence( maslejos, <0,0,0>, DEFAULT_EVAC_RADIUS, player.GetTeam(), 5, 120, true, true, true, true )
	
	foreach( i, org in navmeshPositions )
	{
		vector spawnPoint = navmeshPositions[i]
		
		entity npc = CreateNPC( "npc_dummie", 99, spawnPoint, <0,0,0> )
		SetSpawnOption_AISettings( npc, "npc_nextbot" )
		
		vector angles = VectorToAngles( player.GetOrigin() - npc.GetOrigin() )
		npc.SetAngles( <0, angles.y*-1, 0> )
		
		DispatchSpawn( npc )
		
		npc.Hide()
		npc.SetTakeDamageType( DAMAGE_NO )
		npc.SetNPCMoveSpeedScale( 1.75 )
		npc.SetThinkEveryFrame( true )
		
		thread Nextbots_InstagibEnemy( npc )
		thread Nextbots_ControlSpeed( npc )
	}
}

void function Nextbots_CreateSafeZone( entity test, vector origin )
{
	entity aiDangerTarget = CreateEntity( "info_target" )
	DispatchSpawn( aiDangerTarget )
	aiDangerTarget.SetOrigin( origin )
	SetTeam( aiDangerTarget, test.GetTeam() )

	AI_CreateDangerousArea_Static( aiDangerTarget, test, 1000, TEAM_INVALID, true, true, origin )

	// AI_CreateDangerousArea( test, test, 512, TEAM_INVALID, true, true )
}

void function Nextbots_ControlSpeed( entity npc )
{
	EndSignal( npc, "OnDestroy" )
	EndSignal( npc, "OnDeath" )
	
	while( true )
	{
		wait 0.1
		
		entity enemy = npc.GetEnemy()
		
		if( !IsValid( enemy ) || !IsAlive( enemy ) )
			continue

		// if( Distance( npc.GetOrigin(), enemy.GetOrigin() ) > 2000 )
			// npc.SetNPCMoveSpeedScale( 1.9 )
			
		if( Distance( npc.GetOrigin(), enemy.GetOrigin() ) < 500 && Time() - npc.ai.screamSoundDebounce > 2.0 )
		{
			EmitSoundOnEntity( npc, AUDIO_AI_SCREAM )
			printt( "played sound" )
			npc.ai.screamSoundDebounce = Time()
		} else
		{
			// npc.SetNPCMoveSpeedScale( 1.75 )
		}

		// if( enemy.IsCloaked( true ) )
		// {
			// npc.ClearAllEnemyMemory()
		// }
	}
}

void function Nextbots_InstagibEnemy( entity npc )
{
	EndSignal( npc, "OnDestroy" )
	
	while( true )
	{
		WaitFrame()
		
		entity enemy = npc.GetEnemy()

		if( !IsValid( enemy ) || !IsAlive( enemy ) )
			continue

		if( Distance( npc.GetOrigin(), enemy.GetOrigin() ) < DISTANCE_TO_INSTAGIB )
		{
			EmitSoundAtPosition( TEAM_ANY, enemy.GetOrigin(), AUDIO_PLAYER_KILLED )
			enemy.Gib( <0,0,100> )
			enemy.Die( null, null, { damageSourceId = eDamageSourceId.nextbot } )
		}
	}
}

#endif

#if CLIENT
void function OnNextbotSpawned( entity npc )
{
	printt( "spawned bot" )
	if( !IsValid( npc ) || npc.GetAISettingsName() != "npc_nextbot" )
		return
	
	var topo = CreateRUITopology_Worldspace( npc.GetOrigin(), <0,0,0>, 200, 200 )
	var rui = RuiCreate( $"ui/basic_image.rpak", topo, RUI_DRAW_WORLD, 32767 )
	
	int assetToPlay = RandomIntRangeInclusive(0,file.emotes.len()-1)

	//make sure the asset to play is not in the meh list
	for ( int j = 0; j < 1; j++ )
	{
		if ( mehList.contains( assetToPlay ) )
		{
			assetToPlay = RandomIntRangeInclusive(0,file.emotes.len()-1)
			j--
		}
	}
	
	Nextbots_CreateAmbientGeneric( npc )
	thread Nextbots_PNGPlayAsset( npc, rui, assetToPlay )
	thread Nextbots_PNGSetAngles( npc, topo, assetToPlay )
}

void function Nextbots_CreateAmbientGeneric( entity npc )
{
	vector origin = npc.GetOrigin()
	entity clientAG = CreateClientSideAmbientGeneric( origin, AUDIO_LOOP, 10000 )
	clientAG.SetEnabled( true )
	clientAG.RemoveFromAllRealms()
	clientAG.AddToOtherEntitysRealms( npc )
	clientAG.SetParent( npc, "", true, 0.0 )
}

void function Nextbots_PNGSetAngles(entity npc, var topo, int index )
{
	EndSignal( npc, "OnDestroy" )
	EndSignal( npc, "OnDeath" )
	
	OnThreadEnd(
		function() : ( topo ) {
			if(topo != null)
				RuiTopology_Destroy( topo )
		}
	)
	
	array<NextbotAsset> assetsToPlay = file.emotes[index]

	vector angles
	vector origin = npc.GetOrigin()
	
	float width = min( 400, assetsToPlay[0].width / 2.0 )
	float height = min( 400, assetsToPlay[0].height / 2.0 )
	entity player = GetLocalViewPlayer()
	
	while( true )
	{
		wait 0.0001
		
		if( !IsValid( npc ) )
			break
		
		vector camPos = player.CameraPosition()
		vector camAng = player.CameraAngles()
		
		vector upVec = AnglesToUp( camAng )
		vector targetPos = camPos + upVec
		
		vector closestPoint    = GetClosestPointOnLine( camPos, targetPos, origin )		
		angles = VectorToAngles( origin - closestPoint )
		origin = npc.GetOrigin() + <0,0,height*0.5>

		UpdateOrientedTopologyPos(topo, origin, Vector(0,angles.y,0), width, height)
	}
}

void function Nextbots_PNGPlayAsset( entity prop, var rui, int index )
{
	array<NextbotAsset> assetsToPlay = file.emotes[index]
	
	if( assetsToPlay.len() == 1 ) //is static
	{
		RuiSetImage( rui, "basicImage", assetsToPlay[0].name)
		RuiSetFloat(rui, "basicImageAlpha", 1.0)

		thread PlayAnimatedEmote(prop, rui, assetsToPlay, true)
	}
	else if( assetsToPlay.len() > 1 ) //is gif?
		thread PlayAnimatedEmote(prop, rui, assetsToPlay)
}

void function PlayAnimatedEmote( entity prop, var rui, array<NextbotAsset> assetsToPlay, bool watchNotAnimated = false )
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
				RuiSetImage( rui, "basicImage", Asset.name)
				wait 0.05
			}
			WaitFrame()
		}
	}
}
#endif
