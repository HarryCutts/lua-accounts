require('lsqlite3')

Database = { }
local Database_mt = { __index = Database }

function Database:New(sqliteDB)
	return setmetatable({ _sqliteDB = sqliteDB }, Database_mt)
end

function Database:Close()
	self._sqliteDB:close()
end

function CreateDatabase(path)
	local db = sqlite3.open(path)

	-- Enable foreign key support
	db:exec([[PRAGMA foreign_keys = ON;]])

	-- Create tables
	db:exec([[
		CREATE TABLE Account (ID INTEGER PRIMARY KEY, Name TEXT);
		CREATE TABLE Category(ID INTEGER PRIMARY KEY, Name TEXT);
		CREATE TABLE Trans(
			Date        DATE,
			Amount      INTEGER,
			ToFrom      TEXT,
			Description TEXT,
			AccountID   INTEGER NOT NULL,
			CategoryID  INTEGER,
			FOREIGN KEY(AccountID)  REFERENCES Account(ID),
			FOREIGN KEY(CategoryID) REFERENCES Category(ID)
		);
	]])

	return Database:New(db)
end

function OpenDatabase(path)
	return Database:New(sqlite3.open(path))
end
