#define CT_STATIC           0
#define CT_BUTTON           1
#define CT_EDIT             2
#define CT_SLIDER           3
#define CT_COMBO            4
#define CT_LISTBOX          5
#define CT_TOOLBOX          6
#define CT_CHECKBOXES       7
#define CT_PROGRESS         8
#define CT_HTML             9
#define CT_STATIC_SKEW      10
#define CT_ACTIVETEXT       11
#define CT_TREE             12
#define CT_STRUCTURED_TEXT  13
#define CT_CONTEXT_MENU     14
#define CT_CONTROLS_GROUP   15
#define CT_XKEYDESC         40
#define CT_XBUTTON          41
#define CT_XLISTBOX         42
#define CT_XSLIDER          43
#define CT_XCOMBO           44
#define CT_ANIMATED_TEXTURE 45
#define CT_OBJECT           80
#define CT_OBJECT_ZOOM      81
#define CT_OBJECT_CONTAINER 82
#define CT_OBJECT_CONT_ANIM 83
#define CT_LINEBREAK        98
#define CT_USER             99
#define CT_MAP              100
#define CT_MAP_MAIN         101

// Static styles
#define ST_POS            0x0F
#define ST_HPOS           0x03
#define ST_VPOS           0x0C
#define ST_LEFT           0x00
#define ST_RIGHT          0x01
#define ST_CENTER         0x02
#define ST_DOWN           0x04
#define ST_UP             0x08
#define ST_VCENTER        0x0c

#define ST_TYPE           0xF0
#define ST_SINGLE         0
#define ST_MULTI          16
#define ST_TITLE_BAR      32
#define ST_PICTURE        48
#define ST_FRAME          64
#define ST_BACKGROUND     80
#define ST_GROUP_BOX      96
#define ST_GROUP_BOX2     112
#define ST_HUD_BACKGROUND 128
#define ST_TILE_PICTURE   144
#define ST_WITH_RECT      160
#define ST_LINE           176

#define ST_SHADOW         0x100
#define ST_NO_RECT        0x200
#define ST_KEEP_ASPECT_RATIO  0x800

// Listbox styles
#define LB_TEXTURES       0x10
#define LB_MULTI          0x20

#define ST_TITLE          ST_TITLE_BAR + ST_CENTER

#define ReadAndWrite 0

#define ProcTextWhite "#(argb,8,8,3)color(1,1,1,1)"
#define ProcTextEmpty "#(argb,8,8,3)color(1,1,1,0)"
#define ProcTextBlack "#(argb,8,8,3)color(0,0,0,1)"
#define ProcTextGray "#(argb,8,8,3)color(0.3,0.3,0.3,1)"
#define ProcTextRed "#(argb,8,8,3)color(1,0,0,1)"
#define ProcTextGreen "#(argb,8,8,3)color(0,1,0,1)"
#define ProcTextBlue "#(argb,8,8,3)color(0,0,1,1)"

//Colors
#define Color_WhiteDark 			{1, 1, 1, 0.5}
#define Color_White					{1, 1, 1, 1}
#define Color_Black 				{0, 0, 0, 1}
#define Color_Gray 					{1, 1, 1, 0.5}
#define Color_GrayLight 			{0.6, 0.6, 0.6, 1}
#define Color_GrayDark 				{0.2, 0.2, 0.2, 1}
#define Color_DarkRed 				{0.5, 0.1, 0, 0.5}
#define Color_Green 				{0.8, 0.9, 0.4, 1}
#define Color_Orange 				{0.9, 0.45, 0.1, 1}
#define Color_Red 					{0.9, 0.2, 0.2, 1}
#define Color_Blue 					{0.2, 0.2, 0.9, 1}
#define Color_NoColor				{0, 0, 0, 0}

#define CA_UI_element_background 		{1, 1, 1, 0.7}
#define CA_UI_background 				{0.6, 0.6, 0.6, 0.4}
#define CA_UI_help_background 			{0.2, 0.1, 0.1, 0.7}
#define CA_UI_title_background			{0.24, 0.47, 0.07, 1.0}
#define CA_UI_green						{0.84,1,0.55,1}

//Colors background
#define CA_UI_background 			{0.6, 0.6, 0.6, 0.4}
#define Color_MainBack 				{1, 1, 1, 0.9} //hlavni pozadi

//Font Size
#define TextSize_IGUI_normal 		0.023 // test //19/768
#define TextSize_small 				0.022 //16/768
#define TextSize_normal 			0.024 //19/768
#define TextSize_medium 			0.027 //23/768
#define TextSize_large  			0.057 //44/768

