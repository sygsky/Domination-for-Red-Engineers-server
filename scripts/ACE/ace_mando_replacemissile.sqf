/*
mando_replacemissile.sqf v2.35B
December 2008 Mandoble

DO NOT EXECUTE THIS SCRIPT MANUALLY

You may add here more missile types to be replaced by mando ones, as well as change the parameters of already replaced ArmA missile types.

+++ 10-JUN-2019, Sygsky: code is compacted and flight distance increased for Javelins and Stingers
+++ 14-SEP-2019, Sygsky: added reveal shooter procedure
+++ 09-JAN-2023, Sygsky: prevent missile targeting to the parachutes with any man in

*/

private [
        "_target", "_type", "_shooter", "_missile", "_vel", "_dir", "_up", "_launcher", "_missilebody", 
        "_speedini","_speedmax","_acceleration","_boomrange","_activerange","_modeinit","_cruisealt",
        "_boomscript","_smokescript","_soundrsc","_sounddur","_endurance",
        "_terrainavoidance","_updatefreq","_delayinit", "_controltime",
        "_detectable","_debug","_launchscript","_hagility","_vagility",
        "_accuracy","_intercept", "_scanarch","_scanarcv","_posfire","_vdir","_dir","_vangle","_replaced", "_mode",
        "_ra","_dropped"
        ];

_makeNameShooter = {
    _shooter call _makeNameObject
};

_makeNameTarget = {
    _target call _makeNameObject
};

_makeNameObject = {
    private ["_name"];
    _name = "<obj>"; // default value
    if ( _this isKindOf "CAManBase" ) exitWith {
        if ( isPlayer _this) then {_name = name _this }
        else { _name = typeOf _this; };
        _name
    };

    _name = typeOf _this;
    if ( (count crew _this) == 1) then {
        if ( isPlayer((crew _this) select 0) ) then {_name = format["%1(%2)",name ((crew _this) select 0), _name]};
    } else {
        if (isPlayer (effectiveCommander _this)) then {_name = format["%1(%2)",name (effectiveCommander _this), _name] };
    };
    _name
};

_rocketJavelin  =
[          // M_Javelin_AT
    0,     // 0:? // Launcher, unit that fires the missile
    0,     // 1: _missilebody   =  _type;
    0,     // 2:_speedini      =  (speed _missile)/3.6;
    250,   // 3:speedmax
    100,   // 4:acceleration
    0,     // 5:boomrange
    280,   // 6:activerange
    0,     // 7:modeinit
    100,   // 8:cruisealt
    "s\warheads\ace_mando_warhead_javelin.sqf", // 9: boomscript
    "",    // 10: smokescript
    "",    // 11: soundrsc
    29,    // 12: sounddur
    16,    // 13: 8,     // endurance 14th
    false, // 14:9 terrainavoidance
    1,     // 15:10 updatefreq - delay before engine is switched on
    0,     // 16: delayinit
    0,     // 17:controltime
    false, // 18:detectable
    false, // 19:debug
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
    _this set [6,  ((_target distance _shooter) - 60) max 500]; // activerange:  TODO may be replace max with min to allow work on dist <= 500 m?
};

_rocketStinger =
[
     0, //0
     0, //1
     2, //2
     680, //3: maxspeed
     175, //4: acceleration
     3, //5: boomrange
     7000, //6: activerange
     2,
     50,
     "s\warheads\ace_mando_warhead_stinger.sqf", // 9
     "",//mando_missile_path+"exhausts\mando_missilesmoke1a.sqf";
     "",
     29,
     20, //13: // endurace!! Most important parameter
     false,
     999,//15:Time between creating the missile and switching on its engine in seconds (the missile will be in free fall during this period)
     0, //16: init delay before giudance is switched on
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
     } else {
        _this set [9, mando_missile_path + (_this select 9)]; // boomscript
     };
     // TODO: disable guidance if target on land and has engine off #342
};

_rocketStrela =
[
     0,
     0,
     2,
     680,
     175,
     3,
     5000,
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
     // disable guidance if target has engine off and shooter is player #342
     if ( (isPlayer _shooter) && (! isEngineOn _target)) then {
        _this set [ 15, 10 ]; // drop any processing during first 10 seconds
        _dropped = true;
     };
};

_rocketDefault = [
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
	_rocketJavelin,       _rocketJavelin,
    _rocketStinger,       _rocketStinger, _rocketStinger,
    _rocketStrela,       _rocketStrela
    ];

