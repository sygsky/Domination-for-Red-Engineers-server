//
// SYG_utilsDateTime
//

/**
 * Module to date time functions
 *
 */

#include "x_setup.sqf"
 
#define arg(x) (_this select(x))
#define argp(param,x) ((param)select(x))
#define argopt(num,val) if (count _this<=num)then{val}else{arg(num)}
#define RAR(ARR) (ARR select(floor(random(count ARR ))))

#define DAY_SECS 86400
#define HOUR_SECS 3600

#define DAY_SECONDS(st) (argp(st,3)*HOUR_SECS+argp(st,4)*60+argp(st,5))

#define ONLY_SECONDS(secs) (round((secs)%60))
#define ONLY_MINS(secs) (floor((secs)%HOUR_SECS))
#define ONLY_DAYS(secs) (floor((secs)%DAY_SECS))

//MONTH_LEN_ARR = [31,28,31,30,31,30,31,31,30,31,30,31];

if ( !isNil "SYG_timeStart" ) exitWith {};

// set some internal info
SYG_timeStart = time;
hint localize format["SYG_utilsDateTime.sqf: init with SYG_timeStart = %1", SYG_timeStart];

// creates 1 digit number as 2 symbol string, adding zero before dogit
SYG_twoDigsNumber0 = {
	if ( (_this < 0) || (_this > 9) ) then { format["%1", floor _this] } else {format["0%1",floor _this]};
};

// creates 1 digit number as 2 symbol string, adding space before dogit
SYG_twoDigsNumberSpace = {
	if ( (_this < 0) || (_this > 9) ) then { format["%1", floor _this] } else {format[" %1",floor _this]};
};

/**
 * Date format  is [year, month, day, hour, minute<,second>] 
 * call: 
 *     _datestr = date call SYG_dateToStr; // 31.05.2015 14:33:03
 *
 */
SYG_dateToStr = {
	if ( typeName _this == "ARRAY" && count _this  >= 5 ) then 
	{
		private ["_str"];
		if (count _this > 5) then { _str = (_this select 5) call SYG_twoDigsNumber0;} else { _str = "00";};
		format["%1.%2.%3 %4:%5:%6",(_this select 2) call SYG_twoDigsNumber0,(_this select 1) call SYG_twoDigsNumber0, _this select 0, (_this select 3) call SYG_twoDigsNumber0, (_this select 4) call SYG_twoDigsNumber0, _str]
	}
	else
	{
		format["-- SYG_dateToStr: expected date format illegal:'%1'",_this]
	};
};

//
//
// Example call:
// _oldtime = time;
// sleep random 600;
// _str = [ time,_oldtime] call SYG_timeDiffToStr; // "hh:mm:ss" as always positive difference between two times
//
SYG_timeDiffToStr = {
	private ["_diff","_hours","_mins","_secs"];
	_diff  = abs(arg(0) - arg(1));
	_hours = floor(_diff/HOUR_SECS);
	_mins  = floor((_diff - _hours * HOUR_SECS)/60);
	_secs  = round(_diff - (_hours * HOUR_SECS + _mins *60));
	format["%1:%2:%3", _hours call SYG_twoDigsNumber0, _mins call SYG_twoDigsNumber0,_secs call SYG_twoDigsNumber0]
};

/**
 * Date format  is [year, month, day...] 
 * call: _datestr = call SYG_dateOnlyToStr; // 31.05.2015
 *
 */
SYG_dateOnlyToStr = {
	if ( typeName _this == "ARRAY" && count _this  >= 3 ) then 
	{
		format["%1.%2.%3",(_this select 2) call SYG_twoDigsNumber0,(_this select 1) call SYG_twoDigsNumber0, _this select 0]
	}
	else
	{
		format["--- Expected date only format illegal:'%1'",_this]
	};
};

SYG_nowTimeToStr = {
	format ["%1 %2",date call SYG_dateOnlyToStr, call SYG_daytimeToStr]
};

