// init included common (executed on both server and client)

titleText ["", "BLACK FADED", 0.2];

if (isNil "Param1") then {
	number_targets = 50;
} else {
	number_targets = Param1;
};
#ifdef __DEFAULT__
_number_targets_h = number_targets;
#endif

if (number_targets >= 50) then {
	_h = (
		switch (number_targets) do {
			case 50: {7};
			case 60: {4};
			case 70: {6};
			case 80: {6};
			case 90: {22};
			case 91: {8};
			default {22};
		}
	);
	number_targets = _h;
};
hint localize format["+++ number_targets %1", number_targets];
#ifndef __WITH_GRASS_AT_START__
setTerrainGrid 50;
#endif

// true = weapons and ammo is only available per player type, false = all weapons and ammo available for everyone
d_limit_weapons = false;
#ifdef __AI__
d_limit_weapons = false;
#endif
if (!isServer) then {
	if (d_limit_weapons) then {
		d_ltd_weapons_array =
			#ifdef __OWN_SIDE_WEST__
					[
					[["TeamLeaderW","SoldierWMedic","SquadLeaderW"],[["M9",5],["M16A2",5],["M16A4",5],["M4",5],["M4A1",5],["M4AIM",5],["MP5A5",5]],[["15Rnd_9x19_M9",30],["30Rnd_556x45_Stanag",30],["30Rnd_9x19_MP5",30],["Handgrenade",30],["Smokeshell", 10],["Smokeshellred",10],["Smokeshellgreen",10],["M136",10]] ],
					[["SoldierWMiner"],[["M9",5],["M16A2",5],["M16A4",5],["M4",5],["M4A1",5],["M4AIM",5],["MP5A5",5]],[["15Rnd_9x19_M9",30],["30Rnd_556x45_Stanag",30],["30Rnd_9x19_MP5",30],["Handgrenade",30],["PipeBomb",10],["Mine",10]] ],
					[["SoldierWMG"],[["M9",5],["M4AIM",5],["M240",5],["M249",5]],[["15Rnd_9x19_M9",30],["30Rnd_556x45_Stanag",30],["100Rnd_762x51_M240",30],["200Rnd_556x45_M249",30],["Handgrenade",30]] ],
					[["SoldierWAT"],[["M9",5],["M16A2",5],["M16A4",5],["M4",5],["M4A1",5],["M4AIM",5],["MP5A5",5],["M136",5]],[["15Rnd_9x19_M9",30],["30Rnd_556x45_Stanag",30],["30Rnd_9x19_MP5",30],["M136",30],["Handgrenade",30]] ],
					[["SoldierWG"],[["M4AIM",5],["M16A2GL",5],["M16A4_GL",5],["M16A4_ACG_GL",5],["M4GL",5],["M4A1GL",5]], [["30Rnd_556x45_Stanag",30],["1Rnd_HE_M203",30],["FlareWhite_M203",30],["FlareGreen_M203",30],["FlareRed_M203",30],["FlareYellow_M203",30],["Handgrenade",30]] ],
					[["SoldierWSniper","SoldierWSaboteurMarksman"],[["M9",5],["M4AIM",5],["M16A4_ACG",5],["M4SPR",5],["M107",5]],[["15Rnd_9x19_M9",30],["30Rnd_556x45_Stanag",30],["5Rnd_762x51_M24",30],["10Rnd_127x99_M107",30]] ],
					[["SoldierWSaboteurAssault"],[["M9SD",5],["M4AIM",5],["M4A1GL",5],["M4A1SD",5],["MP5SD",5],["Laserdesignator",5]],[["15Rnd_9x19_M9SD",30],["30Rnd_556x45_Stanag",30],["30Rnd_556x45_StanagSD",30],["30Rnd_9x19_MP5SD",30],["1Rnd_HE_M203",30],["FlareWhite_M203",30],["FlareGreen_M203",30],["FlareRed_M203",30],["FlareYellow_M203",30],["Handgrenade",30],["Pipebomb",30],["Laserbatteries",10]] ],
					[["SoldierWSaboteurPipe","SoldierWSaboteurRecon","SoldierWSaboteurPipe2"],[["M4AIM",5],["M4A1SD",5],["MP5SD",5],["Laserdesignator",5]],[["30Rnd_556x45_Stanag",30],["30Rnd_556x45_StanagSD",30],["30Rnd_9x19_MP5SD",30],["Pipebomb",30],["Laserbatteries",10]] ],
					[["OfficerW"],[["M9",5],["M4AIM",5]],[["15Rnd_9x19_M9",30],["30Rnd_556x45_Stanag",30],["Handgrenade",30],["Smokeshell", 10],["Smokeshellred",10],["Smokeshellgreen",10]] ]
					];
			#endif
			#ifdef __OWN_SIDE_RACS__
					[
					[["TeamLeaderG","SoldierGMedic","SquadLeaderG"],[["M9",5],["M16A2",5],["M16A4",5],["M4",5],["M4A1",5],["M4AIM",5],["MP5A5",5]],[["15Rnd_9x19_M9",30],["30Rnd_556x45_Stanag",30],["30Rnd_9x19_MP5",30],["Handgrenade",30],["Smokeshell", 10],["Smokeshellred",10],["Smokeshellgreen",10],["M136",10]] ],
					[["SoldierGMiner"],[["M9",5],["M16A2",5],["M16A4",5],["M4",5],["M4A1",5],["M4AIM",5],["MP5A5",5]],[["15Rnd_9x19_M9",30],["30Rnd_556x45_Stanag",30],["30Rnd_9x19_MP5",30],["Handgrenade",30],["PipeBomb",10],["Mine",10]] ],
					[["SoldierGMG"],[["M9",5],["M4AIM",5],["M240",5],["M249",5]],[["15Rnd_9x19_M9",30],["30Rnd_556x45_Stanag",30],["100Rnd_762x51_M240",30],["200Rnd_556x45_M249",30],["Handgrenade",30]] ],
					[["SoldierGAT"],[["M9",5],["M16A2",5],["M16A4",5],["M4",5],["M4A1",5],["M4AIM",5],["MP5A5",5],["M136",5]],[["15Rnd_9x19_M9",30],["30Rnd_556x45_Stanag",30],["30Rnd_9x19_MP5",30],["M136",30],["Handgrenade",30]] ],
					[["SoldierGG"],[["M4AIM",5],["M16A2GL",5],["M16A4_GL",5],["M16A4_ACG_GL",5],["M4GL",5],["M4A1GL",5]], [["30Rnd_556x45_Stanag",30],["1Rnd_HE_M203",30],["FlareWhite_M203",30],["FlareGreen_M203",30],["FlareRed_M203",30],["FlareYellow_M203",30],["Handgrenade",30]] ],
					[["SoldierGSniper","SoldierGMarksman"],[["M9",5],["M4AIM",5],["M16A4_ACG",5],["M4SPR",5],["M107",5]],[["15Rnd_9x19_M9",30],["30Rnd_556x45_Stanag",30],["5Rnd_762x51_M24",30],["10Rnd_127x99_M107",30]] ],
					[["SoldierGCommando","SoldierGGuard"],[["M9SD",5],["M4AIM",5],["G36k",5],["M4A1GL",5],["M4A1SD",5],["MP5SD",5],["Laserdesignator",5]],[["15Rnd_9x19_M9SD",30],["30Rnd_556x45_Stanag",30],["30Rnd_556x45_StanagSD",30],["30Rnd_556x45_G36",30],["30Rnd_9x19_MP5SD",30],["1Rnd_HE_M203",30],["FlareWhite_M203",30],["FlareGreen_M203",30],["FlareRed_M203",30],["FlareYellow_M203",30],["Handgrenade",30],["Pipebomb",30],["Laserbatteries",10]] ],
					[["OfficerG"],[["M9",5],["M4AIM",5]],[["15Rnd_9x19_M9",30],["30Rnd_556x45_Stanag",30],["Handgrenade",30],["Smokeshell", 10],["Smokeshellred",10],["Smokeshellgreen",10]] ]
					];
			#endif
			#ifdef __OWN_SIDE_EAST__
					[
					[["TeamLeaderE","SoldierEMedic","SquadLeaderE"],[["Makarov",5],["AK74",5]],[["8Rnd_9x18_Makarov",30],["30Rnd_545x39_AK",30],["Handgrenade",30],["Smokeshell", 10],["Smokeshellred",10],["Smokeshellgreen",10],["PG7V",10]] ],
					[["SoldierEMiner"],[["Makarov",5],["AK74",5]],[["8Rnd_9x18_Makarov",30],["30Rnd_545x39_AK",30],["Handgrenade",30],["PipeBomb",10],["Mine",10]] ],
					[["SoldierEMG"],[["Makarov",5],["AK74",5],["PK",5]],[["8Rnd_9x18_Makarov",30],["30Rnd_545x39_AK",30],["100Rnd_762x54_PK",30],["Handgrenade",30]] ],
					[["SoldierEAT"],[["Makarov",5],["AK74",5],["RPG7V",5]],[["8Rnd_9x18_Makarov",30],["30Rnd_545x39_AK",30],["PG7V",30],["PG7VR",30],["Handgrenade",30]] ],
					[["SoldierEG"],[["AK74",5],["AK74GL",5]], [["30Rnd_545x39_AK",30],["1Rnd_HE_GP25",30],["FlareWhite_GP25",30],["FlareGreen_GP25",30],["FlareRed_GP25",30],["FlareYellow_GP25",30],["Handgrenade",30]] ],
					[["SoldierESniper","SoldierESaboteurMarksman"],[["Makarov",5],["AK74",5],["SVD",5],["AKS74PSO",5],["KSVK",5]],[["8Rnd_9x18_Makarov",30],["30Rnd_545x39_AK",30],["10Rnd_762x54_SVD",30],["5Rnd_127x108_KSVK",30]] ],
					[["SoldierESaboteur","SoldierESaboteurPipe","SoldierESaboteurBizon"],[["MakarovSD",5],["AK74",5],["AK74GL",5],["AKS74UN",5],["AKS74UN",5],["Laserdesignator",5]],[["8Rnd_9x18_MakarovSD",30],["30Rnd_545x39_AK",30],["30Rnd_545x39_AKSD",30],["1Rnd_HE_GP25",30],["FlareWhite_GP25",30],["FlareGreen_GP25",30],["FlareRed_GP25",30],["FlareYellow_GP25",30],["Handgrenade",30],["Pipebomb",30],["Laserbatteries",10]] ],
					[["OfficerE"],[["Makarov",5],["AK74",5]],[["8Rnd_9x18_Makarov",30],["30Rnd_545x39_AK",30],["Handgrenade",30],["Smokeshell", 10],["Smokeshellred",10],["Smokeshellgreen",10]] ]
					];
			#endif
			#ifdef __TT__
					[
					[["TeamLeaderW","SoldierWMedic","SquadLeaderW","TeamLeaderG","SoldierGMedic","SquadLeaderG"],[["M9",5],["M16A2",5],["M16A4",5],["M4",5],["M4A1",5],["M4AIM",5],["MP5A5",5]],[["15Rnd_9x19_M9",30],["30Rnd_556x45_Stanag",30],["30Rnd_9x19_MP5",30],["Handgrenade",30],["Smokeshell", 10],["Smokeshellred",10],["Smokeshellgreen",10],["M136",10]] ],
					[["SoldierWMiner","SoldierGMiner"],[["M9",5],["M16A2",5],["M16A4",5],["M4",5],["M4A1",5],["M4AIM",5],["MP5A5",5]],[["15Rnd_9x19_M9",30],["30Rnd_556x45_Stanag",30],["30Rnd_9x19_MP5",30],["Handgrenade",30],["PipeBomb",10],["Mine",10]] ],
					[["SoldierWMG","SoldierGMG"],[["M9",5],["M4AIM",5],["M240",5],["M249",5]],[["15Rnd_9x19_M9",30],["30Rnd_556x45_Stanag",30],["100Rnd_762x51_M240",30],["200Rnd_556x45_M249",30],["Handgrenade",30]] ],
					[["SoldierWAT","SoldierGAT"],[["M9",5],["M16A2",5],["M16A4",5],["M4",5],["M4A1",5],["M4AIM",5],["MP5A5",5],["M136",5]],[["15Rnd_9x19_M9",30],["30Rnd_556x45_Stanag",30],["30Rnd_9x19_MP5",30],["M136",30],["Handgrenade",30]] ],
					[["SoldierWG","SoldierGG"],[["M4AIM",5],["M16A2GL",5],["M16A4_GL",5],["M16A4_ACG_GL",5],["M4GL",5],["M4A1GL",5]], [["30Rnd_556x45_Stanag",30],["1Rnd_HE_M203",30],["FlareWhite_M203",30],["FlareGreen_M203",30],["FlareRed_M203",30],["FlareYellow_M203",30],["Handgrenade",30]] ],
					[["SoldierWSniper","SoldierWSaboteurMarksman","SoldierGSniper"],[["M9",5],["M4AIM",5],["M16A4_ACG",5],["M4SPR",5],["M107",5]],[["15Rnd_9x19_M9",30],["30Rnd_556x45_Stanag",30],["5Rnd_762x51_M24",30],["10Rnd_127x99_M107",30]] ],
					[["SoldierWSaboteurAssault"],[["M9SD",5],["M4AIM",5],["M4A1GL",5],["M4A1SD",5],["MP5SD",5],["Laserdesignator",5]],[["15Rnd_9x19_M9SD",30],["30Rnd_556x45_Stanag",30],["30Rnd_556x45_StanagSD",30],["30Rnd_9x19_MP5SD",30],["1Rnd_HE_M203",30],["FlareWhite_M203",30],["FlareGreen_M203",30],["FlareRed_M203",30],["FlareYellow_M203",30],["Handgrenade",30],["Pipebomb",30],["Laserbatteries",10]] ],
					[["SoldierWSaboteurPipe","SoldierWSaboteurRecon","SoldierWSaboteurPipe2","SoldierGCommando"],[["M4AIM",5],["M4A1SD",5],["MP5SD",5],["Laserdesignator",5]],[["30Rnd_556x45_Stanag",30],["30Rnd_556x45_StanagSD",30],["30Rnd_9x19_MP5SD",30],["Pipebomb",30],["Laserbatteries",10]] ],
					[["OfficerW","OfficerG"],[["M9",5],["M4AIM",5]],[["15Rnd_9x19_M9",30],["30Rnd_556x45_Stanag",30],["Handgrenade",30],["Smokeshell", 10],["Smokeshellred",10],["Smokeshellgreen",10]] ]
					];
			#endif
	};
};

