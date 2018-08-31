return function()
    local Test = require(script.Parent.Test)
    local HttpService = game:GetService("HttpService")

    describe("MockGlobalDataStore", function()

        it("should expose all API members", function()
            Test.reset()
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

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
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            expect(MockGlobalDataStore:GetAsync("TestKey")).to.never.be.ok()

        end)

        it("should return the value for existing keys", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            local values = {
                TestKey1 = 123;
                TestKey2 = "abc";
                TestKey3 = true;
                TestKey4 = false;
                TestKey5 = 5.6;
                TestKey6 = {a = 1, b = 2, c = {1,2,3}, d = 4};
            }

            MockGlobalDataStore:ImportFromJSON(values)

            for key, value in pairs(values) do
                expect(Test.subsetOf(MockGlobalDataStore:GetAsync(key), value)).to.equal(true)
            end

        end)

        it("should not allow mutation of stored values indirectly", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

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
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            Test.captureBudget()

            for i = 1, 10 do
                MockGlobalDataStore:GetAsync("TestKey"..i)
                expect(Test.checkpointBudget{
                    [Enum.DataStoreRequestType.GetAsync] = -1
                }).to.be.ok()
            end

        end)

        it("should throttle requests correctly when out of budget", function()
            --TODO
        end)

        it("should throw for invalid input", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

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
                MockGlobalDataStore:GetAsync(("a"):rep(Test.Constants.MAX_LENGTH_KEY + 1))
            end).to.throw()

        end)

        it("should set the get-cache", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            MockGlobalDataStore:GetAsync("TestKey")

            Test.captureBudget()

            MockGlobalDataStore:GetAsync("TestKey")

            expect(Test.checkpointBudget{}).to.be.ok()

        end)

    end)

    describe("MockGlobalDataStore::IncrementAsync", function()

        it("should increment keys", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            MockGlobalDataStore:ImportFromJSON({TestKey = 1})

            MockGlobalDataStore:IncrementAsync("TestKey", 1)

            local export = HttpService:JSONDecode(MockGlobalDataStore:ExportToJSON())

            expect(export.TestKey).to.equal(2)

        end)

        it("should increment non-existing keys", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            MockGlobalDataStore:IncrementAsync("TestKey", 1)

            local export = HttpService:JSONDecode(MockGlobalDataStore:ExportToJSON())

            expect(export.TestKey).to.equal(1)

        end)

        it("should increment by the correct value", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

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
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

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
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

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
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            Test.captureBudget()

            MockGlobalDataStore:IncrementAsync("TestKey1")
            expect(Test.checkpointBudget{
                [Enum.DataStoreRequestType.SetIncrementAsync] = -1
            }).to.be.ok()

            MockGlobalDataStore:IncrementAsync("TestKey2", 5)
            expect(Test.checkpointBudget{
                [Enum.DataStoreRequestType.SetIncrementAsync] = -1
            }).to.be.ok()

            MockGlobalDataStore:IncrementAsync("TestKey3", 0)
            expect(Test.checkpointBudget{
                [Enum.DataStoreRequestType.SetIncrementAsync] = -1
            }).to.be.ok()

            MockGlobalDataStore:IncrementAsync("TestKey4", -5)
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

        it("should throw for invalid input", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

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
                MockGlobalDataStore:IncrementAsync(("a"):rep(Test.Constants.MAX_LENGTH_KEY + 1))
            end).to.throw()

            expect(function()
                MockGlobalDataStore:IncrementAsync("Test", "Not A Number")
            end).to.throw()

            expect(function()
                MockGlobalDataStore:IncrementAsync(123, 1)
            end).to.throw()

        end)

        it("should set the get-cache", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            MockGlobalDataStore:IncrementAsync("TestKey")

            Test.captureBudget()

            MockGlobalDataStore:GetAsync("TestKey")

            expect(Test.checkpointBudget{}).to.be.ok()

        end)

    end)

    describe("MockGlobalDataStore::RemoveAsync", function()

        it("should be able to remove existing keys", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            MockGlobalDataStore:ImportFromJSON({ExistingKey = "Hello world!"})

            MockGlobalDataStore:RemoveAsync("ExistingKey")

            local export = HttpService:JSONDecode(MockGlobalDataStore:ExportToJSON())
            expect(export.ExistingKey).to.never.be.ok()

        end)

        it("should be able to remove non-existing keys", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            MockGlobalDataStore:RemoveAsync("NonExistingKey")

            local export = HttpService:JSONDecode(MockGlobalDataStore:ExportToJSON())
            expect(export.NonExistingKey).to.never.be.ok()

        end)

        it("should return the old value", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            local values = {
                TestKey1 = "Hello world!";
                TestKey2 = 123;
                TestKey3 = false;
                TestKey4 = {1,2,3};
                TestKey5 = {A = {B = {}, C = 3}, D = 4, E = 5};
            }

            MockGlobalDataStore:ImportFromJSON(values)

            for key, value in pairs(values) do
                expect(Test.subsetOf(MockGlobalDataStore:RemoveAsync(key), value)).to.equal(true)
            end

        end)

        it("should consume budgets correctly", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            MockGlobalDataStore:ImportFromJSON({ExistingKey = "Hello world!"})

            Test.captureBudget()

            MockGlobalDataStore:RemoveAsync("NonExistingKey")

            expect(Test.checkpointBudget{
                [Enum.DataStoreRequestType.SetIncrementAsync] = -1;
            }).to.be.ok()

            MockGlobalDataStore:RemoveAsync("ExistingKey")

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

        it("should throw for invalid input", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

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
                MockGlobalDataStore:RemoveAsync(("a"):rep(Test.Constants.MAX_LENGTH_KEY + 1))
            end).to.throw()

        end)

        it("should not set the get-cache", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            MockGlobalDataStore:RemoveAsync("TestKey")

            Test.captureBudget()

            MockGlobalDataStore:GetAsync("TestKey")

            expect(Test.checkpointBudget{
                [Enum.DataStoreRequestType.GetAsync] = -1;
            }).to.be.ok()

        end)

    end)

    describe("MockGlobalDataStore::SetAsync", function()

        it("should set keys if value is valid", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            MockGlobalDataStore:ImportFromJSON({TestKey3 = "ThisShouldBeOverwritten", TestKey4 = "ThisToo"})

            MockGlobalDataStore:SetAsync("TestKey1", 123)
            MockGlobalDataStore:SetAsync("TestKey2", "abc")
            MockGlobalDataStore:SetAsync("TestKey3", {a = {1,2,3}, b = {c = 1, d = 2}, e = 3})
            MockGlobalDataStore:SetAsync("TestKey4", false)

            local exported = HttpService:JSONDecode(MockGlobalDataStore:ExportToJSON())
            expect(exported.TestKey1).to.equal(123)
            expect(exported.TestKey2).to.equal("abc")
            expect(exported.TestKey3).to.be.a("table")
            expect(exported.TestKey4).to.equal(false)

        end)

        it("should not return anything", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            MockGlobalDataStore:ImportFromJSON({TestKey2 = "test"})

            expect(MockGlobalDataStore:SetAsync("TestKey1", 123)).to.never.be.ok()
            expect(MockGlobalDataStore:SetAsync("TestKey2", false)).to.never.be.ok()
            expect(MockGlobalDataStore:SetAsync("TestKey3", "abc")).to.never.be.ok()
            expect(MockGlobalDataStore:SetAsync("TestKey4", {})).to.never.be.ok()

        end)

        it("should not allow mutation of stored values indirectly", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            local value = {a = {1,2,3}, b = {c = 1, d = 2}, e = 3}

            MockGlobalDataStore:SetAsync(value)

            value.a[1] = 1337
            value.e = "This should not be changed in the datastore"
            value.b.d = 42

            local exported = HttpService:JSONDecode(MockGlobalDataStore:ExportToJSON())

            expect(exported.a[1]).to.equal(1)
            expect(exported.e).to.equal(3)
            expect(exported.b.d).to.equal(2)

        end)

        it("should consume budgets correctly", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            Test.captureBudget()

            MockGlobalDataStore:SetAsync("TestKey1", 123)
            expect(Test.checkpointBudget{
                [Enum.DataStoreRequestType.SetIncrementAsync] = -1
            }).to.be.ok()

            MockGlobalDataStore:SetAsync("TestKey2", "abc")
            expect(Test.checkpointBudget{
                [Enum.DataStoreRequestType.SetIncrementAsync] = -1
            }).to.be.ok()

            MockGlobalDataStore:SetAsync("TestKey3", {})
            expect(Test.checkpointBudget{
                [Enum.DataStoreRequestType.SetIncrementAsync] = -1
            }).to.be.ok()

            MockGlobalDataStore:SetAsync("TestKey4", true)
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

        it("should throw for invalid key", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            expect(function()
                MockGlobalDataStore:SetAsync()
            end).to.throw()

            expect(function()
                MockGlobalDataStore:SetAsync(nil, "value")
            end).to.throw()

            expect(function()
                MockGlobalDataStore:SetAsync(123, "value")
            end).to.throw()

            expect(function()
                MockGlobalDataStore:SetAsync("", "value")
            end).to.throw()

            expect(function()
                MockGlobalDataStore:SetAsync(("a"):rep(Test.Constants.MAX_LENGTH_KEY + 1), "value")
            end).to.throw()

        end)

        it("should throw at attempts to store invalid data", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            local function testValue(v)
                expect(function()
                    MockGlobalDataStore:SetAsync("TestKey", v)
                end).to.throw()
            end

            testValue(nil)
            testValue(function() end)
            testValue(coroutine.create(function() end))
            testValue(Instance.new("Frame"))
            testValue(Enum.DataStoreRequestType.GetAsync)
            testValue({a = 1, 2, 3})
            testValue({[0] = 1, 2, 3})
            testValue({[1] = 1, [2] = 2, [4] = 3})
            testValue({a = {function() end, 1, 2}, b = Instance.new("Frame")})
            testValue({a = {1,2,3}, b = {1,2,{{coroutine.create(function() end)},4,5}}, c = 3})
            testValue(("a"):rep(Test.Constants.MAX_LENGTH_DATA + 1))

        end)

        it("should not set the get-cache", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            MockGlobalDataStore:SetAsync("TestKey", 1)

            Test.captureBudget()

            MockGlobalDataStore:GetAsync("TestKey")

            expect(Test.checkpointBudget{
                [Enum.DataStoreRequestType.GetAsync] = -1;
            })

        end)

    end)

    describe("MockGlobalDataStore::UpdateAsync", function()

        it("should update keys correctly", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            MockGlobalDataStore:ImportFromJSON({TestKey3 = "ThisShouldBeOverwritten", TestKey4 = "ThisToo"})

            MockGlobalDataStore:UpdateAsync("TestKey1", function() return 123 end)
            MockGlobalDataStore:UpdateAsync("TestKey2", function() return "abc" end)
            MockGlobalDataStore:UpdateAsync("TestKey3", function() return {a = {1,2,3}, b = {c = 1, d = 2}, e = 3} end)
            MockGlobalDataStore:UpdateAsync("TestKey4", function() return false end)

            local exported = HttpService:JSONDecode(MockGlobalDataStore:ExportToJSON())
            expect(exported.TestKey1).to.equal(123)
            expect(exported.TestKey2).to.equal("abc")
            expect(exported.TestKey3).to.be.a("table")
            expect(exported.TestKey4).to.equal(false)

        end)

        it("should return the updated value", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            expect(MockGlobalDataStore:UpdateAsync("TestKey1", function() return 123 end)).to.equal(123)
            expect(MockGlobalDataStore:UpdateAsync("TestKey2", function() return false end)).to.equal(false)
            expect(MockGlobalDataStore:UpdateAsync("TestKey3", function() return "abc" end)).to.equal("abc")
            expect(MockGlobalDataStore:UpdateAsync("TestKey4", function() return {} end)).to.be.a("table")

        end)

        it("should pass the old value to the callback", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            local oldValues = {
                TestKey1 = "OldValue";
                TestKey2 = {};
                TestKey3 = false;
                TestKey4 = 123;
            }

            MockGlobalDataStore:ImportFromJSON(oldValues)

            for key, value in pairs(oldValues) do
                expect(MockGlobalDataStore:UpdateAsync(key, function(oldValue)
                    if oldValue == value then
                        return oldValue
                    end
                    error()
                end)).never.to.throw()
            end

        end)

        it("should not allow mutation of stored values indirectly", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            local value = {a = {1,2,3}, b = 2, c = {d = 1, e = 2}}

            MockGlobalDataStore:UpdateAsync("TestKey1", function() return value end)

            value.b = 300
            value.a[3] = 1337
            value.c.e = 200

            local exported = HttpService:JSONDecode(MockGlobalDataStore:ExportToJSON())
            expect(exported.TestKey1).to.be.ok()
            expect(exported.TestKey1.b).to.equal(2)
            expect(exported.TestKey1.a[3]).to.equal(3)
            expect(exported.TestKey1.c.e).to.equal(2)

            MockGlobalDataStore:ImportFromJSON({TestKey2 = value})

            expect(function()
                MockGlobalDataStore:UpdateAsync("TestKey2", function(old)
                    old.a = 123
                    old.b = 500
                    old.c = 456
                    error()
                end)
            end).to.throw()

            exported = HttpService:JSONDecode(MockGlobalDataStore:ExportToJSON())
            expect(exported.TestKey2).to.be.ok()
            expect(exported.TestKey2.b).to.equal(2)
            expect(exported.TestKey2.a[3]).to.equal(3)
            expect(exported.TestKey2.c.e).to.equal(2)

        end)

        it("should consume budgets correctly", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            Test.captureBudget()

            for i = 1, 10 do
                MockGlobalDataStore:UpdateAsync("TestKey"..i, function() return 1 end)
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

        it("should throw for invalid key", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            local func = function() return 1 end

            expect(function()
                MockGlobalDataStore:UpdateAsync()
            end).to.throw()

            expect(function()
                MockGlobalDataStore:UpdateAsync(nil, func)
            end).to.throw()

            expect(function()
                MockGlobalDataStore:UpdateAsync(123, func)
            end).to.throw()

            expect(function()
                MockGlobalDataStore:UpdateAsync("", func)
            end).to.throw()

            expect(function()
                MockGlobalDataStore:UpdateAsync(("a"):rep(Test.Constants.MAX_LENGTH_KEY + 1), func)
            end).to.throw()

        end)

        it("should throw at attempts to store invalid data", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            local function testValue(v)
                expect(function()
                    MockGlobalDataStore:UpdateAsync("TestKey", function() return v end)
                end).to.throw()
            end

            testValue(nil)
            testValue(function() end)
            testValue(coroutine.create(function() end))
            testValue(Instance.new("Frame"))
            testValue(Enum.DataStoreRequestType.GetAsync)
            testValue({a = 1, 2, 3})
            testValue({[0] = 1, 2, 3})
            testValue({[1] = 1, [2] = 2, [4] = 3})
            testValue({a = {function() end, 1, 2}, b = Instance.new("Frame")})
            testValue({a = {1,2,3}, b = {1,2,{{coroutine.create(function() end)},4,5}}, c = 3})
            testValue(("a"):rep(Test.Constants.MAX_LENGTH_DATA + 1))

        end)

        it("should set the get-cache", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            MockGlobalDataStore:UpdateAsync("TestKey", function() return 1 end)
            MockGlobalDataStore:GetAsync("TestKey")

            expect(Test.Manager:GetBudget(Enum.DataStoreRequestType.GetAsync)).to.equal(1)

        end)

    end)

    describe("MockGlobalDataStore::OnUpdate", function()

        it("should return a RBXScriptConnection", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            local conn = MockGlobalDataStore:OnUpdate("TestKey")

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

        it("should not fire callback after disconnecting", function()
            --TODO
        end)

        it("should not allow mutation of stored values indirectly", function()
            --TODO
        end)

        it("should consume budgets correctly", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            Test.captureBudget()

            for i = 1, 10 do
                local conn = MockGlobalDataStore:OnUpdate("TestKey"..i, function() end)
                conn:Disconnect()
                expect(Test.checkpointBudget{
                    [Enum.DataStoreRequestType.OnUpdate] = -1;
                }).to.be.ok()
            end

        end)

        it("should throttle requests correctly when out of budget", function()
            --TODO
        end)

        it("should throw for invalid input", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

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
                MockGlobalDataStore:OnUpdate(("a"):rep(Test.Constants.MAX_LENGTH_KEY + 1))
            end).to.throw()

            expect(function()
                MockGlobalDataStore:OnUpdate("Test", 123)
            end).to.throw()

            expect(function()
                MockGlobalDataStore:OnUpdate(123, function() end)
            end).to.throw()

        end)

        it("should not set the get-cache", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            local connection = MockGlobalDataStore:OnUpdate("TestKey", function() end)

            Test.captureBudget()

            local result = expect(function()
                MockGlobalDataStore:GetAsync("TestKey")
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

    local scope1 = {
        TestKey1 = true;
        TestKey2 = "Hello world!";
        TestKey3 = {First = 1, Second = 2, Third = 3};
        TestKey4 = false;
    }

    local scope2 = {}

    local scope3 = {
        TestKey1 = "Test string";
        TestKey2 = {
            First = {First = "Hello"};
            Second = {First = true, Second = false};
            Third = 3;
            Fourth = {"One", 1, "Two", 2, "Three", {3, 4, 5, 6}, 7};
        };
        TestKey3 = 12345;
    }

    local scope4 = {
        TestKey1 = 1;
        TestKey2 = 2;
        TestKey3 = 3;
    }

    local scope5 = {
        TestImportKey1 = -5.1;
        TestImportKey2 = "Test string";
        TestImportKey3 = {};
    }

    describe("MockGlobalDataStore::ImportFromJSON/ExportToJSON", function()

        it("should import keys correctly", function()
            Test.reset()
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            expect(function()

                MockGlobalDataStore:ImportFromJSON(scope1, false)
                MockGlobalDataStore:ImportFromJSON(scope2, false)
                MockGlobalDataStore:ImportFromJSON(scope3, false)
                MockGlobalDataStore:ImportFromJSON(scope4, false)
                MockGlobalDataStore:ImportFromJSON(scope5, false)

                MockGlobalDataStore:ImportFromJSON(HttpService:JSONEncode(scope1), false)
                MockGlobalDataStore:ImportFromJSON(HttpService:JSONEncode(scope2), false)
                MockGlobalDataStore:ImportFromJSON(HttpService:JSONEncode(scope3), false)
                MockGlobalDataStore:ImportFromJSON(HttpService:JSONEncode(scope4), false)
                MockGlobalDataStore:ImportFromJSON(HttpService:JSONEncode(scope5), false)

            end).never.to.throw()

        end)

        it("should contain all imported values afterwards", function()
            Test.reset()
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            MockGlobalDataStore:ImportFromJSON(scope3, false)
            MockGlobalDataStore:ImportFromJSON(scope5, false)

            local exported = HttpService:JSONDecode(MockGlobalDataStore:ExportToJSON())
            expect(Test.subsetOf(scope3, exported)).to.equal(true)
            expect(Test.subsetOf(scope5, exported)).to.equal(true)

        end)

        it("should fire OnUpdate signals", function()
            --TODO
        end)

        it("should ignore invalid values and keys", function()
            Test.reset()
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

            local partiallyValid = {
                TestKey1 = 1;
                TestKey2 = true;
                TestKey3 = "Test";
                TestKey4 = {1,2,3,4};
                TestKey5 = {}; -- will loop
                TestKey6 = 6;
                [true] = 7;
                [123] = "Hello";
                TestKey8 = Instance.new("Frame");
                TestKey9 = math.huge;
                TestKey10 = -math.huge;
                TestKey11 = 11;
                TestKey12 = function() end;
                TestKey13 = {a = 1, 2, 3};
                TestKey14 = {[1] = 1, [2] = 2, [4] = 3};
                TestKey15 = {a = {1,2,3}, b = 4, c = {{1,2},3,4,5,{6,7}}, d = "Testing"};
                TestKey16 = ("a"):rep(Test.Constants.MAX_LENGTH_DATA + 1);
                TestKey17 = {a = {1,2,3}, b = 4, c = {{1,2},3,4,5,{6,7, coroutine.create(function() end)}}};
            }
            partiallyValid.TestKey5.loop = partiallyValid.TestKey5

            MockGlobalDataStore:ImportFromJSON(partiallyValid)

            local exported = HttpService:JSONDecode(MockGlobalDataStore:ExportToJSON())

            expect(exported.TestKey1).to.be.ok()
            expect(exported.TestKey2).to.be.ok()
            expect(exported.TestKey3).to.be.ok()
            expect(exported.TestKey4).to.be.ok()
            expect(exported.TestKey5).to.never.be.ok()
            expect(exported.TestKey6).to.be.ok()
            expect(exported[true]).to.never.be.ok()
            expect(exported[123]).to.never.be.ok()
            expect(exported.TestKey8).to.never.be.ok()
            expect(exported.TestKey9).to.never.be.ok()
            expect(exported.TestKey10).to.never.be.ok()
            expect(exported.TestKey11).to.be.ok()
            expect(exported.TestKey12).to.never.be.ok()
            expect(exported.TestKey13).to.never.be.ok()
            expect(exported.TestKey14).to.never.be.ok()
            expect(exported.TestKey15).to.be.ok()
            expect(exported.TestKey16).to.never.be.ok()
            expect(exported.TestKey17).to.never.be.ok()

        end)

        it("should throw for invalid input", function()
            Test.reset()
            local MockGlobalDataStore = Test.Service:GetDataStore("Test")

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

end