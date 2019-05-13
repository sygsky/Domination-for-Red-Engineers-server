// Control types
#define CT_STATIC 0
#define CT_BUTTON 1
#define CT_EDIT 2
#define CT_SLIDER 3
#define CT_COMBO 4
#define CT_LISTBOX 5
#define CT_TOOLBOX 6
#define CT_CHECKBOXES 7
#define CT_PROGRESS 8
#define CT_HTML 9
#define CT_STATIC_SKEW 10
#define CT_ACTIVETEXT 11
#define CT_TREE 12
#define CT_STRUCTURED_TEXT 13
#define CT_CONTEXT_MENU 14
#define CT_CONTROLS_GROUP 15
#define CT_XKEYDESC 40
#define CT_XBUTTON 41
#define CT_XLISTBOX 42
#define CT_XSLIDER 43
#define CT_XCOMBO 44
#define CT_ANIMATED_TEXTURE 45
#define CT_OBJECT 80
#define CT_OBJECT_ZOOM 81
#define CT_OBJECT_CONTAINER 82
#define CT_OBJECT_CONT_ANIM 83
#define CT_LINEBREAK 98
#define CT_USER 99
#define CT_MAP 100
#define CT_MAP_MAIN 101 // Static styles
#define ST_POS 0x0F
#define ST_HPOS 0x03
#define ST_VPOS 0x0C
#define ST_LEFT 0x00
#define ST_RIGHT 0x01
#define ST_CENTER 0x02
#define ST_DOWN 0x04
#define ST_UP 0x08
#define ST_VCENTER 0x0c
#define ST_TYPE 0xF0
#define ST_SINGLE 0
#define ST_MULTI 16
#define ST_TITLE_BAR 32
#define ST_PICTURE 48
#define ST_FRAME 64
#define ST_BACKGROUND 80
#define ST_GROUP_BOX 96

#define ST_GROUP_BOX2 112
#define ST_HUD_BACKGROUND 128
#define ST_TILE_PICTURE 144
#define ST_WITH_RECT 160
#define ST_LINE 176
#define FontM "Zeppelin32"
#define Size_Main_Small 0.027
#define Size_Main_Normal 0.04
#define Size_Text_Default Size_Main_Normal
#define Size_Text_Small Size_Main_Small
#define Color_White {1, 1, 1, 1}
#define Color_Main_Foreground1 Color_White
#define Color_Text_Default Color_Main_Foreground1

#include "x_setup.sqf"

class X3_RscText
{
	access = ReadAndWrite;
	type = CT_STATIC;
	idc = -1;
	style = ST_CENTER;
	w = 0.05;
	h = 0.05;
	font = FontM;
	sizeEx = Size_Text_Default;
	colorBackground[] = {0, 0, 0, 0};
	colorText[] = Color_Text_Default;
	text = "";
};

// ####
class XC_RscText
{
	type = CT_STATIC;
	idc = -1;
	style = ST_LEFT;
	x = 0.0;
	y = 0.0;
	w = 0.3;
	h = 0.03;
	sizeEx = 0.023;
	colorBackground[] = {0.5, 0.5, 0.5, 0.75};
	colorText[] = { 0, 0, 0, 1 };
	font = FontM;
	text = "";
};

// ####
class XD_StatusDialog
{
	idd = 11001;
	movingEnable = 1;
	controlsBackground[] = {XD_BackGround};
	// ####
	objects[] = {};
	controls[] =
	{
		XD_SideMissionTxt,
 		XD_CloseButton,
		XD_MainTargetNumber,
		XD_MainTarget, // main target name
		XD_PlayerHealth,
		XD_PlayerFatigue,
		XD_SecondaryCaption,
		XD_SecondaryTxt,
		XD_WeatherInfo,
		XD_WeatherInfoCaption,
		XD_FixHeadBugButton,
		XD_SettingsButton,
		XD_TeamStatusButton,
		XD_Map,
		XD_ShowSideButton,
		XD_ShowMainButton,
		XD_HintCaption,
		XD_RankPicture,
		XD_RankCaption,
		XD_RankString
#ifdef __TT__
		,XD_NPointsCaption,
		XD_GamePoints,
		XD_KillsCaption,
		XD_KillPoints
#endif
#ifdef __ACE__
		,XD_MapBlack
#endif
	};

