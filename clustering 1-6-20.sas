

*reading in aggdata;

%macro aggdata(sheet=,name=);

proc import datafile='/folders/myshortcuts/Documents/UNCW/BallHogTheory/NBA_Aggregate.xlsx'
	out= &name
	dbms=xlsx
	replace;
	sheet=&sheet;
run;

%mend;

%aggdata(sheet='Agg 2013-14',name=agg13);
%aggdata(sheet='Agg 2014-15', name=agg14);
%aggdata(sheet='Agg 2015-16',name=agg15);
%aggdata(sheet='Agg 2016-17',name=agg16);
%aggdata(sheet='Agg 2017-18',name=agg17);
%aggdata(sheet='Agg 2018-19',name=agg18);


*creating year variables in aggdata;
data agg13;
	set agg13;
	year=2013;
run;

data agg14;
	set agg14;
	year=2014;
run;

data agg15;
	set agg15;
	year=2015;
run;

data agg16;
	set agg16;
	year=2016;
run;

data agg17;
	set agg17;
	year=2017;
run;

data agg18;
	set agg18;
	year=2018;
run;


data totalgamedata;
	set agg13 agg14 agg15 agg16 agg17 agg18;
run;



















%macro aggdata(sheet=,name=);

proc import datafile='/folders/myshortcuts/Documents/UNCW/BallHogTheory/season_avg with def.xlsx'
	out= &name
	dbms=xlsx
	replace;
	sheet=&sheet;
run;

%mend;

%aggdata(sheet='2013-2014',name=teamdata13);
%aggdata(sheet='2014-2015', name=teamdata14);
%aggdata(sheet='2015-2016',name=teamdata15);
%aggdata(sheet='2016-2017',name=teamdata16);
%aggdata(sheet='2017-2018',name=teamdata17);
%aggdata(sheet='2018-2019',name=teamdata18);



%macro teamdata(season=,file=);

proc sql outobs=30;
create table &season as
select *
from &file
;
quit;

%mend;

%teamdata(season=season13,file=teamdata13);
%teamdata(season=season14,file=teamdata14);
%teamdata(season=season15,file=teamdata15);
%teamdata(season=season16,file=teamdata16);
%teamdata(season=season17,file=teamdata17);
%teamdata(season=season18,file=teamdata18);



data totaldata;
	set season13 season14 season15 season16 season17 season18;
run;


proc fastclus data=totaldata out=totalclust maxclusters=3 maxiter=100;
	var  time_of_possession avg_drib_per_touch touches paint_touches front_ct_touches elbow_touches post_touches avg_sec_per_touch;
run;


proc candisc data=totalclust out=Can noprint;
   class Cluster;
   var   time_of_possession avg_drib_per_touch touches paint_touches front_ct_touches elbow_touches post_touches avg_sec_per_touch;
run;

proc sgplot data=Can;
   scatter y=Can2 x=Can1 / group=Cluster markerattrs=(symbol=CircleFilled);
run;



proc sql;
create table gamebygameclust as
select totalclust.cluster, totalgamedata.* 
from totalclust , totalgamedata
where totalclust.team = totalgamedata.team and totalclust.year = totalgamedata.year
;
quit;


ods graphics off;
proc glm data=gamebygameclust; 
  class cluster;
  model winloss = cluster / solution noint; 
  lsmeans cluster / diff adjust=tukey;
  format cluster cluster.;
run;

	
proc format;
	value cluster
	 1='Pass Heavy'
	 2='Isolation Heavy'
	 3='Mixed'
	 ;
run;







%macro cluster(season= , clust=  ) ;

proc fastclus data= &season out=&clust maxclusters=4 maxiter=100;
	var time_of_possession avg_drib_per_touch touches paint_touches front_ct_touches elbow_touches post_touches avg_sec_per_touch;
run;


proc candisc data=&clust out=Can noprint;
   class Cluster;
   var  time_of_possession avg_drib_per_touch touches paint_touches front_ct_touches elbow_touches post_touches avg_sec_per_touch;
run;

proc sgplot data=Can;
   scatter y=Can2 x=Can1 / group=Cluster markerattrs=(symbol=CircleFilled);
run;

%mend;


%cluster(season=season13,clust=clust13);
%cluster(season=season14,clust=clust14);
%cluster(season=season15,clust=clust15);
%cluster(season=season16,clust=clust16);
%cluster(season=season17,clust=clust17);
%cluster(season=season18,clust=clust18);






