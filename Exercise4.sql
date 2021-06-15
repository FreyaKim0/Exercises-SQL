-- Ecommerce Deliverables
drop  index discount_index;
drop FUNCTION check_shop_number;
drop PROCEDURE free_shipping_pro;
drop procedure check_vip_pro;
drop trigger order_history_trigger;
drop trigger buyer_history_trigger;
drop sequence order_history_seq;
drop table buyer_history;
drop table order_history;
drop table order_item;
drop table buyer;
drop table sale_item;
drop table shop;

create table shop (name varchar(20) primary key, shop_id varchar(15) unique not null);
insert into shop values ('Bed Shop','S001');
insert into shop values ('Food Shop','S002');
insert into shop values ('Computer Shop','S003');
insert into shop values ('Printer Shop','S004');
insert into shop values ('Cusometic Shop','S005');
insert into shop values ('Tattoo Shop','S006');
insert into shop values ('Grocvery Shop','S007');
insert into shop values ('Gas Shop','S008');
insert into shop values ('Handcraft Shop','S009');
insert into shop values ('Monitor','S0010');

create table sale_item (item_name varchar(20) primary key, shop_id varchar(15) not null , cost int not null check (cost>0));
alter table sale_item add constraint fk_shop_id foreign key (shop_id) references shop(shop_id);
insert into sale_item values ('King Bed','S001',1000);
insert into sale_item values ('Vege Ramen','S002',3000);
insert into sale_item values ('Mac 11 laptap','S003',4000);
insert into sale_item values ('HP 2700 Printer','S004',5000);
insert into sale_item values ('KOES lipstick','S005',6000);
insert into sale_item values ('Tattoo Deisgn','S006',7000);
insert into sale_item values ('Chips','S007',6000);
insert into sale_item values ('95 Gas','S008',9000);
insert into sale_item values ('Gift Card','S009',2000);
insert into sale_item values ('BenQ 4934','S0010',10000);

create table buyer  (buyer_id varchar(20) primary key, name varchar(15) not null);
create table order_item (order_id varchar(20) primary key,buyer_id varchar(20), item_name varchar(20) unique,quentity int not null check(quentity>0));
alter table  order_item add constraint fk_buyer_id foreign key (buyer_id) references buyer(buyer_id);
alter table  order_item add constraint fk_item_name foreign key (item_name) references sale_item(item_name);
create table order_history (order_id int primary key, buyer_id varchar(20) unique,order_item varchar(20),order_quentity int, action varchar(20));
create table buyer_history (buyer_id varchar(20),name varchar(20), action varchar(20));

-- Sequences: generate order_history id
create sequence  order_history_seq;

-- Index: for search price ragne of product
create index price_index on sale_item (upper(cost));

-- Trigger1: trace all buyer's action
create or replace trigger buyer_history_trigger
after
insert or
update
on buyer
for each row

declare
this_buyer_id  varchar(20);
this_name  varchar(20);
this_action varchar(20);

begin
this_buyer_id := :new.buyer_id;
this_name := :new.name;

if inserting then
    this_action := 'Create new';

elsif updating then
    this_action := 'Update old';

else
    dbms_output.put_line('Error: The code does not exsist....!');

end if;

insert into buyer_history values(this_buyer_id,this_name,this_action);

end  buyer_history_trigger;
/

-- Test trigger1
insert into buyer values ('b001','Amy');
insert into buyer values ('b002','Bob');
insert into buyer values ('b003','CeCil');
insert into buyer values ('b004','Dee');
insert into buyer values ('b005','Emily');
insert into buyer values ('b006','Frank');
insert into buyer values ('b007','Gill');
insert into buyer values ('b008','Hawk');
insert into buyer values ('b009','Iesabeth');
insert into buyer values ('b0010','Jessica');

-- Trigger2: trace all order records
create or replace trigger order_history_trigger
after
insert or
update
on order_item
for each row

declare
this_action varchar(20);
this_buyer_id  varchar(20);
this_item_name  varchar(20);
this_order_quentity  int;

begin
this_buyer_id := :new.buyer_id;
this_item_name := :new.item_name;
this_order_quentity := :new.quentity;

if inserting then
    this_action := 'Create new';

elsif updating then
    this_action := 'Update old';

else
    dbms_output.put_line('Error: The code does not exsist....!');

end if;

insert into order_history values(order_history_seq.nextval,this_buyer_id,this_item_name,this_order_quentity,this_action);

end  order_history_trigger;
/

-- Test trigger2
Insert Into order_item Values('o001','b001','King Bed',3);commit;
Insert Into order_item Values('o002','b002','Vege Ramen',3);commit;
Insert Into order_item Values('o003','b003','Mac 11 laptap',3);commit;
Insert Into order_item Values('o004','b004','HP 2700 Printer',3);commit;
Insert Into order_item Values('o005','b005','KOES lipstick',3);commit;
Insert Into order_item Values('o006','b006','Tattoo Deisgn',3);commit;
Insert Into order_item Values('o007','b007','Chips',3);commit;
Insert Into order_item Values('o008','b008','95 Gas',3);commit;
Insert Into order_item Values('o009','b009','Gift Card',3);commit;
Insert Into order_item Values('o0010','b0010','BenQ 4934',3);commit;

-- Procedure 1: determind if a productto have free shipping ( is over then $3000 )
create or replace procedure free_shipping_pro(i_item in varchar ,ship out boolean)  
authid current_user as 
item_price int;
begin
 select cost into item_price from sale_item where item_name=i_item;
 if item_price < 3000 then
    ship := true;
  else
    ship := false;
  end if;
end  free_shipping_pro;
/

-- Test Procedure 1
set serveroutput on;
declare
result boolean;
begin
free_shipping_pro('King Bed', result);
dbms_output.put('King Bed');
if result then
 dbms_output.put('has');
else
 dbms_output.put('doesnt have');
end if;
 dbms_output.put_line(' free shipping.');
end;
/

-- Procedure 2:determind if a buyer is vip ( had made more than 5 orders )
create or replace procedure check_vip_pro(check_id in varchar ,vip out boolean)  
authid current_user as 
purchase_time int;
begin
 select count(*) into purchase_time from order_history where buyer_id=check_id;
 if purchase_time < 6 then
    vip := false;
  else
    vip := true;
  end if;
end  check_vip_pro;
/

-- Test Procedure 2
set serveroutput on;
declare
result boolean;
begin
check_vip_pro('b005', result);
dbms_output.put('This buyer ');
if result then
 dbms_output.put('is');
else
 dbms_output.put('is not');
end if;
 dbms_output.put_line(' VIP');
end;
/

-- Function: show how many shops have registered in the website
CREATE OR REPLACE FUNCTION check_shop_number RETURN int
authid current_user as 
result_shop int;
BEGIN
  select count(*) into result_shop from shop;
  RETURN result_shop;
END check_shop_number;
/

-- Test Function
DECLARE
  result NUMBER;
BEGIN
  result := check_shop_number();
  DBMS_OUTPUT.PUT_LINE(result); --print "1"
END;