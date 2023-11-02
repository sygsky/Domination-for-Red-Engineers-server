//
// SYG_utilsDateTime.sqf
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

#define DT_YEAR_OFF 0
#define DT_MONTH_OFF 1
#define DT_DAY_OFF 2
#define DT_HOUR_OFF 3
#define DT_MIN_OFF 4

// only for missionStart output parameter
#define DT_SEC_OFF 5

#define NEW_YEAR_FIRST_DAY 25
#define NEW_YEAR_LAST_DAY 10

//MONTH_LEN_ARR = [31,28,31,30,31,30,31,31,30,31,30,31];

if ( !isNil "SYG_timeStart" ) exitWith {};

// set some internal info
SYG_timeStart = time;
SYG_dateStart = date;
hint localize format["+++ SYG_utilsDateTime.sqf: init with SYG_timeStart = %1, SYG_dateStart = %2, daytime = %3", SYG_timeStart, SYG_dateStart, daytime ];

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
	if ( typeName _this == "ARRAY" && count _this  >= 5 ) then {
		private ["_str"];
		if (count _this > 5) then { _str = (_this select 5) call SYG_twoDigsNumber0;} else { _str = "00";};
		format["%1.%2.%3 %4:%5:%6",(_this select 2) call SYG_twoDigsNumber0,(_this select 1) call SYG_twoDigsNumber0, _this select 0, (_this select 3) call SYG_twoDigsNumber0, (_this select 4) call SYG_twoDigsNumber0, _str]
	} else {
		format["--- SYG_dateToStr: expected date format illegal:'%1'",_this]
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
//	_diff  = abs(arg(0) - arg(1));
	_diff  = abs((_this select 0) - (_this select 1));
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
	if ( typeName _this == "ARRAY" && count _this  >= 3 ) then {
		format["%1.%2.%3",(_this select 2) call SYG_twoDigsNumber0,(_this select 1) call SYG_twoDigsNumber0, _this select 0]
	} else {
		format["--- Expected date only format illegal:'%1'",_this]
	};
};

SYG_nowTimeToStr = {
	format ["%1 %2",date call SYG_dateOnlyToStr, call SYG_daytimeToStr]
};

/**
 * Returns user designated time info (IN HOURS!!! Not in seconds!!! convert to hours from seconds please) to string format as follow: "hh:mm:ss"
 * call: _timestr = daytime call SYG_userTimeToStr;
 *	_timestr = (time/3600)  call SYG_userTimeToStr;
 */
SYG_userTimeToStr = {
	private ["_hour", "_minute","_second"];
	_hour = floor _this;
	_minute = floor ((_this - _hour) * 60);
	_second = floor (((((_this) - (_hour))*60) - _minute)*60);
	format["%1:%2:%3", _hour call SYG_twoDigsNumber0, _minute call SYG_twoDigsNumber0, _second call SYG_twoDigsNumber0]
};

/**
 * Returns internal mission day time info in format "hh:mm:ss"
 * call: _timestr = call SYG_daytimeToStr;
 */
SYG_daytimeToStr = {
	daytime call SYG_userTimeToStr
};

/**
 * Returns user designated period in time (in seconds) to string format as follow: "hh:mm:ss"
 * call: _timestr = time call SYG_secondsToStr;
 */
SYG_secondsToStr = {
	private ["_hour", "_minute","_second","_counted","_day"];
	_day = floor( _this /DAY_SECS);
	_counted = _day * DAY_SECS;
	_hour = floor ( (_this - _counted) / HOUR_SECS); // hours
	_counted = _counted + _hour * HOUR_SECS;
	_minute = floor ((_this - _counted) / 60);
	_counted = _counted + _minute * 60;
	_second = round (_this - _counted);
	format["%1%2:%3:%4", if (_day == 0) then {""} else {format["%1d ", _day]}, _hour call SYG_twoDigsNumber0, _minute call SYG_twoDigsNumber0, _second call SYG_twoDigsNumber0]
};

