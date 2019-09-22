-- luacheck: globals __LEMUR__

local ServerStorage = game:GetService("ServerStorage")

local TestEZ = require(ServerStorage.TestEZ)

local results = TestEZ.TestBootstrap:run(ServerStorage.TestDataStoreService, TestEZ.Reporters.TextReporter)

if __LEMUR__ then
	if results.failureCount > 0 then
		os.exit(1)
	end
end