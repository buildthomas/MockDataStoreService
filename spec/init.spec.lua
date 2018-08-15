return function()

    local DataStoreService = require(script.Parent.Parent.DataStoreService)

    describe("DataStoreService", function()

        it("should return the MockDataStoreService in the test environment", function()
            local MockDataStoreService = require(script.Parent.Parent.DataStoreService.MockDataStoreService)

            expect(MockDataStoreService).to.equal(DataStoreService)
        end)

    end)

end