	class XD_BackGround : XC_RscText
	{
		x = 0.1;
		y = 0.1;
		w = 0.8;
		h = 0.8;
		colorBackground[] = {0.5, 0.5, 0.5, 0.3};
	};

  // ####
	class XD_CloseButton
	{
		idc = -1;
		type = CT_BUTTON;
		style = ST_CENTER;
		default = false;
		font = FontM;
		sizeEx = 0.03;
		colorText[] = { 0, 0, 0, 1 };
		colorFocused[] = { 1, 0, 0, 1 }; // border color for focused state
		colorDisabled[] = { 0, 0, 1, 0.7 }; // text color for disabled state
		colorBackground[] = { 1, 1, 1, 0.5 };
		colorBackgroundDisabled[] = { 1, 1, 1, 0.5 }; // background color for disabled state
		colorBackgroundActive[] = { 1, 1, 1, 0.7 }; // background color for active state
		offsetX = 0.003;
		offsetY = 0.003;
		offsetPressedX = 0.002;
		offsetPressedY = 0.002;
		colorShadow[] = { 0, 0, 0, 0.5 };
		colorBorder[] = { 0, 0, 0, 1 };
		borderSize = 0;
		soundEnter[] = { "", 0, 1 }; // no sound
		soundPush[] = { "\ca\ui\data\sound\new1", 0.1, 1 };
		soundClick[] = { "", 0, 1 }; // no sound
		soundEscape[] = { "", 0, 1 }; // no sound
		x = 0.68;
		y = 0.82;
		w = 0.2;
		h = 0.05;
		text = $STR_SYS_53; //"Закрыть"
		action = "closeDialog 0;";
	};
	class XD_FixHeadBugButton
	{
		idc = -1;
		type = CT_BUTTON;
		style = ST_CENTER;
		default = false;
		font = FontM;
		sizeEx = 0.02;
		colorText[] = { 0, 0, 0, 1 };
		colorFocused[] = { 1, 0, 0, 1 }; // border color for focused state
		colorDisabled[] = { 0, 0, 1, 0.7 }; // text color for disabled state
		colorBackground[] = { 1, 1, 1, 0.2 };
		colorBackgroundDisabled[] = { 1, 1, 1, 0.5 }; // background color for disabled state
		colorBackgroundActive[] = { 1, 1, 1, 0.4 }; // background color for active state
		offsetX = 0.003;
		offsetY = 0.003;
		offsetPressedX = 0.002;
		offsetPressedY = 0.002;
		colorShadow[] = { 0, 0, 0, 0.5 };
		colorBorder[] = { 0, 0, 0, 1 };
		borderSize = 0;
		soundEnter[] = { "", 0, 1 }; // no sound
		soundPush[] = { "\ca\ui\data\sound\new1", 0.1, 1 };
		soundClick[] = { "", 0, 1 }; // no sound
		soundEscape[] = { "", 0, 1 }; // no sound
		x = 0.68;
		y = 0.72;
		w = 0.2;
		h = 0.05;
		text = $STR_SYS_1150; //"Restore veg/fences";
		action = "closeDialog 0;_bt = player spawn XsFixHeadBug";
//		action = "closeDialog 0; _handle = [0,5] execVM ""dlg\resurrect_dlg.sqf""";
	};