/**
 * Returns user designated time info (in hours) to string format as follow: "hh:mm:ss"
 * call: _timestr = daytime call SYG_userTimeToStr;
 */
SYG_userTimeToStr = {
	private ["_hour", "_minute","_second"];
	_hour = floor _this;
	_minute = floor ((_this - _hour) * 60);
	_second = floor (((((_this) - (_hour))*60) - _minute)*60);
	format["%1:%2:%3", _hour call SYG_twoDigsNumber0, _minute call SYG_twoDigsNumber0, _second call SYG_twoDigsNumber0]
};

/**
 * Returns number of days current mission is runnning. Returned number has decimal part
 * call: _days = round(call SYG_missionDayToNum); // to return full days mission run
 * call: _days = ceil(call SYG_missionDayToNum); // to return current day number mission run, be 1 for first day, 2 for second etc
 */
SYG_missionDayToNum = {
	time / DAY_SECS
};

/**
 * Returns mission time info in format "dd.mm.yyyy hh:mm:ss/md"
 * where 'md' is number of days mission is running (from 1 to ...)
 * call: _str = call SYG_missionTimeInfoStr);
 */
SYG_missionTimeInfoStr = 
{
	format["%1/%2",call SYG_nowTimeToStr, (ceil(call SYG_missionDayToNum)) call SYG_twoDigsNumber0]
};

SYG_nowToStr = SYG_nowTimeToStr;
SYG_nowDateToStr = SYG_nowTimeToStr;
SYG_nowDateTimeToStr = SYG_nowTimeToStr;

/**
 * Returns internal mission day time info in format "hh:mm:ss"
 * call: _timestr = call SYG_userTimeToStr;
 */
SYG_daytimeToStr = {
	daytime call SYG_userTimeToStr
};

/**
 * Returns human date localized format: e.g: "1 August 1985"/ "1 августа 1985"
 *
 * call: _str = date call SYG_humanDateStr;
 *
 */
SYG_humanDateStr = 
{
	if ( typeName _this == "ARRAY" && count _this  >= 3 ) then 
	{
		format["%1 %2 %3", _this select 2, localize (format["STR_MON_%1",_this select 1]), _this select 0]
	}
	else
	{
		format["--- SYG_humanDateStr: Expected date format illegal:'%1'",_this]
	};
};

//
// returns day of week for the designated date. For Monday returns 0, for Sunday 6. Returns -1 on input error 
// Uses Zeller formula: https://en.wikipedia.org/wiki/Zeller's_congruence
//
SYG_weekDay = { // by Zeller formulae
// _now = date;   // _now = [2014,10,30,2,30] (Oct. 30th, 2:30am)
	_ret = -1;
	if ( count _this >= 3 ) then
	{
		_q = _this select 2; // month day
		_m = _this select 1; // month number (1-12)
		if ( _m < 3 ) then { _m = _m + 12;}; // 3 = March, ... 13 = January, 14 = February
		_Y = _this select 0; // year
		_ret = (((_q + floor(13*(_m+1)/5) + _Y + floor(_Y/4) + 6* floor(_Y/100) + floor(_Y/400)) mod 7) +5) mod 7;
	}
	else
	{
		hint localize format["SYG_weekDay: Expected input array[min 3 items] is illegal -> (%1)", _this];
	};
	_ret
};

// call: _mlen = [_mon, _year] call SYG_monthLen;
SYG_monthLen = {
	private ["_mon", "_year", "_len"];
	if ( (typeName _this) != "ARRAY") exitWith {localize format["--- SYG_monthLen: expected input array[_mon,_year], found %1", _this]; -1};
	if ( (count _this) < 2) exitWith {localize format["--- SYG_monthLen: expected input array[_mon,_year], found %1", _this]; -1};
	_mon  = arg(0);
	_year = arg(1);
	if ( _mon < 1 || _mon > 12 ) exitWith { localize format["--- SYG_monthLen: expected month number must be in range 1..12, found %1", _this]; -1 };
	_len = if ( _mon == 2 ) then
	{
		if ( (_year  mod 4) == 0 ) then
		{
			if ( (_year mod 100) == 0 ) then
			{
				if ( (_year mod 400) == 0 ) then
				{
					29
				}
				else {28};
			}
			else {28};
		} else {28};
	} else {argp(MONTH_LEN_ARR,_mon)};
	_len
};

