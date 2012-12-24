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

	["list-accounts"] = function(session)
		for account in session.db:Accounts() do
			print(account.ID, account.Name)
		end
	end,

	["choose-account"] = function(session, name)
		if not name or name == "" then
			print(session.account and session.account.Name or "(none)")

		else
			account = session.db:Account(name)
			if account then
				session.account = account
			else
				print("Account not found: "..name)
			end
		end
	end,

	["create-category"] = function(session, name)
		success, errorMessage = session.db:AddCategory(name)
		if not success then
			print(errorMessage)
		end
	end,

	["list-categories"] = function(session)
		for category in session.db:Categories() do
			print(category.ID, category.Name)
		end
	end,

	-- TODO: Allow removal of categories (and accounts?)
}
