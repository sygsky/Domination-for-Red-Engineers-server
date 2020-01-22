// by Xeno

// setup global chat logic
x_global_chat_logic = "Logic" createVehicleLocal [0,0,0];

// display a text message over a global logic chat
// parameters: text (without brackets)
// example: "Hello World!" call XfGlobalChat;
XfGlobalChat = {
	x_global_chat_logic globalChat _this;
};

// display a text message over side chat
// parameters: unit, text
// example: [player,"Hello World!"] call XfSideChat;
XfSideChat = {
	(_this select 0) sideChat (_this select 1);
};

// display a text message over group chat
// parameters: unit, text
// example: [player,"Hello World!"] call XfGroupChat;
XfGroupChat = {
	(_this select 0) groupChat (_this select 1);
};

// display a text message over vehicle chat
// parameters: vehicle, text
// example: [vehicle player,"Hello World!"] call XfVehicleChat;
XfVehicleChat = {
	(_this select 0) vehicleChat (_this select 1);
};

// display a text message over HQ sidechat (CROSSROAD)
// parameters: text
// example: "Hello World!" call XfHQChat;
XfHQChat = {
	[playerSide,"HQ"] sideChat _this;
};

// removes linebreaks from strings ("\n" amd "\N" replaced with space " ")
// parameters: text
// example: "My nice text\n\nHello World" call XfRemoveLineBreak;
// returns: "My nice text  Hello World"
XfRemoveLineBreak = {
	private ["_msg", "_msg_chat_a", "_i", "_c"];
	_msg = _this;
	_msg_chat_a = toArray (_msg);
	for "_i" from 0 to (count _msg_chat_a - 2) do {
		_c = _msg_chat_a select _i;
		if (_c == 92) then {
			if ((_msg_chat_a select (_i + 1)) in [78,110]) then {
				_msg_chat_a set [_i, 32];
				_i = _i + 1;
				_msg_chat_a set [_i, "(xx_rm_xx)"];
			};
		};
	};
	_msg_chat_a = _msg_chat_a - ["(xx_rm_xx)"];
	toString (_msg_chat_a)
};

// displays a hint and a chat message, \n get removed for the chat text
// parameters: text (with \n for hints), type of chat ("HQ","SIDE","GLOBAL" or "GROUP")
// example: ["My nice text\n\nHello World", "HQ"] call XHintChatMsg;
XHintChatMsg = {	
	private ["_msg", "_type_chat", "_msg_chat"];
	_msg = _this select 0;
	_type_chat = _this select 1;
	hint _msg;
	_msg_chat = _msg call XfRemoveLineBreak;
	
	_type_chat = toUpper _type_chat;
	switch (_type_chat) do {
		case "HQ": {
			_msg_chat call XfHQChat;
		};
		case "SIDE": {
			[player,_msg_chat] call XfSideChat;
		};
		case "GLOBAL": {
			_msg_chat call XfGlobalChat;
		};
		case "GROUP": {
			[player,_msg_chat] call XfGroupChat;
		};
	};
};

