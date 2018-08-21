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

    describe("MockOrderedDataStore", function()

        it("should expose all API members", function()
            local MockOrderedDataStore = getDataStoreService():GetOrderedDataStore("Test", "Test")
            expect(MockOrderedDataStore.GetAsync).to.be.a("function")
            expect(MockOrderedDataStore.IncrementAsync).to.be.a("function")
            expect(MockOrderedDataStore.RemoveAsync).to.be.a("function")
            expect(MockOrderedDataStore.SetAsync).to.be.a("function")
            expect(MockOrderedDataStore.UpdateAsync).to.be.a("function")
            expect(MockOrderedDataStore.OnUpdate).to.be.a("function")
            expect(MockOrderedDataStore.GetSortedAsync).to.be.a("function")
        end)

    end)

    describe("MockOrderedDataStore::GetAsync", function()

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

    end)

    describe("MockOrderedDataStore::IncrementAsync", function()

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

    end)

    describe("MockOrderedDataStore::RemoveAsync", function()

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

    end)

    describe("MockOrderedDataStore::SetAsync", function()

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

    end)

    describe("MockOrderedDataStore::UpdateAsync", function()

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

    end)

    describe("MockOrderedDataStore::OnUpdate", function()

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

    end)

    describe("MockOrderedDataStore::GetSortedAsync", function()

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

    end)

end