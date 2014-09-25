--[[

Common Functions Version 1.3 Dev
Do not modify, copy or distribute without permission of author
Helkarakse 20130614

Changelog:
1.3 - Removed MiscPeripherals related segments - 20131201
1.2 - Changed encrypt function to accept multiple arguments - 20130614
]]--

-- String Functions
function explode(divider, inputString)
	if (divider == '') then return false end
	local charPos, array = 0, {}
	for stringStart, stringEnd in function() return string.find(inputString, divider, charPos, true) end do
		table.insert(array, string.sub(inputString, charPos,stringStart - 1))
		charPos = stringEnd + 1
	end

	table.insert(array,string.sub(inputString, charPos))
	return array
end

-- Truncates a string and appends ellipsis to end
function truncate(inputString, limit)
	if (#inputString < limit) then
		return inputString
	else
		return string.sub(inputString, 1, (limit - 3)) .. "..."
	end
end

function buildString(...)
	local tempString = ""
	for i,v in ipairs(arg) do
		tempString = tempString .. tostring(v) .. " "
	end
	return tempString
end

-- Logging
function log(...)
	local logHandle = fs.open("log", "a")

	local output = ""
	for i,v in ipairs(arg) do
		output = output .. tostring(v) .. "\t"
	end
	output = output .. "\n"

	logHandle.writeLine("LOG> " .. output)
	logHandle.close()
end

-- debug level debugging message
function debug(...)
	local printResult = ""
	for i,v in ipairs(arg) do
		printResult = printResult .. tostring(v) .. "\t"
	end
	print("DEBUG> " .. printResult)
end

-- info level debugging message
function info(...)
	local printResult = ""
	for i,v in ipairs(arg) do
		printResult = printResult .. tostring(v) .. "\t"
	end
	print("INFO> " .. printResult)
end

-- error level debugging message
function error(...)
	local printResult = ""
	for i,v in ipairs(arg) do
		printResult = printResult .. tostring(v) .. "\t"
	end
	print("ERROR> " .. printResult)
end

-- Peripherals
-- checks sides for a peripheral, returns true if found, false if not
function locatePeripheral(peripheralType)
	local dirs = { "top", "bottom", "back", "front", "left", "right" }
	local found = {}
	for i, dir in ipairs(dirs) do
		if peripheral.isPresent(dir) and peripheral.getType(dir) == peripheralType then
			print("Found " .. peripheralType .. " peripheral. Location = " .. dir)
			return true, dir
		end
	end
	return false, peripheralType .. " not found on all sides."
end


-- Table Functions
function writeTable(table,name)
	local file = fs.open(name,"w")
	file.write(textutils.serialize(table))
	file.close()
end

function readTable(name)
	debug("Checking if table exists...")
	if (fs.exists(name) ~= true) then
		return false, {}
	end

	debug("Table found, reading it now.")
	local file = fs.open(name,"r")
	local data = file.readAll()
	file.close()
	return true, textutils.unserialize(data)
end

function readLookup(name)
	local file = fs.open(name, "r")
	local outputTable = {}
	local eof = false;
	while(not eof) do
		local line = file.readLine()

		if (line ~= nil) then
			local tempTable = explode("|", line)
			outputTable[tempTable[1]] = tempTable[2]
		else
			eof = true
		end
	end
	file.close()
	return outputTable
end

function tablePrint(inputTable, indent, done)
	done = done or {}
	indent = indent or 0
	if type(inputTable) == "table" then
		local stringBuilt = {}
		for key, value in pairs (inputTable) do
			table.insert(stringBuilt, string.rep (" ", indent))
			if type (value) == "table" and not done [value] then
				done [value] = true
				table.insert(stringBuilt, "{\n");
				table.insert(stringBuilt, tablePrint(value, indent + 2, done))
				table.insert(stringBuilt, string.rep (" ", indent))
				table.insert(stringBuilt, "}\n");
			elseif "number" == type(key) then
				table.insert(stringBuilt, string.format("\"%outputString\"\n", tostring(value)))
			else
				table.insert(stringBuilt, string.format("%outputString = \"%outputString\"\n", tostring (key), tostring(value)))
			end
		end
		return table.concat(stringBuilt)
	else
		return inputTable .. "\n"
	end
end

function getTableCount(table)
	local count = 0
	for key, value in pairs(table) do
		count = count + 1
	end
	return count
end

-- Miscellaneous
function runFuncFor(func,timeout,tArgs, eventType)
	local result = nil
	local co = coroutine.wrap(
		function()
			os.queueEvent('done', func(unpack(tArgs or {})))
		end
	)

	local event = {}
	local timer = os.startTimer(timeout)

	while true do
		co(unpack(event))
		event = { os.pullEvent(eventType or "") }
		if (event[1] == "timer") then
			return nil
		elseif (event[1] == "done") then
			return event
		end
	end
end

function roundTo(number, decimal)
	return tonumber(string.format("%." .. (decimal or 0) .. "f", tonumber(number)))
end

function switch(table)
	table.case = function (self, param)
		local func = self[param] or self.default
		if (func) then
			if type(func) == "function" then
				func(param, self)
			else
				error("Case " .. tostring(param) .. " is not a function")
			end
		end
	end

	return table
end

-- Convert decimal number to hexadecimal
function decToHex(inputDec)
	local hexString = '0123456789ABCDEF'
	local outputString = ''

	while inputDec > 0 do
		local mod = math.fmod(inputDec, 16)
		outputString = string.sub(hexString, mod+1, mod+1) .. outputString
		inputDec = math.floor(inputDec / 16)
	end

	if (outputString == '') then
		outputString = '0'
	end
	return outputString
end

function stripCData(inputString)
	return string.gsub(inputString, '^<!%[CDATA%[(.-)%]%]>', "%1")
end