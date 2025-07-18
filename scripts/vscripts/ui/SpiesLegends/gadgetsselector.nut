//Made by @CafeFPS

untyped

global function Init_GadgetsSelector
global function GadgetsSelector_Open
global function GadgetsSelector_Close
global function InitSpiesPanel
global function InitMercsPanel

global function AddSpyAbility
global function AddMercAbility
global function ClearAbilitiesData

const int TEAM_SPIES = 0
const int TEAM_MERCS = 1

const int MAX_ABILITIES = 5
const int MAX_PASSIVES = 3

global struct AbilityData
{
	string name
	string weaponName
	asset icon
	bool isPassive
}

struct AbilityButton
{
	var circle
	var icon
	var name
	var button
	bool isSelected
	AbilityData &data
}

struct PassiveButton
{
	var icon
	var name
	AbilityData &data
}

array<AbilityData> spyGadgets
array<AbilityData> mercGadgets

struct
{
	var menu
	var spiesPanel
	var mercsPanel
	
	var resetButton
	
	array<AbilityButton> abilitiesButtons
	array<PassiveButton> passives
	
	int choice1 = -1
	int choice2 = -1
	int team
} file


void function Init_GadgetsSelector( var newMenuArg )
{
	var menu = GetMenu( "Spies_GadgetsSelector" )
	file.menu = menu

    // AddMenuEventHandler( menu, eUIEvent.MENU_SHOW, OnR5RSB_Show )
	// AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnR5RSB_Open )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnR5RSB_Close )
	AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, OnR5RSB_Close )

	AddButtonEventHandler( Hud_GetChild( file.menu, "GoBackButton"), UIE_CLICK, GoBackButtonFunct )

	SetMenuReceivesCommands( menu, false )
	SetGamepadCursorEnabled( menu, true )

	//Build abilities buttons and passives icons
	for( int i = 1; i <= MAX_ABILITIES ; i++ )
	{
		file.abilitiesButtons.append( CreateButtonData( Hud_GetChild( file.menu, "AbilityCircle_" + i ), Hud_GetChild( file.menu, "AbilityIcon_" + i ), Hud_GetChild( file.menu, "AbilityText_" + i ), Hud_GetChild( file.menu, "AbilityButton_" + i ) ) )
	}

	for( int i = 1; i <= MAX_PASSIVES ; i++ )
	{
		file.passives.append( CreateButtonData_Passive( Hud_GetChild( file.menu, "PassiveIcon_" + i ), Hud_GetChild( file.menu, "PassiveText_" + i ) ) )
	}
	
	//Reset button
	file.resetButton = Hud_GetChild( file.menu, "ResetButton_1" )
	AddButtonEventHandler( Hud_GetChild( file.menu, "ResetButton_1" ), UIE_CLICK, ResetButton_OnPressed )
	AddButtonEventHandler( Hud_GetChild( file.menu, "ResetButton_1" ), UIE_GET_FOCUS, FocusAbility )
	AddButtonEventHandler( Hud_GetChild( file.menu, "ResetButton_1" ), UIE_LOSE_FOCUS, LoseFocusAbility )
	
	//temp
	for( int i = 1; i <= MAX_ABILITIES ; i++ )
	{
		AddButtonEventHandler( Hud_GetChild( file.menu, "AbilityButton_" + i ), UIE_CLICK, SelectAbility )
		AddButtonEventHandler( Hud_GetChild( file.menu, "AbilityButton_" + i ), UIE_GET_FOCUS, FocusAbility )
		AddButtonEventHandler( Hud_GetChild( file.menu, "AbilityButton_" + i ), UIE_LOSE_FOCUS, LoseFocusAbility )
	}
}

AbilityButton function CreateButtonData( var circle, var icon, var name, var buttonElem )
{
	AbilityButton button
	button.circle = circle
	button.icon = icon
	button.name = name
	button.button = buttonElem
	button.isSelected = false
	
	return button
}

PassiveButton function CreateButtonData_Passive( var icon, var name )
{
	PassiveButton button
	button.icon = icon
	button.name = name
	
	return button
}

void function GadgetsSelector_Open( int team )
{
	// Check if abilities data is loaded
	if( spyGadgets.len() == 0 && mercGadgets.len() == 0 )
	{
		// Abilities data not loaded yet, wait for it
		thread WaitForAbilitiesAndOpenMenu( team )
		return
	}
	
	// Abilities data is loaded, proceed normally
	GadgetsSelector_OpenInternal( team )
}

