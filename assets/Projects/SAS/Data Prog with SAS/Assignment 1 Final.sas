/* Assignment 1 */

/* Question 1 */
/* A new library has been made called "S40840". Use import data and dragged and dropped Dub-Airport.csv. Click change and change name to weather and saved. */

%web_drop_table(S40840.Weather);


FILENAME REFFILE '/home/u58705050/my_shared_file_links/u49048486/dub-airport.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=S40840.Weather;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=S40840.Weather; RUN;


%web_open_table(S40840.Weather);

/* Question 2 */
PROC contents data=s40840.weather order=varnum;
run;

/* As we can see, there are 21 variables. The format of the year variable tells us the variable is displayed as character data of length 6 */

/* Question 3 */

PROC print data=s40840.weather(obs=10);
var day month year maxtp mintp rain;
run;

/* The value of the rain variable in the sixth row is 0. */

/* Question 4 */
/* To gain the required code from a snippet, we use the scatter plot matrix entry under the Graph tab. We can then edit the code for our answer */

title 'Weather Profile';
proc sgscatter data=s40840.WEATHER(where=(year in ('2020'))) datacolors=(red) datacontrastcolors=(red);
  label MAXTP='Max Temperature';
  label MINTP='Min Temperature';
  label rain='Rain';
  label wdsp='Windspeed';
  matrix maxtp mintp rain wdsp/
     transparency=0.5 markerattrs=graphdata3(symbol=circlefilled);
  run;

/* Max and Min temperature show a strong positive coorelation. This would be expected as these measurements are tracking the same variable. */
/* It would appear there is no relationship between either of the temperature variables with the windspeed variable.*/
/* It is difficult to establish a coorelation between rain and any of the other recorded variables here. This is partially due to it not raining for a considerable number of days.*/

/* Question 5 */ 
/* Using Data Set and Rename, we can rename any variable we have. */

DATA s40840.Weather;
set s40840.weather;
rename maxtp = Max_Temp
		mintp = Min_Temp
		WDSP = Wind_Speed;
run;

PROC print data=s40840.weather(obs=5);
var day month year Max_Temp Min_Temp Wind_Speed;
run;

/* Question 6 */

data s40840.weathermeantemp;
	set S40840.WEATHER;
	Mean_Temp=(Max_Temp + Min_Temp)/2;
run;

/* This new variable can be found at the end of our table */

/* Question 7 */

proc sort data=S40840.WEATHERMEANTEMP out=S40840.RAINRECORDING
(drop=Max_Temp Min_Temp gmin cbl Wind_Speed g_rad dos pe smd_md evap smd_wd 
		smd_pd hm hg sun ddhm soil) equals;
	where Mean_Temp > 20;
	by day month year Mean_Temp rain;
run;

proc print DATA=S40840.rainrecording;
run;

/* On 3 out of 7 of these days, rain was recorded */ 

/* Question 8 */
/* Let's use the  Summary Statistics tab to calculate this */

proc means data=S40840.WEATHERMEANTEMP chartype mean std min max vardef=df;
	var Mean_Temp rain Wind_Speed;
run;

/* The Max Wind Speed is 28.0 knots. */
/* The Min Mean Temperature is minus 2.8 degrees celcius. */

/* Question 9 */ 
/* We want to check whether Sunshine is in any way correlated to evaporation, whilst this might seem obvious, it should be noted that evaporation is not neccesarily possible as sunshine increases */

title 'Sunshines Relationship to Evaporation';
proc sgplot data=S40840.WEATHERMEANTEMP;
	scatter x=sun y=evap /;
	label sun='Sun';
	label evap='Evaporation'
	xaxis grid;
	yaxis grid;
run;

/* As we can see, these variables are positively coorelated */