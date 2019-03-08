/*
	author: Sygsky
	description: none
	returns: nothing
*/

// [
//["NVGoggles","ACE_RPK47"],
//["ACE_Bandage","ACE_Bandage","ACE_Morphine","ACE_Morphine","ACE_75Rnd_762x39_B_AK","ACE_75Rnd_762x39_B_AK","ACE_75Rnd_762x39_B_AK","ACE_75Rnd_762x39_B_AK","ACE_75Rnd_762x39_B_AK","ACE_75Rnd_762x39_B_AK","ACE_Bandage","ACE_Morphine","ACE_Morphine","ACE_Epinephrine"],
//"ACE_Rucksack_MOLLE_Green_Miner",
//[],
//3000]
_p = _this;

removeAllWeapons _p;
// add magazines first to reload weapon later
{
    _p addMagazine _x;
} forEach ["ACE_Bandage","ACE_Bandage","ACE_Morphine","ACE_Morphine","ACE_75Rnd_762x39_B_AK","ACE_75Rnd_762x39_B_AK","ACE_75Rnd_762x39_B_AK","ACE_75Rnd_762x39_B_AK","ACE_75Rnd_762x39_B_AK","ACE_75Rnd_762x39_B_AK","ACE_Bandage","ACE_Morphine","ACE_Morphine","ACE_Epinephrine"];

// add all weapons
_wpn = "ACE_RPK47";
{
    _p addWeapon _x;
} forEach ["NVGoggles",_wpn];

// select weapon and reload it
_p selectWeapon _wpn;
_muzzles = getArray( configFile >> "cfgWeapons" >> _wpn >> "muzzles" );
if ( count _muzzles > 0) then
{
    _p selectWeapon ( _muzzles select 0 );
};

// fill backpak
_p setVariable ["ACE_weapononback","ACE_Rucksack_MOLLE_Green_Miner"];
_p setVariable ["ACE_Ruckmagazines", []];
3000 call SYG_setViewDistance;
