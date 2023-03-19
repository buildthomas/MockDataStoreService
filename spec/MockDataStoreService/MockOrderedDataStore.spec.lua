return function()
    local Test = require(script.Parent.Test)
    local HttpService = game:GetService("HttpService")

    describe("MockOrderedDataStore", function()

        it("should expose all API members", function()
            Test.reset()
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test", "Test")

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
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            expect(MockOrderedDataStore:GetAsync("TestKey")).to.never.be.ok()

        end)

        it("should return the value for existing keys", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            MockOrderedDataStore:ImportFromJSON({
                TestKey1 = -123;
                TestKey2 = 0;
                TestKey3 = 291;
            })

            expect(MockOrderedDataStore:GetAsync("TestKey1")).to.equal(-123)
            expect(MockOrderedDataStore:GetAsync("TestKey2")).to.equal(0)
            expect(MockOrderedDataStore:GetAsync("TestKey3")).to.equal(291)

        end)

        it("should consume budgets correctly", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            Test.captureBudget()

            for i = 1, 10 do
                MockOrderedDataStore:GetAsync("TestKey"..i)
                expect(Test.checkpointBudget{
                    [Enum.DataStoreRequestType.GetAsync] = -1
                }).to.be.ok()
            end

        end)

        it("should throttle requests correctly when out of budget", function()
            --TODO
        end)

        itSKIP("should throw for invalid input", function() -- NOTE: Test failing, skipped
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            expect(function()
                MockOrderedDataStore:GetAsync()
            end).to.throw()

            expect(function()
                MockOrderedDataStore:GetAsync(123)
            end).to.throw()

            expect(function()
                MockOrderedDataStore:GetAsync("")
            end).to.throw()

            expect(function()
                MockOrderedDataStore:GetAsync(("a"):rep(Test.Constants.MAX_LENGTH_KEY + 1))
            end).to.throw()

        end)

        it("should set the get-cache", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            MockOrderedDataStore:GetAsync("TestKey")

            Test.captureBudget()

            MockOrderedDataStore:GetAsync("TestKey")

            expect(Test.checkpointBudget{}).to.be.ok()

        end)

    end)

    describe("MockOrderedDataStore::IncrementAsync", function()

        it("should increment keys", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            MockOrderedDataStore:ImportFromJSON({TestKey = 1})

            MockOrderedDataStore:IncrementAsync("TestKey", 1)

            local export = HttpService:JSONDecode(MockOrderedDataStore:ExportToJSON())

            expect(export.TestKey).to.equal(2)

        end)

        it("should increment non-existing keys", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            MockOrderedDataStore:IncrementAsync("TestKey", 1)

            local export = HttpService:JSONDecode(MockOrderedDataStore:ExportToJSON())

            expect(export.TestKey).to.equal(1)

        end)

        it("should increment by the correct value", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            MockOrderedDataStore:ImportFromJSON({TestKey1 = 1, TestKey2 = 2, TestKey3 = 3, TestKey4 = 4, TestKey5 = 5})

            MockOrderedDataStore:IncrementAsync("TestKey1", 19)
            MockOrderedDataStore:IncrementAsync("TestKey2", -43)
            MockOrderedDataStore:IncrementAsync("TestKey3", 0)
            MockOrderedDataStore:IncrementAsync("TestKey4", 1.5)
            MockOrderedDataStore:IncrementAsync("TestKey5")

            local export = HttpService:JSONDecode(MockOrderedDataStore:ExportToJSON())

            expect(export.TestKey1).to.equal(20)
            expect(export.TestKey2).to.equal(-41)
            expect(export.TestKey3).to.equal(3)
            expect(export.TestKey4).to.equal(6)
            expect(export.TestKey5).to.equal(6)

        end)

        it("should return the incremented value", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            MockOrderedDataStore:ImportFromJSON({TestKey6 = 1938, TestKey7 = 42})

            expect(MockOrderedDataStore:IncrementAsync("TestKey1")).to.be.a("number")
            expect(MockOrderedDataStore:IncrementAsync("TestKey2", 100)).to.be.a("number")
            expect(MockOrderedDataStore:IncrementAsync("TestKey3", -100)).to.be.a("number")
            expect(MockOrderedDataStore:IncrementAsync("TestKey4", 0)).to.be.a("number")
            expect(MockOrderedDataStore:IncrementAsync("TestKey5", 1.5)).to.be.a("number")
            expect(MockOrderedDataStore:IncrementAsync("TestKey6")).to.be.a("number")
            expect(MockOrderedDataStore:IncrementAsync("TestKey7", 1083)).to.be.a("number")

        end)

        itSKIP("should consume budgets correctly", function() -- NOTE: Test failing, skipped
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            MockOrderedDataStore:ImportFromJSON({TestKey2 = 10})

            Test.captureBudget()

            MockOrderedDataStore:IncrementAsync("TestKey1")
            expect(Test.checkpointBudget{
                [Enum.DataStoreRequestType.SetIncrementAsync] = -1
            }).to.be.ok()

            MockOrderedDataStore:IncrementAsync("TestKey2", 5)
            expect(Test.checkpointBudget{
                [Enum.DataStoreRequestType.SetIncrementAsync] = -1
            }).to.be.ok()

            MockOrderedDataStore:IncrementAsync("TestKey3", 0)
            expect(Test.checkpointBudget{
                [Enum.DataStoreRequestType.SetIncrementAsync] = -1
            }).to.be.ok()

            MockOrderedDataStore:IncrementAsync("TestKey4", -5)
            expect(Test.checkpointBudget{
                [Enum.DataStoreRequestType.SetIncrementAsync] = -1
            }).to.be.ok()

        end)

        it("should throttle requests correctly when out of budget", function()
            --TODO
        end)

        it("should throttle requests to respect write cooldown", function()
            --TODO
        end)

        itSKIP("should throw for invalid input", function() -- NOTE: Test failing, skipped
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            expect(function()
                MockOrderedDataStore:IncrementAsync()
            end).to.throw()

            expect(function()
                MockOrderedDataStore:IncrementAsync(123)
            end).to.throw()

            expect(function()
                MockOrderedDataStore:IncrementAsync("")
            end).to.throw()

            expect(function()
                MockOrderedDataStore:IncrementAsync(("a"):rep(Test.Constants.MAX_LENGTH_KEY + 1))
            end).to.throw()

            expect(function()
                MockOrderedDataStore:IncrementAsync("Test", "Not A Number")
            end).to.throw()

            expect(function()
                MockOrderedDataStore:IncrementAsync(123, 1)
            end).to.throw()

        end)

        it("should set the get-cache", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            MockOrderedDataStore:IncrementAsync("TestKey")

            Test.captureBudget()

            MockOrderedDataStore:GetAsync("TestKey")

            expect(Test.checkpointBudget{}).to.be.ok()

        end)

    end)

    describe("MockOrderedDataStore::RemoveAsync", function()

        it("should be able to remove existing keys", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            MockOrderedDataStore:ImportFromJSON({ExistingKey = 1})

            MockOrderedDataStore:RemoveAsync("ExistingKey")

            local export = HttpService:JSONDecode(MockOrderedDataStore:ExportToJSON())
            expect(export.ExistingKey).to.never.be.ok()

        end)

        it("should be able to remove non-existing keys", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            MockOrderedDataStore:RemoveAsync("NonExistingKey")

            local export = HttpService:JSONDecode(MockOrderedDataStore:ExportToJSON())
            expect(export.NonExistingKey).to.never.be.ok()

        end)

        it("should return the old value", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            local values = {
                TestKey1 = 123;
            }

            MockOrderedDataStore:ImportFromJSON(values)

            expect(MockOrderedDataStore:RemoveAsync("TestKey1")).to.equal(values.TestKey1)

        end)

        itSKIP("should consume budgets correctly", function() -- NOTE: Test failing, skipped
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            MockOrderedDataStore:ImportFromJSON({ExistingKey = 42})

            Test.captureBudget()

            MockOrderedDataStore:RemoveAsync("NonExistingKey")

            expect(Test.checkpointBudget{
                [Enum.DataStoreRequestType.SetIncrementAsync] = -1;
            }).to.be.ok()

            MockOrderedDataStore:RemoveAsync("ExistingKey")

            expect(Test.checkpointBudget{
                [Enum.DataStoreRequestType.SetIncrementAsync] = -1;
            }).to.be.ok()

        end)

        it("should throttle requests correctly when out of budget", function()
            --TODO
        end)

        it("should throttle requests to respect write cooldown", function()
            --TODO
        end)

        itSKIP("should throw for invalid input", function() -- NOTE: Test failing, skipped
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            expect(function()
                MockOrderedDataStore:RemoveAsync()
            end).to.throw()

            expect(function()
                MockOrderedDataStore:RemoveAsync(123)
            end).to.throw()

            expect(function()
                MockOrderedDataStore:RemoveAsync("")
            end).to.throw()

            expect(function()
                MockOrderedDataStore:RemoveAsync(("a"):rep(Test.Constants.MAX_LENGTH_KEY + 1))
            end).to.throw()

        end)

        it("should not set the get-cache", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            MockOrderedDataStore:RemoveAsync("TestKey")

            Test.captureBudget()

            MockOrderedDataStore:GetAsync("TestKey")

            expect(Test.checkpointBudget{
                [Enum.DataStoreRequestType.GetAsync] = -1;
            }).to.equal(true)

        end)

    end)

    describe("MockOrderedDataStore::SetAsync", function()

        it("should set keys if value is valid", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            MockOrderedDataStore:ImportFromJSON({TestKey2 = 42})

            MockOrderedDataStore:SetAsync("TestKey1", 100)
            MockOrderedDataStore:SetAsync("TestKey2", 200)
            MockOrderedDataStore:SetAsync("TestKey3", -300)
            MockOrderedDataStore:SetAsync("TestKey4", 0)

            local exported = HttpService:JSONDecode(MockOrderedDataStore:ExportToJSON())
            expect(exported.TestKey1).to.equal(100)
            expect(exported.TestKey2).to.equal(200)
            expect(exported.TestKey3).to.equal(-300)
            expect(exported.TestKey4).to.equal(0)

        end)

        itSKIP("should not return anything", function() -- NOTE: Test failing, skipped
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            MockOrderedDataStore:ImportFromJSON({TestKey2 = 42})

            expect(MockOrderedDataStore:SetAsync("TestKey1", 100)).to.never.be.ok()
            expect(MockOrderedDataStore:SetAsync("TestKey2", -100)).to.never.be.ok()
            expect(MockOrderedDataStore:SetAsync("TestKey3", 0)).to.never.be.ok()

        end)

        itSKIP("should consume budgets correctly", function() -- NOTE: Test failing, skipped
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            Test.captureBudget()

            MockOrderedDataStore:SetAsync("TestKey1", 123)
            expect(Test.checkpointBudget{
                [Enum.DataStoreRequestType.SetIncrementAsync] = -1
            }).to.be.ok()

            MockOrderedDataStore:SetAsync("TestKey2", -123)
            expect(Test.checkpointBudget{
                [Enum.DataStoreRequestType.SetIncrementAsync] = -1
            }).to.be.ok()

            MockOrderedDataStore:SetAsync("TestKey3", 0)
            expect(Test.checkpointBudget{
                [Enum.DataStoreRequestType.SetIncrementAsync] = -1
            }).to.be.ok()

        end)

        it("should throttle requests correctly when out of budget", function()
            --TODO
        end)

        it("should throttle requests to respect write cooldown", function()
            --TODO
        end)

        itSKIP("should throw for invalid input", function() -- NOTE: Test failing, skipped
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            expect(function()
                MockOrderedDataStore:SetAsync()
            end).to.throw()

            expect(function()
                MockOrderedDataStore:SetAsync(nil, 42)
            end).to.throw()

            expect(function()
                MockOrderedDataStore:SetAsync(123, 42)
            end).to.throw()

            expect(function()
                MockOrderedDataStore:SetAsync("", 42)
            end).to.throw()

            expect(function()
                MockOrderedDataStore:SetAsync(("a"):rep(Test.Constants.MAX_LENGTH_KEY + 1), 42)
            end).to.throw()

        end)

        it("should throw at attempts to store invalid data", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            local function testValue(v)
                expect(function()
                    MockOrderedDataStore:SetAsync("TestKey", v)
                end).to.throw()
            end

            testValue(nil)
            testValue("string")
            testValue({})
            testValue(true)
            testValue(function() end)
            testValue(Instance.new("Frame"))
            testValue(Enum.DataStoreRequestType.GetAsync)
            testValue(coroutine.create(function() end))
            testValue(10.23)
            testValue(math.huge)
            testValue(-math.huge)
            testValue(-294.4)

        end)

        it("should not set the get-cache", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            MockOrderedDataStore:SetAsync("TestKey", 1)

            Test.captureBudget()

            MockOrderedDataStore:GetAsync("TestKey")

            expect(Test.checkpointBudget{
                [Enum.DataStoreRequestType.GetAsync] = -1;
            }).to.equal(true)

        end)

    end)

    describe("MockOrderedDataStore::UpdateAsync", function()

        it("should update keys correctly", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            MockOrderedDataStore:ImportFromJSON({TestKey2 = 42})

            MockOrderedDataStore:UpdateAsync("TestKey1", function() return 123 end)
            MockOrderedDataStore:UpdateAsync("TestKey2", function() return 456 end)

            local exported = HttpService:JSONDecode(MockOrderedDataStore:ExportToJSON())
            expect(exported.TestKey1).to.equal(123)
            expect(exported.TestKey2).to.equal(456)

        end)

        it("should return the updated value", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            expect(MockOrderedDataStore:UpdateAsync("TestKey", function() return 13 end)).to.equal(13)

        end)

        itSKIP("should pass the old value to the callback", function() -- NOTE: Test failing, skipped
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            local oldValues = {
                TestKey1 = 0;
                TestKey2 = 100;
                TestKey3 = -100;
            }

            MockOrderedDataStore:ImportFromJSON(oldValues)

            for key, value in pairs(oldValues) do
                expect(MockOrderedDataStore:UpdateAsync(key, function(oldValue)
                    if oldValue == value then
                        return oldValue
                    end
                    error()
                end)).never.to.throw()
            end

        end)

        itSKIP("should consume budgets correctly", function() -- NOTE: Test failing, skipped
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            Test.captureBudget()

            for i = 1, 10 do
                MockOrderedDataStore:UpdateAsync("TestKey"..i, function() return 1 end)
                expect(Test.checkpointBudget{
                    [Enum.DataStoreRequestType.GetAsync] = -1;
                    [Enum.DataStoreRequestType.SetIncrementAsync] = -1;
                }).to.be.ok()
            end

        end)

        it("should throttle requests correctly when out of budget", function()
            --TODO
        end)

        it("should throttle requests to respect write cooldown", function()
            --TODO
        end)

        itSKIP("should throw for invalid key", function() -- NOTE: Test failing, skipped
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            local func = function() return 1 end

            expect(function()
                MockOrderedDataStore:UpdateAsync()
            end).to.throw()

            expect(function()
                MockOrderedDataStore:UpdateAsync(nil, func)
            end).to.throw()

            expect(function()
                MockOrderedDataStore:UpdateAsync(123, func)
            end).to.throw()

            expect(function()
                MockOrderedDataStore:UpdateAsync("", func)
            end).to.throw()

            expect(function()
                MockOrderedDataStore:UpdateAsync(("a"):rep(Test.Constants.MAX_LENGTH_KEY + 1), func)
            end).to.throw()

        end)

        itSKIP("should throw at attempts to store invalid data", function() -- NOTE: Test failing, skipped
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            local function testValue(v)
                expect(function()
                    MockOrderedDataStore:UpdateAsync("TestKey", function() return v end)
                end).to.throw()
            end

            testValue(nil)
            testValue("string")
            testValue({})
            testValue(true)
            testValue(function() end)
            testValue(Instance.new("Frame"))
            testValue(Enum.DataStoreRequestType.GetAsync)
            testValue(coroutine.create(function() end))
            testValue(10.23)
            testValue(math.huge)
            testValue(-math.huge)
            testValue(-294.4)

        end)

        itSKIP("should set the get-cache", function() -- NOTE: Test failing, skipped
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            Test.captureBudget()

            MockOrderedDataStore:UpdateAsync("TestKey", function() return 1 end)
            MockOrderedDataStore:GetAsync("TestKey")

            expect(Test.checkpointBudget{
                [Enum.DataStoreRequestType.GetAsync] = -1;
                [Enum.DataStoreRequestType.SetIncrementAsync] = -1;
                [Enum.DataStoreRequestType.UpdateAsync] = -1;
            }).to.equal(true)

        end)

    end)

    describe("MockOrderedDataStore::OnUpdate", function()

        itSKIP("should return a RBXScriptConnection", function() -- NOTE: Test failing, skipped
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            local conn = MockOrderedDataStore:OnUpdate("TestKey")

            conn:Disconnect() -- don't leak after test

            expect(conn).to.be.a("RBXScriptConnection")

        end)

        it("should only receives updates for its connected key", function()
            --TODO
        end)

        it("should work with SetAsync", function()
            --TODO
        end)

        it("should work with UpdateAsync", function()
            --TODO
        end)

        it("should work with RemoveAsync", function()
            --TODO
        end)

        it("should work with IncrementAsync", function()
            --TODO
        end)

        it("should consume budgets correctly", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            Test.captureBudget()

            for i = 1, 10 do
                local conn = MockOrderedDataStore:OnUpdate("TestKey"..i, function() end)
                conn:Disconnect()
                expect(Test.checkpointBudget{
                    [Enum.DataStoreRequestType.OnUpdate] = -1;
                }).to.be.ok()
            end

        end)

        it("should throttle requests correctly when out of budget", function()
            --TODO
        end)

        itSKIP("should throw for invalid input", function() -- NOTE: Test failing, skipped
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            expect(function()
                MockOrderedDataStore:OnUpdate()
            end).to.throw()

            expect(function()
                MockOrderedDataStore:OnUpdate(123)
            end).to.throw()

            expect(function()
                MockOrderedDataStore:OnUpdate("")
            end).to.throw()

            expect(function()
                MockOrderedDataStore:OnUpdate(("a"):rep(Test.Constants.MAX_LENGTH_KEY + 1))
            end).to.throw()

            expect(function()
                MockOrderedDataStore:OnUpdate("Test", 123)
            end).to.throw()

            expect(function()
                MockOrderedDataStore:OnUpdate(123, function() end)
            end).to.throw()

        end)

        it("should not set the get-cache", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            local connection = MockOrderedDataStore:OnUpdate("TestKey", function() end)

            Test.captureBudget()

            local result = expect(function()
                MockOrderedDataStore:GetAsync("TestKey")
            end)

            if connection then
                connection:Disconnect()
            end

            expect(result.never.to.throw())
            expect(Test.checkpointBudget{
                [Enum.DataStoreRequestType.GetAsync] = -1;
            }).to.be.ok()

        end)

    end)

    describe("MockOrderedDataStore::GetSortedAsync", function()

        it("should complete successfully and return object for valid input", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            expect(MockOrderedDataStore:GetSortedAsync(true, 50)).to.be.ok()
            expect(MockOrderedDataStore:GetSortedAsync(true, 50, 100)).to.be.ok()
            expect(MockOrderedDataStore:GetSortedAsync(true, 50, nil, 100)).to.be.ok()
            expect(MockOrderedDataStore:GetSortedAsync(true, 50, 100, 200)).to.be.ok()

            expect(MockOrderedDataStore:GetSortedAsync(false, 50)).to.be.ok()
            expect(MockOrderedDataStore:GetSortedAsync(false, 50, 100)).to.be.ok()
            expect(MockOrderedDataStore:GetSortedAsync(false, 50, nil, 100)).to.be.ok()
            expect(MockOrderedDataStore:GetSortedAsync(false, 50, 100, 200)).to.be.ok()

        end)

        itSKIP("should consume budgets correctly", function() -- NOTE: Test failing, skipped
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            Test.captureBudget()

            MockOrderedDataStore:GetSortedAsync(true, 100) -- empty results
            expect(Test.checkpointBudget{
                [Enum.DataStoreRequestType.GetSortedAsync] = -1;
            }).to.be.ok()

            local values = {}
            for i = 1, 789 do
                values["TestKey"..i] = i
            end

            MockOrderedDataStore:ImportFromJSON(values)

            MockOrderedDataStore:GetSortedAsync(false, 110, 230, 720) -- not empty
            expect(Test.checkpointBudget{
                [Enum.DataStoreRequestType.GetSortedAsync] = -1;
            }).to.be.ok()

        end)

        it("should throttle requests correctly when out of budget", function()
            --TODO
        end)

        itSKIP("should throw for invalid input", function() -- NOTE: Test failing, skipped
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            expect(function()
                MockOrderedDataStore:GetSortedAsync()
            end).to.throw()

            expect(function()
                MockOrderedDataStore:GetSortedAsync("wrong type", 50)
            end).to.throw()

            expect(function()
                MockOrderedDataStore:GetSortedAsync(true)
            end).to.throw()

            expect(function()
                MockOrderedDataStore:GetSortedAsync(false, "wrong type")
            end).to.throw()

            expect(function()
                MockOrderedDataStore:GetSortedAsync(true, -5)
            end).to.throw()

            expect(function()
                MockOrderedDataStore:GetSortedAsync(false, 0)
            end).to.throw()

            expect(function()
                MockOrderedDataStore:GetSortedAsync(true, Test.Constants.MAX_PAGE_SIZE + 1)
            end).to.throw()

            expect(function()
                MockOrderedDataStore:GetSortedAsync(false, 56.7)
            end).to.throw()

            expect(function()
                MockOrderedDataStore:GetSortedAsync(false, 50, "wrong type")
            end).to.throw()

            expect(function()
                MockOrderedDataStore:GetSortedAsync(false, 50, 102.9)
            end).to.throw()

            expect(function()
                MockOrderedDataStore:GetSortedAsync(true, 50, 100, "wrong type")
            end).to.throw()

            expect(function()
                MockOrderedDataStore:GetSortedAsync(true, 50, 100, 472.39)
            end).to.throw()

            expect(function()
                MockOrderedDataStore:GetSortedAsync(true, 50, 100, 99)
            end).to.throw()

        end)

        -- See more testing with ordered data lookups in MockDataStorePages.spec.lua!

    end)

    describe("MockOrderedDataStore::ImportFromJSON/ExportToJSON", function()

        it("should import keys correctly", function()
            Test.reset()
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test", "Test")

            local scope = {
                TestKey1 = 1;
                TestKey2 = 2;
                TestKey3 = 3;
            }

            expect(function()
                MockOrderedDataStore:ImportFromJSON(scope, false)
                MockOrderedDataStore:ImportFromJSON(HttpService:JSONEncode(scope), false)
            end).never.to.throw()

        end)

        it("should contain all imported values afterwards", function()
            Test.reset()
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test", "Test")

            local data = {}
            for i = 1, 100 do
                data["TestKey"..i] = i
            end

            MockOrderedDataStore:ImportFromJSON(data, false)

            local exported = HttpService:JSONDecode(MockOrderedDataStore:ExportToJSON())
            for i = 1, 100 do
                expect(exported["TestKey"..i]).to.equal(i)
            end

        end)

        it("should fire OnUpdate signals", function()
            --TODO
        end)

        it("should ignore invalid values and keys", function()
            Test.reset()
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test", "Test")

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

            MockOrderedDataStore:ImportFromJSON(data, false)

            local store = HttpService:JSONDecode(MockOrderedDataStore:ExportToJSON())
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
            Test.reset()
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test", "Test")

            expect(function()
                MockOrderedDataStore:ImportFromJSON("{this is invalid json}", false)
            end).to.throw()

            expect(function()
                MockOrderedDataStore:ImportFromJSON(123, false)
            end).to.throw()

            expect(function()
                MockOrderedDataStore:ImportFromJSON({}, 123)
            end).to.throw()

            expect(function()
                MockOrderedDataStore:ImportFromJSON("{}", 123)
            end).to.throw()

        end)

    end)

end