//
// returns name of designated day of week. For 0 return "Monday", for 6 return "Sunday" etc
// calls: _weekdayname = (date call SYG_weekDay) call SYG_weekDayLocalName;
//
SYG_weekDayLocalName = {
	switch _this do
	{
		case 0: {localize "STR_MONDAY"};
		case 1: {localize "STR_TUESDAY"};
		case 2: {localize "STR_WEDNESDAY"};
		case 3: {localize "STR_THURSDAY"};
		case 4: {localize "STR_FRIDAY"};
		case 5: {localize "STR_SATURDAY"};
		case 6: {localize "STR_SUNDAY"};
		default {format["expected value in range 0..6, detected %1", _this]};
	}
}; 

// returns string in format "HH:MM" e.g. "15:34"
// calls: _hh_mm_str  = call SYG_nowHourMinToStr;
//
SYG_nowHourMinToStr = {
	private ["_hour", "_minute"];
	_this = daytime;
	_hour = floor _this;
	_minute = floor ((_this - _hour) * 60);
	format["%1:%2", _hour call SYG_twoDigsNumber0, _minute call SYG_twoDigsNumber0]
};

//
// returns true if day is in a new year range (from 21.12 to 10.01)
//
SYG_isNewYear = {
	private ["_day","_mon","_date"];
	_date = call SYG_getServerDate;
	if ( argp(_date,0) < 1985) exitWith { [0,0,0,0,0,0] }; // illegal || suspicious  time received from server
	_mon = _date select 1;
	_day = _date select 2;
	( ((_mon == 12) && (_day > 20)) || ((_mon == 1) && ( _day < 11)))
};

//
// returns true if day is in a new year range (from 21.12 to 10.01)
//
//	
// call as follow: 
//                _srvDate = call SYG_getServerDate;
//                _isNewYear = _srvDate call SYG_isNewYear0;
//
SYG_isNewYear0 = {
	private ["_day","_mon"];
	if ( arg(0) < 1985) exitWith { [0,0,0,0,0,0] }; // illegal or suspicious  time received from server
	_mon = arg(1);
	_day = arg(2);
	( ((_mon == 12) && (_day > 20)) || ((_mon == 1) && ( _day < 11)))
};

SYG_monLength  = [31,28,31,30,31,30,31,31,30,31,30,31]; // months length

SYG_leapYear = {
	( ( (_this%4) + (_this%400) ) == 0 ) && ( (_this%100) > 0)
};

