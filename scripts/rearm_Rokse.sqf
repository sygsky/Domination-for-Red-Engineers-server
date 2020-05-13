/*
	author: Sygsky, scripts\rearm_Rokse.sqf
	description: rearm player Rokse [LT]
	returns: nothing
*/

// [
//   ["Binocular","ACE_RPG7","ACE_RPK47"],
//   ["ACE_Morphine","ACE_Morphine","ACE_Bandage","ACE_Bandage","ACE_Bandage","ACE_Morphine","ACE_Bandage","ACE_RPG7_PG7VR","ACE_RPG7_PG7VR","ACE_75Rnd_762x39_BT_AK","ACE_75Rnd_762x39_BT_AK","ACE_75Rnd_762x39_BT_AK","ACE_Morphine"],
//   "ACE_Rucksack_Alice",
//   [["ACE_RPG7_PG7VR_PDM",4]],10000,1
// ]
//hint localize "+++ I'm Rokse-e-e-e";
_p = _this;
if (typeName _p == "ARRAY") then {_p = _p select 0}; // can be designated array [player, _rankIndex] for the future development

removeAllWeapons _p;

_wpn  = "ACE_RPK47";
_rpg  = "ACE_RPG7";
_mags =
[
    ["ACE_Morphine",4],
    ["ACE_Bandage",4],
    ["ACE_Morphine"],
    ["ACE_RPG7_PG7VR",2],
    ["ACE_75Rnd_762x39_BT_AK",3]
];

_magp = [["ACE_RPG7_PG7VR_PDM",4]];

// add magazines first to reload weapon later
{
    if (typeName _x == "STRING") then { _x = [ _x, 1]; };
    _item = _x select 0;
    _cnt = _x select 1;
    for "_i" from 1 to _cnt do { _p addMagazine _item; };
} forEach _mags;

// add all weapons
_weapons = [ _rpg, _wpn, "Binocular" ];
if ( (daytime < SYG_startMorning) || (daytime > (SYG_startNight - 3)) ) then { _weapons = _weapons + ["NVGoggles"]};

{
    _p addWeapon _x;
} forEach _weapons; // "Binocular","NVGoggles" may be added automatically in x_setupplayer.sqf

// select weapon and reload it
_p selectWeapon _wpn;

_muzzles = getArray( configFile >> "cfgWeapons" >> _wpn >> "muzzles" );

if ( count _muzzles > 0) then { _p selectWeapon ( _muzzles select 0 ); };

// fill backpak
_p setVariable ["ACE_weapononback","ACE_Rucksack_Alice"];
_p setVariable ["ACE_Ruckmagazines", _magp];
