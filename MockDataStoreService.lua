--[[
	
	Documentation:
	--------------
	
	MockDataStoreService API:
	
		See members of DataStoreService:
		> https://wiki.roblox.com/index.php?title=API:Class/DataStoreService
		
		MockDataStoreService:ExportToJSON()
			Dumps the contents of all datastores to a JSON string that
			can be loaded via MockDataStoreService:ImportFromJSON(...)
			
		MockDataStoreService:ImportFromJSON(json, verbose = true)
			Loads the contents of datastores defined by the json parameter
			(a string or table) provided to the method.
			The verbose parameter determines whether warnings will be
			printed when the json table/string contains invalid entries.
	
	
	GlobalDataStore/OrderedDataStore API:
		
		See members of GlobalDataStore / OrderedDataStore:
		> https://wiki.roblox.com/index.php?title=API:Class/GlobalDataStore
		> https://wiki.roblox.com/index.php?title=API:Class/OrderedDataStore
		
		GlobalDataStore:ExportToJSON()
		OrderedDataStore:ExportToJSON()
			Dumps the contents of only this datastore to a JSON string that
			can be loaded via DataStore:ImportFromJSON(...)
			
		GlobalDataStore:ImportFromJSON(json, verbose = true)
		OrderedDataStore:ImportFromJSON(json, verbose = true)
			Loads the contents of a datastore defined by the json parameter
			(a string or table) provided to the method.
			The verbose parameter determines whether warnings will be
			printed when the json table/string contains invalid entries.
	
	-----
	
	Format of JSON output table for full datastore services:
	
		Data = {
			GlobalDataStore = {
				[key] = [value];
				...
			};
			DataStore = {
				[name] = {
					[scope] = {
						[key] = [value];
						...
					};
					...
				};
				...
			}
			OrderedDataStore = {
				[name] = {
					[scope] = {
						[key] = [value];
						...
					};
					...
				};
				...
			}
		}
		
	-----
		
	Format of JSON output table for a single datastore:
	
		Data = {
			[key] = [value];
			...
		};
	
]]

local MAX_LENGTH_KEY = 50			-- Max number of chars in key string
local MAX_LENGTH_NAME = 50			-- Max number of chars in name string
local MAX_LENGTH_SCOPE = 50			-- Max number of chars in scope string
local MAX_LENGTH_DATA = 260e3		-- Max number of chars in (encoded) data strings

local MAX_PAGE_SIZE = 100			-- Max page size for GetSortedAsync

local YIELD_TIME_MIN = 0.4			-- Random yield time values for set/get/update/remove/getsorted
local YIELD_TIME_MAX = 1.0
local YIELD_TIME_UPDATE_MIN = 1.0	-- Random yield times from events from OnUpdate
local YIELD_TIME_UPDATE_MAX = 3.0

---

local Data = {
	GlobalDataStore = {};
	DataStore = {};
	OrderedDataStore = {};
}

local Interfaces = {}

---

local HttpService = game:GetService("HttpService") -- for JSON encode/decode

local rand = Random.new()

local function deepcopy(t)
	if typeof(t) == "table" then
		local n = {}
		for i,v in pairs(t) do
			n[i] = deepcopy(v)
		end
		return n
	else
		return t
	end
end

