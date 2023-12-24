/*
	scripts\intro\findAborigen.sqf, called on server only
	author: Sygsky
	description:
		finds or creates aborigen on Antigua on request at server from new player client.
		If alive aborigen found, nothing done, if killed or absent, he is re-created
	params:
		100 execVM "scripts\intro\findAborigen.sqf"; // 100 = sleep interval
	returns: nothing
*/

#define ABORIGEN "ABORIGEN"

hint localize "+++ findAborigen.sqf: started";
//	if (!(player call SYG_pointOnAntigua)) exitWith {false};

private ["_newgroup"];

_nil = isNil "aborigen";
_null = if (!_nil) then { isNull aborigen } else {false};
_alive = if (!_null) then {alive aborigen} else {false};
if ( ! _null ) then { deleteVehicle aborigen };

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Create new group for the next civilian
if (_alive) exitWith {
	hint localize "+++ findAborigen.sqf: aborigen alive, exit";
};

if (typeName _this == "SCALAR") then { // sleep needed period
	if (_this > 0 ) then {sleep _this};
};
_type = format ["Civilian%1", (floor (random 19)) + 2];

hint localize format["+++ Server: spawn_tent pos %1", getPos spawn_tent];

//		hint localize format["+++ findAborigen.sqf: civ not found, create unit with type %1", _type];
_house = nearestObject [spawn_tent, "Land_hlaska"];
_pos = [];
if (alive _house) then {
	if ( (random 10) < 1) then { // 1 of 10 aborigen is created on the tower top
		_pos = _house call SYG_getRndBuildingPos;
	};
};
if (count _pos == 0) then {
	_pos = [getPos spawn_tent, 60, 60, 0] call XfGetRanPointSquareOld; // No flat position requested, use smallest rect
};
//		hint localize format["+++ _find_civilian: civ not found, create unit with type %1 at pos %2", _type, _pos];
_newgroup = call SYG_createCivGroup;
aborigen = _newgroup createUnit [_type, _pos, [], 0,"NONE"];
sleep 0.05;
[aborigen] join _newgroup;
sleep 0.05;
aborigen setPos _pos;
hint localize format["+++ findAborigen.sqf: group %1, _pos %2, pos %3 ", group aborigen, _pos, getPos aborigen];
//aborigen setVehiclePosition [_pos, [], 0, "CAN_COLLIDE"];

publicVariable "aborigen";

// assign all events for new aborigen
sleep 3;
["remote_execute","[] execVM ""scripts\intro\aborigenInit.sqf""", "<server>"] call XSendNetStartScriptClient; // Assign abo action on all client computers

//aborigen setVariable [ABORIGEN, true]; // ??? Do we need this statement? No we don't!
aborigen setBehaviour "Careless";
aborigen setCombatMode "BLUE";
aborigen playMove "AmovPercMstpSlowWrflDnon_AmovPsitMstpSlowWrflDnon"; // Sit on the ground
aborigen disableAI "MOVE";

// _this = [_killed, _killer];
aborigen addEventHandler ["killed", {
    private ["_name"];
	(_this select 0) call XAddDead0;
	if (isPlayer (_this select 1)) then {
	    _name = name (_this select 1);
	    //-20 call SYG_addBonusScore;
	    // "%1 killed the wonderful man, an Aborigen with a capital letter. %1 will be punished! For now, just -20 points."
	    [ "change_score", _name, -20, ["msg_to_user", [ ["STR_ABORIGEN_KILLER", _name ] ], 0, 1, false, "losing_patience"] ] call XSendNetStartScriptClient;
	} else {
	    // "Just now the wonderful man was killed, the Aborigen with a capital letter. But the enemy made a wrong move. And another will take his place!"
	    ["msg_to_user", [ ["STR_ABORIGEN_KILLER_0"] ], 0, 1, false, "losing_patience"] call XSendNetStartScriptClient;
	    _name = str (_this select 1);
	};
	hint localize  format["--- aborigen killed by %1(%2), dist %3, at %4!",
		_name,
		typeOf (vehicle (_this select 1)),
		round((_this select 0) distance (_this select 1)),
		[(_this select 1),10] call SYG_MsgOnPos0];
	100 execVM "scripts\intro\findAborigen.sqf"; // add new aborigen except killed one after 100 seconds
} ];
