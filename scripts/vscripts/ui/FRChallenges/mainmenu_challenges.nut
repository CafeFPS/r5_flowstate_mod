global function InitFRChallengesMainMenu
global function OpenFRChallengesMainMenu
global function CloseFRChallengesMainMenu
global function SetAimTrainerSessionEnabled

global function Init_ChallengesListMenu

string currentCategory = "AllChallenges"

struct
{
	var menu

	var panel
	var contentPanel
	
	var   videoRui
	int   videoChannel = -1
	asset currentVideo = $""
} file

void function OpenFRChallengesMainMenu(int dummiesKilled)
{
	CloseAllMenus()
	ISAIMTRAINER = true
	PlayerKillsForChallengesUI = dummiesKilled.tostring()
	Hud_SetText(Hud_GetChild( file.menu, "DummiesKilledCounter"), "Dummies killed this session: " + dummiesKilled.tostring())
	if(PlayerCurrentWeapon == "") 
		Hud_SetText(Hud_GetChild( file.menu, "CurrentWeapon"), "Current Weapon: Hitscan Auto")
	else
		Hud_SetText(Hud_GetChild( file.menu, "CurrentWeapon"), "Current Weapon: " + PlayerCurrentWeapon)
	
	//Play random challenge video on menu open
	array<Challenge> allChallenges = GetAllChallengesFlattened()
	
	if(allChallenges.len() > 0)
	{
		int randomIndex = RandomInt(allChallenges.len())
		Challenge randomChallenge = allChallenges[randomIndex]
		
#if DEVELOPER
		printt("Playing random challenge video on menu open: " + randomChallenge.name + " (" + randomChallenge.category + ")")
#endif
		
		StartVideoOnChannel( file.videoChannel, randomChallenge.videoAsset, true, 0.0 )
	}
	
	EmitUISound("UI_Menu_SelectMode_Extend")
	AdvanceMenu( file.menu )
}

void function SetAimTrainerSessionEnabled(bool activated)
{
	if(!activated) ISAIMTRAINER = true
	else ISAIMTRAINER = false	
}

void function CloseFRChallengesMainMenu()
{
	ISAIMTRAINER = false
	CloseAllMenus()
}

