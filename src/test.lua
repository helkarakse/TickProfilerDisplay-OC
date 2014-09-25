local parser = require("parser")
local internet = require("internet")

local result, response = pcall(internet.request, "http://dev.otegamers.com/api/v1/tps/get/btp/1")
if (result) then
    local raw = ""
    for data in response do
        raw = raw .. data
    end

    parser:load(raw)
    print(parser:getSingle())
else
    print("Failed to retrieve data.")
end