return function()

    local MockDataStoreService = require(script.Parent)
    local Constants = require(script.Parent.Parent.Parent.DataStoreService.MockDataStoreService.MockDataStoreConstants)
    local MockDataStoreManager = require(script.Parent.Parent.Parent.DataStoreService.MockDataStoreService.MockDataStoreManager)
    local HttpService = game:GetService("HttpService")

    local function reset()
        MockDataStoreManager:ResetData()
        MockDataStoreManager:ResetBudget()
    end

    describe("MockDataStoreService", function()

        it("should expose all API members", function()
            expect(MockDataStoreService.GetDataStore).to.be.a("function")
            expect(MockDataStoreService.GetGlobalDataStore).to.be.a("function")
            expect(MockDataStoreService.GetOrderedDataStore).to.be.a("function")
            expect(MockDataStoreService.GetRequestBudgetForRequestType).to.be.a("function")
            expect(MockDataStoreService.ImportFromJSON).to.be.a("function")
            expect(MockDataStoreService.ExportFromJSON).to.be.a("function")
        end)

    end)

    describe("MockDataStoreService::GetDataStore", function()

        it("should return an object for valid input", function()

            local store

            expect(function()
                store = MockDataStoreService:GetDataStore("Test")
            end).never.to.throw()

            expect(store).to.be.ok()

            expect(function()
                store = MockDataStoreService:GetDataStore("Test", "Test")
            end).never.to.throw()

            expect(store).to.be.ok()

        end)

        it("should throw for invalid input", function()

            expect(function()
                MockDataStoreService:GetDataStore()
            end).to.throw()

            expect(function()
                MockDataStoreService:GetDataStore(nil, "Test")
            end).to.throw()

            expect(function()
                MockDataStoreService:GetDataStore("Test", 123)
            end).to.throw()

            expect(function()
                MockDataStoreService:GetDataStore(("a"):rep(Constants.MAX_LENGTH_NAME + 1), "Test")
            end).to.throw()

            expect(function()
                MockDataStoreService:GetDataStore(123, "Test")
            end).to.throw()

            expect(function()
                MockDataStoreService:GetDataStore("Test", ("a"):rep(Constants.MAX_LENGTH_SCOPE + 1))
            end).to.throw()

            expect(function()
                MockDataStoreService:GetDataStore("", "Test")
            end).to.throw()

            expect(function()
                MockDataStoreService:GetDataStore("Test", "")
            end).to.throw()

        end)

    end)

    describe("MockDataStoreService::GetGlobalDataStore", function()

        it("should return an object", function()
            expect(MockDataStoreService:GetGlobalDataStore()).to.be.ok()
        end)

    end)

    describe("MockDataStoreService::GetOrderedDataStore", function()

        it("should return an object for valid input", function()

            local store

            expect(function()
                store = MockDataStoreService:GetOrderedDataStore("Test")
            end).never.to.throw()

            expect(store).to.be.ok()

            expect(function()
                store = MockDataStoreService:GetOrderedDataStore("Test2", "Test2")
            end).never.to.throw()

            expect(store).to.be.ok()

        end)

        it("should throw for invalid input", function()

            expect(function()
                MockDataStoreService:GetOrderedDataStore()
            end).to.throw()

            expect(function()
                MockDataStoreService:GetOrderedDataStore(nil, "Test")
            end).to.throw()

            expect(function()
                MockDataStoreService:GetOrderedDataStore("Test", 123)
            end).to.throw()

            expect(function()
                MockDataStoreService:GetOrderedDataStore(("a"):rep(51), "Test")
            end).to.throw()

            expect(function()
                MockDataStoreService:GetOrderedDataStore(123, "Test")
            end).to.throw()

            expect(function()
                MockDataStoreService:GetOrderedDataStore("Test", ("a"):rep(51))
            end).to.throw()

            expect(function()
                MockDataStoreService:GetOrderedDataStore("", "Test")
            end).to.throw()

            expect(function()
                MockDataStoreService:GetOrderedDataStore("Test", "")
            end).to.throw()

        end)

    end)

    describe("MockDataStoreService::GetRequestBudgetForRequestType", function()

        it("should return numerical budgets", function()
            for _,v in pairs(Enum.DataStoreRequestType:GetEnumItems()) do
                expect(MockDataStoreService:GetRequestBudgetForRequestType(v)).to.be.a("number")
            end
        end)

        it("should accept enumerator values", function()
            for _,v in pairs(Enum.DataStoreRequestType:GetEnumItems()) do
                expect(MockDataStoreService:GetRequestBudgetForRequestType(v.Value)).to.be.ok()
            end
        end)

        it("should accept enumerator names", function()
            for _,v in pairs(Enum.DataStoreRequestType:GetEnumItems()) do
                expect(MockDataStoreService:GetRequestBudgetForRequestType(v.Name)).to.be.ok()
            end
        end)

        it("should throw for invalid input", function()

            expect(function()
                MockDataStoreService:GetRequestBudgetForRequestType("NotARequestType")
            end).to.throw()

            expect(function()
                MockDataStoreService:GetRequestBudgetForRequestType()
            end).to.throw()

            expect(function()
                MockDataStoreService:GetRequestBudgetForRequestType(13373)
            end).to.throw()

            expect(function()
                MockDataStoreService:GetRequestBudgetForRequestType(true)
            end).to.throw()

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
                        Fourth = {"One", 1, "Two", 2, "Three", 3};
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

    local function subsetOf(t1, t2)
        if type(t1) ~= "table" or type(t2) ~= "table" then
            return t1 == t2
        end
        for key, value in pairs(t1) do
            if type(value) == "table" then
                if type(t2[key]) == "table" then
                    if not subsetOf(t1[key], t2[key]) then
                        return false
                    end
                else
                    return false
                end
            elseif t1[key] ~= t2[key] then
                return false
            end
        end
        return true
    end

    describe("MockDataStoreService::ImportFromJSON", function()

        it("should import from correct json strings", function()
            reset()

            local json = HttpService:JSONEncode(testDataStores)

            expect(function()
                MockDataStoreService:ImportFromJSON(json, false)
            end).never.to.throw()

        end)

        it("should import from correct table input", function()
            reset()

            expect(function()
                MockDataStoreService:ImportFromJSON(testDataStores, false)
            end).never.to.throw()

        end)

        it("should contain newly imported values after importing", function()
            reset()

            MockDataStoreService:ImportFromJSON(testDataStores, false)

            local globalData = MockDataStoreManager:GetGlobalData()
            expect(globalData).to.be.ok()
            expect(subsetOf(globalData, testDataStores.GlobalDataStore)).to.equal(true)

            for name, scopes in pairs(testDataStores.DataStores) do
                for scope, data in pairs(scopes) do
                    local importedData = MockDataStoreManager:GetData(name, scope)
                    expect(importedData).to.be.ok()
                    expect(subsetOf(data, importedData)).to.equal(true)
                end
            end

            for name, scopes in pairs(testDataStores.OrderedDataStores) do
                for scope, data in pairs(scopes) do
                    local importedData = MockDataStoreManager:GetOrderedData(name, scope)
                    expect(importedData).to.be.ok()
                    expect(subsetOf(data, importedData)).to.equal(true)
                end
            end

        end)

        it("should contain old values after importing new values", function()
            reset()

            local oldValues = {
                DataStores = {
                    ImportTestName = {
                        ImportTestScope = {
                            TestKey5 = 123;
                            TestKey6 = {A = "a", B = "b", C = "c"};
                        };
                        ImportTestScope2 = {
                            TestKey1 = "Test";
                        };
                        ImportTestScope4 = {
                            TestKey1 = "Hello world!";
                        }
                    };
                    ImportTestName2 = {
                        ImportTestScope = {
                            TestKey1 = 456;
                            TestKey2 = {1,2,3,4};
                        };
                    };
                };
                GlobalDataStore = {
                    TestImportKey4 = "Foo";
                    TestImportKey5 = "Bar";
                    TestImportKey6 = "Baz";
                };
            }

            MockDataStoreService:ImportFromJSON(oldValues, false)

            MockDataStoreService:ImportFromJSON(testDataStores, false)

            local globalData = MockDataStoreManager:GetGlobalData()
            expect(globalData).to.be.ok()
            expect(subsetOf(globalData, oldValues.GlobalDataStore)).to.equal(true)

            for name, scopes in pairs(oldValues.DataStores) do
                for scope, data in pairs(scopes) do
                    local importedData = MockDataStoreManager:GetData(name, scope)
                    expect(importedData).to.be.ok()
                    expect(subsetOf(data, importedData)).to.equal(true)
                end
            end

        end)

        it("should not contain invalid entries from input tables after importing", function()
            reset()

            local frame = Instance.new("Frame")
            local func = function() end

            local partiallyValid = {
                DataStores = {
                    ImportTestName = {
                        ImportTestScope = {
                            TestKey1 = 123;
                            TestKey2 = {A = "a", "b", C = "c"}; -- mixed table
                        };
                        ImportTestScope2 = {
                            TestKey1 = func; -- invalid type
                            TestKey2 = "Hello world!";
                            TestKey3 = frame;
                        };
                        ImportTestScope3 = {
                            TestKey1 = "Hello world!";
                            [frame] = 123; -- invalid keys
                            [true] = 456;
                            [123] = 789;
                            [func] = "abc";
                        };
                    };
                    ImportTestName2 = {
                        ImportTestScope = {
                            TestKey1 = 456;
                            TestKey2 = {1,2,3,4};
                            TestKey3 = {[0] = 1, 2, 3}; -- does not start at 1
                        };
                        ImportTestScope2 = {
                            TestKey1 = {[1] = 1, [2] = 2, [4] = 3}; -- holes
                            TestKey2 = {[1.2] = true}; -- invalid key entry
                        };
                    };
                };
                GlobalDataStore = {
                    TestKey1 = "Foo";
                    TestKey2 = "Bar";
                    TestKey3 = "Baz";
                    TestKey4 = math.huge; -- invalid value
                };
            }

            MockDataStoreService:ImportFromJSON(partiallyValid, false)

            expect(MockDataStoreManager:GetData("ImportTestName", "ImportTestScope").TestKey1).to.be.ok()
            expect(MockDataStoreManager:GetData("ImportTestName", "ImportTestScope").TestKey2).to.never.be.ok()

            expect(MockDataStoreManager:GetData("ImportTestName", "ImportTestScope2").TestKey1).to.never.be.ok()
            expect(MockDataStoreManager:GetData("ImportTestName", "ImportTestScope2").TestKey2).to.be.ok()
            expect(MockDataStoreManager:GetData("ImportTestName", "ImportTestScope2").TestKey3).to.never.be.ok()

            expect(MockDataStoreManager:GetData("ImportTestName", "ImportTestScope3").TestKey1).to.be.ok()
            expect(MockDataStoreManager:GetData("ImportTestName", "ImportTestScope3")[frame]).to.never.be.ok()
            expect(MockDataStoreManager:GetData("ImportTestName", "ImportTestScope3")[true]).to.never.be.ok()
            expect(MockDataStoreManager:GetData("ImportTestName", "ImportTestScope3")[123]).to.never.be.ok()
            expect(MockDataStoreManager:GetData("ImportTestName", "ImportTestScope3")[func]).to.never.be.ok()

            expect(MockDataStoreManager:GetData("ImportTestName2", "ImportTestScope").TestKey1).to.be.ok()
            expect(MockDataStoreManager:GetData("ImportTestName2", "ImportTestScope").TestKey2).to.be.ok()
            expect(MockDataStoreManager:GetData("ImportTestName2", "ImportTestScope").TestKey3).to.never.be.ok()

            expect(MockDataStoreManager:GetData("ImportTestName2", "ImportTestScope2").TestKey1).to.never.be.ok()
            expect(MockDataStoreManager:GetData("ImportTestName2", "ImportTestScope2").TestKey2).to.never.be.ok()

            expect(MockDataStoreManager:GetGlobalData().TestKey1).to.be.ok()
            expect(MockDataStoreManager:GetGlobalData().TestKey1).to.be.ok()
            expect(MockDataStoreManager:GetGlobalData().TestKey1).to.be.ok()
            expect(MockDataStoreManager:GetGlobalData().TestKey1).to.never.be.ok()

        end)

        it("should throw for invalid input", function()

            expect(function()
                MockDataStoreService:ImportFromJSON("{this is invalid json}", false)
            end).to.throw()

            expect(function()
                MockDataStoreService:ImportFromJSON(123, false)
            end).to.throw()

            expect(function()
                MockDataStoreService:ImportFromJSON({}, 123)
            end).to.throw()

            expect(function()
                MockDataStoreService:ImportFromJSON("{}", 123)
            end).to.throw()

        end)

    end)

    describe("MockDataStoreService::ExportToJSON", function()

        it("should return valid json", function()
            reset()

            MockDataStoreService:ImportFromJSON(testDataStores, false)

            local json = MockDataStoreService:ExportToJSON()

            expect(function()
                HttpService:JSONDecode(json)
            end).never.to.throw()

        end)

        it("should export all values", function()
            reset()

            MockDataStoreService:ImportFromJSON(testDataStores, false)

            local exported = HttpService:JSONDecode(MockDataStoreService:ExportToJSON())

            expect(subsetOf(exported, testDataStores)).to.equal(true)

        end)

        it("should not contain empty datastore scopes", function()
            reset()

            MockDataStoreService:ImportFromJSON(testDataStores, false)

            local exported = HttpService:JSONDecode(MockDataStoreService:ExportToJSON())

            expect(exported.DataStores.ImportTestName.ImportTestScope2).to.never.be.ok()
            expect(exported.OrderedDataStores.ImportTestName.ImportTestScope3).to.never.be.ok()
            expect(exported.OrderedDataStores.ImportTestName2.ImportTestScope).to.never.be.ok()

        end)

        it("should not contain empty datastore names", function()
            reset()

            MockDataStoreService:ImportFromJSON(testDataStores, false)

            local exported = HttpService:JSONDecode(MockDataStoreService:ExportToJSON())

            expect(exported.DataStores.ImportTestName2).to.never.be.ok()
            expect(exported.OrderedDataStores.ImportTestName3).to.never.be.ok()

        end)

        it("should not contain empty datastore types", function()
            reset()

            local exported = HttpService:JSONDecode(MockDataStoreService:ExportToJSON())

            expect(exported.DataStores).to.never.be.ok()
            expect(exported.OrderedDataStores).to.never.be.ok()
            expect(exported.GlobalDataStore).to.never.be.ok()

        end)

    end)

end