// юнит идет за оружием
//[unit] execVM "take_weapondead.sqf";


_unit=_this select 0;

_trup=[];
_weap=[];
_mag=[];
{
if ((_x distance _unit <50)and(_x isKindOf "Man")) then {
	_trup set [count _trup, _x];
	_weap set [count _weap, (primaryWeapon _x)];
	_mag set [count _mag, (currentMagazine _x)];
	};
} forEach allDead;
_trup0 = _trup select 0;
_weap0=_weap select 0;
_mag0=_mag select 0;


_unit doMove (getPos _trup0);
waitUntil {_unit distance _trup0 < 4};
_unit doWatch (getPos _trup0);
sleep 1;

_unit action ["TakeWeapon", (_trup0),_weap0];
sleep 2;
_unit action ["TakeMagazine", (_trup0),_mag0];
sleep 2;