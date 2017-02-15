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

//##################################

class XD_RscMapControl
{
	access = 0;
	type = 101;
	idc = -1;
	style = 48;
	colorBackground[] = {1, 1, 1, 1};
	colorText[] = {0, 0, 0, 1};
	font = "TahomaB";
	sizeEx = 0.040000;
	colorSea[] = {0.560000, 0.800000, 0.980000, 0.500000};
	colorForest[] = {0.600000, 0.800000, 0.200000, 0.500000};
	colorRocks[] = {0.500000, 0.500000, 0.500000, 0.500000};
	colorCountlines[] = {0.650000, 0.450000, 0.270000, 0.500000};
	colorMainCountlines[] = {0.650000, 0.450000, 0.270000, 1};
	colorCountlinesWater[] = {0, 0.530000, 1, 0.500000};
	colorMainCountlinesWater[] = {0, 0.530000, 1, 1};
	colorForestBorder[] = {0.400000, 0.800000, 0, 1};
	colorRocksBorder[] = {0.500000, 0.500000, 0.500000, 1};
	colorPowerLines[] = {0, 0, 0, 1};
	colorNames[] = {0, 0, 0, 1};
	colorInactive[] = {1, 1, 1, 0.500000};
	colorLevels[] = {0, 0, 0, 1};
	fontLabel = "TahomaB";
	sizeExLabel = 0.020000;
	fontGrid = "TahomaB";
	sizeExGrid = 0.020000;
	fontUnits = "TahomaB";
	sizeExUnits = 0.020000;
	fontNames = "TahomaB";
	sizeExNames = 0.020000;
	fontInfo = "TahomaB";
	sizeExInfo = 0.020000;
	fontLevel = "TahomaB";
	showCountourInterval = "true";
	sizeExLevel = 0.020000;
	stickX[] = {0.200000, {"Gamma", 1, 1.500000}};
	stickY[] = {0.200000, {"Gamma", 1, 1.500000}};
	ptsPerSquareSea = 6;
	ptsPerSquareTxt = 8;
	ptsPerSquareCLn = 8;
	ptsPerSquareExp = 8;
	ptsPerSquareCost = 8;
	ptsPerSquareFor = "4.0f";
	ptsPerSquareForEdge = "10.0f";
	ptsPerSquareRoad = 2;
	ptsPerSquareObj = 10;
	text = "\ca\ui\data\map_background2_co.paa";

