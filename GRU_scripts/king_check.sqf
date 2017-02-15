// king_check.sqf created by Sygsky at 12-JUN-2016. Checks king from 5 side mission state

#include "x_macros.sqf"

if ( isNil "king") exitWith {true};

while {alive king} do
{
    if (X_MP) then { if ((call XPlayersNumber) == 0) then {waitUntil { sleep 60; (call XPlayersNumber) > 0 }; } };
    sleep 60;
};

deleteVehicle _this;
sleep 300;
king = nil;

if (true) exitWith {true};