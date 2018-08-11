--[[	MockDataStoreManager.lua
		This module does bookkeeping of data, interfaces and request limits used by MockDataStoreService and its sub-classes.

		This module is licensed under APLv2, refer to the LICENSE file or:
		https://github.com/buildthomas/MockDataStoreService/blob/master/LICENSE
]]

local MockDataStoreManager = {}

local Utils = require(script.Parent.MockDataStoreUtils)
local Constants = require(script.Parent.MockDataStoreConstants)
local HttpService = game:GetService("HttpService")

-- Bookkeeping of all data:
local Data = {
	GlobalDataStore = {};
	DataStore = {};
	OrderedDataStore = {};
}

-- Bookkeeping of all active GlobalDataStore/OrderedDataStore interfaces indexed by data table:
local Interfaces = {}

-- Request limit bookkeeping:
local Budgets = {
	[Enum.DataStoreRequestType.GetAsync] = Constants.GETASYNC;
	[Enum.DataStoreRequestType.GetSortedAsync] = Constants.GETSORTEDASYNC;
	[Enum.DataStoreRequestType.OnUpdate] = Constants.ONUPDATE;
	[Enum.DataStoreRequestType.SetIncrementAsync] = Constants.SETINCRASYNC;
	[Enum.DataStoreRequestType.SetIncrementSortedAsync] = Constants.SETINCRSORTEDASYNC;
	[Enum.DataStoreRequestType.UpdateAsync] = Constants.UPDATEASYNC;
}

delay(0, function() -- Thread that restores budgets periodically

	-- TODO: investigate how Roblox restores budgets and implement

end)

function MockDataStoreManager:GetGlobalData()
	return Data.GlobalDataStore
end

function MockDataStoreManager:GetData(name, scope)
	assert(typeof(name) == "string")
	assert(typeof(scope) == "string")

	if not Data.DataStore[name] then
		Data.DataStore[name] = {}
	end
	if not Data.DataStore[name][scope] then
		Data.DataStore[name][scope] = {}
	end

	return Data.DataStore[name][scope]
end

function MockDataStoreManager:GetOrderedData(name, scope)
	assert(typeof(name) == "string")
	assert(typeof(scope) == "string")

	if not Data.OrderedDataStore[name] then
		Data.OrderedDataStore[name] = {}
	end
	if not Data.OrderedDataStore[name][scope] then
		Data.OrderedDataStore[name][scope] = {}
	end

	return Data.OrderedDataStore[name][scope]
end

function MockDataStoreManager:GetDataInterface(data)
	return Interfaces[data]
end

function MockDataStoreManager:SetDataInterface(data, interface)
	assert(typeof(data) == "table")
	assert(typeof(interface) == "table")

	Interfaces[data] = interface
end

function MockDataStoreManager:GetBudget(requestType)
	return Budgets[requestType] or 0
end

function MockDataStoreManager:ConsumeBudget(requestType)
	if not Budgets[requestType] or Budgets[requestType] <= 0 then
		return false
	end
	-- TODO: uncomment when request limits are actually refreshed
	--Budgets[requestType] = Budgets[requestType] - 1
	return true
end

function MockDataStoreManager:ExportToJSON()
	local export = {}

	if next(Data.GlobalDataStore) ~= nil then -- GlobalDataStore not empty
		export.GlobalDataStore = Data.GlobalDataStore
	end
	export.DataStore = Utils.prepareDataStoresForExport(Data.DataStore) -- can be nil
	export.OrderedDataStore = Utils.prepareDataStoresForExport(Data.OrderedDataStore) -- can be nil

	return HttpService:JSONEncode(export)
end

function MockDataStoreManager:ImportFromJSON(json, verbose)
	local content
	if typeof(json) == "string" then
		local parsed, value = pcall(function() return HttpService:JSONDecode(json) end)
		if not parsed then
			error("bad argument #1 to 'ImportFromJSON' (string is not valid json)", 2)
		end
		content = value
	elseif typeof(json) == "table" then
		content = Utils.deepcopy(json)
	else
		error(("bad argument #1 to 'ImportFromJSON' (string or table expected, got %s)"):format(typeof(json)), 2)
	end

	local warnFunc = warn -- assume verbose as default
	if verbose == false then -- intentional formatting
		warnFunc = function() end
	end

	if typeof(content.GlobalDataStore) == "table" then
		Utils.importPairsFromTable(
			content.GlobalDataStore,
			Data.GlobalDataStore,
			warnFunc,
			"ImportFromJSON",
			"GlobalDataStore",
			false
		)
	end
	if typeof(content.DataStore) == "table" then
		Utils.importDataStoresFromTable(
			content.DataStore,
			Data.DataStore,
			warnFunc,
			"ImportFromJSON",
			"DataStore",
			false
		)
	end
	if typeof(content.OrderedDataStore) == "table" then
		Utils.importDataStoresFromTable(
			content.OrderedDataStore,
			Data.OrderedDataStore,
			warnFunc,
			"ImportFromJSON",
			"OrderedDataStore",
			true
		)
	end
end

return MockDataStoreManager