	class XD_SettingsButton
	{
		idc = -1;
		type = CT_BUTTON;
		style = ST_CENTER;
		default = false;
		font = FontM;
		sizeEx = 0.02;
		colorText[] = { 0, 0, 0, 1 };
		colorFocused[] = { 1, 0, 0, 1 }; // border color for focused state
		colorDisabled[] = { 0, 0, 1, 0.7 }; // text color for disabled state
		colorBackground[] = { 1, 1, 1, 0.2 };
		colorBackgroundDisabled[] = { 1, 1, 1, 0.5 }; // background color for disabled state
		colorBackgroundActive[] = { 1, 1, 1, 0.4 }; // background color for active state
		offsetX = 0.003;
		offsetY = 0.003;
		offsetPressedX = 0.002;
		offsetPressedY = 0.002;
		colorShadow[] = { 0, 0, 0, 0.5 };
		colorBorder[] = { 0, 0, 0, 1 };
		borderSize = 0;
		soundEnter[] = { "", 0, 1 }; // no sound
		soundPush[] = { "\ca\ui\data\sound\new1", 0.1, 1 };
		soundClick[] = { "", 0, 1 }; // no sound
		soundEscape[] = { "", 0, 1 }; // no sound
		x = 0.68;
		y = 0.62;
		w = 0.2;
		h = 0.05;
		text = $STR_SYS_57; //"Настройки";
		action = "CloseDialog 0;_handle = [] execVM ""x_scripts\x_settingsdialog.sqf""";
	};

	class XD_TeamStatusButton
	{
		idc = 11009;
		type = CT_BUTTON;
		style = ST_CENTER;
		default = false;
		font = FontM;
		sizeEx = 0.02;
		colorText[] = { 0, 0, 0, 1 };
		colorFocused[] = { 1, 0, 0, 1 }; // border color for focused state
		colorDisabled[] = { 0, 0, 1, 0.7 }; // text color for disabled state
		colorBackground[] = { 1, 1, 1, 0.2 };
		colorBackgroundDisabled[] = { 1, 1, 1, 0.5 }; // background color for disabled state
		colorBackgroundActive[] = { 1, 1, 1, 0.4 }; // background color for active state
		offsetX = 0.003;
		offsetY = 0.003;
		offsetPressedX = 0.002;
		offsetPressedY = 0.002;
		colorShadow[] = { 0, 0, 0, 0.5 };
		colorBorder[] = { 0, 0, 0, 1 };
		borderSize = 0;
		soundEnter[] = { "", 0, 1 }; // no sound
		soundPush[] = { "\ca\ui\data\sound\new1", 0.1, 1 };
		soundClick[] = { "", 0, 1 }; // no sound
		soundEscape[] = { "", 0, 1 }; // no sound
		x = 0.68;
		y = 0.52;
		w = 0.2;
		h = 0.05;
		text = $STR_TSD9_01; //"Статус команды";
		action = "CloseDialog 0;xhandle = player execVM ""x_scripts\x_teamstatus.sqf"";";
	};

	class XD_ShowSideButton
	{
		idc = -1;
		type = CT_BUTTON;
		style = ST_CENTER;
		default = false;
		font = FontM;
		sizeEx = 0.02;
		colorText[] = { 1, 1, 1, 1 };
		colorFocused[] = {1, 1, 1, 0.0}; // border color for focused state
		colorDisabled[] = { 0, 0, 1, 0.7 }; // text color for disabled state
		colorBackground[] = {1, 1, 1, 0.0};
		colorBackgroundDisabled[] = { 1, 1, 1, 0.5 }; // background color for disabled state
		colorBackgroundActive[] = {1, 1, 1, 0.0}; // background color for active state
		offsetX = 0.003;
		offsetY = 0.003;
		offsetPressedX = 0.002;
		offsetPressedY = 0.002;
		colorShadow[] = {1, 1, 1, 0.0};
		colorBorder[] = {1, 1, 1, 0.0};
		borderSize = 0;
		soundEnter[] = { "", 0, 1 }; // no sound
		soundPush[] = { "\ca\ui\data\sound\new1", 0.1, 1 };
		soundClick[] = { "", 0, 1 }; // no sound
		soundEscape[] = { "", 0, 1 }; // no sound
		x = 0.13;
		y = 0.07;
		w = 0.16;
		h = 0.1;
		text = $STR_SYS_58;//"Дополнительное задание:";
		action = "xhandle = [0] execVM ""x_scripts\x_showsidemain.sqf"";";
	};

