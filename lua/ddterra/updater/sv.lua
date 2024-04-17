local remove = table.remove
local format = string.format
local ceil = math.ceil
local timerName = "ddterra.updatecheckout"
local updateCoroutine
local maxMsgBits = 30000
util.AddNetworkString("ddterra.netchannel")
module("ddterra",package.seeall)
local bitSizePoint = NetUInt_Index + 14 + 8
local bitSizeCell = NetUInt_Index + 4 + 1 + 1

local updateStack = {
	[UPDTYPE_POINT] = {
		_count = 0
	},
	[UPDTYPE_CELL] = {
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
	coroutine.resume(thread,updateStack[UPDTYPE_POINT],updateStack[UPDTYPE_CELL])

	timer.Create(timerName,0.2,0,function()
		if coroutine.status(thread) == "dead" then
			timer.Remove(timerName)

			return
		end

		net.Start("ddterra.netchannel")
		local succ,err = coroutine.resume(thread)

		if !succ then
			ErrorNoHalt(err)
		end

		if coroutine.status(thread) == "dead" then
			timer.Remove(timerName)
			net.Abort()

			return
		end

		net.Broadcast()
	end)
end

function SendFullUpdate(trg)
	local trgTimerName = format("%s-%s",timerName,trg)
	if timer.Exists(trgTimerName) then return end
	local thread = coroutine.create(updateCoroutine)
	ddcord.perftest.Start()
	local points = Points:GetRawClone()
	local cells = Cells:GetRawClone()
	ddcord.perftest.End("Created Raws")
	coroutine.resume(thread,points,cells)

	timer.Create(trgTimerName,0.1,0,function()
		if !IsValid(trg) || coroutine.status(thread) == "dead" then
			timer.Remove(trgTimerName)

			return
		end

		net.Start("ddterra.netchannel")
		local succ,err = coroutine.resume(thread)

		if !succ then
			ErrorNoHalt(err)
		end

		if coroutine.status(thread) == "dead" then
			timer.Remove(trgTimerName)
			net.Abort()

			return
		end

		net.Send(trg)
	end)
end

//hook.Add("OnRequestFullUpdate","ddterra.onFullUpdate",function(data)
//	local ply = Entity(data.index + 1)
//	if !IsValid(ply) then return end
//	print("RequestingUpdate for",ply)
//	SendFullUpdate(ply)
//end)
hook.Add("SetupMove","PlayerInitialized",function(ply,_,cmd)
	if ply.m_bInitialized || !(cmd:IsForced() || ply:IsBot()) then return end
	ply.m_bInitialized = true
	print("RequestingUpdate for",ply)
	SendFullUpdate(ply)
end)

do
	local function WriteUpdType(type)
		net.WriteUInt(type,3)
	end

	local function sendStack(stack,bitsize)
		local count = stack._count
		local bitcount = ceil(maxMsgBits / bitsize)

		if bitcount < count then
			count = bitcount
		end

		net.WriteUInt(count,14)

		for i = 1,count do
			local entry = stack[1]
			net.WriteUInt(entry:GetID(),NetUInt_Index)
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
			WriteUpdType(UPDTYPE_POINT)
			sendStack(points,bitSizePoint)
			goto RETREAT
		end

		if cells._count > 0 then
			WriteUpdType(UPDTYPE_CELL)
			sendStack(cells,bitSizeCell)
			goto RETREAT
		end

		net.Abort()
	end
end

local requestSwitch = {
	[REQUEST_BRUSHCHANGE] = function(ply)
		local tool = ply:GetWeapon("ddterra_sculpt")
		if !IsValid(tool) then return end
		tool:SetBrushType(net.ReadString())
	end,
	[REQUEST_BRUSHSETTINGS] = function(ply)
		local tool = ply:GetWeapon("ddterra_sculpt")
		if !IsValid(tool) then return end
		local tab = util.TableToJSON(net.ReadTable())
		if !tab then return end
		tool:SetBrushSettings(tab)
	end
}

net.Receive("ddterra.netchannel",function(len,ply)
	local requestType = net.ReadUInt(3)
	local func = requestSwitch[requestType]
	if !func then return end
	func(ply)
end)