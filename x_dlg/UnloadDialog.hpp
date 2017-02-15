class XD_UnloadDialog
{
  	idd = 11099;
	movingEnable = 1;
	onLoad="_test = [] execVM ""x_scripts\x_fillunload.sqf""";
	controlsBackground[] = {XD_BackGround};
	// ####
	objects[] = {};

	controls[] =
	{
		XD_SelectButton,
		XD_CancelButton,
		XD_Unloadlistbox,
		XD_UnloadCaption
	};

	class XD_BackGround : XC_RscText
	{
		x = 0.25;
		y = 0.2;
		w = 0.5;
		h = 0.6;
		colorBackground[] = {0.5, 0.5, 0.5, 0.5};
	};

	// ####
	class XD_SelectButton
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
		x = 0.29;
		y = 0.725;
		w = 0.15;
		h = 0.05;
		text = "Выберите";
		action = "_kk = 0 execVM ""x_scripts\x_setcargo.sqf""";
	};
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
		x = 0.56;
		y = 0.725;
		w = 0.15;
		h = 0.05;
		text = "Отмена";
		action = "closeDialog 0;";
	};
	class XD_Unloadlistbox : RscListBox
	{
		x = 0.36;
		y = 0.3;
		w = 0.275;
		h = 0.36;
		idc = 101115;
		soundselect[]={};
		sizeEx = 0.02;
		rowHeight = 0.04;
		style = ST_PICTURE;
		colorSelectBackground[] = {0.2, 0.4, 1, 0.5};
		SoundExpand[]={"\ca\ui\data\sound\new1", 0.15, 1};
		SoundCollapse[]={"\ca\ui\data\sound\new1", 0.15, 1};
	};
	class XD_UnloadCaption : XC_RscText
	{
		x = 0.4;
		y = 0.22;
		w = 0.2;
		h = 0.1;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = "Выберите автомобиль для разгрузки:";
	};
};
