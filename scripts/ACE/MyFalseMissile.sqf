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
		if ( isNull _shooter ) then { "<null>"} else { format[ "dead(%1)", typeOf _shooter ] }
	];
};

_name = if (isNull _target) then { "<null>" } else {
	_crew = crew _target;
	if (count _crew > 0) then {
		name (_crew select 0)
	} else {
	 	"<null>"
	};
};
hint localize format[ "+++ MyFalseMissile.sqf: shooter %1, missile %2, parachute %3 is worn by player ""%4"", skip it now, TODO in future...",
	typeOf _shooter,
	_type,
	typeOf _target,
	_name
];

// Restore lost missiles for vehicle/AI unit
if (_shooter isKindOf "CAManBase") exitWith {
	_stingerAmmo = -1;
	_mags0 = [];
	if (_shooter hasWeapon "ACE_FIM92A") then {
		_stingerAmmo = _shooter ammo "ACE_FIM92A";
		_mags0 = magazines _shooter;

        _shooter removeWeapon "ACE_FIM92A";
        _shooter addMagazine "ACE_Stinger";
        _shooter addWeapon "ACE_FIM92A"; // this reloads Stringer for an AA soldier
		_mags1= magazines _shooter;

        hint localize format["+++ MyFalseMissile.sqf: restore ammo for %3:", typeOf _shooter];
        hint localize format["+++ MyFalseMissile.sqf: initial %1", _mags0 call SYG_compactArray];
        hint localize format["+++ MyFalseMissile.sqf: result  %1", _mags1 call SYG_compactArray];
	} else {
	    hint localize format["--- MyFalseMissile.sqf: shooter %1(%2) has no Stinger launcher ""ACE_FIM92A"", skip reload", _name, typeOf _shooter];
	};
};

if (_shooter isKindOf "ACE_M6A1") exitWith { // Linebacker reloading is tested correctly
	// replace exhaused  magazines and reload launcher by default
	_cnt =[_shooter,"ACE_M6_Stinger_Launcher", "ACE_M6_FIM92"] call SYG_reloadAmmo; // Stinger ammo type is "ACE_FIM92round" and is not used here
	hint localize format["+++ MyFalseMissile.sqf: replace %1 mags (ACE_M6_FIM92) for ACE_M6A1", _cnt];
};

if (_shooter isKindOf "Stinger_Pod") exitWIth {  // TODO: need test all weapon/mags names
	_cnt = {_x isKindOf "2Rnd_Stinger"} count (weapons _shooter);
	if (_cnt < 10) then {
		// restore 1..10 rounds for Stinger pod
		for "_i" from _cnt to 9 do { _shooter addMagazine "2Rnd_Stinger"; };
		hint localize format["+++ MyFalseMissile.sqf: restore %1 2Rnd_Stinger for Stinger_Pod", 10 - _cnt];
	};
};
