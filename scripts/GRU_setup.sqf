//
// GRU_setup.sqf by Sygsky at 08-DEC-2015. For Domination GRU tasks system.
//

#define arg(x) (_this select(x))
#define argp(arr,x) ((arr)select(x))
#define inc(x) ((x)=(x)+1)
#define argopt(num,val) if ((count _this)<=(num))then{val}else{arg(num)}

// offsets for array to call GRU_startNewTask
#define GRU_TASK_KIND 0
#define GRU_TASK_PARAMS 1

#define GRU_MAIN_TOWN_INFO 0
#define GRU_MAIN_SCORE 1
#define GRU_MAIN_LIST 2

// main task target town params
#define TONW_CENTER_IN_INFO 0
#define TOWN_NAME_IN_INFO 1
#define TOWN_RADIOUS_IN_INFO 2

// mission kind offsets in common array
#define GRU_MAIN_TASK 0
#define GRU_SECONDARY_TASK 1
#define GRU_OCCUPIED_TASK 2
#define GRU_PERSONAL_TASK 3
#define GRU_FIND_TASK 4

// GRU to client message ids (sent from server only)
#define GRU_MSG_STOP_TASK 0
#define GRU_MSG_START_TASK 1

#define GRU_MSG_INFO_TO_USER		 100
// subkind of GRU_MSG_INFO_TO_USER
#define GRU_MSG_INFO_KIND_PATROL_DETECTED 1
#define GRU_MSG_INFO_KIND_PATROL_ABSENCE 2
#define GRU_MSG_INFO_KIND_MAP_CREATED 10

// GRU to client and server message ids (may be sent from client as result and server as info)
#define GRU_MSG_TASK_SOLVED 2
#define GRU_MSG_TASK_FAILED 3

// GRU to server message ids (may be sent from client only)
#define GRU_MSG_TASK_ACCEPTED 4
#define GRU_MSG_TASK_SKIPPED 5
#define GRU_MSG_COMP_CREATED 6

// minimum score to allow task start
#define GRU_MAIN_TASK_MIN_SCORE 30

#define GRU_SECONDARY_MARKER_NAME (cur_mis_ind) (format["XMISSIONM%1",current_mission_index+1])

#define GRU_GET_TASK(ind) argp(GRU_tasks,ind)
#define GRU_MAIN_GET_TOWN_INFO argp(GRU_GET_TASK(GRU_MAIN_TASK),GRU_MAIN_TOWN_INFO)
#define GRU_MAIN_GET_TOWN_INFO_FROM_TASK(tsk) argp(tsk,GRU_MAIN_TOWN_INFO)
#define GRU_MAIN_GET_TOWN_NAME_FROM_TASK(tsk) GET_TOWN_NAME(GRU_MAIN_GET_TOWN_INFO_FROM_TASK(tsk))

#define GET_TOWN_CENTER(tinfo) argp(tinfo,TONW_CENTER_IN_INFO)
#define GET_TOWN_NAME(tinfo) argp(tinfo,TOWN_NAME_IN_INFO)
#define GET_TOWN_RADIOUS(tinfo) argp(tinfo,TOWN_RADIOUS_IN_INFO)

#define GRU_MAIN_GET_TOWN_CENTER GET_TOWN_CENTER(GRU_MAIN_GET_TOWN_INFO)
#define GRU_MAIN_GET_TOWN_NAME GET_TOWN_NAME(GRU_MAIN_GET_TOWN_INFO) 
#define GRU_MAIN_GET_TOWN_RADIOUS GET_TOWN_RADIOUS(GRU_MAIN_GET_TOWN_INFO)
#define GRU_MAIN_GET_SCORE argp(GRU_GET_TASK(GRU_MAIN_TASK),GRU_MAIN_SCORE)
#define GRU_MAIN_GET_SCORE_FROM_TASK(tsk) argp(tsk,GRU_MAIN_SCORE)
// calculate score minus  from score plus
#define GRU_MAIN_GET_SCORE_MINUS(score_plus) (floor(score_plus/4/10)*10)

#define GRU_SET_MAIN_TASK_SCORE(score) 
#define GRU_MAIN_GET_USER_LIST argp(GRU_GET_TASK(GRU_MAIN_TASK),GRU_MAIN_LIST)
#define GRU_CLEAR_MAIN_TASK_USER_LIST (GRU_GET_TASK(GRU_MAIN_TASK)set[GRU_MAIN_LIST,[]])

#define GRU_CLEAR_TASK(id) (if(TASK_ID_IS_VALID(id))then{GRU_tasks set[id,[]]})

#define TASK_IS_EMPTY(tsk) (count(tsk)==0)
#define TASK_IS_ACTIVE(tsk) (count(tsk)>0)
#define TASK_ID_IS_ACTIVE(id) TASK_IS_ACTIVE(GRU_GET_TASK(id))

#define MAIN_TASK_IS_EMPTY TASK_IS_EMPTY(GRU_GET_TASK(GRU_MAIN_TASK))
#define MAIN_TASK_IS_ACTIVE TASK_IS_ACTIVE(GRU_GET_TASK(GRU_MAIN_TASK))

#define GRU_TASK_NUMBER (count GRU_tasks)

#define TASK_ID_IS_VALID(id) (((id)>=0)AND(id<(count GRU_tasks)))
#define TASK_ID_NOT_VALID(id) (((id)<0)OR(id>=(count GRU_tasks)))

#define WAIT_FOR_PLAYER_CONNECTION (if(X_MP)then{if((call XPlayersNumber)==0)then{waitUntil{sleep 15;(call XPlayersNumber)>0};}})

#define PLAYER_ACTION_REMOVE_DOC_ID_NAME "remove_doc_id"

#define COMPUTER_ACTION_ID_NAME "GRU_comp_action_id"

#define GRU_BEFORE_NEXT_JOB_DELAY 600

#define GRU_SPECIAL_SCORE_ON_FIRELIT_INFO 0
#define GRU_SPECIAL_SCORE_ON_MAP_INFO 1