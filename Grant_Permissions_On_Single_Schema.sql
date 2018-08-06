CREATE ROLE [RoleName] AUTHORIZATION dbo;
EXEC sp_addrolemember 'RoleName', '[UserName]';

CREATE SCHEMA [SchemaName] AUTHORIZATION [RoleName];

GRANT CREATE TABLE, CREATE PROCEDURE, CREATE FUNCTION, CREATE VIEW TO [RoleName];
