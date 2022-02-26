/*
	1.Sara/scripts/bonuses/x_netinit.sqf
	author: Sygsky
	description: none
	returns: nothing
*/

XSendNetStartScriptClient = {
	_this call XHandleNetStartScriptClient; // sent to all clients except issuer if issued not from server
};

// To ensure all clients receive this message
XSendNetStartScriptClientAll = XSendNetStartScriptClient;

XHandleNetStartScriptClient = {
	_this spawn {

		switch (_this select 0) do {

			// adds vehicle to the markered list of players
			case "bonus" : { // [ "bonus", _sub_command, _player_name, _vehicle ]
				if ( ! ( (_this select 2) in [""," ","*",name player]) ) exitWith {};
				private ["_veh"];
				_veh = _this select 3;
				switch (_this select 1) do {
					// send vehicle to players to control and re-draw its marker every few seconds
					case "ADD": {
						client_bonus_markers_array set [ count client_bonus_markers_array, _veh ];    // add next vehcile to the place of the timestamp
						client_bonus_markers_timestamp = time;		 // set new timestamp
						(localize "STR_BONUS_1") hintC [
							format [localize "STR_BONUS_1_1", _this select 2, typeOf _veh ],
							format[localize "STR_BONUS_1_2", typeOf _veh],
							format[localize "STR_BONUS_1_3", typeOf _veh, localize "STR_CHECK_ITEM"]
							];

						//  send info to all players except author
						hint localize format["+++ client: bonus ADD %1 to the markers list", typeOf _veh];
	//                    ["msg_to_user",["-", name player],[["'%1' обнаружил %2", _this select 2, typeOf _veh]],0,0,"good_news"] call XHandleNetStartScriptClient;
					};

					// send vehicle to players to remove from re-draw list as vehicle now is recoverable
					case "REG": { // register vehicle as recoverable
						private ["_id"];
						_id = _veh getVariable "INSPECT_ACTION_ID";
						if (!isNil "_id") then {
							_veh removeAction _id;
							_veh setVariable ["INSPECT_ACTION_ID", nil];
						} else {hint localize format["--- bonus.REG: %1 hasnt variable INSPECT_ACTION_ID!!!", typeOf _veh]};

						// remove from markered vehs list
						[client_bonus_markers_array, _veh] call SYG_removeObjectFromArray;
						client_bonus_markers_timestamp = time;		 // set new timestamp
						// register as recoverable vehicle
						// ["msg_to_user",_player_name,[_msg1, ... _msgN]<,_delay_between_messages<,_initial_delay<,_sound>>>]
						localize "STR_BONUS_3_1" hintC [
							format [localize "STR_BONUS_3_2", typeOf _veh,  _this select 2 ],
							localize "STR_BONUS_3_3"
							];
						  //0              1,                  2,                                                          3, 4, 5
	//                    [ "msg_to_user", ["-", name player], [["'%1' зарегистрировал %2", _this select 2, typeOf _veh]], 0, 0, "good_news" ] call XHandleNetStartScriptClient;
					};

					// bonus vehicle killed event
					//  [ "bonus", _sub_command, _killer, _vehicle ]
					case "DEL" : {
						private ["_killer","_name"];
						[client_bonus_markers_array, _veh] call SYG_removeObjectFromArray;
						client_bonus_markers_timestamp = time;		 // set new timestamp
						_killer = _this select 2;
						_name = if (isPlayer _killer) then {name _killer} else {localize "STR_BONUS_DEL_1"};
						["msg_to_user", "", [[ localize "STR_BONUS_DEL", typeOf _veh, _name]], 0, 2, "losing_patience"] call XHandleNetStartScriptClient;
					};

					// init bonus vehicle event
					//  [ "bonus", "INIT", _name, _veh_arr ]
					case "INIT" : {
						client_bonus_markers_array = _this select 3; // known markered bonus vehicles array
						client_bonus_markers_timestamp = time;		 // set new timestamp
					};

				};
			};

			// simples realization of msg_to_user
			// ["msg_to_user",_player_name,[_msg1, ... _msgN]<,_delay_between_messages<,_initial_delay<,_sound>>>]
			case "msg_to_user" : {
					private ["_x"];
					hint localize format["+++ msg_to_user: %1", _this];
					if (count _this > 4) then {sleep (_this select 4)};
					{
						_str = format _x;
						player groupChat _str;
						if (count _this > 3) then {sleep (_this select 3)};
					} forEach (_this select 2);
			};

			default {};
		};
	};
};

XSendNetStartScriptClientAll = { _this call XHandleNetStartScriptServer};

//
// call as: [] call XHandleNetStartScriptServer
//
XHandleNetStartScriptServer = {
	_this spawn {

		switch (_this select 0) do {

			// remove vehicle from markered list of bonus vehicles
			case "bonus" : { // [ "bonus", _sub_command, _player_name, _vehicle ]
				private ["_veh"];
				_veh = _this select 3;

				switch (_this select 1) do {
					// vehicle is sent to any player to draw and control marker on it
					case "ADD": {
						// add to the list of markered vehicles
						if (!(_veh in server_bonus_markers_array)) then {
							_veh setVariable ["RECOVERABLE", false]; // mark vehicle as inspected, marked and not recoverable
							// store vehicle to send list to the new player on connection.
							// It is the only task for this list
							server_bonus_markers_array set [count server_bonus_markers_array, _veh];
							// TODO: send info to all clients
							hint localize format["+++ server: bonus ADD %1 to all clients", typeOf _veh];
							_this call XSendNetStartScriptClientAll; // to all clients
						};
					};

					// register vehicle as RECOVERABLE from now
					case "REG": {
						clearVehicleInit _veh;
						_veh setVariable ["RECOVERABLE", true]; // allow to restore vehicle
						_veh call SYG_removeVehicleHitDamKilEvents;
						_veh call SYG_assignVehAsBonusOne;
						if (_veh in server_bonus_markers_array) then {
							// remove vehicle from the markered list
							[server_bonus_markers_array, _veh] call SYG_removeObjectFromArray;
						};
						hint localize format["+++ server: bonus REG %1 to all clients", typeOf _veh];
						_this call XSendNetStartScriptClientAll; // to all clients
					};

					default { player groupChat format["--- XHandleNetStartScriptServer: command '%1', unknown sub-command '%1'", _this select 0,_this select 0]};
				};
			};

			default { player groupChat format["--- XHandleNetStartScriptServer: unknown command '%1'", _this select 0]};
		};
	};
};

XSendNetStartScriptServer = {_this call XHandleNetStartScriptServer};

hint localize format["+++ XHandleNetStartScriptServer initialized as %1", typeName XHandleNetStartScriptServer];

