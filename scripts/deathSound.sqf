// deathSound.sqf, called when player respawn on client side to play fun music
/*
	author: Sygsky
	description: spawn this file to play some short music while you are laying dead
	returns: nothing
*/

#include "x_setup.sqf"

#define RANDOM_ARR_ITEM(ARR) (ARR select(floor(random(count ARR))))

_killer = _this select 1;
_unit = _this select 0; // player

//hint localize format["+++ open.sqf runs for killed %1 and killer %2 +++", name _unit, name _killer];

if (!(local _unit)) exitWith {hint localize format["--- scripts/deathSound.sqf, params not allow to play sound (!local): %1", _this]};
if (!(isPlayer _unit)) exitWith {hint localize format["--- scripts/deathSound.sqf, params not allow to play sound(!isPlayer): %1", _this]};
if ( _unit != _killer) then // KIA
{
    if ( (vehicle _killer) isKindOf "Helicopter" && (format["%1",side _killer] == d_enemy_side) ) exitWith
    {
        playSound "helicopter_fly_over"; // play sound of heli fly over your poor remnants
    };
    _unit call SYG_playRandomDefeatTrackByPos; // some music for poor dead man
}
else    // some kind of suicide? Say something about...
{
    // check if you are near church etc
    _churchArr = nearestObjects [ getPos _unit, SYG_religious_buildings, 50];
    if ( (count _churchArr > 0) && ((random 9) > 1)) exitWith
    {
        // let all to hear this sound, not only current player
        ["say_sound", _churchArr select 0, RANDOM_ARR_ITEM(SYG_liturgyDefeatTracks)] call XSendNetStartScriptClientAll;
    };

    // short melody on unknown death case, anybody within some range can hear this
    _sound = "male_scream_0"; // default value
    // check if a woman is killed
    if (typeOf _unit == "ACE_SoldierEMedicWoman_VDV")
    then { _sound = "female_shout_of_pain_" + str(ceil (random 4)); } // 1-4
    else
    {
#undef __ACE__ // test new screams
#ifdef __ACE__
        // play 15 sounds from ACE collection for hard screams
        _sound = format["ACE_BrutalScream%1", ceil(random 15)]; // 1-15
//        hint localize format["ACE sound is %1", _sound];
#else
        if (isNil "SYG_selfKillingSound") then {SYG_selfKillingSound = "male_scream_" + str(floor(random 7))};  // 0-6
        _sound = SYG_selfKillingSound;
#endif
    };

    // let all to hear this sound, not only current player
    ["say_sound", _unit, _sound] call XSendNetStartScriptClientAll;

};
