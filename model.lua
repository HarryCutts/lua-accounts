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

--[[ Database Class Functions ]]--

function Database:New(sqliteDB)
	assert(sqliteDB)
	return setmetatable({ _sqliteDB = sqliteDB }, Database_mt)
end

function Database:Close()
	self._sqliteDB:close()
end

local function AddAccountOrCategory(sqliteDB, tableName, name)
	-- TODO: Prepared statements?
	-- Validate the name (must be unique and cannot contain spaces or slashes)
	if name:match('[%s/]') then
		return false, "Names cannot contain slashes or spaces."
	end

	query = string.format('SELECT count(*) FROM %s WHERE Name == "%s"', tableName, name)
	if value(sqliteDB, query) > 0 then
		return false, "Name already in use."
	end

	-- TODO: case insensitivity?

	-- Get a free ID number for the account or category (one more than the maximum ID)
	local id = (value(sqliteDB, 'SELECT max(ID) FROM '..tableName) or 0) + 1

	-- Create the account
	errcode = sqliteDB:exec(string.format('INSERT INTO %s VALUES(%d, "%s")',
		tableName, id, name))

	if errcode == sqlite3.OK then
		return true
	else
		return false, "SQLite3 error "..errcode
	end
end

function Database:Accounts()
	return self._sqliteDB:nrows('SELECT * FROM Account')
end

function Database:Account(name)
	-- TODO: Prepared queries
	local query = string.format('SELECT * FROM Account WHERE Name == "%s"', name)
	for account in self._sqliteDB:nrows(query) do
		return account
	end
end

function Database:AddAccount(name)
	return AddAccountOrCategory(self._sqliteDB, 'Account', name)
end

function Database:Categories()
	return self._sqliteDB:nrows('SELECT * FROM Category')
end

function Database:AddCategory(name)
	return AddAccountOrCategory(self._sqliteDB, 'Category', name)
end

--[[ "Static" Functions ]]--

function CreateDatabase(path)
	local sqliteDB = sqlite3.open(path)

	-- Enable foreign key support
	sqliteDB:exec([[PRAGMA foreign_keys = ON;]])

	-- Create tables
	sqliteDB:exec([[
		CREATE TABLE Account (ID INTEGER PRIMARY KEY, Name TEXT);
		CREATE TABLE Category(ID INTEGER PRIMARY KEY, Name TEXT);
		CREATE TABLE Trans(
			ID          INTEGER PRIMARY KEY
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
