//
// GRU_townraid.sqf, created by Sygsky at 09-DEC-2015
//
// start with GRU town reconnaissance mission. Call only on client to use 'player' variable
//
// It does:
// 1. GRU-port procedure
// 2. GRU-port effects during it
// 3. Checking task execution up to the end (success or failure)
//
// call as : _hnd = [_pc, _dist, _score_plus, _score_minus] execVM "GRU_scripts\GRU_townraid.sqf"
// _pc         : GRU computer or its position 
// _dist       : distance to computer to done mission
// _score_plus  : positive (> 0)score for success
// _score_minus : negative score (< 0) for failure
//

#include "x_macros.sqf"
#include "GRU_setup.sqf"

//#define __DEBUG__

#define INTEL_MAP_TEMP_MARKERS_PREFIX "IMMTemp_"

#define SEARCH_DURATION_STEPS 30
#define CYCLE_SLEEP_SEC 2
#define LOST_REMINDER_PERIOD_STEPS 5

#define FADE_OUT_DURATION 0.3
#define FADE_IN_DURATION 6

#define WEAPON_HOLDER_DIST_TO_SEARCH 10

if (!isNil "player_is_on_town_raid") exitWith {};
player_is_on_town_raid = [];

if ( isNil "GRU_next_job_time") then 
{ 
	GRU_next_job_time = 0;
	publicVariable "GRU_next_job_time";
}; // last time you got the GRU job

_tt = [];

