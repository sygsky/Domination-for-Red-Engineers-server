// by Sygsky for Xeno Domination
if (!X_Client) exitWith {};

#include "x_setup.sqf"
#ifndef __DEFAULT__
// TODO: start intro with flight above the map
if (true) exitWith{};
#endif

d_still_in_intro = true;

sleep 4;
playMusic "ATrack10";

// if player not reached the base in previous visits to the Sahrani  he is first time dropped with parachute onto the Antigua
// If player reached base before, it is respawned 1st time in parachute above the plain between Somato and base
// Or he will see current x_intro.sqf, I don't decided it.
// All other times he is respawned as usually (on base point or on one of two MHQ)
// # Set night if still not
// create plane, fill it with cargo, remove random cargo partially, insert player
// set WP for plane so it will traverse Antigua
// # print multiple interesting messages
// Before jump switch on/off red alert lamp (#lightpoint)
// At the destination point eject player with planning parachute
// # Restore daytime if changed in the moment of the paradrop (while player still in plane)
// put flag with rumors on the Antigua hills,
// put several habitants,
// put dead enemy officer with map (and command "Inspect" on its body) among the Antigua hills.
// create the boat for this player if not already exists
// create sea patrols from boats with Vulcans on board (1st weapon place)

// If player landed successfully, it is respawned next times
// in any of 3-4 respawn points ammong the hills of Antigua

sleep 14;
titleRsc ["Titel1", "PLAIN"];

d_still_in_intro = false;

if (true) exitWith {};
