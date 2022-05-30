create database Bookcatalog
go
use bookcatalog
go

create table tags 
(
  tagid int not null identity primary key,
  tag nvarchar (30) not null
)
go 
create table publishers
( 
  publisherid int identity primary key,
  publishername nvarchar (40) not null,
  publisheremail nvarchar (50) null
 )
 go
 create table authors
 (
	authorid int identity primary key,
	authorname nvarchar(50) not null,
	email nvarchar(50) null
)
go
 create table books
( 
  bookid int identity primary key,
  title nvarchar (40) not null,
  coverprice money not null,
  publishdate date not null,
  available bit default 0,
  publisherid int not null references publishers(publisherid)
 )
go
create table booktags
(
  bookid int not null references books (bookid),
  tagid int not null references tags (tagid),
  primary key (bookid,tagid)
)
go
create table bookauthors 
(
  bookid int not null references books (bookid),
  authorid int not null references authors (authorid)
  primary key (bookid, authorid)
)
go

-- Procedures

CREATE PROC spInsertAuthor	@authorname nvarchar(50) ,
				@email nvarchar(50) = null,
				@authorid INT  OUTPUT
AS
	DECLARE @id INT
	BEGIN TRY
		insert into authors (authorname, email) values (@authorname, @email)
		SELECT @authorid = SCOPE_IDENTITY()
		
	END TRY
	BEGIN CATCH
		DECLARE @errmessage nvarchar(500)
		set @errmessage = ERROR_MESSAGE()
		RAISERROR( @errmessage, 11, 1)
		return 
	END CATCH
GO
--Update proc
CREATE PROC spUpdateAuthor 	@authorid INT ,
				@authorname nvarchar(50) = null ,
				@email nvarchar(50) = null
							
AS
BEGIN TRY
	UPDATE authors SET authorname=ISNULL(@authorname,authorname), email=ISNULL(@email, email)
	WHERE authorid = @authorid 	
END TRY
BEGIN CATCH
	DECLARE @errmessage nvarchar(500)
	set @errmessage = ERROR_MESSAGE()
	RAISERROR( @errmessage, 11, 1)
	return 
END CATCH
return 
GO 

GO
CREATE PROC spDeleteAuthor @authorid INT, @cascade BIT = 0
AS
IF EXISTS (SELECT 1 FROM bookauthors WHERE authorid=@authorid)
BEGIN
	 IF NOT @cascade <> 1
	 BEGIN
		raiserror ('Cannot delete Author, Author has related books and cascade is enabled', 11, 1)
		return
	 END
	 ELSE
	 BEGIN 
		DELETE bookauthors WHERE authorid= @authorid
	 END
END
DELETE FROM authors WHERE authorid = @authorid
GO


CREATE PROC spInsertTag	@tag nvarchar(30) ,
							@tageid INT  OUTPUT
AS
	DECLARE @id INT
	BEGIN TRY
		insert into tags(tag) values (@tag)
		SELECT @tageid = SCOPE_IDENTITY()
		
	END TRY
	BEGIN CATCH
		DECLARE @errmessage nvarchar(500)
		set @errmessage = ERROR_MESSAGE()
		RAISERROR( @errmessage, 11, 1)
		return 
	END CATCH
GO
CREATE PROC spUpdateTag	@tageid INT, @tag nvarchar(30) 						 
AS
BEGIN TRY
	UPDATE tags set tag=@tag
	WHERE tagid = @tageid 
		
END TRY
BEGIN CATCH
	DECLARE @errmessage nvarchar(500)
	set @errmessage = ERROR_MESSAGE()
	RAISERROR( @errmessage, 11, 1)
	return 
END CATCH
GO



CREATE PROC spDeleteTag @tageid INT, @cascade BIT = 0
AS
IF EXISTS (SELECT 1 FROM booktags WHERE tagid=@tageid)
BEGIN
	 IF NOT @cascade <> 1
	 BEGIN
		raiserror ('Cannot delete Tag, Tag has related books and cascade is enabled', 11, 1)
		return
	 END
	 ELSE
	 BEGIN 
		DELETE booktags WHERE tagid= @tageid
	 END
END
DELETE FROM tags WHERE tagid = @tageid
GO


CREATE PROC spInsertPublisher	@publishername nvarchar(40),
								@pulisheremail nvarchar(50) = NULL,
								@publisherid INT OUTPUT
AS
DECLARE @id INT
BEGIN TRY
	insert into publishers(publishername, publisheremail) values (@publishername, @pulisheremail)
	SELECT @publisherid = SCOPE_IDENTITY()
		
END TRY
BEGIN CATCH
	DECLARE @errmessage nvarchar(500)
	set @errmessage = ERROR_MESSAGE()
	;
	throw 50001,@errmessage,1 

END CATCH
GO

CREATE PROC spUpdatePublisher	@publisherid INT,
								@publishername nvarchar(40) =NULL,
								@pulisheremail nvarchar(50) = NULL
								 
AS

BEGIN TRY
	update publishers set publishername= isnull(@publishername, publishername), publisheremail = isnull(@pulisheremail, publisheremail)
	WHERE publisherid = @publisherid
		
