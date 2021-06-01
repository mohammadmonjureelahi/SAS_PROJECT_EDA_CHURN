/* Let us import the dataset to SAS first. We bring the dataset to the Permanent custome Library named Project. */

DATA Project.CustomerBehavior;
Infile "C:\Users\ruzdomain\Desktop\ASAS\Project\New_Wireless_Fixed.txt";

Input @1 Account_Number $13. 
      @15 Account_Activation_Date MMDDYY10. 
	  @26 Account_Deactivation_Date MMDDYY10. 
      @37 Reason_For_Deactivation $8.
      @53 Customer_Credit_Status 1.
      @62 Rate_Plan 1.
	  @65 Dealer_Type $2.
	  @74 Customer_Age 2.
	  @80 Province $2.
	  @83 Sales_Amount dollar8.2
 ;      
Format Account_Activation_Date Account_Deactivation_Date MMDDYY10. Sales_Amount dollar8.2;
RUN;

/* We check the top 20 observation of the dataset. */
TITLE;
PROC PRINT DATA = Project.CustomerBehavior (OBS =20);
RUN;

/* We examin the content of the dataset. */

PROC CONTENTS DATA=Project.CustomerBehavior varnum;
RUN;

/* We came to know from the output of the content that total number of rows were 102255 and we go ahead to check the bottom 20 row. */

PROC PRINT DATA = Project.CustomerBehavior (FIRSTOBS=102236) ;
RUN;

/* Let us attempt to find the distribution of missing and non-mmising values in each column. */

DATA WORK.CustomerBehavior_00 ;
SET Project.CustomerBehavior ;
RUN;

proc format ;
  value $missfmt ' ' = 'Missing' other = 'Not Missing';
  value  missfmt  .  = 'Missing' other = 'Not Missing';
  RUN;



PROC FREQ DATA = CustomerBehavior_00;
format _CHAR_ $missfmt.;
format _NUMERIC_ missfmt.;
tables _CHAR_ / missing nocum nopercent;
tables _NUMERIC_ / missing nocum nopercent;
RUN;

PROC PRINT DATA = WORK.CustomerBehavior_00 (FIRSTOBS=102236) ;
RUN;


DATA CustomerBehavior_Missing;
	SET Project.CustomerBehavior;
	format Account_Number Reason_For_Deactivation Dealer_Type Province $missfmt. 
          Account_Number Account_Activation_Date Account_Deactivation_Date Customer_Credit_Status Rate_Plan Customer_Age  Sales_Amount missfmt.;
RUN;

PROC PRINT DATA = CustomerBehavior_Missing (FIRSTOBS=102236) ;
RUN;

PROC CONTENTS DATA=CustomerBehavior_Missing varnum;
RUN;

PROC GCHART DATA = CustomerBehavior_Missing;
vbar Account_Number;
RUN;


PROC GCHART DATA = CustomerBehavior_Missing;
vbar Reason_For_Deactivation;
RUN;


PROC GCHART DATA = CustomerBehavior_Missing;
vbar Dealer_Type;
RUN;


PROC GCHART DATA = CustomerBehavior_Missing;
vbar Province;
RUN;

PROC GCHART DATA = CustomerBehavior_Missing;
PIE Customer_Credit_Status ;
RUN;


/* Let us now attempt to vizualize the data as it is found just after loadinbg the data to SAS. */

PROC GCHART DATA = Project.CustomerBehavior;
vbar Reason_For_Deactivation;
RUN;


PROC GCHART DATA = Project.CustomerBehavior;
vbar Dealer_Type;
RUN;


PROC GCHART DATA = Project.CustomerBehavior;
vbar Province;
RUN;

PROC GCHART DATA = Project.CustomerBehavior;
PIE Customer_Credit_Status ;
RUN;

PROC GCHART DATA = Project.CustomerBehavior;
PIE Rate_Plan ;
RUN;


PROC UNIVARIATE DATA = Project.CustomerBehavior;
var Customer_Age;
histogram/normal;
RUN;


