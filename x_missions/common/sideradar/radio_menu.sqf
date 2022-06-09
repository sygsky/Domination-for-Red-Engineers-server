/*
    x_missions\common\sideradar\radio_menu.sqf
    created 2022.06.04
	author: Sygsky, on #410 request by Rokse
	description: Execute load/unload/install radiomast operation

	Parameters array passed to the script upon activation in _this  variable is: [target, caller, ID, arguments]
    target (_this select 0): Object  - the object which the action is assigned to
    caller (_this select 1): Object  - the unit that activated the action
    ID (_this select 2): Number  - ID of the activated action (same as ID returned by addAction)
    arguments (_this select 3): Anything  - arguments given to the script if you are using the extended syntax

	changed:
	returns: nothing
*/
_arg = _this select 3; // must be "LOAD", "UNLOAD", "INSTALL"
_veh = _this select 0;
_pl  = _this select 1;
_txt = "";
private ["_ids"];

_remove_ids = {
	private ["_last","_id","_i"];
	_ids = _veh getVariable "IDS"; // get all id from menu
	_last = (count _ids) - 1;
	for "_i" from _last to 0 do {
		_id = _ids select _i;
		_veh removeAction _id;
	};
};
if (true) then {

	if ((vehicle _pl == _pl) ||  (_pl != driver (vehicle _pl)) ) exitWith  { _txt = "STR_RADAR_TRUCK_NOT_DRIVER" };

	if (locked _veh) exitWith {_txt = "STR_RADAR_NO"};

	if (!alive d_radar) exitWith {_txt = "STR_RADAR_MAST_DEAD"};
	switch (_arg) do {
		case "LOAD": {
			_asl = getPosASL d_radar;
			if ((_asl select 2) < 0 ) exitWith { // already loaded into this vehicle, so change all menu items
				_txt = "STR_RADAR_MAST_ALREADY_LOADED";
				call _remove_ids;
				_ids resize 0;
				_ids set [0, _veh addAction[localize "STR_INSPECT","x_missions\common\sideradar\radio_inspect.sqf"]]; // Inspect
				_ids set [1, _veh addAction[localize "STR_UNLOAD","x_missions\common\sideradar\radio_menu.sqf","UNLOAD"]]; // load
			};
			_asl resize 2;
			_radar = _asl nearObjects["Land_radar", 20];
			{
				if (!isNil (_x getVariable "RADAR")) exitWith { _radar = _x };
			}forEach _radar;
			if (typeName _radar == "ARRAY") exitWith { _txt = "STR_RADAR_MAST_LOADED"};
		};
		case "UNLOAD": {
			_asl = getPosASL d_radar;
			if ((_asl select 2) > 0 ) exitWith {
				// already unloaded into this vehicle, so change all menu items
				_txt = "STR_RADAR_MAST_ALREADY_UNLOADED";
				call _remove_ids;
				_ids resize 0;
				_ids set [0, _veh addAction[localize "STR_INSPECT","x_missions\common\sideradar\radio_inspect.sqf"]]; // Inspect
				_ids set [1, _veh addAction[localize "STR_LOAD","x_missions\common\sideradar\radio_menu.sqf","LOAD"]]; // load
			};

		};
		case "INSTALL": {

		};
	};

};
(localize _txt) call XfGlobalChat;