END TRY
BEGIN CATCH
	DECLARE @errmessage nvarchar(500)
	set @errmessage = ERROR_MESSAGE()
	;
	throw 50001,@errmessage,1 

END CATCH
GO

CREATE PROC spDeletePublicher @publisherid INT
AS
IF EXISTS (SELECT 1 FROM books WHERE publisherid=@publisherid)
BEGIN

	raiserror ('Cannot delete Publisher', 11, 1)
	return
END
ELSE
BEGIN
	DELETE publishers WHERE publisherid= @publisherid
END
GO
CREATE PROC spInsertBook @title NVARCHAR(40), @price MONEY, @available BIT, @publishdate DATE, @publisherid INT, @tags NVARCHAR(max), @authors NVARCHAR(max)
AS
	MERGE tags t using (select RTRIM(value) as v FROM string_split(@tags, ',')) as s
		ON t.tag = s.v
	WHEN NOT MATCHED BY TARGET
		THEN INSERT (tag) VALUES(s.v);

	INSERT INTO books (title, coverprice, publishdate,available,publisherid )
	VALUES ( @title, @price,@publishdate, IIF(@publishdate > cast(@publishdate as date), 0, @available), @publisherid)

	DECLARE @id INT
	SET @id = SCOPE_IDENTITY()
	--bookauthors
	insert into bookauthors (bookid, authorid)
	select @id, RTRIM(value)
	FROM string_split(@authors, ',') 
	--booktags
	insert into booktags (bookid, tagid)
	SELECT @id, t.tagid
	FROM
	(SELECT RTRIM(value) as value
	FROM string_split(@tags, ',')) as s
	INNER JOIN tags t ON t.tag = s.value

	RETURN;
GO

--- Views

CREATE VIEW vBookWithDeatils 
AS

SELECT b.bookid, b.title, b.publishdate, b.coverprice, b.available, a.authorname, p.publishername
FROM books b
INNER JOIN publishers p ON b.publisherid=p.publisherid
INNER JOIN bookauthors ba ON b.bookid = ba.bookid
INNER JOIN booktags bt ON b.bookid = bt.bookid
INNER JOIN authors a ON ba.authorid = a.authorid
INNER JOIN tags t ON bt.tagid = t.tagid
GO



CREATE VIEW vAuthoBookCount
AS
SELECT a.authorname,COUNT(ba.bookid) 'Books written'
FROM books b
INNER JOIN bookauthors ba ON b.bookid = ba.bookid
INNER JOIN authors a ON ba.authorid = a.authorid
GROUP BY a.authorname
GO

--UDF

 CREATE FUNCTION fnBooksPublished (@year INT) RETURNS INT
 AS
 BEGIN
 DECLARE @c INT
 SELECT @c = COUNT(*) FROM books
 WHERE YEAR(publishdate)= @year
 RETURN @c
 END
 GO

 CREATE FUNCTION fnBooksUnderTag(@tag nvarchar(30)) RETURNS TABLE
 AS
RETURN (SELECT b.bookid, b.title, b.publishdate, b.coverprice, b.available, a.authorname, p.publishername
FROM books b
INNER JOIN publishers p ON b.publisherid=p.publisherid
INNER JOIN bookauthors ba ON b.bookid = ba.bookid
INNER JOIN booktags bt ON b.bookid = bt.bookid
INNER JOIN authors a ON ba.authorid = a.authorid
INNER JOIN tags t ON bt.tagid = t.tagid
WHERE t.tag = @tag
)
GO

-- Tiggers

 --Prevents insert book publishdate before today
create TRIGGER trInsertBook
ON books
FOR INSERT
AS 
BEGIN
	DECLARE @pd DATE
	SELECT @pd = publishdate FROM inserted
	 
	IF CAST(@pd AS DATE) < CAST(DATEADD(year, -2, GETDATE()) as DATE) 
	BEGIN
		RAISERROR('Invalid date', 11, 1)
		ROLLBACK Transaction
	END
END
GO
CREATE TRIGGER trAuthorDelete
ON authors
AFTER DELETE
AS
BEGIN
	 DECLARE @id INT
	 SELECT @id = authorid FROM deleted
	 IF EXISTS (SELECT 1 FROM bookauthors where authorid = @id)
	 BEGIN
		ROLLBACK TRANSACTION
		RAISERROR ('Author has dependendent book. So delete them first', 16, 1)
		RETURN
	 END
END
GO
CREATE TRIGGER trPublisherDelete
ON publishers
AFTER DELETE
AS
BEGIN
	 DECLARE @id INT
	 SELECT @id = publisherid FROM deleted
	 IF EXISTS (SELECT 1 FROM books where publisherid = @id)
	 BEGIN
		ROLLBACK TRANSACTION
		RAISERROR ('Publisher has dependendent book. Delete them first', 16, 1)
		RETURN
	 END
END
GO

GO
CREATE TRIGGER trTagDelete
ON tags
AFTER DELETE
AS
BEGIN
	 DECLARE @id INT
	 SELECT @id = tagid FROM tags
	 DELETE FROM booktags WHERE tagid=@id
END
GO
