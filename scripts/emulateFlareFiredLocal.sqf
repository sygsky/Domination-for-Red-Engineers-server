//
// emulateFlareFired.sqf: ACE flare script modified to use on server by Sygsky
//
// call as: [_flare, _flare_color (may be "Red","Green","Yellow","White"), _factor] spawn "emulateFlareFired.sqf"
//
private ["_col","_fx_flare","_fx_smoke","_factor","_pos","_flare","_pos","_flare_type","_die_away_height"];

#define __FLARE    (_this select 0)
#define __COL    (_this select 1)
#define __FACTOR   (_this select 2)

//#define __R [[1,0,0,1],[1,0,0,0.8],[1,0,0,1],[1,0,0,0.9]]
#define __R [[1,0,0,0.7],[1,0,0,0.5],[1,0,0,0.7],[1,0,0,0.6]]
#define __G [[0,1,0,1],[0,1,0,0.8],[0,1,0,1],[0,1,0,0.9]]
//#define __W [[1,1,1,1],[1,1,1,1.8],[1,1,1,1],[1,1,1,1.9]]
#define __W [[1,1,1,0.7],[1,1,1,0.5],[1,1,1,0.7],[1,1,1,0.9]]
#define __Y [[1,1,0,1],[1,1,0,0.8],[1,1,0,1],[1,1,0,0.9]]
#define __VEL velocity _flare
#define __I .025

//#define __DIST ( (player distance _flare) / 400 )

#define __FX_FLARE _fx_flare setParticleParams [["\Ca\Data\sunHalo.p3d", 1, 0, 0],"", "Billboard", \
10, 0.5, [0,0,0.1], \
__VEL, \
1, 1.275, 1, 0, \
[_factor,(_factor/2),(_factor/4)], \
_col, \
[0.08], 1, 0, "", "", _flare]

#define __FX_SMOKE _fx_smoke setParticleParams [["\Ca\data\ParticleEffects\ROCKETSMOKE\RocketSmoke", 1, 0, 0],"", "Billboard", \
10, 0.5, [0,0,0.1], \
[0,0,8], \
1, 1.275, 1, 0, \
[(_factor/4),(_factor/8),(_factor/16)], \
__W, \
[0.08], 1, 0, "", "", _flare]

_flare = __FLARE;
if ( isNull _flare ) exitWith { hint localize "emulateFlareFiredLocal.sqf: flare object isNull"; };

_col = __COL;
switch (toUpper(_col)) do
{
	case "WHITE":  { _col = __W; };
	case "GREEN":  { _col = __G; };
	case "YELLOW": { _col = __Y; };
	case "RED";
	default        { _col = __R; };
};

_factor = __FACTOR;

//sleep 0.1;

// Flare
_fx_flare = "#particleSource" createVehicleLocal (getPos _flare);
_fx_flare setParticleRandom [0.5,[0.1,0.1,0.1],[0,0,0],0,0.1,[0.1,0.1,0.1,0.05],0,0];
_fx_flare setDropInterval __I;

// Smoke
_fx_smoke = "#particleSource" createVehicleLocal (getPos _flare);
_fx_smoke setParticleRandom [0.5,[0.1,0.1,0.1],[0,0,0],0,0.1,[0.1,0.1,0.1,0.05],0,0];
_fx_smoke setDropInterval __I;

	__FX_FLARE;
	__FX_SMOKE;
	
//[ "launch_flare", _flare ] call XSendNetStartScriptClient;