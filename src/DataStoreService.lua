--[[	DataStoreService.lua
		This module decides whether to use actual datastores or mock datastores depending on the environment.

		This module is licensed under APLv2, refer to the LICENSE file or:
		https://www.apache.org/licenses/LICENSE-2.0

		To use this code, you must keep this notice in all copies of (significant pieces of) this code.
		Copyright 2018 buildthomas
]]

local MockDataStoreServiceModule = script.Parent.MockDataStoreService -- set this as path to the module

local shouldUseMock = false
if game.GameId == 0 then
	-- Local place file, use mock:
	shouldUseMock = true
elseif game:GetService("RunService"):IsStudio() then
	-- Published file in Studio, check if API access is available:
	local status, message = pcall(function()
		-- This will error if current instance has no Studio API access:
		game:GetService("DataStoreService"):GetDataStore("__TEST"):UpdateAsync("__TEST", function(...) return ... end)
	end)
	if not status and (message:lower():find("api access") or message:lower():find("http 403")) then -- hack
		-- Can connect to datastores, but no API access, so use mock:
		shouldUseMock = true
	end
end

-- Return the mock or actual service depending on environment:
if shouldUseMock then
	warn("INFO: Using MockDataStoreService instead of DataStoreService")
	return require(MockDataStoreServiceModule)
else
	return game:GetService("DataStoreService")
end
