--[[	MockDataStoreConstants.lua
		Contains all constants used by the entirety of MockDataStoreService and its sub-classes.

		This module is licensed under APLv2, refer to the LICENSE file or:
		https://github.com/buildthomas/MockDataStoreService/blob/master/LICENSE
]]

return {

    MAX_LENGTH_KEY = 50;			-- Max number of chars in key string
    MAX_LENGTH_NAME = 50;			-- Max number of chars in name string
    MAX_LENGTH_SCOPE = 50;			-- Max number of chars in scope string
    MAX_LENGTH_DATA = 260e3;		-- Max number of chars in (encoded) data strings

    MAX_PAGE_SIZE = 100;			-- Max page size for GetSortedAsync

    YIELD_TIME_MIN = 0.4;			-- Random yield time values for set/get/update/remove/getsorted
    YIELD_TIME_MAX = 1.0;

    YIELD_TIME_UPDATE_MIN = 1.0;	-- Random yield times from events from OnUpdate
    YIELD_TIME_UPDATE_MAX = 3.0;

    WRITE_COOLDOWN = 6.0;           -- Amount of cooldown time between writes on the same key in a particular datastore

    BUDGET_GETASYNC = 60;           -- Starting budgets for all request types
    BUDGET_GETSORTEDASYNC = 5;
    BUDGET_ONUPDATE = 30;
    BUDGET_SETINCRASYNC = 60;
    BUDGET_SETINCRSORTEDASYNC = 60;
    BUDGET_UPDATEASYNC = 60;

}