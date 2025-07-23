"scripts/resource/ui/menus/FRChallenges/challenges_list_mainmenu.res"
{
	//Screen
	//{
	//	ControlName		ImagePanel
	//	wide			%100
	//	tall			%100
	//}

	/////////////////////////////////////////////
	// 1
	//////////////////////////////////////////////
	
	// Background
	// {
		// ControlName 			RuiPanel
		// xpos					0
		// ypos					0
		// wide					266 //same as this CNest in parent
		// tall					830 //same as this CNest in parent
		// visible					0
		// image 					"ui/menu/lobby/lobby_playlist_back_01"
		// rui                     "ui/basic_border_box.rpak"
		// scaleImage				1
	// }

	Header
    {
        ControlName				ImagePanel
        InheritProperties		SubheaderBackgroundWide
        xpos					0
        ypos					0

        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	BOTTOM_LEFT
    }
	
    HeaderText
    {
        ControlName				Label
        InheritProperties		SubheaderText
		
		font					DefaultRegularFont
		allcaps					0
		
        pin_to_sibling			Header
        pin_corner_to_sibling	LEFT
        pin_to_sibling_corner	LEFT
        labelText				"#FS_SELECT_CHALLENGE"
		fgcolor_override		"252 198 3 255"
		fontHeight				"40"
    }
	
    Button0
    {
        ControlName				RuiButton
		classname               MenuButton
        wide					1024
		ypos                     "15"
        tall					50
		zpos					5
        rui                     "ui/generic_icon_button.rpak"
		isSelected 				0
        visible					1
        // cursorVelocityModifier  0.7

		sound_focus             "UI_Menu_Focus_Small"
		
        tabPosition				1
        // navDown					SldADSAdvancedSensitivity0
		
		scriptID				0
		
        pin_to_sibling          Header
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	BOTTOM_LEFT
    }
	
	Text0
	{
		ControlName					"Label"
		labelText					"Made by @CafeFPS"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"45"
		visible					1
		
		
		pin_to_sibling				Button0
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		LEFT
	}

	Score0
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button0
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew0
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text0
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
	
	/////////////////////////////////////////
	
    Button1
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  1
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              2
		scriptID				1
        pin_to_sibling           Button0
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text1
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					1
		
        pin_to_sibling           Button1
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score1
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button1
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew1
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text1
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button2
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  1
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              3
		scriptID				2
        pin_to_sibling           Button1
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text2
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					1
        pin_to_sibling           Button2
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score2
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button2
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew2
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text2
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button3
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  1
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              4
		scriptID				3
        pin_to_sibling           Button2
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text3
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					1
        pin_to_sibling           Button3
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score3
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button3
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew3
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text3
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button4
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  1
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              5
		scriptID				4
        pin_to_sibling           Button3
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text4
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					1
        pin_to_sibling           Button4
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score4
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button4
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew4
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text4
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button5
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  1
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              6
		scriptID				5
        pin_to_sibling           Button4
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text5
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					1
        pin_to_sibling           Button5
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score5
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button5
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew5
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text5
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button6
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  1
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              7
		scriptID				6
        pin_to_sibling           Button5
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text6
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					1
        pin_to_sibling           Button6
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score6
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button6
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew6
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text6
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button7
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  1
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              8
		scriptID				7
        pin_to_sibling           Button6
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text7
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					1
        pin_to_sibling           Button7
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score7
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button7
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew7
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text7
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button8
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  1
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              9
		scriptID				8
        pin_to_sibling           Button7
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text8
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					1
        pin_to_sibling           Button8
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score8
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button8
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew8
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text8
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button9
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  1
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              10
		scriptID				9
        pin_to_sibling           Button8
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text9
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					1
        pin_to_sibling           Button9
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score9
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button9
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew9
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text9
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button10
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  1
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              11
		scriptID				10
        pin_to_sibling           Button9
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text10
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					1
        pin_to_sibling           Button10
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score10
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button10
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew10
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text10
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button11
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  1
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              12
		scriptID				11
        pin_to_sibling           Button10
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text11
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					1
        pin_to_sibling           Button11
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score11
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button11
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew11
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text11
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button12
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  1
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              13
		scriptID				12
        pin_to_sibling           Button11
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text12
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					1
        pin_to_sibling           Button12
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score12
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button12
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew12
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text12
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button13
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  1
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              14
		scriptID				13
        pin_to_sibling           Button12
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text13
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					1
        pin_to_sibling           Button13
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score13
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button13
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew13
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text13
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button14
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  1
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              15
		scriptID				14
        pin_to_sibling           Button13
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text14
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					1
        pin_to_sibling           Button14
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score14
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button14
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew14
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text14
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button15
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  1
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              16
		scriptID				15
        pin_to_sibling           Button14
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text15
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					1
        pin_to_sibling           Button15
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score15
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button15
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew15
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text15
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button16
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  1
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              17
		scriptID				16
        pin_to_sibling           Button15
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text16
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					1
        pin_to_sibling           Button16
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score16
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button16
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew16
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text16
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button17
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  1
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              18
		scriptID				17
        pin_to_sibling           Button16
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text17
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					1
        pin_to_sibling           Button17
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score17
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button17
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew17
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text17
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button18
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  1
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              19
		scriptID				18
        pin_to_sibling           Button17
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text18
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					1
        pin_to_sibling           Button18
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score18
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button18
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew18
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text18
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button19
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  1
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              20
		scriptID				19
        pin_to_sibling           Button18
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text19
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					1
        pin_to_sibling           Button19
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score19
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button19
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew19
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text19
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button20
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  1
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				20
        pin_to_sibling           Button19
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text20
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					1
        pin_to_sibling           Button20
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score20
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button20
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew20
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text20
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button21
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  1
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				21
        pin_to_sibling           Button20
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text21
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					1
        pin_to_sibling           Button21
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score21
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button21
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew21
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text21
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button22
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  1
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				22
        pin_to_sibling           Button21
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text22
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					1
        pin_to_sibling           Button22
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score22
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button22
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew22
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text22
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button23
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  1
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				23
        pin_to_sibling           Button22
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text23
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					1
        pin_to_sibling           Button23
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score23
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button23
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew23
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text23
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button24
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  1
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				24
        pin_to_sibling           Button23
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text24
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					1
        pin_to_sibling           Button24
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score24
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button24
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew24
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text24
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button25
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  1
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				25
        pin_to_sibling           Button24
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text25
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					1
        pin_to_sibling           Button25
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score25
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button25
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew25
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text25
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button26
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  0
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				26
        pin_to_sibling           Button25
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text26
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					0
        pin_to_sibling           Button26
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score26
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button26
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew26
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text26
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button27
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  0
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				27
        pin_to_sibling           Button26
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text27
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					0
        pin_to_sibling           Button27
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score27
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button27
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew27
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text27
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button28
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  0
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				28
        pin_to_sibling           Button27
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text28
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					0
        pin_to_sibling           Button28
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score28
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button28
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew28
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text28
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button29
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  0
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				29
        pin_to_sibling           Button28
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text29
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					0
        pin_to_sibling           Button29
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score29
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button29
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew29
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text29
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button30
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  0
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				30
        pin_to_sibling           Button29
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text30
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					0
        pin_to_sibling           Button30
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score30
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button30
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew30
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text30
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button31
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  0
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				31
        pin_to_sibling           Button30
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text31
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					0
        pin_to_sibling           Button31
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score31
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button31
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew31
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text31
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button32
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  0
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				32
        pin_to_sibling           Button31
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text32
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					0
        pin_to_sibling           Button32
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score32
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button32
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew32
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text32
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button33
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  0
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				33
        pin_to_sibling           Button32
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text33
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					0
        pin_to_sibling           Button33
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score33
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button33
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew33
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text33
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button34
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  0
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				34
        pin_to_sibling           Button33
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text34
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					0
        pin_to_sibling           Button34
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score34
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button34
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew34
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text34
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button35
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  0
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				35
        pin_to_sibling           Button34
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text35
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					0
        pin_to_sibling           Button35
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score35
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button35
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew35
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text35
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button36
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  0
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				36
        pin_to_sibling           Button35
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text36
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					0
        pin_to_sibling           Button36
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score36
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button36
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew36
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text36
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button37
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  0
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				37
        pin_to_sibling           Button36
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text37
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					0
        pin_to_sibling           Button37
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score37
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button37
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew37
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text37
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button38
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  0
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				38
        pin_to_sibling           Button37
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text38
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					0
        pin_to_sibling           Button38
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score38
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button38
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew38
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text38
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button39
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  0
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				39
        pin_to_sibling           Button38
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text39
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					0
        pin_to_sibling           Button39
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score39
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button39
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew39
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text39
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button40
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  0
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				40
        pin_to_sibling           Button39
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text40
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					0
        pin_to_sibling           Button40
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score40
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button40
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew40
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text40
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button41
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  0
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				41
        pin_to_sibling           Button40
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text41
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					0
        pin_to_sibling           Button41
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score41
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button41
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew41
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text41
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button42
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  0
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				42
        pin_to_sibling           Button41
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text42
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					0
        pin_to_sibling           Button42
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score42
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button42
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew42
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text42
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button43
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  0
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				43
        pin_to_sibling           Button42
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text43
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					0
        pin_to_sibling           Button43
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score43
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button43
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew43
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text43
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button44
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  0
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				44
        pin_to_sibling           Button43
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text44
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					0
        pin_to_sibling           Button44
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score44
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button44
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew44
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text44
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button45
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  0
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				45
        pin_to_sibling           Button44
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text45
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					0
        pin_to_sibling           Button45
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score45
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button45
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew45
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text45
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button46
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  0
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				46
        pin_to_sibling           Button45
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text46
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					0
        pin_to_sibling           Button46
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score46
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button46
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew46
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text46
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button47
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  0
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				47
        pin_to_sibling           Button46
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text47
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					0
        pin_to_sibling           Button47
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score47
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button47
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew47
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text47
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button48
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  0
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				48
        pin_to_sibling           Button47
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text48
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					0
        pin_to_sibling           Button48
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score48
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button48
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew48
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text48
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button49
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  0
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				49
        pin_to_sibling           Button48
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text49
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					0
        pin_to_sibling           Button49
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score49
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button49
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew49
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text49
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    

    Button50
    {
        ControlName              RuiButton
        classname                MenuButton
        wide                     1024
		ypos                     "15"
        tall                     50
        zpos                     5
        rui                      "ui/generic_icon_button.rpak"
        isSelected               0
        visible                  0
        sound_focus              "UI_Menu_Focus_Small"
        tabPosition              1
		scriptID				50
        pin_to_sibling           Button49
        pin_corner_to_sibling    TOP_LEFT
        pin_to_sibling_corner    BOTTOM_LEFT
    }
    
    Text50
    {
        ControlName              "Label"
        labelText					"Made by @CafeFPS"
        xpos                     "-25"
        ypos                     "0"
        zpos                     "5"
        auto_wide_tocontents    1
        auto_tall_tocontents    1
        fontHeight               "45"
		visible					0
        pin_to_sibling           Button50
        pin_corner_to_sibling    LEFT
        pin_to_sibling_corner    LEFT
    }

	Score50
	{
		ControlName					"Label"
		labelText					"Best: 0"
		xpos						"-25"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"35"
		visible					1
		textAlignment			west
		
		pin_to_sibling				Button50
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	IsNew50
	{
		ControlName					"Label"
		labelText					"New!"
		xpos						"15"
		ypos						"0"
		zpos						"5"
		auto_wide_tocontents    1
		auto_tall_tocontents    1
		fontHeight					"25"
		visible					1
		font					TitleBoldFont
		
		fgcolor_override		"190 252 3 255"
		
		pin_to_sibling				Text50
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}
    	
}
