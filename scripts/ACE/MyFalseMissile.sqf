/*
	MyFalseMissile.sqf, to handle missile targeted to the parachute
	author: Sygsky
	description:
		handle AI lunched missile if it is targeted to the parachute.
		Lunched from "scripts\ACE\ace_mando_replacemissile.sqf", line 315
	returns: nothing
*/

_target   = _this select 0;	// Parachute targeted
_type     = _this select 1;	// Missile type (STRING)
_shooter  = _this select 2;	// Who launched missile

if (! (alive _shooter)) exitWith {
	hint localize format[ "+++ MyFalseMissile.sqf: _shooter is %1, exit",
		if ( isNull _shooter ) then { "null"} else { format[ "dead(%1)", typeOf _shooter ] }
	];
};

_name = if (isNull _target) then { "null" } else {name (driver _target)};
hint localize format[ "+++ MyFalseMissile.sqf: shooter %1, missile %2, parachute %3 is worn by player ""%4"", skip it now, TODO in future...",
	typeOf _shooter,
	_type,
	typeOf _target,
	_name
];

// Restore lost missiles for vehicle/AI unit
if (_shooter isKindOf "CAManBase") then {
	_shooter addMagazine _type;
	_shooter removeWeapon "ACE_FIM92A";
	_shooter addWeapon "ACE_FIM92A";
	hint localize format["+++ MyFalseMissile.sqf: restore 1 %1 for %2", _type, typeOf _shooter];

} else {
	// TODO: full add Stinger/etc ammo to the inventory of launchng  vehicle
	if (_shooter isKindOf "ACE_M6A1") exitWith { // Linebacker
		_cnt = {_x isKindOf "ACE_M6_FIM92"} count (weapons _shooter);
		if (_cnt < 3) then {
			// restore 1..3 rounds for Linebacker
			for "_i" from _cnt to 2 do {
				_shooter addMagazine "ACE_M6_FIM92";
			};
			hint localize format["+++ MyFalseMissile.sqf: restore %1 ACE_M6_FIM92 for ACE_M6A1", 3 - _cnt];
		};
	};

	if (_shooter isKindOf "Stinger_Pod") exitWIth {
		_cnt = {_x isKindOf "2Rnd_Stinger"} count (weapons _shooter);
		if (_cnt < 10) then {
			// restore 1..10 rounds for Stinger pod
			for "_i" from _cnt to 9 do {
				_shooter addMagazine "2Rnd_Stinger";
			};
			hint localize format["+++ MyFalseMissile.sqf: restore %1 2Rnd_Stinger for Stinger_Pod", 10 - _cnt];
		};
	};
}