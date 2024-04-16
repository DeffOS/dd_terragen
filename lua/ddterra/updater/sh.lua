local ceil = math.ceil
local log = math.log
local remove = table.remove
gameevent.Listen( "OnRequestFullUpdate" )
module("ddterra",package.seeall)
REQUEST_FULLUPDATE = 0
UPDTYPE_POINT = 1
UPDTYPE_CELL = 2
NetUInt_Index = ceil(log((WorldCellCount + 1) ^ 2,2))


do
	local TimerBody
	local updTimer = "ddterra.updatechunks"

	local updChunks = {
		_count = 0
	}

	function RequestChunkUpdate(chunk)
		local index = updChunks._count + 1
		updChunks[index] = chunk
		updChunks._count = index

		if !timer.Exists(updTimer) then
			timer.Create(updTimer,0.1,0,TimerBody)
		end
	end

	TimerBody = function()
		while updChunks._count > 0 do
			local index = updChunks._count
			local chunk = updChunks[index]
			chunk:UpdateEntity()
			chunk._dirty = false
			updChunks[index] = nil
			updChunks._count = index - 1
		end

		timer.Remove(updTimer)
	end
end

if SERVER then return end

local typeSwitch = {
	[UPDTYPE_POINT] = function()
		local point = Points[net.ReadUInt(NetUInt_Index)]
		point:ReadNet()
		point:Update()
	end,
	[UPDTYPE_CELL] = function()
		Cells[net.ReadUInt(NetUInt_Index)]:ReadNet()
	end,
}

net.Receive("ddterra.netchannel",function(len)
	local type = net.ReadUInt(3)
	local func = typeSwitch[type]
	if len <= 0 or !func then return end
	local count = net.ReadUInt(14)
	print("Receiving Net Update",type,count,len)
	for i = 1,count do
		func()
	end
end)

hook.Add( "OnRequestFullUpdate", "ddterra.fixBounds", function( data )
	local chunks = Chunks
	for i = 0, chunks._count - 1 do
		local chunk = chunks[i]
		if !chunk:IsEntityValid() then continue end
		chunk.Entity:InitBounds()
	end
end)