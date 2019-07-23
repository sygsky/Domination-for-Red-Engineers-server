/*
mando_replacemissile.sqf v2.35B
December 2008 Mandoble

DO NOT EXECUTE THIS SCRIPT MANUALLY

You may add here more missile types to be replaced by mando ones, as well as change the parameters of already replaced ArmA missile types.

+++ 10-JUN-2019, Sygsky: code is compacted and flight distance increased twice for Javelins and Stringers

*/


private [
        "_target", "_type", "_shooter", "_missile", "_vel", "_dir", "_up", "_launcher", "_missilebody", 
        "_speedini","_speedmax","_acceleration","_boomrange","_activerange","_modeinit","_cruisealt",
        "_boomscript","_smokescript","_soundrsc","_sounddur","_endurance",
        "_terrainavoidance","_updatefreq","_delayinit", "_controltime",
        "_detectable","_debug","_launchscript","_hagility","_vagility",
        "_accuracy","_intercept", "_scanarch","_scanarcv","_posfire","_vdir","_dir","_vangle","_replaced", "_mode",
        "_ra"
        ];

_rocketJavelin  =
[           // M_Javelin_AT
    0,
    0,     //_missilebody   =  _type;
    0,     //_speedini      =  (speed _missile)/3.6;
    250,   // speedmax
    100,   // acceleration
    0,     // boomrange
    280,   // activerange
    0,     // modeinit
    100,   // cruisealt
    "s\warheads\ace_mando_warhead_javelin.sqf",
    "",    // smokescript
    "",    // soundrsc
    29,    // sounddur
    16, //8,     // endurance 14th
    false, // 9 terrainavoidance
    1,     // 10 updatefreq
    0,     // delayinit
    0,     // controltime
    false, // detectable
    false, // debug
    "",    // launchscript
    30,    // hagility
    55,    // vagility
    1,     // accuracy
    false, // intercept
    35,    // scanarch
    85,    // scanarcv
    0     // vangle = asin(_vdir select 2);
];

_applyJavelin0 = {
    _this set [0,  _shooter];                             // shooter
    _this set [1, _type];                                 // missilebody
    _this set [2, (speed _missile)/3.6];                  // speedini
    _this set [9, mando_missile_path + (_this select 9)]; // boomscript
    _this set [27, asin(_vdir select 2)];                 // vangle
};

_applyJavelin1 = {
    _this call _applyParams0;
    _this set [6,  ((_target distance _shooter) - 60) max 500]; // activerange
};

_rocketStinger =
[
     0,
     0,
     2,
     680,
     175,
     3,
     3000,
     2,
     50,
     "s\warheads\ace_mando_warhead_stinger.sqf",
     "",//mando_missile_path+"exhausts\mando_missilesmoke1a.sqf";
     "",
     29,
     20, //6, // endurace!! Most important parameter
     false,
     999,
     0,
     0,
     false,
     false,
     "",
     65,
     35,
     1,
     false,
     35,
     35,
     0
];

_applyStingerParams = {
    _this set [0, _shooter];
    _this set [1, _type];
    _this set [27, asin(_vdir select 2)];                 // vangle

     //change the warhead strength to normal if Target is a LandVehicle
     _TargetISLandVehicle = _target isKindOf "LandVehicle";
     if (_TargetISLandVehicle) then {
        _this set [9,  mando_missile_path+"s\warheads\ace_mando_warhead_stinger_vs_ground.sqf"];
     }
     else
     {
        _this set [9, mando_missile_path + (_this select 9)]; // boomscript
     };
};

_rocketStrela =
[
     0,
     0,
     2,
     680,
     175,
     3,
     3000,
     2,
     50,
     "s\warheads\ace_mando_warhead_strela.sqf",
     "",//mando_missile_path+"exhausts\mando_missilesmoke1a.sqf";
     "",
     29,
     6,
     false,
     999,
     0,
     0,
     false,
     false,
     "",
     65,
     35,
     1,
     false,
     35,
     35,
     0
];

_applyStrelaParams0 = {
    _this call _applyStrelaParams1;
    _this set [4, 275]; // not sure that it is not author mistake
};

_applyStrelaParams1 = {
    _this set [0, _shooter];
    _this set [1, _type];
    _this set [27, asin(_vdir select 2)];                 // vangle

     //change the warhead strength to normal if Target is a LandVehicle
     _TargetISLandVehicle = _target isKindOf "LandVehicle";
     if (_TargetISLandVehicle) then {
        _this set [9, mando_missile_path+"s\warheads\ace_mando_warhead_strela_vs_ground.sqf"];
     }
     else
     {
        _this set [9, mando_missile_path + (_this select 9)]; // boomscript
     };
};

