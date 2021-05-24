//
// ACE flare script modified to use by Sygsky: scripts\emulateFlareFired.sqf
//
// call as: [getPos _alarm_obj, _height, "Yellow", 400, true] execVM "scripts\emulateFlareFired.sqf";
//
private ["_col","_fx_flare","_fx_smoke","_factor","_pos","_flare","_flare_type","_die_away_height"];

#define __POS    (_this select 0)
#define __HEIGHT ((_this select 1)-5+(random 10))
#define __COL    (_this select 2)
#define __DIST   ((_this select 3)/1600)
#define __LOCAL (if(count _this < 5)then{false}else{_this select 4})

//#define __DEBUG__

//#define __R [[1,0,0,1],[1,0,0,0.8],[1,0,0,1],[1,0,0,0.9]]
#define __R [[1,0,0,0.7],[1,0,0,0.5],[1,0,0,0.7],[1,0,0,0.6]]
#define __G [[0,1,0,1],[0,1,0,0.8],[0,1,0,1],[0,1,0,0.9]]
//#define __W [[1,1,1,1],[1,1,1,1.8],[1,1,1,1],[1,1,1,1.9]]
#define __W [[1,1,1,0.7],[1,1,1,0.5],[1,1,1,0.7],[1,1,1,0.9]]
#define __Y [[1,1,0,1],[1,1,0,0.8],[1,1,0,1],[1,1,0,0.9]]
#define __VEL velocity _flare
#define __I .025

_col = __COL;
//_flare_type = "F_40mm_White"; // default flare type
_flare_type = switch (toUpper(_col)) do {
	case "RED":    { _flare_type = "F_40mm_Red";    };
	case "GREEN":  { _flare_type = "F_40mm_Green";  };
	case "YELLOW": { _flare_type = "F_40mm_Yellow"; };
	default{ _flare_type = "F_40mm_White"; }; //	case "WHITE":  { _flare_type = "F_40mm_White";  };
};

_pos = __POS;
if ( typeName _pos == "OBJECT" ) then {_pos = getPos _pos;}; // convert object to its position
_pos set [ 2, __HEIGHT ];

_factor = __DIST max 12.5; // if (_factor > 12.5) then { _factor = 12.5; };

#ifdef __DEBUG__
hint localize format[ "+++ emulateFlareFired.sqf: pos %1 col %2 fact %3 ftype %4", _pos, __COL, _factor, _flare_type ];
#endif

_flare = objNull;
_flare = _flare_type createVehicle _pos;
__POS setVariable ["flare", true]; // mark flare is on
if ( isNull _flare ) exitWith { hint localize format["--- emulateFlareFired.sqf: flare object not created (null) at pos %1", _pos]; };

sleep 0.5;

if (__LOCAL) then {
// call on client as: [ _flare, _flare_color (may be "Red","Green","Yellow","White"), _factor] execVM "scripts\emulateFlareFiredLocal.sqf";
	 [ _flare, _col, _factor] execVM "scripts\emulateFlareFiredLocal.sqf"; // run only on local client
} else {
// call on server as: [ "flare_launched", [ _flare, _flare_color (may be "Red","Green","Yellow","White"), _factor] ] call XSendNetStartScriptClient;
	[ "flare_launched", [ _flare, _col, _factor] ] call XSendNetStartScriptClient; // run on all clients
};

_die_away_height = 15 + random 15;
while { alive _flare && (((getPos _flare) select 2) > _die_away_height) } do { sleep 0.5; };

//if ( !isNull _flare ) then {hint localize format["emulateFlareFired.sqf: flare drop speed %1. Fog %2, fogForecast %3, weather change %4", velocity _flare, fog, fogForecast,nextWeatherChange]; 
if ( !isNull _flare ) then { /* hint localize format["emulateFlareFired.sqf: flare drop speed %1", velocity _flare];*/ deleteVehicle _flare;};
__POS setVariable [ "flare", nil ]; // mark flare is off
	