bool SW_WAS_GREEN; bool ES_WAS_GREEN; bool WE_WAS_GREEN;
bool SW_SENSE; bool ES_SENSE; bool WE_SENSE;
mtype = {GREEN, RED};
mtype SW_LIGHT=RED; mtype WE_LIGHT=RED; mtype ES_LIGHT=RED;
chan LIGHT_LOCK = [0] of {bool};
active proctype semaphore(){
bool lock = false;
do 
:: (!lock) -> LIGHT_LOCK ! false; lock = true;
:: (lock) -> LIGHT_LOCK ? true; lock = false;
od
}
inline update_prior() {
if 
:: (SW_WAS_GREEN && ES_WAS_GREEN && WE_WAS_GREEN) ->
SW_WAS_GREEN = false; 
ES_WAS_GREEN = false;
WE_WAS_GREEN = false;
:: else -> skip
fi
}
active proctype SW(){
do
:: (SW_SENSE && (!SW_WAS_GREEN || (!WE_SENSE && !ES_SENSE))) -> 
LIGHT_LOCK ? false;
SW_LIGHT = GREEN;
(!SW_SENSE) -> 
SW_LIGHT = RED;
LIGHT_LOCK ! true;
SW_WAS_GREEN = 1;
update_prior();
od
}
active proctype ES(){
do
:: (ES_SENSE && (!ES_WAS_GREEN || (!WE_SENSE && !SW_SENSE))) -> 
LIGHT_LOCK ? false;
ES_LIGHT = GREEN;
(!ES_SENSE) -> 
ES_LIGHT = RED;
LIGHT_LOCK ! true;
ES_WAS_GREEN = 1;
update_prior();
od
}
active proctype WE(){
do
:: (WE_SENSE && (!WE_WAS_GREEN || (!SW_SENSE && !ES_SENSE))) -> 
LIGHT_LOCK ? false;
WE_LIGHT = GREEN;
(!WE_SENSE) -> 
WE_LIGHT = RED;
LIGHT_LOCK ! true;
WE_WAS_GREEN = 1;
update_prior();
od
}
active proctype SW_car(){
do 
:: ((SW_LIGHT == RED) && !SW_SENSE) -> SW_SENSE = true;  
:: ((SW_LIGHT == GREEN) && SW_SENSE) ->  SW_SENSE = false; 
od
}
active proctype WE_car(){
do 
:: ((WE_LIGHT == RED) && !WE_SENSE) -> WE_SENSE = true;  
:: ((WE_LIGHT == GREEN) && WE_SENSE) ->  WE_SENSE = false; 
od
}
active proctype ES_car(){
do 
:: ((ES_LIGHT == RED) && !ES_SENSE) -> ES_SENSE = true;  
:: ((ES_LIGHT == GREEN) && ES_SENSE) ->  ES_SENSE = false; 
od
}
ltl safety {[] ! (
((SW_LIGHT == GREEN) && (WE_LIGHT == GREEN)) || 
((ES_LIGHT == GREEN) && (WE_LIGHT == GREEN)) ||
((SW_LIGHT == GREEN) && (ES_LIGHT == GREEN)))
}
ltl liveness_SW {
([]<> ! ((SW_LIGHT==GREEN) && SW_SENSE))
-> ([] ((SW_SENSE && (SW_LIGHT == RED)) ->  (<>(SW_LIGHT == GREEN))))
}
ltl liveness_WE {
([]<> ! ((WE_LIGHT==GREEN) && WE_SENSE))
-> ([] ((WE_SENSE && (WE_LIGHT == RED)) -> (<> (WE_LIGHT == GREEN)))) 
}
ltl liveness_ES {
([]<> ! ((ES_LIGHT==GREEN) && ES_SENSE))
-> ([] ((ES_SENSE && (ES_LIGHT == RED)) -> (<> (ES_LIGHT == GREEN)))) }
