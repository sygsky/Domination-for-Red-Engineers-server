//
// ACE flare script modified to use by Sygsky: scripts\emulateFlareFired.sqf
//
// Calld from server!!!
// call as: [getPos _alarm_obj, _height, "Yellow", 400] execVM "scripts\emulateFlareFired.sqf";
//
private ["_col","_fx_flare","_fx_smoke","_factor","_pos","_flare","_flare_type","_die_away_height","_alarm_obj"];

#define __POS    (_this select 0)
#define __HEIGHT ((_this select 1)-5+(random 10))
#define __COL    (_this select 2)
#define __DIST   ((_this select 3)/1600)
//#define __LOCAL (if(count _this < 5)then{false}else{_this select 4})

//#define __DEBUG__

_col = __COL;
//_flare_type = "F_40mm_White"; // default flare type
_flare_type = switch (toUpper(_col)) do {
	case "RED":    { _flare_type = "F_40mm_Red";    };
	case "GREEN":  { _flare_type = "F_40mm_Green";  };
	case "YELLOW": { _flare_type = "F_40mm_Yellow"; };
	default{ _flare_type = "F_40mm_White"; }; //	case "WHITE":  { _flare_type = "F_40mm_White";  };
};

hint localize format["+++ emulateFlareFired.sqf: _this = %1, %2", _this, if (isServer) then {"isServer"} else {"isClient"}];
_pos = __POS;
_alarm_obj = objNull;
if ( typeName _pos == "OBJECT" ) then {
	_alarm_obj = _pos; // store alarm object (tower etc)
	_pos = getPos _pos; // convert object to its position
};
// set flare position as slightly random one
_pos set [ 0, (_pos select 0) + random 2];
_pos set [ 1, (_pos select 1) + random 2];
_pos set [ 2, __HEIGHT ];

_factor = __DIST max 12.5; // if (_factor > 12.5) then { _factor = 12.5; };

#ifdef __DEBUG__
hint localize format[ "+++ emulateFlareFired.sqf: pos %1 col %2 fact %3 ftype %4", _pos, __COL, _factor, _flare_type ];
#endif

_flare = objNull;
if ( isServer ) then {
	_flare = _flare_type createVehicle _pos;
} else {
	_flare = _flare_type createVehicleLocal _pos;
};

if ( isNull _flare ) exitWith { hint localize format["--- emulateFlareFired.sqf: flare object not created (null) at pos %1", _pos]; };
sleep 0.5;

hint localize format["+++ emulateFlareFired.sqf: ""%1"" %2",
	_col,
	format[ "%1 ""%2"" flare is launched above %3",
		if (local _flare) then {"local"} else {"global"},
		typeOf _flare,
		if (isNull _alarm_obj) then { "null" } else { typeOf _alarm_obj }]
];
if ( isServer ) then {
	// call on server as: [ "flare_launched", [ _flare, _flare_color (may be "Red","Green","Yellow","White"), _factor] ] call XSendNetStartScriptClient;
	[ "flare_launched", [ _flare, _col, _factor] ] call XSendNetStartScriptClient; // run on all clients
} else {
// call on client as: [ _flare, _flare_color (may be "Red","Green","Yellow","White"), _factor] execVM "scripts\emulateFlareFiredLocal.sqf";
	[ _flare, _col, _factor] execVM "scripts\emulateFlareFiredLocal.sqf"; // run only on local client
};

_die_away_height = 15 + random 15;
while { alive _flare && (((getPos _flare) select 2) > _die_away_height) } do { sleep 0.5; };

if ( !isNull _flare ) then { /* hint localize format["emulateFlareFired.sqf: flare drop speed %1", velocity _flare];*/ deleteVehicle _flare;};