// WEST, EAST or RACS for own side, setup in x_setup.sqf
#ifdef __OWN_SIDE_WEST__
d_own_side = "WEST";
d_enemy_side = "EAST";
#endif
#ifdef __OWN_SIDE_EAST__
d_own_side = "EAST";
d_enemy_side = "WEST";
#endif
#ifdef __OWN_SIDE_RACS__
d_own_side = "RACS";
d_enemy_side = "EAST";
#endif
#ifdef __TT__
d_enemy_side = "EAST";
d_own_side = "";
#endif

// setup in x_setup.sqf
d_version = [];
#ifdef __AI__
d_version = d_version + ["AI"]; // AI version
#endif
#ifdef __MANDO__
d_version = d_version + ["MANDO"]; // MANDO version
#endif
#ifdef __REVIVE__
d_version = d_version + ["REVIVE"]; // Revive version
#endif
#ifdef __TT__
d_version = d_version + ["TT"]; // Two Teams version
#endif
#ifdef __ACE__
d_version = d_version + ["ACE"]; // A.C.E. version
#endif
#ifdef __CSLA__
d_version = d_version + ["CSLA"]; // CSLA version
#endif
#ifdef __P85__
d_version = d_version + ["P85"]; // P85 version
#endif
#ifdef __RANKED__
d_version = d_version + ["RANKED"]; // Ranked version
#endif