	class Legend {
		x = 0.75;
		y = 0.0;
		w = 0.25;
		h = 0.1;
		font = "TahomaB";
		sizeEx = 0.020;
		colorBackground[] = {1, 1, 1, 0.8};
		color[] = {0, 0, 0, 1};
	};
	class ActiveMarker {
		color[] = {0.300000, 0.100000, 0.900000, 1};
		size = 50;
	};
	class Bunker {
		icon = "\ca\ui\data\map_bunker_ca.paa";
		color[] = {0, 0.350000, 0.700000, 1};
		size = 14;
		importance = "1.5 * 14 * 0.05";
		coefMin = 0.250000;
		coefMax = 4;
	};
	class Bush {
		icon = "\ca\ui\data\map_bush_ca.paa";
		color[] = {0.550000, 0.640000, 0.430000, 1};
		size = 14;
		importance = "0.2 * 14 * 0.05";
		coefMin = 0.250000;
		coefMax = 4;
	};
	class BusStop {
		icon = "\ca\ui\data\map_busstop_ca.paa";
		color[] = {0, 0, 1, 1};
		size = 10;
		importance = "1 * 10 * 0.05";
		coefMin = 0.250000;
		coefMax = 4;
	};
	class Command {
		icon = "#(argb,8,8,3)color(1,1,1,1)";
		color[] = {0, 0, 0, 1};
		size = 18;
		importance = 1;
		coefMin = 1;
		coefMax = 1;
	};
	class Cross {
		icon = "\ca\ui\data\map_cross_ca.paa";
 	    color[] = {0, 0.350000, 0.700000, 1};
		size = 16;
		importance = "0.7 * 16 * 0.05";
		coefMin = 0.250000;
		coefMax = 4;
	};
	class Fortress {
		icon = "\ca\ui\data\map_bunker_ca.paa";
		color[] = {0, 0.350000, 0.700000, 1};
		size = 16;
		importance = "2 * 16 * 0.05";
		coefMin = 0.250000;
		coefMax = 4;
	};
	class Fuelstation {
		icon = "\ca\ui\data\map_fuelstation_ca.paa";
		color[] = {1, 0.350000, 0.350000, 1};
		size = 16;
		importance = "2 * 16 * 0.05";
		coefMin = 0.750000;
		coefMax = 4;
	};
	class Fountain {
		icon = "\ca\ui\data\map_fountain_ca.paa";
		color[] = {0, 0.350000, 0.700000, 1};
		size = 12;
		importance = "1 * 12 * 0.05";
		coefMin = 0.250000;
		coefMax = 4;
	};
	class Hospital {
		icon = "\ca\ui\data\map_hospital_ca.paa";
		color[] = {0.780000, 0, 0.050000, 1};
		size = 16;
		importance = "2 * 16 * 0.05";
		coefMin = 0.500000;
		coefMax = 4;
	};
	class Chapel {
		icon = "\ca\ui\data\map_chapel_ca.paa";
		color[] = {0, 0.350000, 0.700000, 1};
		size = 16;
		importance = "1 * 16 * 0.05";
		coefMin = 0.900000;
		coefMax = 4;
	};
	class Church {
		icon = "\ca\ui\data\map_church_ca.paa";
		color[] = {0, 0.350000, 0.700000, 1};
		size = 16;
		importance = "2 * 16 * 0.05";
		coefMin = 0.900000;
		coefMax = 4;
	};
	class Lighthouse {
		icon = "\ca\ui\data\map_lighthouse_ca.paa";
		color[] = {0.780000, 0, 0.050000, 1};
		size = 20;
		importance = "3 * 16 * 0.05";
		coefMin = 0.900000;
		coefMax = 4;
	};
	class Quay {
		icon = "\ca\ui\data\map_quay_ca.paa";
		color[] = {0, 0.350000, 0.700000, 1};
		size = 16;
		importance = "2 * 16 * 0.05";
		coefMin = 0.500000;
		coefMax = 4;
	};
	class Rock {
		icon = "\ca\ui\data\map_rock_ca.paa";
        color[] = {0.35, 0.350000, 0.350000, 1};
		size = 12;
		importance = "0.5 * 12 * 0.05";
		coefMin = 0.250000;
		coefMax = 4;
	};
	class Ruin {
		icon = "\ca\ui\data\map_ruin_ca.paa";
		color[] = {0.780000, 0, 0.050000, 1};
		size = 16;
		importance = "1.2 * 16 * 0.05";
		coefMin = 1;
		coefMax = 4;
	};
	class Stack {
		icon = "\ca\ui\data\map_stack_ca.paa";
		color[] = {0, 0.350000, 0.700000, 1};
		size = 20;
		importance = "2 * 16 * 0.05";
		coefMin = 0.900000;
		coefMax = 4;
	};
	class Tree {
		icon = "\ca\ui\data\map_tree_ca.paa";
		color[] = {0.550000, 0.640000, 0.430000, 1};
		size = 12;
		importance = "0.9 * 16 * 0.05";
		coefMin = 0.250000;
		coefMax = 4;
	};
	class SmallTree {
		icon = "\ca\ui\data\map_smalltree_ca.paa";
		color[] = {0.550000, 0.640000, 0.430000, 1};
		size = 12;
		importance = "0.6 * 12 * 0.05";
		coefMin = 0.250000;
		coefMax = 4;
	};
	class Tourism {
		icon = "\ca\ui\data\map_tourism_ca.paa";
		color[] = {0.780000, 0, 0.050000, 1};
		size = 16;
		importance = "1 * 16 * 0.05";
		coefMin = 0.700000;
		coefMax = 4;
	};
	class Transmitter {
		icon = "\ca\ui\data\map_transmitter_ca.paa";
		color[] = {0, 0.350000, 0.700000, 1};
		size = 20;
		importance = "2 * 16 * 0.05";
		coefMin = 0.900000;
		coefMax = 4;
	};
	class ViewTower {
		icon = "\ca\ui\data\map_viewtower_ca.paa";
		color[] = {0, 0.350000, 0.700000, 1};
		size = 16;
		importance = "2.5 * 16 * 0.05";
		coefMin = 0.500000;
		coefMax = 4;
	};

