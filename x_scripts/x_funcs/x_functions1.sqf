// by Xeno: x_scripts\x_funcs\x_functions1.sqf

x_funcs1_compiled = false;

// get a random numer, floored
// parameters: number
// example: _randomint = 30 call XfRandomFloor;
XfRandomFloor = {
	floor (random _this)
};

// shuffles the content of an array
// parameters: array
// example: _myrandomarray = _myNormalArray call XfRandomArray;
XfRandomArray = {
	private ["_ar","_ran_array","_this"];
	_ar =+ _this;
	_ran_array = [];
	while {count _ar > 0} do {
		_ran = (count _ar) call XfRandomFloor;
		_ran_array = _ran_array + [_ar select _ran];
		_ar set [_ran, "xfXX_del_432_ZFV"];
		_ar = _ar - ["xfXX_del_432_ZFV"];
	};
	_ran_array
};

// creates an array with count random indices
// parameters: int (number of entries)
// example: _myrandomindexarray = _numberentries call XfRandomIndexArray;
XfRandomIndexArray = {
	private ["_count","_ran_array"];
	_count = _this;
	_ran_array = [];
	for "_i" from 0 to (_count - 1) do {_ran_array = _ran_array + [_i]};
	_ran_array = _ran_array call XfRandomArray;
	_ran_array
};

/**
 * Creates an array with count random indexes so then some imdexes are mandatory and some are optional, designated through predefined array
 * Params:  _inds = [ _out_cnt, _cnt, _important_arr, _unimportant_arr ] call XfRandomIndexArrayWithPredefVals;
 * where: _unimportant_arr - array with predefined indexes that may be excluded in resulting array,
 * e.g. to work with target_names(defined in i_common.sqf) so that exclude some small towns,
 * use [count target_names, 22, [18,21,22,23,24,25,26,27]] call  XfRandomIndexArrayWithPredefVals to return 22 town indexes
 * excluding some of array [18,21,22,23,24,25,26,27]
 * Returns: array with _cnt indexes in range [0.._ind_max] excluding some (or all) of indexes stored in _pre_arr. Of course
 * input named arrays must contain only indexes in range [0..(_cnt-1)]
 */
XfIndexArrayWithPredefVals = {
    private ["_unimportantArr","_cnt","_outCnt","_arrIn"];
    _unimportantArr    = + _this select 3; // unimportant town indexes, may be skipped from result list
    _importantArr      = + _this select 2; // importan town indexe, must present in result
    _cnt               = _this select 1; // sequenced indexes length
    _outCnt            = _this select 0; // number of indexes in resulting array

    _arrIn = [];

    for "_i" from 0 to _cnt - 1 do { _arrIn = _arrIn + [_i]}; // add all available indexes

    _arrIn = _arrIn - _importantArr -_unimportantArr; // remove predefined indexes to create intermediate list

    _importantArr  = _importantArr call XfRandomArray; // shuffe important just in case (if they can be cut also)
    _arrIn = _arrIn call XfRandomArray; // shuffle ordinal list to cut random items
    _unimportantArr = _unimportantArr call XfRandomArray; // shuffle unimportant to cut random iteems

    _arrIn = _importantArr + _arrIn + _unimportantArr ;
    _arrIn resize _outCnt;
    _arrIn call XfRandomArray
};

// #########################################

// converts a bit array to an integer number
// parameters: bit array (without brackets)
// example: _numfrombitarray = _myBitArray call XfBitArrayToNum;
XfBitArrayToNum = {
	private ["_ar","_ret"];
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
	private ["_num","_bits","_ret"];
	_num = _this select 0;
	_bits = (_this select 1) - 1;
	_ret = [];
	for "_i" from _bits to 0 step -1 do {
		_val = _num mod 2 ^ _i;
		_ret = _ret + [(if (_val == _num) then {false} else {true})];
		_num = _val;
	};
	_ret
};

x_funcs1_compiled = true;