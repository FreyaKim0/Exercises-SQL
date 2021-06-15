--List the name of each officer who has reported less than the maximum number of crimes officers have reported.
select o.first ,o.last from officers o,
(select officer_id, count(*) as num from crime_officers group by officer_id)c
where o.officer_id=c.officer_id
and c.num<(select max(num) from (select officer_id, count(*) as num from crime_officers group by officer_id));

--List the names of all criminals who have committed more than average number of crimes and aren’t listed as violent offenders.
select c.first,c.last from criminals c, 
(select criminal_id, count(*) as num from crimes group by criminal_id)b,
(select violations,criminal_id from sentences)s
where c.criminal_id = b.criminal_id and s.criminal_id = b.criminal_id
and (b.num>(select avg(num)from (select criminal_id, count(*) as num from crimes group by criminal_id))
and s.violations<1);

--List appeal information for each appeal that has a less than the average number of days between the filing and hearing dates.
select a.appeal_id,a.filing_date,a.hearing_date,a.status from appeals a,(select appeal_id,(to_date (hearing_date,'dd-MM-yyyy') - to_date(filing_date,'dd-MM-yyyy')) as average_days from appeals)b
where a.appeal_id = b.appeal_id
and b.average_days<(select avg(to_date (hearing_date,'dd-MM-yyyy') - to_date(filing_date,'dd-MM-yyyy'))  from appeals);

--List the names of probation officers who have had a greater than average number of criminals assigned.
select* from(select first,last, sum(assign_num) as total_assign from (select p.first,p.last,g.prob_id,k.assign_num from prob_officers p,
(select criminal_id,count(distinct criminal_id) as assign_num from (select criminal_id,prob_id from sentences) group by criminal_id)k,
(select distinct criminal_id,prob_id from sentences where prob_id is not null)g
where p.prob_id=g.prob_id and g.criminal_id = k.criminal_id) group by first,last)
where total_assign>(select avg(total_assign) from (select criminal_id,count(distinct criminal_id) as total_assign from (select criminal_id,prob_id from sentences) group by criminal_id));

--List each crime that has had the least number of appeals recorded.
select * from (select crime_id,count(appeal_numbers) as total_app_num from
(select x.crime_id,y.appeal_numbers from crimes x left join  
(select a.crime_id,b.appeal_numbers from appeals a,(select appeal_id , count(appeal_id) as appeal_numbers from appeals group by appeal_id)b 
where a.appeal_id=b.appeal_id)y on x.crime_id = y.crime_id) group by crime_id)
where total_app_num = (select min(total_app_num) from 
(select crime_id,count(appeal_numbers) as total_app_num from 
(select x.crime_id,y.appeal_numbers from crimes x left join 
(select a.crime_id,b.appeal_numbers from appeals a,(select appeal_id , count(appeal_id) as appeal_numbers from appeals group by appeal_id)b 
where a.appeal_id=b.appeal_id)y on x.crime_id = y.crime_id) group by crime_id));