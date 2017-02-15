// by Xeno
// Dictionary
// keys may not be arrays !!!!
// implements multiple values for each key
// not fully implemented yet

XDictionaryNew = {
	call compile format ["dic_keys_%1 = []",_this];
	call compile format ["dic_values_%1 = []",_this];
};

XDictionaryAdd = {
	private ["_name", "_key", "_value", "_xdic_values", "_index", "_found"];
	_name = _this select 0;
	_key = _this select 1;
	_value = _this select 2;
	call compile format ["
		_index = dic_keys_%1 find _key;
		if (_index != -1) then {
			_xdic_values = dic_values_%1 select _index;
			if (typeName _value != ""ARRAY"") then {
				if (!(_value in _xdic_values)) then {_xdic_values = _xdic_values + [_value];dic_values_%1 set [_index,_xdic_values]};
			} else {
				_found = false;
				{
					if (str (_x) == str (_value)) exitWith {
						_found = true;
					};
				} forEach _xdic_values;
				if (!_found) then {_xdic_values = _xdic_values + [_value];dic_values_%1 set [_index,_xdic_values]};
			};
		} else {
			dic_keys_%1 = dic_keys_%1 + [_key];
			dic_values_%1 = dic_values_%1 + [[_value]];
		};
	", _name];
};

XDictionaryClear = {
	call compile format ["dic_keys_%1 = [];dic_values_%1 = [];", _this];
};

XDictionaryContainsKey = {
	call compile format ["(_this select 1) in dic_keys_%1",_this select 0]
};

XDictionaryContainsValue = {
	private ["_name", "_key", "_value", "_ret", "_index", "_xdic_values"];
	_name = _this select 0;
	_key = _this select 1;
	_value = _this select 2;
	_ret = false;
	call compile format ["
		_index = dic_keys_%1 find _key;
		if (_index != -1) then {
			_xdic_values = dic_values_%1 select _index;
			if (typeName _value != ""ARRAY"") then {
				if (_xdic_values find _value != -1) then {_ret = true};
			} else {
				{
					if (str (_x) == str (_value)) exitWith {
						_ret = true;
					};
				} forEach _xdic_values;
			};
		};
	",_name];
	_ret
};

XDictionaryRemoveKey = {
	private ["_name", "_key", "_index"];
	_name = _this select 0;
	_key = _this select 1;
	call compile format ["
		_index = dic_keys_%1 find _key;
		if (_index != -1) then {
			dic_keys_%1 set [_index, ""XXX_REMOVE_X78_ME_XXX""];
			dic_keys_%1 = dic_keys_%1 - [""XXX_REMOVE_X78_ME_XXX""];
			dic_values_%1 set [_index, ""XXX_REMOVE_X78_ME_XXX""];
			dic_values_%1 = dic_values_%1 - [""XXX_REMOVE_X78_ME_XXX""];
		};
	", _name];
};

XDictionaryRemoveValue = {
	private ["_name", "_key", "_value", "_index", "_xdic_values", "_index2", "_val"];
	_name = _this select 0;
	_key = _this select 1;
	_value = _this select 2;
	call compile format ["
		_index = dic_keys_%1 find _key;
		if (_index != -1) then {
			_xdic_values = dic_values_%1 select _index;
			if (typeName _value != ""ARRAY"") then {
				_index2 = _xdic_values find _value;
				if (_index2 != -1) then {
					_xdic_values set [_index2, ""XXX_REMOVE_X78_ME_XXX""];
					_xdic_values = _xdic_values - [""XXX_REMOVE_X78_ME_XXX""];
					dic_values_%1 set [_index, _xdic_values];
				};
			} else {
				for ""_index2"" from 0 to (count _xdic_values - 1) do {
					_val = _xdic_values select _index2;
					if (str (_x) == str (_value)) exitWith {
						_xdic_values set [_index2, ""XXX_REMOVE_X78_ME_XXX""];
						_xdic_values = _xdic_values - [""XXX_REMOVE_X78_ME_XXX""];
						dic_values_%1 set [_index, _xdic_values];
					};
				};
			};
		};
	",_name];
};

// sleep 2;

// "_mydic" call XDictionaryNew;
// ["_mydic","alex","test"] call XDictionaryAdd;
// ["_mydic","alex","test2"] call XDictionaryAdd;
// ["_mydic","angelina","test999"] call XDictionaryAdd;

// player sideChat format ["%1", dic_keys__mydic];
// player sideChat format ["%1", dic_values__mydic];

// player sideChat format ["Contains %1", ["_mydic","peter"] call XDictionaryContainsKey];