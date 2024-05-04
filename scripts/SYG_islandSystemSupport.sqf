//++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
// scripts\SYG_islandSystemSupport.sqf, by Sygsky
//
// Common scripts created by Sygsky to handle with islnd maps data support and organize (towns, patrols, etc.)
// Created at 2024-MAY-01
//++++++++++++++++++++++++++++++++++++++++++++++++++++++

#include "x_setup.sqf"
#include "x_macros.sqf"


// New structures to play on maps with  ultiple islands (e.g. "OFP_World")

SYG_island_commons = [
    //  Array with common land patrol spawn areas (rects, circles, ellipses). Used if no island spawn areas
    [
    ],
    //  Array with common sea patrol routes
    [], // Common sea paths, may be separated for far situated island ones
    [], // Common SM array, for Sahrani all SM are here as Rahmadi island is very small and rather close to the Main island
    5, // Maximal number of patrols, can't be more than max number of patrols in commons
    //  Method of tasks creation: "MIXED", "SEQUENTIAL_ISLANDS', "RANDOM_ISLANDS"
    "MIXED"
//
];

_patrol_spawn_areas = [
];

_d_with_isledefense = ["RECT"];
_d_with_isledefense set[1, d_with_isledefense select 0];
_d_with_isledefense set [2, d_with_isledefense select 1];

SYG_island_arr = [

#ifdef __DEFAULT__
    // Island #1 (Main)
	[
	    // Towns array
		[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,/*20 - Rahmadi*/ 21,22,23,24,25,26,27,28],
		 // Special Side Missions array (53 is SM on Rahmady - airpane hijack)
		[57,56,44,/* 53, */54,55,40,20,30,21,22,25,42,26,52,51,50,49,48,47,46,45,43,3,41,39,38,37,36,35,34,33,32,31,29,28,27,24,23,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,2,1,0],
		// Add special land patrols on the island for this island
        [
            // Sahrani Main
            ["RECT",[[7105.91,8488.53,0],200,20,-40]], // spawn1
            ["RECT",[[8808.7,5080.61,0],200,20,45]], // spawn2
            ["RECT",[[11154.9,5014.03,0],200,20,-40]], // spawn3
            ["RECT",[[12521.1,6240.03,0],200,20,0]], // spawn4
            ["RECT",[[13491.1,7230.74,0],200,20,-60]], // spawn5
            ["RECT",[[16577,9014.8,0],100,30,0]], // spawn6
            ["RECT",[[19342.6,13772,0],60,20,335]], // spawn7
            ["RECT",[[18442.6,14610,0],100,30,0]], // spawn8
            ["RECT",[[11939.7,17193.7,0],90,25,-43]], // spawn9
            ["RECT",[[11691.3,16641.5,0],50,20,-40]], // spawn10
            ["RECT",[[9253.96,14875.3,0],50,20,20]], // spawn11
            ["RECT",[[12911.5,11156,0],100,30,40]], // spawn12
            ["RECT",[[17091.1,9558.37,0],70,30,345]], // spawn13
            ["RECT",[[10198.8,16417.9,0],60,15,20]] // spawn14
        ],
        5,
        // TODO: Add sea patrols

		d_with_isledefense, // [[[12422.8,11518.5,0], 6850, 6850, 0], 5];
		getArray(configFile>>"CfgWorlds">>worldName>>"centerPosition") // Center of the Sahrani
	],
	// Island #2 Rahmadi, just in case, to demonstrate all features of the new structure
	[
		[ 20 ], // 20 => index for Rahmadi in the common list only
		[ 53 ], // Special SM array for this island, if empty, common SM will be used
		[ // Special spawn rects for patrols
            // If the array is empty, no patrols
            // If not empty: 1st element = "RECT" | "CIRCLE" | "ELLIPSE"
            // If "RECT" or "ELLIPSE", second element is rectangle/ellipse description [ [center position, A | rad1, B | rad2, angle],number of groups]
            // E.g.: ["RECT", [[12422.8,11518.5,0], 6850, 6850, 0], 5];
            // If "CIRCLE", second element is circle description [ [center position, radious], number of groups]
            // E.g.: 		[ "CIRCLE", [[2928,2732, 0], 900], 2], // Patrols circle for the Rahmadi

            // Rahmadi
            ["RECT",[[3215.84,2141.65,0],50,25,0]], // spawn15
            ["RECT",[[3423.54,3435.07,0],50,25,90]], // spawn16
            ["RECT",[[2252.18,2600.55,0],50,25,90]] // spawn17
		],
		1, // Number of patrols
//		[ [[2928,2732, 0], 900], 2], // Patrols circle for the Rahmadi
        [], //
		[2928, 2732, 0] // Center of Rahmadi
	]
];
#endif

#ifdef __OFP_WORLD__

#endif