PROC UNIVARIATE DATA = Project.CustomerBehavior;
var Sales_Amount;
histogram/normal;
RUN;

 
/* Let us now convert the missing values in the Account_Deactivation_Date column to churn value RETAIN meaning that churn did not take place and
   non missing values to churn value CHURN meaning that churn took place. */


PROC SQL;
 CREATE TABLE Project.CustomerBehavior_01 AS
 SELECT * ,
		CASE 
        WHEN Account_Deactivation_Date EQ . THEN "RETAIN"
        ELSE "CHURN"
		END AS Churn_Status
FROM Project.CustomerBehavior
;
QUIT;

PROC PRINT DATA = Project.CustomerBehavior_01 (OBS =20) ;
RUN;

/* Trying to convert the missing values to MEAN for Customer_Age */
PROC SQL;
 CREATE TABLE Project.CustomerBehavior_01a AS
 SELECT * ,
		CASE 
        WHEN Customer_Age EQ . THEN MEAN(Customer_Age)
        ELSE Customer_Age
		END AS NM_Customer_Age
FROM Project.CustomerBehavior_01
;
QUIT;

PROC PRINT DATA = Project.CustomerBehavior_01a (OBS =20) ;
RUN;


/* Trying to convert the missing values to MEAN for Sales_Amount */
PROC SQL;
 CREATE TABLE Project.CustomerBehavior_01b AS
 SELECT * ,
		CASE 
        WHEN Sales_Amount EQ . THEN MEAN(Sales_Amount)
        ELSE Sales_Amount
		END AS NM_Sales_Amount
FROM Project.CustomerBehavior_01a
;
QUIT;

PROC PRINT DATA = Project.CustomerBehavior_01b (OBS =20) ;
RUN;



/* Trying to convert the 1 and 0 to "GOOD CREDIT" and "NOT GOOD" for Customer_Credit_Status */
PROC SQL;
 CREATE TABLE Project.CustomerBehavior_01c AS
 SELECT * ,
		CASE 
        WHEN Customer_Credit_Status EQ 1 THEN "GOOD CREDIT"
        ELSE "NOT GOOD"
		END AS NM_Customer_Credit_Status
FROM Project.CustomerBehavior_01b
;
QUIT;

PROC PRINT DATA = Project.CustomerBehavior_01c (OBS =20) ;
RUN;

PROC CONTENTS DATA=Project.CustomerBehavior_01c varnum;
RUN;

/* Trying to convert the 1, 2 and 3 to "LEVEL1", "LEVEL2" and "LEVEL3" respectively for Customer_Credit_Status */

DATA Project.CustomerBehavior_01d;
 SET Project.CustomerBehavior_01c;
 IF Rate_Plan EQ 1 THEN CH_Rate_Plan = "LEVEL1";
 ELSE IF Rate_Plan EQ 2 THEN CH_Rate_Plan = "LEVEL2";
 ELSE CH_Rate_Plan = "LEVEL3";
RUN;

PROC PRINT DATA = Project.CustomerBehavior_01d (OBS =20) ;
RUN;


/* Let us drop the unnecessary columns for now. */

DATA Project.CustomerBehavior_01e (DROP=Customer_Credit_Status Rate_Plan Customer_Age Sales_Amount) ;
SET Project.CustomerBehavior_01d;

rename NM_Customer_Credit_Status=Customer_Credit_Status ;
rename CH_Rate_Plan=Rate_Plan ;
rename NM_Customer_Age=Customer_Age ;
rename NM_Sales_Amount=Sales_Amount ;


RUN;


PROC PRINT DATA = Project.CustomerBehavior_01e (OBS =20) ;
RUN;


/* Let us check the number of Account_Number,Reason_For_Deactivation, Customer_Credit_Status, Rate_Plan, Dealer_Type and Province.   */
PROC SQL;
SELECT count(distinct Account_Number) as Total_Unique_Account_Number,
       count(distinct Reason_For_Deactivation) as Unique_Reason,
	   count(distinct Customer_Credit_Status) as Credit_Status,
	   count(distinct Rate_Plan) as Rate_Plan,
	   count(distinct Dealer_Type) as Dealer_Type,
	   count(distinct Province) as Province
