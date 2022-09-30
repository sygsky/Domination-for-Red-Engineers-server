// Xeno, x_scripts\x_funcs\x_netinitserver.sqf, on server only
#include "x_setup.sqf"
#include "x_macros.sqf"
#include "global_vars.sqf"

// #define __DEBUG_DOSAAF__

"d_nv_serv" addPublicVariableEventHandler {
	(_this select 1) call XHandleNetVar;
};
// Yeti has variable time offset, so I commented him
SYG_userNames  = ["EngineerACE","HE_MACTEP","Snooper","yeti","Rokse [LT]","Ceres-de","CERES de","Ceres.","CERES","gyuri", "Frosty", /*"Aron",*/"White Jaguar","Renton J. Junior","HRUN"/*,"GREY."*/];
SYG_localZones = [            0,          0,        0,    -4,           0,        +1,        +1,      +1,     +1,     +1,       +1, /*    +1,*/            -4,                +1,    -7/*,     +2*/];

XHandleNetStartScriptServer = {
	private ["_this","_params"];
	//__DEBUG_NET("x_netinitserver.sqf XHandleNetStartScriptServer _this",_this)
	switch (_this select 0) do {
#ifdef __DEBUG_DOSAAF__
	    case "getbonus": {
//	        hint localize "+++ x_netinitserver.sqf: [] execVM ""x_scripts\x_getbonus.sqf""";
//	        side_mission_winner = 1;
			[] execVM "scripts\bonus\createBFBonus.sqf";
	    };
#endif
		case "ari_type": {
			__compile_to_var;
			ari_salvos = (_this select 2);
			(_this select 3) execVM "x_scripts\x_arifire.sqf";
		};
		case "ari_type2": {
			__compile_to_var;
			ari_salvos2 = (_this select 2);
			(_this select 3) execVM "x_scripts\x_arifire2.sqf";
		};
		case "d_create_box": {
			if (!d_old_ammobox_handling) then {
				(_this select 1) spawn XCreateDroppedBox;
			} else {
				[_this select 1, _this select 2] spawn XCreateDroppedBox;
			};
		};
#ifndef __TT__
		case "d_fac_ruins_pos": {
			[(_this select 1) select 0,(_this select 1) select 1] spawn XFacRebuild;
		};
#endif
#ifdef __TT__
		case "add_kills_racs": {
			kill_points_racs = kill_points_racs + (_this select 1);
		};
		case "add_kills_west": {
			kill_points_west = kill_points_west + (_this select 1);
		};
#endif
		case "mr1_in_air": {
			__compile_to_var;
		};
		case "mr2_in_air": {
			__compile_to_var;
		};
#ifdef __TT__
		case "mrr1_in_air": {
			__compile_to_var;
		};
		case "mrr2_in_air": {
			__compile_to_var;
		};
#endif
		case "mr1_lift_chopper": {
			__compile_to_var;
			if (!isNull mr1_lift_chopper) then {[mr1_lift_chopper] spawn x_checktransport;};
		};
		case "mr2_lift_chopper": {
			__compile_to_var;
			if (!isNull mr2_lift_chopper) then {[mr2_lift_chopper] spawn x_checktransport;};
		};
#ifdef __TT__
		case "mrr1_lift_chopper": {
			__compile_to_var;
			if (!isNull mrr1_lift_chopper) then {[mrr1_lift_chopper] spawn x_checktransport2;};
		};
		case "mrr2_lift_chopper": {
			__compile_to_var;
			if (!isNull mrr2_lift_chopper) then {[mrr2_lift_chopper] spawn x_checktransport2;};
		};
#endif
		case "x_drop_type": { // 	["x_drop_type",x_drop_type,markerPos "x_drop_zone",name player] call XSendNetStartScriptServer;
			[_this select 1,_this select 2,_this select 3] execVM "x_scripts\x_createdrop.sqf";
		};
		case "d_placed_obj_add": {
			d_placed_objs set [count d_placed_objs, _this select 1];
		};
		case "d_air_taxi": {
			(_this select 1) execVM "x_scripts\x_airtaxiserver.sqf";
		};
		case "d_rem_box": {
			private ["_i", "_box_a", "_pos"];
			for "_i" from 0 to (count d_ammo_boxes - 1) do {
				_box_a = d_ammo_boxes select _i;
				_pos = _box_a select 0;
				if (_pos distance (_this select 1) < 5) exitWith {
					_box_a set [0,[]];
				};
			};
		};
		case "d_flag_vec": {
			(_this select 1) setVariable ["d_end_time", (time + d_remove_mhq_vec_time + 60)];
			[(_this select 1)] call XAddCheckDead;
		};

		// store currect player score
		// send full score (_newscore), in town kill score (_mtkills)
        // Variants:
        // 1. ["d_ad_sc", name player || _player_id, _newscore, _mtkills] call XSendNetStartScriptServer;
        // 2. ["d_ad_sc", name player] - simply to inform about town score received by the player
		case "d_ad_sc": {
			if ( count _this  == 2 ) exitWith { // confirmation that player is online
				if ( ! ( ( _this select 1 ) in SYG_players_online ) ) then {
//					hint localize format[ "+++ DEBUG: player ""%1"" confirmed his online status", _this select 1 ];
					SYG_players_online set [ count SYG_players_online, _this select 1 ]; // add player name to the bonus receiver array
				};
			};
			_this call XAddPlayerScore;
		};

		// store player weapon list on the server
		// params: ["d_ad_wp", _player_name,_player_weapon_str_array<,_sound<,_sound_object>>]
		case "d_ad_wp": {
			[(_this select 1),(_this select 2)] spawn SYG_storePlayerEquipmentAsStr;
			if ((count _this) > 4) then {
				["say_sound", _this select 4, _this select 3] call XSendNetStartScriptClientAll; // send armory sound to all players
			};
		};

		// It is 1st message from client, info from user about his name, missionStart, language, addons found etc.
		// This message is answered with  user score, weapons etc
		// Example: ["d_p_a", name player<, missionStart<,"RUSSIAN"<,"ACE_found">>>]
		case "d_p_a": {
            // store server time directly now for better accuracy
            SYG_server_time  = time;       // current server time at the synchonizaton moment

			_this spawn XGetPlayerPoints; // response with user scores, equipment, viewdistance, suicide sound...
			if ( count _this > 2) then { // missionStart received
			    private ["_userLogin", "_ind"];
			    _userLogin = arg(1);
			    _ind = SYG_userNames find _userLogin;
				private ["_localDate", "_timeOffset"];
				_localDate  = arg(2);
			    if (_ind >= 0 ) then {
			        _timeOffset = SYG_localZones select _ind;

			        // store real time or the server (MSK must be guarantied)
			        // and local time to help know real time through whole mission during being suspend/resume in virtual machines
			        // TODO: надо как то 
                    SYG_client_start = [_localDate, _timeOffset] call SYG_bumpDateByHours; // current time on last connected client
                    hint localize format["+++ x_netinitserver.sqf: ""d_p_a"", missionStart from known timezone (%1) client was accepted !!!",
                        if (_timeOffset >= 0) then {format["+%1",_timeOffset ]} else {_timeOffset}];
			    } else {
			        if ( isNil "SYG_client_start") then {
                        // unknown client started server, let get time from it in any case
                        SYG_client_start = _localDate; // current time on first and unknown connected client
                        hint localize "+++ x_netinitserver.sqf: ""d_p_a"", missionStart from client started server without known timezone was accepted !!!";
			        } else {
                        hint localize "+++ x_netinitserver.sqf: ""d_p_a"", missionStart from client with unknown timezone wasn't accepted !!!";
			        };
			    };
			    hint localize format[ "+++ x_netinitserver.sqf: %1 ""d_p_a"", %2, %3, %4", argopt(3,"<NO_LANG>"), _userLogin, arg(2), if ((count _this) > 4) then {_this select 4} else { "" } ];
//			    if (count _this > 4) then {
//			    	hint localize format["+++ x_netinitserver.sqf: client file path ""%1""", arg(5)]
//			    }; // "x_setuplayer.sqf" file path on client computer (just for fun)
			};
		};
		/*
		 * Answer to initiation message sent from client as follow:
		 * _name = name player;
		 * ["d_p_varname",_name,str(player)] call XSendNetStartScriptServer;
		 * Is answered to client with messages to describe current situation in the mission
		 */
		case "d_p_varname": {
			_this call SYG_d_p_varname;
		};

		case "GRU_msg": {
			_this call GRU_procServerMsg;
		};

#ifdef __SPPM__

		// SPPM event handler on server (receive messages from client)
		// format:	["SPPM","ADD", _pos, name player] call XSendNetStartScriptServer;
		case "SPPM": {
			switch ( _this select 1 ) do {

				// format: ["SPPM","ADD", _pos, player_name]
				case "ADD": { // add SPPM at designated position by known player
					hint localize format["+++ SPPM ADD: pos %1 (%2), player ""%3""",
						arg(2),
						[arg(2),"%1 m. to %2 from %3",10] call SYG_MsgOnPosE,
						arg(3)
						];
					private [ "_msg_arr" ];
					_msg_arr = arg(2) call SYG_addSPPMMarker; // returns message about results
					if (typeName _msg_arr == "STRING") then {_msg_arr = [_msg_arr]};
					[ "msg_to_user", arg(3), [_msg_arr], 5, random 4, false, "set_marker" ] call XSendNetStartScriptClient; // corresponding message after procedure execution
				};

				// format: ["SPPM", "UPDATE", name player<, false>] call XSendNetStartScriptServer;
				case "UPDATE" : { // update all SPPM available
					hint localize format["+++ SPPM UPDATE (ALL): player ""%1""", arg(2)];
					private ["_cnt","_arr", "_send"];
					_cnt = count SYG_SPPMArr;
					_send = if (count _this > 3) then { _this select 3 } else {true};
					if ( _cnt == 0) exitWith {
						if (_send) then {
							["msg_to_user", "*", [["STR_SPPM_0"]], 5, 0, false, "losing_patience"] call XSendNetStartScriptClient; // "SPPM markers not found on map"
							}
					}; //

					_arr = call SYG_updateAllSPPMMarkers;
					if (_send) then {
						["msg_to_user", "*", [["STR_SPPM_1", arg(2), _cnt, _arr select 0, _arr select 1]], 5, 4, false, "message_received"] call XSendNetStartScriptClient; // "All SPPM markers have been updated"
					};
				};

				default {hint localize format["--- bad SPPM params: %1", _this];};
			};
		};
#endif

        // ["syg_plants_restore", _player_name, _restore_center_pos, _restore_radious] call XSendNetStartScriptServer;
/**
        // REMOVED as non workable correctly in Arma-1. Vegetation can't be restored as no synchronization betweeen server and client about it.
        case "syg_plants_restore": // restore plants and fences
		{
		    hint localize format["+++ Server received msg: %1",_this];
            _score = [arg(2),arg(3)] call SYG_restoreIslandItems;
            ["syg_plants_restored", arg(1), arg(2), arg(3), _score] call XSendNetStartScriptClient;
		    hint localize format["+++ Server send msg: %1", ["syg_plants_restored", arg(1), arg(2), arg(3)]];
		};
*/
/** Not used on server
        case "say_sound": // say user sound from predefined vehicle/unit
		{
		    private ["_vehicle","_sound"];
		    _vehicle = argopt(1, objNull);   // vehicle to play sound on it
		    if ( isNull _vehicle ) exitWith {hint localize "--- ""say_sound"" _vehicle is null";};
		    _sound   = argopt(2, "");        // sound to play
		    if ( _sound == "" ) exitWith {hint localize "--- ""say_sound"" _vehicle sound is empty";};
		    hint localize format["server ""say_sound"" (%1, %2)", typeOf _vehicle, _sound];
		    _this call XSendNetStartScriptClientAll; // resend to all clients
//		    _vehicle say _sound; // do this on clients only
		};
*/

		// add vehicle to the group: ["addVehicle", (group player), _veh]
		case "addVehicle": {
		    (_this select 1) addVehicle (_this select 2); // (group player) addVehicle _veh;
		};

        // information about battle air vehicle activity: ["veh_info", [ _veh, "on" ]] or ["veh_info", [ _veh, "off" ]]
		case "veh_info": {
		    private ["_veh","_cmd","_cnt","_usr"];
		    _params = (_this select 1); // parameters array of this command
		    _veh    = _params select 0; // vehicle
		    _cmd    = _params select 1; // "on"/"off"
		    _usr    = if ( (count _params) > 2) then {format["(%1)", _params select 2]} else {"(?)"};
		    switch (toLower _cmd) do {
		        case "on"  : {
		            if (!(_veh isKindOf "Air") ) exitWith {
		                _cnt = count SYG_owner_active_air_vehicles_arr;
		                hint localize format["--- ""veh_info"": attempt to add illegal type %1%2 to the list[%3]", typeOf _veh, _usr, _cnt];
		            };
		            if (_veh in SYG_owner_active_air_vehicles_arr) exitWith {};  // already in
		            SYG_owner_active_air_vehicles_arr set[ count SYG_owner_active_air_vehicles_arr , _veh ]; // add new vehicle
		            _cnt = count SYG_owner_active_air_vehicles_arr;
		            hint localize format["+++ ""veh_info"": %1%2 added to list[%3]", typeOf _veh, _usr, _cnt];
		        };
		        // remove vehicle
		        case "off" : {
		            SYG_owner_active_air_vehicles_arr = SYG_owner_active_air_vehicles_arr - [ _veh ];
		            _cnt = count SYG_owner_active_air_vehicles_arr;
		            hint localize format["+++ ""veh_info"": %1%2 removed from list[%3]", typeOf _veh, _usr, _cnt];
		        };
		        default {hint localize format["--- ""veh_info"": illegal params %1", _params]};
		    }
		};

        // request to run illum over base, params: [ "illum_over_base", _player_name]
        case "illum_over_base" : {
            // define object to be center of illumination zone (base flag)

            // script will remove all found objects that are closer (in 2D dist) than 10 meters to these poins
            [   _this select 1,
            #ifndef __TT__
                FLAG_BASE // [ flare lunching player name, central object of illumination zone]
            #else
                if (d_own_side == "WEST") then { WFLAG_BASE } else { RFLAG_BASE  }
            #endif
            ] execVM "scripts\baseillum\illumination_full.sqf"
        };
#ifdef __DEBUG_FLARE__
        // debug YELLOW flares over base object (e.g. FLAG_BSE)
        case "yellow_flare_over_base" : {
			[_this select 1, 150, "Yellow", 400] execVM "scripts\emulateFlareFired.sqf";
        };

#endif

        // ["log2server", _player_name,"literal_message_not_STR_NNN"]...
        case "log2server": {
            hint localize format["+++ Log from ""%1"": %2", _this select 1, _this select 2];
        };

#ifdef __DOSAAF_BONUS__
		// [ "bonus", _sub_command, _player_name, _vehicle ]
		case "bonus" : {
			private ["_veh"];
			_veh = _this select 3;

			switch (_this select 1) do {
				// send vehicle to all players to draw and control marker on it
				case "ADD": { // add vehicle to the markered list of known vehicles
					// mark to be marked and monitored vehicle
					_veh setVariable ["RECOVERABLE", false]; // mark vehicle as inspected, marked and not recoverable
					_veh setVariable ["DOSAAF", nil];
					hint localize format["+++ bonus.ADD on server: change from ""Inspect"" to ""Register"", send info on %1 to all clients from %2", typeOf _veh, _this select 2];
					_this call XSendNetStartScriptClientAll; // to all clients
				};

				// register vehicle as RECOVERABLE from now
				case "REG": {
					_veh setVariable ["RECOVERABLE", true]; // is set in call SYG_assignVehAsBonusOne to allow to restore vehicle
					_veh setVariable ["DOSAAF", nil];
					_veh call SYG_removeVehicleHitDamKilEvents;
					_veh call SYG_assignVehAsBonusOne;
					hint localize format["+++ bonus.REG on server:  register event about  %1 is send to all clients from %2, RECOVERABLE = %3", typeOf _veh, _this select 2, _veh getVariable "RECOVERABLE"];
					_this call XSendNetStartScriptClientAll; // to all clients
				};
				default { player groupChat format["--- XHandleNetStartScriptServer: command '%1', unknown sub-command '%1'", _this select 0,_this select 0]};
			};
		};
#endif
		//
		// remote execute command sent as string to the server
		// call as:		["remote_execute", format["%1 setPos %2", _reveal_name, getPos _nearest]] call XSendNetStartScriptServer;
		//
		case "remote_execute" : {
			hint localize format["+++ x_netinitserver.sqf ""remote_execute"": ""%1""", _this select 1 ];
			call (compile (_this select 1));
		};

//========================================================================================================== END OF CASES

        default {
            hint localize format["--- x_netinitserver.sqf: unknown command detected: %1", _this];
        };
	}; // switch (_this select 0) do
}; // XHandleNetStartScriptServer = {
 
"d_ns_serv" addPublicVariableEventHandler {
	(_this select 1) spawn XHandleNetStartScriptServer;
};

