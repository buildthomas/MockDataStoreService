--[[	MockOrderedDataStore.lua
		This module implements the API and functionality of Roblox's OrderedDataStore class.

		This module is licensed under APLv2, refer to the LICENSE file or:
		https://github.com/buildthomas/MockDataStoreService/blob/master/LICENSE
]]

local MockOrderedDataStore = {}
MockOrderedDataStore.__index = MockOrderedDataStore

local Manager = require(script.Parent.MockDataStoreManager)
local MockDataStorePages = require(script.Parent.MockDataStorePages)
local Utils = require(script.Parent.MockDataStoreUtils)
local Constants = require(script.Parent.MockDataStoreConstants)
local HttpService = game:GetService("HttpService") -- for json encode/decode

local rand = Random.new()

function MockOrderedDataStore:OnUpdate(key, callback)
	if typeof(key) ~= "string" then
		error(("bad argument #1 to 'OnUpdate' (string expected, got %s)"):format(typeof(key)), 2)
	elseif typeof(callback) ~= "function" then
		error(("bad argument #2 to 'OnUpdate' (function expected, got %s)"):format(typeof(callback)), 2)
	elseif #key == 0 then
		error("bad argument #1 to 'OnUpdate' (key name can't be empty)", 2)
	elseif #key > Constants.MAX_LENGTH_KEY then
		error(("bad argument #1 to 'OnUpdate' (key name exceeds %d character limit)"):format(Constants.MAX_LENGTH_KEY), 2)
	end

	return self.__event.Event:Connect(function(k, v)
		if k == key and Manager:StealBudget(Enum.DataStoreRequestType.OnUpdate) then
			if Constants.YIELD_TIME_UPDATE_MAX > 0 then
				wait(rand:NextNumber(Constants.YIELD_TIME_UPDATE_MIN, Constants.YIELD_TIME_UPDATE_MAX))
			end
			callback(v) -- v was implicitly deep-copied
		end
	end)
end

function MockOrderedDataStore:GetAsync(key)
	if typeof(key) ~= "string" then
		error(("bad argument #1 to 'GetAsync' (string expected, got %s)"):format(typeof(key)), 2)
	elseif #key == 0 then
		error("bad argument #1 to 'GetAsync' (key name can't be empty)", 2)
	elseif #key > Constants.MAX_LENGTH_KEY then
		error(("bad argument #1 to 'GetAsync' (key name exceeds %d character limit)"):format(Constants.MAX_LENGTH_KEY), 2)
	end

	self.__getCache[key] = tick()
	Manager:TakeBudget(key, Enum.DataStoreRequestType.GetAsync)

	local retValue = self.__data[key]

	if Constants.YIELD_TIME_MAX > 0 then
		wait(rand:NextNumber(Constants.YIELD_TIME_MIN, Constants.YIELD_TIME_MAX))
	end

	return retValue
end

function MockOrderedDataStore:IncrementAsync(key, delta)
	if typeof(key) ~= "string" then
		error(("bad argument #1 to 'IncrementAsync' (string expected, got %s)"):format(typeof(key)), 2)
	elseif delta ~= nil and typeof(delta) ~= "number" then
		error(("bad argument #2 to 'IncrementAsync' (number expected, got %s)"):format(typeof(delta)), 2)
	elseif #key == 0 then
		error("bad argument #1 to 'IncrementAsync' (key name can't be empty)", 2)
	elseif #key > Constants.MAX_LENGTH_KEY then
		error(("bad argument #1 to 'IncrementAsync' (key name exceeds %d character limit)")
			:format(Constants.MAX_LENGTH_KEY), 2)
	end

	Manager:TakeBudget(key, Enum.DataStoreRequestType.SetIncrementSortedAsync)

	local old = self.__data[key]

	if old ~= nil and (typeof(old) ~= "number" or old%1 ~= 0) then
		if Constants.YIELD_TIME_MAX > 0 then
			wait(rand:NextNumber(Constants.YIELD_TIME_MIN, Constants.YIELD_TIME_MAX))
		end
		error("IncrementAsync rejected with error: cannot increment non-integer value", 2)
	end

	if tick() - (self.__writeCache[key] or 0) < Constants.WRITE_COOLDOWN then
		return warn(("Request was throttled, a key can only be written to once every %d seconds. Key = %s")
			:format(Constants.WRITE_COOLDOWN, key))
	end

	delta = delta and math.floor(delta + .5) or 1

	if old == nil then
		self.__data[key] = delta
		self.__ref[key] = {Key = key, Value = self.__data[key]}
		table.insert(self.__sorted, self.__ref[key])
		self.__changed = true
		self.__event:Fire(key, self.__data[key])
	elseif delta ~= 0 then
		self.__data[key] = self.__data[key] + delta
		self.__ref[key].Value = self.__data[key]
		self.__changed = true
		self.__event:Fire(key, self.__data[key])
	end

	self.__writeCache[key] = tick()

	local retValue = self.__data[key]

	if Constants.YIELD_TIME_MAX > 0 then
		wait(rand:NextNumber(Constants.YIELD_TIME_MIN, Constants.YIELD_TIME_MAX))
	end

	return retValue
