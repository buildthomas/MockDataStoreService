return function()

    describe("DataStoreService", function()

        it("should return MockDataStoreService in a test environment", function()
            local DataStoreService = require(script.Parent.Parent.DataStoreService)
            local MockDataStoreService = require(script.Parent.Parent.DataStoreService.MockDataStoreService)

            expect(MockDataStoreService).to.be.ok()
            expect(MockDataStoreService).to.equal(DataStoreService)
        end)

        it("should return the built-in DataStoreService in a live environment", function()
            local DataStoreService = require(script.Parent.Parent.DataStoreService)
            --TODO
            expect(DataStoreService).to.be.ok()
        end)

    end)

end
