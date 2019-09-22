return function()
    local Test = require(script.Parent.Test)
    local HttpService = game:GetService("HttpService")

    local function reset()
        Test.Manager.ResetData()
        Test.Manager.ResetBudget()
        Test.Manager.ThawBudgetUpdates()
    end

    describe("MockDataStoreService", function()

        it("should expose all API members", function()
            expect(Test.Service.GetDataStore).to.be.a("function")
            expect(Test.Service.GetGlobalDataStore).to.be.a("function")
            expect(Test.Service.GetOrderedDataStore).to.be.a("function")
            expect(Test.Service.GetRequestBudgetForRequestType).to.be.a("function")
            expect(Test.Service.ImportFromJSON).to.be.a("function")
            expect(Test.Service.ExportFromJSON).to.be.a("function")
        end)

    end)

    describe("Test.Service::GetDataStore", function()

        it("should return an object for valid input", function()
            expect(Test.Service:GetDataStore("Test")).to.be.ok()
            expect(Test.Service:GetDataStore("Test2", "Test2")).to.be.ok()
        end)

        it("should throw for invalid input", function()

            expect(function()
                Test.Service:GetDataStore()
            end).to.throw()

            expect(function()
                Test.Service:GetDataStore(nil, "Test")
            end).to.throw()

            expect(function()
                Test.Service:GetDataStore("Test", 123)
            end).to.throw()

            expect(function()
                Test.Service:GetDataStore(("a"):rep(Test.Constants.MAX_LENGTH_NAME + 1), "Test")
            end).to.throw()

            expect(function()
                Test.Service:GetDataStore(123, "Test")
            end).to.throw()

            expect(function()
                Test.Service:GetDataStore("Test", ("a"):rep(Test.Constants.MAX_LENGTH_SCOPE + 1))
            end).to.throw()

            expect(function()
                Test.Service:GetDataStore("", "Test")
            end).to.throw()

            expect(function()
                Test.Service:GetDataStore("Test", "")
            end).to.throw()

        end)

    end)

    describe("Test.Service::GetGlobalDataStore", function()

        it("should return an object", function()
            expect(Test.Service:GetGlobalDataStore()).to.be.ok()
        end)

    end)

    describe("Test.Service::GetOrderedDataStore", function()

        it("should return an object for valid input", function()
            expect(Test.Service:GetOrderedDataStore("Test")).to.be.ok()
            expect(Test.Service:GetOrderedDataStore("Test2", "Test2")).to.be.ok()
        end)

        it("should throw for invalid input", function()

            expect(function()
                Test.Service:GetOrderedDataStore()
            end).to.throw()

            expect(function()
                Test.Service:GetOrderedDataStore(nil, "Test")
            end).to.throw()

            expect(function()
                Test.Service:GetOrderedDataStore("Test", 123)
            end).to.throw()

            expect(function()
                Test.Service:GetOrderedDataStore(("a"):rep(51), "Test")
            end).to.throw()

            expect(function()
                Test.Service:GetOrderedDataStore(123, "Test")
            end).to.throw()

            expect(function()
                Test.Service:GetOrderedDataStore("Test", ("a"):rep(51))
            end).to.throw()

            expect(function()
                Test.Service:GetOrderedDataStore("", "Test")
            end).to.throw()

            expect(function()
                Test.Service:GetOrderedDataStore("Test", "")
            end).to.throw()

        end)

    end)

    describe("Test.Service::GetRequestBudgetForRequestType", function()

        it("should return numerical budgets", function()
            for _,v in pairs(Enum.DataStoreRequestType:GetEnumItems()) do
                expect(Test.Service:GetRequestBudgetForRequestType(v)).to.be.a("number")
            end
        end)

        it("should accept enumerator values", function()
            for _,v in pairs(Enum.DataStoreRequestType:GetEnumItems()) do
                expect(Test.Service:GetRequestBudgetForRequestType(v.Value)).to.be.ok()
            end
        end)

        it("should accept enumerator names", function()
            for _,v in pairs(Enum.DataStoreRequestType:GetEnumItems()) do
                expect(Test.Service:GetRequestBudgetForRequestType(v.Name)).to.be.ok()
            end
        end)

        it("should throw for invalid input", function()

            expect(function()
                Test.Service:GetRequestBudgetForRequestType("NotARequestType")
            end).to.throw()

            expect(function()
                Test.Service:GetRequestBudgetForRequestType()
            end).to.throw()

            expect(function()
                Test.Service:GetRequestBudgetForRequestType(13373)
            end).to.throw()

            expect(function()
                Test.Service:GetRequestBudgetForRequestType(true)
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

    describe("Test.Service::ImportFromJSON", function()

        it("should import from correct json strings", function()
            reset()

            local json = HttpService:JSONEncode(testDataStores)

            expect(function()
                Test.Service:ImportFromJSON(json, false)
            end).never.to.throw()

        end)

        it("should import from correct table input", function()
            reset()

            expect(function()
                Test.Service:ImportFromJSON(testDataStores, false)
            end).never.to.throw()

        end)

        it("should contain newly imported values after importing", function()
            reset()

            Test.Service:ImportFromJSON(testDataStores, false)

            local globalData = Test.Manager.GetGlobalData()
            expect(globalData).to.be.ok()
            expect(Test.subsetOf(globalData, testDataStores.GlobalDataStore)).to.equal(true)

            for name, scopes in pairs(testDataStores.DataStores) do
                for scope, data in pairs(scopes) do
                    local importedData = Test.Manager.GetData(name, scope)
                    expect(importedData).to.be.ok()
                    expect(Test.subsetOf(data, importedData)).to.equal(true)
                end
            end

            for name, scopes in pairs(testDataStores.OrderedDataStores) do
                for scope, data in pairs(scopes) do
                    local importedData = Test.Manager.GetOrderedData(name, scope)
                    expect(importedData).to.be.ok()
                    expect(Test.subsetOf(data, importedData)).to.equal(true)
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

            Test.Service:ImportFromJSON(oldValues, false)

            Test.Service:ImportFromJSON(testDataStores, false)

            local globalData = Test.Manager.GetGlobalData()
            expect(globalData).to.be.ok()
            expect(Test.subsetOf(globalData, oldValues.GlobalDataStore)).to.equal(true)

            for name, scopes in pairs(oldValues.DataStores) do
                for scope, data in pairs(scopes) do
                    local importedData = Test.Manager.GetData(name, scope)
                    expect(importedData).to.be.ok()
                    expect(Test.subsetOf(data, importedData)).to.equal(true)
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

            Test.Service:ImportFromJSON(partiallyValid, false)

            expect(Test.Manager.GetData("ImportTestName", "ImportTestScope").TestKey1).to.be.ok()
            expect(Test.Manager.GetData("ImportTestName", "ImportTestScope").TestKey2).to.never.be.ok()

            expect(Test.Manager.GetData("ImportTestName", "ImportTestScope2").TestKey1).to.never.be.ok()
            expect(Test.Manager.GetData("ImportTestName", "ImportTestScope2").TestKey2).to.be.ok()
            expect(Test.Manager.GetData("ImportTestName", "ImportTestScope2").TestKey3).to.never.be.ok()

            expect(Test.Manager.GetData("ImportTestName", "ImportTestScope3").TestKey1).to.be.ok()
            expect(Test.Manager.GetData("ImportTestName", "ImportTestScope3")[frame]).to.never.be.ok()
            expect(Test.Manager.GetData("ImportTestName", "ImportTestScope3")[true]).to.never.be.ok()
            expect(Test.Manager.GetData("ImportTestName", "ImportTestScope3")[123]).to.never.be.ok()
            expect(Test.Manager.GetData("ImportTestName", "ImportTestScope3")[func]).to.never.be.ok()

            expect(Test.Manager.GetData("ImportTestName2", "ImportTestScope").TestKey1).to.be.ok()
            expect(Test.Manager.GetData("ImportTestName2", "ImportTestScope").TestKey2).to.be.ok()
            expect(Test.Manager.GetData("ImportTestName2", "ImportTestScope").TestKey3).to.never.be.ok()

            expect(Test.Manager.GetData("ImportTestName2", "ImportTestScope2").TestKey1).to.never.be.ok()
            expect(Test.Manager.GetData("ImportTestName2", "ImportTestScope2").TestKey2).to.never.be.ok()

            expect(Test.Manager.GetGlobalData().TestKey1).to.be.ok()
            expect(Test.Manager.GetGlobalData().TestKey1).to.be.ok()
            expect(Test.Manager.GetGlobalData().TestKey1).to.be.ok()
            expect(Test.Manager.GetGlobalData().TestKey1).to.never.be.ok()

        end)

        it("should throw for invalid input", function()

            expect(function()
                Test.Service:ImportFromJSON("{this is invalid json}", false)
            end).to.throw()

            expect(function()
                Test.Service:ImportFromJSON(123, false)
            end).to.throw()

            expect(function()
                Test.Service:ImportFromJSON({}, 123)
            end).to.throw()

            expect(function()
                Test.Service:ImportFromJSON("{}", 123)
            end).to.throw()

        end)

    end)

    describe("Test.Service::ExportToJSON", function()

        it("should return valid json", function()
            reset()

            Test.Service:ImportFromJSON(testDataStores, false)

            local json = Test.Service:ExportToJSON()

            expect(function()
                HttpService:JSONDecode(json)
            end).never.to.throw()

        end)

        it("should export all values", function()
            reset()

            Test.Service:ImportFromJSON(testDataStores, false)

            local exported = HttpService:JSONDecode(Test.Service:ExportToJSON())

            expect(Test.subsetOf(exported, testDataStores)).to.equal(true)

        end)

        it("should not contain empty datastore scopes", function()
            reset()

            Test.Service:ImportFromJSON(testDataStores, false)

            local exported = HttpService:JSONDecode(Test.Service:ExportToJSON())

            expect(exported.DataStores.ImportTestName.ImportTestScope2).to.never.be.ok()
            expect(exported.OrderedDataStores.ImportTestName.ImportTestScope3).to.never.be.ok()
            expect(exported.OrderedDataStores.ImportTestName2.ImportTestScope).to.never.be.ok()

        end)

        it("should not contain empty datastore names", function()
            reset()

            Test.Service:ImportFromJSON(testDataStores, false)

            local exported = HttpService:JSONDecode(Test.Service:ExportToJSON())

            expect(exported.DataStores.ImportTestName2).to.never.be.ok()
            expect(exported.OrderedDataStores.ImportTestName3).to.never.be.ok()

        end)

        it("should not contain empty datastore types", function()
            reset()

            local exported = HttpService:JSONDecode(Test.Service:ExportToJSON())

            expect(exported.DataStores).to.never.be.ok()
            expect(exported.OrderedDataStores).to.never.be.ok()
            expect(exported.GlobalDataStore).to.never.be.ok()

        end)

    end)

end
