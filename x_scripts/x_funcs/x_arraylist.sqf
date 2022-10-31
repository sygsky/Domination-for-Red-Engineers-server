// by Xeno
x_arraylist_compiled = false;

// weird... an ArrayList implementation

// adds an element to an ArrayList
// parameters: array var as string, element to add
// example ["_myArrayList",_element] call XfArrayListAdd;
XfArrayListAdd = {
	[_this select 0, _this select 1] call XfStackPush
};

// adds an array range (simply another array) to an ArrayList
// parameters: array var as string, array to add
// example ["_myArrayList",_arraytoadd] call XfArrayListAddRange;
XfArrayListAddRange = {
	call compile format ["%1 = %1 + (_this select 1);", (_this select 0)];
};

// clears an ArrayList
// parameters: array var as string (no brackets)
// example "_myArrayList" call XfArrayListClear;
XfArrayListClear = {
	call compile format ["%1 = [];", _this];
};

// clones an ArrayList
// parameters: array var as string (no brackets)
// example _clone = "_myArrayList" call XfArrayListClone;
XfArrayListClone = {
	private ["_clone"];
	call compile format ["_clone =+ %1;", _this];
	_clone
};

// checks if an item is in an ArrayList 
// parameters: array var as string, item to search for, supports also items that are arrays
// example _contains = ["_myArrayList",_searchitem] call XfArrayListContains;
XfArrayListContains = {
    private ["_ar","_it","_ret","_arl","_x"];
	_ar = _this select 0;_it = _this select 1;_ret = false;
	if (typeName _it != "ARRAY") then {
		call compile format ["_ret = _it in %1;", _ar]
	} else {
		_arl = [];
		 call compile format ["_arl = %1", _ar];
		{if (str _x == str _it) exitWith {_ret = true}} forEach _arl;
	};
	_ret
};

// copies an arraylist to a new array 
// parameters: array var as string, start index, end index
// example _newlist = ["_myArrayList",_startindex, _endindex] call XfArrayListCopyTo;
// example _newlist = ["_myArrayList",_startindex] call XfArrayListCopyTo;
// example _newlist = ["_myArrayList"] call XfArrayListCopyTo;
XfArrayListCopyTo = {
	private ["_ar","_si","_ei","_ret","_i"];
	_ar = call compile format ["%1",_this select 0];
	_si = if (count _this > 1) then {_this select 1} else {0};
	_ei = if (count _this > 2) then {_this select 2} else {count _ar - 1};
	_ret = [];
	if (_si == 0 && (_ei == count _ar - 1)) then {
		_ret =+ _ar;
	} else {
		for "_i" from _si to _ei do {_ret = _ret + [_ar select _i]}
	};
	_ret
};

// checks if two ArrayLists are equal
// parameters: array1 var as string, array2 var as string
// example _equal = ["_myArrayList1","_myArrayList2"] call XfArrayListEquals;
XfArrayListEquals = {
	call compile format ["[%1, %2] call XfArrayCompare;", (_this select 0), (_this select 1)]
};

// gets a range of items of an ArrayList starting at index _startindex
// parameters: array1 var as string, start index, count
// example _range = ["_myArrayList1",_startindex, 5] call XfArrayListGetRange;
XfArrayListGetRange = {
	private ["_ar","_si","_count","_ret","_i"];
	_ar = call compile format ["%1",_this select 0];_si = _this select 1;_count = _this select 2;_ret = [];
	for "_i" from _si to (_si + _count) do {_ret = _ret + [_ar select _i];};
	_ret
};

