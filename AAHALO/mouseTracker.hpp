class ctrlParaDiag
{
	idd = 856;
	moving = false;
	movingEnable = false;
	movingEnabled = false;
	controlsBackground[]={ interface };
	objects[]={ };
	controls[]={  mouseField,altmeter,Map};

	class mouseField
	{
		idc = -1;
		type = 0;
		style = 16;
		colorText[]={ 0,0,0,0 };
		colorBackground[]={ 1,1,1,0 };
		font = "Zeppelin32";
		sizeEx = 0.05;
		lineSpacing = 0;
		x = 0;
		y = 0;
		w = 1;
		h = 1;
		text = "";
		onMouseMoving = "v__float_mousePos =[ _this select 1,_this select 2 ];";
		onKeyDown = "v__int_reqKeys set [ count v__int_reqKeys, _this select 1 ];";
	};
	class altmeter
	{
		idc = 857;
		type = 0;
		style = 0x01;
		colorText[]={ 0,0,0,1 };
		colorBackground[]={ 0,0,0,0 };
		font = "Zeppelin32";
		sizeEx = 0.03;
		lineSpacing = 0;
		x = 0.715;
		y = 0.635;
		w = 0.1;
		h = 0.2;
		border = 1;
		borderSize = 10;
		text = $STR_SYS_616; //"Высота";
	};
	class Map: RscMapControl
	{
		idc = 858;
		colorBackground[] = {1,1,1,1};
		colorSea[] = {0.56,0.8,0.98,0.5};
		x = 0.0;
		y = 0.0;
		w = 0.3;
		h = 0.3;
		default = true;
		showCountourInterval = false;
	};
	class interface
	{
		idc = -1;
		type = 0;
		style = 48;
		colorText[]={ 1,1,1,1 };
		colorBackground[]={ 0.4,0.4,0.4,1 };
		font = "Zeppelin32";
		sizeEx = 0.01;
		lineSpacing = 0;
		x = 0.7;
		y = 0.1;
		w = 0.3;
		h = 0.8;
		border = 1;
		borderSize = 10;
		text = "AAHALO\altimeter.paa";
	};
};