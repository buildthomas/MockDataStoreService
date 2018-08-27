return function()

    local MockDataStoreService = require(script.Parent)
    local MockDataStoreManager = require(script.Parent.Parent.Parent.DataStoreService.MockDataStoreService.MockDataStoreManager)

    local function reset()
        MockDataStoreManager:ResetData()
        MockDataStoreManager:ResetBudget()
    end

    describe("MockDataStorePages", function()

        it("should expose all API members", function()
            local MockOrderedDataStore = MockDataStoreService:GetOrderedDataStore("TestExposesMembers")
            local MockDataStorePages = MockOrderedDataStore:GetSortedAsync(true, 100)
            expect(MockDataStorePages.AdvanceToNextPageAsync).to.be.a("function")
            expect(MockDataStorePages.IsFinished).to.be.a("boolean")
        end)

    end)

    describe("MockDataStorePages::AdvanceToNextPageAsync", function()

        it("should get all results", function()
            local MockOrderedDataStore = MockDataStoreService:GetOrderedDataStore("TestAllResults")

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