_target   = _this select 0;	// To whom missile is launhed
_type     = _this select 1;	// Missile type (STRING)
_shooter  = _this select 2;	// Who launched missile
_replaced = false;
_local    = false;
_ind      = -1;

//hint localize format["+++ ACE_MANDO_REPLACE_MISSILE: %1", _this];

if ( local _shooter ) then {
// hint format["M:%1", _this];
    _missile = nearestObject [_shooter, _type];
    _local = true;
    sleep 0.4;
    _posfire = _shooter worldToModel (getPos _missile);
    _vdir = vectorDir _missile;
    _dir = (_vdir select 0) atan2 (_vdir select 1);
    _ind = _rocketNamesArr find _type;
    if (_ind >= 0) then {
        _replaced = true;
        _dropped  = false;
        _ra       = _rocketParamsArr select _ind;
        switch (_ind) do {
            case 0;
            case 1: {
                _mode = _shooter getVariable "mando_javelin_mode";
                if (isNil "_mode") then { _mode = 0; };
                // hint localize format["+++ MANDO Javelin mode %1", _mode];
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
    } else {
        if (!mando_replace_all_missiles) exitWith {_replaced = false;};
        _replaced = true;
        _ra = _rocketDefault;
   };
};
//      hint format["M:%1 %2", _this, _missile];
if (!_replaced) exitWith {
    _target reveal _shooter;
    _name  =  call _makeNameShooter;
    _name1 =  call _makeNameTarget;

    hint localize format["+++ MANDO Missile not replaced (local %1, id %2): from %3.%4(s. %5) -> %6, dmg %7, dst %8 m., h %9, spd %10, near %11, exit",
    	_local,
    	_ind,
        _name,
        _type,
        round(speed _shooter),
        _name1,
        (round((damage _target)*100))/100,
        round(_target distance _shooter), // distance from the shooter to the target
        round((getPos _target) select 2), // height
        round(speed _target),
        text( _target call SYG_nearestLocation)]; // distance from target to location
};

_missile setPos [ 0,0,(getPos _missile select 2) + 5000];
deleteVehicle _missile;

//#ifdef __FUTURE__
// Prevent attacking parachutes as they are not damageable
if (_target call SYG_isParachute) exitWith { _this execVM "scripts\ACE\MyFalseMissile.sqf"}; // restore missile in shooter inventory
//#endif

//[_launcher, _missilebody, _posfire, _dir, _vangle, _speedini, _speedmax, _acceleration, _target, _boomrange, _activerange, _modeinit, _cruisealt, _boomscript, _smokescript, _soundrsc, _sounddur, _endurance, _terrainavoidance, _updatefreq, _delayinit, _controltime, _detectable, _debug, _launchscript, _hagility, _vagility, _accuracy, _intercept, _scanarch, _scanarcv] call mando_missile_handler;
_arr = [
_ra select 0,
_ra select 1, 
_posfire,       // 2
_dir,           // 3
_ra select 27,  // 4
_ra select 2,
_ra select 3,
_ra select 4,
_target,
_ra select 5,
_ra select 6, //10
_ra select 7,
_ra select 8,
_ra select 9,
_ra select 10,
_ra select 11, //15
_ra select 12,
_ra select 13,
_ra select 14,
_ra select 15, // 19
_ra select 16, //20
_ra select 17,
_ra select 18,
_ra select 19,
_ra select 20,
_ra select 21, //25
_ra select 22,
_ra select 23,
_ra select 24,
_ra select 25,
_ra select 26 //30
];

_target reveal _shooter;

_name  = call _makeNameShooter;
_name1 = call _makeNameTarget;
_arr call mando_missile_handler; // variable in ACE code
//2020/04/04, 16:33:28 +++ MANDO Missile: from ACE_SoldierWAA.ACE_Missile_Stinger spd 0 m/s -> Виталий(ACE_Mi17_MG) dmg 0.01, h 12 d 88 spd 255 m/s, near Gulan
hint localize format[ "+++ MANDO Missile: from %1.%2, spd %3 km/h -> %4, dmg %5, h %6, d %7, spd %8 km/h, near %9",
    _name,
    format["%1%2",_type,if((_arr select 20) > 0) then {format["/delay=%1",_arr select 20]} else {""}],
    round(((velocity _shooter ) distance [0,0,0])*3.6), // round (speed _shooter),
    _name1,  (round((damage _target)*100))/100, round((getPos _target) select 2),
    round(_target distance _shooter),
    round(((velocity _target ) distance [0,0,0])*3.6), // velocity km/h
    text( _target call SYG_nearestLocation)
    ];