end

function MockOrderedDataStore:RemoveAsync(key)
	if typeof(key) ~= "string" then
		error(("bad argument #1 to 'RemoveAsync' (string expected, got %s)"):format(typeof(key)), 2)
	elseif #key == 0 then
		error("bad argument #1 to 'RemoveAsync' (key name can't be empty)", 2)
	elseif #key > Constants.MAX_LENGTH_KEY then
		error(("bad argument #1 to 'RemoveAsync' (key name exceeds %d character limit)"):format(Constants.MAX_LENGTH_KEY), 2)
	end

	Manager:TakeBudget(key, Enum.DataStoreRequestType.SetIncrementSortedAsync)

	if tick() - (self.__writeCache[key] or 0) < Constants.WRITE_COOLDOWN then
		return warn(("Request was throttled, a key can only be written to once every %d seconds. Key = %s")
			:format(Constants.WRITE_COOLDOWN, key))
	end

	local value = self.__data[key]

	if value ~= nil then
		self.__data[key] = nil
		self.__ref[key] = nil
		for i,v in pairs(self.__sorted) do
			if v.Key == key then
				table.remove(self.__sorted, i)
				break
			end
		end
		self.__event:Fire(key, nil)
	end

	self.__writeCache[key] = tick()

	if Constants.YIELD_TIME_MAX > 0 then
		wait(rand:NextNumber(Constants.YIELD_TIME_MIN, Constants.YIELD_TIME_MAX))
	end

	return value
end

function MockOrderedDataStore:SetAsync(key, value)
	if typeof(key) ~= "string" then
		error(("bad argument #1 to 'SetAsync' (string expected, got %s)"):format(typeof(key)), 2)
	elseif #key == 0 then
		error("bad argument #1 to 'SetAsync' (key name can't be empty)", 2)
	elseif #key > Constants.MAX_LENGTH_KEY then
		error(("bad argument #1 to 'SetAsync' (key name exceeds %d character limit)"):format(Constants.MAX_LENGTH_KEY), 2)
	elseif typeof(value) ~= "number" then
		error(("bad argument #2 to 'SetAsync' (number expected, got %s)"):format(typeof(value)), 2)
	elseif value%1 ~= 0 then
		error("bad argument #2 to 'SetAsync' (cannot store non-integer values in OrderedDataStore)", 2)
	end

	Manager:TakeBudget(key, Enum.DataStoreRequestType.SetIncrementSortedAsync)

	if tick() - (self.__writeCache[key] or 0) < Constants.WRITE_COOLDOWN then
		return warn(("Request was throttled, a key can only be written to once every %d seconds. Key = %s")
			:format(Constants.WRITE_COOLDOWN, key))
	end

	local old = self.__data[key]

	if old == nil then
		self.__data[key] = value
		self.__ref[key] = {Key = key, Value = value}
		table.insert(self.__sorted, self.__ref[key])
		self.__changed = true
		self.__event:Fire(key, self.__data[key])
	elseif old ~= value then
		self.__data[key] = value
		self.__ref[key].Value = value
		self.__changed = true
		self.__event:Fire(key, self.__data[key])
	end

	self.__writeCache[key] = tick()

	if Constants.YIELD_TIME_MAX > 0 then
		wait(rand:NextNumber(Constants.YIELD_TIME_MIN, Constants.YIELD_TIME_MAX))
	end

	return value
end

function MockOrderedDataStore:UpdateAsync(key, transformFunction)
	if typeof(key) ~= "string" then
		error(("bad argument #1 to 'UpdateAsync' (string expected, got %s)"):format(typeof(key)), 2)
	elseif typeof(transformFunction) ~= "function" then
		error(("bad argument #2 to 'UpdateAsync' (function expected, got %s)"):format(typeof(transformFunction)), 2)
	elseif #key == 0 then
		error("bad argument #1 to 'UpdateAsync' (key name can't be empty)", 2)
	elseif #key > Constants.MAX_LENGTH_KEY then
		error(("bad argument #1 to 'UpdateAsync' (key name exceeds %d character limit)"):format(Constants.MAX_LENGTH_KEY), 2)
	end

	if tick() - (self.__getCache[key] or 0) < Constants.GET_CACHE_COOLDOWN then
		Manager:TakeBudget(key, Enum.DataStoreRequestType.SetIncrementSortedAsync)
	else
		self.__getCache[key] = tick()
		Manager:TakeBudget(key, Enum.DataStoreRequestType.SetIncrementSortedAsync, Enum.DataStoreRequestType.GetAsync)
	end

	local value = transformFunction(self.__data[key])

	if type(value) ~= "number" or value%1 ~= 0 then
		error("bad argument #2 to 'UpdateAsync' (resulting non-integer value can't be stored in OrderedDataStore)", 2)
	end

	if tick() - (self.__writeCache[key] or 0) < Constants.WRITE_COOLDOWN then
		return warn(("Request was throttled, a key can only be written to once every %d seconds. Key = %s")
			:format(Constants.WRITE_COOLDOWN, key))
	end

	local old = self.__data[key]

	if old == nil then
		self.__data[key] = value
		self.__ref[key] = {Key = key, Value = value}
		table.insert(self.__sorted, self.__ref[key])
		self.__changed = true
		self.__event:Fire(key, self.__data[key])
	elseif old ~= value then
		self.__data[key] = value
		self.__ref[key].Value = value
		self.__changed = true
		self.__event:Fire(key, self.__data[key])
	end

	self.__writeCache[key] = tick()

	if Constants.YIELD_TIME_MAX > 0 then
		wait(rand:NextNumber(Constants.YIELD_TIME_MIN, Constants.YIELD_TIME_MAX))
	end

	return value
