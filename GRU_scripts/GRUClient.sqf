// GRUClient.sqf, created by Sygsky on 09-DEC-2015
// receives and process all messages from server to client

#include "x_macros.sqf"
#include "GRU_setup.sqf"

#include "GRUCommon.sqf"

#define __DEBUG__

// removes action "remove document" from player menu. If no action id found in player variables, nothing occures
// call: call GRU_removeDocAction;
GRU_removeDocAction = {
	//hint localize format["GRU_removeDocAction: action exists == %1",call GRU_hasDocAction];
	if (call GRU_hasDocAction) then {
		private ["_id"];
		_id = player getVariable PLAYER_ACTION_REMOVE_DOC_ID_NAME;
		player removeAction _id;
		player setVariable [PLAYER_ACTION_REMOVE_DOC_ID_NAME, nil];
	};
};

// adds remove action to player menu. If action already exists, nothing occures
// call: call GRU_addDocAction;
GRU_addDocAction = {
	//hint localize format["GRU_addDocAction: action exists == %1",call GRU_hasDocAction];
	if ( !call GRU_hasDocAction ) then {
		private ["_id"];
		// let it be the most top menu item: "Уничтожить донесение"
		_id = player addAction [ "<t color='#FF0000'>"+ (localize "STR_GRU_26") + "</t>", "GRU_scripts\GRU_removedoc.sqf",[0], 1000];
		player setVariable [PLAYER_ACTION_REMOVE_DOC_ID_NAME, _id];
	};
};

GRU_hasDocAction = {
	if (isNull player) exitWith {false};
	private ["_var"];
	_var = player getVariable PLAYER_ACTION_REMOVE_DOC_ID_NAME;
	!isNil "_var";
};

// detects if player alreay has document (ACE_Map object)
GRU_hasDoc = {
	if (isNull player) exitWith {false};
	player call XCheckForMap
};

//
// call on client only as follow: _msg call GRU_msg2player;
GRU_msg2player = {
	if (isNull player ) exitWith {hint localize "GRU_msg2player: player isNull"};
	
	if ( typeName _this == "ARRAY" ) then {
		titleText [_this select 0, "PLAIN DOWN"];
		((_this select  0) call XfRemoveLineBreak) call XfGlobalChat;
	} else {
		titleText [ _this, "PLAIN DOWN"];
	};
};

//
// call on client only (on server always return false and doing nothing) 
// to remove any doc from user inventory and/or rucksack
//
// returns true if some (first detected) doc was found and removed 
// or false if not (e.g. called on server or no doc found in inventory)
//
GRU_removeDoc = {
	if ( isNull player ) exitWith {hint localize "GRU_removeDoc: isNull player";false}; // no player -> no docs
	if ( player hasWeapon "ACE_Map") exitWith {hint localize "GRU_removeDoc: ACE_Map removed"; player removeWeapon "ACE_Map"; /* GRU_docState = 0;  */true};
	private ["_removed"];
	_removed = false;
	if ( player call ACE_Sys_Ruck_HasRucksack ) then {
		{
			if ( _x == "ACE_Map_PDM" ) then {
				[player, "ACE_Map_PDM"] call ACE_Sys_Ruck_RemoveRuckMagazine;
				/* GRU_docState = 0; */
				_removed = true;
			};
		} forEach (player call ACE_Sys_Ruck_RuckMagazines);
	};
	_removed
};

//
// call on client only (on server always return false and doing nothing) to check document presence in user inventory and/or rucksack
//
// returns true if any doc is detected or false if called on server or no found
//
GRU_lostDoc = {
	if ( isNull player ) exitWith {false}; // no player -> no docs
	if ( GRU_docState == 0 ) then {	false } else { !(call XCheckForMap ) };
};


//
// calls on client only (on server always return false and doing nothing) to remove any doc from user inventory and/or rucksack
//
// returns true if doc was added or false if no place (rare case of full rucksack) or called
//
GRU_addDoc = {
	if ( isNull player ) exitWith {false}; // no player -> no docs
	private ["_weapons","_cnt","_str","_ret"];
	_weapons = weapons player;
	// check low slots filled
	_cnt = 0;
	{
		if ( (_x call SYG_weaponClass) == 0 ) then {_cnt = _cnt +1;};
	} forEach (weapons player);
	
	if ( _cnt < 2 ) then {  // can add map to inventory
		player addWeapon "ACE_Map";
	} else {
		_str = "";
		{
			_str = _str + format["%1:%2, ", _x,_x call SYG_weaponClass];
		} forEach (_weapons);
		hint localize format["GRU_addDoc: inventory bottom slots are occupied, can't add to them %1",_str];
	};
	
	if ( player hasWeapon "ACE_Map") exitWith { /* GRU_docState = 1; */ true };

	_ret = false;
	if ( player call ACE_Sys_Ruck_HasRucksack ) then {
		if ( [player, "ACE_Map_PDM"] call ACE_Sys_Ruck_FitsInRucksack ) exitWith
		{
			[player, "ACE_Map_PDM"] call ACE_Sys_Ruck_AddRuckMagazine; _ret = true;
#ifdef __DEBUG__
			hint localize "GRU_addDoc: map added to rucksack";
#endif	
		};
	};
#ifdef __DEBUG__
	hint localize format["GRU_addDoc: before exit weapons player == %1", weapons player];
#endif	
	_ret
};

