// by Xeno: x_helirespawn2.sqf, runs only on real server, not X_SPE
if (!isServer) exitWith{};

private ["_heli_array", "_vec_a", "_vehicle", "_number_v", "_is_west_chopper", "_i", "_tt", "_ifdamage", "_empty",
        "_disabled", "_empty_respawn", "_startpos", "_hasbox", "_empty_respawn", "_cnt"];

#include "x_setup.sqf"
#include "x_macros.sqf"

// [[ch1,"HR1",true],[ch2,"HR2",true],[ch3,"HR3",false,1500],[ch4,"HR4",false,1500]] execVM "x_scripts\x_helirespawn2.sqf";

_cnt = 0;
_heli_array = [];
{
    //  vehicle name is "ch1" etc
	_vec_a    = _x;

	_vehicle       = argp(_vec_a,0);
	_number_v      = argp(_vec_a,1);
    _ifdamage      = argp(_vec_a,2);
	_empty_respawn = argpopt(_vec,3,0); // min dist to return
	// offset in veh array:              0,        1,        2,  3,                 4,                 5,              6,        7
	_heli_array = _heli_array + [[_vehicle,_number_v,_ifdamage,  0, position _vehicle,direction _vehicle,typeOf _vehicle,_empty_respawn]];

	// change cargo for Mi-17 only (USSR version). FIXME: do the same for non USSR version heli
/*
    if ((typeOf _vehicle) == "ACE_Mi17_MG") then
    {
        _vehicle setVehicleInit "[this, 2] call SYG_setHeliParaCargo;";
        _cnt = _cnt + 1;
    };
*/
#ifndef __TT__
	call compile format ["%1 =_vehicle;publicVariable ""%1"";", _number_v];
#endif

#ifdef __TT__
	_is_west_chopper = false;
	{if (_number_v == (_x select 0)) exitWith {_is_west_chopper = true;}} forEach d_choppers_west;
	if (!_is_west_chopper) then {
		call compile format ["
			%1 =_vehicle;
			publicVariable ""%1"";
			%1 addEventHandler [""killed"", {_this execVM ""x_scripts\x_checkveckillracs.sqf""}];
		", _number_v];
	} else {
		call compile format ["
			%1 =_vehicle;
			publicVariable ""%1"";
			%1 addEventHandler [""killed"", {_this execVM ""x_scripts\x_checkveckillwest.sqf""}];
		", _number_v];
	};
#endif

} forEach _this;

// if ( _cnt > 0 ) then { processInitCommands; };


_this = nil;

while {true} do {
	if (X_MP) then {
		if ( (call XPlayersNumber) == 0 ) then
		{
			waitUntil {sleep (20.012 + random 1);(call XPlayersNumber) > 0};
		};
	};
	__DEBUG_NET("x_helirespawn2.sqf",(call XPlayersNumber))
	for "_i" from 0 to (count _heli_array - 1) do {
		_tt = 20 + random 10;
		sleep _tt;
		_vec_a = _heli_array select _i;
		_vehicle = _vec_a select 0;
		_ifdamage = _vec_a select 2;

		_empty = {alive _x} count (crew _vehicle) == 0;

		_disabled = false;
		if (!_ifdamage) then {
			_empty_respawn = _vec_a select 3;
			if (_empty && ((_vehicle distance _startpos) > 10) ) then {
				_empty_respawn = _empty_respawn + _tt;
				_vec_a set [3,_empty_respawn];
			};

			if (_empty && (_empty_respawn > (_vec_a select 7)) ) then {
				_disabled = true;
			} else {
				if (!_empty && alive _vehicle) then {_vec_a set [3,0]};
			};
		};

		if (damage _vehicle > 0.9) then {_disabled = true;};

//		if ((_disabled && _empty) || (_empty && !(alive _vehicle))) then {
		if ( _empty && (_disabled || !(alive _vehicle)) ) then {
			_hasbox = _vehicle getVariable "d_ammobox";
			if (format["%1",_hasbox] == "<null>") then {
				_hasbox = false;
			};
			if (_hasbox) then {
				ammo_boxes = ammo_boxes - 1;
				["ammo_boxes",ammo_boxes] call XSendNetVarClient;
			};
			sleep 0.1;
			deleteVehicle _vehicle;
			if (!_ifdamage) then {_vec_a set [3,0]};
			sleep 0.5;
			_vehicle = objNull;
			_vehicle = (_vec_a select 6) createVehicle (_vec_a select 4);
			_vehicle setPos (_vec_a select 4);
			_vehicle setdir (_vec_a select 5);
			_vec_a set [0,_vehicle];
			_number_v = _vec_a select 1;
            // change cargo for Mi-17 only (USSR version). FIXME: do the same for non USSR version heli
            if ((typeOf _vehicle) == "ACE_Mi17_MG") then
            {
                _vehicle setVehicleInit "[this, 2] call SYG_setHeliParaCargo;";
                processInitCommands;
            };

#ifndef __TT__
			call compile format ["%1 =_vehicle;publicVariable ""%1"";", _number_v];
			if (X_SPE) then {
				_dchop_v = [];
				{
					if (_number_v == _x select 0) exitWith {
						_dchop_v = _x;
					};
				} forEach d_choppers;
				if (count _dchop_v > 0) then {
					switch (_dchop_v select 1) do {
						case 0: {
							_vehicle addAction [localize "STR_SYS_79_1","x_scripts\x_vecdialog.sqf",[],-1,false]; // "Меню вертолета"
							_vehicle addEventHandler ["getin", {[_this,0] execVM "x_scripts\x_checkhelipilot.sqf";}];
							_vehicle addEventHandler ["getout", {_this execVM "x_scripts\x_checkhelipilotout.sqf";}];
						};
						case 1: {
							_vehicle addAction [localize "STR_SYS_79_1","x_scripts\x_vecdialog.sqf",[],-1,false]; // "Меню вертолета"
							_vehicle addEventHandler ["getin", {_this execVM "x_scripts\x_checkhelipilot_wreck.sqf";}];
							_vehicle addEventHandler ["getout", {_this execVM "x_scripts\x_checkhelipilotout.sqf";}];
						};
						case 2: {
							_vehicle addAction [localize "STR_SYS_79_1","x_scripts\x_vecdialog.sqf",[],-1,false]; // "Меню вертолета"
							_vehicle addEventHandler ["getout", {[_this,1] execVM "x_scripts\x_checkhelipilot.sqf";}];
						};
					};
				};
			};
#else
			if (!_is_west_chopper) then {
				call compile format ["
					%1=_vehicle;
					publicVariable ""%1"";
					%1 addEventHandler [""killed"", {_this execVM ""x_scripts\x_checkveckillracs.sqf"";}];
				", _number_v];
				if (X_SPE) then {
					_dchop_v = [];
					{
						if (_number_v == _x select 0) exitWith {
							_dchop_v = _x;
						};
					} forEach d_choppers_racs;
					if (count _dchop_v > 0) then {
						switch (_dchop_v select 1) do {
							case 0: {
								_vehicle addAction [localize "STR_SYS_79_1","x_scripts\x_vecdialog.sqf",[],-1,false]; // "Меню вертолета"
								_vehicle addEventHandler ["getin", {[_this,0] execVM "x_scripts\x_checkhelipilot.sqf";}];
								_vehicle addEventHandler ["getout", {_this execVM "x_scripts\x_checkhelipilotout.sqf";}];
								_vehicle addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillracs.sqf";}];
							};
							case 1: {
								_vehicle addAction [localize "STR_SYS_79_1","x_scripts\x_vecdialog.sqf",[],-1,false]; // "Меню вертолета"
								_vehicle addEventHandler ["getin", {_this execVM "x_scripts\x_checkhelipilot_wreck.sqf";}];
								_vehicle addEventHandler ["getout", {_this execVM "x_scripts\x_checkhelipilotout.sqf";}];
								_vehicle addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillracs.sqf";}];
							};
							case 2: {
								_vehicle addAction [localize "STR_SYS_79_1","x_scripts\x_vecdialog.sqf",[],-1,false]; // "Меню вертолета"
								_vehicle addEventHandler ["getin", {[_this,1] execVM "x_scripts\x_checkhelipilot.sqf";}];
								_vehicle addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillracs.sqf";}];
							};
						};
					};
				};
			} else {
				call compile format ["
					%1=_vehicle;
					publicVariable ""%1"";
					%1 addEventHandler [""killed"", {_this execVM ""x_scripts\x_checkveckillwest.sqf""}];
				", _number_v];
				if (X_SPE) then {
					_dchop_v = [];
					{
						if (_number_v == _x select 0) exitWith {
							_dchop_v = _x;
						};
					} forEach d_choppers_west;
					if (count _dchop_v > 0) then {
						switch (_dchop_v select 1) do {
							case 0: {
								_vehicle addAction [localize "STR_SYS_79_1","x_scripts\x_vecdialog.sqf",[],-1,false]; // "Меню вертолета"
								_vehicle addEventHandler ["getin", {[_this,0] execVM "x_scripts\x_checkhelipilot.sqf"}];
								_vehicle addEventHandler ["getout", {_this execVM "x_scripts\x_checkhelipilotout.sqf"}];
								_vehicle addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillwest.sqf"}];
							};
							case 1: {
								_vehicle addAction [localize "STR_SYS_79_1","x_scripts\x_vecdialog.sqf",[],-1,false];// "Меню вертолета"
								_vehicle addEventHandler ["getin", {_this execVM "x_scripts\x_checkhelipilot_wreck.sqf"}];
								_vehicle addEventHandler ["getout", {_this execVM "x_scripts\x_checkhelipilotout.sqf"}];
								_vehicle addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillwest.sqf"}];
							};
							case 2: {
								_vehicle addAction [localize "STR_SYS_79_1","x_scripts\x_vecdialog.sqf",[],-1,false];// "Меню вертолета"
								_vehicle addEventHandler ["getin", {[_this,1] execVM "x_scripts\x_checkhelipilot.sqf"}];
								_vehicle addEventHandler ["killed", {_this execVM "x_scripts\x_checkveckillwest.sqf"}];
							};
						};
					};
				};
			};
#endif
		}; // if ((_disabled && _empty) || (_empty && !(alive _vehicle))) then
	}; // for "_i" from 0 to (count _heli_array - 1) do
	sleep 20 + random 5;
};
