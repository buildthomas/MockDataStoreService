return function()

    local Utils = require(script.Parent.Parent.Parent.DataStoreService.MockDataStoreService.MockDataStoreUtils)

    describe("Utils", function()

        it("should be a table", function()
            expect(Utils).to.be.a("table")
        end)

    end)

    describe("Utils.deepcopy", function()

        it("should copy flat arrays correctly", function()
            local test = { 1; 2; 3; "Testing..."; true; false; }
            local test2 = Utils.deepcopy(test)

            expect(test2).to.be.a("table")
            for i, v in pairs(test) do
                expect(test2[i]).to.equal(v)
            end
            for i, v in pairs(test2) do
                expect(test[i]).to.equal(v)
            end
            expect(#test2).to.equal(#test)
        end)

        it("should copy flat dictionaries correctly", function()
            local test = { a = 1; b = 2; c = 3; [true] = false }
            local test2 = Utils.deepcopy(test)

            expect(test2).to.be.a("table")
            for i, v in pairs(test) do
                expect(test2[i]).to.equal(v)
            end
            for i, v in pairs(test2) do
                expect(test[i]).to.equal(v)
            end
            expect(#test2).to.equal(#test)
        end)

        it("should copy flat mixed tables correctly", function()
            local test = {
                a = "Test";
                42;
                1337;
                b = "Hello world!";
                c = 123;
                "Testing!";
            }
            local test2 = Utils.deepcopy(test)

            expect(test2).to.be.a("table")
            for i, v in pairs(test) do
                expect(test2[i]).to.equal(v)
            end
            for i, v in pairs(test2) do
                expect(test[i]).to.equal(v)
            end
            expect(#test2).to.equal(#test)
        end)

        it("should copy nested arrays/dictionaries/mixed tables correctly", function()
            local test = {
                a = { 42; };
                b = {
                    c = 3.14;
                    d = { "Testing"; 1; 2; 3 };
                    "w";
                    "t";
                    "f";
                };
                e = {};
            }
            local test2 = Utils.deepcopy(test)

            expect(test2).to.be.a("table")
            expect(#test2).to.equal(#test)

            expect(test2.a).to.be.a("table")
            expect(#test2.a).to.equal(#test.a)
            expect(test2.a[1]).to.equal(test.a[1])

            expect(test2.b).to.be.a("table")
            expect(#test2.b).to.equal(#test.b)
            expect(test2.b.c).to.equal(test.b.c)
            expect(test2.b.d).to.a("table")
            for i = 1, 4 do
                expect(test2.b.d[i]).to.equal(test.b.d[i])
            end
            expect(#test2.b.d).to.equal(#test.b.d)
            for i = 1, 3 do
                expect(test2.b[i]).to.equal(test.b[i])
            end

            expect(test2.e).to.be.a("table")
            expect(#test2.e).to.equal(#test.e)
        end)

    end)

    describe("Utils.scanValidity", function()

        it("should report nothing for proper entries", function()
            local test1 = { a = 1; b = {1; 2; 3}; c = 3; }
            local test2 = { a = "Test"; b = {true; false; true}; c = "Hello world!"; }

            expect(Utils.scanValidity(test1)).to.equal(true)
            expect(Utils.scanValidity(test2)).to.equal(true)
        end)

        it("should report invalidly typed values", function()
            local test1 = { a = function() end; b = 2; c = 3; }
            local test2 = { a = 1; b = {"a"; Instance.new("Part"); "c"}; c = Instance.new("Model"); }
            local test3 = { a = 1; b = coroutine.create(function() end); c = {coroutine.create(function() end)}; }

            local isValid, keyPath, reason = Utils.scanValidity(test1)
            expect(isValid).to.equal(false)
            expect(keyPath).to.be.ok()
            expect(reason).to.be.ok()

            isValid, keyPath, reason = Utils.scanValidity(test2)
            expect(isValid).to.equal(false)
            expect(keyPath).to.be.ok()
            expect(reason).to.be.ok()

            isValid, keyPath, reason = Utils.scanValidity(test3)
            expect(isValid).to.equal(false)
            expect(keyPath).to.be.ok()
            expect(reason).to.be.ok()
        end)

        it("should report mixed tables", function()
            local test1 = { a = 1; 2; 3; }
            local test2 = { a = { "1"; b = "2"; "3" }; b = 2; }

            local isValid, keyPath, reason = Utils.scanValidity(test1)
            expect(isValid).to.equal(false)
            expect(keyPath).to.be.ok()
            expect(reason).to.be.ok()

            isValid, keyPath, reason = Utils.scanValidity(test2)
            expect(isValid).to.equal(false)
            expect(keyPath).to.be.ok()
            expect(reason).to.be.ok()
        end)

        it("should report array tables with holes", function()
            local test = { [1] = "a"; [2] = "b"; [4] = "c"; [-1] = "d"}

            local isValid, keyPath, reason = Utils.scanValidity(test)
            expect(isValid).to.equal(false)
            expect(keyPath).to.be.ok()
            expect(reason).to.be.ok()
        end)

        it("should report float indices", function()
            local test = { [-1.4] = "a"; [math.pi] = "b"; [1/9] = "c"; }

            local isValid, keyPath, reason = Utils.scanValidity(test)
            expect(isValid).to.equal(false)
            expect(keyPath).to.be.ok()
            expect(reason).to.be.ok()
        end)

        it("should report invalidly typed indices", function()
            local test = { [true] = "a"; [function() end] = "b"; [Instance.new("Part")] = "c"; }

            local isValid, keyPath, reason = Utils.scanValidity(test)
            expect(isValid).to.equal(false)
            expect(keyPath).to.be.ok()
            expect(reason).to.be.ok()
        end)

        it("should report cyclic tables", function()
            local test1 = { level = { baz = 3; }; foo = 1; bar = 2; }
            test1.level.test = test1
            local test2 = { recursion = {}; }
            test2.recursion.recursion = test2.recursion

            local isValid, keyPath, reason = Utils.scanValidity(test1)
            expect(isValid).to.equal(false)
            expect(keyPath).to.be.ok()
            expect(reason).to.be.ok()

            isValid, keyPath, reason = Utils.scanValidity(test2)
            expect(isValid).to.equal(false)
            expect(keyPath).to.be.ok()
            expect(reason).to.be.ok()
        end)

        it("should report infinite/-infinite indices", function()
            local test = { [-math.huge] = "Hello"; [math.huge] = "world!"; }

            local isValid, keyPath, reason = Utils.scanValidity(test)
            expect(isValid).to.equal(false)
            expect(keyPath).to.be.ok()
            expect(reason).to.be.ok()
        end)

    end)

    describe("Utils.getStringPath", function()

        it("should format paths in the expected way", function()
            local path = { "foo"; "bar"; "baz"; }

            expect(Utils.getStringPath(path)).to.equal("foo.bar.baz")
        end)

    end)

    -- Utils.importPairsFromTable is not tested here, but through
    -- DataStoreService/GlobalDataStore/OrderedDataStore:ImportFromJSON(...)

    describe("Utils.prepareDataStoresForExport", function()

        it("should strip off empty scopes", function()
            local stores = { TestScope = {Key1 = 1; Key2 = 2; Key3 = 3}; TestScope2 = {}; }

            stores = Utils.prepareDataStoresForExport(stores)
            expect(stores.TestScope).to.be.ok()
            expect(stores.TestScope2).to.never.be.ok()
        end)

        it("should return nothing if entirely empty", function()
            local stores = { TestScope = {}; TestScope2 = {}; TestScope3 = {}; }

            expect(Utils.prepareDataStoresForExport(stores)).to.never.be.ok()
        end)

    end)

end