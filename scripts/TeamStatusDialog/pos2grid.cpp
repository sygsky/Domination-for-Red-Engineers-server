private ["_x","_y","_cfg","_offsetX","_offsetY","_stepX","_stepY","_el","_smallZoom"];
_cfg    =configFile>>"CfgWorlds">>worldName>>"Grid";

_offsetX=getNumber(_cfg>>"offsetX");
_offsetY=getNumber(_cfg>>"offsetY");

_smallZoom = "Zoom1"; // Zoom1/Zoom2 is default used by BIS/ArmA/Sara - _smallZoom can be Zoom0/Zoom1/Zoom2
if (isClass (_cfg>>"Zoom0")) then {_smallZoom = "Zoom0"}; // if Zoom0 exists, assume it uses Zoom0/Zoom1

_stepX=getNumber(_cfg>> _smallZoom >>"stepX");
_stepY=getNumber(_cfg>> _smallZoom >>"stepY");

switch toLower(worldName) do {
	case 'sara': { _offsetY=-480*-1; }; // uses Zoom1 & Zoom2
	case 'saralite': { _offsetY=-480*5+120; }; // uses Zoom1 & Zoom2
	case 'sakakah': { _offsetY=-480*11+160; }; // uses Zoom1 & Zoom2
	case 'vte_australianao': { _offsetY=-480*30; };
	case 'map_ssara': { _offsetY=-480*5+120; }; // uses Zoom1 & Zoom2, offsetX = -4880; offsetY = -7480; 
	case 'intro': { _offsetY=-480*-1; };
	case 'porto': { _offsetY=480*10+320; }; // uses Zoom1 & Zoom2
	case 'syr_darain': { _offsetY=480*10+320; };
	case 'tolafarush': { _offsetY=480*11+320; };
	case 'schmalfelden': { _offsetY=480*10+320; _stepX=100; _stepY=100; }; // uses Zoom0 & Zoom1
	case 'avgani': { _offsetY=480*10+320; _stepX=100; _stepY=100; }; // uses Zoom0 & Zoom1
	case 'map_3demap': { _offsetY=-480*15+0; };
	case 'watkins': { _offsetY=-480*11+160; }; // uses Zoom0 & Zoom1
	case 'uhao': { _offsetY=480*11+320; }; // uses Zoom1 & Zoom2, offsetY = -15360;
};

_x=(_this select 0 select 0)-_offsetX;
_y=(_this select 0 select 1)-_offsetY;


_el=[
	["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"],
	["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"],
	["0","1","2","3","4","5","6","7","8","9"],
	["0","1","2","3","4","5","6","7","8","9"]
];

_xs=([1,-1]select(_x<0));
_x =((abs _x)-((abs _x)mod _stepX))/_stepX;

_y=100*_stepY-_y;
_ys=([1,-1]select(_y<0));
_y=((abs _y)-((abs _y)mod _stepY))/_stepY;

_xf=_x mod 10;
_xc=(_x-_xf)/10;
if(_xs<0)then{_xf=9-_xf;_xc=count(_el select 0)-1-_xc};_xc=_xc mod(count(_el select 0));_xc=_xc max 0;

_yf=_y mod 10;
_yc=(_y-_yf)/10;
if(_ys<0)then{_yf=9-_yf;_yc=count(_el select 2)-1-_yc};_yc=_yc mod(count(_el select 2));_yc=_yc max 0;

format["%1%2%3%4",_el select 0 select _xc,_el select 1 select _xf,_el select 2 select _yc,_el select 3 select _yf]
