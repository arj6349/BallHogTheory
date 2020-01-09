
						/***READING IN OUR DATA***/

proc import datafile='/folders/myshortcuts/Documents/UNCW/BallHogTheory/data/BallHogTeamData.xlsx'
	out=teamtrain
	dbms=xlsx
	replace;
	sheet='train';
run;

proc import datafile='/folders/myshortcuts/Documents/UNCW/BallHogTheory/data/BallHogTeamData.xlsx'
	out=teamtest
	dbms=xlsx
	replace;
	sheet='test';
run;


						/*** SORTING OUR DATA***/



data teamtrain2;
	set teamtrain(drop=ppe_touch_team ppPost_touch_team ppPaint_touch_team);
		team_win_pct = team_W / (team_L +team_W);
	rename top_team = timeofposs;
	label top_team ='timeofposs_team';
run;


data teamtest2;
	set teamtest(drop=ppe_touch_team ppPost_touch_team ppPaint_touch_team);
		team_win_pct = team_W / (team_L +team_W);
	rename top_team = timeofposs;
	label top_team ='timeofposs_team';
run;



						/***CREATING OUR REGRESSION MODEL***/

proc reg data = teamtrain2 ;
	id team;
	model team_ppg = team_touches -- Paint_touch_team / selection = adjRSQ aic sbc;
run;

proc reg data = teamtrain2 outest=output;
	id team;
	PPG: model team_ppg = timeofposs sec_touch_team pp_touch_team e_touches_team post_ups_team;
	Title 'Regression on Train Set';
run;



proc reg data = teamtest2;
	id team;
	model team_ppg = timeofposs sec_touch_team pp_touch_team e_touches_team post_ups_team;
run;


						/***TESTING OUR REGRESSION MODEL***/

proc score data=work.teamtest2 score=output type=parms predict out=predicted_data;
	var timeofposs sec_touch_team pp_touch_team e_touches_team post_ups_team;
run;



Title  'Team PPG 18-19 Season';
proc sgplot data = work.teamtest2 noautolegend;
	vbar team / group = team response = team_ppg;
	yaxis values= (90 to 120 by 10) label = 'PPG';
	xaxis label = 'Team';

run;

proc sql;
create table predict as 
select team, team_ppg as actual_ppg, PPG as predicted_ppg
from work.predicted_data;
;
quit;

TITLE 'Team PPG actual vs predicted';
proc sgplot data=work.predict noautolegend;
	series x=team y=actual_ppg;
	series x = team y= predicted_ppg;
	yaxis values= (90 to 120 by 10) label = 'PPG';
	xaxis label = 'Team';
run;
