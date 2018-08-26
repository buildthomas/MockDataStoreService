return function()

    local function getDataStoreService()
        local MockDataStoreService = script.Parent.Parent.Parent.DataStoreService.MockDataStoreService
        local Constants = require(MockDataStoreService.MockDataStoreConstants)
        Constants.YIELD_TIME_MIN = 0.01
        Constants.YIELD_TIME_MAX = 0.02
        Constants.YIELD_TIME_UPDATE_MIN = 0.04
        Constants.YIELD_TIME_UPDATE_MAX = 0.08
        return require(MockDataStoreService)
    end

    describe("MockGlobalDataStore", function()

        it("should expose all API members", function()
            local MockGlobalDataStore = getDataStoreService():GetOrderedDataStore("Test", "Test")
            expect(MockGlobalDataStore.GetAsync).to.be.a("function")
            expect(MockGlobalDataStore.IncrementAsync).to.be.a("function")
            expect(MockGlobalDataStore.RemoveAsync).to.be.a("function")
            expect(MockGlobalDataStore.SetAsync).to.be.a("function")
            expect(MockGlobalDataStore.UpdateAsync).to.be.a("function")
            expect(MockGlobalDataStore.OnUpdate).to.be.a("function")
        end)

    end)

    describe("MockGlobalDataStore::GetAsync", function()

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

    end)

    describe("MockGlobalDataStore::IncrementAsync", function()

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

    end)

    describe("MockGlobalDataStore::RemoveAsync", function()

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

    end)

    describe("MockGlobalDataStore::SetAsync", function()

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

    end)

    describe("MockGlobalDataStore::UpdateAsync", function()

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

    end)

    describe("MockGlobalDataStore::OnUpdate", function()

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