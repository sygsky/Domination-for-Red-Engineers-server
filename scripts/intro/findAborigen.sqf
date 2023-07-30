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
//		hint localize format["+++ findAborigen.sqf: civ not found, create unit with type %1", _type];
_pos = [getPos spawn_tent, 60, 60, 0] call XfGetRanPointSquareOld; // No flat position requested, use smallest rect
//		hint localize format["+++ _find_civilian: civ not found, create unit with type %1 at pos %2", _type, _pos];
_newgroup = call SYG_createCivGroup;
hint localize format["+++ findAborigen.sqf: group created %1", _newgroup];
aborigen = _newgroup createUnit [_type, _pos, [], 0,"NONE"];
[aborigen] join _newgroup;
publicVariable "aborigen";
hint localize format["+++ findAborigen.sqf: aborigen group is %1", group aborigen];

// assign all events for new aborigen
sleep 3;
["remote_execute","[] execVM ""scripts\intro\aborigenInit.sqf"""] call XSendNetStartScriptClient; // Assign abo action on all client computers

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
	hint localize  format["--- aborigen killed by %1(%2)!", _name, typeOf (_this select 1) ];
	100 execVM "scripts\intro\findAborigen.sqf"; // add new aborigen except killed one after 100 seconds
} ];
