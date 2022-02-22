// x_helilift.sqf, by Xeno. Called on client computer
private ["_vehicle", "_menu_lift_shown", "_nearest", "_id", "_possible_types", "_pos", "_nobjects", "_dummy", "_nearest_pos",
		 "_nx", "_ny", "_px", "_py", "_release_id", "_height", "_vup", "_vdir", "_npos", "_fheight","_reveal_name"];

if (!X_Client) exitWith {};

#include "x_setup.sqf"

_vehicle = _this select 0; // heli to lift with

Vehicle_Attached = false;
Vehicle_Released = false;
Attached_Vec = objNull;
_menu_lift_shown = false;
_nearest = objNull;
_id = -1;

sleep 10.123;

_possible_types = [];
#ifndef __TT__
{
	call compile format ["
		if (%1 == _vehicle) exitWith {
			_possible_types = %2;
		};
	", _x select 0, _x select 3];
} forEach d_choppers;
#endif
#ifdef __TT__
if (playerSide == west) then {
	{
		call compile format ["
			if (%1 == _vehicle) exitWith {
				_possible_types = %2;
			};
		", _x select 0, _x select 3];
	} forEach d_choppers_west;
} else {
	{
		call compile format ["
			if (%1 == _vehicle) exitWith {
				_possible_types = %2;
			};
		", _x select 0, _x select 3];
	} forEach d_choppers_racs;
};
#endif

while {(alive _vehicle) && (alive player) && player_is_driver} do {
	if ((driver _vehicle) == player) then {
		_pos = getPos _vehicle;

		if (!Vehicle_Attached && (_pos select 2 > 2.5) && (_pos select 2 < 11)) then {
			_nearest = objNull;
			_nobjects = nearestObjects [_vehicle, ["LandVehicle","Air"],40];
			if (count _nobjects > 0) then {
				_dummy = _nobjects select 0;
				if (_dummy == _vehicle) then {
					if (count _nobjects > 1) then {
						_nearest = _nobjects select 1;
					};
				} else {
					_nearest = _dummy;
				};
			};
			sleep 0.1;
			if (!(isNull _nearest) && _nearest != Attached_Vec && (((typeOf _nearest) in _possible_types) || (_nearest isKindOf "StaticWeapon"))) then {
				_nearest_pos = getPos _nearest;
				_nx = _nearest_pos select 0;_ny = _nearest_pos select 1;_px = _pos select 0;_py = _pos select 1;
				if ((_px <= _nx + 10 && _px >= _nx - 10) && (_py <= _ny + 10 && _py >= _ny - 10)) then {
					if (!_menu_lift_shown) then {
						_id = _vehicle addAction [ localize "STR_SYS_35", "x_scripts\x_heli_action.sqf",-1,100000]; // "Поднять технику"
						_menu_lift_shown = true;
					};
				} else {
					_nearest = objNull;
					if (_menu_lift_shown) then {
						_vehicle removeAction _id;
						_menu_lift_shown = false;
					};
				};
			};
		} else {
			if (_menu_lift_shown) then
			{
				_vehicle removeAction _id;
				_menu_lift_shown = false;
			};

			sleep 0.1;

			if (isNull _nearest) then {
				Vehicle_Attached = false;
				Vehicle_Released = false;
			} else {
				if (Vehicle_Attached) then {
				
					// ++ Sygsky: checking again legal type of vehicle to lift here
				  
					if ( !((typeOf _nearest) in _possible_types || (_nearest isKindOf "StaticWeapon"))) exitWith 	{
                        // vehicle not in legal list
                        //++ Sygsky: found that vehicle ready to lift isn't in legal list! Clear possible activity and report user about
                        [_vehicle, format[localize "STR_SYS_38", typeOf _nearest]] call XfVehicleChat; // "Overwhelming vehicle (%1)..."
                        Vehicle_Attached = false;
                        Vehicle_Released = false;
                        Attached_Vec = objNull;
                    };

                    if ( isNull Attached_Vec ) then {
                        //hint localize format["+++ x_helilift.sqf: vehicle %1 lifted", typeOf _nearest];
                        Attached_Vec = _nearest;
						_release_id = _vehicle addAction [ localize "STR_SYS_36", "x_scripts\x_heli_release.sqf",-1,100000]; //"Сбросить технику"
                        [_vehicle, format[localize "STR_SYS_37",[typeOf (_nearest),0] call XfGetDisplayName]] call XfVehicleChat;
	  					_reveal_name = "";
						switch (_nearest) do {
							case MRR1: {
								_reveal_name = "MRR1";
								mr1_in_air=true;
								["mr1_in_air",mr1_in_air] call XSendNetStartScriptAllDiff;
								["mr1_lift_chopper",_vehicle] call XSendNetStartScriptServer;
	                        	hint localize format["+++ reveal_name = ""%1""", _reveal_name];
							};
							case MRR2: {
								_reveal_name = "MRR2";
								mr2_in_air=true;
								["mr2_in_air",mr2_in_air] call XSendNetStartScriptAllDiff;
								["mr2_lift_chopper",_vehicle] call XSendNetStartScriptServer;
	                        	hint localize format["+++ reveal_name = ""%1""", _reveal_name];
							};
#ifdef __TT__
							case MRRR1: {
								_reveal_name = "MRRR1";
								mrr1_in_air=true;
								["mrr1_in_air",mrr1_in_air] call XSendNetStartScriptAllDiff;
								["mrr1_lift_chopper",_vehicle] call XSendNetStartScriptServer;
							};
							case MRRR2: {
								_reveal_name = "MRRR2";
								mrr2_in_air=true;
								["mrr2_in_air",mrr2_in_air] call XSendNetStartScriptAllDiff;
								["mrr2_lift_chopper",_vehicle] call XSendNetStartScriptServer;
							};
#endif
						};
	  
						_height = 15;
                        _fuel = fuel _nearest;
                        // hint localize format["+++ x_helilift.sqf: vehicle local=%1", local _vehicle]; // yes, it is really local
                        _nearest setFuel 0;
						while {alive _vehicle && player_is_driver && alive _nearest && alive player && !Vehicle_Released} do {
							_vup = vectorUp _vehicle;
							_vdir = vectorDir _vehicle;
							_voffset = (speed _vehicle min 50) / 3.57;
							_fheight = _height + (2.5 min (_vehicle modelToWorld [0,-1-_voffset,-_height] select 2));
							_nearest_pos = _vehicle modelToWorld [0,-1-_voffset,-_fheight];
							_nearest setPos _nearest_pos;
                            _nearest setVectorDir _vdir; // TODO: use setVectorDirAndUp
							_nearest setVectorUp  _vup;
                            _nearest setVelocity (velocity _vehicle);  //+++ Sygsky - let vehicle to inertially fly ahead some distance
                            _nearest engineOn false;
                            //_nearest setVelocity [0,0,0];
							sleep 0.001;
						};
                        _nearest setFuel _fuel;
						_nearest engineOn false;
						_nearest setVelocity (velocity _vehicle);  //+++ Sygsky - let vehicle to inertially fly ahead some distance

                        // detect the ground bump speed of vehicle
/*
                        _nearest spawn
                        {
                            hint localize format["+++ x_helilift.sqf: start time %1, v %2, h  %3", (round(time * 1000)) / 100 , velocity _this, (round(getPos _this select 2) *100)/100];
                            _time = time;
                            while { ((velocity _this) distance [0,0,0]) > 0.1 } do
                            {
                                if (( time - _time) >= 0.1) then
                                {
                                    _time = time;
                                    hint localize format["=== x_helilift.sqf: time %1, v %2, h %3", (round(time * 100)) / 100 , velocity _this, (round(getPos _this select 2) *100)/100];
                                };
                                sleep 0.01;
                            };
                            hint localize format["--- x_helilift.sqf: end time %1, v %2, h  %3", (round(time * 100)) / 100 , velocity _this, (round(getPos _this select 2) *100)/100];
                        };
*/
						Vehicle_Attached = false;
						Vehicle_Released = false;
	  
                        if (!alive _vehicle) then {
                            _vehicle removeAction _release_id;
                        } else {
                            [_vehicle, localize "STR_SYS_39"] call XfVehicleChat; //"Техника сброшена..."
                        };

                        // Wait until stop format["%1 setPos %2; %1 setDir %3", _reveal_name, getPos _nearest, getDir _nearest]
                        waitUntil { ((velocity _nearest) distance [0,0,0] < 0.1) };

                        sleep 1.012;
                        _npos = position _nearest;
                        _nearest setPos [_npos select 0, _npos select 1, 0]; // TODO: allow to be upside down if dropping height was high
                        _nearest setVelocity [0,0,0];
                        if ( isEngineOn _nearest ) then { _nearest engineOn false; };
                        Attached_Vec = objNull;

                        // reveal to all players new position of MHQ. It can help!
                        hint localize format["_reveal_name = ""%1""", _reveal_name];
                        if (_reveal_name != "") then {
                        	_str  = format["hint localize format[""+++ %1(1) %2"", getPos %1]", _reveal_name, "%1" ];
                        	_str1 = format["hint localize format[""+++ %1(2) %2"", getPos %1]", _reveal_name, "%1" ];
                        	_str  = format["%1; %2 setPos %3; %2 setDir %4;sleep 0.1;%5;", _str, _reveal_name, getPos _nearest, getDir _nearest, _str1];
                        	hint localize format["+++ ""remote_execute"" sent: ""%1""", _str];
                        	["remote_execute", _str] call XSendNetStartScriptClient; // Sent to all clients only
                        };

                        // send information to all clients about new position of well known lifted vehicle
						switch (_nearest) do {
							case MRR1: {
								mr1_in_air = false;
								["mr1_in_air",mr1_in_air] call XSendNetStartScriptAllDiff;
								["mr1_lift_chopper",objNull] call XSendNetStartScriptServer;
								// Never  use statement like publicVariable "MRR1", it will have strange effect in multiple items of "Menu MHQ 1", the same stands for MHQ 2 also
							};
							case MRR2: {
								mr2_in_air = false;
								["mr2_in_air",mr2_in_air] call XSendNetStartScriptAllDiff;
								["mr2_lift_chopper",objNull] call XSendNetStartScriptServer;
							};
#ifdef __TT__
							case MRRR1: {
								mrr1_in_air = false;
								["mrr1_in_air",mrr1_in_air] call XSendNetStartScriptAllDiff;
								["mrr1_lift_chopper",objNull] call XSendNetStartScriptServer;
							};
							case MRRR2: {
								mrr2_in_air = false;
								["mrr2_in_air",mrr2_in_air] call XSendNetStartScriptAllDiff;
								["mrr2_lift_chopper",objNull] call XSendNetStartScriptServer;
							};
#endif
						};
					};
				};
			};
		};
	};
	sleep 0.51;
};

if (!(alive _vehicle) || !(alive player)) then {
	player_is_driver = false;
	_vehicle removeAction vec_id;
};

if (true) exitWith {};