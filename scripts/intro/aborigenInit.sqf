/*
	aborigenInit
	author: Sygsky
	description: add all actions and events to the aborigen on player client
	returns: nothing
*/
#include "x_setup.sqf"

#define ABORIGEN "ABORIGEN"

_civ = _this;
_civ addEventHandler ["killed", {(_this select 0) call XAddDead0;
	if (isPlayer (_this select 1)) then { -20 call SYG_addBonusScore; };
	["log2server", name player, "--- aborigen killed by me!" ]  call XSendNetStartScriptServer;
} ];

// not all players can use Antigua items except killed event
if (!(name player in __ARRIVED_ON_ANTIGUA__)) exitWith {format["+++ You '%1' cant to arrive at Antigus, exit.", name player]};

hint localize format["+++ aborigenInit.sqf: processed unit %1, pos %2", typeOf _civ, _pos];
_civ setVariable [ABORIGEN, true];

// TODO: add follow sub-menus to the civilian:
// 1. "Ask about boats". 2. "Ask about cars". 3. "Ask about weapons". 4. "Ask about soldiers". 5. "Ask about rumors"
{
	_civ addAction[ localize format["STR_ABORIGEN_%1", _x], "scripts\intro\SYG_aborigenAction.sqf", _x]; // "STR_ABORIGEN_BOAT", "STR_ABORIGEN_CAR" etc
} forEach ["BOAT", "CAR", "WEAPON", "MEN", "RUMORS","GO"];

while { !(player call SYG_pointOnAntigua) } do { sleep 5; }; // while out of Antigua

while {((getPos player) select 2) > 5} do { sleep 2}; // while in air

if (alive _civ) then { // show info
	player groupChat format [localize "STR_ABORIGEN_INFO", round (player distance _civ), ([player,_civ] call XfDirToObj) call SYG_getDirName]; // "Aborigen is on dist. %1 to %2"
} else {
	player groupChat (localize "STR_ABORIGEN_INFO_NONE"); // "Locals are not observed"
};

// Giggle while not closer than 10 meters
while {(player distance _civ) > 10} do {
	sleep (5 + (random 2));
	_civ setMimic (["Default","Normal","Smile","Hurt","Ironic","Sad","Cynic","Surprised","Agresive","Angry"] call XfRandomArrayVal);
	_civ say format["laughter_%1", (floor (random 12)) + 1]; // 1..12
	_civ setDir (getDir _civ) + ((random 20) - 10);
};

_civ setMimic "Normal";
// Do watch while alive or near
_civ doWatch player;
while { (alive _civ) && (alive player) && ((player distance _civ) < 40)} do { sleep 5};
_civ doWatch objNull;
_civ spawn {
	private ["_list","_civ"];
	_civ = _this;
	/*
	"ActsPercMstpSlowWrflDnon_Lolling",  // Stretches, as if the unit has just woken up
	"ActsPercMstpSnonWnonDnon_DancingDuoIvan", // Does various dance moves
	"ActsPercMstpSnonWnonDnon_DancingDuoStefan", // Dances
	"ActsPercMstpSnonWnonDnon_DancingStefan",	// As above
	*/
	_list = [
		"AmovPercMstpSnonWnonDnon_exerciseKata",	//		Martial arts moves
		"AmovPercMstpSnonWnonDnon_exercisePushup",	//	Pushups
		"AmovPercMstpSnonWnonDnon_Ease",	//	"At ease"
		"AmovPercMstpSnonWnonDnon_AmovPsitMstpSnonWnonDnon_ground",	//	Sits on the ground
		"AmovPercMstpSnonWnonDnon",	//	Stand without weapon
		"AmovPercMstpSlowWrflDnon_seeWatch",	//	Checks watch with weapon in other hand
		"AmovPercMstpSlowWrflDnon_AmovPsitMstpSlowWrflDnon"	//	Sits on ground
	];
	while {canStand _civ } do {
		_arr = _civ nearObjects [ "CAManBase", 50];
		_cnt = {(canStand _x) && (isPlayer _x)} count _arr;
		if (_cnt  == 1) then { // only for single player
			_move = _list call XfRandomArrayVal;
			_civ doWatch player;
			sleep 1;
			_civ playMove _move;
			sleep 9;
			_civ doWatch objNull;
		};
		sleep (random 5);
	};
};
// set marker on civ
_marker = createMarkerLocal["aborigen_marker", getPos _civ];
_marker setMarkerTypeLocal  "Vehicle";
_marker setMarkerColorLocal "ColorGreen";
_marker setMarkerTextLocal "?";
_marker setMarkerSizeLocal [0.5, 0.5];

while {alive _civ} do {
	sleep 10;
	if ( ([getMarkerPos _marker, getPosASL _civ] call SYG_distance2D) > 10) then {
		_marker setMarkerPosLocal (getPosASL _civ);
	};
};
deleteMarkerLocal _marker;
// exit this humorescue

