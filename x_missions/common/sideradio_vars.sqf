/*
	x_missions\common\sideradio_vars.sqf - include file for radio mast intalling side mission
	author: Sygsky
	description: definition for the side-radio mast inatallation mission[s]
	returns: nothing
*/


// central point of the area to install radar
#define RADAR_INSTALL_POINT [13592,15591,0],[13105,16500,0],[14592,15084,0],[15002,15251,0],[14578,15620,0],[13058,16800,0],[13788,15516,0],[11066,13408,0]
#define RADAR_ZONE_CENTER [13788,15516,0]
#define INSTALL_RADIUS 2000             // how far from the RADAR_ZONE_CENTER
#define INSTALL_MIN_ALTITUDE 440        // minimal height above sea level to install
//#define RADAR_INSTALL_POINT [10044,8030]       // debug radar point (near Somato at height 231)
//#define INSTALL_RADIUS 300             // how far from the debug RADAR_INSTALL_POINT
//#define INSTALL_MIN_ALTITUDE 200       // minimal height above sea level to install

#define MAX_SLOPE 0.21					// 0.21 m. per 3x3 m. area
#define RADAR_MARKER "Arrow"            // BIS marker for radar
#define SM_MARKER "Unknown"             // BIS marker for question sign
#define DIST_TO_SHIFT_MARKER 25         // shift size between marker and object to update marker position
#define DIST_MAST_TO_TRUCK 15           // distance from truck to mast to allow handle mast from truck
#define DIST_MAST_TO_INSTALL 10         // distance from truck to mast to allow handle mast from truck
#define RADAR_SM_COLOR "ColorRed"
#define RADAR_ON_COLOR "ColorGreen"
#define RADAR_TYPE "Land_radar"