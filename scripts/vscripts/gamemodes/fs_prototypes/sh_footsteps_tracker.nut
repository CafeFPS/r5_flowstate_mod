global function FootstepsTracker_Init

#if CLIENT
global function DEV_StartFootstepsTracker
#endif

void function FootstepsTracker_Init()
{
	#if CLIENT
		RegisterSignal( "LootCompassStop" )
	#endif
}

#if CLIENT
void function DEV_StartFootstepsTracker()
{
	thread EnemyCompassThink()
}
#endif

#if CLIENT
void function EnemyCompassThink()
{
	entity localViewPlayer = GetLocalViewPlayer()
	
	EndSignal( localViewPlayer, "OnDeath" )
	
	float startTime = Time()
	var rui = RuiCreate( $"ui/loot_compass.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 0 )
	RuiSetResolutionToScreenSize( rui )
	RuiSetGameTime( rui, "startTime", startTime )

	OnThreadEnd(
	function() : ( rui )
		{
			RuiDestroy( rui )
		}
	)

	int count = 20
	bool enemyFound = true
	vector enemyPos

	while( true )
	{
		++count
		vector cameraPos = localViewPlayer.CameraPosition()
		if ( count > 20 )
		{
			array<entity> enemies = GetPlayerArrayOfEnemies( localViewPlayer.GetTeam() )
			enemies.extend( GetNPCArray() )
			
			array<entity> nearbyEnemies
			foreach( enemy in enemies )
			{
				if ( Distance2D( enemy.GetOrigin(), cameraPos ) <= 3000 )
					nearbyEnemies.append( enemy )
			}

			enemyFound = nearbyEnemies.len() > 0
			if ( enemyFound )
			{
				nearbyEnemies.sort( SortByDistanceFromPlayer )
				entity closestEnemy = nearbyEnemies[0]
				enemyPos = closestEnemy.GetOrigin()
			}
			else
			{
				float elapsedTime = Time() - startTime
				enemyPos = cameraPos + < sin( elapsedTime ), cos( elapsedTime ), 0 >
			}
			count = 0
		}

		vector vecToEnemy = enemyPos - cameraPos
		vecToEnemy.z = 0
		vecToEnemy = Normalize( vecToEnemy )
		RuiSetFloat( rui, "distance", Distance2D( enemyPos, cameraPos ) )
		RuiSetFloat3( rui, "vecToDamage2D", vecToEnemy )
		RuiSetFloat3( rui, "camVec2D", Normalize( AnglesToForward( <0, localViewPlayer.CameraAngles().y, 0> ) ) )
		RuiSetFloat( rui, "sideDot", vecToEnemy.Dot( CrossProduct( <0,0,1>, Normalize( AnglesToForward( <0, localViewPlayer.CameraAngles().y, 0> ) ) ) ) )
		RuiSetBool( rui, "lootFound", enemyFound )

		if ( enemyFound )
		{
			// Use enemy indicator image and color
			RuiSetAsset( rui, "lootImage", $"ui/enemy_icon" )
			RuiSetFloat3( rui, "lootColor", <255, 0, 0> / 255 ) // Red color for enemies
			RuiSetBool( rui, "isWeapon", false )
		}
		else
		{
			RuiSetAsset( rui, "lootImage", $"" )
			RuiSetFloat3( rui, "lootColor", <255, 255, 255> / 255 )
			RuiSetBool( rui, "isWeapon", false )
		}

		WaitFrame()
	}
}

int function SortByDistanceFromPlayer( entity a, entity b )
{
	vector cameraPos = GetLocalViewPlayer().CameraPosition()
	float distA = Distance2D( a.GetOrigin(), cameraPos )
	float distB = Distance2D( b.GetOrigin(), cameraPos )

	if ( distA < distB )
		return -1
	else if ( distA > distB )
		return 1
	return 0
}
#endif