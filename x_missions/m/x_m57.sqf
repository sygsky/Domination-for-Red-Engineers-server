// by Sygsky, sea devil capture mission (#655, Sygsky proposal). x_missions/m/x_m57.sqf
//
// This SM always is successfull and can't return failure code
//
#include "x_setup.sqf"
#include "x_macros.sqf"

//#define __DEBUG_SM_57__
#define BOAT_TYPE "RHIB2Turret"
#define BOAT_GRU_TYPE "RHIB"
#define POINT_TYPE "Heli_H_civil"

// side mission index: 57,
// Capturing the sea devil boat,
// point near base shore on the west side of airbase and GRU_boat respawn point
x_sm_pos = [[8585.3,10103.7,0],[8580,10095,0]];
x_sm_type = "normal"; // "normal", "convoy", "undefined"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

_circle_pos = x_sm_pos select 0;

if (call SYG_isSMPosRequest) exitWith {_circle_pos}; // it is request for pos, not SM execution

if (X_Client) then {
	_name = _circle_pos call SYG_nearestSettlementName;
	// "Capture a sea devil (sea patrol boat) and drive it to a given point on the coast (see map near %1) to pass it to the GRU.
	// \nKeep in mind, the GRU is only interested in the newest vehicle!"
	current_mission_text = format[localize "STR_SM_57", _name];
	current_mission_resolved_text = localize "STR_SM_057"; // "Mission accomplished, the boat has been handed over to the GRU for study"
};

if (!isServer) exitWith {};

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Start the service of sea devil capture

// Find all empty sea devils and block them for the duration of this sidemission

_cnt = 0;
_cnt_boat = 0;
_list = [];
{
	if (typeOf _x == BOAT_TYPE) then {
		if (alive _x) then {
			if ( (side _x) != d_side_enemy ) then { // If empty or friendly, remember it as vehicle that can't be used to finish SM
				_list set [count _list, _x];
			};
		};
		_cnt_boat  = _cnt_boat + 1; // Count patrol boats only
		sleep 0.3;
	};
	_cnt = _cnt + 1; // Vehicles (and objects created im mission) count
	if ( (_cnt mod 20) == 0) then { sleep 0.3}; // Just in case of a very long vehicle list sleep on each 20th vehicle
} forEach vehicles;
hint localize format["+++ x_m57.sqf: global coll vehicles (size %1) scanned for '%2', found %3 and set as old alive %4", _cnt, BOAT_TYPE, _cnt_boat, count _list ];

["remote_execute", "sleep 30; playSound 'sea_devil1'; ['sea_devil1', 22] call SYG_showMusicTitle", "<server>"] call XSendNetStartScriptClientAll; // Sent to all clients only

_pos    = + _circle_pos;

#ifdef __OWN_SIDE_WEST__
_flag_type = "FlagCarrierWest"; //
_flag_Texture = "\ca\misc\data\usa_vlajka.pac";
_factory = "WarfareBWestAircraftFactory";
#endif
#ifdef __OWN_SIDE_RACS__
_flag_type = "FlagCarrierWest"; //
_flag_Texture = "\ca\misc\data\usa_vlajka.pac";
_factory = "WarfareBWestAircraftFactory";
#endif
#ifdef __OWN_SIDE_EAST__
_flag_type = "FlagCarrierNorth"; //
_flag_Texture =  "\ca\misc\data\rus_vlajka.pac";
_factory = "WarfareBEastAircraftFactory";
#endif

_sites = [
#ifdef __DEBUG_SM_57__
	[[(_pos select 0) - 10, (_pos select 1) - 3,0], 0, BOAT_GRU_TYPE], // create debug vehicle
#endif
	[              _pos,   0, POINT_TYPE], // underwater heli yellow circle
	[[8592.9,10094.2,0],   0, _flag_type], // Flag to help find circle, added by request of gyuri
#ifdef __OWN_SIDE_WEST__
	[[8573.7,10073.6,0], 325, "WarfareBWestContructionSite1"],
	[[8598.9,10070.5,0],  70, "WarfareBWestContructionSite"],
#endif
#ifdef __OWN_SIDE_RACS__
	[[8573.7,10073.6,0], 325, "WarfareBWestContructionSite1"],
	[[8598.9,10070.5,0],  70, "WarfareBWestContructionSite"],
#endif
#ifdef __OWN_SIDE_EAST__
	[[8573.7,10073.6,0], 325, "WarfareBEastContructionSite1"],
	[[8598.9,10070.5,0],  70, "WarfareBEastContructionSite"],
#endif
	[[8613.1,10102.8,0],   0, _factory]
];

