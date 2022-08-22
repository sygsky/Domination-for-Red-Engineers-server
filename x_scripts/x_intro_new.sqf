// x_scripts\x_intro_new.sqf
// by Sygsky for Xeno Domination
//
// Mode identificators:
// "PLANE" - 1st time in the mission player is dropped with parachute from the plane over the Antigua island.
//			After jumping from the plane, the player is revived in the hills of Antigua until he reaches base territory.
//			After reaching the base mode changed to the "BASE" (see next lines)
//
// "BASE"  - 1st time in the session player is dropped with parachute on the plain between Somato and base.
//			And until he not reaches base territory in this session, he is respawned on that plain.

//			usual intro (flight to the base depot) for the player still not used.
if (!X_Client) exitWith {};

#include "x_setup.sqf"

#ifdef __OLD_INTRO__
if (true) exitWith{ execVM "x_scripts\x_intro_old.sqf"};
#endif

#ifndef __DEFAULT__
if (true) exitWith{ execVM "x_scripts\x_intro.sqf"};
#endif

d_still_in_intro = true;

sleep 4;
playMusic "ATrack10";
//
//++++++++++++++++++++++++ populate the plane with player and cargo
//
_pos = [16000,16000,500];
/**
class Item150
{
	position[]={17514.957031,49.762451,17998.087891};
	name="paradrop";
	markerType="RECTANGLE";
	type="Flag";
	colorName="ColorGreenAlpha";
	a=300.000000;
	b=200.000000;
};
*/

_droprect = [[17515,17998,500],300,200,0]; // rectangle to drop with parachute

_plane = createVehicle [ "DC3", _pos, [], 0, "FLY"];
_grp = call SYG_createOwnGroup;
_pilot = (
	switch (d_enemy_side) do {
		case "EAST": {d_pilot_E};
		case "WEST": {d_pilot_W};
	}
);
[_plane, _grp, _pilot] call SYG_populateVehicle;
_unit_array = (["civilian", "CIV"] call x_getunitliste) select 0;
_cnt = _plane emptyPositions "Cargo";
_arr = [];
_id = floor random _cnt;
_arr set[_id, player];
for "_i" from 0 to _cnt - 1 do {
	if (_i == _id) then {
		player moveInCargo _plane; // now put player into the plane
	} else {
		_civ = (_unit_array call XfRandomArrayVal) createVehicleLocal [0,0,0];
		_civ moveInCargo _plane;
		_arr set [_i, _civ ];
	};
};

// remove random number of passangers
_cnt1 = floor ((random _cnt1) / 2);
for "_i" from 1 to _cnt1 do {
	_id1 = floor (random _cnt1);
	if (_id != _id1) then { deleteVehicle (_arr select _id1); };
};

//
//+++++++++++++++++++++ Move the plane to the island
//

// calculate center of drop rect
_drop = _droprect select 0;
_pilot = driver _plane;
(group _pilot) addWaypoint [_drop,0];
_grp flyInHeightASL 500;
_grp setSpeedMode "NORMAL";
_grp setBehaviour "CARELESS";
grp setCombatMode "BLUE";

_dist = [_plane, _drop] call SYG_distance2D;
_drop_reached = false;
while { _drop_reached = ([_droprect, getPosASL _plane] call SYG_pointInRect); !_drop_reached } do {
	_drop_reached = (!isNull (driver _plane)) && (alive driver _plane) && (alive player);
};

//
//++++++++++++++++++++ parajump
//
if ( _drop_reached ) then { // drop him

};


// if player not reached the base in previous visits to the Sahrani  he is first time dropped with parachute onto the Antigua
// If player reached base before, it is respawned 1st time in parachute above the plain between Somato and base
// Or he will see current x_intro.sqf, I don't decided it.
// All other times he is respawned as usually (on base point or on one of two MHQ)

// # Set night if still not
// create plane, fill it with cargo, remove random cargo partially, insert player
// set WP for plane so it will traverse Antigua

// # print multiple interesting messages
// Before jump switch on/off red alert lamp (#lightpoint)
// At the destination point eject player with planning parachute

// # Restore daytime if changed in the moment of the paradrop (while player still in plane)
// put flag with rumors on the Antigua hills,
// put several habitants,
// put dead enemy officer with map (and command "Inspect" on its body) among the Antigua hills.
// create the boat for this player if not already exists
// create sea patrols from boats with Vulcans on board (1st weapon place)

// If player landed successfully, it is respawned next times
// in any of 3-4 respawn points ammong the hills of Antigua

sleep 14;
titleRsc ["Titel1", "PLAIN"];

d_still_in_intro = false;

if (true) exitWith {};
