drop table Raabta_Real_Sales

----Upload File------

select  * from Raabta_Real_Sales 


--######################################
--alter table Raabta_Real_Sales drop column Sub
alter table Raabta_Real_Sales add Sub varchar (12)
alter table Raabta_Real_Sales add Real_Date Date
alter table Raabta_Real_Sales add Tariff varchar (35)
alter table Raabta_Real_Sales add OnDate Date
alter table Raabta_Real_Sales add CAM varchar (60)
alter table Raabta_Real_Sales add Acc varchar (30)
alter table Raabta_Real_Sales add Cust_ID varchar (30)
alter table Raabta_Real_Sales add Channel varchar (30)
alter table Raabta_Real_Sales add Region varchar (40)

update Raabta_Real_Sales set Sub = '0'+right(msisdn,10)

update Raabta_Real_Sales set Real_Date = cast([Added Date] as Date)

Select * from Raabta_Real_Sales

select distinct [Added Date],Real_Date from Raabta_Real_Sales order by 2 desc

update Raabta_Real_Sales
set Tariff = b.Pack
	,OnDate = cast(b.ondate as date)
	,CompanyName = b.Name
	,Acc = b.Acc
	,Cust_Id = b.customer_ref
from Raabta_Real_Sales a,bsdmain b
where a.sub = b.Sub

Select * from Raabta_Real_Sales

select distinct [KAM Name],[Dealer Code],count(*) from Raabta_Real_Sales 
group by [KAM Name],[Dealer Code]
order by 2

select distinct [KAM Name], count(*) from Raabta_Real_Sales where [Dealer Code] = '\N'
group by [KAM Name]

update Raabta_Real_Sales 
set [Dealer Code] = b.DealerCode
from Raabta_Real_Sales a,bsdmain b
where a.sub = b.sub
and a.[Dealer Code] = '\N' and b.ondate >= '2022-01-01'

Select Distinct [Dealer Code] from Raabta_Real_Sales 

Select Distinct * from Raabta_Real_Sales where [Dealer Code] is NULL

--Select * from bsdmain where sub in (Select sub from Raabta_Real_Sales where [Dealer Code] in ('\N',''))

Select Distinct [KAM NAME] from Raabta_Real_Sales where CAM is null



Update Raabta_Real_Sales
Set [Dealer Code] = '4758'
where [KAM NAME] = 'Azhar Farooq'
and
[Dealer Code] in ('\N','')

--Select * from ST where [EMP NAME] like '%uzair%khalid%'

update Raabta_Real_Sales 
--set DC = b.DC
set [Dealer Code] = b.DC
from Raabta_Real_Sales a,Postpaid_Activation_Log b
where a.sub = b.sub
--and a.DC = '\N' and b.Active_Date >= '2020-01-01'
and a.[Dealer Code] = '\N' and b.Active_Date >= '2021-09-01'

update Raabta_Real_Sales
--set DC = b.DC
set [Dealer Code] = b.DC
from Raabta_Real_Sales a, B2BCER b
where a.Sub =b.sub
and a.[Dealer Code] = '\N'
and SDate >= '2021-09-01'
and CRDate >= '2021-09-01'



update Raabta_Real_Sales
set CAM = b.[Emp Name]
	,Channel = b.Channel
	,Region = b.Region
from Raabta_Real_Sales a, ST b
--where a.DC = b.[Jazz Dealer ID]
where a.[Dealer Code] = b.[JazzID]


Update Raabta_Real_Sales
Set [Dealer Code] = b.Dealercode
from Raabta_Real_Sales a, bsdmain b
where a.Sub = b.Sub
and a.[Dealer Code] = '/N'

Select * from Raabta_Real_Sales where CAM is null

Select distinct Channel from Raabta_Real_Sales

Select distinct Region from Raabta_Real_Sales

--############### Data Insertion #############################

'Change the Real Date to Last Date of the month'

set ansi_warnings off

insert into Real_Sales_Log_Final(Sub,Company_Name,Customer_Ref,Account_Number, Real_Date , Activation_Date,	Tariff,	Customer_Type,	Dealer_Code,	Activation_type, Remarks, Channel,	CAM, Region,i_Date,Sources)
--	select Sub,Name,Cust_ID,Acc,'2020-08-31',OnDate,Tariff,'CORPORATE' Cust_Type,DC,'FRESHSALE'Act_Type,null Remarks,Channel ,CAM,Region,cast(getdate() as Date)i_Date,'Raabta Real' Sources
	select Sub,CompanyName,Cust_ID,Acc,'2022-05-31',OnDate,Tariff,'CORPORATE' Cust_Type,[Dealer Code],'FRESHSALE'Act_Type,null Remarks,Channel ,CAM,Region,cast(getdate() as Date)i_Date,'Raabta Real'Sources
from Raabta_Real_Sales
where CAM is not null
and sub not in (select sub from Real_Sales_Log_Final where Real_Date >= '2021-06-01')
and OnDate >= '2022-01-01'
and Tariff like 'Tracker Service'

--######################### END ###############################
--#############################################################

select top 3 * from Raabta_Real_Sales

select year(real_date),month(Real_date),count(*) from Real_Sales_Log_Final
WHERE Year(Real_date) >= '2022'
GROUP BY year(real_date),month(Real_date)