	class Watertower {
		icon = "\ca\ui\data\map_watertower_ca.paa";
		color[] = {0, 0.350000, 0.700000, 1};
		size = 32;
		importance = "1.2 * 16 * 0.05";
		coefMin = 0.900000;
		coefMax = 4;
	};
    class Waypoint {
		icon = "\ca\ui\data\map_waypoint_ca.paa";
		color[] = {0, 0, 0, 1};
		size = 24;
		importance = 1;
		coefMin = 1;
		coefMax = 1;
	};
	class WaypointCompleted {
		icon = "\ca\ui\data\map_waypoint_completed_ca.paa";
		color[] = {0, 0, 0, 1};
		size = 24;
		importance = 1;
		coefMin = 1;
		coefMax = 1;
	};
};

//##################################

class x_miscXC_RscText
{
	type = CT_STATIC;
	idc = -1;
	style = ST_LEFT;

	x = 0.0;y = 0.0;w = 0.3;h = 0.03;
	sizeEx = 0.023;

	colorBackground[] = {0.5, 0.5, 0.5, 0.75};
	colorText[] = { 0, 0, 0, 1 };
	font = FontM;
	text = "";
};

// ####
class XD_AirDropDialog
{
	idd = 77899;
	movingEnable = true;
	controlsBackground[] = {XD_BackGround};
	// ####
	objects[] = {};

	controls[] =
	{
 		XD_CancelButton,
		XD_DropMapText,
		XD_Map,
		XD_Drop1,
		XD_Drop2,
		XD_Drop3
	};

	class XD_BackGround : x_miscXC_RscText
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
		y = 0.80;
		w = 0.2;
		h = 0.05;
		text = $STR_SYS_1120; // Cancel
		action = "closeDialog 0;";
	};
	class XD_Drop3
	{
		idc = 11004;
		type = CT_BUTTON;
		style = ST_CENTER;
		default = false;
		font = FontM;
		sizeEx = 0.03;
		colorText[] = { 0, 0, 1, 1 };
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
		y = 0.40;
		w = 0.2;
		h = 0.05;
		text = $STR_SYS_1123;
		action = "_xdxd_a = X_Drop_Array select 2; x_drop_type = _xdxd_a select 1;closeDialog 0;";
	};
	class XD_Drop2
	{
		idc = 11003;
		type = CT_BUTTON;
		style = ST_CENTER;
		default = false;
		font = FontM;
		sizeEx = 0.03;
		colorText[] = { 0, 1, 0, 1 };
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
		y = 0.30;
		w = 0.2;
		h = 0.05;
		text = $STR_SYS_1122;
		action = "_xdxd_a = X_Drop_Array select 1; x_drop_type = _xdxd_a select 1;closeDialog 0;";
	};
	class XD_Drop1
	{
		idc = 11002;
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
		y = 0.20;
		w = 0.2;
		h = 0.05;
		text = $STR_SYS_1121; // "Drop Item 1"
		action = "_xdxd_a = X_Drop_Array select 0; x_drop_type = _xdxd_a select 1;closeDialog 0;";
	};
	class XD_DropMapText : x_miscXC_RscText
	{
		x = 0.12;
		y = 0.12;
		w = 0.3;
		h = 0.1;
		colorBackground[] = {1, 1, 1, 0.0};
		colorText[] = { 1, 1, 1, 1 };
		text = $STR_SYS_1124; // "Select drop zone by map click:"
	};
	class XD_Map : XD_RscMapControl
	{
		colorBackground[] = { 0.9, 0.9, 0.9, 0.9 };
		x = 0.12;
		y = 0.2;
		w = 0.52;
		h = 0.64;
		default = true;
		showCountourInterval = false;
	};
};
