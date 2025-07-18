 // █████╗ ██╗   ██╗██████╗ ██╗ ██████╗     ██╗   ██╗██╗███████╗██╗   ██╗ █████╗ ██╗          ██████╗██╗     ██╗   ██╗███████╗███████╗
// ██╔══██╗██║   ██║██╔══██╗██║██╔═══██╗    ██║   ██║██║██╔════╝██║   ██║██╔══██╗██║         ██╔════╝██║     ██║   ██║██╔════╝██╔════╝
// ███████║██║   ██║██║  ██║██║██║   ██║    ██║   ██║██║███████╗██║   ██║███████║██║         ██║     ██║     ██║   ██║█████╗  ███████╗
// ██╔══██║██║   ██║██║  ██║██║██║   ██║    ╚██╗ ██╔╝██║╚════██║██║   ██║██╔══██║██║         ██║     ██║     ██║   ██║██╔══╝  ╚════██║
// ██║  ██║╚██████╔╝██████╔╝██║╚██████╔╝     ╚████╔╝ ██║███████║╚██████╔╝██║  ██║███████╗    ╚██████╗███████╗╚██████╔╝███████╗███████║
// ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝ ╚═════╝       ╚═══╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝     ╚═════╝╚══════╝ ╚═════╝ ╚══════╝╚══════╝
                                                                                                                                   
// ███╗   ███╗ █████╗ ██████╗ ███████╗    ██████╗ ██╗   ██╗     ██████╗ █████╗ ███████╗███████╗███████╗██████╗ ███████╗               
// ████╗ ████║██╔══██╗██╔══██╗██╔════╝    ██╔══██╗╚██╗ ██╔╝    ██╔════╝██╔══██╗██╔════╝██╔════╝██╔════╝██╔══██╗██╔════╝               
// ██╔████╔██║███████║██║  ██║█████╗      ██████╔╝ ╚████╔╝     ██║     ███████║█████╗  █████╗  █████╗  ██████╔╝███████╗               
// ██║╚██╔╝██║██╔══██║██║  ██║██╔══╝      ██╔══██╗  ╚██╔╝      ██║     ██╔══██║██╔══╝  ██╔══╝  ██╔══╝  ██╔═══╝ ╚════██║               
// ██║ ╚═╝ ██║██║  ██║██████╔╝███████╗    ██████╔╝   ██║       ╚██████╗██║  ██║██║     ███████╗██║     ██║     ███████║               
// ╚═╝     ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝    ╚═════╝    ╚═╝        ╚═════╝╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝     ╚═╝     ╚══════╝               

global function AudioVisualCluesTracker_Init

#if CLIENT
global function ServerCallback_AddGunfireEvent
#endif //CLIENT

#if DEVELOPER && CLIENT
global function DEV_StartAudioVisualCluesTracker
#endif // DEVELOPER && CLIENT

#if CLIENT
struct EventData {
	entity player
	vector position
	float timestamp
	float duration = 5.0
	bool isGunfire = false
	var	circleElem
	float  rotationAngle = 0.0
}

struct {
	array<var> footstepElems
	array<var> gunfireElems
	array<var> circleElems
	array<EventData> activeFootsteps
	array<EventData> activeGunfire
} file

const int MAX_EVENTS_PER_TYPE = 10

#endif //CLIENT

void function AudioVisualCluesTracker_Init()
{
	#if CLIENT
	AddCallback_OnClientScriptInit( SaveHudElements )
	// PrecacheHUDMaterial( $"vgui/hud/custom/circle_shape" ) //todo(cafe): port this asset
	#endif //CLIENT
	
	#if SERVER
	AddCallback_OnWeaponAttack( VisualCluesTracker_OnWeaponAttack )
	#endif //SERVER
}

#if SERVER
void function VisualCluesTracker_OnWeaponAttack( entity player, entity weapon, string weaponName, int ammoUsed, vector attackOrigin, vector attackDir )
{
	foreach( sPlayer in GetPlayerArray() )
		Remote_CallFunction_NonReplay( sPlayer, "ServerCallback_AddGunfireEvent", player, attackOrigin )
}
#endif //SERVER

