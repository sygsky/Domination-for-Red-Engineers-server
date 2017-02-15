#define UILEFT 0
#define UICOMBO 4
#define DEFAULTFONT "Bitstream"
#define CT_BUTTON 1
#define ST_CENTER 0x02
#define FontM "Zeppelin32"

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
	wholeHeight = 0.3;
};

class XD_SettingsDialog
{
	idd = 11251;
	movingEnable = 1;
	controlsBackground[] = {XD_BackGround};
	objects[] = {};
	controls[] =
	{
		XD_CloseButton,
		VDistanceCombo,
		XD_MainCaption,
		XD_ViewDistanceCaption,
		XD_ViewDistanceHint,
		XD_GraslayerCaption,
		XD_GraslayerHint,
		GraslayerCombo,
		XD_PlayermarkerCaption,
		XD_PlayermarkerHint,
		PlayermarkerCombo,
		XD_PointsCaption,
		XD_PointsCaption2,
		XD_CorporalPic,
		XD_CorporalString,
		XD_CorporalPoints,
		XD_SergeantPic,
		XD_SergeantString,
		XD_SergeantPoints,
		XD_LieutenantPic,
		XD_LieutenantString,
		XD_LieutenantPoints,
		XD_CaptainPic,
		XD_CaptainString,
		XD_CaptainPoints,
		XD_MajorPic,
		XD_MajorString,
		XD_MajorPoints,
		XD_ColonelPic,
		XD_ColonelString,
		XD_ColonelPoints,
		XD_GRUCaption,
		XD_GRUTxt,
		XD_GeneralCaption,
		XD_GeneralTxt,
		XD_GeneralCaptionHint,
		XD_MedicsCaption,
		XD_MedicsTxt,
		XD_ArtilleryCaption,
		XD_ArtilleryTxt,
		XD_EngineerCaption,
		XD_EngineerTxt
	};

	class XD_BackGround : XC_RscText
	{
		x = 0.1;
		y = 0.1;
		w = 0.8;
		h = 0.8;
		colorBackground[] = {0.5, 0.5, 0.5, 0.3};
	};

	class XD_ViewDistanceCaption : XC_RscText
	{
		x = 0.12;
		y = 0.15;
		w = 0.25;
		h = 0.1;
		sizeEx = 0.025;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = $STR_SYS_160;
	};

	class XD_ViewDistanceHint : XC_RscText
	{
		x = 0.12;
		y = 0.168;
		w = 0.25;
		h = 0.1;
		sizeEx = 0.010;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = {0.5, 0.5, 0.5, 0.8};
		text = $STR_SYS_161; //"Выберите из списка";
	};

	class VDistanceCombo:UIComboBox
	{
		idc = 1000;
		x = 0.125;
		y = 0.226;
		w = 0.17;
		h = 0.03;
		onLBSelChanged = "_handle = [_this] execVM ""x_scripts\x_vdselchanged.sqf""";
	};

	class XD_GraslayerCaption : XC_RscText
	{
		x = 0.12;
		y = 0.25;
		w = 0.25;
		h = 0.1;
		sizeEx = 0.025;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = $STR_SYS_162; //"Прорисовка травы";
	};

	class XD_GraslayerHint : XC_RscText
	{
		x = 0.12;
		y = 0.268;
		w = 0.25;
		h = 0.1;
		sizeEx = 0.010;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = {0.5, 0.5, 0.5, 0.8};
		text = $STR_SYS_161; // "Выберите из списка";
	};

	class GraslayerCombo:UIComboBox
	{
		idc = 1001;
		x = 0.125;
		y = 0.326;
		w = 0.17;
		h = 0.03;
		onLBSelChanged = "_handle = [_this] execVM ""x_scripts\x_glselchanged.sqf""";
	};

	class XD_PlayermarkerCaption : XC_RscText
	{
		idc = 1501;
		x = 0.12;
		y = 0.35;
		w = 0.25;
		h = 0.1;
		sizeEx = 0.025;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = $STR_SYS_163; //"Маркеры игроков";
	};

	class XD_PlayermarkerHint : XC_RscText
	{
		idc = 1500;
		x = 0.12;
		y = 0.368;
		w = 0.25;
		h = 0.1;
		sizeEx = 0.010;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = {0.5, 0.5, 0.5, 0.8};
		text = $STR_SYS_161; // "Выберите из списка";
	};

	class PlayermarkerCombo:UIComboBox
	{
		idc = 1002;
		x = 0.125;
		y = 0.426;
		w = 0.17;
		h = 0.03;
		onLBSelChanged = "_handle = [_this] execVM ""x_scripts\x_pmselchanged.sqf""";
	};