//
// returns current server date, based on variable SYG_mission_start (filled with srvtime.sqf script created BEFORE server started),
// SYG_mission_time  and current server time
//
SYG_getServerDate = {
	private ["_time", "_adddays","_addsecs","_ssecs","_ssecsreminder","_ret","_year","_mon","_day","_hour","_min","_sec","_monlen","_newday"];
	
	// synchronize server start time and value of function 'time'
	_time  = time - SYG_timeStart;
	//_time = _this - SYG_timeStart; 
	//hint localize format["_this type is %1", typeName _this];
	
	_adddays = floor(_time/DAY_SECS); // how many days to add to server date
	_addsecs = _time % DAY_SECS; // how many seconds to add to new server date from current time
	_ssecs = DAY_SECONDS(SYG_mission_start); // how many seconds for old server day
	_ssecsreminder = DAY_SECS - _ssecs; // how many seconds to add to bump to the new server day
	
	//hint localize format["SYG_getServerDate(1): _this %6, _time %5, _adddays %1, _addsecs %2, _ssecs %3, _ssecsreminder %4", _adddays, _addsecs, _ssecs, _ssecsreminder, _time, _this];
	
	_ret = + SYG_mission_start; // copy server time here
	if ( _addsecs >= _ssecsreminder ) then
	{
		_adddays = _adddays + 1; // bump next server day
		_addsecs = _addsecs - _ssecsreminder;
		//hint localize format["SYG_getServerDate(2): day added by seconds, _adddays %1, _addsecs %2", _adddays, _addsecs];
	}
	else { _addsecs = _ssecs + _addsecs;};
	
	if ( _adddays > 0 ) then // bump days
	{
		_year = argp(SYG_mission_start,0); // server year
		_mon  = argp(SYG_mission_start,1); // server month (1..12)
		_day  = argp(SYG_mission_start,2); // server month day (1..31)
		while { _adddays > 0 } do
		{
			_monlen = if ( _mon == 2 ) then { if (_year call SYG_leapYear) then { 29} else {28}} else {argp(SYG_monLength,_mon-1)};
			_newday = _day + _adddays;
			if ( _newday > _monlen) then // bump month as days  are out of range
			{
				_newday  = _monlen;
				if ( _mon == 11 ) then // December, so bump year too
				{
					_year = _year + 1;
					_ret set [0, _year];
					_mon = 1;
				};
				_ret set [1, _mon]; // bump month number
			};
			_adddays = _adddays - _newday;
			_ret set [2, _newday];
		};
	};
	// bump hours, mins, secs
	_hour = floor(_addsecs / HOUR_SECS);
	_ret set [3, _hour ];
	_min = floor((_addsecs % HOUR_SECS)/60);
	_ret set [4, _min ];
	_sec = round (_addsecs % 60);
	_ret set[ 5, _sec ];
	_ret
};

// gets day count in month sequence from m1 to m2 (e.g. from jan to mar if 1, 3 used) at designated year
// call: _days = [1,3,_2016] call SYG_countDaysInMonth; // Result is 89
SYG_countDaysInMonth = {
	private ["_cnt","_m1","_m2","_y","_i"];
	_cnt = 0;
	if ( count _this < 3) exitWith {localize format["--- SYG_countDaysInMonth: expected param must be array[3], detected is %1", _this];0};
	_m1 = arg(0);
	_m2 = arg(1);
	_y  = arg(3);
	for "_i" from _m1 to _m2 do
	{
		_cnt  = _cnt + (if (_i != 2) then { argp(SYG_monLength, _i) } else { if (_y call SYG_leapYear) then {29} else {28} } );
	};
	_cnt;
};

