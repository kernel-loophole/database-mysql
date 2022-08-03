----------------################ Postpaid Activations ################----------------

Drop table g

Select acc,sub,name,cast(ondate as date) Active_Date, dealercode DC, Pack, 'Bsdmain' Sources, cast(getdate() as date) i_date ,Channel,CAM, Region
into g
from bsdmain
where Year(ondate) = '2022' and Month(ondate) = '05'

---- Duplication Removal ----

Drop table h

Select distinct * into h from g

Select * from h

---- Insertion into Postpaid Log ----

Set ANSI_Warnings Off

Insert into Postpaid_Activation_Log (Acc,Sub,Name,Active_Date,DC,Pack,Sources,i_Date,Channel,CAM,Region)
Select * from h
where sub not in (select sub from Postpaid_Activation_Log where month(Active_Date) in ('12','01','02','03','04','05')
and year(Active_Date) in ('2021','2022'))
order by Active_Date

Select Year(Active_date) as Year,Datename(month,Active_Date) as Month_Name, count(*)
from Postpaid_Activation_Log
where Year(Active_date) in ('2021','2022')
group by Year(Active_date),Datename(month,Active_Date)
order by Year(Active_date),Datename(month,Active_Date)

---- Duplication Check ----

Select sub, count(*)
from Postpaid_Activation_Log
where Active_Date >= '2021-11-01'
group by sub having count(*) > 1


------------------------######################## END ########################------------------------