	class XD_CloseButton
	{
		idc = -1;
		type = CT_BUTTON;
		style = ST_CENTER;
		default = true;
		font = FontM;
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
		x = 0.77;
		y = 0.86; // y = 0.83;
		w = 0.1;
		h = 0.03;
		sizeEx = 0.018;
		text =  $STR_SYS_53; //"Закрыть";
		action = "closeDialog 0;";
	};

	class XD_MainCaption : XC_RscText
	{
		x = 0.12;
		y = 0.08;
		w = 0.25;
		h = 0.1;
		sizeEx = 0.03;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = $STR_SYS_57; //"Настройки";
	};

	class XD_PointsCaption : XC_RscText
	{
		x = 0.12;
		y = 0.48;
		w = 0.25;
		h = 0.1;
		sizeEx = 0.025;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = $STR_SYS_164; //"Необходимо очков для";
	};

	class XD_PointsCaption2 : XC_RscText
	{
		x = 0.12;
		y = 0.505;
		w = 0.25;
		h = 0.1;
		sizeEx = 0.025;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = $STR_SYS_165; //"получения звания:";
	};

	class XD_CorporalPic : RscPicture
	{
		x=0.13; y=0.582; w=0.02; h=0.025;
		text = "\warfare\Images\rank_corporal.paa";
		sizeEx = 256;
		colorText[] = { 0, 0, 0, 1 };
	};

	class XD_CorporalString : XC_RscText
	{
		x = 0.16;
		y = 0.545;
		w = 0.25;
		h = 0.1;
		sizeEx = 0.025;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = $STR_TSD9_27; //"Ефрейтор";
	};

	class XD_CorporalPoints : XC_RscText
	{
		idc = 2001;
		x = 0.25;
		y = 0.545;
		w= 0.06;
		h = 0.1;
		style = ST_RIGHT;
		sizeEx = 0.025;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = "";
	};

	class XD_SergeantPic : RscPicture
	{
		x=0.13; y=0.612; w=0.02; h=0.025;
		text = "\warfare\Images\rank_sergeant.paa";
		sizeEx = 256;
		colorText[] = { 0, 0, 0, 1 };
	};

	class XD_SergeantString : XC_RscText
	{
		x = 0.16;
		y = 0.575;
		w = 0.25;
		h = 0.1;
		sizeEx = 0.025;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = $STR_TSD9_28; //"Сержант";
	};

	class XD_SergeantPoints : XC_RscText
	{
		idc = 2002;
		x = 0.25;
		y = 0.575;
		w= 0.06;
		h = 0.1;
		style = ST_RIGHT;
		sizeEx = 0.025;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = "";
	};

	class XD_LieutenantPic : RscPicture
	{
		x=0.13; y=0.642; w=0.02; h=0.025;
		text = "\warfare\Images\rank_lieutenant.paa";
		sizeEx = 256;
		colorText[] = { 0, 0, 0, 1 };
	};

	class XD_LieutenantString : XC_RscText
	{
		x = 0.16;
		y = 0.605;
		w = 0.25;
		h = 0.1;
		sizeEx = 0.025;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = $STR_TSD9_29; //"Лейтенант";
	};

	class XD_LieutenantPoints : XC_RscText
	{
		idc = 2003;
		x = 0.25;
		y = 0.605;
		w= 0.06;
		h = 0.1;
		style = ST_RIGHT;
		sizeEx = 0.025;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = "";
	};

	class XD_CaptainPic : RscPicture
	{
		x=0.13; y=0.672; w=0.02; h=0.025;
		text = "\warfare\Images\rank_captain.paa";
		sizeEx = 256;
		colorText[] = { 0, 0, 0, 1 };
	};

	class XD_CaptainString : XC_RscText
	{
		x = 0.16;
		y = 0.635;
		w = 0.25;
		h = 0.1;
		sizeEx = 0.025;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = $STR_TSD9_30; //"Капитан";
	};

	class XD_CaptainPoints : XC_RscText
	{
		idc = 2004;
		x = 0.25;
		y = 0.635;
		w = 0.06;
		h = 0.1;
		style = ST_RIGHT;
		sizeEx = 0.025;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = "";
	};

	class XD_MajorPic : RscPicture
	{
		x=0.13; y=0.702; w=0.02; h=0.025;
		text = "\warfare\Images\rank_major.paa";
		sizeEx = 256;
		colorText[] = { 0, 0, 0, 1 };
	};

	class XD_MajorString : XC_RscText
	{
		x = 0.16;
		y = 0.665;
		w = 0.25;
		h = 0.1;
		sizeEx = 0.025;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = $STR_TSD9_31; //"Майор";
	};

