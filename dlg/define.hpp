#define CT_STATIC			0
#define CT_BUTTON			1
#define CT_EDIT				2
#define CT_SLIDER			3
#define CT_COMBO			4
#define CT_LISTBOX			5
#define CT_TOOLBOX			6
#define CT_CHECKBOXES		7
#define CT_PROGRESS			8
#define CT_HTML				9
#define CT_STATIC_SKEW		10
#define CT_ACTIVETEXT		11
#define CT_TREE				12
#define CT_STRUCTURED_TEXT	13 
#define CT_3DSTATIC			20
#define CT_3DACTIVETEXT		21
#define CT_3DLISTBOX		22
#define CT_3DHTML			23
#define CT_3DSLIDER			24
#define CT_3DEDIT			25
#define CT_OBJECT			80
#define CT_OBJECT_ZOOM		81
#define CT_OBJECT_CONTAINER	82
#define CT_OBJECT_CONT_ANIM	83
#define CT_USER				99

// Static styles
#define ST_HPOS				0x0F
#define ST_LEFT				0
#define ST_RIGHT			1
#define ST_CENTER			2
#define ST_UP				3
#define ST_DOWN				4
#define ST_VCENTER			5

#define ST_TYPE				0xF0
#define ST_SINGLE			0
#define ST_MULTI			16
#define ST_TITLE_BAR		32
#define ST_PICTURE			48
#define ST_FRAME			64
#define ST_BACKGROUND		80
#define ST_GROUP_BOX		96
#define ST_GROUP_BOX2		112
#define ST_HUD_BACKGROUND	128
#define ST_TILE_PICTURE		144
#define ST_WITH_RECT		160
#define ST_LINE				176

#define ST_SHADOW			256
#define ST_NO_RECT			512

#define ST_TITLE			ST_TITLE_BAR + ST_CENTER

#define FontHTML			"Zeppelin32"
#define FontM				"Zeppelin32"

#define Dlg_ROWS			36
#define Dlg_COLS			90

#define Dlg_CONTROLHGT		((100/Dlg_ROWS)/100)
#define Dlg_COLWIDTH		((100/Dlg_COLS)/100)

#define Dlg_TEXTHGT_MOD		0.9
#define Dlg_ROWSPACING_MOD	1.3

#define Dlg_ROWHGT			(Dlg_CONTROLHGT*Dlg_ROWSPACING_MOD)
#define Dlg_TEXTHGT			(Dlg_CONTROLHGT*Dlg_TEXTHGT_MOD)

class RscText
{
	type = CT_STATIC;
	idc = -1;
	style = ST_LEFT;
	colorBackground[] = {0, 0, 0, 0};
	colorText[] = {1, 1, 1, 1};
	font = FontM;
	sizeEx = 0.015;
};

class RscBG: RscText
{
	type = CT_STATIC;
	idc = -1;
	style = ST_LEFT;
	colorBackground[] = {0.02, 0.11, 0.27, 0.7};
	colorText[] = {1, 1, 1, 0};
	font = FontM;
	sizeEx = 0.015;
	text="";
};

class RscButton
{
	type = CT_BUTTON;
	idc = -1;
	style = ST_CENTER;
	colorText[] = {1, 1, 1, 1};
	colorDisabled[] = {1, 1, 1, 0.7};
	colorBackground[] = {0.04, 0.22, 054, 0.7};
	colorBackgroundActive[] = {0.04, 0.22, 0.54, 0.9};
	colorBackgroundDisabled[] = {0.04, 0.22, 0.54, 0.4};
	colorFocused[] = {1, 1, 1, 0.4};
	colorShadow[] = {0, 1, 0, 0};
	colorBorder[] = {0, 1, 0, 0};
	font = FontM;
	soundEnter[] = {"\ca\ui\data\sound\mouse2", 0.15, 1};
	soundPush[] = {"\ca\ui\data\sound\new1", 0.15, 1};
	soundClick[] = {"\ca\ui\data\sound\mouse3", 0.15, 1};
	soundEscape[] = {"\ca\ui\data\sound\mouse1", 0.15, 1};
	sizeEx = 0.02;
	offsetX=0;
	offsetY=0;
	offsetPressedX = 0.002; 
	offsetPressedY = 0.002;
	borderSize=0;
	default = false;
};

class RscNavButton:RscButton
{
	w=0.1;
	h=0.04;
	x=0.90;
};

class RscListBox
{
	type = CT_LISTBOX;
	style = ST_LEFT;
	idc = -1;
	colorSelect[] = {1, 1, 1, 1};
	colorSelectBackground[] = {0.2, 0.4, 1, 1};
	colorText[] = {1, 1, 1, 1};
	colorBackground[] = {0.02, 0.11, 0.27, 0.4};
	font = FontM;
	sizeEx = 0.02;
	rowHeight = 0.02;
	offsetX = 0.003;
	offsetY = 0.003;
	offsetPressedX = 0.002;
	offsetPressedY = 0.002;
	colorFocused[] = {0.02, 0.11, 0.27, 0.4};
	colorShadow[] = {0.2, 0.2, 0.2, 0.8};
	colorBorder[] = {0.4, 0.4, 0.4, 1};
	borderSize = 0.03;
	soundEnter[] = {"\ca\ui\data\sound\mouse2", 0.15, 1};
	soundPush[] = {"\ca\ui\data\sound\new1", 0.15, 1};
	soundClick[] = {"\ca\ui\data\sound\mouse3", 0.15, 1};
	soundEscape[] = {"\ca\ui\data\sound\mouse1", 0.15, 1};
};

class RscPicture
{
	type = CT_STATIC;
	idc = -1;
	style = ST_PICTURE;

	x = 0.1;
	y = 0.1;
	w = 0.4;
	h = 0.2;
	sizeEx = Dlg_TEXTHGT;

	colorBackground[] = {0, 0, 0, 0};
	colorText[] = {1,1,1, 1};
	font = FontM;

	text = "";
};

class RscMapControl
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
