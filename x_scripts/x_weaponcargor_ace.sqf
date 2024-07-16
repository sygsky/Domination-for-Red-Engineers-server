// by Xeno, x_scripts\x_weaponcargor_ace.sqf
// called only for __ACE__ + __RANKED__ defined version

if ( (_this select 0) isKindOf "AmmoBoxWest" ) then {
    _this execVM "x_scripts\x_weaponcargor_west_ace.sqf";
} else { // Default is the east!!!
    _this execVM "x_scripts\x_weaponcargor_east_ace.sqf";
};

hint localize format["+++ x_scripts\x_weaponcargor_ace.sqf: _this = %1", _this];
if (true) exitWith {};
