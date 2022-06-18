// by Xeno: x_scripts\x_bike.sqf
private ["_create_bike", "_disp_name", "_str", "_pos", "_vehicle", "_exitit", "_dosearch", "_index", "_parray", "_rank"];
if (!X_Client) exitWith {};

#include "x_setup.sqf"

_create_bike = (_this select 3) select 0;
_b_mode = (_this select 3) select 1; // 0 - created from the MHQ diallog, 1 - created from jump flag (d_jumpflag_vec != "")

#ifdef __RANKED__
_exitit = false;
if (_create_bike in d_create_bike) then {
	if (count d_create_bike > 0) then {
		_index = d_create_bike find _create_bike;
		if (_index != -1) then {
			if (score player < d_points_needed select _index) then {
				_rank = (d_points_needed select _index) call XGetRankFromScore;
				(format [localize "STR_SYS_329"/* "%2: для выгрузки требуется звание: %1." */,_rank call XGetRankStringLocalized, _create_bike]) call XfGlobalChat;
				_exitit = true;
			};
		};
	} else { // if (count d_create_bike > 1) then
		(localize "STR_SYS_329_1"/* "Устройства для выгрузки не предусмотрены" */) call XfGlobalChat;
		_exitit = true;
	};
	
};
if (_exitit) exitWith {};

if (score player < (d_ranked_a select 6)) exitWith {
		_rank = ((d_ranked_a select 6) call XGetRankFromScore)call XGetRankStringLocalized;
		(format[localize "STR_SYS_329"/* "%2: для выгрузки требуется звание: %1." */,_create_bike,_rank call XGetRankStringLocalized]) call XfGlobalChat;
};
#endif

_disp_name = [_create_bike,0] call XfGetDisplayName;

if (vehicle player != player) exitWith {
	_str = format [localize "STR_SYS_330"/* "Нельзя выгрузить %1, находяcь в транспортном средстве..." */, _disp_name];
	_str call XfGlobalChat;
};

if (bike_created && _b_mode == 1) exitWith {
	(localize "STR_SYS_331") /* "Выгрузка доступна только один раз, после респауна..." */ call XfGlobalChat;
};

if (time > d_vec_end_time && !isNull d_flag_vec) then {
	if (({alive _x} count (crew d_flag_vec)) == 0) then {
		deleteVehicle d_flag_vec;
		d_flag_vec = objNull;
		d_vec_end_time = -1;
	};
};
if (!isNull d_flag_vec && alive d_flag_vec && _b_mode == 0) exitWith {
	(format [localize "STR_SYS_332"/* "Выгрузка завершена... Вновь она будет доступна через %1 мин." */,0 max (ceil((d_vec_end_time - time)/60))]) call XfGlobalChat;
};

#ifdef __RANKED__
//player addScore (d_ranked_a select 5) * -1;
((d_ranked_a select 5) * -1) call SYG_addBonusScore;
#endif

_pos = position player;
_str = format [localize "STR_SYS_333"/* "Выгружается %1, ожидайте..." */, _disp_name];
_str call XfGlobalChat;
sleep 3.123;
bike_created = true;
_pos = position player;
#ifdef __ACE__
if (_create_bike == "ACE_ATV_HondaR") then { if (_pos call SYG_isDesert) then {_create_bike = "ACE_ATV_HondaR_Desert"}}; // Ha-ha-ha
#endif
_vehicle = _create_bike createVehicle _pos;
_vehicle setDir direction player;

#ifdef __ACE__
if (typeOf _vehicle != "ACE_Bicycle") then {
#endif
player moveInDriver _vehicle;
#ifdef __ACE__
} else { ["say_sound", _vehicle, "bicycle_ring"] call XSendNetStartScriptClientAll; };
#endif

if (_b_mode == 1) then {
	_vehicle spawn {
		private ["_vehicle"];
		_vehicle = _this;
		waitUntil {sleep 4.412;!alive player || !alive _vehicle};

		sleep 10.123;

		_vehicle spawn {
			private ["_vehicle"];
			_vehicle = _this;
			while {true} do {
				if (({alive _x} count (crew _vehicle)) == 0) exitWith {
					deleteVehicle _vehicle;
				};
				sleep 15.123;
			};
		};
	};
} else {
	d_flag_vec = _vehicle;
/*
	if ( _vehicle isKindOf "Motorcycle") then
	{
	    _vehicle addWeapon "CarHorn"; // add horn for motorcycle
	};
*/
	d_vec_end_time = time + d_remove_mhq_vec_time + 60;
	["d_flag_vec",d_flag_vec] call XSendNetStartScriptServer;
	d_flag_vec addEventHandler ["killed", {(_this select 0) spawn {private ["_vec"];_vec = _this;sleep 10.123;while {true} do {if (isNull _vec) exitWith {};if (({alive _x} count (crew _vec)) == 0) exitWith {deleteVehicle _vec;};sleep 15.123;};d_flag_vec = objNull}}];
};

if (true) exitWith {};
