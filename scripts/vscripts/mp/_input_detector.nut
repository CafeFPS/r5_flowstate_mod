globalize_all_functions

void function StartInputDetectorForPlayer( entity player )
{
	thread Thread_CheckInput( player ) //Todo(mk): move to code
	
	AddButtonPressedPlayerInputCallback( player, IN_MOVELEFT, SetInput_IN_MOVELEFT )
	AddButtonPressedPlayerInputCallback( player, IN_MOVERIGHT, SetInput_IN_MOVERIGHT )
	AddButtonPressedPlayerInputCallback( player, IN_BACK, SetInput_IN_BACK )
	AddButtonPressedPlayerInputCallback( player, IN_FORWARD, SetInput_IN_FORWARD )	
}

void function Thread_CheckInput( entity player )
{
	int timesCheckedForNewInput = 0
	int previousInput = -1
	bool isCheckerRunning
	bool previousMnkState = false
	bool mnkStateInitialized = false

    for( ; ; )
	{
		wait 0.1 //was 0.1
		
		if( !IsValid( player ) )
			break

		int typeOfInput = GetInput( player )
		
		if ( !isCheckerRunning && typeOfInput == 1 )
			player.p.movevalue = 0
		
		if( typeOfInput == 9 )
			continue
		
		//Set networked var only when input state changes
		bool currentMnkState = (player.p.input == 0)
		
		if( !mnkStateInitialized || currentMnkState != previousMnkState )
		{
			if( currentMnkState )
			{
				#if DEVELOPER
				if( player == gp()[0] )
					printw( player.GetPlayerName() + " is mnk" )
				#endif
				player.SetPlayerNetBool( "FS_PlayerIsMnk", true )
			}
			else
			{
				#if DEVELOPER
				if( player == gp()[0] )
					printw( player.GetPlayerName() + " is rolla" )
				#endif
				player.SetPlayerNetBool( "FS_PlayerIsMnk", false )
			}
			
			previousMnkState = currentMnkState
			mnkStateInitialized = true
		}
		
		if( isCheckerRunning )
		{
			if( typeOfInput == previousInput )
			{
				if( timesCheckedForNewInput >= 4 )
				{
					isCheckerRunning = false
					timesCheckedForNewInput = 0

					if ( InvalidInput( typeOfInput, player.p.movevalue ) ) 
					{				
                       // HandlePlayer( player ) //not used yet
					   player.p.input = 1					
                    }
					else
					{
                        //sqprint("Player did change input! Old: " + player.p.input.tostring() + " - New: " + typeOfInput.tostring());
                        player.p.input = typeOfInput
						player.p.lastInputChangeTime = Time()
						
						player.Signal( "InputChanged" ) //registered signal in CPlayer class		
                    }
					continue
				}
				timesCheckedForNewInput++
				//sqprint( "Checking if it's a valid input change..." + typeOfInput.tostring() + previousInput.tostring() + " - Times checked: " + timesCheckedForNewInput.tostring() )
			}
			else
			{
				timesCheckedForNewInput = 0
				isCheckerRunning = false
				//sqprint( "Player did NOT change input. It was a false alarm." )
			}
			
			previousInput = typeOfInput
			continue
		}

		if( player.p.input != typeOfInput && !isCheckerRunning )
		{
			//sqprint( "Input change check triggered. " + player.p.input.tostring() + typeOfInput.tostring() + " - Did player change input?" )
			isCheckerRunning = true
			previousInput = typeOfInput
			continue
		}
    }
}//ty cafe for fixed thread

bool function InvalidInput( int input_type, int movevalue )
{
	if ( movevalue == 0 && input_type == 0 )
		return true
	
	return false	
}

//(mk): not currently used
void function HandlePlayer( entity player )
{
	string id = player.GetPlatformUID()
	int action = GetCurrentPlaylistVarInt( "invalid_input_action", 1 )
	string msg = GetCurrentPlaylistVarString( "invalid_input_msg", "Invalid Input Device" )
	bool log_invalid_input = GetCurrentPlaylistVarBool( "log_invalid_input", false )
	
	switch (action)
	{
	
		case 1:
			printt("Action: keeping as controller")
			player.p.input = 1
			break
		case 2:
			printt("Action: kick")
			//KickPlayerById( id, msg )
			break
		case 3:
			printt("Action: Ban")
			//BanPlayerById( id, msg )
			break
	
	}
}

//Made by @CafeFPS
int function GetInput( entity player )
{	
    float value = player.GetInputAxisRight() == 0 ? player.GetInputAxisForward() : player.GetInputAxisRight() 
	
    if( value == 0 || value == 0.5 )
		return 9
		
	//sqprint( "Right axis value: " + player.GetInputAxisRight().tostring() + " --- Player forward axis: " + player.GetInputAxisForward())
	//sqprint( "Value: " + value.tostring() + " Length:" + value.tostring().len().tostring() )
    
	return value.tostring().len() < 5 ? 0 : 1
}

void function SetInput_IN_MOVELEFT( entity player )
{
	//sqprint( "Setting movevalue for " + player.GetPlayerName() + " to 3" )
	player.p.movevalue = 3
}

void function SetInput_IN_MOVERIGHT( entity player )
{
	//sqprint("Setting movevalue for " + player.GetPlayerName() + " to 4")
	player.p.movevalue = 4
}

void function SetInput_IN_BACK( entity player )
{	
	//sqprint("Setting movevalue for " + player.GetPlayerName() + " to 5")
	player.p.movevalue = 5
}

void function SetInput_IN_FORWARD( entity player )
{	
	//sqprint("Setting movevalue for " + player.GetPlayerName() + " to 6")
	player.p.movevalue = 6
}
