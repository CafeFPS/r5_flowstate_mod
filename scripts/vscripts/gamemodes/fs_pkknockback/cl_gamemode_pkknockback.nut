//APEX KNOCKBACK RING
//Made by @CafeFPS

// everyone else - advice

global function Cl_GamemodePkknockback_Init
global function MakeKnockbacksRUI
global function DestroyKnockbacsRUI
global function PKKNOCKBACK_CustomHint

global function PKKNOCKBACK_PlayerKilled
global function PKKNOCKBACK_Timer
global function PKKNOCKBACK_SetUIVisibility

struct {
    var scoreRui
	var activeQuickHint
	float endtime
	
} file

struct {
	int local_placement
    int local_points
    entity local_p
    int p2_placement
    int p2_points
    entity p2
} savedState

void function Cl_GamemodePkknockback_Init()
{
	Sh_ArenaDeathField_Init()
	AddCallback_EntitiesDidLoad( _OnEntitiesDidLoad )

	//I don't want these things in user screen even if they launch in debug
	SetConVarBool( "cl_showpos", false )
	SetConVarBool( "cl_showfps", false )
	SetConVarBool( "cl_showgpustats", false )
	SetConVarBool( "cl_showsimstats", false )
	SetConVarBool( "host_speeds", false )
	SetConVarBool( "con_drawnotify", false )
	// SetConVarBool( "enable_debug_overlays", false )
	
	RegisterSignal("ChallengeStartRemoveCameras")
	RegisterSignal("ChangeCameraToSelectedLocation")
	RegisterSignal("PKKNOCKBACK_EndTimer")
}

void function PKKNOCKBACK_CustomHint(int index, int eHandle)
{
	if(!IsValid(GetLocalViewPlayer())) return

	switch(index)
	{
		case 0:
		QuickHint("", "Player Killed +100 Points", true, 4)
		EmitSoundOnEntity(GetLocalViewPlayer(), "ui_ingame_switchingsides")
		break

		case 1:
		QuickHint("", "10% Pushback Power Adquired!", true, 5)
		EmitSoundOnEntity(GetLocalViewPlayer(), "ui_ingame_switchingsides")
		break

		case 2:
		Obituary_Print_Localized( EHI_GetName(eHandle) + " got +10% pushback power buff!", GetChatTitleColorForPlayer( GetLocalViewPlayer() ), BURN_COLOR )
		break
		
		case 3:
		Obituary_Print_Localized( "Made with love by @CafeFPS", GetChatTitleColorForPlayer( GetLocalViewPlayer() ), BURN_COLOR )
		
		UISize screenSize = GetScreenSize()
		var screenAlignmentTopo = RuiTopology_CreatePlane( <( screenSize.width * 0.25),( screenSize.height * 0.28 ), 0>, <float( screenSize.width ), 0, 0>, <0, float( screenSize.height ), 0>, false )
		var rui = RuiCreate( $"ui/announcement_quick_right.rpak", screenAlignmentTopo, RUI_DRAW_HUD, RUI_SORT_SCREENFADE + 1 )
		
		RuiSetGameTime( rui, "startTime", Time() )
		RuiSetString( rui, "messageText", "Stay close to the main ring. \n Collect pushback boost zones. \n Kick enemies out of the ring.")
		RuiSetString( rui, "messageSubText", "Text 2")
		RuiSetFloat( rui, "duration", 10 )
		RuiSetFloat3( rui, "eventColor", SrgbToLinear( <48, 107, 255> / 255.0 ) )
		break

		case 4:
		QuickHint("", "Damage Boost Limit Reached!", false, 5)
		EmitSoundOnEntity(GetLocalViewPlayer(), "vdu_on")
		break

		case 5:
		QuickHint("", "Collecting Buff: +3 Points!", true, 2)
		EmitSoundOnEntity(GetLocalViewPlayer(), "UI_PostGame_TitanSlideIn")
		break

		case 6:
		QuickHint("", "Move Speed Boost Limit Reached!", false, 5)
		EmitSoundOnEntity(GetLocalViewPlayer(), "vdu_on")
		break

		case 7:
		QuickHint("", "Fire Rate Boost Limit Reached!", false, 5)
		EmitSoundOnEntity(GetLocalViewPlayer(), "vdu_on")
		break

		case 8:
		QuickHint("", "10% Movement Speed Boost Adquired!", true, 5)
		EmitSoundOnEntity(GetLocalViewPlayer(), "ui_ingame_switchingsides")
		break
		
		case 9:
		QuickHint("", "10% Fire Rate Boost Adquired!", true, 5)
		EmitSoundOnEntity(GetLocalViewPlayer(), "ui_ingame_switchingsides")
		break
		
		case 10:
		QuickHint("", "My Global Points: " + eHandle.tostring(), true, 5)
		EmitSoundOnEntity(GetLocalViewPlayer(), "ui_ingame_switchingsides")
		break
	}
}

