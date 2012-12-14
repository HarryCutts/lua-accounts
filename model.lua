require('lsqlite3')

Database = { }
local Database_mt = { __index = Database }


--[[ Utility Functions ]]--

-- Returns the first value in the first row of the given query.
local function value(db, query)
	for v in db:urows(query) do
		return v
	end
end

function Database:New(sqliteDB)
	assert(sqliteDB)
	return setmetatable({ _sqliteDB = sqliteDB }, Database_mt)
end

function Database:Close()
	self._sqliteDB:close()
end

function Database:AddAccount(name)
	-- Validate the name (must be unique and cannot contain spaces or slashes)
	if name:match("[%s/]") then
		return false, "Names cannot contain slashes or spaces."
	end

	if value(self._sqliteDB, [[SELECT count(*) FROM Account WHERE Name == "]]..name..'"') > 0 then
		return false, "Name already in use."
	end

	-- TODO: case insensitivity?

	-- Get a free ID number for the account (one more than the maximum ID)
	local id = value(self._sqliteDB, [[SELECT max(ID) FROM Account]]) + 1

	-- Create the account
	errcode = self._sqliteDB:exec(string.format([[INSERT INTO Account VALUES(%d, "%s")]],
		id, name))

	if errcode == sqlite3.OK then
		return true
	else
		return false, "SQLite3 error "..errcode
	end
end

function CreateDatabase(path)
	local sqliteDB = sqlite3.open(path)

	-- Enable foreign key support
	sqliteDB:exec([[PRAGMA foreign_keys = ON;]])

	-- Create tables
	sqliteDB:exec([[
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

	return Database:New(sqliteDB)
end

function OpenDatabase(path)
	local sqliteDB = sqlite3.open(path)
	sqliteDB:exec([[PRAGMA foreign_keys = ON;]])
	return Database:New(sqliteDB)
end