void function GadgetsSelector_OpenInternal( int team )
{
	CloseAllMenus()
	file.team = team
	EmitUISound( "UI_Menu_FriendInspect" )
	AdvanceMenu( file.menu )
	
	if( team == TEAM_SPIES )
	{
		Hud_SetText( Hud_GetChild( file.menu, "TitleAbilitySelector" ), "SELECT TWO GADGETS - SPY")
	} else if( team == TEAM_MERCS )
	{
		Hud_SetText( Hud_GetChild( file.menu, "TitleAbilitySelector" ), "SELECT TWO GADGETS - MERC")
	}
	
	ResetButton_OnPressed(null)
	PopulateMenuWithAbilitiesAndPassives( team )
}

void function WaitForAbilitiesAndOpenMenu( int team )
{
	float timeoutTime = Time() + 10.0 // 10 second timeout
	
	while( Time() < timeoutTime )
	{
		// Check if abilities data is now loaded
		if( spyGadgets.len() > 0 || mercGadgets.len() > 0 )
		{
			GadgetsSelector_OpenInternal( team )
			return
		}
		
		wait 0.1 // Check every 100ms
	}
	
	// Timeout reached, open anyway (will be empty but won't break)
	printw( "GadgetsSelector: Timeout waiting for abilities data, opening empty menu" )
	GadgetsSelector_OpenInternal( team )
}

void function GadgetsSelector_Close()
{
	CloseAllMenus()
	EmitUISound( "UI_Menu_FriendInspect" )
}

void function PopulateMenuWithAbilitiesAndPassives( int team )
{
	array<AbilityData> abilities = team == TEAM_SPIES ? clone spyGadgets : clone mercGadgets
	array<AbilityData> passives
	
	for ( int i = abilities.len() - 1; i >= 0; i-- )
	{
		AbilityData ability = abilities[i]
		
		if( ability.isPassive )
		{
			passives.append(ability)
			abilities.remove( i )
			continue
		}
		
		if( i >= MAX_ABILITIES )
			continue
		
		AbilityButton button = file.abilitiesButtons[i]
		button.data = ability 

		Hud_SetVisible( button.circle, true )
		Hud_SetVisible( button.icon, true )
		Hud_SetVisible( button.name, true )
		Hud_SetVisible( button.button, true )
		
		Hud_SetText(button.name, ability.name)
		RuiSetImage(Hud_GetRui(button.icon), "basicImage", ability.icon)
		
		printw( "showing ability", i, "max", abilities.len() )
	}
	
	for(int i = 0; i < passives.len(); i++)
	{
		AbilityData passive = passives[i]
		
		PassiveButton button = file.passives[i]
		button.data = passive 

		Hud_SetVisible( button.icon, true )
		Hud_SetVisible( button.name, true )
		
		Hud_SetText(button.name, passive.name)
		RuiSetImage(Hud_GetRui(button.icon), "basicImage", passive.icon)
		
		printw( "showing passive", i, "max", abilities.len() )		
	}
	
	for(int i = abilities.len(); i < MAX_ABILITIES; i++)
	{
		AbilityButton button = file.abilitiesButtons[i]
		
		Hud_SetVisible( button.circle, false )
		Hud_SetVisible( button.icon, false )
		Hud_SetVisible( button.name, false )
		Hud_SetVisible( button.button, false )
		
		printw( "hiding ability icon", i, "max", MAX_ABILITIES )
	}
	
	for(int i = passives.len(); i < MAX_PASSIVES; i++)
	{
		PassiveButton button = file.passives[i]
		
		Hud_SetVisible( button.icon, false )
		Hud_SetVisible( button.name, false )
		
		printw( "hiding passive icon", i, "max", MAX_ABILITIES )
	}
	// Hud_SetVisible(
	
	// if( team == TEAM_SPIES )
	// {

	// } else if( team == TEAM_MERCS )
	// {
		
	// }
}

void function ResetButton_OnPressed( var button )
{
	//Reset choices on client
	//Reset choices icons
	
	file.choice1 = -1
	file.choice2 = -1
	
	RuiSetImage(Hud_GetRui(Hud_GetChild( file.menu, "TacticalSquare")), "basicImage", $"rui/flowstate_custom/gadgets_empty")
	Hud_SetVisible( Hud_GetChild( file.menu, "TacticalIcon"), false )
	
	RuiSetImage(Hud_GetRui(Hud_GetChild( file.menu, "UltimateSquare")), "basicImage", $"rui/flowstate_custom/gadgets_empty")
	Hud_SetVisible( Hud_GetChild( file.menu, "UltimateIcon"), false )
	
	foreach( buttonData in file.abilitiesButtons )
	{
		Hud_SetSelected( buttonData.button, false )
		LoseFocusAbility( buttonData.button )
	}

}