// call: _diff =  [_date1, _date2] call SYG_getDateDiff;
// 
// _data1 and _data2 may be in any relations each to other, the difference be calculated correctly
//
// Example: _diff = [[2016,5,17,15,45],[2016,4,26,9,5]] call SYG_getDateDiff;
//
// returns difference between two dates in days
SYG_getDateDiff = {
	private [ "_diff", "_date1", "_date2", "_days", "_hours", "_mins", "_y1","_y2","_m1","_m2", "_d2", "_dm2", "_h2"];
	_date1 = arg(0);
	_date2 = arg(1);
	// check what date is younger
	_short_date = count date1 == 3 || count date2 == 3;
	_ids = [0,1,2];
	if ( !_short_date ) then {_ids = _ids + [3,4];};
	{
		if (argp(_date1, _x) > argp(_date2, _x)) exitWith { };
		if (argp(_date1, _x) < argp(_date2, _x)) exitWith {	_date2 = arg(0);	_date1 = arg(1); };
	} forEach _ids;

	_days = 0; // initial day count
	_y1 = argp(_date1,0);
	_y2 = argp(_date2,0);
	if ( (_y1 - _y2) > 1 ) then // full year[s] difference detected
	{
		for "_i" from _y1+1 to _y2-1 do
		{
			_days = _days + ([1,12,_i] call  SYG_countDaysInMonth);
		};
	};
	// full months of last year
	_m1 = argp(_date1,1);
	if ( _m1 > 1) then  // full months of 1st year
	{
		_days = _days + ([1, _m1 - 1, _y1] call SYG_countDaysInMonth);
	};

	// full months of first year
	_m2 = argp(_date2,1);
	if ( _m2 < 12) then  // full months of 1st year
	{
		_days = _days + ([_m2 + 1, 12, _y2] call SYG_countDaysInMonth);
	};
	
	// count full days in partial months
	_days = _days + argp(_date1,2) - 1;

	_d2 = argp(_date2,2);
	
	_dm2 = if ( (_y2 call SYG_leapYear) && (_m2 == 2)) then { 29} else {argp(SYG_monLength, _m2)};
	_days = _days + _dm2 - _d2;

	if ( !_short_date ) then
	{
        // count full hours
        _hours = argp(_date1,3);
        _h2 = argp(_date2,3);
        _hours = _hours + 24 - _h2 - 1;

        // mins
        _mins = argp(_date1,4);
        _m2 = argp(_date2,4);
        _mins = _mins + 60 - _m2 - 1;
        if ( _mins > 60 ) then
        {
            _hours = _hours + 1;
            _mins = _mins - 60;
        };
        if ( _hours > 24 ) then
        {
            _days = _days + 1;
            _hours = _hours - 24;
        };
        _hours = _hours + _mins  / 60;
        _days  = _days  + _hours / 24;
	};
	_days
};

// [day,mon,range<, "common_music_name" || ["rnd_music1",..."rnd_music#"]>]
SYG_holidayTable =
[
    [ 1, 1,10], // new year, 10 days in range
    [23, 2, 2], // 23th of February
    [ 8, 3, 2], // 8th of March
    [ 1, 5, 3], // 1st May
    [ 9, 5, 3], // 9th of May
    [ 7,11, 5]  // 7th of November
];

// Runs music and return found holiday index, -1 if no holiday found
// _ret = _mode call  SYG_runHolidayMusic;
// where:
//   _mode == 0 intro mode runs music if holiday found, returns true if music played else false
//   _mode = 1 return true if new year detectedm else false
SYG_runHolidayMusic =
{
    _date = date;
    _year = argp(_date,0);
    _curr_mon = argp(_date,1);
    if (_this == 1) exitWith // check only ofr new  year
    {
        _dateNY = [_year, 1, 1];
        if (_curr_mon == 12) then {_dateNY set [0,_year +1];};
        ([_dateNY, [argp(_date,0),argp(_date,1),argp(_date,2)]] call SYG_getDateDiff) <= 10
    };

    _curr_day = argp(_date,2);
    _date = [_year,argp(_date,1),argp(_date,2)];
    {
        _day = argp(_x,0);
        _mon = argp(_x,1);
        _holydate = [_year, _mon, _day];
        if ( _mon == 1 && _curr_mon == 12) then { _holydate set[ 0, _year + 1];};
        _diff = [_date, _holydate] call SYG_getDateDiff;
        if ( _diff <= argp(_x,2) ) exitWith
        {
            if (count _x > 3 ) then // check music rules
            {
                _music = arg(3);
                if ( typeName _music == "STRING" ) exitWith
                {
                    playMusic _music;
                };
                if ( typeName _music == "ARRAY" ) exitWith
                {
                    if ( count _music > 0) then
                    {
                        playMusic (_music select (floor (random (count _music))));
                    };
                };
            };
        };
    } forEach
    [
      [ 1, 1,10, ["snovymgodom","grig"]], // new year, 10 days in range
      [23, 2, 3, ["burnash","podolinam"]], // 23th of February
      [ 8, 3, 2], // 8th of March
      [ 1, 5, 3, "Varshavianka"], // 1st May
      [ 9, 5, 3], // 9th of May
      [22, 6, 3, "invasion"],
      [ 7,11, 7, "Varshavianka"]  // 7th of November
    ];
};