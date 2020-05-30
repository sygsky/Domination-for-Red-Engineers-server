// by Xeno: x_scripts/x_recapture.sqf, server call only
private [ "_num_p", "_recap_index", "_loop_running", "_ran", "_target_array", "_target_pos", "_checktrigger", "_checktrigger2", "_target_name", "_radius", "_helih","_allready_recaptured","_arr"];
if (!isServer) exitWith {};

#include "x_setup.sqf"
#include "x_macros.sqf"

sleep (1200 + random 1200);

// return true if recapture is possible, else false

#define CAN_RECAPTURE ((d_max_recaptures > 0) && (count d_recapture_indices < d_max_recaptures))

_allready_recaptured = [];

while {true} do {
	// do recapture only if there are human players
	if (X_MP) then {
		waitUntil {sleep (61.012 + random 20);(call XPlayersNumber) > 0};
	};
	//__DEBUG_NET("x_recapture.sqf",(call XPlayersNumber))
	
	while {!main_target_ready} do {sleep 20.321}; // don't recapture if tower is down
	
	if (the_end) exitWith {false}; // no more towns, end of game

	 if( (count resolved_targets > 1) && (count d_recapture_indices < count resolved_targets - 1) && CAN_RECAPTURE ) then {
		_recap_index = -1;
		_loop_running = true;

		// Main loop to check exit conditions

		while {_loop_running} do {
			if (X_MP) then {
				waitUntil {sleep (8.012 + random 1);(call XPlayersNumber) > 0};
			};
			_ran = (count resolved_targets - 1) call XfRandomFloor;
			#ifndef __TT__
			_recap_index = resolved_targets select _ran;
			#endif
			#ifdef __TT__
			_recap_index = (resolved_targets select _ran) select 0;
			#endif
			sleep 0.1;
			if (!(_recap_index in d_recapture_indices) && !(_recap_index in _allready_recaptured)) then {
				_target_array = target_names select _recap_index;
				_target_pos = _target_array select 0;
				_radius = ((_target_array select 2) max 300) + 100; //+++ Sygsky: calculate radius, not use constant

				_checktrigger = createTrigger["EmptyDetector",_target_pos];
//				_checktrigger setTriggerArea [400,400, 0, false];
				_checktrigger setTriggerArea [_radius,_radius, 0, false]; //+++ Sygsky: Xeno trigger radius value was 400 
				_checktrigger setTriggerActivation [d_own_side_trigger, d_enemy_side, false];
				_checktrigger setTriggerStatements["this","",""];
				
				#ifdef __TT__
				_checktrigger2 = createTrigger["EmptyDetector",_target_pos];
//				_checktrigger2 setTriggerArea [400,400, 0, false];
				_checktrigger2 setTriggerArea [_radius,_radius, 0, false]; //+++ Sygsky: Xeno trigger radius value was 400 
				_checktrigger2 setTriggerActivation ["GUER", d_enemy_side, false];
				_checktrigger2 setTriggerStatements["this","",""];
				#endif
				
				sleep 125;
				
				#ifndef __TT__
				if (count list _checktrigger == 0) then {_loop_running = false};
				deleteVehicle _checktrigger;
				#else
				if (count list _checktrigger == 0 && count list _checktrigger2 == 0) then {_loop_running = false};
				deleteVehicle _checktrigger; deleteVehicle _checktrigger2;
				#endif
			};
			if (_loop_running) then {sleep 25};
		};
		
		sleep 0.01;
		
		_target_array = target_names select _recap_index;
		_target_pos = _target_array select 0;
		_target_name = _target_array select 1;
		_radius = _target_array select 2;
		_helih = _target_pos nearestObject "HeliHEmpty";
		_helih setDir 359;
		d_recapture_indices = d_recapture_indices + [_recap_index];
		_allready_recaptured = _allready_recaptured + [_recap_index];
		sleep 0.01;
		// create enemy troops, add to an array, check if units in array are still alive !!! if not, recapture over
		[_target_pos, _radius,_recap_index,_helih] execVM "x_scripts\x_dorecapture.sqf";
		
		if (d_own_side == "EAST") then //+++Sygsky: add more fun with flags
		{
			_arr = nearestObjects[_target_pos,["FlagCarrierNorth"],_radius];
			_sound = false;
			if ( (count _arr)  > 0 ) then
			{
				{
					_x setFlagTexture "\ca\misc\data\usa_vlajka.pac"; //+++Sygsky: set USA flag for more fun
				    if (!_sound) then {
				        ["say_sound", _x, (call SYG_invasionSound)] call XSendNetStartScriptClientAll;
				        _sound = true;
				    };
				} forEach _arr;
			};
		};
		
		// wait
		sleep 5.012;
		// send to players
		["recaptured",_recap_index,0] call XSendNetStartScriptClient;
	};
	if (current_counter > number_targets) exitWith {
	    hint localize "+++ x_recapture.sqf: stop recapture system as all target towns are liberated !!!";
	};
	sleep (1800 + random 600);
};

if (true) exitWith {};