	class XD_ShowMainButton
	{
		idc = -1;
		type = CT_BUTTON;
		style = ST_CENTER;
		default = false;
		font = FontM;
		sizeEx = 0.03;
		colorText[] = { 1, 1, 1, 1 };
		colorFocused[] = {1, 1, 1, 0.0}; // border color for focused state
		colorDisabled[] = { 0, 0, 1, 0.7 }; // text color for disabled state
		colorBackground[] = {1, 1, 1, 0.0};
		colorBackgroundDisabled[] = { 1, 1, 1, 0.5 }; // background color for disabled state
		colorBackgroundActive[] = {1, 1, 1, 0.0}; // background color for active state
		offsetX = 0.003;
		offsetY = 0.003;
		offsetPressedX = 0.002;
		offsetPressedY = 0.002;
		colorShadow[] = {1, 1, 1, 0.0};
		colorBorder[] = {1, 1, 1, 0.0};
		borderSize = 0;
		soundEnter[] = { "", 0, 1 }; // no sound
		soundPush[] = { "\ca\ui\data\sound\new1", 0.1, 1 };
		soundClick[] = { "", 0, 1 }; // no sound
		soundEscape[] = { "", 0, 1 }; // no sound
		x = 0.68;
		y = 0.13;
		w = 0.125;
		h = 0.1;
		text = $STR_SYS_59; //"Главная цель:";
		action = "xhandle = [1] execVM ""x_scripts\x_showsidemain.sqf"";";
	};

	class XD_SideMissionTxt : XC_RscText
	{
		idc = 11002;
		style = ST_MULTI; // defined constant
		sizeEx = 0.018;
		lineSpacing = 1;
		colorBackground[] = { 0.9, 0.9, 0.9, 0.4 };
		x = 0.12;
		y = 0.13;
		w = 0.45;
		h = 0.15;
		text = "$STR_SYS_58_2";
	};

	class XD_SecondaryCaption : XC_RscText
	{
		x = 0.12;
		y = 0.25;
		w = 0.25;
		h = 0.1;
		sizeEx = 0.02;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = $STR_SYS_58_1; // "Дополнительный приказ:";
//		action = "xhandle = [1] execVM ""x_scripts\x_showsidemain.sqf"";";
	};

	class XD_SecondaryTxt : XC_RscText
	{
		idc = 11007;
		style = ST_MULTI; // defined constant
		sizeEx = 0.018;
		lineSpacing = 1;
		colorBackground[] = { 0.9, 0.9, 0.9, 0.4 };
		x = 0.12;
		y = 0.31;
		w = 0.45;
		h = 0.09;
		text = "$STR_SYS_58_2";
	};

	class XD_WeatherInfoCaption : XC_RscText
	{
		x = 0.12;
		y = 0.369;
		w = 0.45;
		h = 0.1;
		sizeEx = 0.02;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = $STR_SYS_180; // "По сводкам метеоцентра..."
	};

	class XD_WeatherInfo : XC_RscText
	{
		idc = 11013;
		style = ST_MULTI; // defined constant
		sizeEx = 0.018;
		lineSpacing = 1;
		colorBackground[] = { 0.9, 0.9, 0.9, 0.4 };
		x = 0.12;
		y = 0.43;
		w = 0.45;
		h = 0.09;
		text = "Метеоинформация";
	};

	class XD_MainTargetNumber : XC_RscText
	{
		idc = 11006;
		x = 0.81;
		y = 0.13;
		w = 0.25;
		h = 0.1;
		sizeEx = 0.03;
		colorText[] = { 1, 1, 1, 1 };
		colorBackground[] = {1, 1, 1, 0.0};
		text = "0/0";
	};

    // Main target name (town/airbase)
	class XD_MainTarget : XC_RscText
	{
		idc = 11003;
		x = 0.68;
		y = 0.17;
		w = 0.25;
		h = 0.1;
		sizeEx = 0.035;
		colorText[] = { 0, 1, 0, 1 };
		colorBackground[] = {1, 1, 1, 0.0};
		text = "Нет цели";
		action = "xhandle = [1] execVM ""x_scripts\x_showsidemain.sqf"";";
	};

