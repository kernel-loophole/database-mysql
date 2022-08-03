
--##### Duplication Check ######

DROP TABLE ##tempp

select sub into ##tempp from real_sales_log_final where Real_Date >= '2021-06-01' 
and Remarks is null group by Sub having count(*) > 1

drop table realsales_log_temp 

select * 
into realsales_log_temp 
from real_sales_log_final 
where Remarks is null and sub in (select sub from ##tempp) and Real_Date >= '2021-06-01' order by 1

select sub,count(*) from realsales_log_temp Group by sub order by 2 desc

delete from Real_Sales_Log_Final 
where Remarks is null and sub in (select sub from ##tempp) and Real_Date >= '2021-06-01'

--select * into real_sales_log_final_backup
--from real_sales_log_final

drop table realsales_log_Corrected
select top 0* into realsales_log_Corrected from  Real_Sales_Log_Final

--######## Duplication Removal Based on Minimum ###########################
insert into realsales_log_Corrected (sub,Real_Date,Sources)
select Sub,min(Real_Date)Min_Real_Date ,'Dupli Corrected'
from realsales_log_temp
Group by Sub


update RealSales_Log_Corrected
set Company_Name = b.Company_Name
	,Customer_Ref = b.Customer_Ref
	,Account_Number = b.Account_Number
	,Activation_Date =b.Activation_Date
	,Tariff			=b.Tariff
	,Customer_Type	=b.Customer_Type
	,Dealer_Code	=b.Dealer_Code
	,Activation_type=b.Activation_type
	,Remarks	=b.Remarks
	,Channel	=b.Channel
	,CAM		=b.CAM
	,Region		=b.Region
	,FRC_MBU	=b.FRC_MBU
	,FRC_New_MBU	=b.FRC_New_MBU
	,FRC_New_Region	=b.FRC_New_Region
	,i_Date  = b.i_Date
	,NTN		=b.NTN
	,Port_Status=b.Port_Status
	,Donor		=b.Donor
	,Recepient	=b.Recepient
from RealSales_Log_Corrected a,realsales_log_temp b
where a.sub = b.sub
and a.Real_Date = b.Real_Date

Select * from realsales_log_Corrected

insert into Real_Sales_Log_Final
select * from realsales_log_Corrected
--###########################################################################
select distinct CAM,Channel,count(*)
from Real_Sales_Log_Final
where real_Date >= '2021-06-01' and region is null and Remarks is null and CAM is not null
Group by CAM,Channel order by 3 

update Real_Sales_Log_Final set Region = 'CENTRAL' Where Region is null and CAM in ('UMAR AKRAM 0301-8420421','KHAWAJA AHSAN 0300-8422262') 
update Real_Sales_Log_Final set Region = 'CENTRAL 1' Where Region is null and CAM in ('AHSAN RABBANI') 
update Real_Sales_Log_Final set Region = 'NORTH' Where Region is null and CAM in ('Saad Karim Khan','Shafaat Ahmad Siddiqui') 
update Real_Sales_Log_Final set Region = 'SOUTH Team B' Where Region is null and CAM in ('Asim Sarwar 0300-8219932') 


select distinct region from Real_Sales_Log_Final where channel = 'B2G' and Real_Date >= '2021-06-01'
select distinct region from Real_Sales_Log_Final where channel in ('ES','Sales') and Real_Date >= '2021-06-01'

select * from Real_Sales_Log_Final where region IS NULL and channel in ('ES','Sales') and Real_Date >= '2021-05-01'
select * from Real_Sales_Log_Final where region IS NULL and channel = 'B2G' and Real_Date >= '2021-04-01'
select * from Real_Sales_Log_Final where region IS NULL and channel in ('CS','AM') and Real_Date >= '2021-04-01'


update Real_Sales_Log_Final set Region = 'CENTRAL 1' where Region = 'CENTRAL1'
update Real_Sales_Log_Final set Region = 'CENTRAL 2' where Region = 'CENTRAL2'
update Real_Sales_Log_Final set Region = 'CENTRAL 3' where Region = 'CENTRAL3'
update Real_Sales_Log_Final set Region = 'CENTRAL 4' where Region = 'CENTRAL4'



--###########################################################################
--###########################################################################
drop table real_sales_log_final_Tempppp

--########## Late Reported ######
select *,'Late Reported'Remarks2
into real_sales_log_final_Tempppp
from real_sales_log_final
where Real_Date >= '2022-01-01' and Real_Date < '2022-05-01' and i_Date >= '2022-06-09' and i_Date < '2022-07-01'
and channel in ('AM','CS','B2G','ES','Sales','ASC','ADC')
and Activation_Type not like '%re%org%'and CAM is not null and Remarks is null

delete from real_sales_log_final_Tempppp

insert into real_sales_log_final_Tempppp
select *,'' Remarks2
from real_sales_log_final
where Real_Date >= '2022-05-01'
and channel in ('AM','CS','B2G','ES','Sales','ASC','ADC')
and Activation_Type not like '%re%org%'and CAM is not null and Remarks is null
and Activation_Date >= '2021-06-01'


--################## AM #####################################
--#### Jazz
select Region
	,sum(case when Tariff like 'Pro%' then 1 else 0 end)[Pro]
	,sum(case when Tariff like 'Biz%' then 1 else 0 end)[Biz]
	,sum(case when Tariff like 'War%' or Tariff like 'Sis%' or Tariff like 'W Postpaid%' then 1 else 0 end)[Warid]
	,sum(case when Tariff like 'GSM Control%' and Tariff not like '%M2M%' then 1 else 0 end)[Control]
	,sum(case when Tariff like '%Track%' or Tariff like '%M2M%'then 1 else 0 end)[Tracker]
	,sum(case when Tariff not like '%Track%'and Tariff not like '%M2M%' and Tariff not like 'Biz%' and Tariff not like 'GSM Control%' and Tariff not like 'Pro%'then 1 else 0 end)[Others]
from real_sales_log_final_Tempppp
where channel in ('AM','CS') and CAM is not null and Remarks is null
--and Real_Date >= '2020-08-01'
Group by Region order by 1

select Sub,Account_Number,Dealer_Code,Tariff,Real_Date,Activation_Date,Company_Name,CAM,Region,Activation_Type,'AM',Remarks2
from real_sales_log_final_Tempppp
where channel in ('AM','CS') and CAM is not null and Remarks is null
--and Real_Date >= '2020-08-01'


--#### Warid

Select Sub,Company_name,Real_date,Activation_date,Dealer_code,Tariff,CAM,Region,'AM'
from real_sales_log_final_Tempppp
where channel in ('AM','CS') and CAM is not null and Remarks is null
and tariff like 'War%' or Tariff like 'Sis%' or Tariff like '%W%'

select Sub,Company_Name,Real_Date,Activation_Date,Sales_Person_ID,Package,CAM,Region,'AM'
from Warid_Real_Sales_Log
where Real_Date >= '2021-10-01'
and Channel in ('CS','W - LA','AM')
and CAM is not null
and Remarks is null

--#### Non-Real

select Sub,Name,Active_Date,Pack,CAM,'AM',Region
from Non_Real_Data
where Active_Date >= '2021-12-01'
and channel in ('AM','CS')
and sub not in (select sub from real_sales_log_final where real_date >= '2021-12-01')
and CAM is not null


--################## B2G #####################

--#### Jazz

select Region
	,sum(case when Tariff like 'Pro%' then 1 else 0 end)[Pro]
	,sum(case when Tariff like 'Biz%' then 1 else 0 end)[Biz]
	,sum(case when Tariff like 'War%' or Tariff like 'Sis%' or Tariff like 'W Postpaid%' then 1 else 0 end)[Warid]
	,sum(case when Tariff like 'GSM Control%' and Tariff not like '%M2M%' then 1 else 0 end)[Control]
	,sum(case when Tariff like '%Track%' or Tariff like '%M2M%'then 1 else 0 end)[Tracker]
	,sum(case when Tariff not like '%Track%'and Tariff not like '%M2M%' and Tariff not like 'Biz%' and Tariff not like 'GSM Control%' and Tariff not like 'Pro%'then 1 else 0 end)[Others]
from real_sales_log_final_Tempppp
where channel in ('B2G') and CAM is not null and Remarks is null
--and Real_Date >= '2020-08-01'
Group by Region order by 1

select Sub,Account_Number,Dealer_Code,Tariff,Real_Date,Activation_Date,Company_Name,CAM,Region,Activation_Type,'B2G',Remarks2
from real_sales_log_final_Tempppp
where channel like 'B2G' and CAM is not null and Remarks is null 
--and Real_Date >= '2020-08-01'


--#### Warid

Select Sub,Company_name,Real_date,Activation_date,Dealer_code,Tariff,CAM,Region,'B2G'
from real_sales_log_final_Tempppp
where channel in ('B2G') and CAM is not null and Remarks is null
and tariff like 'War%' or Tariff like 'Sis%' or Tariff like '%W%'



select Sub,Company_Name,Real_Date,Activation_Date,Sales_Person_ID,Package,CAM,Region,'B2G'
from Warid_Real_Sales_Log
where Real_Date >= '2021-01-01'
and Channel like '%B2G%'
and CAM is not null and Remarks is null

--#### Non-Real

select Sub,Name,Active_Date,Pack,CAM,'B2G',Region
from Non_Real_Data
where Active_Date >= '2021-11-01'
and channel like '%B2G%'
and sub not in (select sub from real_sales_log_final where real_date >= '2021-11-01')
and CAM is not null


--################## Sales #####################

--#### Jazz

select Region
	,sum(case when Tariff like 'Pro%' then 1 else 0 end)[Pro]
	,sum(case when Tariff like 'Biz%' then 1 else 0 end)[Biz]
	,sum(case when Tariff like 'War%' or Tariff like 'Sis%' or Tariff like 'W Postpaid%' then 1 else 0 end)[Warid]
	,sum(case when Tariff like 'GSM Control%' and Tariff not like '%M2M%' then 1 else 0 end)[Control]
	,sum(case when Tariff like '%Track%' or Tariff like '%M2M%'then 1 else 0 end)[Tracker]
	,sum(case when Tariff not like '%Track%'and Tariff not like '%M2M%' and Tariff not like 'Biz%' and Tariff not like 'GSM Control%' and Tariff not like 'Pro%'then 1 else 0 end)[Others]
--	,sum(case when Tariff not like '%Track%' or Tariff not like 'Biz%' or Tariff not like 'Control%' or Tariff not like 'Pro%' or Tariff like 'JB%'then 1 else 0 end)[Others]
from real_sales_log_final_Tempppp
where channel in ('ES','Sales','ASC','ADC')  and CAM is not null and Remarks is null
--and Real_Date >= '2020-08-01'
Group by Region order by 1


select Sub,Account_Number,Dealer_Code,Tariff,Real_Date,Activation_Date,Company_Name,CAM,Region,Activation_Type
	,case when channel = 'ES' then 'Sales' else Channel end Channel
	,FRC_MBU, FRC_New_MBU,	FRC_New_Region,Remarks2
from real_sales_log_final_Tempppp
where channel in ('ES','Sales','ASC','ADC') and CAM is not null and Remarks is null 
--and Real_Date >= '2020-08-01'



--#### Warid
select Sub,Company_Name,Real_Date,Activation_Date,Sales_Person_ID,Package,CAM,Region,'Sales'
from Warid_Real_Sales_Log
where REal_Date >= '2021-10-01'
and Channel in ('ES','W - SME - SOHO','Sales')
and CAM is not null
and Remarks is null

--#### Non-Real

select Sub,Acc,Name,DC,Pack,Active_Date,CAM,Region
	,case when channel = 'ES' then 'Sales' else Channel end Channel
from Non_Real_Data
where Active_Date >= '2021-12-01'
and channel in ('Sales','ES','ASC')
and sub not in (select sub from real_sales_log_final where real_date >= '2021-12-01')
and CAM is not null


