----------------################ Final GSM Data ################----------------

Select count(*) from RealSalesMSISDNLevelJazz

---- Duplication Removal ----

Drop table Real_Duplicate

Select * into Real_Duplicate
from RealSalesMSISDNLevelJazz
where MSISDN in (
select msisdn from RealSalesMSISDNLevelJazz group by msisdn having count(*) > 1)

Delete from RealSalesMSISDNLevelJazz where msisdn in (select msisdn from Real_Duplicate)

Insert into [RealSalesMSISDNLevelJazz](MSISDN)
select distinct msisdn from Real_Duplicate

update [RealSalesMSISDNLevelJazz]
set COMPANY_NAME	= b.COMPANY_NAME,
	CUSTOMER_REF	= b.CUSTOMER_REF,
	ACCOUNT_NUMBER	= b.ACCOUNT_NUMBER,
	REALDATE		= b.REALDATE,
	ActDate	= b.ActDate,
	TARIFF			= b.TARIFF,
	Customer_Type	= b.Customer_Type,
	Dealer_Code		= b.Dealer_Code,
	ACTIVATION_TYPE	= b.ACTIVATION_TYPE
from [RealSalesMSISDNLevelJazz] a,(
									select c.*
									from Real_Duplicate c,
									(select msisdn,MAX(realDate)MaxRd
									from Real_Duplicate
									group by MSISDN )d
									where c.msisdn = d.msisdn
									and c.realdate =d.MaxRd )b
where a.msisdn = b.msisdn 
and a.account_number is null

---- Dealer Codes ----

Select DISTINCT Dealer_code from RealSalesMSISDNLevelJazz order by 1

Select MSISDN, Dealer_Code from RealSalesMSISDNLevelJazz where len(Dealer_Code) > '5'
Select MSISDN, Dealer_Code from RealSalesMSISDNLevelJazz where Dealer_Code = ''
Select MSISDN, Dealer_Code from RealSalesMSISDNLevelJazz where Dealer_Code = '0'


Update RealSalesMSISDNLevelJazz
SET Dealer_Code = b.DealerCode
from RealSalesMSISDNLevelJazz a, (Select sub,dealercode from bsdmain) b
where a.MSISDN = b.sub
and a.MSISDN in (Select MSISDN from RealSalesMSISDNLevelJazz where Dealer_Code = '')

Update RealSalesMSISDNLevelJazz
SET Dealer_Code = b.DealerCode
from RealSalesMSISDNLevelJazz a, (Select sub,dealercode from bsdmain) b
where a.MSISDN = b.sub
and a.MSISDN in (Select MSISDN from RealSalesMSISDNLevelJazz where Dealer_Code = '0')


Update RealSalesMSISDNLevelJazz
SET Dealer_Code = b.DealerCode
from RealSalesMSISDNLevelJazz a, (Select sub,dealercode from bsdmain) b
where a.MSISDN = b.sub
and a.MSISDN in (Select MSISDN from RealSalesMSISDNLevelJazz where len(Dealer_Code) > '5')


Delete from RealSalesMSISDNLevelJazz where len(Dealer_Code) > '5'


---- Final Tagging ----

drop table JazzReal_Temp

select	'0'+right(MSISDN,10)Sub,Company_Name,Customer_Ref,Account_Number,
	realdate Real_Date, actdate Activation_Date,Tariff,Customer_Type, Dealer_Code,Activation_type
into JazzReal_Temp		
from [RealSalesMSISDNLevelJazz]
order by Real_Date 

Select * from JazzReal_Temp

alter table JazzReal_Temp add [Remarks] varchar(30),Channel varchar (20), CAM varchar (60),Region varchar(20) , FRC_MBU varchar (15), FRC_New_MBU varchar (30),FRC_New_Region varchar(20);

update JazzReal_Temp
set Remarks = '1 Years Real Check'
where sub in ( select sub from JazzReal_Temp
			where sub in ( select sub  from Real_Sales_Log_Final 
					where DATEDIFF(Day, real_date,getdate())< '365'  
						) 
			and activation_type like '%FRESH%SALE%')

update JazzReal_Temp
set Remarks = null
where Remarks = '1 Years Real Check'
and sub not in (select sub from club.dbo.bsdmain_Oct21)

update JazzReal_Temp
set Channel = b.Channel,
	CAM = b.[Emp Name],
	Region=b.REGION 
from JazzReal_Temp a,ST b
where a.Dealer_Code = b.JazzID

Select * from JazzReal_Temp where channel is null

Select * from ST where [JAZZ Dealer ID] in (Select DISTINCT Dealer_Code from JazzReal_Temp
where Channel is null)

update JazzReal_Temp
set Channel = b.Channel,
	CAM = b.[Emp Name]
from JazzReal_Temp a,ST b
where right(a.Dealer_Code,3) = b.JazzID
and left(a.Dealer_Code,1) = '0'
and a.Channel is null

update JazzReal_Temp
set Channel = b.Channel,
	CAM = b.[Emp Name]
from JazzReal_Temp a,ST b
where a.Dealer_Code = right(b.JazzID,3)
and left(b.JazzID,1) = '0'
and a.Channel is null

update JazzReal_Temp
set Channel = b.Channel,
	CAM = b.[CAM]
from JazzReal_Temp a,bsdmain b
where a.sub in (select sub from JazzReal_Temp where channel is null)

