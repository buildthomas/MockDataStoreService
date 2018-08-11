--[[	MockDataStorePages.lua
		This module implements the API and functionality of Roblox's DataStorePages class.

		This module is licensed under APLv2, refer to the LICENSE file or:
		https://github.com/buildthomas/MockDataStoreService/blob/master/LICENSE
]]

local DataStorePages = {}
DataStorePages.__index = DataStorePages

local Manager = require(script.Parent.MockDataStoreManager)
local Constants = require(script.Parent.MockDataStoreConstants)

local rand = Random.new()

function DataStorePages:GetCurrentPage()
	local retValue = {}

	local minimumIndex = math.max(1, (self.__currentpage - 1) * self.__pagesize + 1)
	local maximumIndex = math.min(self.__currentpage * self.__pagesize, #self.__results)
	for i = minimumIndex, maximumIndex do
		table.insert(retValue, self.__results[i]) -- No need to deepcopy, results only contains numbers
	end

	return retValue
end

function DataStorePages:AdvanceToNextPageAsync()
	if self.IsFinished then
		return
	end

	self.__currentpage = self.__currentpage + 1
	self.IsFinished = #self.__results <= self.__currentpage * self.__pagesize

	if Constants.YIELD_TIME_MAX > 0 then
		wait(rand:NextNumber(Constants.YIELD_TIME_MIN, Constants.YIELD_TIME_MAX))
	end
end

return DataStorePages