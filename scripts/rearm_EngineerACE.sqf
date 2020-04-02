/*
	author: Sygsky, scripts\rearm_EngineerACE.sqf
	description: none
	returns: nothing
*/

_p     = _this; // player itself
if (typeName _p == "ARRAY") then {_p = _p select 0}; // can be designated array [player, _rankIndex] for the future development

removeAllWeapons _p;

_wpn  = "ACE_RPK47";
_rpg  = "ACE_RPG7";
_mags =
[
    ["ACE_Bandage",3],
    ["ACE_Morphine",5],
    ["ACE_75Rnd_762x39_BT_AK",5],
    ["ACE_RPG7_PG7VL",1]
];
_magp = [["ACE_Epinephrine_PDM",1],["ACE_Bandage_PDM",3],["ACE_Morphine_PDM",5],["ACE_PipeBomb_PDM",1],["ACE_SmokeGrenade_Red_PDM",3],["ACE_RPG7_PG7VL_PDM",1]];

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

//hint localize format["+++ rearmEngineerACE.sqf: player hasWeapon %1 = %2, hasWeapon %3 = %4","NVGoggles", player hasWeapon "NVGoggles","Binocular", player hasWeapon "Binocular"];
