// by Xeno. x_helilift_wreck.sqf

//#define __PRINT__

private ["_id","_menu_lift_shown","_nearest","_nearest_pos","_npos","_nx","_ny","_p_x","_p_y","_p_z","_pos","_posi","_px","_py","_release_id","_vehicle"];

if (!X_Client) exitWith {};

#define MAX_DEPTH_TO_LIFT -15
_vehicle = _this select 0;

Attached_Vec = objNull;
Vehicle_Attached = false;
Vehicle_Released = false;
_menu_lift_shown = false;
_nearest = objNull;
_id = -1;

sleep 10.123;

while {(alive _vehicle) && (alive player) && player_is_driver} do {
	if ((driver _vehicle) == player) then {
		_pos = getPos _vehicle;

		if (!Vehicle_Attached && /* (_pos select 2 > 2.5) && */ (_pos select 2 < 30)) then {
			_nearest = objNull;
			_nobjects = nearestObjects [ _vehicle, [ "LandVehicle", "Air", "Ship" ], 40 ]; //+++ Sygsky: changed search dist from 70 to 100 m
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
			if (!(isNull _nearest) && _nearest != Attached_Vec && (damage _nearest >= 1) && ((typeOf _nearest) in x_heli_wreck_lift_types)) then {
				_nearest_pos = getPos _nearest;
				_nx = _nearest_pos select 0;_ny = _nearest_pos select 1;_px = _pos select 0;_py = _pos select 1;
//				if ((_px <= _nx + 10 && _px >= _nx - 10) && (_py <= _ny + 10 && _py >= _ny - 10)) then {
				if ( ((abs(_px - _nx)) < 10) && (abs(_py - _ny) < 10) ) then {
					if (!_menu_lift_shown) then {
						_id = _vehicle addAction [localize "STR_SYS_35", "x_scripts\x_heli_action.sqf",-1,100000]; // "Lift vehicle"
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
			if (_menu_lift_shown) then {
				_vehicle removeAction _id;
				_menu_lift_shown = false;
			};

			sleep 0.1;

			if (isNull _nearest) then {
				Vehicle_Attached = false;
				Vehicle_Released = false;
			} else {
				if (Vehicle_Attached) then {

				    if ( !( (typeof _nearest) in x_heli_wreck_lift_types ) ) exitWith {
                        // vehicle not in legal list
                        //++ Sygsky: found that vehicle ready to lift isn't in legal list! Clear possible activity and report user about
                        [_vehicle, format[localize "STR_SYS_38_1",typeOf _nearest]] call XfVehicleChat; // "The vehicle (%1) not in restore list..."
                        Vehicle_Attached = false;
                        Vehicle_Released = false;
                        Attached_Vec = objNull;
                    };

                    // task #347.1: vehicle is too deep in water to get in
/**
                    if ( (surfaceIsWater (getPos _nearest)) && ( ( ( _nearest modelToWorld [0,0,0] ) select 2 ) < MAX_DEPTH_TO_LIFT ) ) exitWith {
                        [_vehicle, format[localize "STR_SYS_38_2",typeOf _nearest, round ( ( _nearest modelToWorld [0,0,0] ) select 2 )]] call XfVehicleChat; // "This vehicle (%1) is too deep (%2 m.), we will not get it, alas..."
                        Vehicle_Attached = false;
                        Vehicle_Released = false;
                        Attached_Vec = objNull;
                        call SYG_playWaterSound;
                    };
*/
#ifdef __PRINT__
                    if ( (surfaceIsWater (getPos _nearest)) ) then {
                        hint localize format["+++ x_helilift_wreck.sqf: %1 mTW %2,gP %3,gPA %4,d %5; %6 mTW %7,gP %8,gPA %9",
                        typeOf _nearest,
                        _nearest modelToWorld [0,0,0],
                        getPos _nearest,
                        getPosASL _nearest,
                        _nearest distance _vehicle,
                        typeOf _vehicle,
                        _vehicle modelToWorld [0,0,0],
                         getPos _vehicle,
                         getPosASL _vehicle]
                    };
#endif
                    _release_id = _vehicle addAction [localize "STR_SYS_36"/* "СБРОСИТЬ ТЕХНИКУ" */, "x_scripts\x_heli_release.sqf",-1,100000];
                    _rec_msg = localize (if (_nearest call SYG_vehIsRecoverable) then {"STR_SYS_37_1"} else {"STR_SYS_37_0"});
                    hint localize ["+++ x_helilift_wreck: %1, ""RECOVERABLE""=%2 (%3)", typeOf _nearest, _nearest getVariable "RECOVERABLE", localize _rec_msg];
                    [_vehicle, format[localize "STR_SYS_37",[typeOf (_nearest),0] call XfGetDisplayName, _rec_msg]] call XfVehicleChat;
                    Attached_Vec = _nearest;

                    _height = 15;
                    while {alive _vehicle && player_is_driver && (!isNull _nearest) && alive player && !Vehicle_Released} do {
                        _vup = vectorUp _vehicle;
                        _vdir = vectorDir _vehicle;
                        _voffset = (speed _vehicle min 50) / 3.57;
                        _fheight = _height + (2.5 min (_vehicle modelToWorld [0,-1-_voffset,-_height] select 2));
                        _nearest setPos (_vehicle modelToWorld [0,-1-_voffset,-_fheight]);
                        _nearest setVectorDir _vdir;
                        _nearest setVectorUp  _vup;
                        _nearest setVelocity  (velocity _vehicle);//[0,0,0];
                        sleep 0.001;
                    };

                    Vehicle_Attached = false;
                    Vehicle_Released = false;

                    Attached_Vec = objNull;

                    if (!alive _nearest || !alive _vehicle) then {
                        _vehicle removeAction _release_id;
                    } else {
                        [_vehicle, localize "STR_SYS_39"/* "Техника сброшена..." */] call XfVehicleChat;
                    };

					if ((position _nearest) select 2 > 20) then {
    					while { (!(isNull _nearest)) && ( (position _nearest) select 2 < 10) } do {sleep 0.1};
					};

					sleep 1.012;
					_npos = position _nearest;
					_nearest setPos [_npos select 0, _npos select 1, 0];
					_nearest setVelocity [0,0,0];
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