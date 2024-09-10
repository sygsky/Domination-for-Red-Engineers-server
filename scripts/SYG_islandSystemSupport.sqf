//++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
// scripts\SYG_islandSystemSupport.sqf, by Sygsky
//
// Common scripts created by Sygsky to handle with islnd maps data support and organize (towns, patrols, etc.)
// Created at 2024-MAY-01
//++++++++++++++++++++++++++++++++++++++++++++++++++++++

#include "x_setup.sqf"
#include "x_macros.sqf"


// New structure to play on maps with  multiple islands (e.g. "OFP_World", Sahrani Main + Rahmadi etc.)
// Describe the whole design of the mission
_main_island_array = [

    //  Method of main tasks (towns) creation:
    // "MIXED" - all towns on map are randomized and used from common list (as it was in std Domination on Sahrani)
    // "SEQUENTIAL_ISLANDS' - islands in the natural order from SYG_island_arr
    // "RANDOM_ISLANDS" - from random island order
    // [0,1...] from islands in pre-defined oredr
    [[0,1],2], // All towns are mixed from islands 0 and 1, after created list is empty start to use towns from island 2

    // SM orders variants:
    // 1."MIXED" - select SM randomly from all SM summary list, as it was in original Sahrani Domination
    // 2. "RANDOM_ON_TOWN_ISLANDS" - random SM from the SM list for the active island.
    // If no more SM on active island, random SM from nearest available (non-empty) island are used
    // 3. [0,1...] - whole array of needed SM in predefined order. Only these ones are used in the battle, one by one
    "MIXED",

    // Common sea lanes started during whole game, not dependent on island activity.
    // If empty, no special lanes will be created
    [],

    //  A big common border around all the islands of the map, mandatory!
    [],

    // Islands + patrol respawn area ids where to create patrols along this active island.
    // For example, if there is a permanent player base on one island, you can organize patrols there.
    // But immediately arises the problem of finding the boundaries of such a patrol.
    // Example: [[1,[0,2,5]]] means that permanent patrol respawns will be on island #1 (Malden?) with area ids #0,#2, #5.
    // Island id may be replaced with island name, eg: [["Malden",[0,2,5]]] or with #defines
    // #define MALDEN 1
    // [[MALDEN,[0,2,5]]]
    []

];

_patrol_spawn_areas = [
];

// Islands (Sahrani, Rahmadi)
_d_with_isledefense = ["RECT",d_with_isledefense select 0, d_with_isledefense select 1];

//
// Common array of separate island descriptions
//
SYG_island_arr = [

#ifdef __DEFAULT__
    // Island #1 (Main)
	[
	    "Sahrani_Main", // Offset 0: Island name
	    // Towns index array: [ <[big rowns list],[small towns list],> all towns list
	    // Big+small towns lists may be absent (both are on or off)
		[d_big_towns_inds,d_small_towns_inds,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,/*20 - Rahmadi*/ 21,22,23,24,25,26,27,28], // Offset in common array:1
		 // Special Side Missions array (53 is SM on Rahmadi - airplane hijack)
		[57,56,44,/* 53, */54,55,40,20,30,21,22,25,42,26,52,51,50,49,48,47,46,45,43,3,41,39,38,37,36,35,34,33,32,31,29,28,27,24,23,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,2,1,0], // Offset 2
		// Add special land patrols on the island for this island
        [ // Offset 3
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
        // Number of patrols allowed
        5, // Offset 4
        // TODO: Add sea patrol routes
        [], // Offset 5: Sea patrols path array

		d_with_isledefense, // [[[12422.8,11518.5,0], 6850, 6850, 0], 5]; // Offset 6
		getArray(configFile>>"CfgWorlds">>worldName>>"centerPosition") // Center of the Sahrani // Offset 7
	],
	// Island #2 Rahmadi, just in case, to demonstrate all features of the new structure
	[
	    "Rahmadi", // Rahmadi island
		[ 20 ], // 20 => index for Rahmadi town in the common list only
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

#ifdef __MULTI_ISLAND_WORLD__

#endif

