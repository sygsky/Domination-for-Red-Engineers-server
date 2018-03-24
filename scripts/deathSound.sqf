// deathSound.sqf, called on player respawn on client side to play fun music
/*
	author: Sygsky
	description: spawn this file to play some short music while you are laying dead
	returns: nothing
*/
_killer = _this select 1;
_unit = _this select 0; // player

//hint localize format["+++ open.sqf runs for killed %1 and killer %2 +++", name _unit, name _killer];

if (!(local _unit)) exitWith {};
if (!(isPlayer _unit)) exitWith {};
if ( _unit != _killer) then
{
    if ( (vehicle _killer) isKindOf "Helicopter" && (format["%1",side _killer] == d_enemy_side) ) then
    {
        playSound "helicopter_fly_over"; // play sound of heli fly over your poor remnants
    }
    else
    {
        _unit call SYG_playRandomDefeatTrackByPos; // some music for poor dead man
    };
}
else
{
    // short melody on unknown case
    // check if woman is killed
    if (typeOf _unit == "ACE_SoldierEMedicWoman_VDV")
    then { }
    else { playSound "huh1" };
};