void function _OnEntitiesDidLoad()
{
	// This works but there is a little desync that is not fixed after the first round, fix this if we want to new players spawn mid round so their deahtfield has the correct size
	if(GetGameState() == eGameState.Playing)
	{
		InitDeathFieldDataAndStageData() //build ring data for players connected mid round
		GetLocalClientPlayer().ClientCommand("askringsize") //fix ringsize for players connected mid round
	}
}

void function QuickHint( string buttonText, string hintText, bool blueText = false, int duration = 2)
{
	if(file.activeQuickHint != null)
	{
		RuiDestroyIfAlive( file.activeQuickHint )
		file.activeQuickHint = null
	}
	file.activeQuickHint = CreateFullscreenRui( $"ui/announcement_quick_right.rpak" )
	
	RuiSetGameTime( file.activeQuickHint, "startTime", Time() )
	RuiSetString( file.activeQuickHint, "messageText", buttonText + " " + hintText )
	RuiSetFloat( file.activeQuickHint, "duration", duration.tofloat() )
	
	if(blueText)
		RuiSetFloat3( file.activeQuickHint, "eventColor", SrgbToLinear( <48, 107, 255> / 255.0 ) )
	else
		RuiSetFloat3( file.activeQuickHint, "eventColor", SrgbToLinear( <255, 0, 119> / 255.0 ) )
}

void function MakeKnockbacksRUI(int pointsEarned, int distanceToRing)
{
	entity player = GetLocalClientPlayer()
	
	if(!IsValid(player) || player != GetLocalViewPlayer() ) return
	
	player.p.roundPlayerPoints+=pointsEarned
	string pointstring = pointsEarned == 1 ? "Point" : "Points"
	
	Hud_SetText( HudElement( "OITCTIMERTEXT2"), "+" + pointsEarned + " " + pointstring + "!")
	// if(file.scoreRui != null)
	// {		
		// RuiSetString( file.scoreRui, "messageText", "+" + pointsEarned + " " + pointstring + "! \n Points: " + player.p.roundPlayerPoints + " \n Distance To Ring: "+ distanceToRing + "m")
		// return
	// }
	// UISize screenSize = GetScreenSize()
	// var screenAlignmentTopo = RuiTopology_CreatePlane( <( screenSize.width * 0.25),( screenSize.height * 0.28 ), 0>, <float( screenSize.width ), 0, 0>, <0, float( screenSize.height ), 0>, false )
	// var rui = RuiCreate( $"ui/announcement_quick_right.rpak", screenAlignmentTopo, RUI_DRAW_HUD, RUI_SORT_SCREENFADE + 1 )
	
	// RuiSetGameTime( rui, "startTime", Time() )
	// RuiSetString( rui, "messageText", "+" + pointsEarned + " " + pointstring + "! \n Points: " + player.p.roundPlayerPoints + " \n Distance To Ring: "+ distanceToRing + "m")
	// RuiSetString( rui, "messageSubText", "Text 2")
	// RuiSetFloat( rui, "duration", 999999 )
	// RuiSetFloat3( rui, "eventColor", SrgbToLinear( <48, 107, 255> / 255.0 ) )
	
	// file.scoreRui = rui
}

void function DestroyKnockbacsRUI()
{
	entity player = GetLocalClientPlayer()
	
	player.p.roundPlayerPoints = 0
	if(file.scoreRui != null)
	{
		RuiDestroyIfAlive( file.scoreRui )
		file.scoreRui = null
	}
}

void function PKKNOCKBACK_SetUIVisibility(bool show)
{
    Hud_SetVisible(HudElement( "OITCSLOT1" ), show)
	Hud_SetEnabled( HudElement( "OITCSLOT1" ), show)
	
    Hud_SetVisible(HudElement( "OITCSLOT1LINE" ), show)
	Hud_SetEnabled( HudElement( "OITCSLOT1LINE" ), show)
	
    Hud_SetVisible(HudElement( "OITCSLOT2" ), show)
	Hud_SetEnabled( HudElement( "OITCSLOT2" ), show)
	
    Hud_SetVisible(HudElement( "OITCSLOT2LINE" ), show)
	Hud_SetEnabled( HudElement( "OITCSLOT2LINE" ), show)
	
    Hud_SetVisible(HudElement( "OITCSLOT1PLACEMENTTEXT" ), show)
	Hud_SetEnabled( HudElement( "OITCSLOT1PLACEMENTTEXT" ), show)
	
    Hud_SetVisible(HudElement( "OITCSLOT1NAMETEXT" ), show)
	Hud_SetEnabled( HudElement( "OITCSLOT1NAMETEXT" ), show)
	
    Hud_SetVisible(HudElement( "OITCSLOT1SCORETEXT" ), show)
	Hud_SetEnabled( HudElement( "OITCSLOT1SCORETEXT" ), show)
	
    Hud_SetVisible(HudElement( "OITCSLOT2PLACEMENTTEXT" ), show)
	Hud_SetEnabled( HudElement( "OITCSLOT2PLACEMENTTEXT" ), show)
	
    Hud_SetVisible(HudElement( "OITCSLOT2NAMETEXT" ), show)
	Hud_SetEnabled( HudElement( "OITCSLOT2NAMETEXT" ), show)
	
    Hud_SetVisible(HudElement( "OITCSLOT2SCORETEXT" ), show)
	Hud_SetEnabled( HudElement( "OITCSLOT2SCORETEXT" ), show)
	
	Hud_SetEnabled( HudElement( "OITCTIMER" ), show)
	Hud_SetVisible( HudElement( "OITCTIMER" ), show)
	
	Hud_SetEnabled( HudElement( "OITCTIMERTEXT" ), show)
	Hud_SetVisible( HudElement( "OITCTIMERTEXT" ), show)

	Hud_SetEnabled( HudElement( "OITCTIMERTEXT2" ), show)
	Hud_SetVisible( HudElement( "OITCTIMERTEXT2" ), show)	
}

