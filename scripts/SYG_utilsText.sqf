/**
 *
 * SYG_utilsText.sqf : Text functions by Sygsky from JHC. Created on 10-MAY-2016
 *
 */
 
#include "x_macros.sqf"

#define inc(x) (x=x+1)
#define arg(x) (_this select (x))
#define argp(param,x) ((param)select(x))
#define argopt(num,val) (if ( count _this <= (num) ) then {val} else { arg(num) })
#define argoptskip(num,defval,skipval) (if ( count _this <= (num) ) then { defval } else { if (arg(num) == (skipval)) then {defval} else {arg(num)} })

///////////////////////////////////////////////////////////////////
// Call as: _txt = _str_num call SYG_getLocalizedRandomText; 
//  where _str_num must be in form: <any_string_prefix>_NUM
// prefix is used to select random string in the list from stringtable.csv
// the list of strings consists of names with first suffix 0 and last suffix (_NUM-1), e.g.
// if initial string in stringtable.csv is "_STR_NUM","6","6","6" so its first string MUST be  "STR_0" and last one "STR_5"
// E.g.: _txt = "STR_RUM_NUM" call SYG_getLocalizedRandomText;
//       _txt = "STR_SYS_252_NUM" call SYG_getLocalizedRandomText;
//       _txt = "STR_MAIN_COMPLETED_NUM" call SYG_getLocalizedRandomText;
//       _txt = "STR_CAMP_INFO_NUM" call SYG_getLocalizedRandomText;
//       _txt = "STR_CAMP_TEAM_NUM" call SYG_getLocalizedRandomText;
//			etc etc etc
//////////////////////////////////////////////////////////////////
SYG_getLocalizedRandomText = {
	//hint localize format["SYG_getLocalizedRandomText: %1", _this call SYG_getRandomText ];
	localize (_this call SYG_getRandomText)
};


SYG_getLocalMenRandomName = {
	"STR_CAMP_TEAM_NUM" call SYG_getRandomText
};

SYG_getLocalManRandomName = {
	"STR_CAMP_TEAM_A_NUM" call SYG_getRandomText
};

// Non-localized version of random text getting
SYG_getRandomText = {
	if (typeName _this != "STRING") exitWith { format["SYG_utilsText.sqf.SYG_getRandomText: Expected text list base id is not string (%1)", _this] };
	private ["_counter", "_chars", "_i", "_base"];
	call compile format["_counter=%1;", localize _this];
	_chars = toArray _this;
	_base = [];
	for "_i" from 0 to count _chars - 4 do
	{
	    _base set [_i, argp(_chars, _i)];
	};
	//hint localize format["SYG_getRandomText: _counter = %5; %1 ->%2 -> %3 -> %4", _this, _chars, _base, toString(_base), _counter];
	format["%1%2", toString(_base), floor (random _counter)]
};

//#define __DEBUG__

#define RUMOR_WIDTH (_counter/4) // how far serach from start index

SYG_getRumourText = {
    private ["_daytime","_counter","_index","_rnd","_name1","_name2","_name3","_str1"];
    _daytime = daytime;
    if ( _daytime <= SYG_startMorning || _daytime > SYG_startNight ) then {_str1 = localize "STR_RUM_NIGHT";}
    else
    {
        //call compile format["_counter=%1;", localize "STR_RUM_NUM"];
        _counter = parseNumber (localize "STR_RUM_NUM");

        if ( isNil "SYG_rumor_index" ) then
        {
            SYG_rumor_index = floor (random _counter); // start index for current player connection
            SYG_rumor_hour  = floor(daytime); // initial hour of connection
        };

        // find the value of the drifting index corresponding to the time elapsed since the connection started
        _index = (floor(daytime) - SYG_rumor_hour + 24) mod 24; // current offset in hours  since connection
        _index = _index * _counter / 24; // new offset according to rumor number
        _index = round(((_index + SYG_rumor_index) + _counter) mod _counter); // found the value of the current index around which rumors will be created
        _rnd   = (random 2.0) - 1.0; // random offset each time, from +1 to -1
        _index = (_index + (floor((_rnd*_rnd*_rnd)*RUMOR_WIDTH)) + _counter) mod _counter ; // detected rumor index
        _index = (_index min (_counter - 1)) max 0; // to limit index with size of list
        _str1 = localize format["STR_RUM_%1",_index];
    #ifdef __DEBUG__
        hint localize format["+++ SYG_getRumourText: SYG_rumor_index %1, SYG_rumor_hour %2, _index %3, _rnd %4, _counter %5",
                                 SYG_rumor_index,SYG_rumor_hour,_index,_rnd,_counter];
    #endif
    };
    _name1 = (target_names call XfRandomArrayVal) select 1; // random main target name
    _name2 = text (player call SYG_nearestLocation); // nearest location name
    _name3 = text (player call SYG_nearestSettlement); // nearest settlement name
    format[_str1, _name1, _name2, _name3]; // just in case of usage %1 %2 %3 in string
};

//
// Joins string arrays into single string using designated separator
// call as: _str = [_arr,", "] call SYG_joinArr; // _str -> "item1, item2, item3"
//
SYG_joinArr = {
    private [ "_sep", "_arr", "_str", "_i" ];
    if ( typeName _this != "ARRAY" ) exitWith {"?#1"};
    if ( count _this < 2 ) exitWith {"?#2"};
    if ( typeName (_this select 0) != "ARRAY" ) exitWith {"?#3"};
    if ( count (_this select 0) == 0 ) exitWith {"?#4"};
    private ["_str", "_sep", "_arr"];
    _sep = _this select 1;
    if ( typeName _sep != "STRING" ) then { _sep = str(_sep) };
    _arr = _this select 0;
    _str = _arr select 0;
    if ( count _arr == 1) exitWith {_str};
    for "_i" from 1 to ((count _arr) - 1) do{ _str = format[ "%1%2%3", _str, _sep, _arr select _i] };
    _str
};

/*
 * Prepare string to print from vehicles array by converting them into type strings (typeOf _vehicle_obj)
 * Input: _result = [_veh_arr, _max_num_to_print] call SYG_objArrToTypeStr; // result = "[ACE_Abrams,ACE_UAZ,ACE_Mi24P,...25]"
 */
SYG_objArrToTypeStr = {
    if (typeName _this != "ARRAY") exitWith {"--- SYG_objArrToTypeStr: typeOf _this != ""ARRAY"""};
    if (count _this < 2) then {_this set[1, 10]};
    if (typeName (_this select 0) != "ARRAY") then {_this set [0, [_this select 0]]};

    private ["_arr","_print_cnt","_str","_i"];
    _arr = _this select 0;
    _print_cnt = _this select 1;
    _print_cnt = (count _arr) min _print_cnt; // print vehicles count
    if (  _print_cnt > 0 ) then // print only if there is some data to print
    {
        _str = "";
        for "_i" from 0 to _print_cnt - 1 do {
            if (_str == "") then  {_str = format["%1", typeOf (_check_vec_list select _i)];}
            else {_str = format["%1,%2",_str, typeOf (_check_vec_list select _i)]};
        };
        if ( ( count _check_vec_list ) > _print_cnt ) then {
            _str = format["%1,...%2",count _arr];
        };
        _str
    };
};