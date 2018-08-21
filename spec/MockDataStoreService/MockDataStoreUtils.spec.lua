return function()

    local Utils = require(script.Parent.Parent.Parent.DataStoreService.MockDataStoreService.MockDataStoreUtils)

    describe("Utils", function()

        it("should be a table", function()
            expect(Utils).to.be.a("table")
        end)

    end)

    describe("Utils.deepcopy", function()

        it("should copy flat arrays correctly", function()
            local array = {1, 2, 3, "Testing...", true, false}
            local copy = Utils.deepcopy(array)

            expect(copy).to.be.a("table")
            for i, v in pairs(array) do
                expect(copy[i]).to.equal(v)
            end
            for i, v in pairs(copy) do
                expect(array[i]).to.equal(v)
            end
            expect(#copy).to.equal(#array)
        end)

        it("should copy flat dictionaries correctly", function()
            local dictionary = {a = 1, b = 2, c = 3, [true] = false}
            local copy = Utils.deepcopy(dictionary)

            expect(copy).to.be.a("table")
            for i, v in pairs(dictionary) do
                expect(copy[i]).to.equal(v)
            end
            for i, v in pairs(copy) do
                expect(dictionary[i]).to.equal(v)
            end
            expect(#copy).to.equal(#dictionary)
        end)

        it("should copy flat mixed tables correctly", function()
            local mixed = {
                a = "Test";
                42;
                1337;
                b = "Hello world!";
                c = 123;
                "Testing!";
            }
            local copy = Utils.deepcopy(mixed)

            expect(mixed).to.be.a("table")
            for i, v in pairs(copy) do
                expect(mixed[i]).to.equal(v)
            end
            for i, v in pairs(mixed) do
                expect(copy[i]).to.equal(v)
            end
            expect(#mixed).to.equal(#copy)
        end)

        it("should copy nested arrays/dictionaries/mixed tables correctly", function()
            local nested = {
                a = {42};
                b = {
                    c = 3.14;
                    d = {"Testing", 1, 2, 3};
                    "w";
                    "t";
                    "f";
                };
                e = {};
            }
            local copy = Utils.deepcopy(nested)

            expect(copy).to.be.a("table")
            expect(#copy).to.equal(#nested)

            expect(copy.a).to.be.a("table")
            expect(#copy.a).to.equal(#nested.a)
            expect(copy.a[1]).to.equal(nested.a[1])

            expect(copy.b).to.be.a("table")
            expect(#copy.b).to.equal(#nested.b)
            expect(copy.b.c).to.equal(nested.b.c)
            expect(copy.b.d).to.a("table")
            for i = 1, 4 do
                expect(copy.b.d[i]).to.equal(nested.b.d[i])
            end
            expect(#copy.b.d).to.equal(#nested.b.d)
            for i = 1, 3 do
                expect(copy.b[i]).to.equal(nested.b[i])
            end

            expect(copy.e).to.be.a("table")
            expect(#copy.e).to.equal(#nested.e)
        end)

    end)

    describe("Utils.scanValidity", function()

        it("should report nothing for proper entries", function()
            local proper1 = {
                a = 1;
                b = {1, 2, 3};
                c = 3;
            }
            local proper2 = {
                a = "Test";
                b = {true, false, true};
                c = "Hello world!";
            }

            expect(Utils.scanValidity(proper1)).to.equal(true)
            expect(Utils.scanValidity(proper2)).to.equal(true)
        end)

        it("should report invalidly typed values", function()
            local testWithFunction = {
                a = function() end;
                b = 2;
                c = 3;
            }
            local testWithInstances = {
                a = 1;
                b = {"a", Instance.new("Part"), "c"};
                c = Instance.new("Model");
            }
            local testWithCoroutines = {
                a = 1;
                b = coroutine.create(function() end);
                c = {coroutine.create(function() end)};
            }

            local isValid, keyPath, reason = Utils.scanValidity(testWithFunction)
            expect(isValid).to.equal(false)
            expect(keyPath).to.be.ok()
            expect(reason).to.be.ok()

            isValid, keyPath, reason = Utils.scanValidity(testWithInstances)
            expect(isValid).to.equal(false)
            expect(keyPath).to.be.ok()
            expect(reason).to.be.ok()

            isValid, keyPath, reason = Utils.scanValidity(testWithCoroutines)
            expect(isValid).to.equal(false)
            expect(keyPath).to.be.ok()
            expect(reason).to.be.ok()
        end)

        it("should report mixed tables", function()
            local mixed = {
                a = 1;
                2;
                3;
            }
            local mixedNested = {
                a = { "1", b = "2", "3" };
                b = 2;
            }

            local isValid, keyPath, reason = Utils.scanValidity(mixed)
            expect(isValid).to.equal(false)
            expect(keyPath).to.be.ok()
            expect(reason).to.be.ok()

            isValid, keyPath, reason = Utils.scanValidity(mixedNested)
            expect(isValid).to.equal(false)
            expect(keyPath).to.be.ok()
            expect(reason).to.be.ok()
        end)

        it("should report array tables with holes", function()
            local arrayWithHoles = {
                [1] = "a";
                [2] = "b";
                [4] = "c";
                [-1] = "d";
            }

            local isValid, keyPath, reason = Utils.scanValidity(arrayWithHoles)
            expect(isValid).to.equal(false)
            expect(keyPath).to.be.ok()
            expect(reason).to.be.ok()
        end)

        it("should report float indices", function()
            local dictionaryFloatKeys = {
                [-1.4] = "a";
                [math.pi] = "b";
                [1/9] = "c";
            }

            local isValid, keyPath, reason = Utils.scanValidity(dictionaryFloatKeys)
            expect(isValid).to.equal(false)
            expect(keyPath).to.be.ok()
            expect(reason).to.be.ok()
        end)

        it("should report invalidly typed indices", function()
            local dictionaryInvalidKeys = {
                [true] = "a";
                [function() end] = "b";
                [Instance.new("Part")] = "c";
            }

            local isValid, keyPath, reason = Utils.scanValidity(dictionaryInvalidKeys)
            expect(isValid).to.equal(false)
            expect(keyPath).to.be.ok()
            expect(reason).to.be.ok()
        end)

        it("should report cyclic tables", function()
            local cyclic1 = {
                level = {
                    baz = 3;
                };
                foo = 1;
                bar = 2;
            }
            cyclic1.level.test = cyclic1
            local cyclic2 = {
                recursion = {};
            }
            cyclic2.recursion.recursion = cyclic2.recursion

            local isValid, keyPath, reason = Utils.scanValidity(cyclic1)
            expect(isValid).to.equal(false)
            expect(keyPath).to.be.ok()
            expect(reason).to.be.ok()

            isValid, keyPath, reason = Utils.scanValidity(cyclic2)
            expect(isValid).to.equal(false)
            expect(keyPath).to.be.ok()
            expect(reason).to.be.ok()
        end)

        it("should report infinite/-infinite indices", function()
            local dictionaryOutOfRangeKeys = {
                [-math.huge] = "Hello";
                [math.huge] = "world!";
            }

            local isValid, keyPath, reason = Utils.scanValidity(dictionaryOutOfRangeKeys)
            expect(isValid).to.equal(false)
            expect(keyPath).to.be.ok()
            expect(reason).to.be.ok()
        end)

    end)

    describe("Utils.getStringPath", function()

        it("should format paths in the expected way", function()
            local pathTable = {"foo", "bar", "baz"}

            expect(Utils.getStringPath(pathTable)).to.equal("foo.bar.baz")
        end)

    end)

    -- Utils.importPairsFromTable is not tested here, but through
    -- DataStoreService/GlobalDataStore/OrderedDataStore:ImportFromJSON(...)

    describe("Utils.prepareDataStoresForExport", function()

        it("should strip off empty scopes", function()
            local stores = {
                TestName = {
                    TestScope = {
                        Key1 = 1;
                        Key2 = 2;
                        Key3 = 3
                    };
                    TestScope2 = {};
                };
                TestName2 = {
                    TestScope = {};
                    TestScope2 = {};
                    TestScope3 = {};
                };
                TestName3 = {};
            }

            stores = Utils.prepareDataStoresForExport(stores)
            expect(stores.TestName).to.be.ok()
            expect(stores.TestName.TestScope).to.be.ok()
            expect(stores.TestName.TestScope2).to.never.be.ok()
            expect(stores.TestName2).to.never.be.ok()
            expect(stores.TestName3).to.never.be.ok()
        end)

        it("should return nothing if entirely empty", function()
            local storesEmpty = {}
            local storesEmptyName = {
                TestName = {};
            }
            local storesEmptyScopes = {
                TestName = {
                    TestScope1 = {};
                    TestScope2 = {};
                };
            }

            expect(Utils.prepareDataStoresForExport(storesEmpty)).to.never.be.ok()
            expect(Utils.prepareDataStoresForExport(storesEmptyName)).to.never.be.ok()
            expect(Utils.prepareDataStoresForExport(storesEmptyScopes)).to.never.be.ok()
        end)

    end)

end