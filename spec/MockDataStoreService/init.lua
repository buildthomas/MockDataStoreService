local function getDataStoreService()
    local MockDataStoreService = script.Parent.Parent.DataStoreService.MockDataStoreService
    local Constants = require(MockDataStoreService.MockDataStoreConstants)
    Constants.YIELD_TIME_MIN = 0
    Constants.YIELD_TIME_MAX = 0
    Constants.YIELD_TIME_UPDATE_MIN = 0
    Constants.YIELD_TIME_UPDATE_MAX = 0
    return require(MockDataStoreService)
end

return getDataStoreService()