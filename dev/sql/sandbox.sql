-- Samples to try.
-- Prerequisite:
--  1. Set up POSTGRES_URL environment variable with connection string.
--     $ psql $POSTGRES_URL
--
--
--  customers        orders            lines             items
--  +----------+     +-----------+     +-----------+     +-------------+
--  | id       |     | id        |     | id        |     | id          |
--  | name     |<----| cust_id   |     | item_id   |---->| sku         |
--  | address  |     | line_id   |---->| price     |     | description |
--  | city     |     | order_num |     | quantity  |     +-------------+
--  | state    |     +-----------+     +-----------+
--  | zip_code |
--  | country  |
--  +----------+
--

-- Try these with :let g:conjure#client#sql#stdio#command = "psql -U blogger postgres"
-- Must have ~/.pgpass with "chmod 600" set up with blogger's password for postgres database.

-- DDL
DROP TABLE items;
DROP TABLE customers;
DROP TABLE orders;
DROP TABLE lines;

-- Check for tables:   \d

CREATE TABLE items (
    id integer primary key
  , sku varchar(40)
  , description varchar(100)
);

INSERT INTO items VALUES (1, 'ZF-193-1111', 'Super Cleaner'); -- $19.99
INSERT INTO items VALUES (2, 'JF-794-1315', 'Super Soaker'); -- $25.19
INSERT INTO items VALUES (3, 'MH-100-1310', 'Super Fine'); -- $27.79
INSERT INTO items VALUES (4, 'WF-992-3191', 'Ultra Fine'); -- $29.29
INSERT INTO items VALUES (5, 'GS-093-1811', 'Super Duper'); -- $9.09


CREATE TABLE customers (
    id integer primary key
  , name varchar(40)
  , address varchar(40)
  , city varchar(40)
  , state varchar(40)
  , zip_code varchar(10)
  , country varchar(40)
);

INSERT INTO customers VALUES (1, 'John Doe', '92-112 Beta Center Lane', 'Downtown', 'HI', 96718-3214);
INSERT INTO customers VALUES (2, 'Mary Jane Pond', '42 Answer Lane', 'Paia', 'HI', 96712-2148);
INSERT INTO customers VALUES (3, 'Zachary Pena', '911 Tower Boulevard', 'Punaluu', 'HI', 96735-1449);


CREATE TABLE orders (
    id integer primary key
  , cust_id integer
  , line_id integer
  , order_num varchar(20)
);


CREATE TABLE lines (
    id integer primary key
  , item_id integer
  , price numeric(10,2)
  , quantity integer
);


-- John has no orders.

-- Zack has an order with 1 item.
INSERT INTO lines VALUES (1, 1, 29.29, 32);
INSERT INTO orders VALUES (1, 3, 1, 'AA-00001');

-- MJ has an order of 2 items.
INSERT INTO lines VALUES (2, 2, 19.99, 2);
INSERT INTO lines VALUES (3, 5, 9.09, 41);
INSERT INTO orders VALUES (2, 2, 2, 'AA-00002');
INSERT INTO orders VALUES (3, 2, 3, 'AA-00002');

-- Zack has an order with 3 items.
INSERT INTO lines VALUES (4, 4, 19.99, 7);
INSERT INTO lines VALUES (5, 5, 25.19, 5);
INSERT INTO lines VALUES (6, 3, 29.29, 1);
INSERT INTO orders VALUES (4, 3, 4, 'AA-00003');
INSERT INTO orders VALUES (5, 3, 5, 'AA-00003');
INSERT INTO orders VALUES (6, 3, 6, 'AA-00003');

-- Evaluate the following before sending an interrupt.
SELECT 1
\watch


-- From: https://www.postgresqltutorial.com/postgresql-indexes/postgresql-create-index/
-- Show the query plan before an index is added.

--   Tree-sitter SQL parser considers EXPLAIN to be an ERROR so use visual
--   selection to send EXPLAIN statements to the repl.

-- Simple query on a table.
EXPLAIN SELECT *
FROM customers WHERE name = 'Zachary Pena';

-- Who's ordered items?
EXPLAIN SELECT
    description
  , name
  , order_num
  , quantity
  , price
  , description
FROM items a LEFT JOIN lines b ON a.id = b.item_id
LEFT JOIN orders c ON b.id = c.line_id
LEFT JOIN customers d ON c.cust_id = d.id;


CREATE INDEX idx_cust_name ON customers(name);
-- The query plan should show an improvement for the "Seq Scan on customers"
-- step.

-- Show the query plan after an index is added.
EXPLAIN SELECT *
FROM customers WHERE name = 'Zachary Pena';

-- Who's ordered items?
EXPLAIN SELECT
    description
  , name
  , order_num
  , quantity
  , price
  , description
FROM items a LEFT JOIN lines b ON a.id = b.item_id
LEFT JOIN orders c ON b.id = c.line_id
LEFT JOIN customers d ON c.cust_id = d.id;


/*Select all the columns
of all the records in the Customers table:*/
SELECT * FROM customers;
SELECT /*id,*/ description, sku FROM items;
SELECT * FROM orders;
SELECT * FROM lines;

-- What's on each order?
SELECT
    order_num
  , line_id
  , quantity
  , price
  , item_id
  , description
FROM orders a
LEFT JOIN lines b ON a.line_id = b.id
LEFT JOIN items c ON b.item_id = c.id
ORDER BY order_num;


-- What have customers ordered?
SELECT
    name
  , order_num
  , quantity
  , price
  , sku
  , description
FROM customers a LEFT JOIN orders b ON a.id = b.cust_id
LEFT JOIN lines c ON b.line_id = c.id
LEFT JOIN items d ON c.item_id = d.id
ORDER BY name, order_num;


-- Metacommands (aka, slash or backslash commands)
--   Tree-sitter SQL parser considers metacommands to be an ERROR.
--   So, we don't want just throw ERROR parts away.
--
-- If metacommands are a SELECT statement when evaluating the current form
-- (",ee"), they will get picked up along with the SELECT statement. Be sure to
-- have a comment line before the metacommands. 
/*---
-- What tables are there?
\dt
-- Who am I connected as?
\conninfo
-- An error
bad statement;
-- Tell psql to quit; thus causing the repl to stop.
\q
*---*/

/* ---- Postgres-specific examples ---- 
postgres=> insert into test_tab (id, name) values (2, "tock");
ERROR:  column "tock" does not exist
LINE 1: insert into test_tab (id, name) values (2, "tock");
                                               ^
postgres=> insert into test_tab values (1, 'test entry');
INSERT 0 1

postgres=> insert into test_tab values (3, 'tock');
INSERT 0 1

postgres=> select * from test_tab;
 id | name 
----+------
  1 | test entry
  3 | tock
(2 rows)
* ---- End of Postgres-specific examples ----*/
