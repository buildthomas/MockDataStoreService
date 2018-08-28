return function()

    local MockDataStoreService = require(script.Parent)
    local MockDataStoreManager = require(script.Parent.Parent.Parent.DataStoreService.MockDataStoreService.MockDataStoreManager)
    local HttpService = game:GetService("HttpService")

    local function reset()
        MockDataStoreManager:ResetData()
        MockDataStoreManager:ResetBudget()
        MockDataStoreManager:ThawBudgetUpdates()
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

        it("should return nil for non-existing keys", function()
            
        end)

        it("should return the value for existing keys", function()
            
        end)

        it("should not allow mutation of values through result", function()
            reset()
            
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

    describe("MockGlobalDataStore::IncrementAsync", function()

        it("should increment keys", function()
            
        end)

        it("should increment non-existing keys", function()
            
        end)

        it("should increment by the correct value", function()
            
        end)

        it("should return the incremented value", function()
            
        end)

        it("should throw when incrementing non-number key", function()
            
        end)

        it("should consume budgets correctly", function()
            
        end)

        it("should throttle requests correctly when out of budget", function()
            
        end)

        it("should throttle requests to respect write cooldown", function()
            
        end)

        it("should throw for invalid input", function()
            
        end)

        it("should set the get-cache", function()
            
        end)

    end)

    describe("MockGlobalDataStore::RemoveAsync", function()

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

    describe("MockGlobalDataStore::SetAsync", function()

        it("should set keys if value is valid", function()
            
        end)

        it("should not return anything", function()
            
        end)

        it("should not allow mutation of stored values indirectly", function()
            
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

    describe("MockGlobalDataStore::UpdateAsync", function()

        it("should update keys correctly", function()
            
        end)

        it("should return the updated value", function()
            
        end)

        it("should not allow mutation of stored values indirectly", function()
            
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

    describe("MockGlobalDataStore::OnUpdate", function()

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

        it("should not allow mutation of stored values indirectly", function()
            
        end)

        it("should consume budgets correctly", function()
            
        end)

        it("should throttle requests correctly when out of budget", function()
            
        end)

        it("should throw for invalid input", function()
            
        end)

    end)

    local testDataStores = {
        DataStores = {
            ImportTestName = {
                ImportTestScope = {
                    TestKey1 = true;
                    TestKey2 = "Hello world!";
                    TestKey3 = {First = 1, Second = 2, Third = 3};
                    TestKey4 = false;
                };
                ImportTestScope2 = {};
                ImportTestScope3 = {
                    TestKey1 = "Test string";
                    TestKey2 = {
                        First = {First = "Hello"};
                        Second = {First = true, Second = false};
                        Third = 3;
                        Fourth = {"One", 1, "Two", 2, "Three", {3, 4, 5, 6}, 7};
                    };
                    TestKey3 = 12345;
                };
            };
            ImportTestName2 = {};
        };
        OrderedDataStores = {
            ImportTestName = {
                ImportTestScope = {
                    TestKey1 = 1;
                    TestKey2 = 2;
                    TestKey3 = 3;
                };
                ImportTestScope2 = {
                    TestKey1 = 100;
                    TestKey2 = 12308;
                    TestKey3 = 1288;
                    TestKey4 = 1287;
                };
                ImportTestScope3 = {};
            };
            ImportTestName2 = {
                ImportTestScope = {};
            };
            ImportTestName3 = {};
        };
        GlobalDataStore = {
            TestImportKey1 = -5.1;
            TestImportKey2 = "Test string";
            TestImportKey3 = {};
        };
    }

    describe("MockGlobalDataStore::ImportFromJSON", function()

        it("should import keys correctly", function()
            
        end)

        it("should contain all imported values afterwards", function()
            
        end)

        it("should fire OnUpdate signals", function()
            
        end)

        it("should ignore invalid values and keys", function()
            
        end)

        it("should throw for invalid input", function()
            
        end)

    end)

    describe("MockGlobalDataStore::ExportToJSON", function()

        it("should return valid json", function()
            
        end)

        it("should export all keys", function()
            
        end)

    end)

end