#if CLIENT
void function SaveHudElements( entity player )
{
	if( player != GetLocalViewPlayer() )
		return
	
	// Precache HUD elements
	file.footstepElems = [
		HudElement( "Footstep_1" ),
		HudElement( "Footstep_2" ),
		HudElement( "Footstep_3" ),
		HudElement( "Footstep_4" ),
		HudElement( "Footstep_5" ),
		HudElement( "Footstep_6" ),
		HudElement( "Footstep_7" ),
		HudElement( "Footstep_8" ),
		HudElement( "Footstep_9" ),
		HudElement( "Footstep_10" )
	]

	file.gunfireElems = [
		HudElement( "Gunfire_1" ),
		HudElement( "Gunfire_2" ),
		HudElement( "Gunfire_3" ),
		HudElement( "Gunfire_4" ),
		HudElement( "Gunfire_5" ),
		HudElement( "Gunfire_6" ),
		HudElement( "Gunfire_7" ),
		HudElement( "Gunfire_8" ),
		HudElement( "Gunfire_9" ),
		HudElement( "Gunfire_10" )
	]

	file.circleElems = [
		HudElement( "Circle_1" ),
		HudElement( "Circle_2" ),
		HudElement( "Circle_3" ),
		HudElement( "Circle_4" ),
		HudElement( "Circle_5" ),
		HudElement( "Circle_6" ),
		HudElement( "Circle_7" ),
		HudElement( "Circle_8" ),
		HudElement( "Circle_9" ),
		HudElement( "Circle_10" )
	]
}

void function ServerCallback_AddGunfireEvent( entity player, vector attackpos )
{
	if( !IsValid( player ) || player == GetLocalViewPlayer() )
		return
	
	if( Distance2D( player.GetOrigin(), GetLocalViewPlayer().GetOrigin() ) >= 2000 )
		return
	
	EventData newEvent
	newEvent.player = player
	newEvent.position = attackpos
	newEvent.timestamp = Time()
	newEvent.duration = 0.25
	newEvent.isGunfire = true

	AddGunfireEvent( player, newEvent )
}

void function EnemyDetectionThink()
{
	entity localPlayer = GetLocalViewPlayer()
	int team = localPlayer.GetTeam()
	float gunfireCooldown = 0.0
	
	while( true )
	{
		WaitFrame()

		if ( !IsValid( localPlayer ) )
			continue

		// Detect nearby enemies (footsteps)
		array<entity> allPlayers = GetPlayerArray()
		allPlayers.extend( GetNPCArray() )
		
		// First update existing events
		foreach( EventData existingData in file.activeFootsteps )
		{
			if( !IsValid( existingData.player ) )
				continue
				
			// Update position for existing entries
			existingData.position = existingData.player.GetOrigin()
			existingData.timestamp = Time() // Refresh timestamp while visible
		}

		// Check for new enemies
		foreach( entity player in allPlayers )
		{
			if( player == localPlayer || player.GetTeam() == team )
				continue
				
			vector enemyPos = player.GetOrigin()
			float distance = Distance2D( enemyPos, localPlayer.GetOrigin() )
			
			if( distance < 1000 )
			{
				bool foundExisting = false
				
				// Update existing entry if found
				foreach( EventData data in file.activeFootsteps )
				{
					if( data.player == player )
					{
						data.position = enemyPos
						data.timestamp = Time()
						foundExisting = true
						break
					}
				}

				// Add new entry if not found
				if( !foundExisting )
				{
					EventData newEvent
					newEvent.player = player
					newEvent.position = enemyPos
					newEvent.timestamp = Time()
					newEvent.duration = 1.0
					
					AddFootstepEvent( player, newEvent )
				}
			}
		}
		
		// Cleanup out-of-range enemies
		for( int i = file.activeFootsteps.len()-1; i >= 0; i-- )
		{
			EventData data = file.activeFootsteps[i]
			if( Distance2D( data.position, localPlayer.GetOrigin() ) > 1000 )
				file.activeFootsteps.remove(i)
		}
		
		// Update visual indicators
		UpdateIndicators()
	}
}

vector function GetScreenCenter()
{
	UISize screenSize = GetScreenSize()
	return <screenSize.width * 0.5, screenSize.height * 0.5, 0>
}

void function UpdateIndicators()
{
	UpdateEventIndicators( file.activeFootsteps, false, $"rui/flowstate_custom/footstep" )
	UpdateEventIndicators( file.activeGunfire, true, $"rui/flowstate_custom/gunfire" )
}

