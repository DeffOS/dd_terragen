local format = string.format
local netChannel = "ddterra.netchannel"
module("ddterra.netchannel",package.seeall)
Channels = Channels or {}

ChannelKeys = ChannelKeys or {
	_list = {},
	_count = 0
}

UIntIdBitcount = UIntIdBitcount or 1

local function calcBitCount()
	UIntIdBitcount = math.ceil(math.log(ChannelKeys._count + 1,2))
end

local function getChannelID(key)
	local id = ChannelKeys._list[key:lower()]
	assert(id,format("getChannelID - Bad Argument #1 - String channel name (%s) is not registered! \n",key))

	return id
end

function RegisterKey(key)
	assert(isstring(key),format("RegisterKey - Bad Argument #1 - Expected string, got %s \n",type(key)))
	key = key:lower()
	//assert(!ChannelKeys._list[key],format("RegisterChannelKey - Bad Argument #1 - Key (%s) is already registered!\n",key))
	if ChannelKeys._list[key] then return end
	local count = ChannelKeys._count + 1
	ChannelKeys[count] = key
	ChannelKeys._list[key] = count
	ChannelKeys._count = count
	calcBitCount()
end

function SetCallback(key,func)
	assert(isstring(key),format("SetCallback - Bad Argument #1 - Expected string, got %s \n",type(key)))
	assert(isfunction(func),format("SetCallback - Bad Argument #2 - Expected function, got %s \n",type(func)))
	Channels[getChannelID(key)] = func
end

function RemoveCallback(key)
	assert(isstring(key),format("RemoveCallback - Bad Argument #1 - Expected string, got %s \n",type(key)))
	Channels[getChannelID(key)] = nil
end

function Start(key,unrelaeble)
	assert(isstring(key),format("Start - Bad Argument #1 - Expected string, got %s \n",type(key)))
	local id = getChannelID(key)
	net.Start(netChannel,unrelaeble)
	net.WriteUInt(id,UIntIdBitcount)
end

local function runChannel(len,ply)
	local func = Channels[net.ReadUInt(UIntIdBitcount)]
	if !func then return end

	return func(len,ply)
end

net.Receive(netChannel,runChannel)
if CLIENT then return end
util.AddNetworkString(netChannel)