for "_i" from 0 to ((count _sites) - 1) do {
	_x = _sites select _i;
	_pos = _x select 0;
	_type =  _x select 2;
	_item = createVehicle [ _type, _pos, [], 0, "NONE" ]; // [_type, _pos, [markers],_rad, "HOW_TO_POS"]
	if ( _type == _flag_type ) then {
	    sleep 1;
        // #699.3: Add "reload ammo" command on this flag
        _item setVehicleInit "this execVM ""x_missions\common\GRU_boat_flag_init.sqf"""; // To add command "Re-ammo GRU boat". No other boats re-loaded
        // For connected player we will add command throw system command
        ["remote_execute","(_this select 2) execVM ""x_missions\common\GRU_boat_flag_init.sqf""", _item ] call XSendNetStartScriptClientAll;
	};
	_item setDir (_x select 1);
	_pos = getPos _item;
	_pos set [2,0];
	_item setPos _pos;
	_sites set [_i, _item]; // Store created item in the place of its data
	if (_item isKindOf "FlagCarrier") then { _item setFlagTexture _flag_Texture };
	hint localize format["+++ x_m57.sqf: %1 created, pos %2, vUp %3", typeOf _item, getPos _item, vectorUp _item];
};

// 1. Start GRU boat (M2 RHIB).
// 2. Respawn GRU boat while side mission is not completed.
// 3. Wait GRU boat at SM point while players count > 0.
// 4. Remove GRU boat when SM is empty.
[ _circle_pos, BOAT_GRU_TYPE] execVM "x_missions\common\GRU_boat_respawn.sqf";

// Await end of this SM
_do = true;
_pos = + _circle_pos; // Check for the circle position, not any other object
_delay = 5;
while { _do } do {
	sleep _delay;
	_delay = 5;
	_boat = nearestObject [ _pos, BOAT_TYPE ];
	if ( (_boat distance _circle_pos) <= 3) then {
        if ( alive _boat ) then {
            if (  (side _boat) != d_side_enemy  ) then {
                if ( !(_boat in _list) ) then { // New alive non-enemy vehicle is on circle, mission completed!!!
                    _crew = [];
                    // Prepare list of alive crew in SM finished boat
                    {
                        if (alive _x) then { _crew set [count _crew, name _x] };
                    } forEach crew _boat;

                    [ "msg_to_user", "*", [["STR_SM_57_INFO", _crew]], 0, 0, false, "sea_devil2" ] call XSendNetStartScriptClientAll; // "Sea devil! OUR boat crew: %1"
                    [] spawn {	// Wait 1st message shown
                        sleep 5;
                        side_mission_winner = 2;
                        side_mission_resolved = true;
                    };
                    hint localize format["+++ x_m57.sqf: completed, captured %1 with crew %2", typeOf _boat, _crew];
                    _do = false
                } else { // This boat is in older list, refuse it now. Inform all players closer 50 meters to the circle pos
                    [ "msg_to_user", [100, _circle_pos], [["STR_SM_57_BAD_INFO"]], 0, 0, false, "losing_patience" ] call XSendNetStartScriptClientAll; // "The GRU is not interested in this boat, they need a newer one!"
                    _delay = 10;
                };
            } else {
                // "Enemy boat at the mission point! Hurry up and capture it!"
                [ "msg_to_user", "*", [["STR_SM_57_ENEMY_INFO"]], 0, 0, false, "naval" ] call XSendNetStartScriptClientAll;
                _delay = 10;
            };
        } else { // Nearest boat is dead, refuse it
            // "The detected enemy boat has been destroyed! Urgently find a new one, the GRU is very unhappy!"
            [ "msg_to_user", [100, _circle_pos], [["STR_SM_57_DEAD_INFO"]], 0, 0, false, "losing_patience" ] call XSendNetStartScriptClientAll;
        };
	};

};

_list resize 0;
_list = nil;

// Delete all created vehicles
sleep 30;
// _found_names = [_pos, _dist] call SYG_findNearestPlayers;
_names = [];
_cnt = 60;
while { // Waiting for players to move away from the SM by a designated distance, up to a maximum of 10 minutes (600 seconds)
	_names = [_circle_pos, 60] call SYG_findNearestPlayers;
	_cnt = _cnt - 1;
	( count _names > 0 ) && ( _cnt >= 0 )
} do { sleep 10; };
if ( count _names == 0 ) then {
	[ "say_sound", getPos (_sites select 0), "steal" ] call XSendNetStartScriptClientAll; // Play sound on circle center
};

{
    // Remove all except yellow circle and factory that will be repair/reload center for boats in a future
    _type = typeOf _x;
    if ( ! (_type in [POINT_TYPE,_factory]) ) then {
        if ( !alive _x ) then {
            hint localize format[ "--- x_m57.sqf: when try to remove item %1, detected that it is not alive", _type ];
        } else {
            hint localize format[ "+++ x_m57.sqf: remove item %1 at pos %2!", _type, position _x ];
            deleteVehicle _x;
        };
    };
} forEach _sites;
_sites resize 0;
_sites = nil;

if (true) exitWith {};
