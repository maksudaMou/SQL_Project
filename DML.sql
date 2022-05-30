use Bookcatalog
go
---####Create tables & insert values####----
go
insert into Tags values
	('Programming'),('C#'),('Database'),('SQL Server'), ('SQL'),('Blazer'), ('Web Assembly'), ('SPA')
go

insert into Publishers values
	('Northwick publishing',null),('Southwick publishing',null),('Northwick publishing',null),('Westwick publishing',null)
go

INSERT INTO authors VALUES 
	('McDonnel', null), ('Jo Finn', 'jfinn@aol.com'), ('M Antonio', null), ('S Maria', null),
	('K watson', 'watson@mc.co.nz'), ('J Sharp', 'jsharp@magamail.com'), ('J Robbs', null)
GO

INSERT INTO Books VALUES
('c# step by step',67.99,'2022-01-03',1,1),
('SQL server 2016 for developer',88.99,'2022-08-12',1,2),
('Blazeor guide',99.99,'2022-01-07',0,1)
Go

Insert into BookTags values
(1,1),(1,2),(2,3),(2,4),(2,5),(3,6),(3,7),(3,8)
go

insert into BookAuthors values
(1,1),(1,2),(2,3),(2,4),(3,5)
Go

select * from Tags
select * from Publishers
select * from authors
select * from Books
select * from BookTags
select * from BookAuthors
go
--insert authors data uisng procedure spInsertAuthor
DECLARE @id INT
EXEC spInsertAuthor 'Warne', null, @id OUTPUT
SELECT @id as 'inserted with id'
EXEC spInsertAuthor 'McGrath', 'mg@gmail.com', @id OUTPUT
SELECT @id as 'inserted with id'
EXEC spInsertAuthor 'Wagh', null, @id OUTPUT
SELECT @id as 'inserted with id'
EXEC spInsertAuthor 'Sakib', null, @id OUTPUT
SELECT @id as 'inserted with id'
EXEC spInsertAuthor 'Biplob', 'biplob@gmail.com', @id OUTPUT
SELECT @id as 'inserted with id'
EXEC spInsertAuthor 'Watson', 'watsonp@gamail.com', @id OUTPUT
SELECT @id as 'inserted with id'
GO
SELECT * FROM authors
GO
EXEC spUpdateAuthor @authorid=1, @email = 'g1@gmail.com'
EXEC spUpdateAuthor @authorid=4, @email = 'g2@gmail.com'
EXEC spUpdateAuthor 3,'Azhar','g3@gmail.com'
GO
SELECT * FROM authors
GO
EXEC spDeleteAuthor 6, 1
GO
SELECT * FROM authors
GO
DECLARE @id INT
EXEC spInsertTag 'Programming', @id OUTPUT
SELECT @id as 'Inserted with id'
EXEC spInsertTag '.NET', @id OUTPUT
SELECT @id as 'Inserted with id'
EXEC spInsertTag 'C#', @id OUTPUT
SELECT @id as 'Inserted with id'
EXEC spInsertTag 'Database', @id OUTPUT
SELECT @id as 'Inserted with id'
EXEC spInsertTag 'SQL Server', @id OUTPUT
SELECT @id as 'Inserted with id'
EXEC spInsertTag 'ASP', @id OUTPUT
SELECT @id as 'Inserted with id'
EXEC spInsertTag 'ASP.NET', @id OUTPUT
SELECT @id as 'Inserted with id'
GO
SELECT * FROM tags
GO
EXEC spUpdateTag 5, 'SQL Server 2016'
GO
SELECT * FROM tags
GO
EXEC spDeleteTag 7
GO
SELECT * FROM tags
GO
--insert publish data uisng procedure spInsertPublisher
DECLARE @id INT
--EXEC spInsertPublisher 'Wrox publishing',null,  @id OUTPUT
--SELECT @id as 'inserted with id'
EXEC spInsertPublisher 'APres',null,  @id OUTPUT
SELECT @id as 'Inserted with id'
EXEC spInsertPublisher 'MPress',null,  @id OUTPUT
SELECT @id as 'Inserted with id'
EXEC spInsertPublisher 'Wielley',null,  @id OUTPUT
SELECT @id as 'Inserted with id'
EXEC spInsertPublisher 'Manning',null,  @id OUTPUT
SELECT @id as 'Inserted with id'
GO
SELECT * FROM publishers
GO
--update publisher using spUpdatePublisher
EXEC spUpdatePublisher 5, 'Manning Inc',';sales@manning.com'
GO
SELECT * FROM publishers
GO
--Insert data using spInsertBook
EXEC spInsertBook @title ='C#',
		@price = 59.99,
		@available = 1, 
		@publishdate ='2021-07-11',
		@publisherid=1,
		@tags = 'Programming, C#, .NET',
		@authors = '1, 2'
EXEC spInsertBook @title ='SQL',
		@price = 59.99,
		@available = 1, 
		@publishdate ='2021-07-11',
		@publisherid=1,
		@tags = 'SQL Server',
		@authors = '3'
EXEC spInsertBook @title ='UML',
		@price = 59.99,
		@available = 1, 
		@publishdate ='2021-07-11',
		@publisherid=1,
		@tags = 'PHP, Laravel',
		@authors = '5'
GO
SELECT *FROM books
SELECT * FROM bookauthors
SELECT * FROM booktags
GO
--View
SELECT * FROM vBookWithDeatils
GO
SELECT * FROM vAuthoBookCount
GO
--Test UDF
SELECT dbo.fnBooksPublished(2017)
GO
SELECT * FROM fnBooksUnderTag('C#')
--Test Tigger

exec spDeletePublicher 1
GO
SELECT * FROM publishers
GO
exec spDeletePublicher 2
GO
SELECT * FROM publishers
GO
SELECT * FROM books
GO

delete FROM authors where authorid=1

delete FROM publishers where publisherid=1

SELECT * FROM tags
SELECT * FROM booktags
GO
delete FROM tags where tagid=3
GO
SELECT * FROM tags
SELECT * FROM booktags
GO