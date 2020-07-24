private ["_chars","_i","_line","_out_chars","_pre_spaces","_string"];

_pre_spaces = _this select 0;
_string = _this select 1;
_line = _this select 2;

_chars = toArray (_string);

_out_chars = [];

for "_i" from 1 to _pre_spaces do {
	_out_chars set [ count _out_chars, " " ];
};

for "_i" from 0 to ( ( count _chars ) - 1 ) do {
	_out_chars set [ count _out_chars, toString [ ( _chars select _i ) ] ];
};

if (count _out_chars < 30) then {
	for "_i" from ( ( count _out_chars ) + 1 ) to 30 do {
		_out_chars set [ count _out_chars, " "];
	};
};

[_out_chars, _line] execVM "IntroAnim\animateLetters.sqf";

if (true) exitWith {};