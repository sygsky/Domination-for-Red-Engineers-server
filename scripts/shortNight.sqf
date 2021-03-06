// Created by Dupa, modified by Sygsky. Not used more!
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
// [SYG_shortNightStart, SYG_startMorning, SYG_nightSkipFrom, SYG_nightSkipTo] execVM "scripts\shortNightNew.sqf";
//
// +++++++++++++++++++++++++++++++++++++++++ NEW version comments block +++++++++++++++++++++++++++++
//
// Next version of pararameters:
//         Night start,         night end,         skip from,         skip to
//[SYG_shortNightStart, SYG_startMorning, SYG_nightSkipFrom, SYG_nightSkipTo] execVM "scripts\shortNight.sqf";
//
// Now in mission there are follow time stamps, from midnight (24:00 MST, Middle Sahrani Time):
//
//           night skipTo: night darkest period time to skip to
// morning twilight start: time of morning twiligt start
//              day start: day start time
// evening twilight start: evening twilight start time
//            night start: night start time
//        night skip from: night darkest period skip from time
//
// ----------------------------------------- NEW version comments block -----------------------------


//

#define __FUTURE__

#define __DEBUG__

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
SYG_startMorning    = 4.6;
SYG_morningEnd       = 7.0;
SYG_nightDuration    = 0.5;
SYG_twilightDuration = 0.5;
SYG_nightLength      = (24 - SYG_shortNightStart) + SYG_startMorning;
SYG_nightSpeed       = SYG_nightLength/SYG_nightDuration;
*/

#ifndef __FUTURE__
// returns 0 - for night, 1- for day, 2 - for morning, 3 - for evening
_dayPeriod = {
    if (_this < (SYG_startMorning - SYG_twilightDuration)) exitWith {STAT_NIGHT};
    if (_this < (SYG_morningEnd)) exitWith {STAT_MORNING};
    if (_this < (SYG_eveningStart)) exitWith {STAT_DAY};
    if (_this < (SYG_shortNightStart + SYG_twilightDuration)) exitWith {STAT_EVENING};
    STAT_NIGHT
};
#endif

if (!isServer ) then
{
    hint localize format[ "+++ SHORTNIGHT: daytime %1, now %2, sleep 10", daytime, call SYG_nowTimeToStr, time];
    sleep 10;
    hint localize format[ "+++ SHORTNIGHT: daytime %1, now %2, after sleep", daytime, call SYG_nowTimeToStr];
}; // wait 10 seconds on client computer with dedicated server run

waitUntil {time > 0}; // wait time synchronization
// TODO: add some sound effects (morning sounds, day insects, evening bells, night cries etc)
_titleTime = {
    sleep  (random 60);
    _str = localize (format["STR_TIME_%1",_this]);
    titleText [ _str, "PLAIN"];
};

_eveningTwilightStart = _this select 0; // hour value for night start (evening twilight in real)
_dayStart   = _this select 1; // hour value for night end (morning twilight start)

#ifdef __FUTURE__

_nightSkipFrom = _this select 2;
_nightSkipTo   = _this select 3;

#else

_accFactor = _dayStart + 24 - _eveningTwilightStart; // night span in game time (accelerated)
_accFactor  = _accFactor / (_this select 2); // night span in real time
_twilightAccFactor = _accFactor / TWILIGHT_SMOOTH_FACTOR; // smoother in TWILIGHT_SMOOTH_FACTOR times

#endif

if ( isNil "SYG_twilightDuration" ) then { SYG_twilightDuration = 0.5 };
_realNightStart       = _eveningTwilightStart + SYG_twilightDuration;
_morningTwilightStart = _dayStart - SYG_twilightDuration;

#ifdef __FUTURE__

_str = format[ "+++ SHORTNIGHT: nightSkipTo %1, morningTwilightStart %2, dayStart %3, eveningTwilightStart %4, realNightStart %5, nightSkipFrom %6, daytime %7",
        _nightSkipTo,_morningTwilightStart,_dayStart,_eveningTwilightStart,_realNightStart,_nightSkipFrom, daytime ];
//player groupChat _str;
hint localize _str;

while {true } do
{
    if ((daytime < _nightSkipTo) || (daytime >= _nightSkipFrom)) then // we are in real night after 21:00, simply skip time up to the morning twilight
    {
        _skip = (( _nightSkipTo - daytime + 24 ) % 24);
#ifdef __DEBUG__
        _str = format["SHORTNIGHT: daytime (%1)< _nightSkipTo (%2) || daytime >= %3, skip hours = %4",daytime, _nightSkipTo, _nightSkipFrom, _skip];
        // player groupChat _str;
        hint localize _str;
#endif
        skipTime _skip;
    };
    if (daytime < _morningTwilightStart) then // we are in real night after 24:00, let wait
    {
#ifdef __DEBUG__
        _str = format["SHORTNIGHT: daytime (%1)< _morningTwilightStart, sleep to it",daytime];
        //player groupChat _str;
        hint localize _str;
#endif
        sleep ((_morningTwilightStart - daytime) *3600);
    };
    if (daytime < _dayStart) then // we are in morning twilight
    {
        2 spawn _titleTime;
#ifdef __DEBUG__
        _str = format["SHORTNIGHT: daytime (%1)< _dayStart, sleep to it",daytime];
        //player groupChat _str;
        hint localize _str;
#endif
        sleep ((_dayStart - daytime) *3600);
    };
    if (daytime < _eveningTwilightStart) then // we are in day time
    {
        1 spawn _titleTime;
#ifdef __DEBUG__
        _str = format["SHORTNIGHT: daytime (%1)< _eveningTwilightStart, sleep to it",daytime];
        //player groupChat _str;
        hint localize _str;
#endif
        sleep ((_eveningTwilightStart - daytime) * 3600);
    };
    if (daytime < _realNightStart) then // we are in evening twiligth period
    {
        3 spawn _titleTime;
#ifdef __DEBUG__
        _str = format["SHORTNIGHT: daytime (%1)<  _realNightStart, sleep to it",daytime];
        //player groupChat _str;
        hint localize _str;
#endif
        sleep ((_realNightStart - daytime) * 3600);
    };
    if (daytime < _nightSkipFrom) then // we are in evening twiligth period
    {
        0 spawn _titleTime;
#ifdef __DEBUG__
        _str = format["SHORTNIGHT: daytime (%1)< _nightSkipFrom, sleep to it",daytime];
        //player groupChat _str;
        hint localize _str;
#endif
        sleep ((_nightSkipFrom - daytime) * 3600);
    };
    // it is time to skip dark night period
//#ifdef __DEBUG__
//    _str = format["SHORTNIGHT: daytime (%1) < 24:00, skip to _nightSkipTo",daytime];
//    hint localize _str;
//#endif
//    skipTime (( _nightSkipTo - daytime + 24 ) % 24);
};

#else

_daytimestate = -1; // initial state is undefined (defined is in range 0..3)
//_twilight = false;
while {true} do
{
    _time = daytime;
    if (_time >= _eveningTwilightStart or (_time < _dayStart) ) then	 // we are at night
    {
        _date = date;
        if ((_time >= _realNightStart)  or (_time < _morningTwilightStart)) then // we are in true night (not twilight)
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
            titleText [ _str, "PLAIN"];
            _daytimestate = _state;
        };
    };
};//while

#endif