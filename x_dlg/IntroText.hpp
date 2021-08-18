/**
class Titel1
{
	idd=123000;
	movingEnable=0;
	duration=10;
	name="titel1";
	controls[]={"titel1"};
	onLoad="INTRO_HUD = _this select 0";
	class titel1: XC_RscText
	{
		idc=66666;
		style="16+2+512";
		lineSpacing=0.950000;
		text="Made 2009 by Xeno\n\n          mod for Red Engineers";
		x=0.39000000;
		y=0.9100000;
		w=0.900000;
		h=0.700000;
		colorBackground[]={0,0,0,0};
		colorText[]={0.8,0.9,0.9,0.7};
		size=0.57;
		sizeEx = 0.026;
	};
};
*/
class XDomLabel
{
	idd=-1;
	movingEnable=0;
	duration=10;
	name="XDomLabel";
	sizeEx = 256;

	controls[]={"Picture"};

	class Picture : RscPicture
	{
		x=0.31; y=0.4; w=0.4; h=0.07;
		text="pics\domination.paa";
		sizeEx = 256;
	};
};

class XDomLabelNewYear
{
	idd=-1;
	movingEnable=0;
	duration=10;
	name="XDomLabelNewYear";
	sizeEx = 256;

	controls[]={"Picture"};

	class Picture : RscPicture
	{
		x=0.31; y=0.4; w=0.4; h=0.07;
		text="pics\domination_new_year.paa";
		sizeEx = 256;
	};
};

class xvehicle_hud
{
	idd=64431;
	movingEnable = true;
	fadein       =  0;
	fadeout      =  0;
	duration     =  1;
	name="xvehicle_hud";
	controls[]={"vehicle_hud_name","vehicle_hud_speed","vehicle_hud_fuel","vehicle_hud_damage","vehicle_hud_direction"};
	onLoad="DVEC_HUD = _this select 0";

	class vehicle_hud_name
	{
		type = 0;
		idc = 64432;
		style = 0;
		x = 0.87;
		y = 0.725;
		w = 0.2;
		h = 0.2;
		font = "Zeppelin32";
		sizeEx = 0.019;
		colorText[] = {1.0, 1.0, 1.0, 0.9};
		colorBackground[]={0,0,0,0.0};
		text = "";
	};

	class vehicle_hud_speed
	{
		type = 0;
		idc = 64433;
		style = 0;
		x = 0.87;
		y = 0.755;
		w = 0.2;
		h = 0.2;
		font = "Zeppelin32";
		sizeEx = 0.019;
		colorText[] = {1.0, 1.0, 1.0, 0.9};
		colorBackground[]={0,0,0,0.0};
		text = "";
	};

	class vehicle_hud_fuel
	{
		type = 0;
		idc = 64434;
		style = 0;
		x = 0.87;
		y = 0.785;
		w = 0.2;
		h = 0.2;
		font = "Zeppelin32";
		sizeEx = 0.019;
		colorText[] = {1.0, 1.0, 1.0, 0.9};
		colorBackground[]={0,0,0,0.0};
		text = "";
	};

	class vehicle_hud_damage
	{
		type = 0;
		idc = 64435;
		style = 0;
		x = 0.87;
		y = 0.815;
		w = 0.2;
		h = 0.2;
		font = "Zeppelin32";
		sizeEx = 0.019;
		colorText[] = {1.0, 1.0, 1.0, 0.9};
		colorBackground[]={0,0,0,0.0};
		text = "";
	};

	class vehicle_hud_direction
	{
		type = 0;
		idc = 64436;
		style = 0;
		x = 0.87;
		y = 0.845;
		w = 0.2;
		h = 0.2;
		font = "Zeppelin32";
		sizeEx = 0.019;
		colorText[] = {1.0, 1.0, 1.0, 0.9};
		colorBackground[]={0,0,0,0.0};
		text = "";
	};
};
//#####################
class chopper_hud
{
	idd=64432;
	movingEnable = true;
	fadein       =  0;
	fadeout      =  1;
	duration     =  4;
	name="chopper_hud";
	controls[]={"vehicle_hud_start","vehicle_hud_start2","vehicle_hud_start3"};
	onLoad="DCHOP_HUD = _this select 0";
	
	class vehicle_hud_start
	{
		type = 0;
		idc = 64438;
		style = 0;
		x = 0.3;
		y = 0.3;
		w = 0.6;
		h = 0.4;
		font = "Zeppelin32";
		sizeEx = 0.04;
		colorText[] = {1.0, 1.0, 1.0, 0.9};
		colorBackground[]={0,0,0,0.0};
		text = "";
	};
	class vehicle_hud_start2
	{
		type = 0;
		idc = 64439;
		style = 0;
		x = 0.3;
		y = 0.4;
		w = 0.4;
		h = 0.4;
		font = "Zeppelin32";
		sizeEx = 0.03;
		colorText[] = {1.0, 1.0, 1.0, 0.9};
		colorBackground[]={0,0,0,0.0};
		text = "";
	};
	class vehicle_hud_start3
	{
		type = 0;
		idc = 64440;
		style = 0;
		x = 0.3;
		y = 0.5;
		w = 0.5;
		h = 0.4;
		font = "Zeppelin32";
		sizeEx = 0.03;
		colorText[] = {1.0, 1.0, 1.0, 0.9};
		colorBackground[]={0,0,0,0.0};
		text = "";
	};
};

