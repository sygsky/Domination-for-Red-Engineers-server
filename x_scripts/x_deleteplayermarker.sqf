// by Xeno
private ["_marker"];

if (d_show_player_marker > 0) then {
	switch (d_show_player_marker) do {
		case 1: {"Маркеры игроков с именем" call XfGlobalChat;};
		case 2: {"Только маркеры игроков" call XfGlobalChat;};
		case 3: {"Маркеры игроков с ролью" call XfGlobalChat;};
		case 4: {"Маркеры игроков с отображением состояния здоровья" call XfGlobalChat;};
	};
};

if (d_show_player_marker == 0) then {
	"Убираем маркеры игроков..." call XfGlobalChat;
	sleep 2.123;
	for "_i" from 1 to 8 do {
		call compile format ["
			_marker = ""alpha_%1"";
			_marker setMarkerPosLocal [0,0];
			_marker setMarkerTextLocal """";
		", _i];
	};

	for "_i" from 1 to 8 do {
		call compile format ["
			_marker = ""bravo_%1"";
			_marker setMarkerPosLocal [0,0];
			_marker setMarkerTextLocal """";
		", _i];
	};

	for "_i" from 1 to 8 do {
		call compile format ["
			_marker = ""charlie_%1"";
			_marker setMarkerPosLocal [0,0];
			_marker setMarkerTextLocal """";
		", _i];
	};

	for "_i" from 1 to 4 do {
		call compile format ["
			_marker = ""delta_%1"";
			_marker setMarkerPosLocal [0,0];
			_marker setMarkerTextLocal """";
		", _i];
	};

	for "_i" from 1 to 4 do {
		call compile format ["
			_marker = ""charlie_%1"";
			_marker setMarkerPosLocal [0,0];
			_marker setMarkerTextLocal """";
		", _i];
	};

	_marker = "RESCUE";
	_marker setMarkerPosLocal [0,0];
	_marker setMarkerTextLocal "";
	_marker = "RESCUE2";
	_marker setMarkerPosLocal [0,0];
	_marker setMarkerTextLocal "";
	"Маркеры игроков отключены" call XfGlobalChat;
};

if (true) exitWith {};
