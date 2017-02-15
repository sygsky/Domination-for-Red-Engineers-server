#include "x_setup.sqf"

// ####
class XD_ParajumpDialog
{
	idd = 77399;
	movingEnable = true;
	controlsBackground[] = {XD_BackGround};
	// ####
	objects[] = {};

	controls[] =
	{
 		XD_CancelButton,
		XD_ArtiMapText,
		XD_ArtiMapText2,
		XD_ArtiMapText3,
		XD_Map
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
	class XD_CancelButton
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
		text = "Отмена";
		action = "closeDialog 0;onMapSingleClick ''";
	};
	class XD_ArtiMapText : XC_RscText
	{
		x = 0.12;
		y = 0.12;
		w = 0.7;
		h = 0.1;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = "Выбор места десантирования";
	};
	class XD_ArtiMapText2 : XC_RscText
	{
		x = 0.12;
		y = 0.77;
		w = 0.7;
		h = 0.1;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
#ifndef __ACE__
		text = " \ - раскрыть парашют";
#endif
#ifdef __ACE__
		text = "'Esc' - открыть парашют!!!";
#endif
	};
	class XD_ArtiMapText3 : XC_RscText
	{
		x = 0.12;
		y = 0.80;
		w = 0.7;
		h = 0.1;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
#ifndef __ACE__
		text = "";
#endif
#ifdef __ACE__
		text = "";
#endif
	};
	class XD_Map : RscMapControl
	{
		colorBackground[] = {0.9, 0.9, 0.9, 0.9};
		x = 0.12;
		y = 0.2;
		w = 0.76;
		h = 0.58;
		default = true;
		showCountourInterval = false;
	};
};
