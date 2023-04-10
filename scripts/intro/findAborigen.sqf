/*
	scripts\intro\findAborigen.sqf, called on server only
	author: Sygsky
	description:
		finds or creates aborigen on Antigua on request atserver from new player client.
		If fborigen exists, nothing done, if killed or absent, he is re-created

	returns: nothing
*/

#define ABORIGEN "ABORIGEN"

hint localize "+++ findAborigen.sqf: started";
//	if (!(player call SYG_pointOnAntigua)) exitWith {false};

private ["_civ","_newgroup"];
_isle = SYG_SahraniIsletCircles select 3; // Antigua enveloped circle descr
_pos = _isle select 1;
_arr = nearestObjects [ _pos, ["Civilian"], _isle select 2];
hint localize format["+++ _find_civilian: found %1 civ[s]", count _arr];
_civ = objNull;
{
	_var = _x getVariable ABORIGEN;
	if (!isNil "_var") then {
		if (alive _x) then {
			 (isPlayer _x) exitWith {};
			_x setDamage 0;
			_civ = _x;
			hint localize format["+++ findAborigen.sqf: found civ %1 at %2", typeOf _civ, getPos _civ];
		} else {
			deleteVehicle _x;
			sleep 0.1;
		};
	};
	if ( alive _civ ) exitWith {};
} forEach _arr;

if ( alive _civ ) then {}; // Already found, nothing to do

_newgroup = call SYG_createCivGroup;
//		hint localize format["+++ findAborigen.sqf: group created %1", _newgroup];
_type = format ["Civilian%1", (floor (random 19)) + 2];
//		hint localize format["+++ findAborigen.sqf: civ not found, create unit with type %1", _type];
_pos = [[17352,17931,100], 100, 100, 0] call XfGetRanPointSquareOld; // No flat position requested, use smallest rect
//		hint localize format["+++ _find_civilian: civ not found, create unit with type %1 at pos %2", _type, _pos];
_civ = _type createVehicle _pos;
_civ setVehicleInit format ["this execVM ""scripts\intro\aborigenInit.sqf"""];
processInitCommands;
_civ setBehaviour "Careless";
_civ setCombatMode "BLUE";
_civ setVariable [ABORIGEN, true];
_civ playMove "AmovPercMstpSlowWrflDnon_AmovPsitMstpSlowWrflDnon"; // Seat on the gound
_civ addEventHandler ["killed", {(_this select 0) call XAddDead0;
    private ["_name"];
	if (isPlayer (_this select 1)) then {
	    _name = name (_this select 1);
	    //-20 call SYG_addBonusScore;
	    // "%1 killed a wonderful man, an Aborigen with a capital letter. He will be punished! For now, just -20 points."
	    [ "change_score", _name, -20, ["msg_to_user", [ ["STR_ABORIGEN_KILLER", _name ] ], 0, 1, false, "losing_patience"] ] call XSendNetStartScriptClient;
	} else {
	    // "Just now a wonderful man was killed, the Aborigen with a capital letter. But the enemy made a wrong move. And another will take his place!"
	    ["msg_to_user", [ ["STR_ABORIGEN_KILLER_0"] ], 0, 1, false, "losing_patience"] call XSendNetStartScriptClient;
	};
	hint localize  format["--- aborigen killed by %1(%2)!", _name, typeOf (_this select 1) ];
	// TODO: add new aborigen
	sleep 100 + (random 20);
	[] execVM "scripts\intro\findAborigen.sqf";
} ];
