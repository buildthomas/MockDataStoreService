return function()

    local function getDataStoreService()
        local MockDataStoreService = script.Parent.Parent.Parent.DataStoreService.MockDataStoreService:Clone()
        local Constants = require(MockDataStoreService.MockDataStoreConstants)
        Constants.YIELD_TIME_MIN = 0.01
        Constants.YIELD_TIME_MAX = 0.02
        Constants.YIELD_TIME_UPDATE_MIN = 0.04
        Constants.YIELD_TIME_UPDATE_MAX = 0.08
        return require(MockDataStoreService)
    end

    describe("MockDataStoreService", function()

        it("should expose all API members", function()
            local MockDataStoreService = getDataStoreService()
            expect(MockDataStoreService.GetDataStore).to.be.a("function")
            expect(MockDataStoreService.GetGlobalDataStore).to.be.a("function")
            expect(MockDataStoreService.GetOrderedDataStore).to.be.a("function")
            expect(MockDataStoreService.GetRequestBudgetForRequestType).to.be.a("function")
            expect(MockDataStoreService.ImportFromJSON).to.be.a("function")
            expect(MockDataStoreService.ExportFromJSON).to.be.a("function")
        end)

    end)

    describe("MockDataStoreService::GetDataStore", function()

        it("should reject invalid input", function()
            local MockDataStoreService = getDataStoreService()

            expect(function()
                MockDataStoreService:GetDataStore("Test", 123)
            end).to.throw()

            expect(function()
                MockDataStoreService:GetDataStore(("a"):rep(51), "Test")
            end).to.throw()

            expect(function()
                MockDataStoreService:GetDataStore(123, "Test")
            end).to.throw()

            expect(function()
                MockDataStoreService:GetDataStore(123, "Test")
            end).to.throw()

            expect(function()
                MockDataStoreService:GetDataStore(123, "Test")
            end).to.throw()

            expect(function()
                MockDataStoreService:GetDataStore(123, "Test")
            end).to.throw()

            expect(function()
                MockDataStoreService:GetDataStore(123, "Test")
            end).to.throw()

            expect(function()
                MockDataStoreService:GetDataStore(123, "Test")
            end).to.throw()

            expect(function()
                MockDataStoreService:GetDataStore(123, "Test")
            end).to.throw()

        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

    end)

    describe("MockDataStoreService::GetGlobalDataStore", function()

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

    end)

    describe("MockDataStoreService::GetOrderedDataStore", function()

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

    end)

    describe("MockDataStoreService::GetRequestBudgetForRequestType", function()

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

    end)

    describe("MockDataStoreService::ImportFromJSON", function()

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

        it("", function()
            
        end)

    end)

    describe("MockDataStoreService::ExportToJSON", function()

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