	class XD_MajorPoints : XC_RscText
	{
		idc = 2005;
		x = 0.25;
		y = 0.665;
		w = 0.06;
		h = 0.1;
		style = ST_RIGHT;
		sizeEx = 0.025;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = "";
	};

	class XD_ColonelPic : RscPicture
	{
		x=0.13; y=0.732; w=0.02; h=0.025;
		text = "\warfare\Images\rank_colonel.paa";
		sizeEx = 256;
		colorText[] = { 0, 0, 0, 1 };
	};

	class XD_ColonelString : XC_RscText
	{
		x = 0.16;
		y = 0.695;
		w = 0.125;
		h = 0.1;
		sizeEx = 0.025;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = $STR_TSD9_32;// "Полковник";
	};

	class XD_ColonelPoints : XC_RscText
	{
		idc = 2006;
		x = 0.25;
		y = 0.695;
		w = 0.06;
		h = 0.1;
		style = ST_RIGHT;
		sizeEx = 0.025;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = "";
	};

	class XD_GeneralCaption : XC_RscText
	{
		x = 0.35;
		y = 0.222; // y = 0.15;
		w = 0.25;
		h = 0.1;
		sizeEx = 0.025;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = $STR_SYS_166; //"Общие параметры миссии";
	};

	class XD_GeneralCaptionHint : XC_RscText
	{
		x = 0.35;
		y = 0.24; //y = 0.168;
		w = 0.5;
		h = 0.1;
		sizeEx = 0.016;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = {1, 1, 1, 0.6};
		text = $STR_SYS_167; //"Для навигации нажмите на текстовое поле и используйте стрелки вверх/вниз.";
	};

	class XD_GeneralTxt : XC_RscText
	{
		idc = 2007;
		style = 16;
		lineSpacing = 1;
		colorBackground[] = { 0.9, 0.9, 0.9, 0.4 };
		x = 0.358;
		y = 0.31; //y = 0.24;
		w = 0.5;
		h = 0.29;
		sizeEx = 0.018;
		text = "";
	};

	class XD_MedicsCaption : XC_RscText
	{
		x = 0.35;
		y = 0.58;//y = 0.51;
		w = 0.25;
		h = 0.1;
		sizeEx = 0.025;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = $STR_SYS_52; //"Медики/Medics";
	};

	class XD_MedicsTxt : XC_RscText
	{
		idc = 2008;
		style = 16;
		lineSpacing = 1;
		colorBackground[] = { 0.9, 0.9, 0.9, 0.4 };
		x = 0.358;
		y = 0.65; // y = 0.58;
		w = 0.5;
		h = 0.04;
		sizeEx = 0.018;
		text = "";
	};

	class XD_ArtilleryCaption : XC_RscText
	{
		x = 0.35;
		y = 0.66; // y = 0.59;
		w = 0.3;
		h = 0.1;
		sizeEx = 0.025;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = $STR_SYS_51; //"Спецназ ГРУ-артиллеристы/Resque-gunners";
	};

	class XD_ArtilleryTxt : XC_RscText
	{
		idc = 2009;
		style = 16;
		lineSpacing = 1;
		colorBackground[] = { 0.9, 0.9, 0.9, 0.4 };
		x = 0.358;
		y = 0.73; //y = 0.66;
		w = 0.5;
		h = 0.04;
		sizeEx = 0.018;
		text = "";
	};

	class XD_EngineerCaption : XC_RscText
	{
		x = 0.35;
		y = 0.74; // y = 0.67;
		w = 0.3;
		h = 0.1;
		sizeEx = 0.025;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = $STR_SYS_50; //"Военные инженеры/Combat Engineers";
	};

	class XD_EngineerTxt : XC_RscText
	{
		idc = 2010;
		style = 16;
		lineSpacing = 1;
		colorBackground[] = { 0.9, 0.9, 0.9, 0.4 };
		x = 0.358;
		y = 0.81; // y = 0.74;
		w = 0.5;
		h = 0.04;
		sizeEx = 0.018;
		text = "";
	};
	
	class XD_GRUCaption : XC_RscText
	{
		x = 0.35;
		y = 0.07;
		w = 0.3;
		h = 0.1;
		sizeEx = 0.025;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = $STR_SYS_54; //"Информация ГРУ/GRU intel";
	};

	class XD_GRUTxt : XC_RscText
	{
		idc = 2011;
		style = 16;
		lineSpacing = 1;
		colorBackground[] = { 0.9, 0.9, 0.9, 0.4 };
		x = 0.358;
		y = 0.14;
		w = 0.5;
		h = 0.11;
		sizeEx = 0.018;
		text = $STR_SYS_55; // "Разведчик прибудет в следущей версии. Вы поможете ему добраться до места назначения"
	};

};