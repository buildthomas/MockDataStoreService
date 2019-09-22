local Test = {}

local MockDataStoreService_Module = script.Parent.Parent.Parent.DataStoreService.MockDataStoreService

Test.Service = require(MockDataStoreService_Module)
Test.Constants = require(MockDataStoreService_Module.MockDataStoreConstants)
Test.Manager = require(MockDataStoreService_Module.MockDataStoreManager)
Test.Utils = require(MockDataStoreService_Module.MockDataStoreUtils)
Test.Pages = require(MockDataStoreService_Module.MockDataStorePages)

Test.Constants.YIELD_TIME_MIN = 0
Test.Constants.YIELD_TIME_MAX = 0
Test.Constants.YIELD_TIME_UPDATE_MIN = 0
Test.Constants.YIELD_TIME_UPDATE_MAX = 0

local capturedBudgets = {}

function Test.reset()
    Test.Manager:ResetData()
    Test.Manager:ResetBudget()
    Test.Manager:ThawBudgetUpdates()
    capturedBudgets = {}
end

function Test.subsetOf(t1, t2)
    if type(t1) ~= "table" or type(t2) ~= "table" then
        return t1 == t2
    end
    for key, value in pairs(t1) do
        if type(value) == "table" then
            if type(t2[key]) == "table" then
                if not Test.subsetOf(t1[key], t2[key]) then
                    return false
                end
            else
                return false
            end
        elseif t1[key] ~= t2[key] then
            return false
        end
    end
    return true
end

function Test.setStaticBudgets(var)
    Test.Manager:FreezeBudgetUpdates()
    if type(var) == "number" then
        local budget = var
        for _,v in pairs(Enum.DataStoreRequestType:GetEnumItems()) do
            Test.Manager:SetBudget(v, budget)
        end
    elseif type(var) == "table" then
        local budgets = var
        for requestType, budget in pairs(budgets) do
            Test.Manager:SetBudget(requestType, budget)
        end
    end
end

function Test.captureBudget()
    for _,v in pairs(Enum.DataStoreRequestType:GetEnumItems()) do
        if v ~= Enum.DataStoreRequestType.UpdateAsync then
            capturedBudgets[v] = Test.Manager:GetBudget(v)
        end
    end
end

function Test.checkpointBudget(checkpoint)
    local match = true
    for requestType, difference in pairs(checkpoint) do
        if Test.Manager:GetBudget(requestType) - capturedBudgets[requestType] ~= difference then
            match = nil
            break
        end
        capturedBudgets[requestType] = nil
    end
    if match then
        for requestType, budget in pairs(capturedBudgets) do
            if Test.Manager:GetBudget(requestType) ~= budget then
                match = nil
            end
        end
    end
    Test.captureBudget()
    return match
end

return Test