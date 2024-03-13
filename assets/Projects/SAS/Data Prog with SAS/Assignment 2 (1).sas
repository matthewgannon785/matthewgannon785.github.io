/* Assignment 2 */

/* Question 1 */
/* A new library has been made called "S40840". Use import data and dragged and dropped Diamonds.csv. Click change and change name to diamonds and saved. */
/* Generated Code (IMPORT) */
/* Source File: diamonds.csv */
/* Source Path: /home/u58705050/my_shared_file_links/u49048486 */
title 'Q1. Loading in new library';
%web_drop_table(S40840.DIAMONDS);


FILENAME REFFILE '/home/u58705050/my_shared_file_links/u49048486/diamonds.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=S40840.DIAMONDS;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=S40840.DIAMONDS; RUN;


%web_open_table(S40840.DIAMONDS);

/* The first column can be removed with the drop command. */
DATA S40840.DIAMONDS(DROP = VAR1);
SET S40840.DIAMONDS;
RUN;

PROC contents data=s40840.diamonds order=varnum;
run;
/* As we can see this has been removed. */

/* Question 2 */
/* The label function is quite straight forward. */
DATA S40840.Diamonds;
Set S40840.Diamonds;
label carat = "Carat of Diamond";
label cut = "Cut Grade";
label color = "Color Grade";
label clarity = "Clarity Grade";
label depth = "Z depth/Z100";
label table = "table width/x100";
label price = " Price of Diamond";
label x = "X Dimesion";
label y = "Y Dimesion";
label z = "Z Dimension";
run;

/* Lets use format to create the missing value variables. */
proc format;
value $missfmt ''='Missing' other = 'Not Missing';
value missfmt . ='Missing' other = 'Not Missing';
run;

/* Lets use the freq and tables function to display these values. */
title 'Q2. Printing Missing Values';
footnote 'Q2. As we can see here there appears to be no values missing.';
proc freq data=s40840.diamonds;
format _CHAR_ $MISSFMT.;
format _NUMERIC_ missfmt.;
tables _char_ / missing nocum nopercent;
tables _numeric_ / missing nocum nopercent;
run;
/* As we can see here there appears to be no values missing. */

/* A quick print scan just to check if we are clearly wrong. (Code here not included as it would be printed. */
/* Does not appear so */

/* Question 3 */
/* Lets use the substring function to leave the first letter of each variable. */

DATA s40840.diamonds;
	set s40840.diamonds;
		cut = substr(cut, 1, 1);
run;
/* This has worked. */

/* Lets use the tranwrd to change these letters to Colourless and Nearly Colourless. */
DATA s40840.diamonds;
	set s40840.diamonds;
		color = tranwrd(color, 'D', 'Colourless');
		color = tranwrd(color, 'E', 'Colourless');
		color = tranwrd(color, 'F', 'Colourless');
		color = tranwrd(color, 'G', 'Near Colourless');
		color = tranwrd(color, 'H', 'Near Colourless');
		color = tranwrd(color, 'I', 'Near Colourless');
		color = tranwrd(color, 'J', 'Near Colourless');
run;

title 'Q3. Printing First Five Rows.';
footnote 'Q3. As we can see this has worked and the colour of the diamond in the 4th row is Nearly Colourless. ';
PROC print data=s40840.diamonds(obs=5);
run;
/* As we can see this has worked and the colour of the diamond in the 4th row is Nearly Colourless. */

/* Question 4 */
/* Forming the new variable volume is fairly straightforward. */
data S40840.diamonds;
set s40840.diamonds;
volume = x*y*z;
run;

/* Now lets use drop again to remove x,y and z */
proc sort data=s40840.diamonds out=s40840.diamonds
(drop = table depth x y z) equals;
by carat cut color clarity price;
run;

/* Question 5 */
/* Using the tasks and utilities and the histogram tab we can achieve this. */
/* I may be misunderstanding the required methodology here, but I am interpreting extreme observantions as those in the first and last percentile here. */
ods noproctitle;
ods graphics / imagemap=on;
title 'Q5. Printing MEANS and UNIVARIATE procedures.';
proc means data=S40840.DIAMONDS chartype median vardef=df p1 q1 q3 p99 qrange 
		qmethod=os;
	var price;
