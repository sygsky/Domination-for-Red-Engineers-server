/*
	x_missions\common\x_sideradio.sqf

	author: Sygsky
	description: controls the installation of an antenna for radio communication with the USSR.
		Draws the markers for active truck and radio-mast,
		check if mission is failed.
		Really the flow of script is as follow:
		Radar and truck are recreated after each destroy (while script radio_service.sqf is running)
		The truck can be destroyed/found an arbitrary number of times until the radio mast is intalled

		1. If current radar is killed, mission is counted is failed
		2. If current radar is installed, wait until current truck is reached GRU PC.
		3. If last truck or current radar are destroyed, mission is counted as failed.

		Markers:
		All the time markers are drown for radar (if unloaded) and truck.
		If punkt 1 is reached radar marker is cleared.
		After success or failure all markers are cleared.

		The need for the radio relay does not disappear after completing a mission.
		If a mast is destroyed, it must be rebuilt again under the same conditions.

	params: nothing
	returns: nothing
*/
if ( !isServer ) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"
#include "sideradio_vars.sqf"

#ifdef __ACE__
#define TRUCK_MARKER "ACE_Icon_Truck"
#else
#define TRUCK_MARKER "SalvageVehicle"
#endif

hint localize format["+++ x_sideradio.sqf: _this = %1", _this];

_mission = true;
if (!isNil "_this") then {
    switch (typeName _this) do {
        case   "BOOL": { _mission = _this };
        case "STRING": { _mission = !((toUpper _this) in ["NO_MISSION","NOT_MISSION"]); };
        case "SCALAR": { _mission = _this != 0 };  // (!= 0) is mission; (== 0) not mission
        default {};
    };
};

hint localize ( if (_mission) then { format[ "+++ x_sideradio.sqf: mission, _this = %1, d_radar alive = %2 !!!", _this, alive d_radar ] } else { format[ "+++ x_sideradio.sqf: NOT misssion _this = %1, d_radar alive = %2 !!!", _this, alive d_radar ] } );

// wait (new) antenna to be alive or recreated by radio_service.sqf
_cnt = 0;
_time  = time;
while { (!(alive d_radar)) && (_cnt < 100) } do { sleep 5; _cnt = _cnt + 1 };
//waitUntil {sleep 5; _cnt = _cnt + 1; (alive d_radar) || (_cnt > 100)};


// if no radar and it is mission, exit with failure code
if ( _mission && ( !alive d_radar ) ) exitWith {
	hint localize format["--- x_sideradio.sqf: no radar created in %1 seconds, exit!!!", round (time - _time)];
	["msg_to_user","",[["STR_RADAR_FAILED1"]]] call XSendNetStartScriptClient; // "Not a single radio relay mast could be found on the entire island. That's sad!"
	if (_mission) then {
		side_mission_winner = -702;
		side_mission_resolved = true;
	};
};
hint localize format["+++ x_sideradio.sqf: found alive d_radar in %1 seconds after the destruction of the previous one, continue...", floor(time - _time)];

// radar is alive now, store current object and check only it
_radar = d_radar;

if ( (sideradio_status == 2) && (!_mission)) then {
	hint localize "+++ x_sideradio.sqf: not mission, sideradio_status == 2, wait status change";
	_time = time;
	waitUntil {sleep 60; sideradio_status != 2};
	_str = [ time,_time] call SYG_timeDiffToStr;
	hint localize format["+++ x_sideradio.sqf: not mission, sideradio_status == %1, changed after %2", sideradio_status, _str];
};

// _marker_name = [_marker_name, _marker_type, _truck_pos, _marker_color<,_marker_size>] call _make_marker;
_make_marker = {
	private ["_mrk_name"];
	_mrk_name = _this select 0;
	createMarker [_mrk_name, _this select 2 ]; // create marker on pos
	_mrk_name setMarkerColorLocal (_this select 3); // set marker color

	if (count _this > 4) then {
		_mrk_name setMarkerTypeLocal (_this select 1);  // marker type
		_mrk_name setMarkerSize (_this select 4);  // marker size
	} else {
		_mrk_name setMarkerType (_this select 1); // only marker type
	};
	_mrk_name
};

// Antenna/trucks are recreated in radio_service.sqf running during whole misssion

// prepare markers (truck + radiomast)
_truck_marker = "";
_radar_marker = ""; //