class chopper_lift_hud
{
	idd=61420;
	movingEnable = true;
	fadein       =  0;
	fadeout      =  0;
	duration     =  4;
	name="chopper_hud";
	controls[]={"chopper_hud_background","chopper_hud_type","chopper_hud_icon","chopper_hud_edge","chopper_hud_dist","chopper_hud_height","chopper_hud_back","chopper_hud_forward","chopper_hud_left","chopper_hud_right","chopper_hud_middle","chopper_hud_icon2"};
	onLoad="DCHOP_LIFT_HUD = _this select 0";
	
	class chopper_hud_background
	{
		idc = 64437;
		type = 0;
		colorText[] = {1, 1, 1, 1};
		font = "Bitstream";
		colorBackground[] = {0, 0, 1, 0.3};
		text = "";
		style = 128;
		sizeEx = 0.015;
		x = 0.3;
		y = 0.4;
		w = 0.42;
		h = 0.4;
	};
	
	class chopper_hud_type
	{
		type = 0;
		idc = 64438;
		style = 0;
		x = 0.31;
		y = 0.73;
		w = 0.42;
		h = 0.1;
		font = "Zeppelin32";
		sizeEx = 0.02;
		colorText[] = {1.0, 1.0, 1.0, 0.9};
		colorBackground[]={0,0,0,0.0};
		text = "";
	};
	
	class chopper_hud_icon
	{
		type = 0;
		idc = 64439;
		style = 48;
		x = 0.62;
		y = 0.723;
		w = 0.083;
		h = 0.07;
		font = "Zeppelin32";
		sizeEx = 0.02;
		colorText[] = {1,1,1,1};
		colorBackground[] = {0,0,0,0};
		text = "";
	};
	
	class chopper_hud_edge
	{
		type = 0;
		idc = 64440;
		style = 0;
		x = 0.80;
		y = 0.005;
		w = 0.42;
		h = 0.1;
		font = "Zeppelin32";
		sizeEx = 0.02;
		colorText[] = {1.0, 1.0, 1.0, 0.9};
		colorBackground[]={0,0,0,0.0};
		text = "";
	};
	
	class chopper_hud_dist
	{
		type = 0;
		idc = 64441;
		style = 0;
		x = 0.31;
		y = 0.37;
		w = 0.25;
		h = 0.1;
		font = "Zeppelin32";
		sizeEx = 0.02;
		colorText[] = {1.0, 1.0, 1.0, 0.9};
		colorBackground[]={0,0,0,0.0};
		text = "";
	};
	
	class chopper_hud_height
	{
		type = 0;
		idc = 64442;
		style = 0;
		x = 0.6;
		y = 0.37;
		w = 0.2;
		h = 0.1;
		font = "Zeppelin32";
		sizeEx = 0.02;
		colorText[] = {1.0, 1.0, 1.0, 0.9};
		colorBackground[]={0,0,0,0.0};
		text = "";
	};
	
	class chopper_hud_back
	{
		type = 0;
		idc = 64443;
		style = 48;
		x = 0.45;
		y = 0.6;
		w = 0.1;
		h = 0.1;
		font = "Zeppelin32";
		sizeEx = 0.02;
		colorText[] = {1.0, 1.0, 1.0, 0.9};
		colorBackground[]={0,0,0,0.0};
		text = "";
	};
	class chopper_hud_forward
	{
		type = 0;
		idc = 64444;
		style = 48;
		x = 0.45;
		y = 0.5;
		w = 0.1;
		h = 0.1;
		font = "Zeppelin32";
		sizeEx = 0.02;
		colorText[] = {1.0, 1.0, 1.0, 0.9};
		colorBackground[]={0,0,0,0.0};
		text = "";
	};
	class chopper_hud_left
	{
		type = 0;
		idc = 64445;
		style = 48;
		x = 0.4;
		y = 0.55;
		w = 0.1;
		h = 0.1;
		font = "Zeppelin32";
		sizeEx = 0.02;
		colorText[] = {1.0, 1.0, 1.0, 0.9};
		colorBackground[]={0,0,0,0.0};
		text = "";
	};
	class chopper_hud_right
	{
		type = 0;
		idc = 64446;
		style = 48;
		x = 0.5;
		y = 0.55;
		w = 0.1;
		h = 0.1;
		font = "Zeppelin32";
		sizeEx = 0.02;
		colorText[] = {1.0, 1.0, 1.0, 0.9};
		colorBackground[]={0,0,0,0.0};
		text = "";
	};
	class chopper_hud_middle
	{
		type = 0;
		idc = 64447;
		style = 48;
		x = 0.45;
		y = 0.55;
		w = 0.1;
		h = 0.1;
		font = "Zeppelin32";
		sizeEx = 0.02;
		colorText[] = {1.0, 1.0, 1.0, 0.9};
		colorBackground[]={0,0,0,0.0};
		text = "";
	};
	
	class chopper_hud_icon2
	{
		type = 0;
		idc = 64448;
		style = 48;
		x = 0.458;
		y = 0.56;
		w = 0.083;
		h = 0.07;
		font = "Zeppelin32";
		sizeEx = 0.02;
		colorText[] = {1,1,1,1};
		colorBackground[] = {0,0,0,0};
		text = "";
	};
};

class chopper_lift_hud2
{
	idd=61421;
	movingEnable = true;
	fadein       =  0;
	fadeout      =  0;
	duration     =  4;
	name="chopper_hud2";
	controls[]={"chopper_hud_type"};
	onLoad="DCHOP_HUD2 = _this select 0";
	
	class chopper_hud_type
	{
		type = 0;
		idc = 61422;
		style = 0;
		x = 0.80;
		y = 0.005;
		w = 0.42;
		h = 0.1;
		font = "Zeppelin32";
		sizeEx = 0.02;
		colorText[] = {1.0, 1.0, 1.0, 0.9};
		colorBackground[]={0,0,0,0.0};
		text = "";
	};
};
