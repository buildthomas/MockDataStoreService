return function()

    local function getDataStoreService()
        local MockDataStoreService = script.Parent.Parent.Parent.DataStoreService.MockDataStoreService:Clone()
        local Constants = require(MockDataStoreService.MockDataStoreConstants)
        Constants.YIELD_TIME_MIN = 0.01
        Constants.YIELD_TIME_MAX = 0.02
        Constants.YIELD_TIME_UPDATE_MIN = 0.04
        Constants.YIELD_TIME_UPDATE_MAX = 0.08
        return require(MockDataStoreService)
    end

    describe("MockDataStorePages", function()

        it("should expose all API members", function()
            local MockOrderedDataStore = getDataStoreService():GetOrderedDataStore("Test", "Test")
            local MockDataStorePages = MockOrderedDataStore:GetSortedAsync(true, 100)
            expect(MockDataStorePages.AdvanceToNextPageAsync).to.be.a("function")
            expect(MockDataStorePages.IsFinished).to.be.a("boolean")
        end)

    end)

    describe("MockDataStorePages::AdvanceToNextPageAsync", function()

        it("should get all results", function()
            local MockOrderedDataStore = getDataStoreService():GetOrderedDataStore("Test", "Test")

        end)

        it("should report correctly ordered results", function()
            
        end)

        it("should not exceed page size for each page of results", function()
            
        end)

        it("should not report results out of range", function()
            
        end)

        it("should throw when no more pages left", function()
            
        end)

    end)

end