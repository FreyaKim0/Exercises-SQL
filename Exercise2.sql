--A5-10 test
set serveroutput on;
declare
result ddproject%rowtype;
begin
ddproj_sp(101,result);
dbms_output.put_line(result.id||' '||result.name||' '||result.budjet);
end;

--A5-11 test
set serveroutput on;
declare
result boolean;
begin
ddpay_sp(309, result);
dbms_output.put('Donor #309 ');
if result then
 dbms_output.put('has');
else
 dbms_output.put('doesnt have');
end if;
 dbms_output.put_line(' an active pledge.');
end;

--A5-12 test
set serveroutput on;
begin
  ddckpay_sp(20, 104);  -- correct amount
  ddckpay_sp(25, 100);  -- no payment information
  ddckpay_sp(99, 104);  -- exception
exception when others then
  dbms_output.put_line('An error occured.');
end;

--A5-13 test
set serveroutput on;
declare
  amount number;
  paid number;
  remaining number;
begin
  ddckbal_sp(103, amount, paid, remaining);
  dbms_output.put_line('Amount: ' || amount || ', Paid: ' || paid || ', Remaining: ' || remaining);
end;