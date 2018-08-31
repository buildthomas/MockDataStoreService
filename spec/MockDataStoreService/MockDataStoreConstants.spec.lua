return function()
    local Constants = require(script.Parent.Test).Constants

    local budgetTypes = {
        "BUDGET_GETASYNC";
        "BUDGET_GETSORTEDASYNC";
        "BUDGET_ONUPDATE";
        "BUDGET_SETINCREMENTASYNC";
        "BUDGET_SETINCREMENTSORTEDASYNC";
    }

    describe("Constants list", function()

        it("should be a table", function()
            expect(Constants).to.be.a("table")
        end)

        it("should contain all plain values", function()
            expect(Constants.MAX_LENGTH_KEY).to.be.a("number")
            expect(Constants.MAX_LENGTH_NAME).to.be.a("number")
            expect(Constants.MAX_LENGTH_SCOPE).to.be.a("number")
            expect(Constants.MAX_LENGTH_DATA).to.be.a("number")
            expect(Constants.MAX_PAGE_SIZE).to.be.a("number")
            expect(Constants.YIELD_TIME_MIN).to.be.a("number")
            expect(Constants.YIELD_TIME_MAX).to.be.a("number")
            expect(Constants.YIELD_TIME_UPDATE_MIN).to.be.a("number")
            expect(Constants.YIELD_TIME_UPDATE_MAX).to.be.a("number")
            expect(Constants.WRITE_COOLDOWN).to.be.a("number")
            expect(Constants.GET_COOLDOWN).to.be.a("number")
            expect(Constants.THROTTLE_QUEUE_SIZE).to.be.a("number")
            expect(Constants.BUDGETING_ENABLED).to.be.a("boolean")
            expect(Constants.BUDGET_BASE).to.be.a("number")
            expect(Constants.BUDGET_ONCLOSE_BASE).to.be.a("number")
            expect(Constants.BUDGET_UPDATE_INTERVAL).to.be.a("number")
        end)

        it("should contain all structured values", function()
            for i = 1, #budgetTypes do
                local budgetType = budgetTypes[i]
                expect(Constants[budgetType]).to.be.a("table")
                expect(Constants[budgetType].START).to.be.a("number")
                expect(Constants[budgetType].RATE).to.be.a("number")
                expect(Constants[budgetType].RATE_PLR).to.be.a("number")
                expect(Constants[budgetType].MAX_FACTOR).to.be.a("number")
            end
        end)

        it("should have positive integer limits for characters and page size", function()
            expect(Constants.MAX_LENGTH_KEY % 1).to.equal(0)
            expect(Constants.MAX_LENGTH_KEY > 0).to.equal(true)

            expect(Constants.MAX_LENGTH_NAME % 1).to.equal(0)
            expect(Constants.MAX_LENGTH_NAME > 0).to.equal(true)

            expect(Constants.MAX_LENGTH_SCOPE % 1).to.equal(0)
            expect(Constants.MAX_LENGTH_SCOPE > 0).to.equal(true)

            expect(Constants.MAX_LENGTH_DATA % 1).to.equal(0)
            expect(Constants.MAX_LENGTH_DATA > 0).to.equal(true)

            expect(Constants.MAX_PAGE_SIZE % 1).to.equal(0)
            expect(Constants.MAX_PAGE_SIZE > 0).to.equal(true)
        end)

        it("should have positive integer limits for budgeting", function()
            expect(Constants.THROTTLE_QUEUE_SIZE % 1).to.equal(0)
            expect(Constants.THROTTLE_QUEUE_SIZE > 0).to.equal(true)

            for i = 1, #budgetTypes do
                local budgetType = budgetTypes[i]
                expect(Constants[budgetType].START % 1).to.equal(0)
                expect(Constants[budgetType].START > 0).to.equal(true)

                expect(Constants[budgetType].RATE % 1).to.equal(0)
                expect(Constants[budgetType].RATE > 0).to.equal(true)

                expect(Constants[budgetType].RATE_PLR % 1).to.equal(0)
                expect(Constants[budgetType].RATE_PLR > 0).to.equal(true)

                expect(Constants[budgetType].MAX_FACTOR % 1).to.equal(0)
                expect(Constants[budgetType].MAX_FACTOR > 0).to.equal(true)
            end

            expect(Constants.BUDGET_BASE % 1).to.equal(0)
            expect(Constants.BUDGET_BASE > 0).to.equal(true)

            expect(Constants.BUDGET_ONCLOSE_BASE % 1).to.equal(0)
            expect(Constants.BUDGET_ONCLOSE_BASE > 0).to.equal(true)
        end)

        it("should have starting budgets that are within the maximum limit", function()
            for i = 1, #budgetTypes do
                local budgetType = budgetTypes[i]
                expect(Constants[budgetType].START <= Constants[budgetType].MAX_FACTOR * Constants[budgetType].RATE)
                    .to.equal(true)
            end
        end)

        it("should have non-negative time duration values", function()
            expect(Constants.YIELD_TIME_MIN >= 0).to.equal(true)
            expect(Constants.YIELD_TIME_MAX >= 0).to.equal(true)

            expect(Constants.YIELD_TIME_UPDATE_MIN >= 0).to.equal(true)
            expect(Constants.YIELD_TIME_UPDATE_MAX >= 0).to.equal(true)

            expect(Constants.WRITE_COOLDOWN >= 0).to.equal(true)
            expect(Constants.GET_COOLDOWN >= 0).to.equal(true)

            expect(Constants.BUDGET_UPDATE_INTERVAL >= 0).to.equal(true)
        end)

        it("should have consistent minima and maxima for yielding time values", function()
            expect(Constants.YIELD_TIME_MIN <= Constants.YIELD_TIME_MAX).to.equal(true)
            expect(Constants.YIELD_TIME_UPDATE_MIN <= Constants.YIELD_TIME_UPDATE_MAX).to.equal(true)
        end)

    end)

end