// handles messages  transfered over the network
XfHandleMessage = {
	private ["_msg","_receiver_type","_receiver","_type"];
	_msg = _this select 0;
	_receiver_type = toLower(_this select 1); // "unit", "grp", "all","vec"
	_receiver = toLower(_this select 2); // only needed for "unit", "grp", "vec", otherwise objNull
	_type = _this select 3; // "global", "vehicle", "side", "group", "hint", "hq"
	switch (_type) do {
		case "global": {
			switch (_receiver_type) do {
				case "unit": {
					if (!isNull _receiver) then {
						if (player == _receiver) then {
							_msg call XfGlobalChat;
						};
					};
				};
				case "grp": {
					if (!isNull _receiver) then {
						if (player in units _receiver) then {
							_msg call XfGlobalChat;
						};
					};
				};
				case "all": {
					_msg call XfGlobalChat;
				};
				case "vec": {
					if (!isNull _receiver) then {
						if (player in crew _receiver) then {
							_msg call XfGlobalChat;
						};
					};
				};
			};
		};
		case "vehicle": {
			switch (_receiver_type) do {
				case "unit": {
					if (!isNull _receiver) then {
						if (player == crew _receiver) then {
							[_receiver,_msg] call XfVehicleChat;
						};
					};
				};
				case "grp": {
					if (!isNull _receiver) then {
						if (player in crew _receiver) then {
							[_receiver,_msg] call XfVehicleChat;
						};
					};
				};
				case "vec": {
					if (!isNull _receiver) then {
						if (player in crew _receiver) then {
							[_receiver,_msg] call XfVehicleChat;
						};
					};
				};
			};
		};
		case "side": {
			switch (_receiver_type) do {
				case "unit": {
					if (!isNull _receiver) then {
						if (player == _receiver) then {
							[player,_msg] call XfSideChat;
						};
					};
				};
				case "grp": {
					if (!isNull _receiver) then {
						if (player in units _receiver) then {
							[player,_msg] call XfSideChat;
						};
					};
				};
				case "all": {
					[player,_msg] call XfSideChat;
				};
				case "vec": {
					if (!isNull _receiver) then {
						if (player in crew _receiver) then {
							[player,_msg] call XfSideChat;
						};
					};
				};
			};
		};
		case "group": {
			switch (_receiver_type) do {
				case "unit": {
					if (!isNull _receiver) then {
						if (player == _receiver) then {
							[player,_msg] call XfGroupChat;
						};
					};
				};
				case "grp": {
					if (!isNull _receiver) then {
						if (player in units _receiver) then {
							[player,_msg] call XfGroupChat;
						};
					};
				};
				case "all": {
					[player,_msg] call XfGroupChat;
				};
				case "vec": {
					if (!isNull _receiver) then {
						if (player in crew _receiver) then {
							[player,_msg] call XfGroupChat;
						};
					};
				};
			};
		};
		case "hint": {
			switch (_receiver_type) do {
				case "unit": {
					if (!isNull _receiver) then {
						if (player == _receiver) then {
							hint _msg;
						};
					};
				};
				case "grp": {
					if (!isNull _receiver) then {
						if (player in units _receiver) then {
							hint _msg;
						};
					};
				};
				case "all": {
					hint _msg;
				};
				case "vec": {
					if (!isNull _receiver) then {
						if (player in crew _receiver) then {
							hint _msg;
						};
					};
				};
			};
		};
		case "hq": {
			switch (_receiver_type) do {
				case "unit": {
					if (!isNull _receiver) then {
						if (player == _receiver) then {
							_msg call XfHQChat;
						};
					};
				};
				case "grp": {
					if (!isNull _receiver) then {
						if (player in units _receiver) then {
							_msg call XfHQChat;
						};
					};
				};
				case "all": {
					_msg call XfHQChat;
				};
				case "vec": {
					if (!isNull _receiver) then {
						if (player in crew _receiver) then {
							_msg call XfHQChat;
						};
					};
				};
			};
		};
	};
};

// headbug fix
// example: player spawn XsFixHeadbug;
XsFixHeadBug = {
	private ["_dir","_pos","_vehicle"];
	_unit = _this;

	if (vehicle _unit != _unit) exitWith {hint "Not possible in a vehicle...";};

	titleCut ["... Fixing head bug ...","black faded", 0];

	_pos = position _unit;
	_dir = direction _unit;
	_vehicle = "UAZ" createVehicleLocal _pos;
	_unit moveInCargo _vehicle;
	waitUntil {vehicle _unit != _unit};
	unassignVehicle _unit;
	_unit action ["Eject",vehicle _unit];
	waitUntil {vehicle _unit == _unit};
	deleteVehicle _vehicle;
	_unit setPos _pos;
	_unit setDir _dir;

	titleCut["", "BLACK in",2];
};