void function InitFRChallengesMainMenu( var newMenuArg )
{
	var menu = GetMenu( "FRChallengesMainMenu" )
	file.menu = menu
	
	//Initialize shared challenge data
	InitializeSharedChallengeData()
	
	file.videoRui = Hud_GetRui( Hud_GetChild( file.menu, "BikVideo" ) )
	
	file.videoChannel = ReserveVideoChannel()
	RuiSetInt( file.videoRui, "channel", file.videoChannel )
	
    AddMenuEventHandler( menu, eUIEvent.MENU_SHOW, OnR5RSB_Show )
	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnR5RSB_Open )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnR5RSB_Close )
	AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, OnR5RSB_NavigateBack )
	
	AddEventHandlerToButton( menu, "History", UIE_CLICK, HistoryButtonFunct )
	AddEventHandlerToButton( menu, "Settings", UIE_CLICK, SettingsButtonFunct )
	
	//Category button event handlers
	AddEventHandlerToButton( menu, "AllChallenges", UIE_CLICK, OnAllChallengesClicked )
	AddEventHandlerToButton( menu, "ClickingChallenges", UIE_CLICK, OnClickingChallengesClicked )
	AddEventHandlerToButton( menu, "TrackingChallenges", UIE_CLICK, OnTrackingChallengesClicked )
	AddEventHandlerToButton( menu, "SwitchingChallenges", UIE_CLICK, OnSwitchingChallengesClicked )
	AddEventHandlerToButton( menu, "MovementChallenges", UIE_CLICK, OnMovementChallengesClicked )
	//var Challenge1 = Hud_GetChild( menu, "Challenge1" )
	//First column
	// AddEventHandlerToButton( menu, "Challenge1", UIE_CLICK, Challenge1Funct )
	// AddEventHandlerToButton( menu, "Challenge2", UIE_CLICK, Challenge2Funct )
	// AddEventHandlerToButton( menu, "Challenge3", UIE_CLICK, Challenge3Funct )
	// AddEventHandlerToButton( menu, "Challenge4", UIE_CLICK, Challenge4Funct )
	// AddEventHandlerToButton( menu, "Challenge5", UIE_CLICK, Challenge5Funct )
	// AddEventHandlerToButton( menu, "Challenge6", UIE_CLICK, Challenge6Funct )
	// AddEventHandlerToButton( menu, "Challenge7", UIE_CLICK, Challenge7Funct )
	// AddEventHandlerToButton( menu, "Challenge8", UIE_CLICK, Challenge8Funct )
	// //Second column
	// AddEventHandlerToButton( menu, "Challenge1NewC", UIE_CLICK, Challenge1NewCFunct )
	// AddEventHandlerToButton( menu, "Challenge2NewC", UIE_CLICK, Challenge2NewCFunct )
	// AddEventHandlerToButton( menu, "Challenge3NewC", UIE_CLICK, Challenge3NewCFunct )
	// AddEventHandlerToButton( menu, "Challenge4NewC", UIE_CLICK, Challenge4NewCFunct )
	// AddEventHandlerToButton( menu, "Challenge5NewC", UIE_CLICK, Challenge5NewCFunct )
	// AddEventHandlerToButton( menu, "Challenge6NewC", UIE_CLICK, Challenge6NewCFunct )
	// AddEventHandlerToButton( menu, "Challenge7NewC", UIE_CLICK, Challenge7NewCFunct )
	// AddEventHandlerToButton( menu, "Challenge8NewC", UIE_CLICK, Challenge8NewCFunct )
	
	AddButtonEventHandler( Hud_GetChild( file.menu, "SupportTheDev"), UIE_CLICK, SupportTheDev)
	
	SetMenuReceivesCommands( menu, false )
	SetGamepadCursorEnabled( menu, true )
	
	var gameMenuButton = Hud_GetChild( menu, "GameMenuButton" )
	ToolTipData gameMenuToolTip
	gameMenuToolTip.descText = "Global Settings"
	Hud_SetToolTipData( gameMenuButton, gameMenuToolTip )
	HudElem_SetRuiArg( gameMenuButton, "icon", $"rui/menu/lobby/settings_icon" )
	HudElem_SetRuiArg( gameMenuButton, "shortcutText", "Global Settings" )
	Hud_AddEventHandler( gameMenuButton, UIE_CLICK, OpenGlobalSettings )

	if(IsConnected() && GetCurrentPlaylistVarBool( "firingrange_aimtrainerbycolombia", false ))
		RunClientScript("RefreshChallengeActivated")

	AddUICallback_OnLevelInit( OnLevelInit )
}

void function OnR5RSB_Open()
{
	SetBlurEnabled( true )

	ShowPanel( Hud_GetChild( file.menu, "ChallengesList" ) )
	//Initialize with default category
	PopulateChallengesList("AllChallenges")
}

void function Init_ChallengesListMenu( var panel ) 
{
	file.panel = panel
	var contentPanel = Hud_GetChild( panel, "ContentPanel" )
	file.contentPanel = contentPanel

	ScrollPanel_InitPanel( panel )
	ScrollPanel_InitScrollBar( panel, Hud_GetChild( panel, "ScrollBar" ) )
	
	AddPanelEventHandler( panel, eUIEvent.PANEL_SHOW, OnChallengesListPanel_Show )
	AddPanelEventHandler( panel, eUIEvent.PANEL_HIDE, OnChallengesListPanel_Hide )

	//Setup buttons
	for( int i = 0; i <= 50 ; i++ )
	{
		AddButtonEventHandler( Hud_GetChild( file.contentPanel, "Button" + i ), UIE_CLICK, RequestChallengeToPlay )
		AddButtonEventHandler( Hud_GetChild( file.contentPanel, "Button" + i ), UIE_GET_FOCUS, OnChallengeButtonFocused )
	}
}