-- Credit to Corecii
local function scanValidity(tbl, passed, path)
	if type(tbl) ~= "table" then
		return scanValidity({input = tbl}, {}, {})
	end
	passed, path = passed or {}, path or {"root"}
	passed[tbl] = true
	local tblType
	do
		local key, value = next(tbl)
		if type(key) == "number" then
			tblType = "Array"
		else
			tblType = "Dictionary"
		end
	end
	local last = 0
	for key, value in next, tbl do
		path[#path + 1] = tostring(key)
		if type(key) == "number" then
			if tblType == "Dictionary" then
				return false, path, "cannot store mixed tables"
			elseif key%1 ~= 0 then  -- if not an integer
				return false, path, "cannot store tables with non-integer indices"
			elseif key == math.huge or key == -math.huge then
				return false, path, "cannot store tables with (-)infinity indices"
			end
		elseif type(key) ~= "string" then
			return false, path, "dictionaries cannot have keys of type " .. typeof(key)
		elseif tblType == "Array" then
			return false, path, "cannot store mixed tables"
		end
		if tblType == "Array" then
			if last ~= key - 1 then
				return false, path, "array has non-sequential indices"
			end
			last = key
		end
		if type(value) == "userdata" or type(value) == "function" or type(value) == "thread" then
			return false, path, "cannot store values of type " .. typeof(value)
		end
		if type(value) == "table" then
			if passed[value] then
				return false, path, "cannot store cyclic tables"
			end
			local isValid, keyPath, reason = scanValidity(value, passed, path)
			if not isValid then
				return isValid, keyPath, reason
			end
		end
		path[#path] = nil
	end
	passed[tbl] = nil
	return true
end

-- Credit to Corecii
local function getStringPath(path)
	return table.concat(path, '.')
end

local function importPairsFromTable(origin, destination, warnFunc, methodName, prefix, isOrdered)
	for key, value in pairs(origin) do
		if typeof(key) ~= "string" then
			warnFunc(("%s: ignored %s > '%s' (key is not a string, but a %s)"):format(methodName, prefix, tostring(key), typeof(key)))
		elseif #key > MAX_LENGTH_KEY then
			warnFunc(("%s: ignored %s > '%s' (key exceeds %d character limit)"):format(methodName, prefix, key, MAX_LENGTH_KEY))
		elseif typeof(value) == "string" and #value > MAX_LENGTH_DATA then
			warnFunc(("%s: ignored %s > '%s' (length of value exceeds %d character limit)"):format(methodName, prefix, key, MAX_LENGTH_DATA))
		elseif typeof(value) == "table" and #HttpService:JSONEncode(value) > MAX_LENGTH_DATA then
			warnFunc(("%s: ignored %s > '%s' (length of encoded value exceeds %d character limit)"):format(methodName, prefix, key, MAX_LENGTH_DATA))
		elseif type(value) == "function" or type(value) == "userdata" or type(value) == "thread" then
			warnFunc(("%s: ignored %s > '%s' (cannot store values of type %s)"):format(methodName, prefix, key, type(value)))
		elseif isOrdered and type(value) ~= "number" then
			warnFunc(("%s: ignored %s > '%s' (cannot store values of type %s in OrderedDataStore)"):format(methodName, prefix, key, type(value)))
		elseif isOrdered and value%1 ~= 0 then
			warnFunc(("%s: ignored %s > '%s' (cannot store non-integer values in OrderedDataStore)"):format(methodName, prefix, key, type(value)))
		else
			local isValid = true
			local keyPath, reason
			if typeof(value) == "table" then
				isValid, keyPath, reason = scanValidity(value)
			end
			if isOrdered then
				value = math.floor(value + .5)
			end
			if isValid then
				local old = destination[key]
				destination[key] = value
				if Interfaces[destination] and old ~= value then
					if isOrdered and Interfaces[destination] then
						if Interfaces[destination].__ref[key] then
							Interfaces[destination].__ref[key].Value = value
							Interfaces[destination].__changed = true
						else
							Interfaces[destination].__ref[key] = {Key = key, Value = Interfaces[destination].__data[key]}
							table.insert(Interfaces[destination].__sorted, Interfaces[destination].__ref[key])
							Interfaces[destination].__changed = true
						end
					end
					Interfaces[destination].__event:Fire(key, value)
				end
			else
				warnFunc(("%s: ignored %s > '%s' (table has invalid entry at <%s>: %s)"):format(methodName, prefix, key, getStringPath(keyPath), reason))
			end
		end
	end
end

local function importDataStoresFromTable(origin, destination, warnFunc, methodName, prefix, isOrdered)
	for name, scopes in pairs(origin) do
		if typeof(name) ~= "string" then
			warnFunc(("%s: ignored %s > '%s' (name is not a string, but a %s)"):format(methodName, prefix, tostring(name), typeof(name)))
		elseif typeof(scopes) ~= "table" then
			warnFunc(("%s: ignored %s > '%s' (scope list is not a table, but a %s)"):format(methodName, prefix, name, typeof(scopes)))
		elseif #name == 0 then
			warnFunc(("%s: ignored %s > '%s' (name is an empty string)"):format(methodName, prefix, name))
		elseif #name > MAX_LENGTH_NAME then
			warnFunc(("%s: ignored %s > '%s' (name exceeds %d character limit)"):format(methodName, prefix, name, MAX_LENGTH_NAME))
		else
			for scope, data in pairs(scopes) do
				if typeof(scope) ~= "string" then
					warnFunc(("%s: ignored %s > '%s' > '%s' (scope is not a string, but a %s)"):format(methodName, prefix, name, tostring(scope), typeof(scope)))
				elseif typeof(data) ~= "table" then
					warnFunc(("%s: ignored %s > '%s' > '%s' (data list is not a table, but a %s)"):format(methodName, prefix, name, scope, typeof(data)))
				elseif #scope == 0 then
					warnFunc(("%s: ignored %s > '%s' > '%s' (scope is an empty string)"):format(methodName, prefix, name, scope))
				elseif #scope > MAX_LENGTH_SCOPE then
					warnFunc(("%s: ignored %s > '%s' > '%s' (scope exceeds %d character limit)"):format(methodName, prefix, name, scope, MAX_LENGTH_SCOPE))
				else
					if not destination[name] then
						destination[name] = {}
					end
					if not destination[name][scope] then
						destination[name][scope] = {}
					end
					importPairsFromTable(data, destination[name][scope], warnFunc, methodName, ("%s > '%s' > '%s'"):format(prefix, name, scope), isOrdered)
				end
			end
		end
	end
end

---

local DataStore = {}
DataStore.__index = DataStore

function DataStore:OnUpdate(key, callback)
	if typeof(key) ~= "string" then
		error("bad argument #1 to 'OnUpdate' (string expected, got " .. typeof(key) .. ")", 2)
	elseif typeof(callback) ~= "function" then
		error("bad argument #2 to 'OnUpdate' (function expected, got " .. typeof(callback) .. ")", 2)
	elseif #key == 0 then
		error("bad argument #1 to 'OnUpdate' (key name can't be empty)", 2)
	elseif #key > MAX_LENGTH_KEY then
		error("bad argument #1 to 'OnUpdate' (key name exceeds " .. MAX_LENGTH_KEY .. " character limit)", 2)
	end
	
	return self.__event.Event:connect(function(k, v)
		if k == key then
			if YIELD_TIME_UPDATE_MAX > 0 then
				wait(rand:NextNumber(YIELD_TIME_UPDATE_MIN, YIELD_TIME_UPDATE_MAX))
			end
			callback(deepcopy(v))
		end
	end)
	
end

function DataStore:GetAsync(key)
	if typeof(key) ~= "string" then
		error("bad argument #1 to 'GetAsync' (string expected, got " .. typeof(key) .. ")", 2)
	elseif #key == 0 then
		error("bad argument #1 to 'GetAsync' (key name can't be empty)", 2)
	elseif #key > MAX_LENGTH_KEY then
		error("bad argument #1 to 'GetAsync' (key name exceeds " .. MAX_LENGTH_KEY .. " character limit)", 2)
	end
	
	local retValue = deepcopy(self.__data[key])
	
	if YIELD_TIME_MAX > 0 then
		wait(rand:NextNumber(YIELD_TIME_MIN, YIELD_TIME_MAX))
	end
	
	return retValue
	
end

function DataStore:IncrementAsync(key, delta)
	if typeof(key) ~= "string" then
		error("bad argument #1 to 'IncrementAsync' (string expected, got " .. typeof(key) .. ")", 2)
	elseif delta ~= nil and typeof(delta) ~= "number" then
		error("bad argument #2 to 'IncrementAsync' (number expected, got " .. typeof(delta) .. ")", 2)
	elseif #key == 0 then
		error("bad argument #1 to 'IncrementAsync' (key name can't be empty)", 2)
	elseif #key > MAX_LENGTH_KEY then
		error("bad argument #1 to 'IncrementAsync' (key name exceeds " .. MAX_LENGTH_KEY .. " character limit)", 2)
	end
	
	local old = self.__data[key]
	
	if old ~= nil and (typeof(old) ~= "number" or old%1 ~= 0) then
		if YIELD_TIME_MAX > 0 then
			wait(rand:NextNumber(YIELD_TIME_MIN, YIELD_TIME_MAX))
		end
		error("IncrementAsync rejected with error: cannot increment non-integer value", 2)
	end
	
	delta = delta and math.floor(delta + .5) or 1
	
	self.__data[key] = (old or 0) + delta
	
	if old == nil or delta ~= 0 then
		self.__event:Fire(key, self.__data[key])
	end
	
	local retValue = self.__data[key]
	
	if YIELD_TIME_MAX > 0 then
		wait(rand:NextNumber(YIELD_TIME_MIN, YIELD_TIME_MAX))
	end
	
	return retValue
	
end

function DataStore:RemoveAsync(key)
	if typeof(key) ~= "string" then
		error("bad argument #1 to 'RemoveAsync' (string expected, got " .. typeof(key) .. ")", 2)
	elseif #key == 0 then
		error("bad argument #1 to 'RemoveAsync' (key name can't be empty)", 2)
	elseif #key > MAX_LENGTH_KEY then
		error("bad argument #1 to 'RemoveAsync' (key name exceeds " .. MAX_LENGTH_KEY .. " character limit)", 2)
	end
	
	local value = deepcopy(self.__data[key])
	self.__data[key] = nil
	
	if value ~= nil then
		self.__event:Fire(key, nil)
	end
	
	if YIELD_TIME_MAX > 0 then
		wait(rand:NextNumber(YIELD_TIME_MIN, YIELD_TIME_MAX))
	end
	
	return value
	
end

function DataStore:SetAsync(key, value)
	if typeof(key) ~= "string" then
		error("bad argument #1 to 'SetAsync' (string expected, got " .. typeof(key) .. ")", 2)
	elseif #key == 0 then
		error("bad argument #1 to 'SetAsync' (key name can't be empty)", 2)
	elseif #key > MAX_LENGTH_KEY then
		error("bad argument #1 to 'SetAsync' (key name exceeds " .. MAX_LENGTH_KEY .. " character limit)", 2)
	elseif value == nil or type(value) == "function" or type(value) == "userdata" or type(value) == "thread" then
		error("bad argument #2 to 'SetAsync' (cannot store values of type " .. typeof(value) .. ")", 2)
	end
	
	if typeof(value) == "table" then
		local isValid, keyPath, reason = scanValidity(value)
		if not isValid then
			error("bad argument #2 to 'SetAsync' (table has invalid entry at <" .. getStringPath(keyPath) .. ">: " .. reason .. ")", 2)
		end
		local pass, content = pcall(function() return HttpService:JSONEncode(value) end)
		if not pass then
			error("bad argument #2 to 'SetAsync' (table could not be encoded to json)", 2)
		elseif #content > MAX_LENGTH_DATA then
			error("bad argument #2 to 'SetAsync' (encoded data length exceeds " .. MAX_LENGTH_DATA .. " character limit)", 2)
		end
	elseif typeof(value) == "string" then
		if #value > MAX_LENGTH_DATA then
			error("bad argument #2 to 'SetAsync' (data length exceeds " .. MAX_LENGTH_DATA .. " character limit)", 2)
		end
	end
	
	if typeof(value) == "table" or value ~= self.__data[key] then
		self.__data[key] = deepcopy(value)
		self.__event:Fire(key, self.__data[key])
	end
	
	if YIELD_TIME_MAX > 0 then
		wait(rand:NextNumber(YIELD_TIME_MIN, YIELD_TIME_MAX))
	end
	
end

function DataStore:UpdateAsync(key, transformFunction)
	if typeof(key) ~= "string" then
		error("bad argument #1 to 'UpdateAsync' (string expected, got " .. typeof(key) .. ")", 2)
	elseif typeof(transformFunction) ~= "function" then
		error("bad argument #2 to 'UpdateAsync' (function expected, got " .. typeof(transformFunction) .. ")", 2)
	elseif #key == 0 then
		error("bad argument #1 to 'UpdateAsync' (key name can't be empty)", 2)
	elseif #key > MAX_LENGTH_KEY then
		error("bad argument #1 to 'UpdateAsync' (key name exceeds " .. MAX_LENGTH_KEY .. " character limit)", 2)
	end
	
	local value = transformFunction(deepcopy(self.__data[key]))
	
	if value == nil or type(value) == "function" or type(value) == "userdata" or type(value) == "thread" then
		error("bad argument #2 to 'UpdateAsync' (resulting value is of type " .. typeof(value) .. " that cannot be stored)", 2)
	end 
	
	if typeof(value) == "table" then
		local isValid, keyPath, reason = scanValidity(value)
		if not isValid then
			error("bad argument #2 to 'UpdateAsync' (resulting table has invalid entry at <" .. getStringPath(keyPath) .. ">: " .. reason .. ")", 2)
		end
		local pass, content = pcall(function() return HttpService:JSONEncode(value) end)
		if not pass then
			error("bad argument #2 to 'UpdateAsync' (resulting table could not be encoded to json)", 2)
		elseif #content > MAX_LENGTH_DATA then
			error("bad argument #2 to 'UpdateAsync' (resulting encoded data length exceeds " .. MAX_LENGTH_DATA .. " character limit)", 2)
		end
	elseif typeof(value) == "string" then
		if #value > MAX_LENGTH_DATA then
			error("bad argument #2 to 'UpdateAsync' (resulting data length exceeds " .. MAX_LENGTH_DATA .. " character limit)", 2)
		end
	end
	
	if typeof(value) == "table" or value ~= self.__data[key] then
		self.__data[key] = deepcopy(value)
		self.__event:Fire(key, self.__data[key])
	end
	
	local retValue = deepcopy(value)
	
	if YIELD_TIME_MAX > 0 then
		wait(rand:NextNumber(YIELD_TIME_MIN, YIELD_TIME_MAX))
	end
	
	return retValue
	
end

function DataStore:ExportToJSON()
	return HttpService:JSONEncode(self.__data)
end

function DataStore:ImportFromJSON(json, verbose)
	
	local content
	
	if typeof(json) == "string" then
		local parsed, value = pcall(function() return HttpService:JSONDecode(json) end)
		if not parsed then
			error("bad argument #1 to 'ImportFromJSON' (string is not valid json)", 2)
		end
		content = value
	elseif typeof(json) == "table" then
		content = deepcopy(json)
	else
		error("bad argument #1 to 'ImportFromJSON' (string or table expected, got " .. typeof(json) .. ")", 2)
	end
	
	if verbose ~= nil and typeof(verbose) ~= "boolean" then
		error("bad argument #2 to 'ImportFromJSON' (boolean expected, got " .. typeof(verbose) .. ")", 2)
	end
	
	importPairsFromTable(
		content,
		self.__data,
		(verbose == false and function() end or warn),
		"ImportFromJSON",
		((typeof(self.__name) == "string" and typeof(self.__scope) == "string")
			and ("DataStore > %s > %s"):format(self.__name, self.__scope)
			or "GlobalDataStore"),
		false
	)
	
end

---

local OrderedDataStore = {}
OrderedDataStore.__index = OrderedDataStore

function OrderedDataStore:OnUpdate(key, callback)
	if typeof(key) ~= "string" then
		error("bad argument #1 to 'OnUpdate' (string expected, got " .. typeof(key) .. ")", 2)
	elseif typeof(callback) ~= "function" then
		error("bad argument #2 to 'OnUpdate' (function expected, got " .. typeof(callback) .. ")", 2)
	elseif #key == 0 then
		error("bad argument #1 to 'OnUpdate' (key name can't be empty)", 2)
	elseif #key > MAX_LENGTH_KEY then
		error("bad argument #1 to 'OnUpdate' (key name exceeds " .. MAX_LENGTH_KEY .. " character limit)", 2)
	end
	
	return self.__event.Event:connect(function(k, v)
		if k == key then
			if YIELD_TIME_UPDATE_MAX > 0 then
				wait(rand:NextNumber(YIELD_TIME_UPDATE_MIN, YIELD_TIME_UPDATE_MAX))
			end
			callback(deepcopy(v))
		end
	end)
	
end

function OrderedDataStore:GetAsync(key)
	if typeof(key) ~= "string" then
		error("bad argument #1 to 'GetAsync' (string expected, got " .. typeof(key) .. ")", 2)
	elseif #key == 0 then
		error("bad argument #1 to 'GetAsync' (key name can't be empty)", 2)
	elseif #key > MAX_LENGTH_KEY then
		error("bad argument #1 to 'GetAsync' (key name exceeds " .. MAX_LENGTH_KEY .. " character limit)", 2)
	end
	
	local retValue = self.__data[key]
	
	if YIELD_TIME_MAX > 0 then
		wait(rand:NextNumber(YIELD_TIME_MIN, YIELD_TIME_MAX))
	end
	
	return retValue
	
end

function OrderedDataStore:IncrementAsync(key, delta)
	if typeof(key) ~= "string" then
		error("bad argument #1 to 'IncrementAsync' (string expected, got " .. typeof(key) .. ")", 2)
	elseif delta ~= nil and typeof(delta) ~= "number" then
		error("bad argument #2 to 'IncrementAsync' (number expected, got " .. typeof(delta) .. ")", 2)
	elseif #key == 0 then
		error("bad argument #1 to 'IncrementAsync' (key name can't be empty)", 2)
	elseif #key > MAX_LENGTH_KEY then
		error("bad argument #1 to 'IncrementAsync' (key name exceeds " .. MAX_LENGTH_KEY .. " character limit)", 2)
	end
	
	local old = self.__data[key]
	
	if old ~= nil and (typeof(old) ~= "number" or old%1 ~= 0) then
		if YIELD_TIME_MAX > 0 then
			wait(rand:NextNumber(YIELD_TIME_MIN, YIELD_TIME_MAX))
		end
		error("IncrementAsync rejected with error: cannot increment non-integer value", 2)
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
	
	local retValue = self.__data[key]
	
	if YIELD_TIME_MAX > 0 then
		wait(rand:NextNumber(YIELD_TIME_MIN, YIELD_TIME_MAX))
	end
	
	return retValue
	
end

function OrderedDataStore:RemoveAsync(key)
	if typeof(key) ~= "string" then
		error("bad argument #1 to 'RemoveAsync' (string expected, got " .. typeof(key) .. ")", 2)
	elseif #key == 0 then
		error("bad argument #1 to 'RemoveAsync' (key name can't be empty)", 2)
	elseif #key > MAX_LENGTH_KEY then
		error("bad argument #1 to 'RemoveAsync' (key name exceeds " .. MAX_LENGTH_KEY .. " character limit)", 2)
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
	
	if YIELD_TIME_MAX > 0 then
		wait(rand:NextNumber(YIELD_TIME_MIN, YIELD_TIME_MAX))
	end
	
	return value
	
end

function OrderedDataStore:SetAsync(key, value)
	if typeof(key) ~= "string" then
		error("bad argument #1 to 'SetAsync' (string expected, got " .. typeof(key) .. ")", 2)
	elseif #key == 0 then
		error("bad argument #1 to 'SetAsync' (key name can't be empty)", 2)
	elseif #key > MAX_LENGTH_KEY then
		error("bad argument #1 to 'SetAsync' (key name exceeds " .. MAX_LENGTH_KEY .. " character limit)", 2)
	elseif typeof(value) ~= "number" then
		error("bad argument #2 to 'SetAsync' (number expected, got " .. typeof(value) .. ")", 2)
	elseif value%1 ~= 0 then
		error("bad argument #2 to 'SetAsync' (cannot store non-integer values in OrderedDataStore)", 2)
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
	
	if YIELD_TIME_MAX > 0 then
		wait(rand:NextNumber(YIELD_TIME_MIN, YIELD_TIME_MAX))
	end
	
	return value
	
end

function OrderedDataStore:UpdateAsync(key, transformFunction)
	if typeof(key) ~= "string" then
		error("bad argument #1 to 'UpdateAsync' (string expected, got " .. typeof(key) .. ")", 2)
	elseif typeof(transformFunction) ~= "function" then
		error("bad argument #2 to 'UpdateAsync' (function expected, got " .. typeof(transformFunction) .. ")", 2)
	elseif #key == 0 then
		error("bad argument #1 to 'UpdateAsync' (key name can't be empty)", 2)
	elseif #key > MAX_LENGTH_KEY then
		error("bad argument #1 to 'UpdateAsync' (key name exceeds " .. MAX_LENGTH_KEY .. " character limit)", 2)
	end
	
	local value = transformFunction(self.__data[key])
	
	if type(value) ~= "number" or value%1 ~= 0 then
		error("bad argument #2 to 'UpdateAsync' (resulting value is a non-integer which can't be stored in OrderedDataStore)", 2)
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
	
	if YIELD_TIME_MAX > 0 then
		wait(rand:NextNumber(YIELD_TIME_MIN, YIELD_TIME_MAX))
	end
	
	return value
	
end

local DataStorePages = {}
DataStorePages.__index = DataStorePages

function DataStorePages:GetCurrentPage()
	local retValue = {}
	for i = math.max(1, (self.__currentpage - 1) * self.__pagesize + 1), math.min(self.__currentpage * self.__pagesize, #self.__results) do
		table.insert(retValue, self.__results[i])
	end
	return retValue
end

function DataStorePages:AdvanceToNextPageAsync()
	
	if self.IsFinished then
		return
	end
	
	self.__currentpage = self.__currentpage + 1
	self.IsFinished = #self.__results <= self.__currentpage * self.__pagesize
	
	if YIELD_TIME_MAX > 0 then
		wait(rand:NextNumber(YIELD_TIME_MIN, YIELD_TIME_MAX))
	end
	
end

function OrderedDataStore:GetSortedAsync(ascending, pagesize, minValue, maxValue)
	if typeof(ascending) ~= "boolean" then
		error("bad argument #1 to 'GetSortedAsync' (boolean expected, got " .. typeof(ascending) .. ")", 2)
	elseif typeof(pagesize) ~= "number" then
		error("bad argument #2 to 'GetSortedAsync' (number expected, got " .. typeof(pagesize) .. ")", 2)
	end
	
	pagesize = math.floor(pagesize + .5)
	if pagesize <= 0 or pagesize > MAX_PAGE_SIZE then
		error("bad argument #2 to 'GetSortedAsync' (page size must be an integer above 0 and below " .. MAX_PAGE_SIZE .. ")", 2)
	end
	
	if minValue ~= nil then
		if typeof(minValue) ~= "number" then
			error("bad argument #3 to 'GetSortedAsync' (number expected, got " .. typeof(minValue) .. ")", 2)
		elseif minValue%1 ~= 0 then
			error("bad argument #3 to 'GetSortedAsync' (minimum threshold must be an integer)", 2)
		end
	else
		minValue = -math.huge
	end
	
	if maxValue ~= nil then
		if typeof(maxValue) ~= "number" then
			error("bad argument #4 to 'GetSortedAsync' (number expected, got " .. typeof(maxValue) .. ")", 2)
		elseif maxValue%1 ~= 0 then
			error("bad argument #4 to 'GetSortedAsync' (maximum threshold must be an integer)", 2)
		end
	else
		maxValue = math.huge
	end
	
	if minValue > maxValue then
		if YIELD_TIME_MAX > 0 then
			wait(rand:NextNumber(YIELD_TIME_MIN, YIELD_TIME_MAX))
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
	
	if YIELD_TIME_MAX > 0 then
		wait(rand:NextNumber(YIELD_TIME_MIN, YIELD_TIME_MAX))
	end
	
	return setmetatable({
		__currentpage = 1;
		__pagesize = pagesize;
		__results = results;
		IsFinished = (#results <= pagesize);
	}, DataStorePages)
	
end

function OrderedDataStore:ExportToJSON()
	return HttpService:JSONEncode(self.__data)
end

function OrderedDataStore:ImportFromJSON(json, verbose)
	
	local content
	
	if typeof(json) == "string" then
		local parsed, value = pcall(function() return HttpService:JSONDecode(json) end)
		if not parsed then
			error("bad argument #1 to 'ImportFromJSON' (string is not valid json)", 2)
		end
		content = value
	elseif typeof(json) == "table" then
		content = json
	else
		error("bad argument #1 to 'ImportFromJSON' (string or table expected, got " .. typeof(json) .. ")", 2)
	end
	
	importPairsFromTable(
		content,
		self.__data,
		(verbose == false and function() end or warn),
		"ImportFromJSON",
		("OrderedDataStore > %s > %s"):format(self.__name, self.__scope),
		true
	)
	
end

---

local MockDataStoreService = {}

local function makeGetWrapper(methodName, getObject, isGlobal)
	return function(_, name, scope)
		if not game:GetService("RunService"):IsServer() then
			error("DataStore can't be accessed from client", 2)
		end
		
		if isGlobal then
			return getObject()
		else
			if typeof(name) ~= "string" then
				error("bad argument #1 to '" .. methodName .. "' (string expected, got " .. typeof(name) .. ")", 2)
			elseif scope ~= nil and typeof(scope) ~= "string" then
				error("bad argument #2 to '" .. methodName .. "' (string expected, got " .. typeof(scope) .. ")", 2)
			elseif #name == 0 then
				error("bad argument #1 to '" .. methodName .. "' (name can't be empty string)", 2)
			elseif #name > MAX_LENGTH_NAME then
				error("bad argument #1 to '" .. methodName .. "' (name exceeds " .. MAX_LENGTH_NAME .. " character limit)", 2)
			elseif scope and #scope == 0 then
				error("bad argument #2 to '" .. methodName .. "' (scope can't be empty string)", 2)
			elseif scope and #scope > MAX_LENGTH_SCOPE then
				error("bad argument #2 to '" .. methodName .. "' (scope exceeds " .. MAX_LENGTH_SCOPE .. " character limit)", 2)
			end
			return getObject(name, scope or "global")
		end
		
	end
end

MockDataStoreService.GetDataStore = makeGetWrapper(
	"GetDataStore",
	function(name, scope)
		if not Data.DataStore[name] then
			Data.DataStore[name] = {}
		end
		if not Data.DataStore[name][scope] then
			Data.DataStore[name][scope] = {}
		end
		if not Interfaces[Data.DataStore[name][scope]] then
			local value = {
				__name = name;
				__scope = scope;
				__data = Data.DataStore[name][scope];
				__event = Instance.new("BindableEvent");
			}
			value.__event.Event:connect(function() end)
			Interfaces[Data.DataStore[name][scope]] = setmetatable(value, DataStore)
		end
		return Interfaces[Data.DataStore[name][scope]]
	end
)

MockDataStoreService.GetGlobalDataStore = makeGetWrapper(
	"GetGlobalDataStore",
	function()
		if not Interfaces[Data.GlobalDataStore] then
			local value = {
				__data = Data.GlobalDataStore;
				__event = Instance.new("BindableEvent");
			}
			value.__event.Event:connect(function() end)
			Interfaces[Data.GlobalDataStore] = setmetatable(value, DataStore)
		end
		return Interfaces[Data.GlobalDataStore]
	end,
	true
)

MockDataStoreService.GetOrderedDataStore = makeGetWrapper(
	"GetOrderedDataStore",
	function(name, scope)
		if not Data.OrderedDataStore[name] then
			Data.OrderedDataStore[name] = {}
		end
		if not Data.OrderedDataStore[name][scope] then
			Data.OrderedDataStore[name][scope] = {}
		end
		if not Interfaces[Data.OrderedDataStore[name][scope]] then
			local value = {
				__name = name;
				__scope = scope;
				__data = Data.OrderedDataStore[name][scope];
				__sorted = {};
				__ref = {};
				__changed = false;
				__event = Instance.new("BindableEvent");
			}
			value.__event.Event:connect(function() end)
			Interfaces[Data.OrderedDataStore[name][scope]] = setmetatable(value, OrderedDataStore)
		end
		return Interfaces[Data.OrderedDataStore[name][scope]]
	end
)

local budgetMapping = {
	[Enum.DataStoreRequestType.GetAsync] = 60;
	[Enum.DataStoreRequestType.GetSortedAsync] = 5;
	[Enum.DataStoreRequestType.OnUpdate] = 30;
	[Enum.DataStoreRequestType.SetIncrementAsync] = 60;
	[Enum.DataStoreRequestType.SetIncrementSortedAsync] = 60;
	[Enum.DataStoreRequestType.UpdateAsync] = 60;
	Default = 50;
}

function MockDataStoreService:GetRequestBudgetForRequestType(requestType)
	
	if typeof(requestType) ~= "EnumItem" or requestType.EnumType ~= Enum.DataStoreRequestType then
		error("bad argument #1 to 'GetRequestBudgetForRequestType' (DataStoreRequestType expected, got " .. typeof(requestType) .. ")", 2)
	end
	
	return budgetMapping[requestType] or budgetMapping.Default
	
end

function MockDataStoreService:ExportToJSON()
	
	local orderedData = {}
	local numOrdered = 0
	for name, scopes in pairs(Data.OrderedDataStore) do
		local numScopes = 0
		local exportScopes = {}
		for scope, data in pairs(scopes) do
			local numKeys = 0
			local exportData = {}
			for key, value in pairs(data) do
				exportData[key] = value
				numKeys = numKeys + 1
			end
			if numKeys > 0 then
				exportScopes[scope] = exportData
				numScopes = numScopes + 1
			end
		end
		if numScopes > 0 then
			orderedData[name] = exportScopes
			numOrdered = numOrdered + 1
		end
	end
	
	local regularData = {}
	local numRegular = 0
	for name, scopes in pairs(Data.DataStore) do
		local numScopes = 0
		local exportScopes = {}
		for scope, data in pairs(scopes) do
			local numKeys = 0
			local exportData = {}
			for key, value in pairs(data) do
				exportData[key] = value
				numKeys = numKeys + 1
			end
			if numKeys > 0 then
				exportScopes[scope] = exportData
				numScopes = numScopes + 1
			end
		end
		if numScopes > 0 then
			regularData[name] = exportScopes
			numRegular = numRegular + 1
		end
	end
	
	local globalHasItems = false
	for _, _ in pairs(Data.GlobalDataStore) do
		globalHasItems = true
		break
	end
	
	local export = {}
	
	if globalHasItems then
		export.GlobalDataStore = Data.GlobalDataStore
	end
	if numOrdered > 0 then
		export.OrderedDataStore = orderedData
	end
	if numRegular > 0 then
		export.DataStore = regularData
	end
	
	return HttpService:JSONEncode(export)
	
end

function MockDataStoreService:ImportFromJSON(json, verbose)
	
	local content
	
	if typeof(json) == "string" then
		local parsed, value = pcall(function() return HttpService:JSONDecode(json) end)
		if not parsed then
			error("bad argument #1 to 'ImportFromJSON' (string is not valid json)", 2)
		end
		content = value
	elseif typeof(json) == "table" then
		content = deepcopy(json)
	else
		error("bad argument #1 to 'ImportFromJSON' (string or table expected, got " .. typeof(json) .. ")", 2)
	end
	
	local warnFunc = warn
	if verbose == false then
		warnFunc = function() end
	end
	
	if typeof(content.GlobalDataStore) == "table" then
		importPairsFromTable(content.GlobalDataStore, Data.GlobalDataStore, warnFunc, "ImportFromJSON", "GlobalDataStore", false)
	end
	
	if typeof(content.DataStore) == "table" then
		importDataStoresFromTable(content.DataStore, Data.DataStore, warnFunc, "ImportFromJSON", "DataStore", false)
	end
	
	if typeof(content.OrderedDataStore) == "table" then
		importDataStoresFromTable(content.OrderedDataStore, Data.OrderedDataStore, warnFunc, "ImportFromJSON", "OrderedDataStore", true)
	end
	
end

---

return MockDataStoreService
