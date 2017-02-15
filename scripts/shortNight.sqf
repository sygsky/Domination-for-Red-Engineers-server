// Created by Dupa, modified by Sygsky
// syntax: _temp = [nightStart, nightEnd, nightSpan, twilightDuration] execVM shortNight.sqf
// nightStart MUST BE GREATER than nightEnd e.g. [21,6,2].
// Values such as [1,6,2] will lead to unexpected behavior.
// run on server and client simultaneously
//
// Parameters:
// nightStart : used designated night period start in hours, e.g. 19.5 stand for 19:30
// nightEnd : used designated night period end, e.g. 3.5 stands for 03:30
// nightSpan : wanted night duration in real hours. E.g. 0.5 means 30 minutes for whole night length
// twilightDuration: optional (default 0) value for smoothed shift period before and after night (sun rise and sun down)
// e.g. 0.5 means that real life twilight would be 0.5 hour long, in virtual time of short night it will be 0.5/speed_of_night
//
// [SYG_shortNightStart, SYG_shortNightEnd, SYG_nightDuration, SYG_twilightDuration] execVM "scripts\shortNight.sqf";

//
#define STAT_NIGHT 0
#define STAT_DAY 1
#define STAT_MORNING 2
#define STAT_EVENING 3
#define TIME_STATE (daytime call _dayPeriod)

#define STD_SLEEP_DURATION 60
#define TWILIGHT_SMOOTH_FACTOR 10
#define TWILIGHT_SLEEP_DURATION (STD_SLEEP_DURATION/TWILIGHT_SMOOTH_FACTOR)
#define STD_SUBTRACTION (STD_SLEEP_DURATION / STD_SLEEP_DURATION)
#define TWILIGHT_SUBTRACTION (TWILIGHT_SLEEP_DURATION / STD_SLEEP_DURATION)

/*
SYG_shortNightStart  = 19.75;
SYG_eveningStart     = 18.30;
SYG_shortNightEnd    = 4.6;
SYG_morningEnd       = 7.0;
SYG_nightDuration    = 0.5;
SYG_twilightDuration = 0.5;
SYG_nightLength      = (24 - SYG_shortNightStart) + SYG_shortNightEnd;
SYG_nightSpeed       = SYG_nightLength/SYG_nightDuration;
*/

// returns 0 - for night, 1- for day, 2 - for morning, 3 - for evening
_dayPeriod = {
    if (_this < (SYG_shortNightEnd - SYG_twilightDuration)) exitWith {STAT_NIGHT};
    if (_this < (SYG_morningEnd)) exitWith {STAT_MORNING};
    if (_this < (SYG_eveningStart)) exitWith {STAT_DAY};
    if (_this < (SYG_shortNightStart + SYG_twilightDuration)) exitWith {STAT_EVENING};
    STAT_NIGHT
};

private ["_nightStart", "_nightEnd", "_accFactor", "_date", "_time", "_hour", "_minute", "_twilightDuration",
"_sleepDuration", "_realNightStart", "_realNightEnd", "_twilightAccFactor", "_daytimestate"];
_nightStart = _this select 0; // hour value for night start
_nightEnd   = _this select 1; //hour value for night end
_accFactor = _nightEnd + 24 - _nightStart; // night span in game time (accelerated)
_accFactor  = _accFactor / (_this select 2); // night span in real time
_twilightDuration = if ( count _this  > 3 ) then { _this select 3 } else { 0 }; // twilight duration from 0 to used defined value, must be << (night_span /2)
_twilightAccFactor = _accFactor / TWILIGHT_SMOOTH_FACTOR; // smoother in TWILIGHT_SMOOTH_FACTOR times
_realNightStart = _nightStart + _twilightDuration;
_realNightEnd = _nightEnd - _twilightDuration;
_daytimestate = -1; // initial state is undefined (defined is in range 0..3)
//_twilight = false;
while {true} do
{
    _time = daytime;
    if (_time >= _nightStart or (_time < _nightEnd) ) then	 // we are at night
    {
        _date = date;
        if ((_time >= _realNightStart)  or (_time < _realNightEnd)) then // we are in true night (not twilight)
        {
          //player sideChat "shortNight:  NIGHT ON EARTH";
          _minute = (_date select 4) + _accFactor - STD_SUBTRACTION; // convert to minutes
          _sleepDuration = STD_SLEEP_DURATION;
        }
        else // we are at twilight, so smooth night acceleration
        {
          //player sideChat "shortNight:  TWILIGHT period";
          _minute = (_date select 4) + _twilightAccFactor - TWILIGHT_SUBTRACTION; // convert to minutes
          _sleepDuration = TWILIGHT_SLEEP_DURATION;
        };
        _date set [4, _minute];
        setDate _date;
    }
    else
    {
        // player sideChat "shortNight:  DAY time";
        _sleepDuration = STD_SLEEP_DURATION;
    };
    sleep _sleepDuration;
    if (!isServer) then // work on client only!!!
    {
        _state = TIME_STATE;
        if ( _state != _daytimestate) then
        {
            _str = localize (format["STR_TIME_%1",_state]);
/*
           if ( _daytimestate == -1 ) then
           {
               _str spawn
               {
                    sleep ( 40 + random 20 );
                    titleText [ _this, "PLAIN"];
               };
           }
           else
           {
*/
               titleText [ _str, "PLAIN"];
/*
           };
*/
           _daytimestate = _state;
        };
    };
};//while
