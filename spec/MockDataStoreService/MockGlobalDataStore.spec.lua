return function()

    local MockDataStoreService = require(script.Parent)
    local MockDataStoreManager = require(script.Parent.Parent.Parent.DataStoreService.MockDataStoreService.MockDataStoreManager)
    local Constants = require(script.Parent.Parent.Parent.DataStoreService.MockDataStoreService.MockDataStoreConstants)
    local HttpService = game:GetService("HttpService")

    local oldBudgets = {}

    local function reset()
        MockDataStoreManager:ResetData()
        MockDataStoreManager:ResetBudget()
        MockDataStoreManager:ThawBudgetUpdates()
    end

    local function capture()

    end

    local function difference()
        
    end

    describe("MockGlobalDataStore", function()

        it("should expose all API members", function()
            local MockGlobalDataStore = MockDataStoreService:GetDataStore("Test")
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
            reset()
            local MockGlobalDataStore = MockDataStoreService:GetDataStore("Test")

            expect(MockGlobalDataStore:GetAsync("TestKey")).to.never.be.ok()

        end)

        it("should return the value for existing keys", function()
            reset()
            MockDataStoreManager:FreezeBudgetUpdates()
            MockDataStoreManager:SetBudget(Enum.DataStoreRequestType.GetAsync, 1e9)
            local MockGlobalDataStore = MockDataStoreService:GetDataStore("Test")

            MockGlobalDataStore:ImportFromJSON({
                TestKey1 = 123;
                TestKey2 = "abc";
                TestKey3 = true;
                TestKey4 = false;
                TestKey5 = 5.6;
                TestKey6 = {a = 1, b = 2, c = {1,2,3}, d = 4};
            })

            expect(MockGlobalDataStore:GetAsync("TestKey1")).to.equal(123)
            expect(MockGlobalDataStore:GetAsync("TestKey2")).to.equal("abc")
            expect(MockGlobalDataStore:GetAsync("TestKey3")).to.equal(true)
            expect(MockGlobalDataStore:GetAsync("TestKey4")).to.equal(false)
            expect(MockGlobalDataStore:GetAsync("TestKey5")).to.equal(5.6)

            local key6 = MockGlobalDataStore:GetAsync("TestKey6")
            expect(key6).to.be.a("table")
            expect(key6.a).to.equal(1)
            expect(key6.b).to.equal(2)
            expect(key6.c).to.be.a("table")
            expect(#key6.c).to.equal(3)
            expect(key6.d).to.equal(4)

        end)

        it("should not allow mutation of stored values indirectly", function()
            reset()
            local MockGlobalDataStore = MockDataStoreService:GetDataStore("Test")

            MockGlobalDataStore:ImportFromJSON({
                TestKey = {a = 1, b = 2, c = {1,2,3}, d = 4};
            })

            local result = MockGlobalDataStore:GetAsync("TestKey")

            result.a = 500;
            result.c[2] = 1337;

            result = MockGlobalDataStore:GetAsync("TestKey")

            expect(result.a).to.equal(1)
            expect(result.c[2]).to.equal(2);

        end)

        it("should consume budgets correctly", function()
            reset()
            MockDataStoreManager:FreezeBudgetUpdates()
            MockDataStoreManager:SetBudget(Enum.DataStoreRequestType.GetAsync, 100)
            local MockGlobalDataStore = MockDataStoreService:GetDataStore("Test")

            for i = 1, 42 do
                MockGlobalDataStore:GetDataStore("TestKey"..i)
                expect(MockDataStoreManager:GetBudget(Enum.DataStoreRequestType.GetAsync)).to.equal(100-i)
            end

        end)

        it("should throttle requests correctly when out of budget", function()
            --TODO
        end)

        it("should throw for invalid input", function()
            reset()
            local MockGlobalDataStore = MockDataStoreService:GetDataStore("Test")

            expect(function()
                MockGlobalDataStore:GetAsync()
            end).to.throw()

            expect(function()
                MockGlobalDataStore:GetAsync(123)
            end).to.throw()

            expect(function()
                MockGlobalDataStore:GetAsync("")
            end).to.throw()

            expect(function()
                MockGlobalDataStore:GetAsync(("a"):rep(Constants.MAX_LENGTH_KEY + 1))
            end).to.throw()

        end)

        it("should set the get-cache", function()
            reset()
            MockDataStoreManager:FreezeBudgetUpdates()
            MockDataStoreManager:SetBudget(Enum.DataStoreRequestType.GetAsync, 2)
            local MockGlobalDataStore = MockDataStoreService:GetDataStore("Test")

            MockGlobalDataStore:GetAsync("TestKey")
            MockGlobalDataStore:GetAsync("TestKey")

            expect(MockDataStoreManager:GetBudget(Enum.DataStoreRequestType.GetAsync)).to.equal(1)

        end)

    end)

    describe("MockGlobalDataStore::IncrementAsync", function()

        it("should increment keys", function()
            reset()
            local MockGlobalDataStore = MockDataStoreService:GetDataStore("Test")

            MockGlobalDataStore:ImportFromJSON({TestKey = 1})

            MockGlobalDataStore:IncrementAsync("TestKey", 1)

            local export = HttpService:JSONDecode(MockGlobalDataStore:ExportToJSON())

            expect(export.TestKey).to.equal(2)

        end)

        it("should increment non-existing keys", function()
            reset()
            local MockGlobalDataStore = MockDataStoreService:GetDataStore("Test")

            MockGlobalDataStore:IncrementAsync("TestKey", 1)

            local export = HttpService:JSONDecode(MockGlobalDataStore:ExportToJSON())

            expect(export.TestKey).to.equal(1)

        end)

        it("should increment by the correct value", function()
            reset()
            local MockGlobalDataStore = MockDataStoreService:GetDataStore("Test")

            MockGlobalDataStore:ImportFromJSON({TestKey1 = 1, TestKey2 = 2, TestKey3 = 3, TestKey4 = 4, TestKey5 = 5})

            MockGlobalDataStore:IncrementAsync("TestKey1", 19)
            MockGlobalDataStore:IncrementAsync("TestKey2", -43)
            MockGlobalDataStore:IncrementAsync("TestKey3", 0)
            MockGlobalDataStore:IncrementAsync("TestKey4", 1.5)
            MockGlobalDataStore:IncrementAsync("TestKey5")

            local export = HttpService:JSONDecode(MockGlobalDataStore:ExportToJSON())

            expect(export.TestKey1).to.equal(20)
            expect(export.TestKey2).to.equal(-41)
            expect(export.TestKey3).to.equal(3)
            expect(export.TestKey4).to.equal(6)
            expect(export.TestKey5).to.equal(6)

        end)

        it("should return the incremented value", function()
            reset()
            local MockGlobalDataStore = MockDataStoreService:GetDataStore("Test")

            MockGlobalDataStore:ImportFromJSON({TestKey6 = 1938, TestKey7 = 42})

            expect(MockGlobalDataStore:IncrementAsync("TestKey1")).to.be.a("number")
            expect(MockGlobalDataStore:IncrementAsync("TestKey2", 100)).to.be.a("number")
            expect(MockGlobalDataStore:IncrementAsync("TestKey3", -100)).to.be.a("number")
            expect(MockGlobalDataStore:IncrementAsync("TestKey4", 0)).to.be.a("number")
            expect(MockGlobalDataStore:IncrementAsync("TestKey5", 1.5)).to.be.a("number")
            expect(MockGlobalDataStore:IncrementAsync("TestKey6")).to.be.a("number")
            expect(MockGlobalDataStore:IncrementAsync("TestKey7", 1083)).to.be.a("number")

        end)

        it("should throw when incrementing non-number key", function()
            reset()
            local MockGlobalDataStore = MockDataStoreService:GetDataStore("Test")

            MockGlobalDataStore:ImportFromJSON({TestKey1 = {}, TestKey2 = "Hello world!", TestKey3 = true})

            expect(function()
                MockGlobalDataStore:IncrementAsync("TestKey1")
            end).to.throw()

            expect(function()
                MockGlobalDataStore:IncrementAsync("TestKey2")
            end).to.throw()

            expect(function()
                MockGlobalDataStore:IncrementAsync("TestKey3")
            end).to.throw()

        end)

        it("should consume budgets correctly", function()
            reset()
            MockDataStoreManager:FreezeBudgetUpdates()
            MockDataStoreManager:SetBudget(Enum.DataStoreRequestType.GetAsync, 100)
            local MockGlobalDataStore = MockDataStoreService:GetDataStore("Test")

            for i = 1, 42 do
                MockGlobalDataStore:GetDataStore("TestKey"..i)
                expect(MockDataStoreManager:GetBudget(Enum.DataStoreRequestType.GetAsync)).to.equal(100-i)
            end

        end)

        it("should throttle requests correctly when out of budget", function()
            --TODO
        end)

        it("should throttle requests to respect write cooldown", function()
            --TODO
        end)

        it("should throw for invalid input", function()
            reset()
            local MockGlobalDataStore = MockDataStoreService:GetDataStore("Test")

            expect(function()
                MockGlobalDataStore:IncrementAsync()
            end).to.throw()

            expect(function()
                MockGlobalDataStore:IncrementAsync(123)
            end).to.throw()

            expect(function()
                MockGlobalDataStore:IncrementAsync("")
            end).to.throw()

            expect(function()
                MockGlobalDataStore:IncrementAsync(("a"):rep(Constants.MAX_LENGTH_KEY + 1))
            end).to.throw()

            expect(function()
                MockGlobalDataStore:IncrementAsync("Test", "Not A Number")
            end).to.throw()

            expect(function()
                MockGlobalDataStore:IncrementAsync(123, 1)
            end).to.throw()

        end)

        it("should set the get-cache", function()
            reset()
            MockDataStoreManager:FreezeBudgetUpdates()
            MockDataStoreManager:SetBudget(Enum.DataStoreRequestType.GetAsync, 2)
            local MockGlobalDataStore = MockDataStoreService:GetDataStore("Test")

            MockGlobalDataStore:IncrementAsync("TestKey")
            MockGlobalDataStore:GetAsync("TestKey")

            expect(MockDataStoreManager:GetBudget(Enum.DataStoreRequestType.GetAsync)).to.equal(2)

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
            --TODO
        end)

        it("should throttle requests to respect write cooldown", function()
            --TODO
        end)

        it("should throw for invalid input", function()
            reset()
            local MockGlobalDataStore = MockDataStoreService:GetDataStore("Test")

            expect(function()
                MockGlobalDataStore:GetAsync()
            end).to.throw()

            expect(function()
                MockGlobalDataStore:GetAsync(123)
            end).to.throw()

            expect(function()
                MockGlobalDataStore:GetAsync("")
            end).to.throw()

            expect(function()
                MockGlobalDataStore:GetAsync(("a"):rep(Constants.MAX_LENGTH_KEY + 1))
            end).to.throw()

        end)

        it("should not set the get-cache", function()
            reset()
            MockDataStoreManager:FreezeBudgetUpdates()
            MockDataStoreManager:SetBudget(Enum.DataStoreRequestType.GetAsync, 2)
            local MockGlobalDataStore = MockDataStoreService:GetDataStore("Test")

            MockGlobalDataStore:RemoveAsync("TestKey")
            MockGlobalDataStore:GetAsync("TestKey")

            expect(MockDataStoreManager:GetBudget(Enum.DataStoreRequestType.GetAsync)).to.equal(1)

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
            --TODO
        end)

        it("should throttle requests to respect write cooldown", function()
            --TODO
        end)

        it("should throw for invalid input", function()
            reset()
            local MockGlobalDataStore = MockDataStoreService:GetDataStore("Test")

            expect(function()
                MockGlobalDataStore:RemoveAsync()
            end).to.throw()

            expect(function()
                MockGlobalDataStore:RemoveAsync(123)
            end).to.throw()

            expect(function()
                MockGlobalDataStore:RemoveAsync("")
            end).to.throw()

            expect(function()
                MockGlobalDataStore:RemoveAsync(("a"):rep(Constants.MAX_LENGTH_KEY + 1))
            end).to.throw()

        end)

        it("should throw at attempts to store invalid data", function()
            
        end)

        it("should not set the get-cache", function()
            reset()
            MockDataStoreManager:FreezeBudgetUpdates()
            MockDataStoreManager:SetBudget(Enum.DataStoreRequestType.GetAsync, 2)
            local MockGlobalDataStore = MockDataStoreService:GetDataStore("Test")

            MockGlobalDataStore:SetAsync("TestKey", 1)
            MockGlobalDataStore:GetAsync("TestKey")

            expect(MockDataStoreManager:GetBudget(Enum.DataStoreRequestType.GetAsync)).to.equal(1)

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
            --TODO
        end)

        it("should throttle requests to respect write cooldown", function()
            --TODO
        end)

        it("should throw for invalid input", function()
            reset()
            local MockGlobalDataStore = MockDataStoreService:GetDataStore("Test")

            expect(function()
                MockGlobalDataStore:UpdateAsync()
            end).to.throw()

            expect(function()
                MockGlobalDataStore:UpdateAsync(123)
            end).to.throw()

            expect(function()
                MockGlobalDataStore:UpdateAsync("")
            end).to.throw()

            expect(function()
                MockGlobalDataStore:UpdateAsync(("a"):rep(Constants.MAX_LENGTH_KEY + 1))
            end).to.throw()

            expect(function()
                MockGlobalDataStore:UpdateAsync("Test", 123)
            end).to.throw()

            expect(function()
                MockGlobalDataStore:UpdateAsync(123, function() return 1 end)
            end).to.throw()

        end)

        it("should throw at attempts to store invalid data", function()
            
        end)

        it("should set the get-cache", function()
            reset()
            MockDataStoreManager:FreezeBudgetUpdates()
            MockDataStoreManager:SetBudget(Enum.DataStoreRequestType.GetAsync, 2)
            local MockGlobalDataStore = MockDataStoreService:GetDataStore("Test")

            MockGlobalDataStore:UpdateAsync("TestKey", function() return 1 end)
            MockGlobalDataStore:GetAsync("TestKey")

            expect(MockDataStoreManager:GetBudget(Enum.DataStoreRequestType.GetAsync)).to.equal(1)

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
            --TODO
        end)

        it("should throw for invalid input", function()
            reset()
            local MockGlobalDataStore = MockDataStoreService:GetDataStore("Test")

            expect(function()
                MockGlobalDataStore:OnUpdate()
            end).to.throw()

            expect(function()
                MockGlobalDataStore:OnUpdate(123)
            end).to.throw()

            expect(function()
                MockGlobalDataStore:OnUpdate("")
            end).to.throw()

            expect(function()
                MockGlobalDataStore:OnUpdate(("a"):rep(Constants.MAX_LENGTH_KEY + 1))
            end).to.throw()

            expect(function()
                MockGlobalDataStore:OnUpdate("Test", 123)
            end).to.throw()

            expect(function()
                MockGlobalDataStore:OnUpdate(123, function() end)
            end).to.throw()

        end)

        it("should not set the get-cache", function()
            reset()
            MockDataStoreManager:FreezeBudgetUpdates()
            MockDataStoreManager:SetBudget(Enum.DataStoreRequestType.GetAsync, 2)
            local MockGlobalDataStore = MockDataStoreService:GetDataStore("Test")

            local connection = MockGlobalDataStore:OnUpdate("TestKey", function() end)

            local result = expect(function()
                expect(MockDataStoreManager:GetBudget(Enum.DataStoreRequestType.GetAsync)).to.equal(2)
                MockGlobalDataStore:GetAsync("TestKey")
            end)

            if connection then
                connection:Disconnect()
            end

            expect(result.never.to.throw())

            expect(MockDataStoreManager:GetBudget(Enum.DataStoreRequestType.GetAsync)).to.equal(1)

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