target_names =
	#ifdef __SCHMALFELDEN__
	[
		[[1368.8,921.382,0],"Naicha", 220,2],
		[[1096.4,1889.11,0],"Schmalfelden", 300,3],
		[[2290.62,2229.37,0],"Grossbaerenweiler", 250,4],
		[[1528.58,3573.05,0],"Speckheim", 300,5],
		[[3210.08,4493.66,0],"Funkstatt", 250,6],
		[[4786.72,4465.79,0],"Windisch-Bockenfeld", 180,7],
		[[3827.83,3025.79,0],"Wolfskreut",250,8],
		[[3541.6,1733.37,0],"Kleinbaerenweiler",250,9],
		[[4143.13,576.173,0],"Heufelwinden",250,10]
	];
	#endif
	#ifdef __UHAO__
	[
		[[3840.62,2843.14,0],"Varona", 190, 2],
		[[5090.98,4693.36,0],"Ahaiki", 180, 3],
		[[7362.44,2172,0],"Wailupe", 195, 4],
		[[3799.57,5566.33,0],"Waipio", 220, 5],
		[[4992.73,8670.71,0],"Kahuku", 130, 6],
		[[3323.07,7701.39,0],"Haleiwa", 150, 7],
		[[2147.85,6697.09,0],"Mokuleia", 140, 8]
	];
	#endif
	#ifdef __DEFAULT__
	[
		[[9349,5893,0],   "Cayo"      ,210, 2],  //  0
		[[10693,4973,0],  "Iguana"    ,270, 3],  //  1
		[[7613,6424,0],   "Arcadia"   ,235, 4],  //  2
		[[8262,9017,0],   "Chantico"  ,180, 5],  //  3
		[[9170,8309,0],   "Somato"    ,230, 6],  //  4
		[[10550,9375,0],  "Paraiso"   ,405, 7],  //  5 * for big town
		[[12399,7141,0],  "Ortego"    ,280, 8],  //  6 *
		[[11450,6026,0],  "Dolores"   ,350, 9],  //  7 *
		[[13302,8937,0],  "Corazol"   ,450, 10], //  8 *
		[[14470,10774,0], "Obregan"   ,240, 11], //  9
		[[13172,11320,0], "Mercalillo",210, 12], // 10
		[[14233,12545,0], "Bagango"   ,350, 13], // 11 *
		[[17271,14193,0], "Masbete"   ,180, 14], // 12
		[[18984,13764,0], "Pita"      ,250, 15], // 13
		[[12508,15004,0], "Eponia"    ,270, 16], // 14
		[[16596,9358,0],  "Everon"    ,200, 17], // 15
		[[9773,14436,0],  "Pacamac"   ,150, 18], // 16
		[[7722,15802,0],  "Hunapu"    ,150, 19], // 17
		[[10593,16194,0], "Mataredo"  ,150, 20], // 18 - for small town
		[[12387,13388,0], "Carmen"    ,200, 21], // 19
		[[2826,2891,0],   "Rahmadi"   ,180, 22], // 20
		[[14444,8554,0],  "Gaula"     ,180, 23], // 21 -
		[[6850,8069,0],   "Estrella"  ,200, 24], // 22 -
		[[15404,13829,0], "Benoma"    ,279, 25], // 23 -
		[[9321,5275,0],   "Tiberia"   ,279, 26], // 24 -
        [[14351,9461,0],  "Modesta"   ,279, 27], // 25 -
		[[11502.5,9152,0],"Corinto"   ,200, 28], // 26 -
		[[8868,7907,0],   "Gulan"     ,220, 29]  // 27 -

	];
	#endif

