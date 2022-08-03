
Select Activation_type, count(*) from MSTR_Jazz_Real_uploading group by Activation_type

update MSTR_Jazz_Real_uploading set MSISDN = '0'+right(MSISDN,10)

Select distinct tariff from MSTR_Jazz_Real_uploading

Delete from MSTR_Jazz_Real_uploading
where tariff in
('APN_JazzB',
'International',
'Employee',
'Official',
'Official Special',
'Official For Testing',
'Official Special',
'Ex PMCL FnF',
'Official Dealer',
'Brands Alert Solution',
'Business Line Advance',
'Business line Basic',
'Business Line Standard',
'Campaign Management Solution',
'Cell Track',
'Ecommerce- Basic',
'Ecommerce-Advanced',
'Ecommerce-Premium',
'Ecommerce-Standard',
'Field Form Gold',
'Field Form Platinum',
'Field Form Silver',
'Group Data Ace',
'Group Data Basic',
'Group Data Max',
'Group Data Plus',
'Group Data Standard',
'Knox - Configure',
'Knox - Manage',
'M2M Tracker billing',
'O365 - Apps for Business',
'O365 - Business Basic',
'O365 - Business Standard',
'O365 dynamic - subscription Base',
'Smart Track',
'Jazz Cloud services')


Select * from MSTR_Jazz_Real_uploading where tariff = ''
Select * from MSTR_Jazz_Real_uploading where tariff is null


Select sub,pack,cast(ondate as date) from bsdmain where sub in
(Select MSISDN from MSTR_Jazz_Real_uploading where tariff = '')
and ondate >= '2022-01-01'

Update 
MSTR_Jazz_Real_uploading
SET tariff = b.pack
from
MSTR_Jazz_Real_uploading a, bsdmain b
where a.MSISDN = b.Sub
and a.tariff = ''

Delete from MSTR_Jazz_Real_uploading
where tariff = ''


select distinct Real_Date from MSTR_Jazz_Real_uploading order by 1

--############## Date Format #################

alter Table MSTR_Jazz_Real_uploading add RealDate date ,ActDate date

--############## Activation Date ######################

update MSTR_Jazz_Real_uploading set ActDate =  Right([Activation_Date],4)+'-0'		-- Year
									+ Right(left([Activation_Date],3),1)+'-0'--Month
									+ Left([Activation_Date],1)				-- Day
where [Activation_Date] like '_/_/____' and ActDate is null

update MSTR_Jazz_Real_uploading set ActDate =  Right([Activation_Date],4)+'-'		-- Year
									+ Right(left([Activation_Date],5),2)+'-'--Month
									+ Left([Activation_Date],2)				-- Day
where [Activation_Date] like '__/__/____' and ActDate is null

update MSTR_Jazz_Real_uploading set ActDate =  Right([Activation_Date],4)+'-'		-- Year
									+ Right(left([Activation_Date],4),1)+'-'--Month
									+ Left([Activation_Date],2)				-- Day
where [Activation_Date] like '__/_/____' and ActDate is null

update MSTR_Jazz_Real_uploading set ActDate =  Right([Activation_Date],4)+'-'		-- Year
									+ Right(left([Activation_Date],4),2)+'-'--Month
									+ Left([Activation_Date],1)				-- Day
where [Activation_Date] like '_/__/____' and ActDate is null


SELECT TOP 3 * FROM MSTR_Jazz_Real_uploading

---#####Rows from the following quries should be same####-----

select distinct Activation_Date			from MSTR_Jazz_Real_uploading 
select distinct Activation_Date,ActDate from MSTR_Jazz_Real_uploading order by 2 desc


Select Year(Actdate) Year,Month(actdate) Month, count(*) Real_Sales
from MSTR_Jazz_Real_uploading
Group by Year(Actdate), Month(Actdate)
Order by Year(Actdate), Month(Actdate)

Select sub, cast(ondate as date) from bsdmain where sub in
(Select MSISDN from MSTR_Jazz_Real_uploading WHERE ActDate = '1990-01-01')

Update MSTR_Jazz_Real_uploading
Set
ActDate = b.date
from
MSTR_Jazz_Real_uploading a, (select sub, cast(ondate as date) date from bsdmain) b
where a.MSISDN = b.sub
and
a.ActDate = '1990-01-01'

DELETE FROM MSTR_Jazz_Real_uploading WHERE ActDate IS NULL

--########## Real Date Format Issue ################


update MSTR_Jazz_Real_uploading set RealDate =  Right([Real_Date],4)+'-0'		-- Year
									+ Right(left([Real_Date],3),1)+'-0'--Month
									+ Left([Real_Date],1)				-- Day
where [Real_Date] like '_/_/____' and RealDate is null

update MSTR_Jazz_Real_uploading set RealDate =  Right([Real_Date],4)+'-'		-- Year
									+ Right(left([Real_Date],5),2)+'-'--Month
									+ Left([Real_Date],2)				-- Day
where [Real_Date] like '__/__/____' and RealDate is null

update MSTR_Jazz_Real_uploading set RealDate =  Right([Real_Date],4)+'-'		-- Year
									+ Right(left([Real_Date],4),1)+'-'--Month
									+ Left([Real_Date],2)				-- Day
where [Real_Date] like '__/_/____' and RealDate is null

update MSTR_Jazz_Real_uploading set RealDate =  Right([Real_Date],4)+'-'		-- Year
									+ Right(left([Real_Date],4),2)+'-'--Month
									+ Left([Real_Date],1)				-- Day
where [Real_Date] like '_/__/____' and RealDate is null

SELECT TOP 3 * FROM MSTR_Jazz_Real_uploading

select distinct Real_Date			from MSTR_Jazz_Real_uploading 
select distinct Real_Date,RealDate from MSTR_Jazz_Real_uploading order by 2 desc

--########## Jazz Final Data insertion ##################

select top 3 * from [RealSalesMSISDNLevelJazz]
select top 3 * from MSTR_Jazz_Real_uploading

delete from [RealSalesMSISDNLevelJazz]

Set ansi_warnings off

insert into [RealSalesMSISDNLevelJazz]
select MSISDN,COMPANY_NAME,CUSTOMER_REF,ACCOUNT_NUMBER,RealDate,ActDate,Tariff,Customer_Type,Dealer_Code,Activation_Type
from MSTR_Jazz_Real_uploading

SELECT TOP 3 * FROM [RealSalesMSISDNLevelJazz]


-------------------------------############################ End ############################-------------------------------