void function OnChallengesListPanel_Show( var panel )
{
	ScrollPanel_SetActive( panel, true )
	ScrollPanel_Refresh( panel )
}

void function OnChallengesListPanel_Hide( var panel )
{
	ScrollPanel_SetActive( panel, false )
}

void function RequestChallengeToPlay( var button )
{
	int buttonIndex = int( Hud_GetScriptID( button ) )
	
	//Get challenges from current category using shared system
	array<Challenge> challenges = GetChallengesByCategoryName(currentCategory)
	
	//Check if button index is valid for current category
	if(buttonIndex >= 0 && buttonIndex < challenges.len())
	{
		Challenge selectedChallenge = challenges[buttonIndex]
		
#if DEVELOPER
		printt("Starting challenge: " + selectedChallenge.name + " from category: " + selectedChallenge.category + " with script: " + selectedChallenge.clientScript)
#endif
		CloseAllMenus()
		EmitUISound("UI_Menu_SelectMode_Close")
		RunClientScript(selectedChallenge.clientScript)
	}
}

void function OnChallengeButtonFocused( var button )
{
	int buttonIndex = int( Hud_GetScriptID( button ) )
	
	//Get challenges from current category using shared system
	array<Challenge> challenges = GetChallengesByCategoryName(currentCategory)
	
	//Check if button index is valid and play video preview
	if(buttonIndex >= 0 && buttonIndex < challenges.len())
	{
		Challenge focusedChallenge = challenges[buttonIndex]
		
		#if DEVELOPER
		printt("Showing video preview for: " + focusedChallenge.name + " (" + focusedChallenge.category + ")")
		#endif
		
		StartVideoOnChannel( file.videoChannel, focusedChallenge.videoAsset, true, 0.0 )
	}
}

void function SupportTheDev(var button)
{
	LaunchExternalWebBrowser( "https://ko-fi.com/r5r_colombia", WEBBROWSER_FLAG_NONE )
}

void function OnLevelInit()
{
	PlayerCurrentWeapon = ""
}

bool function ShouldShowBackButton()
{
	return true
}

void function HistoryButtonFunct(var button)
{
	CloseAllMenus()
	RunClientScript("ServerCallback_OpenFRChallengesHistory", PlayerKillsForChallengesUI)
}

void function SettingsButtonFunct(var button)
{
	CloseAllMenus()
	EmitUISound("UI_Menu_SelectMode_Close")
	RunClientScript("ServerCallback_OpenFRChallengesSettings")
}

void function Challenge1Funct(var button)
{
	CloseAllMenus()
	EmitUISound("UI_Menu_SelectMode_Close")
	RunClientScript("StartChallenge1Client")
}

void function Challenge2Funct(var button)
{
	CloseAllMenus()
	EmitUISound("UI_Menu_SelectMode_Close")
	RunClientScript("StartChallenge2Client")
}

void function Challenge3Funct(var button)
{
	CloseAllMenus()
	EmitUISound("UI_Menu_SelectMode_Close")
	RunClientScript("StartChallenge3Client")
}

void function Challenge4Funct(var button)
{
	CloseAllMenus()
	EmitUISound("UI_Menu_SelectMode_Close")
	RunClientScript("StartChallenge4Client")
}

void function Challenge5Funct(var button)
{
	CloseAllMenus()
	EmitUISound("UI_Menu_SelectMode_Close")
	RunClientScript("StartChallenge5Client")
}
void function Challenge6Funct(var button)
{
	CloseAllMenus()
	EmitUISound("UI_Menu_SelectMode_Close")
	RunClientScript("StartChallenge6Client")
}
void function Challenge7Funct(var button)
{
	CloseAllMenus()
	EmitUISound("UI_Menu_SelectMode_Close")
	RunClientScript("StartChallenge7Client")
}
void function Challenge8Funct(var button)
{
	CloseAllMenus()
	EmitUISound("UI_Menu_SelectMode_Close")
	RunClientScript("StartChallenge8Client")
}
void function Challenge1NewCFunct(var button)
{
	CloseAllMenus()
	EmitUISound("UI_Menu_SelectMode_Close")
	RunClientScript("StartChallenge1NewCClient")
}