big_town_radious = 280; // if town radious >= this number, town is considered as big one, else as small

#ifdef __DEFAULT__

d_mountine_towns   = [ "Hunapu", "Pacamac", "Masbete", "Benoma" ];

// Small towns indexes. Can be absent from list when playing not maximum number of towns
d_big_towns_inds = [5,6,7,8,11];

// Small towns indexes. Can be absent from list when playing not maximum number of towns
d_small_towns_inds = [18,21,22,23,24,25,26,27];

#endif

//for "_xxxxx" from 2 to ((count target_names) + 1) do { // hide all town markers from the map
// FIXME: hidden all [unresoved] items
//_list = [];

// hide all available [town] markers from the map. Max set to 30, if your marker count exceeds 30, increase max above 30
for "_xxxxx" from ((target_names select 0) select 3) to 35 /*((target_names select ((count target_names) - 1)) select 3)*/ do {
//	call compile format ["""%1"" objStatus ""HIDDEN"";", (target_names select _xxxxx) select 3];
//	_list = _list + [(target_names select _xxxxx) select 3];
    (str _xxxxx) objStatus "HIDDEN";
};

//hint localize format["+++ objects HIDDEN: %1 +++",_list ];
//"0" objStatus "HIDDEN"; // TODO: for future airbase init seizing mission

#ifdef __DEBUG__
// only for debugging, creates markers at all main target positions
{
	_pos = _x select 0;
	_name = _x select 1;
	_size = _x select 2;
	_marker= createMarkerLocal [_name, _pos];
	_marker setMarkerShapeLocal "ELLIPSE";
	_name setMarkerColorLocal "ColorGreen";
	_name setMarkerSizeLocal [_size,_size];
	_name = _name + "xx";
	_marker= createMarkerLocal [_name, _pos];
	_marker setMarkerTypeLocal "DOT";
	_name setMarkerColorLocal "ColorBlack";
	_name setMarkerSizeLocal [0.5,0.5];
	_name setMarkerTextLocal _name;
} forEach target_names;
#endif

d_side_enemy = (
	switch (d_enemy_side) do {
		case "EAST": {east};
		case "WEST": {west};
		case "RACS": {resistance};
	}
);

d_side_player =
	#ifdef __OWN_SIDE_EAST__
	east;
	#endif
	#ifdef __OWN_SIDE_WEST__
	west;
	#endif
	#ifdef __OWN_SIDE_RACS__
	resistance;
	#endif
	#ifdef __TT__
	west;
	#endif

d_side_player_str =
	#ifdef __OWN_SIDE_EAST__
	"east";
	#endif
	#ifdef __OWN_SIDE_WEST__
	"west";
	#endif
	#ifdef __OWN_SIDE_RACS__
	"guerrila";
	#endif
	#ifdef __TT__
	"west";
	#endif

d_own_side_trigger =
	#ifdef __OWN_SIDE_EAST__
	"EAST";
	#endif
	#ifdef __OWN_SIDE_WEST__
	"WEST";
	#endif
	#ifdef __OWN_SIDE_RACS__
	"GUER";
	#endif
	#ifdef __TT__
	"WEST";
	#endif

// if true, internal weather system will be used
d_weather = true;
// if true, fog area will be used
d_weather_fog = true;
d_weather_sandstorm = false; // for islands like Sakakah set to true. Replaces rain with sandstorm

d_rep_truck = (
	if (__ACEVer) then {
		if (d_enemy_side == "EAST") then {"ACE_Truck5t_Repair"} else {"ACE_Ural_Repair"}
	} else {
		if (d_enemy_side == "EAST") then {"Truck5tRepair"} else {"UralRepair"}
	}
);
d_version_string =
	#ifdef __OWN_SIDE_EAST__
	localize "STR_INTRO_SIDE"; //"East";
	#endif
	#ifdef __OWN_SIDE_WEST__
	"West";
	#endif
	#ifdef __OWN_SIDE_RACS__
	"Racs";
	#endif
	#ifdef __TT__
	"Two Teams";
	#endif

//default flag RACS
#ifdef __OWN_SIDE_WEST__
FLAG_BASE setFlagTexture "\ca\misc\data\usa_vlajka.pac";
#endif
#ifdef __OWN_SIDE_EAST__
FLAG_BASE setFlagTexture "\ca\misc\data\rus_vlajka.pac";
#endif
#ifdef __CSLA__
FLAG_BASE setFlagTexture "\CSLA_Warfare\Images\csla_cssr_flag.paa";
#endif

#ifndef __TT__
FLAG_BASE setPos [position FLAG_BASE select 0, position FLAG_BASE select 1, 0];
#endif


//+++ Sygsky: enable limited refuelling enabled for engineers
#ifdef __LIMITED_REFUELLING__
d_refuel_volume = 50; // how many liters engineer can fill up into any repaired vehicle
d_refuel_per_rank = 20;
d_refuel_rank_for_upgrade = "Major"; // begins from Major rank you are  allowed to refuel more and more by any next ranks
#endif
//--- Sygsky

// is engineer
#ifndef __TT__
d_is_engineer = ["delta_1","delta_2","delta_3","delta_4"];
#else
d_is_engineer = ["west_9","west_10","racs_9","racs_10"];
#endif

// is artillery operator
d_can_use_artillery = ["RESCUE","RESCUE2"];

// can build mash
#ifndef __TT__
d_is_medic = ["alpha_3","bravo_7","charlie_3","charlie_9"];
#else
d_is_medic = ["west_3","racs_3"];
#endif

// can build mg nest
#ifndef __TT__
d_can_use_mgnests = ["alpha_5","alpha_7","charlie_5"];
#else
d_can_use_mgnests = ["west_5","west_7","racs_7","racs_5"];
#endif

// can call in air drop
#ifndef __TT__
d_can_call_drop = ["alpha_1","bravo_1","charlie_1"];
#else
d_can_call_drop = ["west_1","racs_1"];
#endif

