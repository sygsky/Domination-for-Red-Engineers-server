/*
    scripts\bonuses\assignAsBonus.sqf
	author: Sygsky
	description: handlers assigned to the vehicle to check bonus in/kill events
		called on server (in debug SP mission it is emulated only)
	call: [_veh1, ..., _vehN] execVM "scripts\bonuses\assignAsBonus.sqf";
	returns: nothing
*/

#include "bonus_def.sqf"

if (typeName _this == "OBJECT") then {_this = [_this]};
if (typeName _this != "ARRAY") exitWith {hint localize format["--- assignAsBonus.sqf, found %1, exit!",typeName _this]};
_msg_arr = [];
{
	if ( ! (_x isKindOf "Landvehicle" || _x isKindOf "Air" || _x isKindOf "Ship") ) exitWith {
		hint localize format["--- assignAsBonus.sqf: expected type LandVehicle|Air|Ship, detected ""%1"", EXIT ON ERROR !!!", typeOf _x];
	};

	// TODO: set according to the server or client code
	if (true) then { // MP server code
		_x setVehicleInit "this setVariable [""INSPECT_ACTION_ID"", this addAction [ localize ""STR_CHECK_ITEM"", ""scripts\bonuses\bonusInspectAction.sqf"", [] ]];";
		processInitCommands;
	} else { // SP code
		_x setVariable ["INSPECT_ACTION_ID", _x addAction [ localize "STR_CHECK_ITEM", "scripts\bonuses\bonusInspectAction.sqf", [] ]];
	};
	_x call SYG_addEventsAndDispose; // add all std mission-driven events here (not recoverable, may be killed and removed from the mission)

	//  Passed array for "killed" event: [unit, killer]
	_x addEventHandler [ "killed", {
			[server_bonus_markers_array, _this select 0] call SYG_removeObjectFromArray;
			["bonus","DEL", _this select 1, _this select 0] call XSendNetStartScriptClientAll;
			hint localize format["+++ killed: %1", _this];
		}
	];
	_near_town_name = text (_x call SYG_nearestSettlement);
	_msg_arr set [count _msg_arr, [localize "STR_BONUS", _near_town_name, typeOf _x]];
	hint localize format["+++ assignAsBonus.sqf: all events set, ""Inspect"" action  added to the %1 near %2", typeOf _x, _near_town_name];
} forEach _this;
["msg_to_user","*",_msg_arr,8,1,"good_news"] call XSendNetStartScriptClientAll;

