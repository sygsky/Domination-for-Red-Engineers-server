#define UILEFT 0
#define UICOMBO 4
#define DEFAULTFONT "Bitstream"
#define CT_BUTTON 1
#define ST_CENTER 0x02
#define FontM "Zeppelin32"

//  Commented classes are already defined in "x_dlg\SettingsDialog.hpp" included into Description.ext before this file
/*
class UIList
{
	style = UILEFT;
	idc = -1;
	colorBackground[] = {0.5, 0.5, 0.5, 1};
	colorSelect[] = {1, 1, 1, 1};
	colorSelectBackground[] = {0.2, 0.4, 1, 0.5};
	colorText[] = {1, 1, 1, 1};
	font = DEFAULTFONT;
	sizeEx = 0.029;
	rowHeight = 0.04;
	soundSelect[] = {"",0.1,1};
	soundExpand[] = {"",0.1,1};
	soundCollapse[] = {"",0.1,1};

	w = 0.275;
	h = 0.04;
};

class UIComboBox:UIList
{
	type = UICOMBO;
	sizeEx = 0.025;
	colorSelectBackground[] = {0.1, 0.1, 0.3, 0.5};
	wholeHeight = 0.3;
};


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
*/

class XD_ResurrectDialog
{
	idd = 13000;
	movingEnable = 1;
	controlsBackground[] = {XD_BackGround};
	objects[] = {};
	controls[] =
	{
		XD_CloseButton,
		XD_MainCaption,
		ResurrectRadiousCombo,
		XD_ResurrectRadiousCaption,
		XD_ResurrectRadiousHint
	};

	class XD_BackGround : XC_RscText
	{
		x = 0.2;
		y = 0.3;
		w = 0.6;
		h = 0.4;
		colorBackground[] = {0.4, 0.5, 0.4, 0.6};
	};

	class XD_ResurrectRadiousCaption : XC_RscText
	{
		x = 0.32;
		y = 0.35;
		w = 0.25;
		h = 0.1;
		sizeEx = 0.025;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 }; // White
		text = $STR_RESTORE_DLG_1; // "To restore"
	};

	class XD_ResurrectRadiousHint : XC_RscText
	{
		x = 0.435;
		y = 0.325;
		w = 0.25;
		h = 0.1;
		sizeEx = 0.02;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = {1, 0, 0, 0.9};
		text = $STR_RESTORE_DLG_2; // "Select from list";
	};

	class ResurrectRadiousCombo:UIComboBox
	{
		idc = 1000;
		x = 0.435;
		y = 0.385;
		w = 0.27;
		h = 0.03;
		onLBSelChanged = "_handle = [_this] execVM ""dlg\res_radselchanged.sqf""";
	};

    class XD_CloseButton
    {
        idc = -1;
        type = CT_BUTTON;
        style = ST_CENTER;
        default = true;
        font = FontM;
        colorText[] = { 1, 1, 1, 1 };
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
        x = 0.425;
        y = 0.5;
        w = 0.15;
        h = 0.03;
        sizeEx = 0.018;
        text =  $STR_RESTORE_DLG_3; // "Execute"
        action = "closeDialog 0;";
    };

	class XD_MainCaption : XC_RscText
	{
		x = 0.2;
		y = 0.28;
		w = 0.6;
		h = 0.1;
		sizeEx = 0.03;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = $STR_RESTORE_DLG_4; // "Resurrection of surrounding plants and fences";
        style = ST_CENTER;
	};

};