/*Student name: Ammar Saad*/
/*EPI 5143 Large databases Quiz 5 submission*/

/*creating permanent repositories*/
libname fixed 'C:\Users\ammar\Desktop\EPI5143\classfile'; run;
libname qz5 'C:\Users\ammar\Desktop\EPI5143\EPI5143 work\programs'; run;

/*creating a new dataset called "spine" from the dataset NhrAbstract and keeping admissions
took place in the years 2003 and 2004*/
data qz5.spine;
set fixed.NhrAbstracts;
by hraEncWID;
if year(datepart(hraAdmDtm)) not in (2003,2004) then delete;
run;

/*sorting the spine dataset by admission IDs and ensureing the absense of duplicates*/
proc sort data=qz5.spine nodupkey;
by hraEncWID;
run;

/*flat-filing the diagnosis dataset and renaming encouter ID variable*/
proc sort data=fixed.nhrdiagnosis out=diag1 (rename=hdgHraEncWID=hraEncWID);
by hdgHraEncWID;
run;

data qz5.diabetes;
set diag1;
by hraEncWID;
if first.hraEncWID then do;
	DM=0; count=0;
	end;
if hdgcd in: ('250' 'E11' 'E10') then do;
	DM=1; count=count+1;
	end;
if last.hraEncWID then output;
retain DM count;
run;

/*sorting the rib dataset by encounter ID. The spine dataset is already sorted*/
proc sort data=qz5.diabetes nodupkey;
by hraEncWID;
run;


/*linking both datasets*/
data qz5.final;
merge qz5.spine (in=a) qz5.diabetes (in=b);
by hraEncWID;
if a and b;
if count=. then count=0;
run;

/*commanding SAS to calculate the percentage of admissions with a diagnosis of diabetes for admissions in 2003 and 2004, and
generate a frequency table of diabetes diagnoses*/

proc freq data=qz5.final;
tables DM count; run;

/*table of diabetes diagnosis and diabetes frequency
DM		Frequency		Percent		Cumulative frequency	Cumulative percent
0		1898			95.81		1898					95.81
1		83				4.19		1981					100.00

Count	Frequency		Percent		Cumulative frequency	Cumulative percent
0		1898			95.81		1898					95.81
1		83				4.19		1981					100.00
*/

/* Findings: 83/1981 (4.19%) of all encounters happening between January 1st of 2013 and December 31st of 2014
had a diagnosis of diabetes. No encounters had more than one diagnosis of diabetes*/

/*End of quiz*/