for "_check" from 0 to 0 do
{
	_tt = GRU_MAIN_GET_TOWN_INFO;
	if ( count _tt < 3) exitWith
	{
		sleep 1; (format[localize "STR_GRU_45", _tt, client_target_counter, number_targets, target_clear]) call GRU_msg2player; // "Ошибка Д-установки. Телеметрия: %1, %2"
	};

	if ( (!alive player) || (getDammage player >= 0.05) ) exitWith
	{
		// if dead or health is <= 0.95, exit
		sleep 1; (localize "STR_GRU_35") call GRU_msg2player; // "Вы отстранены от задания по состоянию здоровья" 
	};

	if ( time < GRU_next_job_time ) exitWith
	{
		_val = floor((GRU_next_job_time - time) /(GRU_BEFORE_NEXT_JOB_DELAY/3));
		_str = format["STR_GRU_4%1", ((_val+1) min 3) max 1]; // раскалённый, горячий, тёплый
		format[localize "STR_GRU_37", round((GRU_next_job_time - time)/60 + 0.5), localize _str] call GRU_msg2player; // "Деритринитатор ещё не остыл, подождите ещё (примерно %1 мин.)"
	};

	// you will be В-ported in any case, so mark this fact
	GRU_next_job_time = time + GRU_BEFORE_NEXT_JOB_DELAY; // set next GRU PS entry time
	publicVariable "GRU_next_job_time";

	_rnd_port_msg = 
	{
//		private ["_str"];
		"STR_GRU_TELE_NUM" call SYG_getLocalizedRandomText;
//		call compile format["_cnt=%1;",localize "STR_GRU_TELE_NUM"];
//		call compile format ["localize 'STR_GRU_TELE_%1'", floor(random _cnt)];
	};

	_menu_id      = -1; // if != -1, action with _menu_id is added
	_pc           = arg(0); // pc position
	_dist         = arg(1); // dist to pc
	_score_plus   = arg(2);
	_score_minus  = arg(3);
	if ( _score_minus > 0 ) then { _score_minus = -_score_minus; };

	_score = 0; // score to add to user on exit
	_wpnHolders = [];

	_remove_weapon_holders = {
		if ( count _wpnHolders > 0 ) then
		{
			{ deleteVehicle _x;} forEach _wpnHolders;
			sleep 0.1;
			_wpnHolders = [];
		};
	};
	
	scopeName "main";

	for "_main" from 0 to 0 do
	{
		GRU_docState =  -1; // undefined before start

		// check if player is in good state
		playSound "ACE_VERSION_DING";
		sleep 0.1;

		playSound "FlashbangRing";
		FADE_OUT_DURATION fadeSound (0.2); // stun him

		cutText["","WHITE OUT",FADE_OUT_DURATION];  // blind him fast
		sleep FADE_OUT_DURATION; // wait until blindness on

		FADE_IN_DURATION fadeSound 1; // smoothly restore hearing

		//(call _rnd_port_msg) spawn {sleep 1; _this call GRU_msg2player;}; // self-feeling rnd message
		sleep (FADE_IN_DURATION/2);
		cutText["","WHITE IN",FADE_IN_DURATION]; // restore vision
		// define if gru-portal succeed or not
		_rnd = random 10;
		if ( _rnd >= 0.2) then 
		{
			_target_town = argp(target_names,current_target_index);
			if ( (client_target_counter < number_targets) && (_rnd < 0.5) ) then
			{
				// undefined D-porting, no real action, only type joke for player
				// teleport to a random location
				_rnd_town = + _target_town;
				while { argp(_rnd_town,1) == argp(_target_town,1)} do {_rnd_town = target_names call XfRandomArrayVal;};
				[_rnd_town, argp(_rnd_town,2),4] call SYG_teleportToTown;
				sleep 2; (localize "STR_GRU_25") call GRU_msg2player; // "GRU-portal worked? But where I am? Surely not on the Mars... Already not so bad..."
				breakTo "main";
			};
			// real gru-portal jump, do all we need for it
			_ret = [_target_town,[/* 50,100, */150],4] call SYG_teleportToTown;
			switch _ret do
			{
			    // bad params
			    case 0:
			    {
                    (localize "STR_GRU_28_1") call GRU_msg2player;
    				breakTo "main";
			    };
			    // no good house found
			    case -1:
			    {
                    (localize "STR_GRU_28_2") call GRU_msg2player;
    				breakTo "main";
			    };
			};
			player_is_on_town_raid = [argp(_target_town,1),_score_plus,_score_minus,time]; // town name, score+, score-,start time
		}
		else 
		{
			// no gru-portal occured at all
			// TODO: info about failure
			sleep 2; (localize "STR_GRU_24") call GRU_msg2player; // ГРУ-портал не сработал
#ifdef __DEBUG__	
			hint localize format["--- GRU_townraid.sqf: (random 10 == %1) < 0.1; GRU portal not works!", _rnd];
#endif		

			breakTo "main";
		};
		
		sleep (FADE_IN_DURATION/2);

		//titleCut ["","BLACK IN",1];

		//10 fadeSound 0;
		//10 fadeMusic 0;
		//[] spawn {sleep 10; 3 fadeSound 1;};

		//playSound "tune";

		// add secret document (ACE_Map object)
		
		GRU_docState = 0; // no doc
		_str = localize "STR_GRU_19"; // "Вы нашли в городе нашего человека и установили с ним контакт"
		// try to add the map to player inventory or rucksack (if already exist, do nothing)
		if ( !(player call XCheckForMap) ) then 
		{
			if ( !(player call GRU_addDoc) ) then
			{
				_str = format["%1. %2", _str, localize "STR_GRU_20"]; //"Но Вам некуда даже спрятать этот документ (нет места)!"
				_str call GRU_msg2player; 
				["GRU_msg", GRU_MSG_TASK_SKIPPED, GRU_MAIN_TASK, name player] call XSendNetStartScriptServer; 
				sleep 2;
				breakTo "main";
			};
		};

		GRU_docState = 1; // owned doc

		_str = format["%1.\n%2", _str, localize "STR_GRU_21"];
		_str call GRU_msg2player; // "Он передал Вам донесение, которое вы надёжно спрятали.\nНе дай разум уничтожить его случайно!"

		[] spawn { // play random well known password phrase sound from one of soviet movie and show message about
		    // get random password speaking
		    playSound (["slavianskiy","odinakovo","vam_bileter"] call XfRandomArrayVal);
            sleep (5 + (random 3));
			(call _rnd_port_msg) call GRU_msg2player;
		};

		_pos = arg(0); // destination
		if (typeName _pos == "OBJECT") then {_pos = getPos _pos;};

		// add top menu item
		call GRU_addDocAction;

		hint localize format["GRU_townraid.sqf: params %1, TargetTown structure %2",_this, _tt];
		_target_pos = argp(_tt,0);
		_target_rad = argp(_tt,2);
		_tt = [west, _target_pos, _target_rad ] call SYG_sideStaticWeapons;
		// clear map if exists
		call SYG_hideDefaultIntelMarkers; // hide default map markers if exist
		[_tt, INTEL_MAP_TEMP_MARKERS_PREFIX] call SYG_resetIntelMapMarkers; // draw new local map
		
		_search_cnt = 0;
		_unc_msg_fired = false;

		while { true } do
		{
			sleep CYCLE_SLEEP_SEC;
			if ( !alive player ) exitWith
			{
				if ( GRU_docState > 0 ) then
				{
					[ localize "STR_GRU_12"] call GRU_msg2player; // "Вы погибли и враг прочтёт доверенное Вам разведдонесение. За это - штраф!"
					[ "GRU_msg", GRU_MSG_TASK_FAILED, GRU_MAIN_TASK, name player ] call XSendNetStartScriptServer;
					_score = _score_minus;
				}
				else
				{
					[localize "STR_GRU_13"] call GRU_msg2player; // "Вы погибли при исполнении задания ГРУ, но не допустили утечки информации. Сахранийцы не забудут героя!"
					["GRU_msg", GRU_MSG_TASK_SKIPPED, GRU_MAIN_TASK, name player] call XSendNetStartScriptServer; 
					sleep 1;
				};
				call SYG_playRandomOFPTrack;
			};
			
			if ( !TASK_ID_IS_ACTIVE(GRU_MAIN_TASK) ) exitWith
			{
				playSound "tune";
				//(localize "STR_GRU_11") call GRU_msg2player; // "ГРУ отменило эту задачу, возвращайтесь к обычной боевой службе"
			};
			
			if ( (player call SYG_ACEUnitUnconscious) && (!_unc_msg_fired)) then
			{
				_unc_msg_fired = true;  // think it once per raid
				[localize "STR_GRU_18"] call GRU_msg2player; // "...последняя ускользающая мысль: УНИЧТОЖИТЬ ... ДОКУМЕНТ ..."
			}
			else // user is alive and can stand
			{
				if ( GRU_docState == 0 ) then // document was deleted
				{
					playSound "tune";
					if (player call SYG_ACEUnitUnconscious) then
					{
						[(localize "STR_GRU_34")] call GRU_msg2player; //"Последним героическим усилием вы уничтожаете документ..."
					}
					else
					{
						[(localize "STR_GRU_30")] call GRU_msg2player; // "Уничтожив документ, придётся вернуться к обычной боевой службе"
					};
					// send message on server about skip 
					["GRU_msg", GRU_MSG_TASK_SKIPPED, GRU_MAIN_TASK, name player,4,4] call XSendNetStartScriptServer; 
					breakTo "main";
				};
				if ( ! (call XCheckForMap) ) then // you lost your map, try to search it in vicinity
				{
					if ( _search_cnt >= SEARCH_DURATION_STEPS ) then 
					{
						// get WeaponHolders at some distance
						call SYG_playRandomDefeatTrack;
						call _remove_weapon_holders;
						[(localize "STR_GRU_16")] call GRU_msg2player; // "Вы позорно потеряли доверенное Вам разведдонесение! Задание провалено!"
						sleep 2;
						["GRU_msg", GRU_MSG_TASK_FAILED, GRU_MAIN_TASK, name player] call XSendNetStartScriptServer; 
						_score = _score_minus;
						breakTo "main";
					};
					if (_search_cnt != 0) then
					{
						if ( (_search_cnt % LOST_REMINDER_PERIOD_STEPS) == 0 ) then
						{
							(format[localize "STR_GRU_15", (SEARCH_DURATION_STEPS - _search_cnt) *CYCLE_SLEEP_SEC]) call GRU_msg2player; // "Найдите карту! У Вас осталось %1 сек. до провала задания!"
						};
					}
					else
					{
						call SYG_playRandomOFPTrack;
						_wpnHolders = nearestObjects [ player, ["WeaponHolder"], WEAPON_HOLDER_DIST_TO_SEARCH];
#ifdef __DEBUG__		
						hint localize format["GRU_townraid.sqf: found WeaponHolders at dist %2 == %1", _wpnHolders, WEAPON_HOLDER_DIST_TO_SEARCH];
#endif			
						(format[localize "STR_GRU_14",CYCLE_SLEEP_SEC * SEARCH_DURATION_STEPS]) call GRU_msg2player; // "Вы потеряли карту! У вас есть только %1 сек. чтобы найти её!"
						call GRU_removeDocAction;
						INTEL_MAP_TEMP_MARKERS_PREFIX call SYG_hideIntelMarkers;
					};
					_search_cnt = _search_cnt + 1;
				}
				else 
				{
					if ( (player distance _pos) < _dist ) then // you bring the map
					{
						// play sound of success, add score etc
						playSound "fanfare";
						_score = _score_plus;
						// send message to server about completion and map markers for all users
						["GRU_msg", GRU_MSG_TASK_SOLVED, GRU_MAIN_TASK, name player, _score, _tt] call XSendNetStartScriptServer; 
						format[ localize "STR_GRU_7",localize "STR_GRU_4", localize "STR_GRU_1", localize "STR_GRU_2", localize "STR_GRU_36",_score] call XfHQChat; // "задача ГРУ ""доставить карту"" выполнена (вами), очки +NNN" 
						breakTo "main";
					};
					if ( _search_cnt > 0 ) then // map was on ground before this step
					{
						call _remove_weapon_holders;

						(localize "STR_GRU_22") call GRU_msg2player; // "Ф-у-у-у, пронесло (вытирая пот со лба)..."
						_search_cnt = 0;
						call GRU_addDocAction;
						INTEL_MAP_TEMP_MARKERS_PREFIX call SYG_showIntelMarkers;
					};
				};
				//_unc_msg_fired = false;
			};
		}; // while { true } do
	}; // for "_main" from 0 to 0 do

	if ( _score != 0 ) then {
		//player addScore _score ;
		_score call SYG_addBonusScore;
	};
	[0] execVM "GRU_scripts\GRU_removedoc.sqf";
}; //for "_check" from 0 to 0 do

INTEL_MAP_TEMP_MARKERS_PREFIX call  SYG_removeMarkers;

call SYG_showDefaultIntelMarkers;

if ( true) exitWith { player_is_on_town_raid = nil;};