void function Challenge2NewCFunct(var button)
{
	CloseAllMenus()
	EmitUISound("UI_Menu_SelectMode_Close")
	RunClientScript("StartChallenge2NewCClient")
}

void function Challenge3NewCFunct(var button)
{
	CloseAllMenus()
	EmitUISound("UI_Menu_SelectMode_Close")
	RunClientScript("StartChallenge3NewCClient")
}

void function Challenge4NewCFunct(var button)
{
	CloseAllMenus()
	EmitUISound("UI_Menu_SelectMode_Close")
	RunClientScript("StartChallenge4NewCClient")
}

void function Challenge5NewCFunct(var button)
{
	CloseAllMenus()
	EmitUISound("UI_Menu_SelectMode_Close")
	RunClientScript("StartChallenge5NewCClient")
}

void function Challenge6NewCFunct(var button)
{
	CloseAllMenus()
	EmitUISound("UI_Menu_SelectMode_Close")
	RunClientScript("StartChallenge6NewCClient")
}

void function Challenge7NewCFunct(var button)
{
	CloseAllMenus()
	EmitUISound("UI_Menu_SelectMode_Close")
	RunClientScript("StartChallenge7NewCClient")
}

void function Challenge8NewCFunct(var button)
{
	CloseAllMenus()
	EmitUISound("UI_Menu_SelectMode_Close")
	RunClientScript("StartChallenge8NewCClient")
}
void function OnR5RSB_Show()
{
    //
}

void function OnR5RSB_Close()
{
	//
}

void function OnR5RSB_NavigateBack()
{
    CloseAllMenus()
	AdvanceMenu( GetMenu( "SystemMenu" ) )	
}

void function OpenGlobalSettings(var button)
{
    CloseAllMenus()
	AdvanceMenu( GetMenu( "SystemMenu" ) )	
}


void function PopulateChallengesList(string category)
{
	//Use shared challenge system
	array<Challenge> challenges = GetChallengesByCategoryName(category)
	
	currentCategory = category
	
	//Show and populate buttons for current category
	for(int i = 0; i < challenges.len(); i++)
	{
		if(i > 50) break //Safety check
		
		var button = Hud_GetChild( file.contentPanel, "Button" + i )
		var text = Hud_GetChild( file.contentPanel, "Text" + i )
		var score = Hud_GetChild( file.contentPanel, "Score" + i )
		var isNew = Hud_GetChild( file.contentPanel, "IsNew" + i )
		
		Hud_SetVisible( button, true )
		Hud_SetVisible( text, true )
		Hud_SetVisible( score, true )
		Hud_SetVisible( isNew, challenges[i].isNew )

		Hud_SetText( text, challenges[i].name )
		Hud_SetText( score, "Best: " + GetConVarInt(challenges[i].maxScoreConVar) )
		
		#if DEVELOPER
		printt("Populated challenge: " + challenges[i].name + " at button index: " + i)
		#endif
	}
	
	// Hide the rest of the buttons
	for(int i = challenges.len(); i <= 50; i++)
	{
		var button = Hud_GetChild( file.contentPanel, "Button" + i )
		var text = Hud_GetChild( file.contentPanel, "Text" + i )
		var score = Hud_GetChild( file.contentPanel, "Score" + i )
		var isNew = Hud_GetChild( file.contentPanel, "IsNew" + i )
		
		Hud_SetVisible( button, false )
		Hud_SetVisible( text, false )
		Hud_SetVisible( score, false )
		Hud_SetVisible( isNew, false )
	}
	
	UpdateCategoryVisualState(category)
	
	//Show video of first challenge in the category
	if(challenges.len() > 0)
	{
		Challenge firstChallenge = challenges[0]
		
		#if DEVELOPER
		printt("Showing first challenge video: " + firstChallenge.name + " for category: " + category)
		#endif
		
		StartVideoOnChannel( file.videoChannel, firstChallenge.videoAsset, true, 0.0 )
	}
}

