//
// GRUMissionSetup.sqf by Sygsky at 08-DEC-2015. For Domination GRU tasks system.
//
// Runs only on server
//
// Spawn it soon after new town target generated, and spawn on server of course
//

if ( !isServer ) exitWith { hint localize "--- GRUMissionSetup.sqf: !isServer, exit" };
if ( !isNil "GRUMissionSetup_on" ) exitWith { hint localize "--- GRUMissionSetup.sqf: !isNil ""GRUMissionSetup_on"" exit" };

GRUMissionSetup_on = true;

#include "x_macros.sqf"
#include "GRU_setup.sqf"

#define __PRINT__

// ordinal loop delay
#define MAIN_TASK_BEFORE_LOOP 150
#define MAIN_TASK_CHECK_LOOP_DELAY 10
#define MAIN_TASK_RERUN_DELAY 300

call compile preprocessFileLineNumbers "GRU_scripts\GRUCommon.sqf";	// Weapons, re-arming etc

//+++++++++++++++++++++++++++++++++++++++ MAIN CODE ++++++++++++++++++++++++++++

// run on server only
//["INIT"] call compile preprocessFileLineNumbers "GRU_scripts\GRUServer.sqf";

// run on client only
//["INIT"] call compile preprocessFileLineNumbers "GRU_scripts\GRUClient.sqf";


sleep MAIN_TASK_BEFORE_LOOP;

_ttinfo      = [];
_start_score = 0;
_rad         = 0;
_tmo         = 0;

//_sleep_delay = GRU_MAIN_TASK_NEXT_RUN; // start task on first step

scopeName "main";
while {current_counter < number_targets} do {
	// TODO: provide exit for this procedure when all tasks are reached
	//
	// here we wait for the next town (first on init) ready
	//
	waitUntil { sleep 10.315; ! (target_clear || mt_radio_down || side_main_done) }; // next target ready

    // wait for any player
    WAIT_FOR_PLAYER_CONNECTION; // define from "GRU_setup.sqf"

	//
	// init next town
	//
	sleep MAIN_TASK_RERUN_DELAY; // ensure all troops are generated
	_ttinfo = call SYG_getTargetTown;
	if (count _ttinfo == 0) then {
	    waitUntil {sleep 10; _ttinfo  = call SYG_getTargetTown; count _ttinfo > 0}
	};
	_rad = argp( _ttinfo, 2 ) max 300; // get 300 or higher radious
	_startScore = [ argp(_ttinfo,0), _rad +50, true ] call SYG_getScore4IntelTask;
	
	if ( _startScore < GRU_MAIN_TASK_MIN_SCORE ) then { // not enough score for the next run
#ifdef __PRINT__			
		hint localize "+++ GRUMissionSetup: MAIN TASK has too low scores to run";
#endif
		waitUntil {sleep 9.843; target_clear || mt_radio_down || side_main_done };
		
	} else { // enough score to run task next time
		
		[GRU_MAIN_TASK, [ _ttinfo, _startScore, []]] call GRU_startNewTask; // run next task for next town
		_task = + GRU_GET_TASK(GRU_MAIN_TASK);
#ifdef __PRINT__			
		_town_name = argp(_ttinfo,1);
		hint localize format["+++ GRUMissionSetup.sqf: GRU MAIN task [re]started for %1", _town_name];
#endif
		//["GRU_msg", GRU_MSG_START_TASK] call XSendNetStartScriptClient;

		scopeName "restart_town";
			
		//
		// loop on the task active
		//
		while { true } do  {
			if ( (call XPlayersNumber) == 0 ) then {
    			 // as players are absent, clear participants list
			    GRU_CLEAR_MAIN_TASK_USER_LIST;
			};

			_task = GRU_MAIN_TASK call GRU_getTask;

			// check if agents are present but all are logged out
   			_agent_list = argpopt(_task, GRU_MAIN_LIST,[]);
   			_cnt = count _agent_list; // valid agent count
   			_cnt1 = 0; // active agent counter
   			_stop = false; // stop task or not stop
   			if ( _cnt > 0 ) then {
				// check if all active agents (who is performing the task) are logged out
				_cnt1 = 0; // logged out agent counter
				{
					_id = d_player_array_names find _x; // get agent index in known player list
					if (_id >= 0 ) then {
						_parray = d_player_array_misc select _id;
						if ((_parray select 4) != "") then { _cnt1 = _cnt1 + 1}; // this agent is still logged in, count as active
					};
				} forEach _agent_list;
				_stop = _cnt1 == 0;
   			}; // else { hint localize format["--- GRUMissionSetup.sqf: agent list is []"]; };

			if ( _stop )  exitWith {
				GRU_CLEAR_MAIN_TASK_USER_LIST;
				if ( _cnt > 0) then { hint localize format["--- GRUMissionSetup.sqf: all %1 agent[s] were logged out ",_cnt]; };
			};
		    hint localize format["--- GRUMissionSetup.sqf: %1 agent[s] from %2 are still active", _cnt1, _cnt];

			// checks task to be invalid
			if ( _task call GRU_mainTaskNotValid ) exitWith  {
				hint localize "--- GRUMissionSetup.sqf: MAIN TASK is invalid, exit town loop";
			};
			if ( MAIN_TASK_IS_EMPTY ) then  {
//#ifdef __PRINT__			
//				hint localize  "hint localize : GRU MAIN task is empty";
//#endif
				// task was stopped due to some circumstances, lets wait some time before restart
				if ( _tmo == 0 ) then {
					_tmo = time + MAIN_TASK_RERUN_DELAY;
				} else {
					if (_tmo < time ) then { breakTo "restart_town";};
				};
			};
			sleep MAIN_TASK_CHECK_LOOP_DELAY;
		}; //while {true} do // town loop
		_tmo = 0;

		//
		// stop current task in any case
		//
		if ( GRU_MAIN_TASK call GRU_stopTask ) then { // msg about task stop
#ifdef __PRINT__			
			hint localize "+++ GRUMissionSetup: MAIN TASK stopped on town check loop exit";
#endif
		};
	};

}; // while {true} do // main loop

// clear task
GRU_MAIN_TASK call GRU_stopTask;

if ( true ) exitWith {GRUMissionSetup_on = nil;};