FROM Project.CustomerBehavior_01e;
QUIT;

/* Let us determine Earliest/Latest Activation, Earliest/Latest Deactivation dates and also maximum of Customer_age and Sales_Amount. */

PROC SQL;
SELECT min(Account_Activation_Date) as Earliest_Activation format=MMDDYY10.,
       max(Account_Activation_Date) as Latest_Activation format=MMDDYY10.,
       min(Account_Deactivation_Date) as Earliest_Deactivation format=MMDDYY10.,
	   max(Account_Deactivation_Date) as Latest_Deactivation format=MMDDYY10.,
       min(Customer_Age) as Min_Customer_Age,
	   max(Customer_Age) as Max_Customer_Age,
	   min(Sales_Amount) as Min_Sales_Amount format=dollar8.2,
	   max(Sales_Amount) as Max_Sales_Amount format=dollar8.2

FROM Project.CustomerBehavior_01e;
QUIT;


/* Number of total activation and deactivation during the time period of the study */

PROC SQL;
SELECT count(Account_Activation_Date) as Total_Activation,
       count(Account_Deactivation_Date) as Total_Deactivation

FROM Project.CustomerBehavior_01e;
QUIT;

/* Let us have a look at the table for each categorical variable. */

PROC FREQ DATA = Project.CustomerBehavior_01e;
table Churn_Status;
RUN;

PROC FREQ DATA = Project.CustomerBehavior_01e;
table Reason_For_Deactivation;
RUN;


PROC FREQ DATA = Project.CustomerBehavior_01e;
table Customer_Credit_Status;
RUN;


PROC FREQ DATA = Project.CustomerBehavior_01e;
table Rate_Plan;
RUN;

PROC FREQ DATA = Project.CustomerBehavior_01e;
table Dealer_Type;
RUN;


PROC FREQ DATA = Project.CustomerBehavior_01e;
table Province;
RUN;


/*

PROC MEANS DATA = Project.CustomerBehavior_01;
RUN;
*/


/* Let us use the below user defined format to convert few numerical column values into some group of values.*/

proc format ;
  value salesg
        low-<100='LT100' 
		100- <500='LT500'
		500- <800='LT800'
		800-high='GT800'
		;
  
  value ageg
        low-<20='TEEN' 
		20- <40='LT40'
		40- <60='LT60'
		60-high='Senior'
		;
  value tenureg
        low-<31='UPTO_MONTH' 
		31- <61='UPTO2MONTHS'
		61- <366='UPTO_YEAR'
		366-high='YEAR+'
		;
run;


DATA CustomerBehavior_02;
	SET Project.CustomerBehavior_01e;
	format Customer_Age ageg. Sales_Amount salesg.;
RUN;

PROC PRINT DATA = CustomerBehavior_02 (OBS =20);
RUN;

/* Let us check the distribution of Customer_Age and Sales_Amount after converting those to categorical variables. */

PROC FREQ DATA = CustomerBehavior_02;
table Customer_Age;
RUN;

PROC FREQ DATA = CustomerBehavior_02;
table Sales_Amount;
RUN;


/* Let us calculate the Tenure of the customer in number of days.We have considered partial days as well.*/

PROC SQL;
 CREATE TABLE CustomerBehavior_03 AS
 SELECT * ,
		CASE 
        WHEN Account_Deactivation_Date EQ . THEN (max(Account_Activation_Date) - Account_Activation_Date + 1)
        ELSE (Account_Deactivation_Date - Account_Activation_Date + 1)
		END AS Tenure_in_Days
FROM CustomerBehavior_02
;
QUIT;

PROC PRINT DATA = CustomerBehavior_03 (OBS =20) ;
RUN;


PROC UNIVARIATE DATA = CustomerBehavior_03;
var Tenure_in_Days;
histogram/normal;
RUN;