// gets index of an ArrayLists item
// parameters: array var as string, item fo find,  start index, end index
// example _index = ["_myArrayList1",_vehicle,_startindex, _endindex] call XfArrayListIndexOf;
// example _index = ["_myArrayList1",_vehicle,_startindex] call XfArrayListIndexOf;
// example _index = ["_myArrayList1", _vehicle] call XfArrayListIndexOf;
XfArrayListIndexOf = {
	private ["_ar","_obj","_si","_ei","_index","_i"];
	_ar = call compile format ["%1",_this select 0];
	_obj = _this select 1;
	_si = if (count _this > 2) then {_this select 2} else {0};
	_ei = if (count _this > 3) then {_this select 3} else {count _ar - 1};
	_index = -1;
	if (_si == 0 && _ei == (count _ar - 1)) then {
		_index = _ar find _obj;
	} else {
		for "_i" from _si to _ei do {if (_ar select _i == _obj) exitWith {_index = _i;};};
	};
	_index
};

// inserts an item at position index in an ArrayList
// parameters: array var as string, insert index,  item to insert
// example ["_myArrayList1",_index,_item] call XfArrayListInsert;
XfArrayListInsert = {
	private ["_ar","_obj","_index","_i","_h"];
	_ar = _this select 0;
	_index = _this select 1;
	_obj = _this select 2;
	if (_index == 0) then {
		call compile format ["%1 = [_obj] + %1;", _ar];
	} else {
		_h = [];
		call compile format ["for ""_i"" from 0 to (count %1 - 1) do {if (_i == _index) then {_h = _h + [_obj];};_h = _h + [%1 select _i];};%1 = _h;", _ar];
	};
};

// inserts a other array (list) at position index in an ArrayList
// parameters: array var as string, insert index,  array var
// example ["_myArrayList1",_index,_array] call XfArrayListInsertRange;
XfArrayListInsertRange = {
	private ["_ar","_obj","_index","_i"];
	_ar = _this select 0;
	_index = _this select 1;
	_obj = _this select 2;
	if (_index == 0) then {
		call compile format ["%1 = _obj + %1;", _ar];
	} else {
		_h = [];
		call compile format ["for ""_i"" from 0 to (count %1 - 1) do {if (_i == _index) then {_h = _h + _obj;};_h = _h + [%1 select _i];};%1 = _h;", _ar];
	};
};

// get the last index of an item in an ArrayList
// parameters: array var as string, object, start index,  end index
// example _lastindexof =["_myArrayList1",_vehicle,_startindex,_endindex] call XfArrayListLastIndexOf;
// example _lastindexof =["_myArrayList1",_vehicle,_startindex] call XfArrayListLastIndexOf;
// example _lastindexof =["_myArrayList1",_vehicle] call XfArrayListLastIndexOf;
XfArrayListLastIndexOf = {
	private ["_ar","_obj","_si","_ei","_index","_i"];
	_ar = call compile format ["%1",_this select 0];
	_obj = _this select 1;
	_si = if (count _this > 2) then {_this select 2} else {0};
	_ei = if (count _this > 3) then {_this select 3} else {count _ar - 1};
	_index = -1;
	for "_i" from _ei to _si step -1 do {if (_ar select _i == _obj) exitWith {_index = _i}};
	_index
};

