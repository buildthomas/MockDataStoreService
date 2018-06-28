local shouldUseMock = false

if game.GameId == 0 then
	-- Local place file, use mock:
	shouldUseMock = true
elseif game:GetService("RunService"):IsStudio() then
	-- Published file, check if API access is available:
	local status, message = pcall(function() game:GetService("DataStoreService"):GetDataStore("__TEST"):UpdateAsync("__TEST", function(...) return ... end) end)
	if not status and (message:lower():find("api access") or message:lower():find("http 403")) then
		-- Can connect to datastores, but no API access, so use mock:
		shouldUseMock = true
	end
end

-- Return the mock or actual service depending on environment:
if shouldUseMock then
	print("INFO: Using MockDataStoreService")
	return require(script.Parent.MockDataStoreService)
else
	return game:GetService("DataStoreService")
end