_check_truck_marker = 	{ // check truck marker
	if ( alive _this ) then {
		if ( locked _this ) exitWith {  // truck is locked that means it is not found
			if (_truck_marker != "") then {
				hint localize format["+++ x_sideradio.sqf: delete _truck_marker at %1", (markerPos _truck_marker) call SYG_MsgOnPosE0];
				deleteMarker _truck_marker; _truck_marker = "";
			};
		};

		// create truck marker if needed
		if ( _truck_marker == "" ) then {
			_truck_marker = [ "sideradio_truck", TRUCK_MARKER, _this, RADAR_SM_COLOR,[0.5, 0.5]] call _make_marker;
			_crew = crew _this;
			for "_i" from 0 to ( (count _crew) -1 ) do {
				_x = _crew select _i;
				_crew set [_i, if (isPlayer _x) then {name _x} else {typeOf _x}];
			};
			hint localize format["+++ x_sideradio.sqf: create _truck_marker at %1, crew %2", (markerPos _truck_marker) call SYG_MsgOnPosE0, _crew];
			_delay = 3;
		} else {
			  // move existing truck marker if needed
			  if ( ( [getMarkerPos _truck_marker, _this] call SYG_distance2D ) > DIST_TO_SHIFT_MARKER ) then {
				  _truck_marker setMarkerPos (getPos _this);
				  _delay = 3;
			  };
		};
	} else { // truck dead, remove marker while new truck will be created
		if ( _truck_marker != "" ) then {
			hint localize format["+++ x_sideradio.sqf: truck dead, delete marker at %1", (markerPos _truck_marker) call SYG_MsgOnPosE0];
			deleteMarker _truck_marker; _truck_marker = ""
		};
	};
};
//
// Main loop, controls markers movement and end of the mission
// Radar can't be destroyed else sidemission is failed
//
hint localize format["+++ x_sideradio.sqf: enter marker loop, status %1", sideradio_status];

_last_pos = [0,0,0]; // last pos of truck, for printing 1 km steps
while { (alive _radar) && (sideradio_status < 1) } do { // 0 state is allowed

	if ( X_MP && ((call XPlayersNumber) == 0) ) then {
		waitUntil {sleep (60 + (random 1)); (call XPlayersNumber) > 0};
	};
	_delay = 15;

	d_radar_truck call _check_truck_marker;
	//
    // process markers of this side mission
    //
    if ((alive _radar) && (sideradio_status < 1)) then { // radar alive
    	_asl = getPosASL _radar;
        if ( ( _asl select 2) >= 0) then { // radar is unloaded, so it stands/lays on the land somewhere
			// check if radar is already detected
			_detected = _radar getVariable "DETECTED";
			if (!isNil "_detected") then { // alive, not installed, detected
				if ( _radar_marker == "") then { // marker not exists, create it now
					_radar_marker = [ "sideradio_radar_marker", RADAR_MARKER, _radar, RADAR_SM_COLOR, [0.5, 0.5] ] call _make_marker;
	       			hint localize format["+++ x_sideradio.sqf: create _radar_marker at %1", [(markerPos _radar_marker),10] call SYG_MsgOnPosE0];
				} else {
					// marker exists, move it if needed
					if ( ( [getMarkerPos _radar_marker, _radar] call SYG_distance2D ) > DIST_TO_SHIFT_MARKER ) then {
						_radar_marker setMarkerPos ( _asl );
					};
				};
			};
        } else {    // radar is load into the truck, wipe it from the map
            if ( _radar_marker != "" ) then {
       			hint localize format["+++ x_sideradio.sqf: delete _radar_marker at %1", (markerPos _radar_marker) call SYG_MsgOnPosE0];
                deleteMarker _radar_marker; _radar_marker = ""
            };
        };
    } else { // radar dead or installed, wait until sideradio_status changes
        if ( _radar_marker != "" ) then {
   			hint localize format["+++ x_sideradio.sqf: delete _radar_marker at %1, radar %2, sideradio_status %3, ", (markerPos _radar_marker) call SYG_MsgOnPosE0, if (alive _radar) then {"alive"} else {"dead"}, sideradio_status];
            deleteMarker _radar_marker; _radar_marker = ""
        };
    };
	// check if the position of the truck has changed by more than 1 km and print the new position
	if (alive d_radar_truck) then {
		if ( ([d_radar_truck,_last_pos] call SYG_distance2D) >= 1000) then {
			_last_pos = getPosASL d_radar_truck;
			_pl = [];
			{
				if (alive _x) then {
					if (isPlayer _x) then {
						_pl set [ count _pl,  name _x ];
					} else { _cnt_ai = _cnt_ai + 1; _pl set [count _pl, format["AI:%1", typeOf _x]] };
				};
			} forEach crew d_radar_truck;
			hint localize format["+++ x_sideradio.sqf: radar truck(%1) now at %2, %3, %4",
				if ( ((getPosASL d_radar) select 2) < 0) then {"+"} else {"-"},
				d_radar_truck call SYG_MsgOnPosE0,
				_pl,
				(getPosASL d_radar_truck) call SYG_roundPos // print rounded meters in position
			];
		}
	};
    // TODO: add random enemy infantry patrols on the way to the destination at certain time intervals,
    // TODO: e.g. on each kilometer close to the mission finish

	sleep _delay;
};
_truck = d_radar_truck; // truck to deliver to the GRU PC position
hint localize format["+++ x_sideradio.sqf: exit marker loop, status %1, alive truck %2, alive radar %3", sideradio_status, alive _radar, alive d_radar_truck];

