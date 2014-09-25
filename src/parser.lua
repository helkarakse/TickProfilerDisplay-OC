local json = require("libJson")

local VERSION = 20140925.1
local AUTHOR_NOTE = "-[ TPS Parser by Helkarakse for OTEGamers v20140925.1 ]-"

local OBJDEF = {
   VERSION      = VERSION,
   AUTHOR_NOTE  = AUTHOR_NOTE,
}

function OBJDEF:newArray(tbl)
    return setmetatable(tbl or {}, isArray)
end

function OBJDEF:newObject(tbl)
    return setmetatable(tbl or {}, isObject)
end

function OBJDEF:load(raw)
    local data = json:decode(raw)
    return data.result.tps.tps, data.result.tps.last_update, data.result.single, data.result.chunk, data.result.type, data.result.call
    -- tps = data.result.tps.tps
    -- lastUpdated = data.result.tps.last_update

    -- tableSingle = data.result.single
    -- tableChunks = data.result.chunk
    -- tableTypes = data.result.type
    -- tableCalls = data.result.call
end

function OBJDEF.__tostring()
    return "TPS parsing package"
end

OBJDEF.__index = OBJDEF

function OBJDEF:new()
  return setmetatable({}, OBJDEF)
end

return OBJDEF:new()