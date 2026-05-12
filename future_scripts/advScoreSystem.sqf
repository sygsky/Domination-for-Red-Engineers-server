//
// advScoreSystem.sqf created by Sygsky at 29-FEB-2016
// counts score player received during last 4 lifes. If score > 10 per life, +40 scores added as prize
//
// Call this script on client computer only
//

if ( isServer && (!X_SPE) ) exitWith { hint localize "--- scripts/advScoreSystem.sqf can't be call on server"};

#define SCORES_PER_LIFE 10
#define LIFE_CHECKED_COUNT 4

if (!isNil "SYG_lastScore" ) exitWith {hint localize "--- advScoreSystem.sqf spawned more then 1 time"};

SYG_lastScore    = score player; // initial player score

SYG_score_per_award  = SCORES_PER_LIFE * LIFE_CHECKED_COUNT;
SYG_score_inform_limit = (LIFE_CHECKED_COUNT-1)*SCORES_PER_LIFE;

SYG_scoreCount   = 0;
SYG_deathCounter = 0;
SYG_scoreQueue   = []; // score per lifes period check cycle
for "_i" from 0 to LIFE_CHECKED_COUNT - 1 do {SYG_scoreQueue set [_i,0]};

SYG_bumpScores = {
	private ["_score"];
	_score = score player;
	if ( _score  <= SYG_lastScore )  exitWith {};
	SYG_lastScore = score player;
	if ( vehicle player != player ) exitWith {}; // check score only if player is not in vehicle
    private ["_score_bump","_i"];
    _score_bump = _score - SYG_lastScore;
    if (( SYG_scoreCount + _score_bump) >= SYG_score_per_award) then {
        // lets award user with additional scores
        //player addScore SYG_score_per_award;
   		SYG_score_per_award call SYG_addBonusScore;

        // todo: inform user about prize
        // reset internal data
        SYG_scoreCount = ( SYG_scoreCount + _score_bump) - SYG_score_per_award;
        for "_i" from 0 to LIFE_CHECKED_COUNT - 1 do { SYG_scoreQueue set [_i, 0]; };
    } else {
        SYG_scoreQueue set [SYG_deathCounter, (SYG_scoreQueue select SYG_deathCounter) + _score_bump];
        if ( SYG_scoreCount >= SYG_score_inform_limit ) then {
            (format["Got score +%1, lost life count %2, award after +%3 scores",SYG_score_per_award - SYG_scoreCount, SYG_deathCounter, SYG_score_per_award]) call XfGlobalChat;
        };
    };
};

SYG_bumpDeath = {
	private ["_prev_score"];
	SYG_deathCounter = (SYG_deathCounter + 1) mod LIFE_CHECKED_COUNT;
	_prev_score = SYG_scoreCount;
	SYG_scoreCount  = SYG_scoreCount - (SYG_scoreQueue select SYG_deathCounter);
	SYG_scoreQueue set [ SYG_deathCounter, 0 ];
	if ( ( _prev_score >= SYG_score_inform_limit) && (SYG_scoreCount < SYG_score_inform_limit) ) then
	{
		(format["Get %1 more scores in this life round to be awarded +%2 scores",SYG_score_per_award - SYG_scoreCount, SYG_score_per_award]) call XfGlobalChat;
	};
};