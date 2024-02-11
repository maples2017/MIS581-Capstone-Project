filename xptIn1 url "https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/P_DEMO.XPT";
libname xptIn1 xport;

/* Step #2 Create a permanent dataset on my computer */
/*libname mydata "/home/u63730569/sasuser.v94"; create library to create permanent dataset*/

libname mydata "/home/u63730569/sasuser.v94";

data mydata.DEMO_P; set xptIn1.P_DEMO;
/*if 21 le RIDAGEYR le 65;*/
if 18 <= RIDAGEYR <= 55;
if DMDEDUC2 not in (.,7,9);
*** Adults 20 and over:
  * Age 20-80 and over: 0=20+ years, 1= 20–29 years, 2=30–39 years, 3=40–49 years, 4=50–59 years, 5=60–69 years, 6=70–79 years, 8=80 years and over;
  if 18<= ridageyr <30 then AGE1855p = 1;
  if 30<= ridageyr <40 then AGE1855p = 2;
  if 40<= ridageyr <55 then AGE1855p = 3;

  if dmdeduc2 in(1,2,3) then EDUC = 1;    /*HS DIPLOMA or LESS*/
  else if dmdeduc2=4 then EDUC=2;       /*Some college*/
  else if dmdeduc2=5  then EDUC =3;     /*COLLEGE*/

GENDER=RIAGENDR;

/*RENAME old-name-1=new-name-1 . . . <old-name-n=new-name-n>;*/

keep SEQN SDDSRVYR RIDAGEYR RIDEXPRG RIAGENDR GENDER DMDEDUC2 WTINTPRP WTMECPRP SDMVPSU SDMVSTRA RIDRETH3 EDUC AGE1855p;
run;

proc contents data=mydata.DEMO_P;
run;

filename xptIn4 url "https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/P_HUQ.XPT";
libname xptIn4 xport;

/*
HUQ010 - General health condition
HUQ030 - Routine place to go for healthcare
HUQ051 - #times receive healthcare over past year
HUD062 - How long since last healthcare visit
HUQ071 - Overnight hospital patient in last year
HUQ090 - Seen mental health professional/past yr*/


data mydata.HUQ_P; set xptIn4.P_HUQ;
IF HUQ010=7 OR HUQ010=9 THEN DELETE;
IF HUQ030=7 OR HUQ030=9 THEN DELETE;
IF HUD062=77  OR HUD062=99 THEN DELETE;
IF HUQ090=7 OR HUQ090=9 THEN DELETE;
IF HUQ051=99 THEN DELETE;
IF HUQ071=7 OR HUQ071=9 THEN DELETE;
GenHealth =HUQ010;
RoutineCare = HUQ030;
TimesCarePY = HUQ051;
HowlongCareVisit = HUD061;
HospitalStayPY = HUQ071;
MentalHealthVisitPY = HUQ090;
drop HUQ010 HUQ030 HUQ051 HUD062 HUQ071 HUQ090;
run;

PROC FREQ DATA=mydata.HUQ_P;
TABLES HUQ010 HUQ030 HUQ051 HUD062 HUQ071 HUQ090/LIST;
RUN;

PROC FREQ DATA=mydata.HUQ_P;
TABLES GenHealth RoutineCare TimesCarePY HowlongCareVisit HospitalStayPY MentalHealthVisitPY/LIST;
RUN;

proc contents data=mydata.HUQ_P;
run;

filename xptIn2 url "https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/P_MCQ.XPT";
libname xptIn2 xport;


data mydata.MCQ_P; set xptIn2.P_MCQ;
keep SEQN MCQ035 MCQ160a MCQ160b MCQ160c MCQ160d MCQ160e MCQ160f MCQ160p MCQ220;
run;

/*MCQ035 - Still have asthma
MCQ160a - Doctor ever said you had arthritis
MCQ160b - Ever told had congestive heart failure
MCQ160c - Ever told you had coronary heart disease
MCQ160d - Ever told you had angina/angina pectoris
MCQ160e - Ever told you had heart attack
MCQ160f - Ever told you had a stroke
MCQ160p - Ever told you had COPD, emphysema, ChB
MCQ220 - Ever told you had cancer or malignancy*/

/*chronic=(bpq030=1)+(bpq080=1)+(diq010=1)+(mcq035=1)+(mcq160a=1)+(mcq160b=1)+(mcq160c=1)+(mcq160d=1)+(mcq160e=1)+(mcq160f=1)+(mcq160p=1)+(mcq220=1);
if chronic ne . then chroncat=(chronic>0);*/

proc contents data=mydata.MCQ_P;
run;


filename xptIn3 url "https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/P_BPQ.XPT";
libname xptIn3 xport;

data mydata.BPQ_P; set xptIn3.P_BPQ;
keep SEQN BPQ030 BPQ080;
run;

proc contents data=mydata.BPQ_P;
run;

/*Blood Pressure & Cholesterol (P_BPQ)
https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/P_BPQ.XPT*/

/*BPQ020 - Ever told you had high blood pressure
BPQ030 - Told had high blood pressure - 2+ times
BPD035 - Age told had hypertension
BPQ040A - Taking prescription for hypertension
BPQ050A - Now taking prescribed medicine for HBP
BPQ080 - Doctor told you - high cholesterol level
BPQ060 - Ever had blood cholesterol checked
BPQ070 - When blood cholesterol last checked
BPQ090D - Told to take prescriptn for cholesterol
BPQ100D - Now taking prescribed medicine*/


filename xptIn5 url "https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/P_DIQ.XPT";
libname xptIn5 xport;

data mydata.DIQ_P; set xptIn5.P_DIQ;
keep SEQN DIQ010;
run;