void function PKKNOCKBACK_Timer(bool enable, float endtime)
{
	Signal(GetLocalClientPlayer(), "PKKNOCKBACK_EndTimer")
	
	file.endtime = endtime
	
	Hud_SetEnabled( HudElement( "OITCTIMER" ), enable )
	Hud_SetVisible( HudElement( "OITCTIMER" ), enable )

	Hud_SetEnabled( HudElement( "OITCTIMERTEXT" ), enable )
	Hud_SetVisible( HudElement( "OITCTIMERTEXT" ), enable )
	
	if(enable)
		thread Thread_PKKNOCKBACK_Timer(endtime)
}

void function Thread_PKKNOCKBACK_Timer(float endtime)
{
	entity player = GetLocalClientPlayer()
	EndSignal( player, "PKKNOCKBACK_EndTimer")

	while ( Time() <= endtime )
	{
		if(file.endtime == 0) break
		
        int elapsedtime = int(endtime) - Time().tointeger()

		DisplayTime dt = SecondsToDHMS( elapsedtime )
		Hud_SetText( HudElement( "OITCTIMERTEXT"), format( "%.2d:%.2d", dt.minutes, dt.seconds ))
		
		wait 1
	}
}

void function PKKNOCKBACK_PlayerKilled( int local_score, int local_placement, entity local_p, int p2_score, int p2_placement, entity p2 )
{
	//printt("should update scoreboard ", local_score, local_placement, local_p, p2_score, p2_placement, p2 )
    //Save the data for when/if the player decides to change resoultion
    savedState.local_placement = local_placement
    savedState.local_points = local_score
    savedState.local_p = local_p
    savedState.p2_placement = p2_placement
    savedState.p2_points = p2_score
    savedState.p2 = p2

    if(local_placement == 1) 
    {
        RuiSetImage( Hud_GetRui( HudElement( "OITCSLOT1LINE") ), "basicImage", $"rui/gamemodes/oitc/Blue" )
        RuiSetImage( Hud_GetRui( HudElement( "OITCSLOT2LINE") ), "basicImage", $"rui/gamemodes/oitc/Red" )

        Hud_SetText( HudElement( "OITCSLOT1PLACEMENTTEXT"), "" + "1." )
        Hud_SetText( HudElement( "OITCSLOT1NAMETEXT"), "" + local_p.GetPlayerName() )
        Hud_SetText( HudElement( "OITCSLOT1SCORETEXT"), "" + local_score )


        if(IsValid(p2)) {
            Hud_SetText( HudElement( "OITCSLOT2PLACEMENTTEXT"), "" + p2_placement + "." )
            Hud_SetText( HudElement( "OITCSLOT2NAMETEXT"), "" + p2.GetPlayerName() )
            Hud_SetText( HudElement( "OITCSLOT2SCORETEXT"), "" + p2_score )
        } else {
            Hud_SetText( HudElement( "OITCSLOT2PLACEMENTTEXT"), "" )
            Hud_SetText( HudElement( "OITCSLOT2NAMETEXT"), "" )
            Hud_SetText( HudElement( "OITCSLOT2SCORETEXT"), "" )
        }
    }
    else 
    {
        RuiSetImage( Hud_GetRui( HudElement( "OITCSLOT1LINE") ), "basicImage", $"rui/gamemodes/oitc/Red" )
        RuiSetImage( Hud_GetRui( HudElement( "OITCSLOT2LINE") ), "basicImage", $"rui/gamemodes/oitc/Blue" )

        Hud_SetText( HudElement( "OITCSLOT1PLACEMENTTEXT"), "" + "1." )
        Hud_SetText( HudElement( "OITCSLOT1NAMETEXT"), "" + p2.GetPlayerName() )
        Hud_SetText( HudElement( "OITCSLOT1SCORETEXT"), "" + p2_score )

        Hud_SetText( HudElement( "OITCSLOT2PLACEMENTTEXT"), "" + local_placement + "." )
        Hud_SetText( HudElement( "OITCSLOT2NAMETEXT"), "" + local_p.GetPlayerName() )
        Hud_SetText( HudElement( "OITCSLOT2SCORETEXT"), "" + local_score )
    }
}