void function UpdateCategoryVisualState(string activeCategory)
{
	//Get all Selected and NotSelected frame elements
	var allSelected = Hud_GetChild( file.menu, "AllChallengesFrameSelected" )
	var allNotSelected = Hud_GetChild( file.menu, "AllChallengesFrameNotSelected" )
	var clickingSelected = Hud_GetChild( file.menu, "ClickingChallengesFrameSelected" )
	var clickingNotSelected = Hud_GetChild( file.menu, "ClickingChallengesFrameNotSelected" )
	var trackingSelected = Hud_GetChild( file.menu, "TrackingChallengesFrameSelected" )
	var trackingNotSelected = Hud_GetChild( file.menu, "TrackingChallengesFrameNotSelected" )
	var switchingSelected = Hud_GetChild( file.menu, "SwitchingChallengesFrameSelected" )
	var switchingNotSelected = Hud_GetChild( file.menu, "SwitchingChallengesFrameNotSelected" )
	var movementSelected = Hud_GetChild( file.menu, "MovementChallengesFrameSelected" )
	var movementNotSelected = Hud_GetChild( file.menu, "MovementChallengesFrameNotSelected" )
	
	//Reset all to not-selected state (hide selected, show not-selected)
	Hud_SetVisible( allSelected, false )
	Hud_SetVisible( allNotSelected, true )
	Hud_SetVisible( clickingSelected, false )
	Hud_SetVisible( clickingNotSelected, true )
	Hud_SetVisible( trackingSelected, false )
	Hud_SetVisible( trackingNotSelected, true )
	Hud_SetVisible( switchingSelected, false )
	Hud_SetVisible( switchingNotSelected, true )
	Hud_SetVisible( movementSelected, false )
	Hud_SetVisible( movementNotSelected, true )
	
	//Show selected frame for active category
	if(activeCategory == "AllChallenges")
	{
		Hud_SetVisible( allSelected, true )
		Hud_SetVisible( allNotSelected, false )
	}
	else if(activeCategory == "ClickingChallenges")
	{
		Hud_SetVisible( clickingSelected, true )
		Hud_SetVisible( clickingNotSelected, false )
	}
	else if(activeCategory == "TrackingChallenges")
	{
		Hud_SetVisible( trackingSelected, true )
		Hud_SetVisible( trackingNotSelected, false )
	}
	else if(activeCategory == "SwitchingChallenges")
	{
		Hud_SetVisible( switchingSelected, true )
		Hud_SetVisible( switchingNotSelected, false )
	}
	else if(activeCategory == "MovementChallenges")
	{
		Hud_SetVisible( movementSelected, true )
		Hud_SetVisible( movementNotSelected, false )
	}
}

void function OnAllChallengesClicked(var button)
{
	EmitUISound("UI_Menu_Accept")
	PopulateChallengesList("AllChallenges")
}

void function OnClickingChallengesClicked(var button)
{
	EmitUISound("UI_Menu_Accept")
	PopulateChallengesList("ClickingChallenges")
}

void function OnTrackingChallengesClicked(var button)
{
	EmitUISound("UI_Menu_Accept")
	PopulateChallengesList("TrackingChallenges")
}

void function OnSwitchingChallengesClicked(var button)
{
	EmitUISound("UI_Menu_Accept")
	PopulateChallengesList("SwitchingChallenges")
}

void function OnMovementChallengesClicked(var button)
{
	EmitUISound("UI_Menu_Accept")
	PopulateChallengesList("MovementChallenges")
}