update JazzReal_Temp
set FRC_MBU = b.MBU,
	FRC_New_MBU = b.New_MBU,
	FRC_New_Region = b.New_Region
from JazzReal_Temp a,FRC_ST b
where a.Dealer_Code = b.SaleID

update JazzReal_Temp 
set Channel = 'ES',
	Region = 'FRC'
where FRC_MBU is not null

update JazzReal_Temp
set Channel = b.Channel ,
	Region = b.region
from JazzReal_Temp a,bsdmain b
where a.sub = b.sub
and a.channel is null

update JazzReal_Temp
set Channel = b.Channel ,
	Region = b.Region
from JazzReal_Temp a,BSDMain b
where a.COMPANY_NAME  = b.nlsname
and a.channel is null

update JazzReal_Temp 
set Channel = 'ES',
	Region = 'FRC'
where Channel is Null 
and Tariff like 'JB%'

update JazzReal_Temp set Remarks = '/Dealer Pack' where tariff = 'Dealer'--0
update JazzReal_Temp set Remarks = '/ES Standard Pack' where tariff = 'ES Standard' --71
update JazzReal_Temp set Remarks = '/Official Pack' where tariff = 'Official' --38
update JazzReal_Temp set Remarks = '/Official Dealer Pack' where tariff = 'Official Dealer' --4
update JazzReal_Temp set Remarks = '/Official for Testing Pack' where tariff = 'Official for Testing' --18
update JazzReal_Temp set Remarks = '/Official Special' where tariff = 'Official Special'--0
update JazzReal_Temp set Remarks = '/Employee' where tariff = 'Employee'
update JazzReal_Temp set Region = 'Central 1' where Region like '%Central%1%'--694
update JazzReal_Temp set Region = 'Central 2' where Region like '%Central%2%'--396
update JazzReal_Temp set Region = 'Central 3' where Region like '%Central%3%'--244
update JazzReal_Temp set Region = 'Central 4' where Region like '%Central%4%' --111
update JazzReal_Temp set Region = null where Region like 'null' ----0

Select * from JazzReal_Temp where Activation_Type not like 're%org'

---- Insertion into Real Sales Log ----

Set ansi_warnings off

insert into Real_Sales_Log_Final( sub,Company_Name ,Customer_Ref ,Account_Number , Real_Date ,Activation_Date ,Tariff ,Customer_Type ,Dealer_Code ,Activation_type ,Remarks,Channel,CAM,Region,FRC_MBU ,FRC_New_MBU ,FRC_New_Region ,i_Date ,Sources)
select sub, Company_Name ,Customer_Ref ,Account_Number ,cast(Real_Date as date) Real_Date, cast(Activation_Date as date) Activation_Date ,Tariff ,Customer_Type ,Dealer_Code ,Activation_type ,Remarks,Channel,CAM,Region,FRC_MBU ,FRC_New_MBU ,FRC_New_Region ,cast(getdate() as date)i_Date ,'Talha Process'Sources
from JazzReal_Temp
where Remarks is null
and Sub not in (select sub from Real_Sales_Log_Final where month(Real_Date) in (month(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()-12) - 3, 0)),month(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()-12) - 2, 0)),month(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()-12) - 1, 0)),month(getdate()-12))and 
year(Real_Date) in (year(getdate()-12),year(getdate()-12)-1)) 
and Activation_Type not like 're%org'
order by Real_Date

insert into Real_Sales_Log_Final ( sub, Company_Name ,Customer_Ref ,Account_Number ,Real_Date ,Activation_Date ,Tariff ,Customer_Type ,Dealer_Code ,Activation_type ,Remarks,Channel,CAM,Region,FRC_MBU ,FRC_New_MBU ,FRC_New_Region ,i_Date ,Sources)
select sub,Company_Name ,Customer_Ref ,Account_Number ,Real_Date , Activation_Date ,Tariff ,Customer_Type ,Dealer_Code ,Activation_type ,Remarks,Channel,CAM,Region,FRC_MBU ,FRC_New_MBU ,FRC_New_Region ,cast(getdate() as date)i_Date ,'Talha Process'Sources
from JazzReal_Temp
where Remarks is not null
and Sub not in (select sub from Real_Sales_Log_Final where month(Real_Date) in (month(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()-12) - 3, 0)),month(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()-12) - 2, 0)),month(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()-12) - 1, 0)),month(getdate()-12))and year(Real_Date) in (year(getdate()-12),(year(getdate()-12)-1))--Month Change and add
				and Remarks is not null)
and Activation_Type not like 're%org'
order by Real_Date 

update Real_Sales_Log_Final
set Region = channel
where Channel in ('ADC')and  Region not in ('ADC')
and Remarks is null
and month(Real_Date)=  month(GETDATE()-12) and year(Real_Date)= year(GETDATE()-12) --37

update real_sales_log_final
set remarks ='1 Year Activation Check'
where  Remarks is null and year(activation_date) <= '2021'
and month(Real_Date)= month(GETDATE()-12) and year(Real_Date)= (year(GETDATE()-12)-1)

SELECT DISTINCT Activation_Date FROM real_sales_log_final 
WHERE remarks = '1 Year Activation Check'
ORDER BY Activation_Date DESC


-------------------------############################## END ##############################-------------------------