// remove the first found item in an ArrayList, removes array items too
// parameters: array var as string, object
// example ["_myArrayList1",_vehicle] call XfArrayListRemove;
XfArrayListRemove = {
	private ["_ar","_obj","_i","_hi"];
	_ar = _this select 0;
	_obj = _this select 1;
	if (typeName _obj != "ARRAY") then {
		call compile format ["
			for ""_i"" from 0 to (count %1 - 1) do {if ((%1 select _i) == _obj) exitWith {%1 set [_i, ""YXZ_DEL_Q_X76""];};};
			%1 = %1 - [""YXZ_DEL_Q_X76""];
		", _ar];
	} else {
		call compile format ["
			_hi = -1;
			for ""_i"" from 0 to (count %1 - 1) do {if ([(%1 select _i), _obj] call XfArrayCompare) exitWith {%1 set [_i, ""YXZ_DEL_Q_X76""];};};
			%1 = %1 - [""YXZ_DEL_Q_X76""];
		", _ar];
	};
};

// remove an item at index position in an ArrayList
// parameters: array var as string, index
// example ["_myArrayList1",_index] call XfArrayListRemoveAt;
XfArrayListRemoveAt = {
	private ["_ar","_index"];
	_ar = _this select 0;_index = _this select 1;
	call compile format ["
		%1 set [_index, ""YXZ_DEL_Q_X76""];
		%1 = %1 - [""YXZ_DEL_Q_X76""];
	", _ar];
};

// remove a range of items in an ArrayList
// parameters: array var as string, start index, end index
// example ["_myArrayList1",_startindex, _endindex] call XfArrayListRemoveRange;
XfArrayListRemoveRange = {
	private ["_ar","_index","_si","_ei","_i"];
	_ar = _this select 0;_si = _this select 1;_ei = _this select 2;
	call compile format ["
		for ""_i"" from _si to _ei do {%1 set [_i, ""YXZ_DEL_Q_X76""];};
		%1 = %1 - [""YXZ_DEL_Q_X76""];
	", _ar];
};

// reverts an ArrayList
// parameters: array var as string, _startindex, _endindex
// example ["_myArrayList1", _startindex, _endindex] call XfArrayListReverse;
// example ["_myArrayList1"] call XfArrayListReverse;
XfArrayListReverse = {
	private ["_ar","_si","_ei","_h","_h2","_co","_i"];
	_ar = _this select 0;
	_si = if (count _this > 2) then {_this select 1} else {0};
	call compile format ["_co = (count %1 - 1);",_ar];
	_ei = if (count _this > 3) then {_this select 2} else {_co};
	_h = [_ar,_si, _ei - _si] call XfArrayListGetRange;
	_h2 = [];
	for "_i" from (count _h - 1) to 0 step - 1 do {_h2 = _h2 + [_h select _i];};
	call compile format ["%1 = ([_ar,0,_si - 1] call XfArrayListGetRange) + _h2 + ([_ar,_ei + 1,_co - _ei - 1] call XfArrayListGetRange);",_ar];
};

// sets a range in an ArrayList to the values of the replacement array
// parameters: array var as string,index, _replacearray
// example ["_myArrayList1", _index, _newarray] call XfArrayListSetRange;
XfArrayListSetRange = {
	private ["_ar","_index","_ra","_i"];
	_ar = _this select 0;_index = _this select 1;_ra = _this select 2;
	call compile format ["
		for ""_i"" from 0 to (count _ra - 1) do {%1 set [_index + _i, (_ra select _i)];};
	", _ar];
};

// converts an ArrayList to a string
// parameters: array var as string (without brackets)
// example _string = "_myArrayList1" call XfArrayListToString;
XfArrayListToString = {
	private ["_ar"];
	_ar = call compile format ["%1",_this];
	str (_ar)
};

// comparer functions for sort
XfNumberGreaterComparer = {
	(_this select 0) > (_this select 1)
};

XfNumberLessComparer = {
	(_this select 0) < (_this select 1)
};

XfStringGreaterComparer = {
	private ["_ta1","_ta2","_st","_ret","_i"];
	_ta1 = toArray (_this select 0);
	_ta2 = toArray (_this select 1);
	_st = (if (count _ta1 > count _ta2) then {(count _ta1 - 1)} else {if (count _ta1 < count _ta2) then {(count _ta2 - 1)} else {(count _ta1 - 1)};});
	_ret = false;
	for "_i" from 0 to _st do {
		if ((_ta1 select _i) > (_ta2 select _i)) exitWith {_ret = true};
		if ((_ta1 select _i) < (_ta2 select _i)) exitWith {_ret = false};
	};
	_ret
};

XfStringLessComparer = {
	private ["_ta1","_ta2","_st","_ret","_i"];
	_ta1 = toArray (_this select 0);
	_ta2 = toArray (_this select 1);
	_st = (if (count _ta1 > count _ta2) then {(count _ta1 - 1)} else {if (count _ta1 < count _ta2) then {(count _ta2 - 1)} else {(count _ta1 - 1)};});
	_ret = false;
	for "_i" from 0 to _st do {
		if ((_ta1 select _i) < (_ta2 select _i)) exitWith {_ret = true};
		if ((_ta1 select _i) > (_ta2 select _i)) exitWith {_ret = false};
	};
	_ret
};

XfObjectGreaterComparer = XfNumberGreaterComparer;

XfObjectLessComparer = XfNumberLessComparer;

XfArrayGreaterComparer = {
	private ["_ars1","_ars2"];
	_ars1 = format ["%1",(_this select 0)];
	_ars2 = format ["%1",(_this select 1)];
	[_ars1, _ars2] call XfStringGreaterComparer
};

XfArrayLessComparer = {
	private ["_ars1","_ars2"];
	_ars1 = format ["%1",(_this select 0)];
	_ars2 = format ["%1",(_this select 1)];
	[_ars1, _ars2] call XfStringLessComparer
};

// sorts an ArrayList or a range of an ArrayList (comparer can be given by parameter). Uses simple BubbleSort
// parameters: array var as string, index, count
// example ["_myArrayList1"] call XfArrayListSort;
// example ["_myArrayList1",_comparer] call XfArrayListSort;
// example ["_myArrayList1",_startindex, _endindex,_comparer] call XfArrayListSort;
XfArrayListSort = {
	private ["_ar","_h","_co","_ei","_si","_comparer","_n","_s"];
	_ar = _this select 0;
	_comparer = XfNumberGreaterComparer;
	if (count _this == 2) then {_comparer = _this select 1;};
	if (count _this == 4) then {
		_si = _this select 1;
		_ei = _this select 2;
		_comparer = _this select 3;
	} else { // use start and end indexes of input array to sort. _ei is 0 by default!
        _si = 0;
        call compile format ["_ei = count %1 - 1", _ar];
	};
	call compile format ["_h =+ %1",_ar];
	_h = ["_h",_si, _ei] call XfArrayListGetRange;
	_co = count _h - 1;
	for "_n" from _co to 1 step - 1 do {
		for "_s" from 0 to (_n - 1) do {
			if ([(_h select _s),(_h select (_s + 1))] call _comparer) then {
				_d = _h select _s;
				_h set [_s, (_h select (_s + 1))];
				_h set [_s + 1,_d];
			};
			sleep 0.001;
		};
	};
	[_ar,_si,_h] call XfArrayListSetRange;
};

// returns an ArrayList item at index
// parameters: array var as string, index
// example _index = ["_myArrayList1", index] call XfArrayListItem;
XfArrayListItem = {
	call compile format ["%1 select (_this select 1)", (_this select 0)]
};

// gets index of an ArrayLists item
// parameters: array var as string, item fo find,  start index, end index
// example _index = ["_myArrayList1",_vehicle,_startindex, _endindex] call XfArrayListIndexOf;
// example _index = ["_myArrayList1",_vehicle,_startindex] call XfArrayListIndexOf;
// example _index = ["_myArrayList1", _vehicle] call XfArrayListIndexOf;
XfArrayListIndexOf = {
	private ["_ar","_obj","_si","_ei","_index","_i"];
	_ar = call compile format ["%1",_this select 0];
	_obj = _this select 1;
	_si = if (count _this > 2) then {_this select 2} else {0};
	_ei = if (count _this > 3) then {_this select 3} else {count _ar - 1};
	_index = -1;
	if (_si == 0 && _ei == (count _ar - 1)) then {
		_index = _ar find _obj;
	} else {
		for "_i" from _si to _ei do {if (_ar select _i == _obj) exitWith {_index = _i;};};
	};
	_index
};

x_arraylist_compiled = true;

if (true) exitWith {};