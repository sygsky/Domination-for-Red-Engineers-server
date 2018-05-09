// by Xeno

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
 * Params:  _inds = [ _out_cnt, _cnt, _pre_arr ] call XfRandomIndexArrayWithPredefVals;
 * where: _pre_arr - array with predefined indexes may be excluded in resulting array,
 * e.g. to work with target_names(defined in i_common.sqf) so that exclude som small towns,
 * use [count target_names, 22, [18,21,22,23,24,25,26,27]] call  XfRandomIndexArrayWithPredefVals to return 22 town indexes
 * excluding some of array [18,21,22,23,24,25,26,27]
 * Returns: array with _cnt indexes in range [0.._ind_max] excluding some of indexes stored in _pre_arr. Of course
 * named array must contain also indexes in range [0..(_cnt-1)]
 */
XfIndexArrayWithPredefVals = {
    private ["_preArr","_cnt","_outCnt","_arrIn"];
    _preArr    = +(_this select 2); // predefined array copy with weak indexes allowed to be removed if needed
    _cnt       = _this select 1; // sequenced indexes length
    _outCnt    = _this select 0; // number of indexes in resulting array
    _arrIn = [];
    for "_i" from 0 to _cnt -1 do {_arrIn = _arrIn + [_i]};
    _arrIn = _arrIn - _preArr; // remove predefined indexes to allow use not all of them later
    _preArr = _preArr call XfRandomArray;
    _preArr resize (_cnt - _outCnt); // remove some inds to result in designated inds count
    _arrIn = _arrIn + _preArr;
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