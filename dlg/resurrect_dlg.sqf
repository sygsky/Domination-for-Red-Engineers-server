//
// by Sygsky at 2016-JAN-14. dlg/resurrect_dlg.sqf, called only on client computer
//
// call as follow: [_max_num, _rad_step execVM "dlg\resurrect-dlg.sqf"]
//

#define __DEBUG__
if (! X_Client) exitWith {};
private ["_ok","_XD_display","_ctrl","_index","_max_num","_rad_step","_score","_item"];

//
// call: _arr = [_unit|_object, max_num<, _radious_step>] call SYG_makeRestoreArray;
// result: [[num1, radious1]<,...[numN1, radiousN]>] where num# is number of restorable objects found in radious#
//

#include "x_setup.sqf"
#include "x_macros.sqf"

#define __DEBUG__

#define DEFAULT_RADIOUS_STEP 5
#define DEFAULT_RADIOUS_MAX 100

//player groupChat format["dlg/resurrect_dlg.sqf: _this=%1", _this];

if ( (typeName _this) == "ARRAY") then
{
    _max_num = arg( 0 ); // max number of resurrection to use
    _rad_step = argopt( 1, DEFAULT_RADIOUS_STEP); // step along radious
}
else
{
    _max_num = _this;
    _rad_step = DEFAULT_RADIOUS_STEP ;
};

#define __DEBUG__

_ok = createDialog "XD_ResurrectDialog";

_XD_display = findDisplay 13000;

_ctrl = _XD_display displayCtrl 1000;


//player groupChat format["SYG_makeRestoreArray returned %1", SYG_resurrect_array];

// set tooltip ("low rank"/"number of lines" etc)
_rankNeeded = (d_ranked_a select 26) call XGetRankIndex;

// get rank of caller
_rankPlayerStr = (score player) call XGetRankFromScore;
_rankPlayer = _rankPlayerStr call XGetRankIndex;

#ifdef __DEBUG__
hint localize format["rank needed %1, rank player %2",_rankNeeded,_rankPlayer];
if ( _rankNeeded > _rankPlayer) then { // inform user about his rank to be too low
    player addScore 100;
    sleep 1;
};
#endif

if ( _rankNeeded > _rankPlayer) then // inform user about his rank to be too low
{
    _ctrl ctrlSetTooltip (format[localize "STR_RESTORE_DLG_10",_rankPlayerStr call XGetRankStringLocalized]);
    _max_num = 0;
    SYG_resurrect_array = [];
}
else
{
    // prepare array with resurrect radious and costs
    // _arr = [_unit|_object, max_num<, _radious_step>] call SYG_makeRestoreArray;
    if ( _max_num == 0) then // get maximum from user score
    {
        _max_num = floor((score player) / 3);
    };
    SYG_resurrect_array = [player, _max_num, _rad_step, DEFAULT_RADIOUS_MAX] call SYG_makeRestoreArray; // get array for resurrection options
    _cnt = count SYG_resurrect_array;
    if ( _cnt == 0) then
    {
        _ctrl ctrlSetTooltip (localize "STR_RESTORE_DLG_9"); // say about absence of restore action
    }
    else
    {
        _ctrl ctrlSetTooltip format[localize "STR_RESTORE_DLG_5", _cnt]; // help user to find way of action
    };
};

_ctrl lbAdd (localize "STR_RESTORE_DLG_6"); //"nothing";
{
    _index = _ctrl lbAdd format[localize "STR_RESTORE_DLG_8",argp(_x,0), argp(_x,1)]; // "%1 item[s] up to the %2 m."
} forEach SYG_resurrect_array;

_ctrl lbSetCurSel 0;

waitUntil {!dialog || !alive player};

if (!alive player) then {
	closeDialog 13000;
}
else
{
    if (! (isNil "SYG_resurrect_array_index")) then // list was selected
    {
        //player groupChat format["SYG_resurrect_array_index=%1",SYG_resurrect_array_index ];
        if ( (SYG_resurrect_array_index > 0) && ((count SYG_resurrect_array) > 0) ) then // some value is selected
        {
            _item = argp(SYG_resurrect_array,SYG_resurrect_array_index-1);
            // Send info about restoration parameters to the server
            ["syg_plants_restore",name player, getPos player, argp(_item,1)] call XSendNetStartScriptServer;
        };
    };
};

SYG_resurrect_array_index = nil;
SYG_resurrect_array = [];
sleep 0.01;
SYG_resurrect_array = nil;
if (true) exitWith {};