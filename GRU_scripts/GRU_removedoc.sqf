// GRU_removedoc.sqf, created by Sygsky on 10-DEC-2015
// removes ACE_map object from user
//
// added as follow:
// _menu_id = player addAction ["Уничтожить документ", "GRU_scripts\GRU_removedoc.sqf",[0], 1000]; // to be the top item in menu
// player setVariable ["remove_doc_id", _menu_id];
//
// Parameters array passed to the script upon activation in _this variable is: [target, caller, ID, arguments]

//
// also you can call script as follow: [0] execVM "GRU_scripts\GRU_removedoc.sqf"; // where 0 is a new GRU_docState value
//

#define __DEBUG__

#define arg(x) (_this select(x))
#define argp(arr,x) ((arr)select(x))

// remove ACE_Map
call GRU_removeDoc;

// remove action if present
call GRU_removeDocAction;

// handle with GRU document state
if (isNil "GRU_docState") exitWith {
#ifdef __DEBUG__
    hint localize "+++ GRU_removedoc.sqf: GRU_docState isNil = true, exit";
#endif
};
_val = GRU_docState;
if (count _this == 1) then {GRU_docState = arg(0);}  // this is call from script: [0] execVM "GRU_scripts\GRU_removedoc.sqf";
else {
	if ( count _this >= 4 ) then { // MUST be called from action (be carefull about this option)
		_this = arg(3);
		if ( count _this > 0) then {GRU_docState = arg(0)};
	};
};

#ifdef __DEBUG__
hint localize format[ "+++ GRU_removedoc.sqf: Action and Var removed, GRU_docState %1", if (GRU_docState == _val) then {format["not changed (%1)",GRU_docState]} else {format["changed from %1 to %2",_val,GRU_docState]}];
#endif


