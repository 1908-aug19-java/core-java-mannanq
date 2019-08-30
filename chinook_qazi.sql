-- chinook exercise

-- 2.1:

-- a.
select * from "Employee";
-- b.
select * from "Employee" where "LastName" = 'King';
-- c.
select * from "Album" order by "Title" desc;
-- d. 
select "FirstName" from "Customer" order by "City";

-- e.
select * from "Invoice" where "BillingAddress" like 'T%';
-- f.
select "Name" from "Track" where "Milliseconds" = (select max("Milliseconds") from "Track");

-- g.
select avg("Total") from "Invoice";

-- h.
select "Title", count(*) from "Employee" group by "Title";

-- 2.2
-- a. 
insert into "Genre" ("GenreId", "Name") values (26, 'Something else');
insert into "Genre" ("GenreId", "Name") values (27, 'Something else else');
--

-- b. 
INSERT INTO "Employee" ("EmployeeId", "LastName", "FirstName", "Title", "BirthDate", "HireDate", "Address", "City", "State", "Country", "PostalCode", "Phone", "Fax", "Email") VALUES (1, N'Jane', N'Doe', N'dev Spec', '1964/2/19', '2004/8/14', N'10901 Capper Ave NE', N'Calgary', N'AB', N'Canada', N'T10 2J1', N'+1 (551) 401-9501', N'+1 (789) 111-4750', N'jane_doe@chinookcorp.com');
INSERT INTO "Employee" ("EmployeeId", "LastName", "FirstName", "Title", "BirthDate", "HireDate", "Address", "City", "State", "Country", "PostalCode", "Phone", "Fax", "Email") VALUES (1, N'John', N'Doe', N'dev support', '1967/3/17', '2004/11/13', N'5501 Jaspe Ave NE', N'Fort McMurray', N'AB', N'Canada', N'J5N 1NN', N'+1 (605) 410-8799', N'+1 (700) 141-6950', N'john_doe@chinookcorp.com');


-- c.

INSERT INTO "Customer" ("CustomerId", "FirstName", "LastName", "Company", "Address", "City", "State", "Country", "PostalCode", "Phone", "Fax", "Email", "SupportRepId") VALUES (1, N'Luois', N'X1V', N'Airbus', N'1234. Airbus Ave ', N'Airbus State', N'FR', N'France', N'10005-10', N'+33 (45) 4900-5555', N'+33 (45) 4900-5556', N'king_Louis@airbus.com.br', 5);

-- d.
update "Customer" set ("FirstName", "LastName") values ('Aaron', 'Mitchell') where "FirstName" = 'Robert' and "LastName" = 'Walter';

select * from "Customer" where "FirstName" = 'Aaron' and "LastName" = 'Mitchell';

select * from "Artist" where "Name" = 'CCR';
update "Artist" set "Name" = 'CCR' where "Name" = 'Creedence Clearwater Revival';

select "ArtistId" from "Artist" where "Name" = 'CCR';

-- Inner join
select c."FirstName" as "Name", i."InvoiceId", i."Total" from "Customer" c join "Invoice" i on c."CustomerId" = i."CustomerId";

-- Outer Join

select c."FirstName", c."LastName", i."InvoiceId", i."Total" from "Customer" c full outer join "Invoice" i on c."CustomerId" = i."CustomerId";

-- Right join
select a."Title", aa."Name" from "Album" a right join "Artist" aa on a."ArtistId" = aa."ArtistId";

-- cross join
select a."Name" as "Artist Name" from "Artist" a cross join "Album"  order by a."Name" desc;

-- self join
select e."FirstName" "Employee First Name", m."FirstName" as "Manager First Name"  from "Employee" e join "Employee" m on m."EmployeeId" = e."ReportsTo";


-- join query 
-- 1.
select c."FirstName" || ' ' || c."LastName", sum(i."Total") as "Total_Spending"  from "Customer" c 
join "Invoice" i on c."CustomerId" = i."CustomerId" group by c."CustomerId";

-- 2.
select count(i."Total"), c."SupportRepId" from "Customer" c 
join "Invoice" i on c."CustomerId" = i."CustomerId" group by c."SupportRepId";

-- 3. 

select count(ii."Quantity"),  g."Name" as "Genre_Name" from "Track" t
join "Genre" g on g."GenreId" = t."GenreId"
left join "InvoiceLine" ii on t."TrackId" = ii."TrackId" group by g."Name" order by count(ii."Quantity") desc;


-- user defined functions
-- 1. Create a function that returns the average total of all invoices.

-- create a function called avgInvoice which returns a float. Get the average of the "Total column" and return it

create or replace function avgInvoice()
returns float
as $avg_inv$
declare 
	avg_inv float;
begin
	select avg(i."Total") into avg_inv
	from "Invoice" i;
	return avg_inv;
end;
$avg_inv$
language plpgsql;


-- run avgInvoice function
select avgInvoice();

-- 2.Create a function that returns all employees who are born after 1968.

 -- this function returns the table of all employees born after 1968. 
create or replace function employeesAfter68()
returns table (First_Name VARCHAR, BirthDate timestamp) 
as $$
begin
	return Query select
	e."FirstName", e."BirthDate"
	from "Employee" e
	where
	e."BirthDate" > '1/1/1969';
end; $$
language 'plpgsql';

select * from employeesAfter68();

--select * from "Employee" e where e."BirthDate" > '1/1/1969';

-- 3. Create a function that returns the manager of an employee, given the id of the employee.

-- part of query after equals returns the reporsTo id of the employee (i.e. the manager). That is then passed onto the other query before the equals which then returns the first and last name of the employee associated with the result of the previosu query.

create or replace function whichManager(num integer)
returns varchar
as $$
declare manager varchar;
begin
	select e."FirstName" || ' ' || e."LastName" from "Employee" e 
	where e."EmployeeId" = (select e."ReportsTo" from "Employee" e
	where e."EmployeeId" = num) into manager;
	return manager;
end;
$$
language plpgsql;

select  whichManager(7);

-- select e."FirstName" from "Employee" e where e."EmployeeId" = (select e."ReportsTo" from "Employee" e where e."EmployeeId" = 6);

