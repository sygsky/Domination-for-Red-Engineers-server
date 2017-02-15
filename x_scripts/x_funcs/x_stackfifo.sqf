// by Xeno

x_stackfifo_compiled = false;

// push (add) element to the stack
// parameters: array var as string, object to add (not as string)
// example: ["_myStackarray", vehicle] call XfStackPush;
XfStackPush = {
	private ["_obj","_ar"];
	_ar = _this select 0;_obj = _this select 1;
	call compile format ["%1 = %1 + [_obj];", _ar];
};

// get the last element and delete it from the stack
// parameters: array var as string (no brackets)
// example: _pop = "_myStackarray" call XfStackPop;
XfStackPop = {
	private ["_ret","_ar"];
	_ar = _this;_ret = objNull;
	call compile format ["
		if (count %1 > 0) then {
			_ret = %1 select (count %1 - 1);
			%1 set [(count %1 - 1), ""YXZ_DEL_Q_X76""];
			%1 = %1 - [""YXZ_DEL_Q_X76""];
		};
	", _ar];
	_ret
};

// get top element without deleting it from stack
// parameters: array var as string (no brackets)
// example: _top = "_myStackarray" call XfStackTop;
XfStackTop = {
	private ["_ret","_ar"];
	_ar = _this;_ret = objNull;
	call compile format ["if (count %1 > 0) then {_ret = %1 select (count %1 - 1);};", _ar];
	_ret
};

// adds an element to the first position of an queue
// parameters: array var as string, object to add (not as string)
// example: ["_myDequearray", vehicle] call XfDequeueAdd;
XfDequeueAdd = {
	private ["_obj","_ar"];
	_ar = _this select 0;_obj = _this select 1;
	call compile format ["%1 = [_obj] + %1;", _ar];
};

// returns the first emelemt of an queue and deletes it from the queue
// parameters: array var as string (no brackets)
// example: _first = "_myDequearray" call XfDequeueGet;
XfDequeueGet = {
	private ["_ret","_ar"];
	_ar = _this;
	_ret = objNull;
	call compile format ["
		if (count %1 > 0) then {
			_ret = %1 select 0;
			%1 set [0, ""YXZ_DEL_Q_X76""];
			%1 = %1 - [""YXZ_DEL_Q_X76""];
		};
	", _ar];
	_ret
};

// gets first element of a queue without deleting it from the queue
// parameters: array var as string (no brackets)
// example: _first = "myDequearray" call XfDequeFirst;
XfDequeFirst = {
	private ["_ar","_ret"];
	_ar = _this;_ret = objNull;
	call compile format ["if (count %1 > 0) then {_ret = %1 select 0;};", _ar];
	_ret
};

// gets last element of a queue without deleting it from the queue
// parameters: array var as string (no brackets)
// example: _last = "_myDequearray" call XfDequeLast;
XfDequeLast = {
	_this call XfStackTop;
};

// add an object to a FIFO
// parameters: array var as string, object to add (not as string)
// example: ["_myFIFOarray", vehicle] call XfFIFOAdd;
XfFIFOAdd = {
	[_this select 0, _this select 1] call XfStackPush;
};

// get object from FIFO and delete it from the FIFO list
// parameters: array var as string (no brackets)
// example: _fifoelement = "_myFIFOarray" call XfFIFOGet;
XfFIFOGet = {
	_this call XfDequeueGet
};

// get the first element of the FIFO list without removing it
// parameters: array var as string (no brackets)
// example: _first = "_myFIFOarray" call XfFIFOFirst;
XfFIFOFirst = {
	_this call XfDequeFirst;
};

// get the last element of the FIFO list without removing it
// parameters: array var as string (no brackets)
// example: _last= "_myFIFOarray" call XfFIFOLast;
XfFIFOLast = {
	_this call XfStackTop;
};

x_stackfifo_compiled = true;

if (true) exitWith {};