/* Let us check the maximum and minimum tenure considering the last date of the dataset. */

PROC SQL;
SELECT min(Tenure_in_Days) as Min_Tenure_in_Days,
	   max(Tenure_in_Days) as Max_Tenure_in_Days	
       
FROM CustomerBehavior_03;
QUIT;

/* Let us convert the Tenure in number of days to categories as instructed. */

DATA CustomerBehavior_04;
	SET CustomerBehavior_03;
	format Tenure_in_Days tenureg.;
RUN;

PROC PRINT DATA = CustomerBehavior_04 (OBS =20) ;
RUN;

PROC FREQ DATA = CustomerBehavior_04;
table Tenure_in_Days;
RUN;


/* Let us perform some bivariate analysis in visualization. */


PROC GCHART DATA=CustomerBehavior_04;
vbar Customer_Credit_Status/subgroup=Churn_Status type=percent;
RUN;


PROC GCHART DATA=CustomerBehavior_04;
vbar Rate_Plan/subgroup=Churn_Status type=percent;
RUN;


PROC GCHART DATA=CustomerBehavior_04;
vbar Dealer_Type/subgroup=Churn_Status type=percent;
RUN;

proc freq DATA=CustomerBehavior_04 order=freq;
   tables Churn_Status*Customer_Age / 
       plots=freqplot(twoway=stacked orient=horizontal);
run;


proc freq DATA=CustomerBehavior_04 order=freq;
   tables Churn_Status*Customer_Age / 
       plots=freqplot(twoway=stacked orient=horizontal);
run;

proc freq DATA=CustomerBehavior_04 order=freq;
   tables Churn_Status*Sales_Amount / 
       plots=freqplot(twoway=stacked orient=horizontal);
run;


PROC CONTENTS DATA=CustomerBehavior_04 varnum;
RUN;


PROC PRINT DATA = CustomerBehavior_04 (OBS =20) ;
RUN;

/* Let us now drop the AccountActivationDate and AccountDeactivationDate as the tenure of chruned and retained customers have been captured in Tenure in Days column already */




DATA CustomerBehavior_05 (DROP=Account_Activation_Date Account_Deactivation_Date) ;
SET CustomerBehavior_04;
RUN;


PROC PRINT DATA = CustomerBehavior_05 (OBS =20);
RUN;


/* We examin the content of the dataset. */

PROC CONTENTS DATA=CustomerBehavior_05 varnum;
RUN;



/* Let us perform some bivariate analysis. */

PROC GCHART DATA=CustomerBehavior_05;
vbar Reason_For_Deactivation/subgroup=Churn_Status type=percent;
RUN;


PROC GCHART DATA=CustomerBehavior_05;
vbar Province/subgroup=Churn_Status type=percent;
RUN;




PROC GCHART DATA=CustomerBehavior_05;
vbar Customer_Credit_Status/subgroup=Churn_Status type=percent;
RUN;


PROC GCHART DATA=CustomerBehavior_05;
vbar Rate_Plan/subgroup=Churn_Status type=percent;
RUN;


PROC GCHART DATA=CustomerBehavior_05;
vbar Dealer_Type/subgroup=Churn_Status type=percent;
RUN;

PROC GCHART DATA=CustomerBehavior_05;
vbar Churn_Status/subgroup=Customer_Age type=percent;
RUN;


PROC GCHART DATA=CustomerBehavior_05;
vbar Sales_Amount/subgroup=Churn_Status type=percent;
RUN;


PROC CONTENTS DATA=CustomerBehavior_05 varnum;
RUN;



/* Let us try to analyze relationships among tenure segments and “Good Credit” “RatePlan ” and “DealerType, RatePlan and DelaerType.” */

proc freq DATA=CustomerBehavior_05 order=freq;
   tables Customer_Credit_Status*Tenure_in_Days / 
       plots=freqplot(twoway=stacked orient=horizontal);
run;


proc freq DATA=CustomerBehavior_05 order=freq;
   tables Rate_Plan*Tenure_in_Days / 
       plots=freqplot(twoway=stacked orient=horizontal);