void function UpdateEventIndicators( array<EventData> events, bool isGunfire, asset imageAsset )
{
	entity localPlayer = GetLocalViewPlayer()
	vector cameraPos = localPlayer.CameraPosition()
	vector cameraAng = localPlayer.CameraAngles()
	vector screenCenter = GetScreenCenter()
	
	array<var> elements = isGunfire ? file.footstepElems : file.gunfireElems

	// Cleanup expired events (now includes owner validation)
	for( int i = events.len() - 1; i >= 0; i-- )
	{
		if( Time() > events[i].timestamp + events[i].duration || !IsValid( events[i].player ) || !IsAlive( events[i].player ) )
			events.remove(i)
	}

	// Sort by distance
	// events.sort( SortByDistance )

	// Update HUD elements
	for ( int i = 0; i < elements.len(); i++ )
	{
		var elem = elements[i]
		var circleElem 
		
		if( !isGunfire )
			circleElem = file.circleElems[i]
		
		bool shouldShow = i < events.len()
		
		Hud_SetVisible( elem, shouldShow )
		
		if( circleElem != null )
			Hud_SetVisible( circleElem, shouldShow )
		
		if ( !shouldShow ) continue
		
		EventData data = events[i]
		vector vecToEnemy = data.position - cameraPos
		// bool isGunfire = data.isGunfire
		
		// Circular positioning parameters
		float radius = !isGunfire ? 225 * ( float( GetScreenSize().height ) / 1080.0 ) : 250 * ( float( GetScreenSize().height ) / 1080.0 ) // Distance from crosshair center in pixels
		float iconSize = !isGunfire ? 50 * ( float( GetScreenSize().height ) / 1080.0 ) : 40 * ( float( GetScreenSize().height ) / 1080.0 ) // Size of indicator icons
		
		vecToEnemy.z = 0
		vecToEnemy = Normalize(vecToEnemy)
		
		// Get camera orientation vectors
		vector cameraForward = Normalize( AnglesToForward( <0, cameraAng.y, 0> ) )
		vector cameraRight = CrossProduct( <0,0,1>, cameraForward )
		
		// Calculate directional dot products
		float forwardDot = vecToEnemy.Dot( cameraForward )
		float rightDot = vecToEnemy.Dot( cameraRight )
		
		// Convert to screen space coordinates
		float angle = atan2( rightDot, forwardDot ) - ( PI / 2 )
		float screenX = cos( angle ) * radius
		float screenY = sin( angle ) * radius
		
		// Distance-based scaling
		float distance = Distance2D( data.position, cameraPos )
		float scale = clamp( 1.0 - (distance / 1000.0), 0.5, 1.0 )
		Hud_SetSize( elem, iconSize * scale, iconSize * scale )
		
		// Set position with icon size compensation
		Hud_SetPos( elem, screenX, screenY )
		
		// Hud_SetAlpha( elem, CalculateAlpha( data.timestamp ) )
		RuiSetImage( Hud_GetRui( elem ), "basicImage", imageAsset)
		
		// Add rotating circle
		// if( !IsValid( data.circleElem ) )
		// {
			// data.circleElem = file.circleElems[i]
		// }
		
		// Position circle with main icon
		float circleElemScreenX = cos( angle ) * 200 * ( float( GetScreenSize().height ) / 1080.0 ) 
		float circleElemScreenY = sin( angle ) * 200 * ( float( GetScreenSize().height ) / 1080.0 )
		if( circleElem != null )
			Hud_SetPos( circleElem, circleElemScreenX, circleElemScreenY )
		// Hud_SetVisible( data.circleElem, true )
		
		// Calculate rotation angle (same as footstep icon)
		float angle2 = atan2(forwardDot, rightDot)
		float angleDeg = angle2 * 180 / PI - 90
		
		// Apply rotation to circle element
		if( circleElem != null )
			Hud_SetRotation(circleElem, angleDeg)
	}
}

int function SortByDistance( EventData a, EventData b )
{
	entity player = GetLocalViewPlayer()
	float distA = Distance( a.position, player.EyePosition() )
	float distB = Distance( b.position, player.EyePosition() )
	
	if ( distA < distB ) return -1
	if ( distA > distB ) return 1
	return 0
}

// Modified AddFootstepEvent with distance-based priority
void function AddFootstepEvent( entity player, EventData data )
{
	// Check for existing active event from this player
	foreach( EventData savedData in file.activeFootsteps )
	{
		if( savedData.player == player && Time() <= savedData.timestamp + savedData.duration )
			return
	}

	// Add new event with owner tracking
	if( file.activeFootsteps.len() >= MAX_EVENTS_PER_TYPE )
		file.activeFootsteps.remove(0)
	
	file.activeFootsteps.append( data )
	
	// Sort by proximity
	file.activeFootsteps.sort( SortByDistance )
}

// Gunfire event handler
void function AddGunfireEvent( entity player, EventData data )
{
	// Check for existing active event from this player
	foreach( EventData savedData in file.activeGunfire )
	{
		if( savedData.player == player && Time() <= savedData.timestamp + savedData.duration )
			return
	}
	
	// Add new event with owner tracking
	if( file.activeGunfire.len() >= MAX_EVENTS_PER_TYPE )
		file.activeGunfire.remove(0)
	else
		file.activeGunfire.append( data)
}
#endif //CLIENT

#if DEVELOPER && CLIENT
void function DEV_StartAudioVisualCluesTracker()
{
	thread EnemyDetectionThink()
}
#endif // DEVELOPER && CLIENT