//Definice z Coru
//Standard static text.
class RscText
{
	access = ReadAndWrite;
	idc = -1;
	type = CT_STATIC;style = ST_LEFT;
	w = 0.1; h = 0.05;
	font = Zeppelin32;
	sizeEx = TextSize_IGUI_normal;
	colorBackground[] = Color_NoColor;
	colorText[] = Color_Black;
	text = "";
};
//Small static text.
class RscTextSmall: RscText
{
	h = 0.03;
	sizeEx = TextSize_small;
};
//Standard static text title.
class RscTitle: RscText
{
	style = ST_CENTER;
	x = 0.15;y = 0.06;
	w = 0.7;
};
class RscPicture
{
	access = ReadAndWrite;
	idc = -1;
	type = CT_STATIC;style = ST_PICTURE;
	colorBackground[] = Color_NoColor;
	colorText[] = Color_White;
	font = Zeppelin32;
	sizeEx = 0;
	lineSpacing = 0;
	text = "";
};
class RscActiveText
{
	access = ReadAndWrite;
	type = CT_ACTIVETEXT;
	style = ST_CENTER;
	h = 0.05;
	w = 0.15;
	font = Zeppelin32;
	sizeEx = TextSize_IGUI_normal;
	color[] = Color_Black;
	colorActive[] = CA_UI_green;
	soundEnter[] = {"", 0.1, 1};
	soundPush[] = {"", 0.1, 1};
	soundClick[] = {"", 0.1, 1};
	soundEscape[] = {"", 0.1, 1};
	text = "";
	default = 0;
};

class RscListBox
{
	idc = -1;
	access = ReadAndWrite;
	style = LB_TEXTURES;
	type = CT_LISTBOX;
	w = 0.4;h = 0.4;
	font = Zeppelin32;
	sizeEx = TextSize_small;
	rowHeight = 0;
	color[] = Color_Black;
	colorText[] = Color_Black;
	colorScrollbar[] = Color_White;
	colorSelect[] = Color_Black;  //First color of selected Text
	colorSelect2[] = Color_Black;  //Second color of selected Text
	colorSelectBackground[] = Color_GrayLight;  // Normal // Grey //First color of selected Backgrnd
	colorSelectBackground2[] = CA_UI_green;  //Active // Green //Second color of selected Backgrnd
	period = 0; //No blinking
	colorBackground[] = CA_UI_background;
	soundSelect[] = {"", 0.1, 1};
};

//Standard button.
class RscButton
{
	// common control items
	access = ReadAndWrite;
	type = CT_BUTTON;style = ST_LEFT;
	x = 0; y = 0;
	w = 0.3; h = 0.1;
	
	// text properties
	text = "";
	font = Zeppelin32;
	sizeEx = TextSize_IGUI_normal;
	colorText[] = Color_Black;
	colorDisabled[] = Color_Gray;
	
	// background properties
	colorBackground[] = Color_GrayLight;
	colorBackgroundDisabled[] = Color_GrayLight;
	colorBackgroundActive[] = Color_Orange;
	offsetX = 0.004; // distance of background from shadow
	offsetY = 0.004;
	offsetPressedX = 0.002; // distance of background from shadow when button is pressed
	offsetPressedY = 0.002;
	colorFocused[] = Color_Black; // color of the rectangle around background when focused
	
	// shadow properties
	colorShadow[] = Color_Black;
	
	// border properties
	colorBorder[] = Color_Black;
	borderSize = 0.008; // when negative, the border is on the right side of background
	
	// sounds
	soundEnter[] = {"", 0.1, 1};
	soundPush[] = {"", 0.1, 1};
	soundClick[] = {"", 0.1, 1};
	soundEscape[] = {"", 0.1, 1};
};


//Standard structured text.
class RscStructuredText
{
	access = ReadAndWrite;
	type = CT_STRUCTURED_TEXT;
	idc = -1;
	style = 0;
	h = 0.05;
	text = "";
	size = TextSize_IGUI_normal;
	colorText[] = Color_Black;

	class Attributes
	{
		font = Zeppelin32;
		color = "#ffffff";
		align = "center";
		shadow = true;
	};
};

//Standard controls group.
class RscControlsGroup
{
  type = CT_CONTROLS_GROUP;
  idc = -1;
  style = 0;
  x = 0; y = 0;
  w = 1; h = 1;

  class VScrollbar
  {
    color[] = Color_Black;
    width = 0.021;
  };

  class HScrollbar
  {
    color[] = Color_Black;
    height = 0.028;
  };

  class Controls {};
};