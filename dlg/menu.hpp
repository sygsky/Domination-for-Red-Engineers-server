class TeleportModule
{
	idd = 100001;
	movingEnable = false;
	controlsBackground[] = {bg1};
	objects[] = {};
	onLoad="_test = 0 execVM ""dlg\update_dlg.sqf""";
	controls[] = {respawn,maprespawn,dtext,mr1inair,mr2inair,respawncaption,BaseButton,Mr1Button,Mr2Button,Tdestination};

	class bg1 : RscBG
	{
		x = 0;
		y = 0;
		idc = 100101;
		colorBackground[] = {0, 0,0, 1};
		w = 1;
		h = 1;
	};
	class respawn : RscNavButton
	{
		y = 0.67;
		w = 0.3;
		x = 0.625;
		idc = 100102;
		text = $STR_SYS_34;//"Телепорт";
		action = "_bt = 0 execVM ""dlg\beam_tele.sqf""";
	};
	class BaseButton : RscNavButton
	{
		y = 0.34;
		w = 0.3;
		x = 0.625;
		idc = 100107;
		text = "База";
		colorBackground[] = {0.04, 0.22, 0.54, 0.7};
		action = "_bt = [0] execVM ""dlg\update_target.sqf""";
	};
	class Mr1Button : RscNavButton
	{
		y = 0.41;
		w = 0.3;
		x = 0.625;
		idc = 100108;
		colorBackground[] = {0.04, 0.22, 0.54, 0.7};
		text = $STR_SYS_71;	//"Мобильный респаун 1";
		action = "_bt = [1] execVM ""dlg\update_target.sqf""";
	};
	class Mr2Button : RscNavButton
	{
		y = 0.48;
		w = 0.3;
		x = 0.625;
		idc = 100109;
		colorBackground[] = {0.04, 0.22, 0.54, 0.7};
		text = $STR_SYS_72;	// "Мобильный респаун 2";
		action = "_bt = [2] execVM ""dlg\update_target.sqf""";
	};
	class Tdestination : RscText
	{
		idc = 100110;
		x = 0.625;
		y = 0.55;
		w = 0.3;
		h = 0.1;
		sizeEx = 0.025;
		text = "";
	};
	class dtext : RscText
	{
		x = 0.87;
		y = 0.92;
		w = 0.3;
		h = 0.1;
		sizeEx = 0.03;
		colorText[] = { 0, 0, 1, 0.5 };
		text = $STR_SYS_70; //"Доминация!"
	};
	class maprespawn : RscMapControl
	{
		idc = 100104;
		x = 0.07;
		y = 0.27;
		w	= 0.51;
		h	= 0.5;
	};
	class mr1inair : RscText
	{
		idc = 100105;
		x = 0.623;
		y = 0.75;
		w = 0.3;
		h = 0.1;
		sizeEx = 0.02;
		text = "";
	};
	class mr2inair : RscText
	{
		idc = 100106;
		x = 0.623;
		y = 0.8;
		w = 0.3;
		h = 0.1;
		sizeEx = 0.02;
		text = "";
	};
	class respawncaption : RscText
	{
		idc = 100111;
		x = 0.4;
		y = 0.07;
		w = 0.6;
		h = 0.2;
		sizeEx = 0.03;
		text = $STR_SYS_69; //"Выбор места телепортирования"
	};
};
