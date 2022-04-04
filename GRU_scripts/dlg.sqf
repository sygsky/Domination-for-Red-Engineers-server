// dlg.sqf, created by Sygsky at 01-DEC-2015, run on client
// shows GRU tasks dialog and process its result
//
// call: _has_only_pistol execVM "GRU_scripts\dlg.sqf";
// player groupChat
//
#include "x_setup.sqf"
#include "GRU_setup.sqf"

#define ACCEPT_BTN_ID 12004
#define CANCEL_BTN_ID 12003
#define INFO_TEXT_ID 12200
#define LOGO_PICTURE_ID 12001

//#define __DEBUG__

#ifdef __DEBUG__
	hint localize format["dlg.sqf: run with params %1", _this];
#endif


private ["_ret_code","_str"];

dialog_ret = -1;

_ret_code = -1;

_only_pistol = _this;
_ok = createDialog "GRUPortalDialog";
sleep 0.1;
_GRU_display = findDisplay 12000;

_ctrl = _GRU_display displayCtrl LOGO_PICTURE_ID; // picture control

//_ctrl ctrlSetText "img\red_star_64x64.paa";
_ctrl ctrlSetText "\ace_sys_map\i\ace_map_equip.paa";
//btnAccept = _GRU_display displayCtrl 12004;

//ctrlShow [12004, false]; // default "Accept" button disabled
//ctrlEnable [12004, false];
ctrlEnable[CANCEL_BTN_ID, true]; // default "Escape" button is enabled
ctrlEnable [ACCEPT_BTN_ID, false];

//buttonSetAction [12004, "closeDialog 0;"];

infoText = _GRU_display displayCtrl 12200;

_pistol_only = arg(0);
// fill the dialog with task titles
_i   = 0;
_cnt = 1;
info_arr = [];
_info = [];

{
	if ( TASK_IS_ACTIVE(_x) ) then {
#ifdef __DEBUG__
		hint localize format["dlg.sqf: task ID %1 is active", _i];
#endif	
		_id = 12100 + _cnt;
		_ctrl = _GRU_display displayCtrl _id;
		_str = format["%1. %2",_cnt, localize format["STR_GRU_TASK_DESCR_%1_TITLE", _i]];
		ctrlSetText [_id,_str]; // set title for any task
//		_action_str = format["ctrlSetText [12200, info_arr select %1];",_i]; // load description text into box on click
		_info = [ "" ];
		if ( _i == GRU_MAIN_TASK ) then {
			//ctrlSetText [12200, call GRU_mainTaskDescription];
			_ret_code = -2;
			if (_pistol_only) then {
				ctrlEnable [ _id, true];
//				ctrlActivate [_ctrl, true];
//				_action_str = _action_str + format[" ctrlShow[12004, true]; ctrlEnable [12004, true]; dialog_ret = %1;",GRU_MAIN_TASK]; // enable "Accept" button
			} else {
				ctrlEnable [ _id, false]; // no task button as illegal weapon detected
			};
			_info set [_i, call GRU_mainTaskDescription]; // set text of order
			[1] execVM "x_scripts\x_showsidemain.sqf"; // go to the main target on the map
		} else {
			_info set [_i,(localize format["STR_GRU_TASK_DESCR_%1_INFO", _i]) ];
			//_action_str = _action_str + " ctrlShow [12004, false];  dialog_ret = -1;"; // disable accept button
		};
		info_arr = info_arr + [ _info ]; // set information
		_cnt = _cnt + 1;
	};
	_i = _i + 1;
} forEach GRU_tasks;

// hide not used lines
if ( _cnt <= GRU_TASK_NUMBER ) then {
	for "_j" from _cnt to GRU_TASK_NUMBER do {
		_id = 12100 + _j;
		_ctrl = _GRU_display displayCtrl _id;
		if ( !isNull _ctrl) then {
			ctrlShow [_id, false]; 
#ifdef __DEBUG__			
			hint localize format[ "+++ dlg.sqf: ctrl %1 shown = %2", _id, ctrlShown _ctrl];
#endif			
		};
	};
};

waitUntil { sleep 0.5; !dialog || !alive player};

if ( alive player ) then {
	switch  dialog_ret do {
		case -1:  {	// cancel button clicked (or "Escape" btn pushed)
			// -1: "ничего кроме пистолета!", any other: "Сеанс связи с ГРУ закончен"
			_str = localize "STR_GRU_27"; 
			if ( !_pistol_only ) then { _str = format["%1.\n%2",_str, localize "STR_COMP_3"];};
			titleText[ _str, "PLAIN DOWN" ];  
		};
		case GRU_MAIN_TASK: {
			_task = GRU_GET_TASK (GRU_MAIN_TASK);
			// find town and battle radious
			private ["_tt"];
			_tt =  call SYG_getTargetTown;
			_score_plus = [GRU_MAIN_GET_TOWN_CENTER,GRU_MAIN_GET_TOWN_RADIOUS,true] call SYG_getScore4IntelTask;
			_score_minus = GRU_MAIN_GET_SCORE_MINUS(_score_plus);
#ifdef __RANKED__
			[ argp(argp(SYG_intelObjects,0),0), 10, _score_plus, d_ranked_a select 24 ] execVM "GRU_scripts\GRU_townraid.sqf";
#else
			[ argp(argp(SYG_intelObjects,0),0), 10, _score_plus, -_score_minus ] execVM "GRU_scripts\GRU_townraid.sqf";
#endif
		};
		default // "Непонятно что произошло..."
		{
			titleText [ format[localize "STR_GRU_28",_ret_code],"PLAIN DOWN" ];
		}; 
	};
};

if ( dialog) then { closeDialog 12000; };