// if you want to use the mgnest for machinegunners
d_with_mgnest = true;

if (d_with_mgnest) then {
	d_mg_nest =
	#ifdef __OWN_SIDE_RACS__
	"WarfareBResistanceMGNest_M240";
	#endif
	#ifdef __OWN_SIDE_EAST__
	"WarfareBEastMGNest_PK";
	#endif
	#ifdef __OWN_SIDE_WEST__
	"WarfareBWestMGNest_M240";
	#endif
	#ifdef __TT__
	"WarfareBWestMGNest_M240";
	#endif
};

sm_bonus_vehicle_array = (
#ifdef __SCHMALFELDEN__
	switch (d_own_side) do {
		case "RACS": {["Stryker_ICV_M2","Stryker_ICV_MK19","HMMWV50","HMMWVMK","HMMWVTOW","Stryker_TOW","M113_RACS"]};
		case "WEST": {["Stryker_ICV_M2","Stryker_ICV_MK19","HMMWV50","HMMWVMK","HMMWVTOW","Stryker_TOW","M113"]};
		case "EAST": {["BMP2","BRDM2","UAZMG","UAZ_AGS30","BRDM2_ATGM","BMP2","BRDM2"]};
	}
#endif
#ifdef __UHAO__
	switch (d_own_side) do {
		case "RACS": {["Stryker_ICV_M2","Stryker_ICV_MK19","HMMWV50","HMMWVMK","HMMWVTOW","Stryker_TOW","M113_RACS"]};
		case "WEST": {["Stryker_ICV_M2","Stryker_ICV_MK19","HMMWV50","HMMWVMK","HMMWVTOW","Stryker_TOW","M113"]};
		case "EAST": {["BMP2","BRDM2","UAZMG","UAZ_AGS30","BRDM2_ATGM","BMP2","BRDM2"]};
	}
#endif
#ifdef __DEFAULT__
	switch (d_own_side) do {
		case "RACS": {["Stryker_ICV_M2","Stryker_ICV_MK19","HMMWV50","HMMWVMK","HMMWVTOW","Stryker_TOW","M113_RACS"]};
		case "WEST": {
			if (__ACEVer) then {
				["ACE_Stryker_M2","ACE_Stryker_MK19","ACE_Stryker_MGS","ACE_Stryker_MGS_SLAT","ACE_HMMWV_50","ACE_HMMWV_GL","ACE_HMMWV_TOW","ACE_HMMWV_GAU19","ACE_M113_A3","ACE_M2A2","ACE_M2A1"]
			} else {
				["Stryker_ICV_M2","Stryker_ICV_MK19","HMMWV50","HMMWVMK","HMMWVTOW","Stryker_TOW","M113"]
			}
		};
		case "EAST": {
			if (__CSLAVer) then {
				["CSLA_BVP1","CSLA_OT64C","UAZMG","UAZ_AGS30","CSLA_9P148","CSLA_BVP2","CSLA_BRDM2"]
			} else {
				if (__ACEVer) then {
[
"ACE_BRDM2_ATGM",	// 0-13 (14 vehicles total)
"ACE_BRDM2",	    // 1
"ACE_T64_BV",	    // 2
"ACE_UAZ_MG",       // 3
"ACE_UAZ_AGS30",    // 4
"ACE_BMP2_D",       // 5
"ACE_T55_AMV",      // 6
"ACE_BRDM2_ATGM",	// 7
"ACE_BMP3_M",       // 8
"ACE_BRDM2_SA9",    // 9
"ACE_BMP1_D",       // 10
"ACE_BMD1p",        // 11
"ACE_T80_U",        // 12
"ACE_T72_BM"        // 13
]
				} else {
					["BMP2","BRDM2","UAZMG","UAZ_AGS30","BRDM2_ATGM","BMP2","BRDM2"]
				}
			}
		};
	}
#endif
#ifdef __TT__
	["A10","AH1W","AH6","AV8B","AV8B2","UH60","Vulcan"]
#endif
);
//hint localize format["sm_bonus_vehicle_array=%1", sm_bonus_vehicle_array];
mt_bonus_vehicle_array = (
#ifdef __SCHMALFELDEN__
	switch (d_own_side) do {
		case "RACS": {["A10","AH1W","AH6_RACS","AV8B","AV8B2","UH60","T72_RACS","Vulcan_RACS"]};
		case "WEST": {["AH1W","AH6","UH60", "M1Abrams","Vulcan"]};
		case "EAST": {["Su34B","KA50","Mi17","Su34","Su34","Mi17","T72","ZSU"]};
	}
#endif
#ifdef __UHAO__
	switch (d_own_side) do {
		case "RACS": {["A10","AH1W","AH6_RACS","AV8B","AV8B2","UH60","T72_RACS","Vulcan_RACS"]};
		case "WEST": {["A10","AH1W","AH6","AV8B","AV8B2", "UH60", "M1Abrams","Vulcan"]};
		case "EAST": {["Su34B","KA50","Mi17","Su34","Su34","Mi17","T72","ZSU"]};
	}
#endif
#ifdef __DEFAULT__
	switch (d_own_side) do {
		case "RACS": {["A10","AH1W","AH6_RACS","AV8B","AV8B2","UH60","T72_RACS","Vulcan_RACS"]};
		case "WEST": {
			if (__ACEVer) then {
				["ACE_A10_AGM_FFAR","ACE_AH64_AGM_HE_F_S_I","ACE_AH1Z_AGM_HE_F_S_I","ACE_AH1Z_TOW_HE_F_S_I","ACE_AH6_GAU19","ACE_AV8B_GBU12","ACE_AV8B_AA", "ACE_UH60RKT_HE_F", "ACE_M1A2_SEP_TUSK","ACE_M1A2_SEP","ACE_M1A2_TUSK","ACE_M1A1_HA","ACE_PIVADS","ACE_Vulcan","ACE_A10_MK82","ACE_A10_MK82HD"]
			} else {
				["A10","AH1W","AH6","AV8B","AV8B2", "UH60", "M1Abrams","Vulcan"]
			}
		};
		case "EAST": {
			if (__CSLAVer) then {
				["Su34B","KA50","CSLA_Mi8T_UK","Su34","Su34","CSLA_Mi8T_S5","CSLA_T72","ZSU"]
			} else {
				if (__ACEVer) then {
[
"ACE_BMP3_M", 		    // 1 - ordinal vehicles list
"ACE_T80_UM",     		// 2
"ACE_T80_B",   			// 3
"ACE_Mi24D", 			// 4
"ACE_KA52",  			// 5
"ACE_BRDM2_SA9", 		// 6
"ACE_T64_BV",			// 7
"ACE_Tunguska",			// 8
"ACE_ZSU",          	// 9
"ACE_T72_BM", 			//10
"ACE_Mi17", 		    //11
"ACE_Mi24P",	        //12
"ACE_Su30Mk_R27_R73",	//13
"ACE_Mi24V",     	    //14
"ACE_Su34B",            //15

"ACE_Ka50", 		    // 1 - first big bonus vehicle (heli + plane + big tank)
"ACE_Ka50_N", 	        // 2
"ACE_Su30Mk_Kh29T",     // 3
"ACE_Su30Mk_KAB500KR",  // 4
"ACE_T90_K", 			// 5
"ACE_T90A"              // 6
];				} else {
					["Su34B","KA50","Mi17","Su34","Su34","Mi17","T72","ZSU"]
				}
			}
		};
	}
#endif
#ifdef __TT__
	["Stryker_ICV_M2","Stryker_ICV_MK19","HMMWV50","HMMWVMK","HMMWVTOW","Stryker_TOW","M113"]
#endif
);

