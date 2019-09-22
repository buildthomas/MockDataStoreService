return function()
    local Test = require(script.Parent.Test)

    describe("MockDataStorePages", function()

        it("should expose all API members", function()
            Test.reset()
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            local MockDataStorePages = MockOrderedDataStore:GetSortedAsync(true, 100)

            expect(MockDataStorePages.AdvanceToNextPageAsync).to.be.a("function")
            expect(MockDataStorePages.GetCurrentPage).to.be.a("function")
            expect(MockDataStorePages.IsFinished).to.be.a("boolean")

        end)

    end)

    describe("MockDataStorePages::AdvanceToNextPageAsync", function()

        it("should get all results", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            local totalResults = 1021

            local data = {}
            for i = 1, totalResults do
                data["TestKey"..i] = i
            end

            MockOrderedDataStore:ImportFromJSON(data)

            local numResults = 0
            local MockDataStorePages = MockOrderedDataStore:GetSortedAsync(true, 50)
            expect(MockDataStorePages.IsFinished).to.equal(false)
            repeat
                numResults = numResults + #MockDataStorePages:GetCurrentPage()
            until MockDataStorePages.IsFinished or MockDataStorePages:AdvanceToNextPageAsync()

            expect(numResults).to.equal(totalResults)

        end)

        it("should report correctly ordered results for ascending mode", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            local totalResults = 1000

            local data = {}
            for i = 1, totalResults do
                data["TestKey"..i] = i
            end

            MockOrderedDataStore:ImportFromJSON(data)

            local MockDataStorePages = MockOrderedDataStore:GetSortedAsync(true, 100)
            local previous = -math.huge
            repeat
                for _, pair in ipairs(MockDataStorePages:GetCurrentPage()) do
                    expect(previous <= pair.value).to.equal(true)
                    previous = pair.value
                end
            until MockDataStorePages.IsFinished or MockDataStorePages:AdvanceToNextPageAsync()

        end)

        it("should report correctly ordered results for descending mode", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            local totalResults = 1000

            local data = {}
            for i = 1, totalResults do
                data["TestKey"..i] = i
            end

            MockOrderedDataStore:ImportFromJSON(data)

            local MockDataStorePages = MockOrderedDataStore:GetSortedAsync(false, 100)
            local previous = math.huge
            repeat
                for _, pair in ipairs(MockDataStorePages:GetCurrentPage()) do
                    expect(previous >= pair.value).to.equal(true)
                    previous = pair.value
                end
            until MockDataStorePages.IsFinished or MockDataStorePages:AdvanceToNextPageAsync()

        end)

        it("should not exceed page size for each page of results", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            local totalResults = 918

            local data = {}
            for i = 1, totalResults do
                data["TestKey"..i] = i
            end

            MockOrderedDataStore:ImportFromJSON(data)

            local MockDataStorePages = MockOrderedDataStore:GetSortedAsync(true, 43)
            repeat
                if not MockDataStorePages.IsFinished then
                    expect(#MockDataStorePages:GetCurrentPage()).to.equal(43)
                else
                   expect(#MockDataStorePages:GetCurrentPage() <= 43).to.equal(true)
                end
            until MockDataStorePages.IsFinished or MockDataStorePages:AdvanceToNextPageAsync()

        end)

        it("should report values if and only if they are in range", function()
            Test.reset()
            Test.setStaticBudgets(1e3)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            local totalResults = 1000

            local data = {}
            for i = 1, totalResults do
                data["TestKey"..i] = i
            end

            MockOrderedDataStore:ImportFromJSON(data)

            local function test(isAscending, pageSize, minValue, maxValue)
                local MockDataStorePages = MockOrderedDataStore:GetSortedAsync(
                    isAscending,
                    pageSize,
                    minValue,
                    maxValue
                )
                minValue = minValue or -math.huge
                maxValue = maxValue or math.huge
                repeat
                    for _, pair in ipairs(MockDataStorePages:GetCurrentPage()) do
                        expect(pair.value >= minValue).to.equal(true)
                        expect(pair.value <= maxValue).to.equal(true)
                    end
                until MockDataStorePages.IsFinished or MockDataStorePages:AdvanceToNextPageAsync()
            end

            test(true, 100, nil, -5)
            test(true, 100, nil, 234)
            test(true, 100, nil, 1592)

            test(false, 100, nil, -5)
            test(false, 100, nil, 234)
            test(false, 100, nil, 1592)

            test(true, 100, 1023, nil)
            test(true, 100, 689, nil)
            test(true, 100, -102, nil)

            test(false, 100, 1023, nil)
            test(false, 100, 689, nil)
            test(false, 100, -102, nil)

            test(true, 100, -123, -49)
            test(true, 100, -148, 184)
            test(true, 100, -94, 1194)
            test(true, 100, 395, 748)
            test(true, 100, 859, 1048)
            test(true, 100, 1038, 1492)

            test(false, 100, -123, -49)
            test(false, 100, -148, 184)
            test(false, 100, -94, 1194)
            test(false, 100, 395, 748)
            test(false, 100, 859, 1048)
            test(false, 100, 1038, 1492)

        end)

        it("should throw when no more pages left", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            local data = {}
            for i = 1, 76 do
                data["TestKey"..i] = i
            end

            MockOrderedDataStore:ImportFromJSON(data)

            local MockDataStorePages = MockOrderedDataStore:GetSortedAsync(true, 100) -- exceeds 76

            expect(MockDataStorePages.IsFinished).to.equal(true)
            expect(function()
                MockDataStorePages:AdvanceToNextPageAsync()
            end).to.throw()

        end)

        it("should consume budgets correctly", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            local data = {}
            for i = 1, 1000 do
                data["TestKey"..i] = i
            end

            MockOrderedDataStore:ImportFromJSON(data)

            local MockDataStorePages = MockOrderedDataStore:GetSortedAsync(true, 10)

            Test.setStaticBudgets(1e3)

            Test.captureBudget()

            for _ = 1, 42 do
                MockDataStorePages:AdvanceToNextPageAsync()
                expect(Test.checkpointBudget{
                    [Enum.DataStoreRequestType.GetSortedAsync] = -1;
                }).to.be.ok()
            end

        end)

        it("should throttle correctly when out of budget", function()
            -- TODO
        end)

    end)

    describe("MockDataStorePages::GetCurrentPage", function()

        it("should return a table", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            local MockDataStorePages = MockOrderedDataStore:GetSortedAsync(true, 100)

            expect(MockDataStorePages:GetCurrentPage()).to.be.a("table")

        end)

        it("should not allow mutation of values indirectly", function()
            Test.reset()
            Test.setStaticBudgets(100)
            local MockOrderedDataStore = Test.Service:GetOrderedDataStore("Test")

            local data = {}
            for i = 1, 100 do
                data["TestKey"..i] = i
            end

            MockOrderedDataStore:ImportFromJSON(data)

            local MockDataStorePages = MockOrderedDataStore:GetSortedAsync(true, 100)

            local result = MockDataStorePages:GetCurrentPage()

            result[1].value = 10001
            result[2].value = 10002
            result[3].value = 10003
            result[4].key = "This is not the actual key..."
            result[5].key = true
            for i = 97,100 do
                result[i] = nil
            end

            result = MockDataStorePages:GetCurrentPage()

            expect(#result).to.equal(100)
            for i = 1, 100 do
                expect(result[i]).to.be.ok()
                expect(result[i].key).to.equal("TestKey"..i)
                expect(result[i].value).to.equal(i)
            end

        end)

    end)

end