_rocketDefault =
[
     0,
     0,
     250,
     680,
     250,
     1,
     5000,
     2,
     50,
     "s\warheads\mando_missilehead1a.sqf",
     "",//mando_missile_path+"exhausts\mando_missilesmoke1a.sqf";
     "",
     29,
     10,
     false,
     999,
     0.5,
     0.2,
     false,
     false,
     "",
     45,
     35,
     1,
     false,
     65,
     65,
     0
];

_rocketNamesArr  = [
    "M_Javelin_AT", "ACE_Missile_Javelin",
    "M_Stinger_AA", "ACE_Missile_Stinger", "ACE_FIM92round",
     "M_Strela_AA",  "ACE_Missile_Strela"
    ];
_rocketParamsArr = [
    _rocketJavelin, _rocketJavelin,
    _rocketStinger, _rocketStinger, _rocketStinger,
    _rocketStrela,  _rocketStrela
    ];

_target  = _this select 0;
_type    = _this select 1;
_shooter = _this select 2;
_replaced = false;

//hint localize format["+++ ACE_MANDO_REPLACE_MISSILE: %1", _this];

if ( local _shooter ) then
{
// hint format["M:%1", _this];
    _missile = nearestObject [_shooter, _type];
    sleep 0.4;
    _posfire = _shooter worldToModel (getPos _missile);
    _vdir = vectorDir _missile;
    _dir = (_vdir select 0) atan2 (_vdir select 1);
    _ind = _rocketNamesArr find _type;
    if (_ind >= 0) then
    {
        _replaced = true;
        _ra = _rocketParamsArr select _ind;
        switch (_ind) do {
            case 0;
            case 1: {
                _mode = _shooter getVariable "mando_javelin_mode";
                if (isNil "_mode") then { _mode = 0; };
                hint localize format["+++ MANDO Javelin mode %1", _mode];
                if (_mode == 0) then {_ra call _applyJavelin0;}
                else {_ra call _applyJavelin1;};
            };
            case 2;
            case 3;
            case 4: {
                _ra call _applyStingerParams;
            };
            case 5: {
                _ra call _applyStrelaParams0;
            };
            case 6: {
                _ra call _applyStrelaParams1;
            };
        };
    }
   else
   {
        if (!mando_replace_all_missiles) exitWith {_replaced = false;};
        _replaced = true;
        _ra = _rocketDefault;
   };
};
//      hint format["M:%1 %2", _this, _missile];
if (!_replaced) exitWith {
    hint localize format["+++ MANDO Missile not replaced: from %1, %2 -> %3(dmg %4) (dst %5 vm.), near %6, exit",
        name _shooter, _type, typeOf _target, (round((damage _target)*100))/100, round(_target distance _shooter), text( _target call SYG_nearestLocation)];
};

_missile SetPos [ 0,0,(getPos _missile select 2) + 5000];
deleteVehicle _missile;

//[_launcher, _missilebody, _posfire, _dir, _vangle, _speedini, _speedmax, _acceleration, _target, _boomrange, _activerange, _modeinit, _cruisealt, _boomscript, _smokescript, _soundrsc, _sounddur, _endurance, _terrainavoidance, _updatefreq, _delayinit, _controltime, _detectable, _debug, _launchscript, _hagility, _vagility, _accuracy, _intercept, _scanarch, _scanarcv] call mando_missile_handler;
_arr = [
_ra select 0,
_ra select 1, 
_posfire,
_dir,
_ra select 27,
_ra select 2,
_ra select 3,
_ra select 4,
_target,
_ra select 5,
_ra select 6,
_ra select 7,
_ra select 8,
_ra select 9,
_ra select 10,
_ra select 11,
_ra select 12,
_ra select 13,
_ra select 14,
_ra select 15,
_ra select 16,
_ra select 17,
_ra select 18,
_ra select 19,
_ra select 20,
_ra select 21,
_ra select 22,
_ra select 23,
_ra select 24,
_ra select 25,
_ra select 26
];
hint localize format[ "+++ MANDO Missile: from %1, %2 -> %3 dmg %4, h %5 d %6, near %7",
    name _shooter, _type, typeOf _target,  (round((damage _target)*100))/100, round((getPos _target) select 2), round(_target distance _shooter),
    text( _target call SYG_nearestLocation)
    ];
_arr call mando_missile_handler;