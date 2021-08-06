// scripts\shortNightNew.sqf: created by Dupa, modified by Sygsky
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
//     [SYG_startMorning, SYG_startDay, SYG_startEvening, SYG_startNight, SYG_nightSkipFrom, SYG_nightSkipTo] execVM "scripts\shortNightNew.sqf";
//
// +++++++++++++++++++++++++++++++++++++++++ NEW version comments block +++++++++++++++++++++++++++++
//
// Next version of pararameters:
//         Night start,         night end,         skip from,         skip to
//[SYG_startNight, SYG_startMorning, SYG_nightSkipFrom, SYG_nightSkipTo] execVM "scripts\shortNight.sqf";
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
// Call it only on server (X_SPE too) side!
//

if ( !isServer) exitWith {false};
//

#define __DEBUG__

private ["_titleTime","_morningStart","_dayStart","_eveningStart","_nightStart","_nightSkipFrom","_nightSkipTo","_str","_skipped"
        ,"_skip"];

waitUntil { time > 0 }; // wait time synchronization
if ( isServer ) then { sleep 300; };// wait 5 min just in case to pass all possible date changes to first user started the server
// TODO: add some sound effects (morning sounds, day insects, evening bells, night cries etc)
_titleTime = {
    sleep  (random 60);
    ["shortnight","info", _this] call XSendNetStartScriptClient; // send to all client including one with server started (if any)
};

// [SYG_startMorning, SYG_startDay, SYG_startEvening, SYG_startNight, SYG_nightSkipFrom, SYG_nightSkipTo] execVM "scripts\shortNightNew.sqf";

_morningStart   = _this select 0; // hour value for night start (evening twilight in real)
_dayStart       = _this select 1; // hour value for night end (morning twilight start)
_eveningStart   = _this select 2;
_nightStart     = _this select 3;

_nightSkipFrom  = _this select 4;
_nightSkipTo    = _this select 5;

_str = format[ "+++ SHORTNIGHT: SYG_startMorning %1, SYG_startDay %2, SYG_startEvening %3, SYG_startNight %4, SYG_nightSkipFrom %5, SYG_nightSkipTo %6, daytime %7",
        _morningStart,_dayStart,_eveningStart,_nightStart,_nightSkipFrom, _nightSkipTo, daytime ];
//player groupChat _str;
hint localize _str;
_skipped = false;

while {true } do {
    _skipped = false;
    // NIGHT begins
    if ((daytime < _nightSkipTo) || (daytime >= _nightSkipFrom)) then {// we are in real night after 21:00, simply skip time up to the morning twilight
        _skip = (( _nightSkipTo - daytime + 24 ) % 24);
    #ifdef __DEBUG__
        _str = format["SHORTNIGHT: night detected; daytime (%1)< _nightSkipTo (%2) || daytime >= _nightSkipFrom (%3), skip hours = %4",daytime, _nightSkipTo, _nightSkipFrom, _skip];
        // player groupChat _str;
        hint localize _str;
    #endif
        ["shortnight","skip", _skip] call XSendNetStartScriptClient; // send skip command to all client
        0 call _titleTime; // send msg on night for all client
        if (!X_SPE) then  {// execute skip on dedicated server only
            // we are on dedicated server!!!
            skipTime _skip;
            _skipped = true;
        } else {
            // we are in Single on Player Execution mode (clent is running the server)
            // so simply wait until skip is completed after XSendNetStartScriptClient executed skip command
            // player groupChat _str;
            hint localize "XPE SHORTNIGHT: wait some time to complete the night skip!!!";
            sleep 10; // wait intil skip time is completed
        };
    };

    // NIGHT up to the TWILIGHT continues
    if (daytime < _morningStart) then {// we are in night from 03:00 to the morning, sleep to morning
    #ifdef __DEBUG__
        _str = format["SHORTNIGHT: night after 03:00: daytime (%1)< _morningStart (%2), sleep to it", daytime, _morningStart];
        //player groupChat _str;
        hint localize _str;
    #endif
        if (!_skipped) then {
            0 call _titleTime; // send msg on night for all client
        };
        sleep ((_morningStart - daytime) *3600);
    };

    // MORNING TWILIGHT started
    if (daytime < _dayStart) then {// we are in morning twilight, sleep to day
        2 call _titleTime;// send msg on morning for all client
    #ifdef __DEBUG__
        _str = format["SHORTNIGHT: twilight: daytime (%1)< _dayStart, sleep to it",daytime];
        //player groupChat _str;
        hint localize _str;
    #endif
        sleep ((_dayStart - daytime) *3600);
    };

    // DAY started
    if (daytime < _eveningStart) then {// we are in day time, sleep to evening
        1 call _titleTime; // send msg on day for all client
    #ifdef __DEBUG__
        _str = format["SHORTNIGHT: day: daytime (%1)< _eveningStart, sleep to it",daytime];
        //player groupChat _str;
        hint localize _str;
    #endif
        sleep ((_eveningStart - daytime) * 3600);
    };

    // EVENING TWILIGHT
    if (daytime < _nightStart) then { // we are in evening twiligth period, sleep to night start
        3 call _titleTime; // send msg on evening for all client
#ifdef __DEBUG__
        _str = format["SHORTNIGHT: evening twilight: daytime (%1)<  _nightStart (%2), sleep to it",daytime, _nightStart];
        //player groupChat _str;
        hint localize _str;
#endif
        sleep ((_nightStart - daytime) * 3600);
    };

    // NIGHT up to 21:00
    if (daytime < _nightSkipFrom) then { // we are in night, sleep to the skip moment
        0 call _titleTime;
#ifdef __DEBUG__
        _str = format["SHORTNIGHT: night before skip: daytime (%1)< _nightSkipFrom (%2), sleep to it",daytime, _nightSkipFrom];
        //player groupChat _str;
        hint localize _str;
#endif
        sleep ((_nightSkipFrom - daytime) * 3600);
    };
}; // while {true } do

