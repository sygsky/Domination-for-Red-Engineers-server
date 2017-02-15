private ["_col","_fx_flare","_fx_smoke","_factor"];

#define __unit (_this select 0)
#define __ammo (_this select 4)
#define __flare (_this select 5)

if (__ammo == "F_HuntIR") exitWith {};

#define __r [[1,0,0,1],[1,0,0,0.8],[1,0,0,1],[1,0,0,0.9]]
#define __g [[0,1,0,1],[0,1,0,0.8],[0,1,0,1],[0,1,0,0.9]]
#define __w [[1,1,1,1],[1,1,1,1.8],[1,1,1,1],[1,1,1,1.9]]
#define __y [[1,1,0,1],[1,1,0,0.8],[1,1,0,1],[1,1,0,0.9]]
#define __col getText(configFile >> "CfgAmmo" >> __ammo >> "ACE_Color")
#define __vel velocity __flare
#define __i .01
#define __s ( (player distance __flare) / 400 )

#define __fx_flare _fx_flare setParticleParams [["\Ca\Data\sunHalo.p3d", 1, 0, 0],"", "Billboard", \
10, 0.5, [0,0,0.1], \
__vel, \
1, 1.275, 1, 0, \
[_factor,(_factor/2),(_factor/4)], \
_col, \
[0.08], 1, 0, "", "", __flare]

#define __fx_smoke _fx_smoke setParticleParams [["\Ca\data\ParticleEffects\ROCKETSMOKE\RocketSmoke", 1, 0, 0],"", "Billboard", \
10, 0.5, [0,0,0.1], \
[0,0,8], \
1, 1.275, 1, 0, \
[(_factor/1.5),(_factor/3),(_factor/6)], \
__w, \
[0.08], 1, 0, "", "", __flare]

switch (__col) do
{
	case "W": { _col = __w; };
	case "R": { _col = __r; };
	case "G": { _col = __g; };
	case "Y": { _col = __y; };
};

while { alive __flare && (__vel select 2 > 0) } do { sleep 1; };

_factor = __s; if (_factor > 12.5) then { _factor = 12.5; };

// Flare
_fx_flare = "#particleSource" createVehicleLocal (getPos __flare);
_fx_flare setParticleRandom [0.5,[0.1,0.1,0.1],[0,0,0],0,0.1,[0.1,0.1,0.1,0.05],0,0];
_fx_flare setDropInterval __i;

// Smoke
_fx_smoke = "#particleSource" createVehicleLocal (getPos __flare);
_fx_smoke setParticleRandom [0.5,[0.1,0.1,0.1],[0,0,0],0,0.1,[0.1,0.1,0.1,0.05],0,0];
_fx_smoke setDropInterval __i;

	__fx_flare;
	__fx_smoke;