end

function MockOrderedDataStore:GetSortedAsync(ascending, pagesize, minValue, maxValue)
	if typeof(ascending) ~= "boolean" then
		error(("bad argument #1 to 'GetSortedAsync' (boolean expected, got %s)"):format(typeof(ascending)), 2)
	elseif typeof(pagesize) ~= "number" then
		error(("bad argument #2 to 'GetSortedAsync' (number expected, got %s)"):format(typeof(pagesize)), 2)
	end

	pagesize = math.floor(pagesize + .5)
	if pagesize <= 0 or pagesize > Constants.MAX_PAGE_SIZE then
		error(("bad argument #2 to 'GetSortedAsync' (page size must be an integer above 0 and below or equal to %d)")
			:format(Constants.MAX_PAGE_SIZE), 2)
	end

	if minValue ~= nil then
		if typeof(minValue) ~= "number" then
			error(("bad argument #3 to 'GetSortedAsync' (number expected, got %s)"):format(typeof(minValue)), 2)
		elseif minValue%1 ~= 0 then
			error("bad argument #3 to 'GetSortedAsync' (minimum threshold must be an integer)", 2)
		end
	else
		minValue = -math.huge
	end

	if maxValue ~= nil then
		if typeof(maxValue) ~= "number" then
			error(("bad argument #4 to 'GetSortedAsync' (number expected, got %s)"):format(typeof(maxValue)), 2)
		elseif maxValue%1 ~= 0 then
			error("bad argument #4 to 'GetSortedAsync' (maximum threshold must be an integer)", 2)
		end
	else
		maxValue = math.huge
	end

	Manager:TakeBudget(nil, Enum.DataStoreRequestType.GetSortedAsync)

	if minValue > maxValue then
		if Constants.YIELD_TIME_MAX > 0 then
			wait(rand:NextNumber(Constants.YIELD_TIME_MIN, Constants.YIELD_TIME_MAX))
		end
		error("GetSortedAsync rejected with error: minimum threshold is higher than maximum threshold", 2)
	end

	if self.__changed then
		table.sort(self.__sorted, function(a,b) return a.Value < b.Value end)
		self.__changed = false
	end

	local results = {}

	if ascending then
		local i = 1
		while self.__sorted[i] and self.__sorted[i].Value < minValue do
			i = i + 1
		end
		while self.__sorted[i] and self.__sorted[i].Value <= maxValue do
			table.insert(results, {key = self.__sorted[i].Key, value = self.__sorted[i].Value})
			i = i + 1
		end
	else
		local i = #self.__sorted
		while i > 0 and self.__sorted[i].Value > maxValue do
			i = i - 1
		end
		while i > 0 and self.__sorted[i].Value >= minValue do
			table.insert(results, {key = self.__sorted[i].Key, value = self.__sorted[i].Value})
			i = i - 1
		end
	end

	if Constants.YIELD_TIME_MAX > 0 then
		wait(rand:NextNumber(Constants.YIELD_TIME_MIN, Constants.YIELD_TIME_MAX))
	end

	return setmetatable({
		__currentpage = 1;
		__pagesize = pagesize;
		__results = results;
		IsFinished = (#results <= pagesize);
	}, MockDataStorePages)
end

function MockOrderedDataStore:ExportToJSON()
	return HttpService:JSONEncode(self.__data)
end

function MockOrderedDataStore:ImportFromJSON(json, verbose)
	local content
	if typeof(json) == "string" then
		local parsed, value = pcall(function() return HttpService:JSONDecode(json) end)
		if not parsed then
			error("bad argument #1 to 'ImportFromJSON' (string is not valid json)", 2)
		end
		content = value
	elseif typeof(json) == "table" then
		content = json -- No need to deepcopy, OrderedDataStore only contains numbers which are passed by value
	else
		error(("bad argument #1 to 'ImportFromJSON' (string or table expected, got %s)"):format(typeof(json)), 2)
	end

	if verbose ~= nil and typeof(verbose) ~= "boolean" then
		error(("bad argument #2 to 'ImportFromJSON' (boolean expected, got %s)"):format(typeof(verbose)), 2)
	end

	Utils.importPairsFromTable(
		content,
		self.__data,
		Manager:GetDataInterface(self.__data),
		(verbose == false and function() end or warn),
		"ImportFromJSON",
		("OrderedDataStore > %s > %s"):format(self.__name, self.__scope),
		true
	)
end

return MockOrderedDataStore