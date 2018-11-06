// deathSound.sqf, called when player respawn on client side to play fun music
/*
	author: Sygsky
	description: spawn this file to play some short music while you are laying dead
	returns: nothing
*/

#include "x_setup.sqf"

_killer = _this select 1;
_unit = _this select 0; // player

//hint localize format["+++ open.sqf runs for killed %1 and killer %2 +++", name _unit, name _killer];

if (!(local _unit)) exitWith {hint localize format["--- scripts/deathSound.sqf, params not allow to play sound (!local): %1", _this]};
if (!(isPlayer _unit)) exitWith {hint localize format["--- scripts/deathSound.sqf, params not allow to play sound(!isPlayer): %1", _this]};
if ( _unit != _killer) then // KIA
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
else    // some kind of suicide? Say something about...
{
    // short melody on unknown death case, anybody within some range can hear this
    _sound = "male_scream_0"; // default value
    // check if a woman is killed
    if (typeOf _unit == "ACE_SoldierEMedicWoman_VDV")
    then { _sound = "female_shout_of_pain_" + str(ceil (random 4)); } // 1-4
    else
    {
#ifdef __ACE__
// play 15 sounds from ACE collection for hard screams
    _sound = format["ACE_BrutalScream%1", ceil(random 15)]; // 1-15

    hint localize format["ACE sound is %1", _sound];
#else
    _sound = "male_scream_" + str(floor(random 6)); // 0-5
#endif
    };

    // hint localize format["+++ open.sqf _sound %1, player %2", _sound, player];
    _nil = "Logic" createVehicle position player;
    sleep 0.01;
    // let all to hear this sound, not only current player
    ["say_sound", _nil, _sound] call XSendNetStartScriptClientAll;
    sleep 20; // sleep longer than known max sound length is possible
    deleteVehicle _nil;

};