#ifdef __DEFAULT__
mt_bonus_received_vehicle_array = []; // temp permament array for smart bonus selection
big_bonus_vec_index = mt_bonus_vehicle_array find "ACE_Ka50"; // index of first good vehicle (helis + jets + big tanks)
//jet_bonus_vec_index = mt_bonus_vehicle_array find "ACE_Su30Mk_Kh29T"; // index of first good plane vehicle
#endif

// positions for aircraft factories (if one get's destroyed you're not able to service jets/service choppers/repair wrecks)
// first jet service, second chopper service, third wreck repair

d_aircraft_facs =
	#ifdef __DEFAULT__
	[[[9377.9,10056.3,0],180],[[9617.58,10079.1,0],90],[[10086.3,10077.3,0],90]];
	#endif
	#ifdef __SCHMALFELDEN__
	[[[0,0,0],180],[[2499.53,242.345,0],147.5],[[2550.05,271.454,0],147.5]];
	#endif
	#ifdef __UHAO__
	[[[2172.4,4372.23,0],0],[[2049.93,4317.15,0],0],[[2051.83,4250.59],0]];
	#endif
	#ifdef __TT__
	[];
	#endif

x_drop_array =
	#ifdef __OWN_SIDE_RACS__
		[["Drop Artillery", "M119"], ["Drop Landrover","Landrover_Closed"], ["Drop Ammo", "SpecialBoxGuer"]];
	#endif
	#ifdef __OWN_SIDE_WEST__
		if (__ACEVer) then {
			[["Drop Artillery", "M119"], ["Drop Humvee","ACE_HMMWV_50"], ["Drop Ammo", "SpecialBoxWest"]]
		} else {
			[["Drop Artillery", "M119"], ["Drop Humvee","HMMWV50"], ["Drop Ammo", "SpecialBoxWest"]]
		};
	#endif
	#ifdef __OWN_SIDE_EAST__
		if (__CSLAVer) then {
			[["Drop Artillery", "D30"], ["Drop Uaz","UAZ"], ["Drop Ammo", "CSLA_ammoBedna2"]]
		} else {
			if (__ACEVer) then {
				[[localize "STR_SYS_335", "WeaponBoxEast"], [localize "STR_SYS_336","D30"], [localize "STR_SYS_337","ACE_BRDM2"]] //[["Пушка", "D30"], ["БРДМ","ACE_BRDM2"], ["Ящик снабжения", "WeaponBoxEast"]]
			} else {
				[["Drop Artillery", "D30"], ["Drop Uaz","UAZ"], ["Drop Ammo", "SpecialBoxEast"]]
			}
		};
	#endif
	#ifdef __TT__
		[["Drop Artillery", "M119"], ["Drop Humvee","HMMWV50"], ["Drop Ammo", "SpecialBoxWest"]];
	#endif

// side of the pilot that will fly the drop air vehicle
x_drop_side = d_own_side;

// change the radius for the drop, default is 0, means it the droped object will be droped allmost exactly at the drop point
d_drop_radius = 0;

// vehicle reload time factor (for the chopper and plane service area).
x_reload_time_factor = 4;
// vehicle reload... turn engine off (false = don't turn engine off)
d_reload_engineoff = true;

// these vehicles can be lifted by the wreck lift chopper (previous chopper 4), but only, if they are completely destroyed
x_heli_wreck_lift_types = sm_bonus_vehicle_array + mt_bonus_vehicle_array;

// The "Choose Parachute Location" option at the flag at base is now disabled again as default
// you can still bring it back by setting d_para_at_base to true
d_para_at_base = true;

// If set to true no parachute flags (Choose Parachute location) will get created at base and cleared main targets (only available for version != AI)
// this also overrides d_para_at_base and sets it to false
d_no_para_at_all = false;

// if you set d_para_timer_base to a value > 0, for example 1800, HALO parajump is not available for 30 minutes once you've parajumped from the base flag (if enabled)
d_para_timer_base = 300; // 600 // 1800
d_next_jump_time = -1;

// set the height for the HALO jump. Previously it was 888m now 8888m (a little bit more ;-))
#ifndef __ACE__
d_halo_height = 1000;
#else
d_halo_height = 1000;
#endif

// d_jumpflag_vec = empty ("") means normal jump flags for HALO jump get created
// if you add a vehicle typename to d_jumpflag_vec (d_jumpflag_vec = "UAZ"; for example) only a vehicle gets created and no HALO jump is available
//d_jumpflag_vec = "ACE_UAZ";
d_jumpflag_vec = ""; //+++ Sygsky: normal jump by request for Home and Yeti 

// Fixes the bug that tanks fly through the air or fall on their back
// code from Hein Blds GDTModTracked addon, thanks Hein
d_use_mod_tracked = true;

// max distance from target where an arti operator can order an artillery strike
d_arti_operator_max_dist = 1000; // 500
// max distance from drop point that a player must be to call in drop
d_drop_max_dist = 500;
// artillery reload time (if arti operator ordered more than one salvos)
d_arti_reload_time = 20;
// once an artillery strike got executed it will take d_arti_available_time + some random time until artillery is available again
// be aware, if you fire more salvoes d_arti_available_time will increase (2 salvoes = 500 seconds, 3 salvoes = 700 seconds)
d_arti_available_time = 300;

