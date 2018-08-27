return function()

    local MockDataStoreService = require(script.Parent)
    local MockDataStoreManager = require(script.Parent.Parent.Parent.DataStoreService.MockDataStoreService.MockDataStoreManager)

    local function reset()
        MockDataStoreManager:ResetData()
        MockDataStoreManager:ResetBudget()
    end

    describe("MockGlobalDataStore", function()

        it("should expose all API members", function()
            local MockGlobalDataStore = MockDataStoreService:GetOrderedDataStore("Test", "Test")
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