run;

footnote 'Q5. Here we find right skewed data, which is to be expected from more and more expensive diamonds being in lesser quantity. We should note a large interquartile range which would be indicative of high variance between the prices of diamonds. Furthermore considering our median of 2401, values of over 17000 would indicate some extreme outliers on the far end of prices, especially given we have only specified the 99th percentile.';
proc univariate data=S40840.DIAMONDS vardef=df noprint;
	var price;
	histogram price;
	inset median p1 q1 q3 p99 qrange / position=n;
run;

/* Here we find right skewed data, which is to be expected from more and more expensive diamonds being in lesser quantity. */
/* We should note a large interquartile range which would be indicative of high variance between the prices of diamonds. */
/* Furthermore considering our median of 2401, values of over 17000 would indicate some extreme outliers on the far end of prices, especially given we have only specified the 99th percentile. */

/* Question 6 */
/* If statements can help us achieve this with a new variable. */
Data S40840.Diamonds;
set S40840.DIAMONDS;
length carat_cat $ 10;
carat_cat = "Light";
if carat >= 0.5 & carat < 0.8 then carat_cat = "Medium";
if carat >= 0.8 then carat_cat = "Heavy";
run;

/* Question 7 */
/* We can use the table procedure to create a two-way contingency table. */
title 'Q7. Two-way contingency Table';
footnote 'Q7. Heavy and Nearly Colourless is the most common.';
PROC freq data=s40840.diamonds;
	tables 	(carat_cat) * color / plots=all
			nopercent;

/* Heavy and Nearly Colourless is the most common. */
/* Question 8 */
/* Using a filter on our summary statistics code will help us achieve this */
ods noproctitle;
ods graphics / imagemap=on;
title 'Q8. Filtering summary statistics';
footnote 'Q8. The Mean Carat for colourless diamonds of clarity SI2 is 1.9239623.(I am unsure why this prints over 	Q7, I do not see any problem with my code here)';
proc means data=S40840.DIAMONDS chartype mean std min max n vardef=df;
    where price>10000;
	var carat;
	class color clarity;
run;
/* The Mean Carat for colourless diamonds of clarity SI2 is 1.9239623. */

title 'Q8. Mean price by Clarity';
footnote 'Q8. The mean price for SI2 clarity grade diamonds is 5063.03.';
proc means data=S40840.DIAMONDS chartype mean vardef=df;
	var price;
	class clarity;
run;
/* The mean price for SI2 clarity grade diamonds is 5063.03. */

/* Question 9 */
/* My goal is to create a barchart comparing grades of clarity by price. */
/* This will be done using the task and utilities tab and the barchart entry */
title 'Q9. Bar Chart comparing Grades of Clarity by Price with 95% confidence';
footnote 'Q9. My goal is to create a barchart comparing grades of clarity by price. This will be done using the task and utilities tab and the barchart entryHere we can see the SI2 grade commands the highest average price whilst grade VVS1 commands the lowest. Price average for each grade seems relatively similar around 4000. Lastly our 95% confidence limits indicate that grade I1 has the highest variance in price as it has the widest limits. This is likely due to I1 being given the smallest sample in our data, as can be observed in the table in Question 5.';
ods graphics / reset width=6.4in height=4.8in imagemap;
title "Mean Prices of Diamonds by Clarity";
proc sgplot data=S40840.DIAMONDS;
	vbar clarity / response=price limits=both limitstat=clm stat=mean;
	yaxis grid;
run;

ods graphics / reset;

/* Here we can see the SI2 grade commands the highest average price whilst grade VVS1 commands the lowest.*/
/* Price average for each grade seems relatively similar around 4000. */
/* Lastly our 95% confidence limits indicate that grade I1 has the highest variance in price as it has the widest limits. */
/* This is likely due to I1 being given the smallest sample in our data, as can be observed in the table in Question 5. */