/**
 * Returns number of days current mission is runnning. Returned number has decimal part
 * call: _days = round(call SYG_missionDayToNum); // to return full days mission run
 * call: _days = ceil(call SYG_missionDayToNum); // to return current day number mission run, be 1 for first day, 2 for second etc
 */
SYG_missionDayToNum = {
    ([SYG_dateStart, date] call SYG_getDateDiffInDays) + 1 // mission length in days
};

/**
 * Returns mission time info in format "dd.mm.yyyy hh:mm:ss/md"
 * where 'md' is number of days mission is running (from 1 to ...)
 * call: _str = call SYG_missionTimeInfoStr;
 */
SYG_missionTimeInfoStr = {
	format["%1/%2",call SYG_nowTimeToStr, (ceil(call SYG_missionDayToNum)) call SYG_twoDigsNumber0]
};

SYG_nowToStr = SYG_nowTimeToStr;
SYG_nowDateToStr = SYG_nowTimeToStr;
SYG_nowDateTimeToStr = SYG_nowTimeToStr;

/**
 * Returns human date localized format: e.g: "1 August 1985" / "1 августа 1985"
 *
 * call: _str = date call SYG_humanDateStr;
 *
 */
SYG_humanDateStr = {
	if ( typeName _this == "ARRAY" && count _this  >= 3 ) then {
		format["%1 %2 %3", _this select 2, localize (format["STR_MON_%1",_this select 1]), _this select 0]
	} else {
		format["--- SYG_humanDateStr: Expected date format illegal:'%1'",_this]
	};
};

//
// returns day of week for the designated date. For Monday returns 0, for Sunday 6. Returns -1 on input error
// Uses Zeller formula: "https://en.wikipedia.org/wiki/Zeller's_congruence"
//
// _now = date;   // _now = [2014,10,30,2,30] (Oct. 30th, 2:30am)
SYG_weekDay = {
//	hint localize format["+++ SYG_weekDay: _this => %1", _this];
	private [ "_ret"];
	_ret = -1;
	if ( count _this >= 3 ) then {
		private [ "_q", "_m", "_y", "_K", "_J" ];
		_q = _this select 2; // month day
		_m = _this select 1; // month number (1-12)
		_y = _this select 0;
		if ( _m < 3 ) then { _m = _m + 12; _y = _y - 1;}; // 3 = March, ... 13 = January, 14 = February
		_K = _y mod 100; // year of the century
		_J = floor(_y / 100); // zero base century of the year
//		hint localize format["+++ SYG_weekDay: %1 => q %2, m %3, K %4, J %5", _this, _q, _m, _K, _J];
		_ret = (((_q + floor((13*(_m+1))/5) + _K + floor(_K/4) + floor(_J/4) - 2*_J) mod 7) + 5) mod 7;
	} else {
		hint localize format["SYG_weekDay: Expected input array[min 3 items] is illegal -> (%1)", _this];
	};
	_ret
};

//
// _day_number = [[6, 2], 9, 2011] call SYG_NthWeekday; // day of 2nd Sunday in September 2021!
//
SYG_NthWeekday = {
	private ["_nthArr","_weekday","_weekcnt","_weekDay1","_weekDayOff"];
	_nthArr  = _this select 0;
	_weekday = _nthArr select 0;
	_weekcnt = _nthArr select 1;
//	hint localize format["+++ SYG_NthWeekday call SYG_weekDay: _this => %1", _arr];
	_weekDay1 = [ _this select 2, _this select 1, 1 ] call SYG_weekDay; // 0 - Monday ... 6 - Sunday
	_weekDayOff = _weekday - _weekDay1;
	hint localize format["+++ SYG_NthWeekday: _this %1, 1st day is %2, weekday off = %3", _this, _weekDay1 call SYG_weekDayLocalName, _weekDayOff];
	if (_weekDayOff < 0 ) then { _weekDayOff = _weekDayOff + 7; }; // first designated weekday month day offset to 1st day (0 - 1st day is wanted weekday)
	if ( _weekcnt > 1) then { _weekDayOff = _weekDayOff + ((_weekcnt -1) * 7)}; // nth weekday
	(_weekDayOff + 1) // 1st day has offset zero
};

