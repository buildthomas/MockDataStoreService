return function()

    local MockDataStoreService = require(script.Parent)
    local MockDataStoreManager = require(script.Parent.Parent.Parent.DataStoreService.MockDataStoreService.MockDataStoreManager)

    local function reset()
        MockDataStoreManager:ResetData()
        MockDataStoreManager:ResetBudget()
    end

    describe("MockOrderedDataStore", function()

        it("should expose all API members", function()
            local MockOrderedDataStore = MockDataStoreService:GetOrderedDataStore("Test", "Test")
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