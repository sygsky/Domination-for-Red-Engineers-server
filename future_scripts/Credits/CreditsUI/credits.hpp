#include "rscbasicDefines.hpp"

class CreditsUI
{
	idd = 70324;
	movingEnable = false;
	enableSimulation = true;
	onLoad = "";
	onUnLoad = "";

//	__EXEC( _xSpacing = 0.0075;  _ySpacing = 0.01;)
//	__EXEC( _xInit = 12 * _xSpacing; _yInit = 3 * _ySpacing;)
//	__EXEC( _windowWidth = 101; _windowHeight = 90;)
//	__EXEC( _windowBorder = 1;)
/*
	class controlsBackground
	{
		class Mainback: RscPicture
		{
			idc = -1;
			x = 0; w = 1;
			y = 0; h = 1;
			text ="\ca\ui\data\ui_gradient_start_gs.paa";
			colorText[]= {1,1,1,0.15};
			colorbackground[] = CA_UI_background;
		};
	};
*/
	class controls
	{
//PROJECT LEADER
		class PL_Title : RscText
		{
			idc = 1001;
			style = ST_MULTI + ST_CENTER + ST_NO_RECT + ST_SHADOW;
			lineSpacing = 1.0;
			x = 0; w = 1;
			y = 1.5; h = 0.05;
			sizeEx = TextSize_small;
			colorText[] = {0.8, 0.8, 0.4, 1};
			text = $STR_QG_CREDITS_LEADER;
		};
		class PL_Name : PL_Title
		{
			idc = 2001;
			sizeEx = TextSize_medium;
			colorText[] = Color_White;
			text = "Radek Volf";
		};

//LEAD DESIGNER
		class D_Title : PL_Title
		{
			idc = 1002;
			text = $STR_QG_CREDITS_LEAD_DESIGNER;
		};
		class D_Name1 : PL_Name
		{
			idc = 2002;
			text = "Jaroslav Kasny";
		};
//DESIGNERS
		class D1_Title : PL_Title
		{
			idc = 1010;
			text = $STR_QG_CREDITS_DESIGNERS;
		};
		class D1_Name1 : PL_Name
		{
			idc = 2010;
			text = "Rudolf Snizek";
		};
		class D1_Name2 : D_Name1
		{
			idc = 2011;
			text = "Josef Vlach";
		};
		class D1_Name3 : D_Name1
		{
			idc = 2012;
			text = "Adam Bilek";
		};
		class D1_Name4 : D_Name1
		{
			idc = 2013;
			text = "Tomas Pulkrabek";
		};
//ARTISTS
		class G_Title : D_Title
		{
			idc = 1020;
			text = $STR_QG_CREDITS_ARTISTS;
		};
		class G_Name1 : D_Name1
		{
			idc = 2020;
			text = "Petr Visek";
		};
		class G_Name2 : D_Name1
		{
			idc = 2021;
			text = "Petr Pechar";
		};
		class G_Name3 : D_Name1
		{
			idc = 2022;
			text = "Daniel Dvorak";
		};
//SCREENWRITTER
		class SP_Title : D_Title
		{
			idc = 1030;
			text = $STR_QG_CREDITS_SCREENWRITTER;
		};
		class SP_Name1 : PL_Name
		{
			idc = 2030;
			text = "Vilma Klimova";
		};
//Support Programmer
		class SP1_Title : D_Title
		{
			idc = 1040;
			text = $STR_QG_CREDITS_SUPPORT_PROGRAMMER;
		};
		class SP1_Name1 : PL_Name
		{
			idc = 2040;
			text = "Michal Svetly";
		};
//SOUNDS AND MUSIC
		class S_Title : D_Title
		{
			idc = 1050;
			text = $STR_QG_CREDITS_MUSIC;
		};
		class S_Name1 : D_Name1
		{
			idc = 2050;
			text = "Ondøej Matejka";
		};
		class S_Name2 : D_Name1
		{
			idc = 2051;
			text = "With Care";
		};
		class S_Name3 : D_Name1
		{
			idc = 2052;
			text = "Simple muffin";
		};
//SCRIPT PROGRAMMERS
		class SP2_Title : D_Title
		{
			idc = 1060;
			text = $STR_QG_CREDITS_SCRIPT_PROGRAMMERS;
		};
		class SP2_Name1 : PL_Name
		{
			idc = 2060;
			text = "Tomas Pulkrabek";
		};
		class SP2_Name2 : SP_Name1
		{
			idc = 2061;
			text = "Jaroslav Kasny";
		};
//CINEMATICS DIRECTOR
		class CN_Title : D_Title
		{
			idc = 1070;
			text = $STR_QG_CREDITS_CINEMATICS_DIRECTOR;
		};
		class CN_Name1 : PL_Name
		{
			idc = 2070;
			text = "Radek Volf";
		};
//MOTION CAPTURE ANIMATION OPERATOR 
		class CN1_Title : D_Title
		{
			idc = 1080;
			text = $STR_QG_CREDITS_CINEMATICS_CAPTURE;
		};
		class CN1_Name1 : PL_Name
		{
			idc = 2080;
			text = "Stepan Kment";
		};
//CINEMATICS CAMERA AND EDITING
		class CN2_Title : D_Title
		{
			idc = 1090;
			text = $STR_QG_CREDITS_CINEMATICS_CAMERA;
		};
		class CN2_Name1 : PL_Name
		{
			idc = 2090;
			text = "Tomas Pulkrabek";
		};
//CINEMATICS MOTION CAPTURE ACTOR
		class CN3_Title : D_Title
		{
			idc = 3000;
			text = $STR_QG_CREDITS_CINEMATICS_ACTOR;
		};
		class CN3_Name1 : PL_Name
		{
			idc = 4000;
			text = "Tomas Kraucher";
		};
//CAST
		class C_Title : D_Title
		{
			idc = 3010;
			text = $STR_QG_CREDITS_CAST;
		};
		class C_Name1 : D_Name1
		{
			idc = 4010;
			text = "Daniel Brown";
		};
		class C_Name2 : D_Name1
		{
			idc = 4011;
			text = "Scott Gerald Bellefeuille";
		};
		class C_Name3 : D_Name1
		{
			idc = 4012;
			text = "Russel Eastman";
		};
		class C_Name4 : D_Name1
		{
			idc = 4013;
			text = "Todd Kramer";
		};
		class C_Name5 : D_Name1
		{
			idc = 4014;
			text = "Denis Lyons";
		};
		class C_Name6 : D_Name1
		{
			idc = 4015;
			text = "Curtis Matthew";
		};
		class C_Name7 : D_Name1
		{
			idc = 4016;
			text = "Juwana Nemcova";
		};
		class C_Name8 : D_Name1
		{
			idc = 4017;
			text = "";
		};
//Idea Games
		class ID_Title : D_Title
		{
			idc = 3222;
			sizeEx = TextSize_medium;
			text = "IDEA GAMES";
		};
		class ID1_Title : D_Title
		{
			idc = 3020;
			text = $STR_QG_CREDITS_PRODUCER;
		};
		class ID1_Name1 : PL_Name
		{
			idc = 4020;
			text = "Martin Klima";
		};
		class ID2_Title : D_Title
		{
			idc = 3030;
			text = $STR_QG_CREDITS_PR;
		};
		class ID2_Name2 : SP_Name1
		{
			idc = 4030;
			text = "Petr Bulir";
		};
		class ID3_Title : D_Title
		{
			idc = 3040;
			text = $STR_QG_CREDITS_SALES;
		};
		class ID3_Name3 : SP_Name1
		{
			idc = 4040;
			text = "Jiri Jakubec";
		};
//CEO
		class CEO_Title : PL_Title
		{
			idc = 3050;
			text = $STR_QG_CREDITS_CEO;
		};
		class CEO_Name : PL_Name
		{
			idc = 4050;
			text = "Slavomir Pavlicek";
		};
//DTP
		class DTP_Title : PL_Title
		{
			idc = 3060;
			text = $STR_QG_CREDITS_DTP;
		};
		class DTP_Name : PL_Name
		{
			idc = 4060;
			text = "Pavel Mazl";
		};
//TESTING
		class Testing_Title : PL_Title
		{
			idc = 3070;
			text = $STR_QG_CREDITS_TESTING;
		};
		class Testing_Name1 : PL_Name
		{
			idc = 4070;
			text = "Czech Games Management";
		};
		class Testing_Name2 : PL_Name
		{
			idc = 4071;
			text = "Tomas Pavlicek";
		};
		class Testing_Name3 : PL_Name
		{
			idc = 4072;
			text = "Martin Dlabal";
		};
		class Testing_Name4 : PL_Name
		{
			idc = 4073;
			text = "Jan Kunt";
		};
		class Testing_Name5 : PL_Name
		{
			idc = 4074;
			text = "Filip Krechan";
		};
//ADMINI
		class Admin_Title : PL_Title
		{
			idc = 3080;
			text = $STR_QG_CREDITS_ADMINISTRATION;
		};
		class Admin_Name1 : PL_Name
		{
			idc = 4080;
			text = "Monika Ruzickova";
		};
		class Admin_Name2 : PL_Name
		{
			idc = 4081;
			text = "Miluse Pavlickova";
		};
//SPECIAL THANKS
		class Special_Title : PL_Title
		{
			idc = 3090;
			text = $STR_QG_CREDITS_SPECIAL;
		};
		class Special_Name1 : PL_Name
		{
			idc = 4090;
			text = "Marek Spanel";
		};
		class Special_Name2 : PL_Name
		{
			idc = 4091;
			text = "Markus Kurzawa";
		};
		class Special_Name3 : PL_Name
		{
			idc = 4092;
			text = "Ivan Buchta";
		};
//BES
		class BES_Title : D_Title
		{
			idc = 15551;
			text = $STR_QG_CREDITS_BES;
		};
	};
};