proc contents data=mydata.DIQ_P;
run;

/*******************************************************************************************************************************************************/
/*proc means data=mydata.DEMO_P;
var RIDAGEYR;
run;*/

/* Step #3 Sort data by participant id*/

proc sort data=mydata.DEMO_P; by seqn; run;
proc sort data=mydata.HUQ_P; by seqn; run;
proc sort data=mydata.MCQ_P; by seqn; run;
proc sort data=mydata.BPQ_P; by seqn; run;
proc sort data=mydata.DIQ_P; by seqn; run;

/* Step #4 Merge all analytical dataset in one*/

data mydata.WRA_HE1720;
merge mydata.DEMO_P (in=x) mydata.HUQ_P mydata.MCQ_P mydata.BPQ_P mydata.DIQ_P;
by seqn;
if x;

if RIDEXPRG=2 and WTMECPRP>0 then inAnalysis=1;
 
chronic=((bpq030=1)+(bpq080=1)+(diq010=1)+(mcq035=1)+(mcq160a=1)+(mcq160b=1)+(mcq160c=1)+(mcq160d=1)+(mcq160e=1)+(mcq160f=1)+(mcq160p=1)+(mcq220=1));

if chronic = 0 then chroncat = 1;
else if chronic = 1 then chroncat = 2;
else if chronic > 1 then chroncat = 3;

if ROUTINECARE = 1 then ROUTINECARE2 = 1;
else if ROUTINECARE = 2 or ROUTINECARE = 3 then ROUTINECARE2 = 2;

if GenHealth = 1 then GenHealth2 = 1;
else if GenHealth = 2 or GenHealth = 3 then GenHealth2 = 2;
else if GenHealth = 4 or GenHealth = 5 then GenHealth2 =3;
run;

* Create variable to define analysis population: pregnant adults age 18 - 55 (inclusive) with positive exam weight *;

/*RIDEXPRG
1 Yes, positive lab pregnancy test or self-reported pregnant at exam
2 The participant was not pregnant at exam
3 Cannot ascertain if the participant is pregnant at exam
. Missing*/

/*EXAMPLE: POPULATION PROPORTION OF CHOLESTEROL PREVALENCE – ADULTS 20 TO 74.
TITLE “UNADJUSTED MEANS FOR PERCENTAGE WITH HIGH TOTAL CHOLESTEROL”;*/
/* Descriptive Analysis */


/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/
/*DATA ANALYSIS*/

libname mydata "/home/u63730569/sasuser.v94";

proc sort data = mydata.WRA_HE1720;
  by sdmvstra sdmvpsu;
run;

proc surveyfreq data=mydata.WRA_HE1720 (WHERE=(inAnalysis=1));
      tables  RIDRETH3 * CHRONIC/row wchisq;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTMECPRP;
   run;

proc surveyfreq data=mydata.WRA_HE1720 (WHERE=(inAnalysis=1));
      tables  RIDRETH3 * ROUTINECARE2/row wchisq;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTMECPRP;
   run;

/* Race and ethnicity CHRONIC */
proc surveyfreq data=mydata.WRA_HE1720 (WHERE=(inAnalysis=1));
      tables  RIDRETH3* CHRONIC/row wchisq;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTMECPRP;
   run;


/* Number of Chronic Conditions by Race and enthinicity */
proc surveyfreq data=mydata.WRA_HE1720 (WHERE=(inAnalysis=1));
      tables  RIDRETH3 * CHRONCAT/row wchisq;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTMECPRP;
   run;


/* Number of Chronic Conditions by Race and Enthinicity */
proc surveyfreq data=mydata.WRA_HE1720 (WHERE=(inAnalysis=1));
      tables  RIDRETH3 * CHRONCAT/row wchisq;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTMECPRP;
   run;


proc freq data=mydata.WRA_HE1720 (WHERE=(inAnalysis=1));
      tables  RIDRETH3 * CHRONCAT/CHISQ EXACT;
run;

/* Race and ethnicity RoutineCare2 */
 
proc surveyfreq data=mydata.WRA_HE1720 (WHERE=(inAnalysis=1));
      tables  RIDRETH3 * ROUTINECARE2/row wchisq;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTMECPRP;
   run;


proc surveyfreq data=mydata.WRA_HE1720 (WHERE=(inAnalysis=1));
      tables  RIDRETH3*(GenHealth RoutineCare TimesCarePY HowlongCareVisit HospitalStayPY MentalHealthVisitPY)/row wchisq;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTMECPRP;
   run;

proc surveyfreq data=mydata.WRA_HE1720 (WHERE=(inAnalysis=1));
      tables  RIDRETH3* TimesCarePY/row wchisq;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTMECPRP;
   run;



/* General Health status by Race and enthinicity */
proc surveyfreq data=mydata.WRA_HE1720 (WHERE=(inAnalysis=1));
      tables  RIDRETH3 * GenHealth2/row wchisq;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTMECPRP;
   run;


/* Cancorr */

proc cancorr data=mydata.WRA_HE1720 (WHERE=(inAnalysis=1)) all
	vprefix = Numerical vname = 'Numerical variable'
	wprefix = Categorical wname = 'Categorical variable';
	var =  chroncat;
	with RIDRETH3;
	title 'Canonical Correlations and Multiple Statistics';
run;


proc corr data=mydata.WRA_HE1720 (WHERE=(inAnalysis=1));
  var RIDRETH3 CHRONIC GenHealth ROUTINECARE2 RoutineCare TimesCarePY HowlongCareVisit HospitalStayPY MentalHealthVisitPY;
run;
 
proc export 
  data=mydata.WRA_HE1720
  dbms=xlsx 
  outfile="/home/u63730569/sasuser.v94" 
  replace;
run;