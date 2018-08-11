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

    BUDGET_GETASYNC_START = 60;		    -- Starting budget
    BUDGET_GETASYNC_RATE = 60;          -- Added budget per minute
    BUDGET_GETASYNC_RATE_PLR = 10;      -- Additional added budget per minute per player
    BUDGET_GETASYNC_MAX_FACTOR = 3;     -- The maximum budget as a factor of (rate + rate_plr * #players)

    BUDGET_GETSORTEDASYNC_START = 5;
    BUDGET_GETSORTEDASYNC_RATE = 5;
    BUDGET_GETSORTEDASYNC_RATE_PLR = 2;
    BUDGET_GETSORTEDASYNC_MAX_FACTOR = 3;

    BUDGET_ONUPDATE_START = 30;
    BUDGET_ONUPDATE_RATE = 30;
    BUDGET_ONUPDATE_RATE_PLR = 5;
    BUDGET_ONUPDATE_MAX_FACTOR = 1;

    BUDGET_SETINCRASYNC_START = 60;
    BUDGET_SETINCRASYNC_RATE = 60;
    BUDGET_SETINCRASYNC_RATE_PLR = 10;
    BUDGET_SETINCRASYNC_MAX_FACTOR = 3;

    BUDGET_SETINCRSORTEDASYNC_START = 30;
    BUDGET_SETINCRSORTEDASYNC_RATE = 30;
    BUDGET_SETINCRSORTEDASYNC_RATE_PLR = 5;
    BUDGET_SETINCRSORTEDASYNC_MAX_FACTOR = 3;

    BUDGET_UPDATEASYNC_START = 60;
    BUDGET_UPDATEASYNC_RATE = 60;
    BUDGET_UPDATEASYNC_RATE_PLR = 10;
    BUDGET_UPDATEASYNC_MAX_FACTOR = 3;

}