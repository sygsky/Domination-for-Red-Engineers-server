/*
	author: Sygsky
	description: called on base flag debug action for client
    	    Parameters array passed to the script upon activation in _this variable is: [target, caller, ID, arguments]
            target (_this select 0): Object - the object which the action is assigned to
            caller (_this select 1): Object - the unit that activated the action
            ID (_this select 2): Number - ID of the activated action (same as ID returned by addAction)
            arguments (_this select 3): Anything - arguments given to the script if you are using the extended syntax
	returns: nothing
*/


// send message to the server, it will respond as if flare run from server

"pilots_resque1" call SYG_playRandomTrack;