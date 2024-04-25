local format = string.format
module("ddterra.event",package.seeall)
local Events = {}

local function isKeyValid(key)
	return key == nil || isnumber(key) || isbool(key) || isfunction(key) || !key.IsValid || !IsValid(key)
end

function Add(event,key,func)
	assert(isstring(event),format("event.Add - Bad Argument #1 - Expected string, got %s \n",type(event)))
	assert(isKeyValid(key),format("event.Add - Bad Argument #2 - Expected string/entity, got %s \n",type(key)))
	assert(isfunction(func),format("event.Add - Bad Argument #3 - Expected function, got %s \n",type(func)))

	if !Events[event] then
		Events[event] = {}
	end

	Events[event][key] = func
end

function Remove(event,key)
	assert(isstring(event),format("event.Remove - Bad Argument #1 - Expected string, got %s \n",type(event)))
	assert(isKeyValid(key),format("event.Remove - Bad Argument #2 - Expected string/entity, got %s \n",type(key)))
	if !Events[event] then return end
	Events[event][key] = nil
end

function Run(event,...)
	local entries = Events[event]
	if !entries then return end
	local v1,v2,v3,v4,v5,v6

	for key,func in pairs(entries) do
		if isstring(key) then
			v1,v2,v3,v4,v5,v6 = func(...)
		else
			if !IsValid(key) then
				entries[key] = nil
				continue
			end

			v1,v2,v3,v4,v5,v6 = func(key,...)
		end

		if v1 then return v1,v2,v3,v4,v5,v6 end
	end
end