run;

proc freq DATA=CustomerBehavior_05 order=freq;
   tables Dealer_Type*Tenure_in_Days / 
       plots=freqplot(twoway=stacked orient=horizontal);
run;


proc freq DATA=CustomerBehavior_05 order=freq;
   tables Dealer_Type*Rate_Plan / 
       plots=freqplot(twoway=stacked orient=horizontal);
run;


/* Let us try to analyze relationships between account status(Churn/Retain) and Tenure Segments. */



proc freq DATA=CustomerBehavior_05 order=freq;
   tables Churn_Status*Tenure_in_Days / 
       plots=freqplot(twoway=stacked orient=horizontal);
run;


proc freq DATA=CustomerBehavior_05 order=freq;
   tables Churn_Status*Tenure_in_Days / 
       plots=freqplot(twoway=stacked orient=horizontal);
run;


/* Does Sales amount differ among different account status, GoodCredit, and customer age segments? */


proc freq DATA=CustomerBehavior_05 order=freq;
   tables Churn_Status*Sales_Amount / 
       plots=freqplot(twoway=stacked orient=horizontal);
run;


proc freq DATA=CustomerBehavior_05 order=freq;
   tables Customer_Credit_Status*Sales_Amount / 
       plots=freqplot(twoway=stacked orient=horizontal);
run;



proc freq DATA=CustomerBehavior_05 order=freq;
   tables Customer_Age*Sales_Amount / 
       plots=freqplot(twoway=stacked orient=horizontal);
run;



/* Let us now find the statistical significant association between out target variable which is Churn_Status and other variables. */


PROC FREQ DATA=CustomerBehavior_05;
TITLE "RELATIONSHIP BETWEEN BETWEEN Reason_For_Deactivation AND Churn_Status";
TABLE Reason_For_Deactivation * Churn_Status/CHISQ OUT=OUT_Deactivation_Churn_Status;
RUN;

PROC FREQ DATA=CustomerBehavior_05;
TITLE "RELATIONSHIP BETWEEN BETWEEN Dealer_Type AND Churn_Status";
TABLE Dealer_Type * Churn_Status/CHISQ OUT=OUT_Dealer_Type_Churn_Status;
RUN;

PROC FREQ DATA=CustomerBehavior_05;
TITLE "RELATIONSHIP BETWEEN BETWEEN Province AND Churn_Status";
TABLE Province * Churn_Status/CHISQ OUT=OUT_Province_Churn_Status;
RUN;

PROC FREQ DATA=CustomerBehavior_05;
TITLE "RELATIONSHIP BETWEEN BETWEEN Customer_Age AND Churn_Status";
TABLE Customer_Age * Churn_Status/CHISQ OUT=OUT_Customer_Age_Churn_Status;
RUN;

PROC FREQ DATA=CustomerBehavior_05;
TITLE "RELATIONSHIP BETWEEN BETWEEN Sales_Amount AND Churn_Status";
TABLE Sales_Amount * Churn_Status/CHISQ OUT=OUT_Sales_Amount_Churn_Status;
RUN;

PROC FREQ DATA=CustomerBehavior_05;
TITLE "RELATIONSHIP BETWEEN BETWEEN Customer_Credit_Status AND Churn_Status";
TABLE Customer_Credit_Status * Churn_Status/CHISQ OUT=OUT_Credit_Statust_Churn_Status;
RUN;

PROC FREQ DATA=CustomerBehavior_05;
TITLE "RELATIONSHIP BETWEEN BETWEEN Rate_Plan AND Churn_Status";
TABLE Rate_Plan * Churn_Status/CHISQ OUT=OUT_Rate_Plan_Churn_Status;
RUN;

PROC FREQ DATA=CustomerBehavior_05;
TITLE "RELATIONSHIP BETWEEN BETWEEN Tenure_in_Days AND Churn_Status";
TABLE Tenure_in_Days * Churn_Status/CHISQ OUT=OUT_Tenure_Churn_Status;
RUN;