void function SelectAbility( var button )
{
	int id = int( Hud_GetScriptID( button ) )
	
	if( file.choice1 != -1 && file.choice2 != -1 )
		return
	
	RuiSetFloat3( Hud_GetRui( Hud_GetChild( file.menu, "AbilityIcon_" + id ) ), "basicImageColor", <0, 0, 255> )
	Hud_SetSelected( Hud_GetChild( file.menu, "AbilityButton_" + id ), true )
	
    if( file.choice1 == id || file.choice2 == id )
		return // already chosen
	
    if( file.choice1 == -1 )
	{
		file.choice1  = id
		RuiSetImage(Hud_GetRui(Hud_GetChild( file.menu, "TacticalSquare")), "basicImage", $"rui/flowstate_custom/gadgets_filled")
		Hud_SetVisible( Hud_GetChild( file.menu, "TacticalIcon"), true )
		RuiSetImage(Hud_GetRui(Hud_GetChild( file.menu, "TacticalIcon")), "basicImage", file.abilitiesButtons[id-1].data.icon)
	}
    else if( file.choice2 == -1 )
	{
		file.choice2 = id
		RuiSetImage(Hud_GetRui(Hud_GetChild( file.menu, "UltimateSquare")), "basicImage", $"rui/flowstate_custom/gadgets_filled")
		Hud_SetVisible( Hud_GetChild( file.menu, "UltimateIcon"), true )
		RuiSetImage(Hud_GetRui(Hud_GetChild( file.menu, "UltimateIcon")), "basicImage", file.abilitiesButtons[id-1].data.icon)
	}
}

void function FocusAbility( var button )
{
	int id = int( Hud_GetScriptID( button ) )
	
	//is selected? Don't focus
	//Hay dos selecciones? Don't focus
	if( file.choice1 != -1 && file.choice2 != -1 && id != 0 )
		return
	
	if( id == 0 ) //Reset button
	{
		RuiSetFloat3( Hud_GetRui( Hud_GetChild( file.menu, "ResetIcon_1" ) ), "basicImageColor", <255, 0, 0> )
	} else
	{
		if( Hud_IsSelected( Hud_GetChild( file.menu, "AbilityButton_" + id ) ) )
			return
		
		RuiSetFloat3( Hud_GetRui( Hud_GetChild( file.menu, "AbilityIcon_" + id ) ), "basicImageColor", <0, 19, 117> )
	}
}

void function LoseFocusAbility( var button )
{
	int id = int( Hud_GetScriptID( button ) )
	
	//is selected? Don't lose focus
	//Hay dos selecciones? Don't focus

	if( file.choice1 != -1 && file.choice2 != -1 && id != 0 )
		return
	
	if( id == 0 ) //Reset button
	{
		RuiSetFloat3( Hud_GetRui( Hud_GetChild( file.menu, "ResetIcon_1" ) ), "basicImageColor", <255, 255, 255> )
	} else
	{
		if( Hud_IsSelected( Hud_GetChild( file.menu, "AbilityButton_" + id ) ) )
			return
	
		RuiSetFloat3( Hud_GetRui( Hud_GetChild( file.menu, "AbilityIcon_" + id ) ), "basicImageColor", <255, 255, 255> )
	}	
}

void function InitSpiesPanel( var panel )
{
	file.spiesPanel = panel
}

void function InitMercsPanel( var panel )
{
	file.mercsPanel = panel
}

void function AddSpyAbility( string name, string weaponName, asset icon, bool isPassive)
{
	AbilityData ability = CreateAbilityData( name, weaponName, icon, isPassive )
	spyGadgets.append( ability )
	
	#if DEVELOPER
	printw( "Added Spy ability to UI VM", name )
	#endif
}

void function AddMercAbility( string name, string weaponName, asset icon, bool isPassive)
{
	AbilityData ability = CreateAbilityData( name, weaponName, icon, isPassive )
	mercGadgets.append( ability )

	#if DEVELOPER
	printw( "Added Merc ability to UI VM", name )
	#endif
}

void function ClearAbilitiesData()
{
	mercGadgets.clear()
	spyGadgets.clear()
}

AbilityData function CreateAbilityData(string name, string weaponName, asset icon, bool isPassive)
{
	AbilityData ability
	ability.name = name
	ability.weaponName = weaponName
	ability.icon = icon
	ability.isPassive = isPassive
	
	return ability
}

void function GoBackButtonFunct(var button)
{
	// if( file.choice1 == -1 && file.choice2 == -1 )
		// return
	
	ClientCommand( "AskForGadget " + file.team.tostring() + " " + file.choice1.tostring() + " " + file.choice2.tostring() )
	
	CloseAllMenus()
	
	if( IsConnected() )
	{
		// RunClientScript("CloseFRChallengesSettingsWpnSelector")
	}
}

void function OnR5RSB_Show()
{
    //
}

void function OnR5RSB_Open()
{
	//
}


void function OnR5RSB_Close()
{
	GoBackButtonFunct(null)
}