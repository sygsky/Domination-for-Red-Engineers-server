// by Xeno

x_bitarray_compiled = false;

// some bit array fun (really just for fun :) or not ?

// create a new bit array (default all bits are false)
// parameters: size of the bit array (no brackets)
XfBitArrayNew = {
	private ["_nar","_size"];
	_size = _this;_nar = [];
	for "_i" from 1 to _size do {_nar = _nar + [false];};
	_nar
};

// set one bit of the bit array to a new value
// parameters: bit array, bit number, on or off (true or false)
// example: _setBitArray = [_myBitarray, 5, true] call XfBitArraySetBit;
XfBitArraySetBit = {
	private ["_ar","_bit","_onoff"];
	_ar = _this select 0;_bit = _this select 1;_onoff = _this select 2;
	if (_bit >= 0 && _bit < count _ar) then {_ar set [_bit, _onoff];};
	_ar
};

// set all bits of the bit array to a new value
// parameters: bit array, on or off (true or false)
// example: _setAllBitArray = [_myBitarray, true] call XfBitArraySetAll;
XfBitArraySetAll = {
	private ["_ar","_onoff"];
	_ar = _this select 0;_onoff = _this select 1;
	if (count _ar > 0) then {for "_i" from 0 to (count _ar - 1) do {_ar set [_i, _onoff];};};
	_ar
};

// helper function
XfBitArrayAddFront = {
	private ["_ar","_n","_h"];
	_ar = _this select 0;_n = _this select 1;_h = [];
	for "_i" from 1 to _n do {_h = _h + [false];};
	(_h + _ar)
};

// performans an And operation between two bit arrays, if the size is not equal, false will be added to beginning of the array with less elements 
// The bitwise AND operation returns true if both operands are true, and returns false if one or both operands are false. 
// parameters: bitArray1, bitArray2
// example: _andBitArray = [bitArray1, bitArray2] call XfBitArrayAnd;
XfBitArrayAnd = {
	private ["_ar1","_ar2","_ret"];
	_ar1 =+ _this select 0;_ar2 =+ _this select 1;
	_ret = [];
	if (count _ar1 > count _ar2) then {
		_ar2 = [_ar2, count _ar1 - count _ar2] call XfBitArrayAddFront;
	} else {
		if (count _ar1 < count _ar2) then {
			_ar1 = [_ar1, count _ar2 - count _ar1] call XfBitArrayAddFront;
		};
	};
	for "_i" from 0 to (count _ar1 - 1) do {_ret = _ret + [if ((_ar1 select _i) && (_ar2 select _i)) then {true} else {false}];};
	_ret
};

// inverts all bits in the bit array
// parameters: bitArray (no brackets)
// example: _notBitArray = bitArray call XfBitArrayNot;
XfBitArrayNot = {
	private ["_ar"];
	_ar = _this;
	for "_i" from 0 to (count _ar - 1) do {_ar set [_i, !(_ar select _i)];};
	_ar
};

// performans an Or operation between two bit arrays, if the size is not equal, false will be added to beginning of the array with less elements 
// The bitwise OR operation returns true if one or both operands are true, and returns false if both operands are false.
// parameters: bitArray1, bitArray2
// example: _orBitArray = [bitArray1, bitArray2] call XfBitArrayOr;
XfBitArrayOr = {
	private ["_ar1","_ar2","_ret"];
	_ar1 =+ _this select 0;_ar2 =+ _this select 1;
	_ret = [];
	if (count _ar1 > count _ar2) then {
		_ar2 = [_ar2, count _ar1 - count _ar2] call XfBitArrayAddFront;
	} else {
		if (count _ar1 < count _ar2) then {
			_ar1 = [_ar1, count _ar2 - count _ar1] call XfBitArrayAddFront;
		};
	};
	for "_i" from 0 to (count _ar1 - 1) do {_ret = _ret + [(_ar1 select _i) || (_ar2 select _i)];};
	_ret
};

// performans an XOr operation between two bit arrays, if the size is not equal, false will be added to beginning of the array with less elements
// The bitwise exclusive OR operation returns true if exactly one operand is true, and returns false if both operands have the same Boolean value. 
// parameters: bitArray1, bitArray2
// example: _xorBitArray = [bitArray1, bitArray2] call XfBitArrayXOr;
XfBitArrayXOr = {
	private ["_ar1","_ar2","_ret"];
	_ar1 =+ _this select 0;_ar2 =+ _this select 1;
	_ret = [];
	if (count _ar1 > count _ar2) then {
		_ar2 = [_ar2, count _ar1 - count _ar2] call XfBitArrayAddFront;
	} else {
		if (count _ar1 < count _ar2) then {
			_ar1 = [_ar1, count _ar2 - count _ar1] call XfBitArrayAddFront;
		};
	};
	for "_i" from 0 to (count _ar1 - 1) do {_ret = _ret + [((_ar1 select _i) || (_ar2 select _i)) && !((_ar1 select _i) && (_ar2 select _i))];};
	_ret
};

// converts an integer number to a bit array, checks allways 32 bit numbers are supported
// parameters: integer number (without brackets)
// example: _bitArrayFromNum = 5000 call XfNumToBitArray;
XfNumToBitArray = {
	private ["_num","_ret"];
	_num = _this;_ret = [];
	for "_i" from 31 to 0 step -1 do {
		_val = _num mod 2 ^ _i;
		_ret = _ret + [(if (_val == _num) then {false} else {true})];
		_num = _val;
	};
	_ret
};

// converts a boolean bit array to a numeric (0/1) bit array
// parameters: bit array (without brackets)
// example _numbitarray = _bitarray call XfBitArrayToNumBitArray;
XfBitArrayToNumBitArray = {
	private ["_ret","_ba"];
	_ba = _this;_ret = [];
	{_ret = _ret + [(if (_x) then {1} else {0})];} forEach _ba;
	_ret
};

// converts a numeric (0/1) bit array to a boolean bit array
// parameters: nummeric bit array (without brackets)
// example _bitarray = _numbitarray call XfNumBitArrayToBitArray;
XfNumBitArrayToBitArray = {
	private ["_ret","_ba"];
	_ba = _this;_ret = [];
	{_ret = _ret + [(if (_x == 1) then {true} else {false})];} forEach _ba;
	_ret
};

x_bitarray_compiled = true;

if (true) exitWith {};