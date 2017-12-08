// by Xeno, x_scripts/x_deleteplayermarker.sqf
private ["_marker"];

if (d_show_player_marker > 0) then {
	switch (d_show_player_marker) do {
		case 1: {localize "STR_SYS_1112" call XfGlobalChat;}; // "Player markers with player names available"
		case 2: {localize "STR_SYS_1113" call XfGlobalChat;}; //"Player markers only (without names) available"
		case 3: {localize "STR_SYS_1114" call XfGlobalChat;}; // "Player markers with player roles available"
		case 4: {localize "STR_SYS_1115" call XfGlobalChat;}; // "Player markers with player health available"
	};
};

if (d_show_player_marker == 0) then {
	localize "STR_SYS_1116" call XfGlobalChat; // "Hiding player markers, one moment"
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
	localize "STR_SYS_1117" call XfGlobalChat; // "Player markers hidden"
};

if (true) exitWith {};
