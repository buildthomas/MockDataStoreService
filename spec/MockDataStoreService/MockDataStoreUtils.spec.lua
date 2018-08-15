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
                a = { 42 };
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

        it("", function()
        
        end)

        it("", function()
        
        end)

        it("", function()
        
        end)

        it("", function()
        
        end)

        it("", function()
        
        end)

        it("", function()
        
        end)

        it("", function()
        
        end)

        it("", function()
        
        end)

        it("", function()
        
        end)

    end)

    describe("Utils.getStringPath", function()

        it("should format paths in the expected way", function()
            local path = { "foo"; "bar"; "baz"; }

            expect(Utils.getStringPath(path)).to.equal("foo.bar.baz")
        end)

    end)

    describe("Utils.importPairsFromTable", function()
        
    end)

    describe("Utils.prepareDataStoresForExport", function()

        it("", function()
            local DataStores = {}


        end)

        it("", function()
        
        end)

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