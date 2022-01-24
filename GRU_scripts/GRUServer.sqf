// GRUClient.sqf, created by Sygsky on 09-DEC-2015
// receives and process all messages from client to server

// ["msg_to_user",_player_name,[_msg1, ... _msgN]<,_delay_between_messages<,_initial_delay>>]

#include "x_macros.sqf"
#include "GRU_setup.sqf"

#include "GRUCommon.sqf"

// call as follow: _stopped = _task_id call GRU_stopTask;
GRU_stopTask = {
	if (!isServer) exitWith {false};
	private ["_task_id"];
	if ( _this call GRU_taskActive ) then
	{
		// stop old task first
		GRU_tasks set [_this, []];
		publicVariable "GRU_tasks";
		// send info about it second
		["GRU_msg", GRU_MSG_STOP_TASK, _this] call XSendNetStartScriptClient;
		true
	}
	else {false};
};

//
//  call on server as follow: _started = [... params ...] call GRU_startNewTask;
//
// params: [_task_kind, [_task params...]]
//
GRU_startNewTask = {
	hint localize format["+++ GRUServer.sqf.GRU_startNewTask: %1", _this];
	if (!isServer) exitWith {false};
	private ["_task_id"];
	_task_id = arg(GRU_TASK_KIND);
	if ( TASK_ID_NOT_VALID(_task_id) ) exitWith {
	 	hint localize format["+++ GRUServer.sqf.GRU_startNewTask: illegal task id %1, must be {0..%2}", _task_id, ((count GRU_tasks) -1)];
	 	false;
	};
	if ( _task_id call GRU_stopTask ) then { sleep 2.63;};
	GRU_tasks set[_task_id, arg(GRU_TASK_PARAMS)];
	publicVariable "GRU_tasks";
	["GRU_msg", GRU_MSG_START_TASK, _task_id] call XSendNetStartScriptClient;
	true
};

GRU_procServerMsg = {
	private ["_task_id","_msg","_task_name_id","_task_name","_player_name","_task","_agent_list"];
	_task_id = arg(2);
	if ( !(_task_id call GRU_taskActive) ) exitWith { hint localize format["Server GRU_msg designated task (%1) is not active %2",_task_id, _this];};
	_msg = arg(1); // sub-id, e.g. ["GRU_msg", GRU_MSG_START_TASK, _task_id<<<,player_name>,score>,marker_arr>] call XSendNetStartScriptClient;
	_task_name_id = "<UNKNOWN>";
	_task_name = switch _task_id do 
	{
		case GRU_MAIN_TASK: { _task_name_id = "STR_GRU_2"; localize "STR_GRU_2"};
		
		case GRU_SECONDARY_TASK: { "<GRU_SECONDARY_TASK>" };
		
		case GRU_OCCUPIED_TASK: { "<GRU_OCCUPIED_TASK>" };

		case GRU_PERSONAL_TASK: { "<GRU_PERSONAL_TASK>" };

		case GRU_FIND_TASK: { "<GRU_FIND_TASK>" };
		default {format ["Unknown GRU task kind %1",_task_id]};
	};
	_player_name = argopt(3,"<Unknown>");
	switch _msg do 	{
		case GRU_MSG_STOP_TASK;
		case GRU_MSG_COMP_CREATED;
		case GRU_MSG_START_TASK: {
			hint localize "--- GRU_MSG_START_TASK/GRU_MSG_STOP_TASK/GRU_MSG_COMP_CREATED can't be send from client to server";
		};
		case GRU_MSG_TASK_SOLVED: {
			// stop corresponding task and send info back to all clients
			_task_id call GRU_stopTask; // done!!!
			_msg = ["STR_GRU_7","STR_GRU_4",  "STR_GRU_1",  _task_name_id, "STR_GRU_9", argopt(4,"???")]; // задача ГРУ доставить развединфо из города выполнена (одним  из вас), очки +135

			// ["msg_to_user","",[_msg],4,4] call XSendNetStartScriptClient;
			//sleep 0.5 + (random 0.5);
			// send user msg and map markers update
			["GRU_msg", GRU_MSG_TASK_SOLVED, [["msg_to_user","",[_msg],4,4],arg(5)] ] call XSendNetStartScriptClient;
			hint localize format["Server GRU_MSG_TASK_SOLVED:  from player ""%1"" ", _player_name];
		};
		case GRU_MSG_TASK_FAILED: {
			// stop corresponding task and send info back to all clients
			_task_id call GRU_stopTask; // done!!!
			_msg = ["STR_GRU_8",  "STR_GRU_4", "STR_GRU_1",  _task_name_id, "STR_GRU_9"]; // "задача ГРУ ""доставить развединфо из города"" провалена (одним из вас)"
			["msg_to_user","",[_msg],4,4] call XSendNetStartScriptClient;
			hint localize format["Server GRU_MSG_TASK_FAILED:  from player ""%1"" ", _player_name];
		};
		case GRU_MSG_TASK_SKIPPED: { // user mission was unsuccessfull but task can continue
			_task = _task_id call GRU_getTask;
			_agent_list = argp(_task,GRU_MAIN_LIST); 
			if ( _player_name in _agent_list) then {
				_task set [GRU_MAIN_LIST, _agent_list - [_player_name]];
				publicVariable "GRU_tasks";
				hint localize format["Server GRU_MSG_TASK_SKIPPED: ""%1"" removed from agent list", _player_name];
			} else {
				hint localize format["Server GRU_MSG_TASK_SKIPPED: player ""%1"" isn't in list %2", _player_name, _agent_list];
			};
		};
		case GRU_MSG_TASK_ACCEPTED: {
			// send info back to all clients
			_task = _task_id call GRU_getTask;
			_agent_list = argp(_task,GRU_MAIN_LIST); 
			if ( !_player_name in _agent_list) then {
				_agent_list set [count _agent_list, _player_name];
//				_task set [GRU_MAIN_LIST, _agent_list + [_player_name]];
				publicVariable "GRU_tasks";
			};
			_msg = ["STR_GRU_10", "STR_GRU_1", _task_name_id, _player_name, GRU_MAIN_GET_TOWN_NAME]; // "задачу %1 ""%2"" начал выполнять %3"
			["msg_to_user","",[_msg]] call XSendNetStartScriptClient; // send mesage to everybody
			hint localize format["Server GRU_MSG_TASK_ACCEPTED: from ""%1""", _player_name];
		};
		
		default {hint localize format["--- GRUClient.sqf: ""GRU_msg"" unknown sub-id %1", _this]};
	}; // switch _msg do

};
/*
private ["_msg"];

_msg = arg(0);
switch (_msg) do
{
	case "GRU_msg": // the only message used for GRU operations (main id)
	{
		_this call GRU_procServerMsg;
	}; // case "GRU_msg"
	
	case "INIT": {};
	// other messages (on real server)
	default { hint localize format["XSendNetStartScriptClient: server still not supply %1", _this ]; };
}; //switch (_msg) do
*/