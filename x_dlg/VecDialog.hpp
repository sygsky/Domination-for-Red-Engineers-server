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

// ####
class XD_VecDialog
{
	idd = 11002;
	movingEnable = 1;
	controlsBackground[] = {XD_BackGround};
	// ####
	objects[] = {};
	controls[] =
	{
		XD_VecDialogCaption,
		XD_CloseButton,
		XD_AmmoBoxCaption,
		XD_VecPicture,
		XD_VecDialogCaption2,
		XD_BoxPicture,
		XD_BoxPicture2,
		XD_DropAmmoButton,
		XD_CreateListbox,
		XD_CreateVecCaption,
		XD_CreateVecButton,
		XD_LoadAmmoButton,
		dtext2,
		XD_TeleportButton
	};

	class XD_BackGround : XC_RscText
	{
		x = 0.2;
		y = 0.2;
		w = 0.6;
		h = 0.6;
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
		x = 0.63;
		y = 0.74;
		w = 0.15;
		h = 0.04;
		text = $STR_SYS_53; //"Закрыть";
		action = "closeDialog 0;";
	};
	class XD_VecDialogCaption : XC_RscText
	{
		x = 0.22;
		y = 0.2;
		w = 0.25;
		h = 0.1;
		sizeEx = 0.04;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = $STR_SYS_287; //"Диалог ТС";
	};
	class XD_VecPicture : RscPicture
	{
		idc = 44444;
		x=0.43; y=0.197; w=0.16; h=0.1;
		text="";
		sizeEx = 256;
	};
	class XD_VecDialogCaption2 : XC_RscText
	{
		idc = 44445;
		x = 0.6;
		y = 0.2;
		w = 0.25;
		h = 0.1;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = $STR_SYS_286; //"Вертолёт 1";
	};
	class XD_AmmoBoxCaption : XC_RscText
	{
		idc = 44454;
		x = 0.26;
		y = 0.30;
		w = 0.25;
		h = 0.1;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = $STR_SYS_285; //"Состояние грузового отсека:";
	};
	class XD_BoxPicture : RscPicture
	{
		idc = 44446;
		x=0.25; y=0.35; w=0.17; h=0.17;
		text="";
		sizeEx = 256;
	};
	class XD_BoxPicture2 : RscPicture
	{
		idc = 44447;
		x=0.275; y=0.375; w=0.12; h=0.12;
		text="";
		sizeEx = 256;
	};
	class XD_DropAmmoButton
	{
		idc = 44448;
		type = CT_BUTTON;
		style = ST_CENTER;
		font = FontM;
		sizeEx = 0.02;
		colorText[] = { 0, 0, 0, 0.8 };
		colorFocused[] = { 1, 0, 0, 1 }; // border color for focused state
		colorDisabled[] = { 1, 0, 0, 0.2 }; // text color for disabled state
		colorBackground[] = { 1, 1, 1, 0.5 };
		colorBackgroundDisabled[] = { 1, 1, 1, 0.2 }; // background color for disabled state
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
		x = 0.26;
		y = 0.52;
		w = 0.15;
		h = 0.04;
		text = $STR_SYS_284; //"Drop box"
		action = "closeDialog 0;if (!d_old_ammobox_handling) then {_handle = [vehicle player, player] execVM ""x_scripts\x_dropammobox2.sqf""} else {_handle = [vehicle player, player] execVM ""x_scripts\x_dropammobox_old.sqf""}";
	};
	class XD_LoadAmmoButton
	{
		idc = 44452;
		type = CT_BUTTON;
		style = ST_CENTER;
		font = FontM;
		sizeEx = 0.02;
		colorText[] = { 0, 0, 0, 0.8 };
		colorFocused[] = { 1, 0, 0, 1 }; // border color for focused state
		colorDisabled[] = { 1, 0, 0, 0.2 }; // text color for disabled state
		colorBackground[] = { 1, 1, 1, 0.5 };
		colorBackgroundDisabled[] = { 1, 1, 1, 0.2 }; // background color for disabled state
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
		x = 0.26;
		y = 0.60;
		w = 0.15;
		h = 0.04;
		text = $STR_SYS_283; //"Load box"
		action = "closeDialog 0;_handle = [vehicle player, player] execVM ""x_scripts\x_loaddropped.sqf""";
	};
	class XD_CreateVecCaption : XC_RscText
	{
		idc = 44450;
		x = 0.55;
		y = 0.30;
		w = 0.25;
		h = 0.1;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = $STR_SYS_282; //"Выгрузить ТС:";
	};
	class XD_CreateListbox : RscListBox
	{
		idc = 44449;
		x = 0.48;
		y = 0.40;
		w = 0.275;
		h = 0.20;
		soundselect[]={};
		sizeEx = 0.015;
		rowHeight = 0.04;
		style = ST_CENTER;
		borderSize = 0;
		colorSelectBackground[] = {0.2, 0.4, 1, 0.5};
		SoundExpand[]={"\ca\ui\data\sound\new1", 0.15, 1};
		SoundCollapse[]={"\ca\ui\data\sound\new1", 0.15, 1};
	};
	class XD_CreateVecButton
	{
		idc = 44451;
		type = CT_BUTTON;
		style = ST_CENTER;
		default = false;
		font = FontM;
		sizeEx = 0.02;
		colorText[] = { 0, 0, 0, 0.8 };
		colorFocused[] = { 1, 0, 0, 1 }; // border color for focused state
		colorDisabled[] = { 0, 0, 1, 0.7 }; // text color for disabled state
		colorBackground[] = { 1, 1, 1, 0.5 };
		colorBackgroundDisabled[] = { 1, 1, 1, 0.2 }; // background color for disabled state
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
		x = 0.55;
		y = 0.62;
		w = 0.15;
		h = 0.04;
		text = $STR_SYS_281; //"Create Vehicle"
		action = "_kk = 0 execVM ""x_scripts\x_create_vec.sqf""";
	};
	class dtext2 : RscText
	{
		x = 0.21;
		y = 0.76;
		w = 0.2;
		h = 0.03;
		sizeEx = 0.03;
		colorText[] = { 1, 1, 1, 0.5 };
		text = $STR_SYS_280; // "Доминация!"
	};
	class XD_TeleportButton
	{
		idc = 44453;
		type = CT_BUTTON;
		style = ST_CENTER;
		font = FontM;
		sizeEx = 0.026;
		colorText[] = { 1, 0, 0, 0.8 };
		colorFocused[] = { 1, 0, 0, 1 }; // border color for focused state
		colorDisabled[] = { 1, 0, 0, 0.2 }; // text color for disabled state
		colorBackground[] = { 1, 1, 1, 0.5 };
		colorBackgroundDisabled[] = { 1, 1, 1, 0.2 }; // background color for disabled state
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
		x = 0.26;
		y = 0.68;
		w = 0.15;
		h = 0.04;
		text = $STR_FLAG_0; // "Teleport";
		action = "closeDialog 0;_handle = [] execVM ""dlg\teleport.sqf""";
	};
};
