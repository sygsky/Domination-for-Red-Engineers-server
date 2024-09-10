// by Xeno: x_scripts\x_funcs\x_functions1.sqf

// get a random numer, floored
// parameters: number
// example: _randomint = 30 call XfRandomFloor;
XfRandomFloor = {
	floor (random _this)
};

// shuffles the content of an array
// parameters: array
// example: _myRandomArray = _myNormalArray call XfRandomArray;
// Optimized by Sygsky (resize except new array creates) at 09-JAN-2022
XfRandomArray = {
	private ["_ar","_ran_array","_ran","_cnt"];
	_ar =+ _this;
	if (count _ar < 2) exitWith { _ar };
	_ran_array = [];
//	hint localize format["+++ _this %1", _this];
	_cnt = count _ar;
	while { _cnt > 1 } do {
		_ran = _cnt call XfRandomFloor; // get random index
		_ran_array set [ count _ran_array, _ar select _ran];
		_cnt = _cnt - 1;
		if (_ran != _cnt) then { _ar set [ _ran, _ar select _cnt ]; };
	};
	_ran_array set [count _ran_array, _ar select 0];
	_ran_array
};

// shuffles the content of an array in place (the same array returned).
// Fisher Yates Algorithm.
// parameters: array
// example: _myRandomArray = _myNormalArray call XfRandomArray;
// Optimized by Sygsky at 12-JAN-2022
XfRandomArrayInPlace = {
	private ["_ar","_tmp","_ran","_cnt", "_cnt1","_i"];
	_ar = _this;
	if (count _ar < 2) exitWith { _ar };
	_cnt = count _ar;
	_cnt1 = _cnt - 1;
	for "_i" from _cnt1 to 1 step -1 do {
		_ran = floor ( random (_i + 1)); // get random index for exchange with arr[i]
		if ( _ran != _i ) then {
			_tmp = _ar select _i;
			_ar set [ _i, _ar select _ran ];
			_ar set [ _ran, _tmp ];
		} ;
	};
	_ar
};

// creates an array with count random indices
// parameters: int (number of entries)
// example: _myrandomindexarray = _numberentries call XfRandomIndexArray;
XfRandomIndexArray = {
	private ["_i","_count","_ran_array"];
	_count = _this;
	_ran_array = [];
	for "_i" from 0 to (_count - 1) do {_ran_array set [count _ran_array, _i ]};
	_ran_array call XfRandomArrayInPlace;
};

/**
 * Creates an array with count random indexes so then some indexes are mandatory and some are optional, designated through predefined array
 * Params:  _inds = [ _user_defined_cnt, _full_cnt, _important_arr, _unimportant_arr ] call XfRandomIndexArrayWithPredefVals;
 * where: _unimportant_arr - array with predefined indexes that may be excluded in resulting array,
 * e.g. to work with target_names (defined in i_common.sqf) so that exclude some small towns,
 * use [22, count target_names, d_big_towns_inds, d_small_towns_inds] call  XfRandomIndexArrayWithPredefVals to return 22 town indexes
 * excluding some of array [18,21,22,23,24,25,26,27]
 * Returns: randomized by pos items in array with _out_cnt indexes in range [0..(_out_cnt-1)] excluding some (or all) of indexes stored in d_small_towns_inds(_unimportant_arr).
 * Of course input named arrays must contain only indexes in range [0..(_cnt-1)]
  */
XfIndexArrayWithPredefVals = {
    private ["_unimportantArr","_importantArr","_cnt","_outCnt","_arrIn","_i","_x"];
    _unimportantArr    = + _this select 3; // unimportant town indexes, may be skipped from result list
    _importantArr      = + _this select 2; // importan town indexe, must present in result
    _cnt               = _this select 1; // sequenced indexes length
    _outCnt            = _this select 0; // number of indexes in resulting array

    _arrIn = [];

    for "_i" from 0 to _cnt - 1 do { _arrIn set [_i, _i] }; // add all valid indexes
	_all_idx = + _arrIn;
    _arrIn = _arrIn - _importantArr -_unimportantArr; // remove predefined indexes to create intermediate list

    _importantArr  = _importantArr call XfRandomArray; // shuffle important indexes (not ids) just in case (if they can be cut also)
    _arrIn call XfRandomArrayInPlace; // shuffle ordinal list to cut random items
    _unimportantArr call XfRandomArrayInPlace; // shuffle unimportant to cut random iteems

    _arrIn = _importantArr + _arrIn + _unimportantArr ;
    _arrIn resize _outCnt;

    // Print town names not used in the missions
    hint localize "+++ Mission unused town names:";
    _id = 1;
    {
		hint localize format [ "+++ %1 (%2)", (target_names select _x) select 1, _id];
		_id = _id + 1;
    } forEach (_all_idx - _arrIn);

    _arrIn call XfRandomArray
};

// #########################################

// converts a bit array to an integer number
// parameters: bit array (without brackets)
// example: _numfrombitarray = _myBitArray call XfBitArrayToNum;
XfBitArrayToNum = {
	private ["_ar","_ret","_i"];
	_ar = _this;_ret = 0;
	if (count _ar > 0) then {
		_xx = (count _ar - 1);
		for "_i" from 0 to (count _ar - 1) do {
			_ret = _ret + ((if (_ar select _i) then {1} else {0}) * 2 ^ _xx);
			_xx = _xx - 1;
		};
	};
	_ret
};

// converts an integer number to a bit array, number of bits can be set
// parameters: integer number, bit number (integer)
// example: _bitArrayFromNum = [5000,16] call XfNumToBitArray;
XfNumToBitArray2 = {
	private ["_num","_bits","_ret","_i","_val"];
	_num = _this select 0;
	_bits = (_this select 1) - 1;
	_ret = [];
	for "_i" from _bits to 0 step -1 do {
		_val = _num mod 2 ^ _i;
		_ret set [ count _ret, if (_val == _num) then {false} else {true} ];
		_num = _val;
	};
	_ret
};
