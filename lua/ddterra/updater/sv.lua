local remove = table.remove
local format = string.format
local ceil = math.ceil
local timerName = "ddterra.updatecheckout"
local updateCoroutine
local maxMsgBits = 50000
module("ddterra",package.seeall)
local bitSizePoint = NetUInt_WorldIndex + 15 + 8
local bitSizeCell = NetUInt_WorldIndex + 4 + 1 + 1

local updateStack = {
	points = {
		_count = 0
	},
	cells = {
		_count = 0
	}
}
function ReportUpdate(type,class)
	local stack = updateStack[type]

	if stack then
		local ind = stack._count + 1
		stack[ind] = class
		stack._count = ind
	end

	if timer.Exists(timerName) then return end
	local thread = coroutine.create(updateCoroutine)
	coroutine.resume(thread,updateStack.points,updateStack.cells)

	timer.Create(timerName,0.2,0,function()
		if coroutine.status(thread) == "dead" then
			timer.Remove(timerName)

			return
		end

		local succ,err = coroutine.resume(thread)

		if !succ then
			ErrorNoHalt(err)
		end

		if coroutine.status(thread) == "dead" then
			timer.Remove(timerName)

			return
		end

		net.Broadcast()
	end)
end

function SendFullUpdate(trg)
	local trgTimerName = format("%s-%s",timerName,trg)
	if timer.Exists(trgTimerName) then return end
	local thread = coroutine.create(updateCoroutine)
	local points = Points:GetRawClone()
	local cells = Cells:GetRawClone()
	coroutine.resume(thread,points,cells)

	timer.Create(trgTimerName,0.25,0,function()
		if !IsValid(trg) || coroutine.status(thread) == "dead" then
			timer.Remove(trgTimerName)

			return
		end
		local succ,err = coroutine.resume(thread)

		if !succ then
			ErrorNoHalt(err)
		end

		if coroutine.status(thread) == "dead" then
			timer.Remove(trgTimerName)

			return
		end

		net.Send(trg)
	end)
end

hook.Add("OnRequestFullUpdate","ddterra.onFullUpdate",function(data)
	local ply = Entity(data.index + 1)
	if !IsValid(ply) then return end
	print("RequestingUpdate for",ply)
	SendFullUpdate(ply)
end)

do
	local function sendStack(stack,bitsize)
		local count = stack._count
		local bitcount = ceil(maxMsgBits / bitsize)

		if bitcount < count then
			count = bitcount
		end

		net.WriteUInt(count,14)

		for i = 1,count do
			local entry = stack[1]
			net.WriteUInt(entry:GetID(),NetUInt_WorldIndex)
			entry:WriteNet()
			entry._dirty = false
			stack._count = stack._count - 1
			remove(stack,1)
		end

		return count
	end

	updateCoroutine = function(points,cells)
		::RETREAT::
		coroutine.yield()

		if points._count > 0 then
			netchannel.Start("sv.UpdatePoints")
			sendStack(points,bitSizePoint)
			goto RETREAT
		end

		if cells._count > 0 then
			netchannel.Start("sv.UpdateCells")
			sendStack(cells,bitSizeCell)
			goto RETREAT
		end
	end
end

netchannel.SetCallback("cl.BrushTypeChange",function(_,ply)
	brushes.PlayerRequestedType(ply,net.ReadString())
end)

netchannel.SetCallback("cl.BrushSettingsChange",function(_,ply)
	brushes.PlayerRequestedSettings(ply,net.ReadTable())
end)