	class XD_PlayerHealth : XC_RscText
	{
		idc = 11015;
		x = 0.68;
		y = 0.34;
		w = 0.25;
		h = 0.1;
		//sizeEx = 0.03;
		colorText[] = { 1, 1, 1, 1 };
		colorBackground[] = {1, 1, 1, 0.0};
		text = "Your health is 9.9";
	};

	class XD_PlayerFatigue : XC_RscText
	{
		idc = 11016;
		x = 0.68;
		y = 0.37;
		w = 0.25;
		h = 0.1;
		//sizeEx = 0.03;
		colorText[] = { 1, 1, 1, 1 };
		colorBackground[] = {1, 1, 1, 0.0};
		text = "Fatigue is 9.9"; // Усталость
	};
	
#ifdef __TT__
	class XD_NPointsCaption : XC_RscText
	{
		idc = -1;
		x = 0.68;
		y = 0.23;
		w = 0.25;
		h = 0.1;
		sizeEx = 0.025;
		colorText[] = { 1, 1, 1, 1 };
		colorBackground[] = {1, 1, 1, 0.0};
		text = "Points (West : Racs):";
	};
	class XD_GamePoints : XC_RscText
	{
		idc = 11011;
		x = 0.68;
		y = 0.26;
		w = 0.25;
		h = 0.1;
		sizeEx = 0.025;
		colorText[] = { 1, 0, 0, 1 };
		colorBackground[] = {1, 1, 1, 0.0};
		text = "200 : 300";
	};
	class XD_KillsCaption : XC_RscText
	{
		idc = -1;
		x = 0.68;
		y = 0.30;
		w = 0.25;
		h = 0.1;
		sizeEx = 0.025;
		colorText[] = { 1, 1, 1, 1 };
		colorBackground[] = {1, 1, 1, 0.0};
		text = "Kills (West : Racs):";
	};
	class XD_KillPoints : XC_RscText
	{
		idc = 11012;
		x = 0.68;
		y = 0.33;
		w = 0.25;
		h = 0.1;
		sizeEx = 0.025;
		colorText[] = { 1, 0, 0, 1 };
		colorBackground[] = {1, 1, 1, 0.0};
		text = "300 : 200";
	};
#endif

	class XD_Map : RscMapControl
	{
		idc = 11010;
		colorBackground[] = { 0.9, 0.9, 0.9, 0.9 };
		x = 0.12;
		y = 0.55;
		w = 0.45;
		h = 0.33;
		default = true;
		showCountourInterval = false;
	};
#ifdef __ACE__
	class XD_MapBlack : XC_RscText
	{
		idc = 111111;
		x = 0.12;
		y = 0.55;
		w = 0.45;
		h = 0.33;
		sizeEx = 0.023;
		colorText[] = {1, 1, 1, 1};
		colorBackground[] = {0, 0, 0, 1};
		text = $STR_SYS_12; //"У вас нет карты!!!";
	};
#endif
	class XD_HintCaption : XC_RscText
	{
		idc = -1;
		x = 0.57;
		y = 0.07;
		w = 0.35;
		h = 0.1;
		sizeEx = 0.015;
		colorText[] = {0.5, 0.5, 0.5, 0.8};
		colorBackground[] = {1, 1, 1, 0.0};
		text =  $STR_SYS_13; //"Клик на заголовок -> центрирование карты на цель";
	};

	class XD_RankCaption : XC_RscText
	{
		x = 0.68;
		y = 0.40;
		w = 0.25;
		h = 0.1;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = $STR_SYS_46; // "Ваше звание:"
	};

	class XD_RankPicture : RscPicture
	{
		idc = 12010;
		x=0.69; y=0.465; w=0.02; h=0.025;
		text="";
		sizeEx = 256;
		colorText[] = { 0, 0, 0, 1 };
	};

	class XD_RankString : XC_RscText
	{
		idc = 11014;
		x = 0.72;
		y = 0.428;
		w = 0.25;
		h = 0.1;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = "";
	};
};
