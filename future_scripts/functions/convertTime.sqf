/*
	File: convertTime.sqf
	Description: function to convert an amount of seconds to a good clock string.
	
	Copyright © Bohemia Interactive Studio. All rights reserved.
*/

private ["_input", "_clock"];
_input = _this select 0;
_clock = "";

private ["_hrs", "_mins", "_secs", "_extraZero"];
_hrs = floor (_input / 3600);
_input = _input % 3600;

_mins = floor (_input / 60);
_secs = _input % 60;

_extraZero = "";
if (_hrs < 10) then 
{
	_extraZero = "0";
};
_clock = _clock + (format ["%1%2:", _extraZero, _hrs]);

_extraZero = "";
if (_mins < 10) then 
{
	_extraZero = "0";
};
_clock = _clock + (format ["%1%2:", _extraZero, _mins]);

_extraZero = "";
if (_secs < 10) then 
{
	_extraZero = "0";
};
_clock = _clock + (format ["%1%2", _extraZero, _secs]);

_clock