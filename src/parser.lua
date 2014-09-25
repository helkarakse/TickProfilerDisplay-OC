--[[

    TickProfiler JSON Data Parser
    Do not modify, copy or distribute without permission of author
    Helkarakse, 20131128
    
    Changelog:
    - 1.3 Added the dimension resolution for dimension ids into the parser
    - 1.2 Moved the tps color and percentage color functions into parser
    - 1.1.1 Added dimension name resolution for nether, overworld and end - 20131201
    - 1.1 Fixed the functions.explode call nil issue - 20131201
    - 1.0 Added all the methods - 20131128
    
]]

-- following json format, first key is tps, 
-- second key is array for single entity, 
-- third key is array for chunk,
-- fourth key is array for entity by type,
-- fifth key is array for average entity

-- Libraries
local json = require("json")

local parser = {}

-- Variables
local stringData, tableData, stringTps, tableSingleEntity, tableChunk, tableEntityByType, tableAverageCalls, stringUpdated

-- References
local tonumber = tonumber
local tostring = tostring
local colors = colors

-- Dimension names
local dimArray = {
    {dimensionId = 0, dimensionName = "Overworld"},
    {dimensionId = -1, dimensionName = "Nether"},
    {dimensionId = 1, dimensionName = "The End"},
    {dimensionId = 4, dimensionName = "Public Mining"},
    {dimensionId = 7, dimensionName = "Twilight Forest"},
    {dimensionId = 8, dimensionName = "Silver Mining"},
    {dimensionId = 9, dimensionName = "Gold Mining"},
    {dimensionId = -31, dimensionName = "Secret Cow Level"},
    {dimensionId = -20, dimensionName = "Promised Lands"},
    {dimensionId = 100, dimensionName = "Deep Dark"},
}

local hexColor = {
    red = 0xFF0000,
    green = 0x00FF00,
    yellow = 0xFFFF00
}

-- Main Functions
-- Parses the json string and initializes each table variable. Returns true on successful parse, false on empty string passed.
function parser.parseData(stringInput)
    if (stringInput == "") then
        return false
    else
        stringData = stringInput
        jsonData = json.decode(stringData)
        tableData = jsonData.result
        stringTps = tableData.tps.tps
        tableSingleEntity = tableData.single
        tableChunk = tableData.chunk
        tableEntityByType = tableData.type
        tableAverageCalls = tableData.call
        stringUpdated = tableData.tps.last_update
        return true
    end
end

-- Last Updated
function parser.getUpdatedDate()
    return stringUpdated
end

-- TPS
-- Returns the exact tps value as listed in the profile
function parser.getExactTps()
    return stringTps
end

-- Rounds the tps value to given decimal places and returns it
-- Fixed, but not accurately rounding the number (using strsub method)
function parser.getTps()
    local tps = getExactTps()
    if (tonumber(tps) ~= nil) then
        if (tonumber(tps) > 20)then
            return "20.00"
        else
            return tostring(tps)
        end
    else
        return "Unknown"
    end
end

-- Returns the dimension name given the server and dimension id
-- If the dimension id is a known minecraft constant, it does not lookup
-- the array.
local function getDimensionName(dimensionId)
    for key, value in pairs(dimArray) do
        if (value.dimensionId == tonumber(dimensionId)) then
            return value.dimensionName
        end
    end
    return "Unknown"
end

-- SingleEntities
-- Returns a table containing single entities that cause lag. 
-- Each row is a table containing the following keys: 
-- percent: percentage of time/tick, time: time/tick, name: name of entity, position: position of entity, dimension: formatted dimension text
function parser.getSingleEntities()
    local returnTable = {}
    
    if (type(tableSingleEntity) == "table") then
        for key, value in pairs(tableSingleEntity) do
            local row = {}
            row.percent = tostring(value.percentage)
            row.time = tostring(value.time)
            row.name = value.name
            row.dimension = value.dimension
            row.position = value.position
            
            table.insert(returnTable, row)
        end
    end
    
    return returnTable
end

-- Chunks
-- Returns a table containing the chunks that cause lag.
-- Each row is a table containing the following keys:
-- percent: percentage of time/tick, time: time/tick, positionX: X coordinate of chunk, positionZ: Z coordinate of chunk, dimension: dimension of chunk
function parser.getChunks()
    local returnTable = {}
    
    if (type(tableChunk) == "table") then
    for key, value in pairs(tableChunk) do
        local row = {}
        row.percent = tostring(value.percentage)
        row.time = tostring(value.time)
        row.positionX = tonumber(value.chunkX) * 16
        row.positionZ = tonumber(value.chunkZ) * 16
        row.dimension = value.dimension
        
        table.insert(returnTable, row)
    end
    end
    
    return returnTable
end

-- EntityByTypes
-- Returns a table containing the types of entities causing the most lag
-- Each row is a table containing the following keys:
-- percent: percentage of time/tick, time: time/tick, type: the type of entity that is listed
function parser.getEntityByTypes()
    local returnTable = {}
    
    if (type(tableEntityByType) == "table") then
    for key, value in pairs(tableEntityByType) do
        local row = {}
        row.percent = tostring(value.percentage)
        row.time = tostring(value.time)
        row.type = value.name
        
        table.insert(returnTable, row)
    end
    end
    
    return returnTable
end

-- AverageCallsPerEntity
-- Returns a table containing the top average calls made by specific entities
-- Each row is a table containing the following keys:
-- name: name of entity, time: time/tick, calls: number of calls made

function parser.getAverageCalls()
    local returnTable = {}
    
    if (type(tableAverageCalls) == "table") then
    for key, value in pairs(tableAverageCalls) do
        local row = {}
        row.time = tostring(value.time)
        row.name = value.name
        row.calls = tostring(value.calls)
        
        table.insert(returnTable, row)
    end
    end
    
    return returnTable
end

-- Miscellaneous Functions
-- Returns the color for the percentage based on severity
function parser.getPercentColor(percent)
    local percentage = tonumber(percent)
    local percentageColor
    if (percentage >= 5) then
        percentageColor = colors.red
    elseif (percentage >= 3 and percentage < 5) then
        percentageColor = colors.yellow
    elseif (percentage >= 0 and percentage < 3) then
        percentageColor = colors.green
    end
    
    return percentageColor
end

-- Returns the color for the percentage based on severity
-- Hex version for glasses
function parser.getPercentHexColor(percent)
    local percentage = tonumber(percent)
    local percentageColor
    if (percentage >= 5) then
        percentageColor = hexColor.red
    elseif (percentage >= 3 and percentage < 5) then
        percentageColor = hexColor.yellow
    elseif (percentage >= 0 and percentage < 3) then
        percentageColor = hexColor.green
    end
    
    return percentageColor
end

-- Returns the color for the TPS based on severity
function parser.getTpsColor(tps)
    local tpsColor
    local tps = tonumber(tps)
    if (tps >= 18) then
            tpsColor = colors.green
    elseif (tps >= 15 and tps < 18) then
            tpsColor = colors.yellow
    elseif (tps < 15) then
            tpsColor = colors.red
    end
    
    return tpsColor
end

function parser.getTpsHexColor(tps)
    local tpsColor
    local tps = tonumber(tps)
    if (tps >= 18) then
            tpsColor = hexColor.green
    elseif (tps >= 15 and tps < 18) then
            tpsColor = hexColor.yellow
    elseif (tps < 15) then
            tpsColor = hexColor.red
    end
    
    return tpsColor
end

return parser