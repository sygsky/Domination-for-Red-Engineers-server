// GRUCommon.sqf.sqf, created by Sygsky on 09-DEC-2015

#include "x_setup.sqf"
#include "GRU_setup.sqf"

if ( isNil "GRU_tasks" ) then
{
	GRU_tasks = [
	//=========================
	// Main task parameters:
	//  _main_info = [[[9349,5893,0],"Cayo", 210,1],START_SCORE,PARTICIPANTS_LIST]; // array target_names from i_common.sqf, start town score, list of participants
	//=========================
		[], // main target (in towns): [target_town_info, initial_score, list_of_participants]
		
	//=========================
	//   Secondary task parameters:
	//   _sec_info = [50]; // radious of teleport zone
	//=========================
		[], // secondary target. In common case it is not valid as secondary missions are rarely situated at houses
		
		[], // occupied town mission
		
		[], // GRU task (pick-up agents, destroy anti-GLONASS device, etc)
		
	//	[], // GRU addition secondary missions (destroy any carrier with old nuclear missile ...)
		
		[]  // GRU task find mission (weapon in most)
	];

	// scores for successfull survey of fire object(0), map (1) etc
	GRU_specialBonusArr    = [              5,               3];
	GRU_specialBonusStrArr = ["STR_LIT_PRIZE", "STR_MAP_PRIZE"];
};

// call: _task = _task_id call GRU_getTask;
GRU_getTask = {
	if ( TASK_ID_NOT_VALID(_this)) exitWith {[]};
	// hint localize "GRUCommon.sqf.GRU_getTask:TASK_ID_NOT_VALID(_this) == true";
	argp(GRU_tasks,_this)
};

//
// call as follow: _isActive = _task_id call GRU_taskActive;
//
GRU_taskActive = {
	TASK_IS_ACTIVE(_this call GRU_getTask)
};

GRU_mainTaskActive = {
	MAIN_TASK_IS_ACTIVE
};

//
// check main task to be valid, that if task can be continued
//
GRU_mainTaskNotValid = 
{
	// check if any of town sub-targets alreadycompleted
	if ( target_clear || mt_radio_down || side_main_done ) exitWith { hint localize "GRUCommon.sqf.GRU_mainTaskNotValid: sub-target(s) finished"; true };
	
	private ["_task","_param_town"];
	_task = _this; // task array
	// check if town name is actual
	_param_town = call SYG_getTargetTown; // real target town info
	//hint localize format[ "param_town -> %1", _param_town ];
	if ( (count _param_town) == 0 ) exitWith { hint localize "GRUCommon.sqf.GRU_mainTaskNotValid: target not defined"; true}; // no real town defined
	
	_name = argp( _param_town, TOWN_NAME_IN_INFO );
	if ( GRU_MAIN_GET_TOWN_NAME_FROM_TASK(_task) != _name ) exitWith { hint localize "GRUCommon.sqf.GRU_mainTaskNotValid: target not coincide"; true };
	
	false
};

// returns main task info array
GRU_mainTaskInfo = {
	GRU_GET_TASK(GRU_MAIN_TASK)
};

// count active tasks and return their count (from 0 to count (GRU_tasks-1))
GRU_taskCount = {
	private ["_cnt"];
	_cnt = 0;
	{
		if ( TASK_IS_ACTIVE( _x) ) then { _cnt = _cnt + 1;};
	} forEach GRU_tasks;
	_cnt
};

// Returns description string for main GRU task
GRU_mainTaskDescription = {
	private ["_task","_score_plus","_score_minus","_str"];
	_task = GRU_GET_TASK(GRU_MAIN_TASK);
	_str = "";
	if ( TASK_IS_ACTIVE(_task) )then
	{
		_score_plus = GRU_MAIN_GET_SCORE_FROM_TASK(_task); // real score on town

		_score_minus = d_ranked_a select 24;
		_str = format [localize "STR_GRU_TASK_DESCR_0_INFO", GRU_MAIN_GET_TOWN_NAME_FROM_TASK(_task), localize "STR_GRU_26", _score_plus, _score_minus ];
	}
	else { _str = localize "STR_GRU_29";}; // "Главная задача не определена..."
	_str
};

/*
    Scores for investigations of some special objects (fire, map, enemy plans paper etc).
    If called from client computer, message if sent to server
    if called on serveк computer, scores are checked and available information sent ot user
*/
GRU_SpecialScores = {
    if (!X_CLIENT) then
    {
        // todo: check for scores
        hint localize format["Server-> GRU_specialScores: input %1", _this];
    }
    else
    {
        hint localize format["Client-> GRU_specialScores: input %1", _this];
        if ( _this >= 0 && _this < (count GRU_specialBonusArr)) then
        {
            if ( argp(GRU_specialBonusArr, _this) > 0) then
            {
                // todo: send info to user about scores for investigations etc
                //hint format[ "Client-> In future you'll got %1 score", argp(GRU_specialBonusArr,_this) ];
                // GRU_specialBonusArr set [_this, 0]; // no more scores available
                // send request to the server for score prize if not already used
                 ["GRU_event_scores", _this, name player] call XSendNetStartScriptServer;
            };
        };
    };
};