// call: _mlen = [_mon, _year] call SYG_monthLen;
SYG_monthLen = {
	private ["_mon", "_year", "_len"];
	if ( (typeName _this) != "ARRAY") exitWith {localize format["--- SYG_monthLen: expected input array[_mon,_year], found %1", _this]; -1};
	if ( (count _this) < 2) exitWith {localize format["--- SYG_monthLen: expected input array[_mon,_year], found %1", _this]; -1};
	_mon  = arg(0);
	_year = arg(1);
	if ( _mon < 1 || _mon > 12 ) exitWith { localize format["--- SYG_monthLen: expected month number must be in range 1..12, found %1", _this]; -1 };
	_len = if ( _mon == 2 ) then {
		if ( (_year  mod 4) == 0 ) then {
			if ( (_year mod 100) == 0 ) then {
				if ( (_year mod 400) == 0 ) then { 29 }
				else {28};
			} else {28};
		} else {28};
	} else {argp(MONTH_LEN_ARR,_mon)};
	_len
};

//
// returns name of designated day of week. For 0 return "Monday", for 6 return "Sunday" etc
// calls: _weekdayname = (date call SYG_weekDay) call SYG_weekDayLocalName;
//
SYG_weekDayLocalName = {
	switch _this do {
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
// returns true if real day is in a new year range (from 21.12 to 10.01)
//
SYG_isNewYear = {
	private ["_serverDateTime"];
	_serverDateTime = call SYG_getServerDate;
//	hint localize format["+++ SYG_isNewYear: %1", _serverDateTime];
	_serverDateTime call SYG_isNewYear0
};

//
// returns true if day is in a new year range (from 20-DEC to 10-JAN)
//
// call as follow:
//                _srvDate = call SYG_getServerDate;
//                _isNewYear = _srvDate call SYG_isNewYear0;
//
SYG_isNewYear0 = {
	private ["_day","_mon"];
	// must be array of at least 3 items [year, month, day]
//	hint localize format["+++ _SYG_isNewYear0: _this %1", _this ];
	if ( count _this  < 3) exitWith { false }; // illegal or suspicious  time received from server
	_mon = arg(1);
	_day = arg(2);
	( ((_mon == 12) && (_day >= NEW_YEAR_FIRST_DAY)) || ((_mon == 1) && ( _day <= NEW_YEAR_LAST_DAY)))
};

SYG_monLength  = [31,28,31,30,31,30,31,31,30,31,30,31]; // months length

SYG_leapYear = {
	( ( (_this%4) + (_this%400) ) == 0 ) && ( (_this%100) > 0)
};

// returns designated month length
// call:
//  _monlen = [2018,12] call SYG_monthLength; // returns 31
//
SYG_monthLength = {
    _year = _this select 0;
    _mon  = _this select 1;
    if ( _mon == 2 ) then { if (_year call SYG_leapYear) then { 29} else {28}} else { SYG_monLength select (_mon-1)};
};
//
// Works only on server!!!
// Returns real time (from real world) server date, based on variable SYG_client_start (filled with missionStart info from user on "d_p_a" message ),
// SYG_mission_time  and current server time
// Return code = [year, month, day, hour, minute, sec];
//
SYG_getServerDate = {
	private ["_time", "_adddays","_addsecs","_ssecs","_ssecsreminder","_ret","_year","_mon","_day","_hour","_min","_sec","_monlen","_newday"];

	// synchronize server start time and value of function 'time'
	_time  = time - SYG_server_time; // difference between current time and synchonized one
	_ret   = + SYG_client_start;     // copy server time here
	//_time = _this - SYG_timeStart;
	//hint localize format["_this type is %1", typeName _this];

	_adddays = floor(_time/DAY_SECS); // how many days to add to server date
	_addsecs = _time % DAY_SECS; // how many seconds to add to new server date from current time
	_ssecs = DAY_SECONDS(SYG_client_start); // how many seconds for old server day
	_ssecsreminder = DAY_SECS - _ssecs; // how many seconds to add to bump to the new server day

	//hint localize format["SYG_getServerDate(1): _this %6, _time %5, _adddays %1, _addsecs %2, _ssecs %3, _ssecsreminder %4", _adddays, _addsecs, _ssecs, _ssecsreminder, _time, _this];

	if ( _addsecs >= _ssecsreminder ) then {
		_adddays = _adddays + 1; // bump next server day
		_addsecs = _addsecs - _ssecsreminder;
		//hint localize format["SYG_getServerDate(2): day added by seconds, _adddays %1, _addsecs %2", _adddays, _addsecs];
	} else { _addsecs = _ssecs + _addsecs;};

	if ( _adddays > 0 ) then {// bump days
	     // server year
		_year = argp(SYG_client_start,0);
		 // server month (1..12)
		_mon  = argp(SYG_client_start,1);
		// server month day (1..31)
		_day  = argp(SYG_client_start,2);
		while { _adddays > 0 } do
		{
			_monlen = if ( _mon == 2 ) then { if (_year call SYG_leapYear) then { 29} else {28}} else {argp(SYG_monLength,_mon-1)};
			_newday = _day + _adddays;
			if ( _newday > _monlen) then {// bump month as days  are out of range
				_newday  = _monlen;
				if ( _mon == 12 ) then { // December, so bump year too
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
	_ret set [ 3, _hour ];
	_min = floor((_addsecs % HOUR_SECS)/60);
	_ret set [ 4, _min ];
	_sec = round (_addsecs % 60);
	_ret set [ 5, _sec ];
	_ret
};

//
// Returns curent real time on client computer in format as missionStart [year, mon, day,hour, min,sec]
// Works only in MP on client computer, return start of Arma.exe on client computer
//
SYG_getClientStatDate = {
	_start = missionStart;
};

// gets day count in month sequence from m1 to m2 (e.g. from jan to mar if 1, 3 used) at designated year
// call: _days = [1,3,2016] call SYG_countDaysInMonth; // Result is 89
SYG_countDaysInMonth = {
	private ["_cnt","_m1","_m2","_y","_i"];
	_cnt = 0;
	if ( count _this < 3 ) exitWith {localize format["--- SYG_countDaysInMonth: expected param must be array[3], detected is %1", _this];0};
	_m1 = _this select 0;
	_m2 = _this select 1;
	if ( _m1  < 1 || _m1 > 12 || _m2 < 1 || _m2 > 12 ) exitWith { hint localize format["--- SYG_countDaysInMonth invalid month[s] desigmated: %1", _this]; 0};
	_y  = _this select 3;
	for "_i" from _m1 to _m2 do {
		_cnt  = _cnt + (if (_i != 2) then { SYG_monLength select  (_i - 1) } else { if (_y call SYG_leapYear) then {29} else {28} } );
	};
	_cnt;
};

// call: _diff =  [_date1, _date2] call SYG_getDateDiffInDays;
//
// _data1 and _data2 may be in any relations each to other, the difference be calculated correctly
//
// Example: _diff = [[2016,5,17,15,45],[2016,4,26,9,5]] call SYG_getDateDiffInDays;
//
// always returns positive integer difference between two dates in days. Use JDN calculatuions from: https://en.wikipedia.org/wiki/Julian_day
SYG_getDateDiffInDays = {
    private ["_date1","_date2","_x"];
	_date1 = _this select 0;
	_date2 = _this select 1;
	// check what date is younger
	{
		if ((_date1 select _x) > (_date2 select _x)) exitWith { };
		if ((_date1 select _x) < (_date2 select _x)) exitWith {	_date2 = _date1; _date1 = _this select 1; };
	} forEach [0,1,2];
    (_date1 call SYG_JDN) - (_date2 call SYG_JDN)
};

/* Julian Day Number -> JDN
All division is integer division, operator % is modulus.
Given integer y, m, d, calculate day number g as:
function g(y,m,d)
m = (m + 9) % 12
y = y - m/10
return 365*y + y/4 - y/100 + y/400 + (m*306 + 5)/10 + ( d - 1 )
Difference between two dates = g(y2,m2,d2) - g(y1,m1,d1)
*/
SYG_JDN = {
    private ["_m","_y"];
    _m = ((_this select 1) + 9) % 12;
    _y = (_this select 0) - floor(_m/10);
    365 * _y + floor(_y/4) - floor(_y/100) + floor(_y/400) + floor((_m*306 + 5)/10) + ( (_this select 2) - 1 )
};

#define OFF_HOLIDAY_DAY 0 // day of month
#define OFF_HOLIDAY_MON 1 // month
#define OFF_HOLIDAY_SND 2 // music := empty string "" (no music still) || single string || array of strings
#define OFF_HOLIDAY_TIT 3 // title for holiday
#define OFF_HOLIDAY_HOL 4 // day off (1), work day (0)

// [day|Nth weekday,mon<, "common_music_name" || ["rnd_music1",..."rnd_music#"]>]
SYG_holidayTable = [
    [ 1,  1, ["snovymgodom","grig","zastolnaya","nutcracker","home_alone","merry_xmas","vangelis","enchanted_boy"], "STR_HOLIDAY_1_JAN", 1], // New Year Day
    [ 9,  2, ["hugging_the_sky","we_teach_planes_to_fly",localize "STR_AVIAMARCH"], "STR_HOLIDAY_9_FEB", 0], // Day of the Soviet Civil aviations
    [23,  2, ["burnash","soviet_officers"],"STR_HOLIDAY_23_FEB",0], // 23th of February
    [ 8,  3, ["esli_ranili_druga"],"STR_HOLIDAY_8_MAR",1], // 8th of March
    [12,  4, ["cosmos_1","cosmos_2","cosmos_3"],"STR_HOLIDAY_12_APR",0], // Cosmonautics day
    [22,  4, ["lenin","lenin_1"],"STR_HOLIDAY_22_APR",0], // Birthday of V.I. Lenin
    [ 1,  5, ["Varshavianka","Varshavianka_eng","warschawyanka_german"], "STR_HOLIDAY_1_MAY",1], // 1st May
    [ 2,  5, ["Varshavianka","Varshavianka_eng","warschawyanka_german"], "STR_HOLIDAY_1_MAY",1], // 1st May 2nd day
    [ 9,  5, "invasion","STR_HOLIDAY_9_MAY",1], // 9th of May
    [ 28, 5, "border_guards","STR_HOLIDAY_28_MAY",0], // //Border Guard Day
    [ 18, 8, ["hugging_the_sky","we_teach_planes_to_fly",localize "STR_AVIAMARCH"],"STR_HOLIDAY_18_AUG", 0], // 18 of Aug: Day of Soviet Aviation
    [  1, 9, "uchat_v_shkole", "STR_HOLIDAY_1_SEP", 0], // 1st of September, Day of Knowledge
    [[6, 2], 9, "march_of_soviet_tankmen","STR_HOLIDAY_TANKIST_DAY",0], // // Tankists Day: 2nd Sunday (week day index is 6)  of September (9th month)
    [ 7, 10, ["communism","Vremia_vpered_Sviridov","ddrhymn"],"STR_HOLIDAY_7_OCT",1], // Day of USSR constitution / Day of DDR
    [29, 10, "komsomol","STR_HOLIDAY_28_OCT",0], // Komsomol day
    [ 7, 11, ["soviet_officers","ahead_friends","Varshavianka","Varshavianka_eng","warschawyanka_german"],"STR_HOLIDAY_7_NOV",1]  // 7th of November

];

// Checks current server date agains holiday list and return array of data if detected, or empty array [] if not
// _retArr = _server_date call  SYG_getHoliday;
// where:
//   _retArr is [false (ordinal day) || true (day off), "registered_sound_name" || "" (no sound),"Holiday_title"] || [] (not holiday)
SYG_getHoliday = {
    private ["_curr_mon","_curr_day","_day","_ret","_music","_XfRandomFloorArray","_XfRandomArrayVal","_x"];

    // get a random number, floored, from count array
    // parameters: array
    // example: _randomarrayint = _myarray call XfRandomFloorArray;
    _XfRandomFloorArray = {
    	floor (random (count _this))
    };

    // get a random item from an array
    // parameters: array
    // example: _randomval = _myarray call XfRandomArrayVal;
    _XfRandomArrayVal = {
    	_this select (_this call _XfRandomFloorArray);
    };
    _curr_mon = _this select 1;
    _curr_day = _this select 2;
    _ret = []; // default return not holiday
    // seek current day&month in the holiday table, sorted my month and day
    {
        if ( _curr_mon  < (_x select 1)) exitWith {}; // month in sorted table .GT. current one, it means current month not exists in the table
        if ( _curr_mon == (_x select 1) ) then  {// month found, check days in table for coincidence with current one
        	_day = _x select 0;	// day number from table item
        	if (typeName _day == "ARRAY") exitWith { // if array, Nth week day designated, not direct day number
        		_day = [ _day, _curr_mon, _this select 0] call SYG_NthWeekday; // Example call:  [[6, 2], 9, 2011] call SYG_NthWeekday; // 2nd Sunday of the month
        	};
			if ( _day == _curr_day ) then { // day also found, it's holyday!!!
				_music = _x select OFF_HOLIDAY_SND;
				if ( typeName _music == "ARRAY" ) then { _music = _music call _XfRandomArrayVal }; // not one music is set for this day, select random one
				_ret = [(_x select OFF_HOLIDAY_HOL) > 0, _music, _x select OFF_HOLIDAY_TIT ];
			};
        };
        if (count _ret > 0 ) exitWith {}; // A holday coincided with current day and its data returned to caller
    } forEach SYG_holidayTable;
    _ret
};

//
// Finds personal player country day (Foundation day of solialist country usually)
// Call as follow: _holiday = SYG_client_start call SYG_getCountryDay; // call only on client (server is headless)
//
SYG_getCountryDay = {
    private ["_holiday","_sound"];
    _holiday = [];
    switch ( name player ) do {
        case "gyuri": {
            if ( ( ( SYG_client_start select 1) == 8 ) && ( (SYG_client_start select 2) == 20 ) ) then { // 20-AUG-1849, Day of HPR
            	_sound = ["Hungary", "hungarian_dances"] call _XfRandomArrayVal;
                _holiday = ["STR_HOLIDAY_HUNGARY", _sound];
            };
        };
    };
    _holiday
};

// Returns 0 for night, 1 for day, 2 for morning and 3 for evening
//
SYG_getDayTimeId = {
    private ["_dt"];
    _dt = daytime;
    if ( _dt < SYG_startMorning ) exitWith {0};
    if ( _dt <     SYG_startDay ) exitWith {2};
    if ( _dt < SYG_startEvening ) exitWith {1};
    if ( _dt <   SYG_startNight ) exitWith {3};
    0
};

// Return localized message text on the current daytime period: night, morning, day, evening
SYG_getMsgForCurrentDayTime = {
    private ["_id"];
    _id = call SYG_getDayTimeId;
    localize format["STR_TIME_%1", _id]
};

// call as follow:
// _soundName = (call SYG_getDayTimeId) call SYG_getDayTimeIdRandomSound;
// return empty string if no sound or illegal id not in [0..3] designated
SYG_getDayTimeIdRandomSound = {
    switch (_this) do {
        case 0 : { playSound format["night_%1", (floor (random 6)) + 1 ]; };   // STAT_NIGHT night_1..6
        case 1 : {  ""  }; // STAT_DAY
        case 2 : {  playSound format["morning_%1", (floor (random 3)) + 1 ]; }; // STAT_MORNING morning_1..3
        case 3 : {   format["evening_%1", (floor (random 6)) + 1]; };// STAT_EVENING: evening_1..6
        default {""};
    };
};

SYG_getCurrentDayTimeRandomSound = {
    ([] call SYG_getDayTimeId) call SYG_getDayTimeIdRandomSound;
};

//
//++++++++++++++++++++++++++++++++++++++++++++++++++
// Updates date with designated hours
// _oldDT = [ 1985, 8, 1, 12, 25]; // 01-AUG-1985 12:25:00
// _newDT = [_oldDT, +12.2] call  SYG_updateDTByHours; // [ 1985, 8, 2, 0, 37] // 02-AUG-1985 00:37:00
//  hour value to add must be positive and and cannot exceed 28 days (28*24 in hours)
//--------------------------------------------------
SYG_bumpDateByHours = {
	private ["_dt","_addhr","_min","_hour","_day","_mon","_year","_new","_monlen"];
    _dt    = + (_this select 0);
    _addhr =    _this select 1;
    if ( _addhr == 0) exitWith {
        hint localize "+++ SYG_bumpDateByHours: called with 0 hour change, accepted as is";
        _dt
    };

	// Process seconds too if available
	// Process seconds too if available
	_min = 0;
	if (count _dt > DT_SEC_OFF) then {
		_sec = _dt select DT_SEC_OFF; // Secs in date
	    _new = _sec  + (((_addhr mod 1) * 3600) mod 60); // seconds in added value
	    _sec = _sec + _new;
	    _min = floor (_sec / 60);
	    _sec = round (_sec mod 60);
	};

    _min  = _min + (_dt select DT_MIN_OFF);
    _hour = _dt select DT_HOUR_OFF;
    _day  = _dt select DT_DAY_OFF;
    _mon  = _dt select DT_MONTH_OFF;
    _year = _dt select DT_YEAR_OFF;

    // MINUTES

	if (count _dt > DT_SEC_OFF) then { // Считаем только полные минуты, т.к. секунды существуют и обработаны отдельно
        _new  = _min + floor((_addhr mod 1) * 60);
    } else {  // Пытаемся учесть остаток в секундах, если они >= 30
        _new  = _min + round((_addhr mod 1) * 60);
    };
    // hint localize format["SYG_bumpDateByHours: new minutes = %1", _new];
    if ( _new >= 60 ) then {
        _dt set [DT_MIN_OFF, _new - 60];
        _addhr = ceil(_addhr);
    } else {
        if (_new < 0) then {
            _dt set [DT_MIN_OFF, 60 + _new];
            _addhr = floor(_addhr);
        } else {
            _dt set [DT_MIN_OFF, _new];
            _addhr = _addhr - (_addhr mod 1);
        };
    };

    // HOURS

    _new = _hour + _addhr; // new hour value
    // hint localize format["SYG_bumpDateByHours: new hours = %1", _new];
    if ( _new >= 24 ) then {
        _dt set [DT_HOUR_OFF, _new % 24];
    } else {
        if (_new < 0) then {
            _dt set [DT_HOUR_OFF, 24 + (_new % 24)];
        } else {
            _dt set [DT_HOUR_OFF, _new];
        };
    };

    // MONTH and YEAR

    _new = floor(_new / 24); // how many new whole days created (+ or -)
    _monlen = [_year, _mon] call SYG_monthLength;

    _new = _new + _day; // new day value
    // hint localize format["SYG_bumpDateByHours: new days = %1", _new];
    if ( _new > _monlen) then {
        if ( _mon == 12 ) then { _mon = 1; _year = _year + 1 } // December => January
        else { _mon = _mon + 1 };
        _new = _new - _monlen;
    } else {
        if ( _new < 1 ) then {
            if ( _mon == 1 ) then { _mon = 12; _year = _year - 1 } // January => December
            else { _mon = _mon - 1 };
            _monlen = [_year, _mon] call SYG_monthLength; // new month may change day number
            _new = _monlen + _new;
        };
    };
    // hint localize format["SYG_bumpDateByHours: new month = %1", _mon];
    // hint localize format["SYG_bumpDateByHours: new year  = %1", _year];
    _dt set [ DT_DAY_OFF   , _new  ]; // set new day
    _dt set [ DT_MONTH_OFF , _mon  ]; // set new month
    _dt set [ DT_YEAR_OFF  , _year ]; // set new year
    // now print old and new datetime values
    hint localize format["+++ SYG_bumpDateByHours: date initial %1, corrected %2", _this select 0, _dt];

    _dt
};

//
// _days = [40,15,36,8]; // 40 days, 15 hours, 36 mins, 8 seconds
// call: _seconds = _days call SYG_getDaysSeconds;
// calculates number of seconds in days mhours, minutes and optionally seconds
//
SYG_getDaysSeconds = {
	private ["_last_id","_i","_diff"];
//	hint localize format["+++ SYG_getDaysSeconds: %1", _this];
	_last_id = ((count _this) min 4) - 1;
	_diff = 0;
	for "_i" from 0 to _last_id do {
		_diff = _diff + (
			switch (_i) do {
				case 0: { (_this select _i) * 24 * 3600 }; // days
				case 1: { (_this select _i) * 3600      }; // hours
				case 2: { (_this select _i) * 60        }; // minutes
				case 3: { (_this select _i)             }; // seconds
			}
		)
	};
	_diff
};

//
// Finds and return difference between 2 date in seconds, ready to use result in the sleep command
// _date1 and _date2 may be in any relations (older, newer, equels), result is correct in any case
// call as: _diff_in_seconds = [_date_old, _date_new] call SYG_getDateDiffInSeconds
//
SYG_getDateDiffInSeconds = {
	private ["_date1","_date2","_cnt","_i","_days"];

	_date1 = _this select 0;
	_date2 = _this select 1;
	_cnt = (count _date1) min (count _date2);
	// put newer (larger) date to _date1 and older (smaller) to _date2
	for "_i" from 0 to (_cnt - 1) do {
		if ( (_date1 select _i) > (_date2 select _i)) exitWith {};
		if ( (_date1 select _i) < (_date2 select _i)) exitWith { _date1 = _date2; _date2 = _this select 0;};
	};

	_days = [_date1, _date2] call SYG_getDateDiffInDays;
	if (_days == 0) exitWith {
		([0, (_date1 select 3) - (_date2 select 3), (_date1 select 4) - (_date2 select 4), if (_cnt > 5 ) then {(_date1 select 5) - (_date2 select 5)} else {0}] call SYG_getDaysSeconds)
	};

//	hint localize format["+++ SYG_getDateDiffInSeconds: days = %1", _days ];
	// sumarize full diff days + partial parts of day of older and newer dates
	(_days - 1 /* full day number */) * 24 * 3600 +
	([0, _date1 select 3, _date1 select 4, if (_cnt > 5 ) then {_date1 select 5} else {0}] call SYG_getDaysSeconds) + // day part of newer date
	([0, 23 - (_date2 select 3), 59 - (_date2 select 4), if (_cnt > 5 ) then { 60 - (_date2 select 5)} else {60}] call SYG_getDaysSeconds) // day part of older date
};
