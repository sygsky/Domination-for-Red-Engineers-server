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
// E.g.: _txt = "STR_RUM_NUM" call SYG_getLocalizedRandomText;//       _txt = "STR_SYS_252_NUM" call SYG_getLocalizedRandomText;
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
	for "_i" from 0 to count _chars - 4 do {
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
    if ( _daytime <= SYG_startMorning || _daytime > SYG_startNight ) then { _str1 = localize "STR_RUM_NIGHT" }
    else {
        //call compile format["_counter=%1;", localize "STR_RUM_NUM"];
        _counter = parseNumber (localize "STR_RUM_NUM"); // number of rumors on the island

        if ( isNil "SYG_rumor_index" ) then {
            SYG_rumor_index = floor (random _counter); // start index for current player connection
            SYG_rumor_hour  = floor(daytime); // initial hour of connection
        };

        // find the value of the drifting index corresponding to the time elapsed since the connection started
        _index = (floor(daytime) - SYG_rumor_hour + 24) mod 24; // current offset in hours  since connection
        _index = _index * _counter / 24; // new offset according to rumor number
        _index = round(((_index + SYG_rumor_index) + _counter) mod _counter); // found the value of the current index around which rumors will be created
        _rnd   = (random 2.0) - 1.0; // random offset each time, from -1 to +1
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
// call as: _str = [_arr,", "<, """">] call SYG_joinArr; // _str -> """item1"", ""item2"", ""item3"""
// call as: _str = [[],", "] call SYG_joinArr; // _str -> "..."
//
SYG_joinArr = {
    if ( typeName _this != "ARRAY" ) exitWith {"--SYG_joinArr:?#1"};
    if ( count _this < 2 ) exitWith {"--SYG_joinArr:?#2"};
    if ( typeName (_this select 0) != "ARRAY" ) exitWith {"--SYG_joinArr:?#3"};
    if ( count (_this select 0) == 0 ) exitWith {"..."};
    private [ "_sep", "_frm_ch", "_arr", "_str", "_i" ];
    _sep = _this select 1;
    _frm_ch  = if (count _this > 2) then {_this select 2} else {""};
    if ( typeName _sep != "STRING" ) then { _sep = str(_sep) };
    _arr = _this select 0;
    _str = format["%1", _arr select 0];
    if ( count _arr == 1) exitWith {_str};
    for "_i" from 1 to ((count _arr) - 1) do { _str = format[ "%1%2%4%3%4", _str, _sep, _arr select _i, _frm_ch] };
    _str
};

/*
 * Prepare string to print from vehicles array by converting them into type strings (typeOf _vehicle_obj)
 * Input: _result = [_veh_arr, _max_num_to_print] call SYG_objArrToTypeStr; // result = "ACE_Abrams,ACE_UAZ,ACE_Mi24P,...25"
 */
SYG_objArrToTypeStr = {
    if (typeName _this != "ARRAY") exitWith {"--- SYG_objArrToTypeStr: typeOf _this != ""ARRAY"""};
    if (typeName (_this select 0) == "OBJECT") then { _this = [_this, count _this]};
    if (count _this < 2) then {_this set[1, 10]};

    private ["_arr","_print_cnt","_str","_i"];
    _arr = _this select 0;
    _print_cnt = _this select 1;
    _print_cnt = (count _arr) min _print_cnt; // print vehicles count
    if (  _print_cnt > 0 ) then { // print only if there is some data to print
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


//
// call as: _multpliedText = [_srcText, _multiplicator] call SYG_textMultiply;
// E.g.: ["txt_",3] call  SYG_textMultiply => "txt_txt_txt_";
//
SYG_textMultiply = {
	toString (_this call SYG_textMultiplyArr)
};

//
// call as: _multpliedTextArr = [_srcText, _multiplicator] call SYG_textMultiplyArr;
// E.g.: ["txt_",3] call  SYG_textMultiply => ['t','x','t','_','t','x','t','_','t','x','t','_'];
//
SYG_textMultiplyArr = {
	private ["_txt","_mult","_res","_i","_x"];
	_txt = toArray (_this select 0);
	_mult = _this select 1;
	_res = [];
	for "_i" from 1 to _mult do {
		{ _res set [count _res, _x]} forEach _txt;
	};
	_res
};

//
// Align text  to left or right by designated width
// call as: _aligned_text = [_text, _align<,_align_symbol>] call SYG_textAlign;
// if align < 0 align is to left: ["align", -10] call SYG_textAlign => "align    ", if > 0 to right: ["align", +10] call SYG_textAlign => "     align"
// if align < string length, returned string is resized to size = abs(aligh)
// if _align == 0, empty string "" is returned
// if _align presents only 1st =ymbol is used as aligning one
//
SYG_textAlign = {
	private [ "_align", "_left", "_right", "_sym", "_empty", "_str", "_x" ];
	_sym = if (count _this > 2) then { toArray (_this select 2)} else {toArray " "};
	_sym resize 1;
	_sym = toString _sym;

	_align = _this select 1;
	_empty = false;
	// prepare left and rihht part to combine in lower code
	if (typeName _align == "STRING") then { // Add symbols from left [20, _text]
		_align = _this select 0;
		if (_align == 0) exitWith { _empty = true };
		_right = toArray(_this select 1); // text is here
		if (_align <= (count _right)) exitWith { _right resize _align; _left = [] };
		_left = [_sym, _align - (count _right)] call SYG_textMultiplyArr;
	} else  { // Add symbols from right [_text,20];
		if (_align == 0) exitWith { _empty = true};
		_left = toArray (_this select 0); // text is here
		if (_align <= (count _left)) exitWith { _left resize _align; __right = [] };
		_right = [_sym, _align - (count _left)] call SYG_textMultiplyArr;
	};
//	_str = format["+++ SYG_textAlign: _sym ""%1"",  _left ""%2"", _right ""%3""", _sym, _align, _left, _right];
//	hint localize _str; player groupChat _str;
	if (_empty) exitWith { "" };
	{ _left set [count _left, _x] } forEach _right;
	toString _left
};

//
// Compact array of names (strings) by print count after repetitive names.
// NOTE: don't designate non-string array as input one as resulted array items all will be strings!
// call as: _new_arr = _old_arr call SYG_compactArray;
// E.g.:  _old_arr = [0,0,"lolport",170,"RESCUE",
//                    ["Binocular","ACE_Dragon","ACE_SCAR_H_CQB_mk4"],
//                    [
//                     "ACE_Dragon","ACE_20Rnd_762x51_SB_SCAR_CQB","ACE_20Rnd_762x51_SB_SCAR_CQB","ACE_20Rnd_762x51_SB_SCAR_CQB",
//                     "ACE_20Rnd_762x51_SB_SCAR_CQB","ACE_20Rnd_762x51_SB_SCAR_CQB","ACE_20Rnd_762x51_SB_SCAR_CQB"
//                    ],
//                    "ACE_Rucksack_Alice",[["ACE_Dragon_PDM",2]],1500,0
//                   ];
//     _new_arr = [0,0,"lolport",170,"RESCUE",
//                  ["Binocular","ACE_Dragon","ACE_SCAR_H_CQB_mk4"],
//                  ["ACE_Dragon","ACE_20Rnd_762x51_SB_SCAR_CQB(6)"],
//                  "ACE_Rucksack_Alice",[["ACE_Dragon_PDM",2]],1500,0
//               ];
//
SYG_compactArray = {
    // compact equipment array strings
    if (typeName _this != "ARRAY") exitWith {
    	hint localize format["--- SYG_compactArray: _this is not ARRAY (%1), exit!", typeName _this];
    	_this
    };
    private ["_items", "_counts","_i", "_arr", "_type", "_ind", "_x"];
    _items  = [];
    _counts = [];

    {
    	_type = typeName _x;
    	if ( _type == "ARRAY") then {
			_items  set [count _items, _x call SYG_compactArray];
			_counts set [count _counts, 1];
    	} else {
    		if (_type == "") then {_x = "<nil>"; _type = "STRING"};
			_ind = _items find _x;
			if (_ind < 0) then { // uknown item, add it to the list
				_items  set [count _items, _x];
				_counts set [count _counts, 1];
			} else { // item known, compact if string else copy to output
				if ( _type != "STRING") then { // non-string items (arrays, scalar, object etc
					_items  set [count _items, _x];
					_counts set [count _counts, 1];
				} else { // count item
					_counts set [_ind, (_counts select _ind) + 1];
				};
			};
    	};
    } forEach _this;

// 	hint localize format["+++ SYG_compactArray: _items  = %1", _items];
// 	hint localize format["+++ SYG_compactArray: _counts = %1", _counts];

	_arr = [];
    for "_i" from 0 to count _items - 1 do {
    	_x = _counts select _i;
    	if (_x > 1) then { _arr set [_i, format["%1(%2)", _items select _i, _x]]} else { _arr set [_i, _items select _i]};
    };
	_arr
};

//
// call: _arr = _arr_str call SYG_str2Arr;
//
SYG_str2Arr = {
    call compile _this
};

//
// call: _arr = _arr_str call SYG_arr2Str;
//
SYG_arr2Str = {
	if (typeName _this == "") exitWith {"nil"}; // nil => "nil" must be 1st in procedure or follow condition if will give unpredictable results!
	if (typeName _this == "ARRAY") exitWith {
		private ["_str","_str1","_x"];
		_str = "";
		{
//			hint localize format["+++ _x = %1", _x];
			if (isNil "_x") then { // this is <nil>
				if (_str == "") then  {_str = "nil"} else {_str = format["%1,nil", _str]};
			} else {
				if (typeName _x == "ARRAY") exitWith {
					if (_str == "") then  {_str = _x call SYG_arr2Str} else { _str1 = _x call SYG_arr2Str; _str = format["%1,%2", _str, _str1]};
				};
				if (typeName _x == "STRING") exitWith {
					if (_str == "") then  {_str = format["""%1""", _x]} else {_str = format["%1,""%2""", _str, _x]};
				};
				// any other value found
				if (_str == "") then  {_str = format["%1", _x]} else {_str = format["%1,%2", _str, _x]};
			};
//			hint localize format["+++ _str = %1", _str];
		} forEach _this;
		format["[%1]", _str]
	};
	if (typeName _this == "STRING") exitWith {format["""%1""", _this]};
    format["%1", _this]
};

// this procedure parse and processs "msg_to_user" server command or compound client message
// In any message to user, param numbers are:
// Offsets:     0,                      1,                 2,                        3,              4,             5,             6
// ["msg_to_user",_player_name | "*" | "",[_msg1, ... _msgN]<,_delay_between_messages<,_initial_delay<,no_title_msg><,sound_name>>>>]
//
// Offset in command array are as follow:
// 0:"msg_to_user": the identifier for this command, must be present
// 1: player name or "" or "*" or vehicle to inform crew only, or array of players, or array of vehicles. Must be present!
// 2: array of each _msg format as is: [<"localize",>"STR_MSG_###"<,<"localize",>_str_format_param...>];. Must be present!
// 3: _delay_between_messages is seconds number to sleep between multiple messages;
// 4: _initial_delay is seconds before first message show;
// 5: no_title_msg if true - no title shown, else shown if false or "" empty string, or scalar <= 0;
// 6: sound_name is the name of the sound to play with first message show on 'say' command; no way to play sound on each message.
//		Or 6th  parameters is an array with follow items:	["say_sound", _object_to_play_sound, "sound_name" ]; // send sound from this player
//
// msg is displayed using titleText ["...", "PLAIN DOWN"] in common(blue)/vehicle(yellow) chat
// msg additionally displayed as title in the middle of the screen

SYG_msgToUserParser = {

	if ((count _this) == 0) exitWith {"--- SYG_msgToUserParser: input array is empty!!!"};
    private [ "_msg_arr","_msg_fmt","_name","_np","_delay","_localize","_vehicle_chat","_print_title","_msg_formatted","_sound",
     "_msg_target_found","_ind","_SYG_processSingleStr","_str","_no_negate","_x"];

    //
    // call as: _newStr = _str call _SYG_processSingleStr; // _str is localized or not localized depending on its value.
    //  if _str start with "STR" (case sensitive) it is localized in any case!!!
    //
    _SYG_processSingleStr = {
        private ["_str"];
        _str = toArray(toUpper(_this)); // e.g. [83,84,82,95,83,89,83,95,54,48,52] for  "STR_SYS_604"
        if ( count _str <= 4) exitWith {_this};
        // [83,84,82]
        if ( (_str select 0 == 83) && (_str select 1 == 84) && (_str select 2 == 82) && (_str select 3 == 95) ) exitWith {localize _this };
        _this
    };

    _name = _this select 1;
    _msg_target_found = false;
    _vehicle_chat = false;
    _np = name player;
    _no_negate = false;

    // hint localize format["msg_to_user ""%1"":%2", _name, _this select 2];
    if  (typeName _name == "ARRAY") then { // list of names is expected
        if ( count _name == 0) then {_name = "";} // all players are addressed
        else {
//        	_str = _name select 0;
//			if (typeName  _str == "STRING") then { // negate sign is detected as 1st item in the array
//				if ( _str in ['-',"!" ] ) exitWith {
//					_no_negate = true;
//					[_name, 0] call SYG_removeFromArrayByIndex; // remove 1st item from array
//				};
//			};
        	if (count _name == 2) then {
        		if (typeName (_name select 0) == "SCALAR") exitWith { // special case: [_dist, _pos] as 2nd parameter
        			if (player distance (_name select 1) <= (_name select 0) ) then { // you are close enough to the designated position
        				_name = [_np];
        			};
        		};
        	};
            _ind = _name find (_np);
            if ( _ind >= 0) then {
                _name = _np;
                _msg_target_found = true;
            } else { // player name not found in the input array, verify player vehicle too
            	if ( (vehicle player) in _name ) then { _name = vehicle player } else {_name = _name select 0};
            };
        };
    };

    if (typeName _name == "OBJECT") then { // is msg is sent to the vehicle team only
        _msg_target_found = vehicle player == _name;
        _vehicle_chat = _msg_target_found;
    } else {
    	if (typeName _name == "STRING") then { _msg_target_found = _name in [_np, "", "*"," "]; };
    };

    if ( !_msg_target_found ) exitWith {}; // target for message not found

    // check for initial delay

    if ( (count _this) > 4) then {
        if ( (_this select 4) > 0 ) then {
            sleep ( _this select 4 );
        };
        // try to say sound on 1st text showing
        if ( (count _this) > 6 ) then {
            _sound = _this select 6;
            if ( typeName _sound == "STRING" ) exitWith { playSound _sound };
            if (typeName _sound == "ARRAY") exitWith {
            	if (count _sound > 2) then {
            		if ( (_sound select 0) == "say_sound") exitWith {
            			_sound call XHandleNetStartScriptClient; // say sound on this client
            		};
            		// TODO: Or it is any other client message to player
            	};
            };
        };
    };
    _delay = 4; // default delay between messages is 4 seconds
    if ( count _this > 3 ) then {
        if ( (_this select 3) > 0 ) then { _delay = (_this select 4) max 4}; // minimum delay is 4 seconds
    };

    _msg_arr = _this select 2;
#ifdef __PRINT__
    hint localize format["+++ SYG_msgToUserParser: %1", _this];
#endif

	if ( typeName (_msg_arr select 0) != "ARRAY") then { // allow to use single message without array envelope
		_msg_arr = [_msg_arr]
	};
	//
	{
        if (typeName _x == "STRING") then { // it is not array but single string, put it to array and process as usuall
            _x = [_x]; // emulate as array with single item
        };
        // all string are localized only if previous string is "localize" (is skipped from output) or is of format "STR..."
        _localize = false;
        _msg_fmt = [];
        {
            if ( _localize ) then {
                _msg_fmt set [count _msg_fmt, localize (_x)]; // localize this format item
                _localize = false;
            } else {
                if (typeName _x == "STRING" ) then {
                    if ( toLower(_x) == "localize") exitWith { _localize = true; }; // Let's localize next string if it will exists
                    _str = _x call _SYG_processSingleStr;
                    _msg_fmt set [ count _msg_fmt, _str ];
                } else {
                    _msg_fmt set [count _msg_fmt, _x]; // not localize this format item
                };
            };
        } forEach _x; // parse each format item. Any item MUST be an array (or single string without following parameters, or array with a single string, doesnt matter)

        _print_title = (count _this) < 6; // if no setting, let print title in screen middle, not only radio message at bottom
        if (!_print_title) then { // value detected in param array, read and parse it
            _print_title = _this select 5; // it may be boolean (true/false) or scalar (<=0 :false else true)
            if ( typeName _print_title == "SCALAR")  // number <= 0 (false); number > 0 (true)
            then {_print_title = (_print_title <= 0)} // print only if value set to false
            else {_print_title = (!_print_title)}; // parse as boolean value, print if value == false
        };

        _msg_formatted = format _msg_fmt; // whole message formatted
 //       hint localize format["+++ ""msg_to_user"": _x %1, _msg_fmt = %2", _x, _msg_fmt];
        if ( _print_title ) then { // no title text disable parameter
            titleText[ _msg_formatted, "PLAIN DOWN" ];
        };

        if (_vehicle_chat) then {
            [_name, _msg_formatted call XfRemoveLineBreak] call XfVehicleChat;
        } else {
            ( _msg_formatted call XfRemoveLineBreak) call XfGlobalChat;
        };

//					hint localize format["msg_to_user: format %1, titleText ""%2""", _msg_fmt, format _msg_fmt];
        if ( (_delay > 0) && ((count _msg_arr) > 1 )) then { sleep _delay; };
    } forEach _msg_arr; // for each messages: _x is format parameters array
};

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
// Gets name of killer in any case, or direct name of unit as gunner in some vehicle
// killer can be:
// a man => name _killer
// a gunner of land vehicle/heli/plane => gunner _killer
// a pilot of plane => driver _killer
// call as: _unit_name = _unit call SYG_getUnitName;
//
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
SYG_getUnitName = {
	if ( _this isKindOf "Man" ) exitWith { name _this };
	if ( !(_this isKindOf "AllVehicles") ) exitWith { "<unknown>" };
	if ( !(isNull (gunner _this) ) ) exitWith { name (gunner _this) };
	if ( !(isNull (driver _this) ) ) exitWith { name (driver _this) };
	if ( !(isNull (commander _this) ) ) exitWith { name (commander _this) };
	"<unknown>"
};

//
// Gets string with killer info: {name of player/unit}<(vehicle type)>
//
SYG_getKillerInfo = {
	private ["_veh","_name"];
	if (isNull _this) exitWith {"<null>"};
	_veh = vehicle _this;
	_name = _veh call SYG_getUnitName;
	if ( _veh == _this) exitWith { _name };
	format["%1(%2)", _name, typeOf _veh];
};

//
// _text call SYG_typeWriter;
// or: [_text,_sound, _sound_len<,_whole_time_in_secs>] call SYG_typeWriter;
//
SYG_typeWriter = {
	private ["_text","_sound","_dur","_arr","_chars","_time","_napis","_i","_last_id","_dt"];
	if ( typeName _this == "STRING") then {
		_text  = _this;
		_sound = "typewriter2";
		_dur   =  0.337;
	} else {
		_text  = _this select 0;
		_sound = _this select 1;
		_dur   =  _this select 2;
	};
	_dur = _dur + 0.1;
	_arr = toArray _text;
//	_text = ["M","o","n","d","a","y",","," ","0","1"," ","A","u","g","u","s","t",","," ","1","9","8","5","\n","\n","N","e","a","r"," ","A","n","t","i","g","u","a"];
	_chars = [];
	_time = time;
	cutText ["", "BLACK FADED", 1];
	_napis = "";
	sleep 1;
	_last_id = count _arr - 1;
	for "_i" from 0 to _last_id do {
		_chars set [_i, _arr select _i];
		_napis = toString(_chars);
		//;hint format ["%1", _napis]
		titleText [_napis, "PLAIN",_dur];
		playsound _sound;
		sleep     _dur;
	};
	if (count _this > 3) then {
		_dt = (_this select 3) - (time - _time); // sleep more time ot not?
		if (_dt > 0) then {sleep _dt};
	};
//	sleep 15;
    cutText ["", "BLACK IN", 1];
};