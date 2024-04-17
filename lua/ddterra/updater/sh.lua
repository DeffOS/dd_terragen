local ceil = math.ceil
local log = math.log
gameevent.Listen( "OnRequestFullUpdate" )
module("ddterra",package.seeall)
REQUEST_FULLUPDATE = 0
REQUEST_BRUSHCHANGE = 1
REQUEST_BRUSHSETTINGS = 2
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