// default = 1800. This will kick players for the first 30  minutes(or 1800 seconds) when they joined out of air vehicles that can be won at main targets or sidemissions
// if you don't want this feature then set d_player_air_autokick = 0;
// if ArmA crashes and the player rejoines then he won't need to wait 60 minutes again (time gets saved)
d_player_air_autokick = 3600;

side_mission_winner = 0;
resolved_targets = [];
target_clear=false;
all_sm_res = false;
ammo_boxes = 0;
the_end = false;
bonus_number = -1;
extra_bonus_number = -1;
mr1_in_air = false;
mr2_in_air = false;
#ifdef __TT__
mrr1_in_air = false;
mrr2_in_air = false;
#endif
ari_available = true;
sec_kind = 0;
ari_type = "";
ari1 = 0;
ari2_available = true;
ari_type2 = "";
sec_target_name = "";
objectID1 = objNull;
objectID2 = objNull;
jump_flags = [];

#ifdef __TT__
points_west = 0;
points_racs = 0;
kill_points_west = 0;
kill_points_racs = 0;
points_array = [];
#endif

d_wreck_marker = [];

// static truck load
truck1_cargo_array = [];
truck2_cargo_array = [];

mt_radio_pos = [0,0,0];
mt_radio_down = false;

Observer1 = objNull;
Observer2 = objNull;
Observer3 = objNull;

d_ammo_boxes = [];

d_jet_service_fac_rebuilding = false;
d_chopper_service_fac_rebuilding = false;
d_wreck_repair_fac_rebuilding = false;

ADD_HIT_EH(MEDIC_TENT1)
ADD_DAM_EH(MEDIC_TENT1)
ADD_HIT_EH(AMMOBUILDING)
ADD_DAM_EH(AMMOBUILDING)

#ifndef __SCHMALFELDEN__
ADD_HIT_EH(MEDIC_TENT2)
ADD_DAM_EH(MEDIC_TENT2)
#endif
#ifndef __TT__
ADD_HIT_EH(WALL1)
ADD_DAM_EH(WALL1)
ADD_HIT_EH(WALL2)
ADD_DAM_EH(WALL2)
ADD_HIT_EH(WALL3)
ADD_DAM_EH(WALL3)
#endif
#ifdef __TT__
ADD_HIT_EH(AMMOBUILDING2)
ADD_DAM_EH(AMMOBUILDING2)
#endif

// for markers and revive (same like NORRN_player_units)
d_player_entities = ["RESCUE","RESCUE2","alpha_1","alpha_2","alpha_3","alpha_4","alpha_5","alpha_6","alpha_7","alpha_8","bravo_1","bravo_2","bravo_3","bravo_4","bravo_5","bravo_6","bravo_7","bravo_8","charlie_1","charlie_2","charlie_3","charlie_4","charlie_5","charlie_6","charlie_7","charlie_8","charlie_9","delta_1","delta_2","delta_3","delta_4"];
d_player_roles = ["PLT LD","PLT SGT","SL","SN","MD","TL","MG","AT","MG","GL","SL","OP","SN","AT","MG","MD","HS","SP","SL","SN","MD","TL","MG","AT","GL","AT","EN","EN","EN","EN"];

#ifdef __REVIVE__
d_NORRN_max_respawns = 30;
d_NORRN_respawn_button_timer = 90;
d_NORRN_revive_time_limit = 300;
d_NORRN_no_of_heals = 3;
d_show_player_marker = 0;
// set x_default_revive_setpos to false if you have troubles with revive (respawning at respawn_xxxx marker instead the place where the player died)
x_default_revive_setpos = false;
d_with_qg_anims = false;
#endif

// all lower objects are null if they are alive. If they are not null, corresponding ruins object stored in it
d_jet_service_fac = objNull;
d_chopper_service_fac = objNull;
d_wreck_repair_fac = objNull;

#ifdef __MANDO__
//cruise missile launcher setup
mando_airsupport_cmissile = server;
mando_airsupport_cmissile_pos = [0,0,10];
if (d_enemy_side == "EAST") then {
	// Mando gun camera (2.35 stuff)
	d_ah1w_gun_camera = ["AH1W"];
	//add flares to UH60 and bonus aircraft
	d_flares_only = ["UH60MG","UH60","AV8B","AV8B2","A10","AH1W"];
	// Stryker_TOW units will be Patriots for players as gunners
	d_patriot_missiles = ["Stryker_TOW"];
	// Vulcan will have 0 flares and 12 AA missiles gunner
	d_aa_vehicles = ["Vulcan"];
	// new Mando Missiles 2.35 cameras
	d_aa_camera = ["AV8B","A10","AH1W"];
	d_lgb_camera = ["AV8B"];
	d_maverick_camera = ["A10"];
	d_hellfire_camera = ["AH1W"];
} else {
	// Mando gun camera (2.35 stuff)
	d_ka50_gun_camera = ["KA50"];
	//add flares to UH60 and bonus aircraft
	d_flares_only = ["Mi17_MG","Mi17","Su34","Su34B","KA50"];
	// BRDM2_ATGM  units will be Patriots for players as gunners
	d_sam_missiles = ["BRDM2_ATGM"];
	// ZSU will have 0 flares and 12 AA missiles gunner
	d_aa_vehicles = ["ZSU"];
	// new Mando Missiles 2.35 cameras
	d_aa_camera = ["Su34B","KA50"];
	d_ch29_camera = ["Su34B"];
};
//provides ammo trucks with ability to reload mando flares and missiles to units
d_reload_flares = ["Truck5tReammo", "UralReammo"];
d_reload_missiles = ["Truck5tReammo", "UralReammo"];

//disable unwanted console buttons
mando_support_no_re = true;
mando_support_no_pa = true;
mando_support_no_am = true;
mando_support_no_cm = true;
#endif

// if set to true, enemy AI spawned vehicles will be locked. Default false, no lock
d_lock_ai_armor = false;
d_lock_ai_car = false;
d_lock_ai_air = false;

d_vars_array = [];

