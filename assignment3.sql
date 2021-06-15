--Hand on practice 9-9 
--Tracking Pledge Payment activity each time a pledge payment is added, changed, or removed.

drop table dd_paytrack;
drop sequence dd_ptrack_seq;
drop trigger pledge_pay_trigger;

--1) create a table named DD_PAYTRACK to hold this information. 
create table dd_paytrack(
idtrack number primary key,
user_name varchar2(30),
current_date date,
action_taken varchar2(30),
idpay number(6,0)
);

--2) create a new sequence named DD_PTRACK_SEQ for the primary key column. 
create sequence dd_ptrack_seq;

--3) create a single trigger for recording the requested information to track pledge payment activity.
create or replace trigger pledge_pay_trigger
after
insert or
update or
delete
on dd_payment
for each row

declare
this_action dd_paytrack.action_taken%type;
this_idpay dd_paytrack.idpay%type;

begin
this_idpay := :new.idpay;

if inserting then
    this_action := 'Insert';

elsif updating then
    this_action := 'Update';

elsif deleting then
    this_idpay := :old.idpay;
    this_action := 'Delete';

else
    dbms_output.put_line('The code does not exsist.');

end if;

insert into dd_paytrack (idtrack,user_name,current_date,action_taken,idpay)
values(dd_ptrack_seq.nextval,user,to_char(sysdate,'DD-MON-YY'),this_action,this_idpay);

end pledge_pay_trigger;
/

--4) test the trigger
insert into dd_payment(idpay, idpledge, payamt, paydate, paymethod)
values (9999, 105, 250, sysdate, 'CC');
commit;

update dd_payment set payamt = 2000 where idpay = 9999;
commit;

delete from dd_payment where idpay = 9999;
commit;

select * from dd_paytrack;




--Hand on practice 9-10
--Identifying if it's the first pledges the DD_PLEDGE table contains the FIRSTPLEDGE column that indicates whether a pledge is the donor’s first pledge. 

drop trigger first_or_not_trigger;

--1) create a trigger that adds the corresponding data to the FIRSTPLEDGE column when a new pledge is added
create or replace trigger first_or_not_trigger 
before 
insert 
on dd_pledge
for each row

declare 
    counter number:=0;

begin
     if :new.firstpledge is null
     then
            select count(idproj) into counter from dd_pledge where idproj=:new.idproj;
                  if (counter = 0) then
                         :new.firstpledge:='Y';
                  else
                         :new.firstpledge:='N';
                  end if;
     end if;
end first_or_not_trigger;
/


--2) test the trigger.

-- case:  idproj=500  is 'NOT' the first pledge 
insert into dd_pledge(idpledge, iddonor, pledgedate, pledgeamt,idproj, idstatus,writeoff,paymonths,campaign)
values (113,309,sysdate,2000,500,10,null,12,738);
commit;

-- case:  idproj=502  is the first pledge 
insert into dd_pledge(idpledge, iddonor, pledgedate, pledgeamt,idproj, idstatus,writeoff,paymonths,campaign)
values (114,309,sysdate,2000,502,10,null,12,738);
commit;

select * from dd_pledge where (idpledge=113 or idpledge=114);
