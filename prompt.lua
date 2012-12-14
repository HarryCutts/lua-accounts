dofile("model.lua")
dofile("commands.lua")

-- Source: http://lua-users.org/wiki/SplitJoin
local function split(str, pat)
	local t = {}  -- NOTE: use {n = 0} in Lua-5.0
	local fpat = "(.-)" .. pat
	local last_end = 1
	local s, e, cap = str:find(fpat, 1)
	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(t,cap)
		end
		last_end = e+1
		s, e, cap = str:find(fpat, last_end)
	end
	if last_end <= #str then
		cap = str:sub(last_end)
		table.insert(t, cap)
	end
	return t
end

local promptCommands = {
	["test-args"] = function(session, ...)
		for i = 1,select('#', ...) do
			print(i, select(i, ...))
		end
	end,

	["exit"] = function(session)
		session.db:Close()
		os.exit()
	end,
}

local function prompt(db)
	print("Lua-accounts alpha 1")
	print("Loaded \""..arg[2].."\".")

	-- Chain the command tables
	commands = setmetatable(promptCommands, { __index = dbCommands })

	-- Create the session table
	session = {
		db = db,
		name = arg[2],
	}

	print("Enter a command, or type \"help\" for help.")
	while true do
		io.write("> ")
		local line = io.read()
		local parts = split(line, "%s+")
		local cmd = parts[1]
		if commands[cmd] then
			commands[cmd](session, select(2, unpack(parts)))
		else
			print("Command not found.")
		end
	end
end

-- TODO: Check file existence
if arg[1] == "create" then
	CreateDatabase(arg[2])
elseif arg[1] == "open" then
	db = OpenDatabase(arg[2])
	prompt(db)
elseif arg[1] == "testprompt" then
	arg[2] = "<no database>"
	prompt(nil)
end
