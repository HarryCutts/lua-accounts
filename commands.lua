dbCommands = {
	["test-db-commands"] = function(session, ...)
		print("Test successful.")
	end,

	["create-account"] = function(session, name)
		success, errorMessage = session.db:AddAccount(name)
		if not success then
			print(errorMessage)
		end
	end,
}
