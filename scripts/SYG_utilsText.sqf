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
