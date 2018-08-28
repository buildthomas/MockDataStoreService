return function()

    local MockDataStoreService = require(script.Parent)
    local MockDataStoreManager = require(script.Parent.Parent.Parent.DataStoreService.MockDataStoreService.MockDataStoreManager)
    local HttpService = game:GetService("HttpService")

    local function reset()
        MockDataStoreManager:ResetData()
        MockDataStoreManager:ResetBudget()
        MockDataStoreManager:ThawBudgetUpdates()
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

        it("should return nil for non-existing keys", function()
            
        end)

        it("should return the value for existing keys", function()
            
        end)

        it("should consume budgets correctly", function()
            
        end)

        it("should throttle requests correctly when out of budget", function()
        
        end)

        it("should throw for invalid input", function()
        
        end)

        it("should set the get-cache", function()
            
        end)

    end)

    describe("MockOrderedDataStore::IncrementAsync", function()

        it("should increment keys", function()
            
        end)

        it("should increment non-existing keys", function()
            
        end)

        it("should increment by the correct value", function()
            
        end)

        it("should return the incremented value", function()
            
        end)

        it("should consume budgets correctly", function()
            
        end)

        it("should throttle requests correctly when out of budget", function()
        
        end)

        it("should throttle requests to respect write cooldown", function()
            
        end)

        it("should set the get-cache", function()
            
        end)

    end)

    describe("MockOrderedDataStore::RemoveAsync", function()

        it("should be able to remove existing keys", function()
            
        end)

        it("should be able to remove non-existing keys", function()
            
        end)

        it("should return the old value", function()
            
        end)

        it("should consume budgets correctly", function()
            
        end)

        it("should throttle requests correctly when out of budget", function()
        
        end)

        it("should throttle requests to respect write cooldown", function()
            
        end)

        it("should throw for invalid input", function()
        
        end)

        it("should not set the get-cache", function()
            
        end)

    end)

    describe("MockOrderedDataStore::SetAsync", function()

        it("should set keys if value is valid", function()
            
        end)

        it("should not return anything", function()
            
        end)

        it("should consume budgets correctly", function()
            
        end)

        it("should throttle requests correctly when out of budget", function()
        
        end)

        it("should throttle requests to respect write cooldown", function()
            
        end)

        it("should throw for invalid input", function()
        
        end)

        it("should throw at attempts to store invalid data", function()
            
        end)

        it("should not set the get-cache", function()
            
        end)

    end)

    describe("MockOrderedDataStore::UpdateAsync", function()

        it("should update keys correctly", function()
            
        end)

        it("should return the updated value", function()
            
        end)

        it("should consume budgets correctly", function()
            
        end)

        it("should throttle requests correctly when out of budget", function()
        
        end)

        it("should throttle requests to respect write cooldown", function()
            
        end)

        it("should throw for invalid input", function()
        
        end)

        it("should throw at attempts to store invalid data", function()
            
        end)

        it("should set the get-cache", function()
            
        end)

    end)

    describe("MockOrderedDataStore::OnUpdate", function()

        it("should return a RBXScriptConnection", function()
            
        end)

        it("should allow disconnecting", function()
            
        end)

        it("should only receives updates for its connected key", function()
            
        end)

        it("should work with SetAsync", function()
            
        end)

        it("should work with UpdateAsync", function()
            
        end)

        it("should work with RemoveAsync", function()
            
        end)

        it("should work with IncrementAsync", function()
            
        end)

        it("should consume budgets correctly", function()
            
        end)

        it("should throttle requests correctly when out of budget", function()
        
        end)

        it("should throw for invalid input", function()
        
        end)

    end)

    describe("MockOrderedDataStore::GetSortedAsync", function()

        it("should return a MockDataStorePages object", function()
            
        end)

        it("should consume budgets correctly", function()
            
        end)

        it("should throttle requests correctly when out of budget", function()
        
        end)

        it("should throw for invalid input", function()
        
        end)

    end)

    describe("MockOrderedDataStore::ImportFromJSON", function()

        it("should import keys correctly", function()
            reset()

            local MockGlobalDataStore = MockDataStoreService:GetOrderedDataStore("Test", "Test")

            expect(function()
                MockGlobalDataStore:ImportFromJSON({
                    TestKey1 = 1;
                    TestKey2 = 2;
                    TestKey3 = 3;
                }, false)
            end).never.to.throw()

        end)

        it("should contain all imported values afterwards", function()
            reset()

            local MockGlobalDataStore = MockDataStoreService:GetOrderedDataStore("Test", "Test")

            local data = {}
            for i = 1, 100 do
                data["TestKey"..i] = i
            end

            MockGlobalDataStore:ImportFromJSON(data, false)

            local store = MockDataStoreManager:GetOrderedData(data)
            for i = 1, 100 do
                expect(store["TestKey"..i]).to.equal(i)
            end

        end)

        it("should fire OnUpdate signals", function()
        
        end)

        it("should ignore invalid values and keys", function()
            reset()

            local MockGlobalDataStore = MockDataStoreService:GetOrderedDataStore("Test", "Test")

            local data = {
                TestKey1 = 1;
                TestKey2 = true;
                TestKey3 = "Test";
                TestKey4 = {1,2,3,4};
                TestKey5 = 5;
                TestKey6 = 6;
                [true] = 7;
                TestKey8 = Instance.new("Frame");
                TestKey9 = math.huge;
                TestKey10 = -math.huge;
                TestKey11 = 11;
            }

            MockGlobalDataStore:ImportFromJSON(data, false)

            local store = MockDataStoreManager:GetOrderedData(data)
            expect(store.TestKey1).to.equal(1)
            expect(store.TestKey2).to.never.be.ok()
            expect(store.TestKey3).to.never.be.ok()
            expect(store.TestKey4).to.never.be.ok()
            expect(store.TestKey5).to.equal(5)
            expect(store.TestKey6).to.equal(6)
            expect(store[true]).to.never.be.ok()
            expect(store.TestKey8).to.never.be.ok()
            expect(store.TestKey9).to.never.be.ok()
            expect(store.TestKey10).to.never.be.ok()
            expect(store.TestKey11).to.equal(11)

        end)

        it("should throw for invalid input", function()
            reset()

            local MockGlobalDataStore = MockDataStoreService:GetOrderedDataStore("Test", "Test")

            expect(function()
                MockGlobalDataStore:ImportFromJSON("{this is invalid json}", false)
            end).to.throw()

            expect(function()
                MockGlobalDataStore:ImportFromJSON(123, false)
            end).to.throw()

            expect(function()
                MockGlobalDataStore:ImportFromJSON({}, 123)
            end).to.throw()

            expect(function()
                MockGlobalDataStore:ImportFromJSON("{}", 123)
            end).to.throw()

        end)

    end)

    describe("MockOrderedDataStore::ExportToJSON", function()

        it("should return valid json", function()
            reset()

            local MockGlobalDataStore = MockDataStoreService:GetOrderedDataStore("Test", "Test")

            MockGlobalDataStore:ImportFromJSON({
                TestKey1 = 1;
                TestKey2 = 2;
                TestKey3 = 3;
            }, false)

            local json = MockDataStoreService:ExportToJSON()

            expect(function()
                MockGlobalDataStore:JSONDecode(json)
            end).never.to.throw()

        end)

        it("should export all keys", function()
            reset()

            local MockGlobalDataStore = MockDataStoreService:GetOrderedDataStore("Test", "Test")

            local data = {}
            for i = 1, 100 do
                data["TestKey"..i] = i
            end

            MockGlobalDataStore:ImportFromJSON(data, false)

            local exported = HttpService:JSONDecode(MockGlobalDataStore:ExportToJSON())
            for i = 1, 100 do
                expect(exported["TestKey"..i]).to.equal(i)
            end

        end)

    end)

end