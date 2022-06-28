/*
	x_missions\common\sideradio_vars.sqf - include file for radio mast intalling side mission
	author: Sygsky
	description: definition for the side-radio mast inatallation mission[s]
	returns: nothing
*/


#define RADAR_POINT [13592,15591,0]   // central point of the area to install radar
#define INSTALL_RADIUS 2000             // how far from the RADAR_POINT
#define INSTALL_MIN_ALTITUDE 450        // minimal height above sea level to install
#define RADAR_MARKER "Arrow"            // BIS marker for radar
#define SM_MARKER "Unknown"             // BIS marker for question sign
#define DIST_TO_SHIFT_MARKER 25         // shift size between marker and object to update marker position
#define DIST_MAST_TO_TRUCK 15           // distance from truck to mast to allow handle mast from truck
#define DIST_MAST_TO_INSTALL 10           // distance from truck to mast to allow handle mast from truck
#define RADAR_SM_COLOR "ColorRed"