if ((sideradio_status == 1) && (alive _radar) && (alive _truck)) then  {

	// set radar marker to be green

	if (_radar_marker !=  "") then {
		deleteMarker _radar_marker;
	};
	_radar_marker = [ "sideradio_radar_marker", RADAR_MARKER, _radar, RADAR_ON_COLOR, [0.5, 0.5] ] call _make_marker;
	_radar_marker setMarkerText (localize "STR_ON");
	hint localize format["+++ x_sideradio.sqf: enter waiting track to be on base loop, status %1, alive truck %2, alive radar %3, radar color is green now", sideradio_status, alive _radar, alive _truck];
	_last_pos = [0,0,0]; // last pos of truck, for printing 1 km steps
	while { (sideradio_status == 1) && (alive _radar) && (alive _truck) } do  {
		sleep 5;
		_truck call _check_truck_marker;

		if ( (_truck distance (call SYG_computerPos)) < 20 ) exitWith { sideradio_status = 2; publicVariable "sideradio_status" };

		// check if the position of the truck has changed by more than 1 km and print the new position
		if (alive d_radar_truck) then {
			if ( ([d_radar_truck,_last_pos] call SYG_distance2D) >= 1000) then {
				_last_pos = getPosASL d_radar_truck;
				_pl = [];
				{
					if (alive _x) then {
						if (isPlayer _x) then {
							_pl set [ count _pl,  name _x ];
						} else { _cnt_ai = _cnt_ai + 1; _pl set [count _pl, format["AI:%1",typeOf _x]] };
					};
				} forEach crew d_radar_truck;
				hint localize format["+++ x_sideradio.sqf: radar truck(%1) now at %2, %3, %4",
					if ( ((getPosASL d_radar) select 2) < 0) then {"+"} else {"-"},
					d_radar_truck call SYG_MsgOnPosE0,
					_pl,
					(getPosASL d_radar_truck) call SYG_roundPos
				];
			}
		};
		// move truck marker
	};
};

if (_mission) then { // check victory or failure
    if ( sideradio_status == 2 ) then { // Victory!
    	_cnt_ai = 0;
    	_pl = [];
    	{
    		if (alive _x) then {
    			if (isPlayer _x) then {
    				_pl set [ count _pl,  name _x ];
    			} else { _cnt_ai = _cnt_ai + 1 };
    		};
    	} forEach crew _truck;
		hint localize format["+++ x_sideradio.sqf: mission SUCCESS, status %1, truck %2, radar %3, pl in truck %4%5, ai %6",
			sideradio_status,
			if (alive _truck) then {"alive"} else {"dead"},
			if (alive _radar) then {"alive"} else {"dead"},
			count _pl,
			_pl,
			_cnt_ai
		];
		_pl1 = call SYG_findPlayersOnBase;
		_pl = _pl - _pl1; // remove non unique players in both arrays
		_pl = _pl + _pl1; // all players on base
		// add also all players on base to the list
		["was_at_sm", _pl, "good_news"] call XSendNetStartScriptClientAll;
//		hint localize format["+++ x_sideradio.sqf:   mission SUCCESS, status %1, alive truck %2, alive radar %3", sideradio_status, alive _truck, alive _radar];
        side_mission_winner = 2;
        side_mission_resolved = true;
    } else {    // Failure
		hint localize format["+++ x_sideradio.sqf: mission FAILURE, status %1, alive truck %2, alive radar %3", sideradio_status, alive _truck, alive _radar];
        side_mission_winner = -702;
        side_mission_resolved = true;
    };
} else { hint localize format["+++ x_sideradio.sqf: exit NOT MISSION, status %1, alive truck %2, alive radar %3", sideradio_status, alive _truck, alive _radar] };

// Compose the message about problem on mission failure
_msg = [""];
_sound = "losing_patience";
if ((sideradio_status ==2) && (alive _radar) && (alive _truck) ) then {
	_msg = ["STR_RADAR_TRUCK_NOT_NEEDED"]; // "Mission accomplished. The truck should be hidden in a safe place"
	_sound = "no_more_waiting";
} else {
	_msg = ["STR_RADAR_FAILURE","",""]; // "Something went wrong and the GRU radio relay could not be restored. %1%2"
	if (!alive _radar) then { _msg set [count _msg,"STR_RADAR_MAST_DEAD"];  }; // "Radio mast destroyed"
	if (!alive _truck) then { _msg set [count _msg, "STR_RADAR_TRUCK_DEAD"];}; // "Truck was killed"
	sideradio_status = 0;
	publicVariable "sideradio_status";
};
["msg_to_user","",[_msg],0,10, false,_sound] call XSendNetStartScriptClient; // show message 10 seconds later this SM finished
sleep (5 + (random 5));

//==================================================
//=            Finish the mission                  =
//==================================================

// assign completed codes etc

// remove markers
deleteMarker _radar_marker;
deleteMarker _truck_marker;
hint localize "+++ x_sideradio.sqf: radar and truck markers deleted at side mission finish";

// d_radar continue to exists for the future adventures
if (_mission) then {
    // start the main loop, because there should be no more missions with the radio relay
    [] spawn {
		private [ "_handle" ];
		while {true} do {
			_handle  = "NOT_MISSION" execVM "x_missions\common\x_sideradio.sqf";
			while {!scriptDone _handle} do { sleep 60 };
		}
    };

};
