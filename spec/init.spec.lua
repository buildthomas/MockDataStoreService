return function()

    local DataStoreService = require(script.Parent.Parent.DataStoreService)

    it("should return the MockDataStoreService", function()
        local MockDataStoreService = require(script.Parent.Parent.DataStoreService.MockDataStoreService)

        expect(MockDataStoreService).to.equal(DataStoreService)
    end)

end