//
// Processing unit for client commands receiver
//
//
GRU_procClientMsg = {
	private ["_msg","_kind","_task_name","_player_name","_obj","_comp"];
	_msg = arg(1); // sub-id, e.g. ["GRU_msg", GRU_MSG_START_TASK, _kind<,player_name>] call XSendNetStartScriptClient;
	_kind = arg(2);
	_task_name = switch _kind do {
		case GRU_MAIN_TASK: { localize "STR_GRU_2"};
		
		case GRU_SECONDARY_TASK: { "GRU_SECONDARY_TASK"};
		
		case GRU_OCCUPIED_TASK: {"GRU_OCCUPIED_TASK"};

		case GRU_PERSONAL_TASK: {"GRU_PERSONAL_TASK"};

		case GRU_FIND_TASK: {"GRU_FIND_TASK"};
		default {format ["Unknown GRU task kind %1",_kind]};
	};
	_player_name = argopt(3,localize "STR_GRU_9");
	switch _msg do {
		case GRU_MSG_STOP_TASK: {
			titleText[ format[localize "STR_GRU_5", localize "STR_GRU_4",localize "STR_GRU_1",_task_name,localize "STR_GRU_3" ],"PLAIN DOWN"]; // "Задача ГРУ ""доставить карту"" отменена"
		};
		case GRU_MSG_START_TASK: {
			titleText[ format[localize "STR_GRU_6", localize "STR_GRU_4",localize "STR_GRU_1", _task_name ],"PLAIN DOWN"]; // "Поступила новая задача ГРУ ""доставить карту"""
			sleep (1 + random 1);
			private ["_town","_comp","_pwr"];
			_town = [];
			for "_i" from 1 to 20 do {
    			_town = call SYG_getTargetTown;
				if ((count _town) > 0) exitWith {};
			    sleep (3 + (random 4));
			};
			if ((count _town) ==0) exitWith {
				hint localize format["--- GRUClient.sqf.GRU_procClientMsg.GRU_MSG_START_TASK: SYG_getTargetTown returned [] after 500 secs"];
			};
			_comp = call SYG_getGRUComp;
			if ( !isNull _comp) then {
			    // TODO: show D-effect not on house but above one of raio-town on base (2 on ground, 3 on services)
				// show Deritrinitation effect corresponding to target distance but not less 3
				_pwr = if (count _town == 0) then {3} else { 1.5 + (_comp distance (_town select 0)) / 1000}; // height of effect is eq to distance in km to target
				[_comp, 5 , _pwr] call SYG_showTeleport;
				hint localize format["GRUClient.sqf.GRU_procClientMsg.GRU_MSG_START_TASK: call to SYG_showTeleport for %1",_town];
			} else {
				hint localize format["--- GRUClient.sqf.GRU_procClientMsg.GRU_MSG_START_TASK: _comp is null"];
			};
/*			
#ifdef __DEBUG__
			hint localize "+++ GRUClient.sqf: GRU_MSG_START_TASK received and message printed";
#endif		
*/
		};
		// sent from clien ta as: ["GRU_msg", GRU_MSG_TASK_SOLVED, [["msg_to_user","",[_msg],4,4],_array_of_objects_array] ] call XSendNetStartScriptClient;
		case GRU_MSG_TASK_SOLVED: {
			playSound "tune"; // playSound "fanfare"; // information already sent to user
			//titleText[ format[localize "STR_GRU_7", localize "STR_GRU_4",localize "STR_GRU_1", _task_name, _player_name ],"PLAIN DOWN"]; // "задача ГРУ ""доставить развединфо из города"" выполнена (одним из вас)"
			private ["_params","_mgs_arr","_markers"];
			_params  = arg(2);
			_mgs_arr = argp(_params,0);
			_markers = argp(_params,1);
			_msg_arr spawn XHandleNetStartScriptClient; // emulate message sent from server
			sleep 0.5 + (random 0.5);
			[_markers] call SYG_resetIntelMapMarkers; //reset default markers set
		};
		case GRU_MSG_TASK_FAILED: {
			titleText[ format[localize "STR_GRU_8", localize "STR_GRU_4",localize "STR_GRU_1", _task_name, localize "STR_GRU_9"/* _player_name */ ],"PLAIN DOWN"]; // "задача ГРУ ""доставить развединфо из города"" провалена одним из вас"
		};
		case GRU_MSG_TASK_ACCEPTED: {
			// send back info to all clients and add accepted player to the list
			titleText[ format[localize "STR_GRU_33",_task_name ],"PLAIN DOWN"]; // "Задачу ГРУ ""доставить развединфо из города"" принята к исполнению"
		};
		case GRU_MSG_COMP_CREATED: {
			// GRU comp created, add action to it etc
			// 1. check if computer exists
			_comp = call SYG_getGRUComp; // get computer object
			hint localize format["+++ GRUClient.sqf: GRU_MSG_COMP_CREATED msg received, GRU PC == %1",_comp];
			if ( !isNull _comp ) then {
				// check if action not added
				if (format["%1",_comp getVariable COMPUTER_ACTION_ID_NAME] == "<null>") then {
//					"GRUClient.sqf: Action added to GRU PC" createVehicleLocal [0,0,0];
					if ( time > 300 ) then {playSound "ACE_VERSION_DING"; }; // inform about computer creation
					// add action
					_comp addAction [ localize (call SYG_getGRUCompActionTextId), call SYG_getGRUCompScript,[] ];
					_comp setVariable [COMPUTER_ACTION_ID_NAME,true];
				};
				_comp addAction [localize "STR_COMP_ILLUM", "scripts\baseillum\illum_start.sqf"];
			};
		};

		case GRU_MSG_INFO_TO_USER: { // id = 100
			// some info message to client, e.g. with sound
		    switch _kind do {
		        case GRU_MSG_INFO_KIND_PATROL_DETECTED: { // patrol detected by locals somewhere
		            //playSound "patrol"; // removed by Yeti request
                    _arr = arg(3); // array: [ _alias,_pos,_size,_patrol_type ]
                    _rank = (rank player) call XGetRankIndex;
                    //_rank = 6; // debug
                    // create base message text
                    _alias = argp(_arr, 0); // name of the observer
                    _args = ["STR_GRU_46",_alias,"","","","",""]; // message visible for any rank: "The landing of the enemy patrol spotted by %1%2%3%4%5%6"
                    _pos = argp(_arr, 1);   // spawn position
                    _loc = (_pos call SYG_nearestLocation);
                    if ( _rank > 1) then { // sergeant, location name
                        _args set[2, format[localize "STR_GRU_46_1", text _loc]];

                        if ( _rank > 2) then { // leutenant, distance
                            _detail_scale = ([500,250,200,100,50] select ( ( _rank min 6 ) - 2 ) ); // position accuracy depends on the rank of player
                            _dist = format[localize "STR_GRU_46_2", ( ceil(( (position _loc) distance _pos )/_detail_scale) ) * _detail_scale];
                            //hint localize format["GRUClient GRU_MSG_INFO_KIND_PATROL_DETECTED: _dist == %1", _dist];
                            _args set[3, _dist];

                            if ( _rank > 3) then { // captain, patrol direction from location
                                _dir = ([position _loc, _pos] call XfDirToObj) call SYG_getDirName;
                                _args set[4, format[localize "STR_GRU_46_3", _dir]];

                                if ( _rank > 4) then { // major, patrol vehicle numbering
                                    _num = argp(_arr, 2);
                                    _args set[5, format[localize "STR_GRU_46_4", _num]];

                                    if ( _rank > 5) then { // colonel, patrol type
                                        _pattype = argp(_arr, 3);
                                        _pattype = localize ("STR_PATROL_TYPE_" + toUpper(_pattype));
                                        _args set[6, format[localize "STR_GRU_46_5", _pattype]];
                                    };
                                };
                            };
                        };
                    };

                    // send GRU_msg to users about new patrol "The landing of the enemy patrol spotted by %1%2%3%4%5%6"
		            // check rank of player and add more info
		            ["msg_to_user", "", [_args]] call SYG_msgToUserParser; // message output
		        };
		        case GRU_MSG_INFO_KIND_PATROL_ABSENCE: { // all patrols are absence
		            ["msg_to_user", "", [["STR_GRU_46_0"] ] ] call SYG_msgToUserParser; // message output
		            playSound "fanfare";
		        };
   		        case GRU_MSG_INFO_KIND_MAP_CREATED: { // GRU wallmap created  (Sahrani or Rahmadi)
   		            sleep (2 + random 6);
   		            hint localize "GRU_MSG_INFO_KIND_MAP_CREATED sent to client";
   		            _pos = call SYG_mapPos;
   		            _map = nearestObjects [_pos, ["Wallmap","RahmadiMap"], 100];
   		            if ( count _map > 0) then {
   		                _map = _map select 0;
                        _id = _map addAction [localize "STR_CHECK_ITEM","GRU_scripts\mapAction.sqf", typeOf _map]; // "Изучить"
       		            hint localize format["GRU_MSG_INFO_KIND_MAP_CREATED: addAction == %1 added to the map", _id];
                    } else {hint localize "GRU_MSG_INFO_KIND_MAP_CREATED: no map found!!!";};
   		        };
                default {hint localize format ["--- unknown kind of [""GRU_msg"", ""GRU_MSG_INFO_TO_USER"", ""%1""] called", _kind]};
		    };
		};

		default {hint localize format["+++ GRUClient.sqf: ""GRU_msg"" unknown sub-id %1", _this]};
	};
};