#ifdef __TT__
// chopper varname, type (0 = lift chopper, 1 = wreck lift chopper, 2 = normal chopper), marker name, placeholder for heli lift types
d_choppers_west = [["HR1",0,"chopper1"], ["HR2",0,"chopper2"], ["HR3",0,"chopper3"], ["HR4",1,"chopper4"]];
d_choppers_racs = [["HRR1",0,"chopperR1"], ["HRR2",0,"chopperR2"], ["HRR3",0,"chopperR3"], ["HRR4",1,"chopperR4"]];
#else
// chopper varname, type (0 = lift chopper, 1 = wreck lift chopper, 2 = normal chopper), marker name, placeholder for heli lift types
d_choppers = [["HR1",0,"chopper1"], ["HR2",0,"chopper2"], ["HR3",0,"chopper3"], ["HR4",1,"chopper4"]];
#endif

// if a player creates a vehicle at a mhq this is the time he has to wait until the old vehicle gets deleted
// and he is able to create a new vehicle again. Default is 30 minutes = 1800 seconds
d_remove_mhq_vec_time = 1800;

if (d_enemy_side == "EAST") then {
	if (__ACEVer) then {
		d_own_trucks = ["ACE_Truck5t_Reammo","ACE_Truck5t_Refuel","ACE_Truck5t_Repair"];
	} else {
		d_own_trucks = ["Truck5tReammo","Truck5tRefuel","Truck5tRepair"];
	};
} else {
	if (__CSLAVer) then {
		d_own_trucks = ["CSLA_T815Ammo8","CSLA_T815CAP6","CSLA_DTP90"];
	} else {
		if (__ACEVer) then {
			d_own_trucks = ["ACE_Ural_Reammo","ACE_Ural_Refuel","ACE_Ural_Repair"];
		} else {
			d_own_trucks = ["UralReammo","UralRefuel","UralRepair"];
		};
	};
};
// position base, a,b, for the enemy at base trigger and marker
d_base_array =

#ifdef __SCHMALFELDEN__
	[[2545.45,156.443,0], 300, 200];
#endif

#ifdef __UHAO__
	[[2141,4371.059,0], 150, 150];
#endif

#ifdef __DEFAULT__
	//+++ Sygsky: Paraiso airfield coordinates and its boundary rectangle box (semi-axis sizes)
	[[9821.47,9971.04,0], 600, 200, 0];
#endif

#ifdef __TT__
	[
		[[2551.25,2709.68,0], 300, 100, 90], // West, Rahmadi
		[[18092.4,18289.4,0], 300, 100, 80]  // Racs, Antigua or Pita, not sure
	];
#endif

// Small base patrol area (only territory populated with obstacles), smaller than original one
//d_ups_array = [[9571.161133,9875.279297],200,130];

d_base_patrol_array = 
[
	[[9502,9871.2,0],290,150,0],       // court of airbase, main area
	[[9956,9771,0],175,250,0],         // middle south of airfield + hangars + forest to Paraiso
	[[10304,9954,0],240,250,-25],      // airbase part near Paraiso (hill and air-field buildings on east)
	[[9780.1,10332.6,0],650,170,0],    // north of airfield (forest-bush
	[[9149.29,10079,0],125,200,0],     // west of airfield (pit on west of air-field)
	[[9582,9377,0],100,300,100],       // south to base (granary area)
	[[10518,10061,0],150,350,0]        // east from base between butt end of airfield and the big hill
];

d_base_patrol_fires_array = 
[
 [9624,10293,0],[10081,10261,0], // northe fires (slope to shore)
 [9084,10006,0], // west fire at a pit
 [9453,9868,0],  // main yard fire
 [9899,9697,0],	// east to yard fire
 [10231,9910,0] // nearest to Paraiso fire
];

// Only for Kronsky patrol script (UPS)
#ifdef __USE_KRONSKY_SCRIPT__
d_base_patrol_markers = [];
{
	_name = createMarker [ format [ "base_patrol_area_%1", (count d_base_patrol_markers) + 1], _x select 0 ];
	d_base_patrol_markers set [ count d_base_patrol_markers, _name ];
	 //base patrol area, for enemy patrol script (UPS by Kronzky)
	_name setMarkerSize [ _x select 1, _x select 2 ];
	if ( count _x > 3) then { _name setMarkerDir  (_x select 3); };
} forEach d_base_patrol_array;
#endif

// set d_old_ammobox_handling to false to get back pre 3.50 ammobox dropping from mhq and choppers
d_old_ammobox_handling = false;

if (d_old_ammobox_handling) then {
	last_ammo_drop = -3423;
};

//_nObject = position FLAG_BASE nearestObject 393;
//_nObject setDamage 1;
//deleteCollection _nObject;

ClearWeaponCargo MEDIC_TENT1;
ClearMagazineCargo MEDIC_TENT1;
ClearWeaponCargo MEDIC_TENT2;
ClearMagazineCargo MEDIC_TENT2;

#ifdef __ACE__
//+++ Sygsky: added on heli wind effect. Set to false if wind effect is not desired
d_with_wind_effect = true;

// list of big heli for WEST with ACE
SYG_HELI_BIG_LIST_ACE_W =
    ["ACE_AH1Z_HE","ACE_AH1Z_HE_F","ACE_AH1Z_HE_S_I","ACE_AH1W_AGM_HE","ACE_AH1Z_AGM_HE_F_S_I","ACE_AH1Z_AGM_HE_F",
     "ACE_AH1W_TOW_HE_F_S_I","ACE_AH1W_TOW2","ACE_AH1W_TOW_TOW_HE","ACE_AH64_HE_F",/*"ACE_AH64_AGM_AIM",*/"ACE_AH64_AGM_HE",
     "ACE_AH64_AGM_HE_F","ACE_AH64_AGM_HE_F_S_I"/*,"ACE_AH64_AGM_AIM","ACE_AH64_AGM_AIM","ACE_AH64_AGM_AIM"*/];
// list of big heli for WEST with ACE
SYG_HELI_LITTLE_LIST_ACE_W = ["ACE_AH6_GAU19","ACE_AH6_TwinM134","ACE_UH60MG_M134","ACE_UH60MG_M240C","ACE_AH6_AGM"];

#endif

d_gwp_formations = ["COLUMN","STAG COLUMN","WEDGE","ECH LEFT","ECH RIGHT","VEE","LINE","DIAMOND"];

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Array of all global variables, see "global_vars.sqf" for each variable offset defines
//
if ( isNil "global_vars" ) then { global_vars = []; };
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// Special fund to accumulate non-engineers score subracted when repairing damaged vehicles
if ( isNil "SYG_engineering_fund") then { SYG_engineering_fund = 0;};
x
hint localize format["i_common.date = %1", date];