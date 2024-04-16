util.AddNetworkString("ddterra.netchannel")
local remove = table.remove
module("ddterra",package.seeall)
local updTimer = "ddterra.updatecheckout"
local maxBits = 60000
local bitsizePoint = NetUInt_Index + 14 + 8
local bitsizeCell = NetUInt_Index + 4 + 1 + 1

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

	if !timer.Exists(updTimer) then
		timer.Create(updTimer,0.1,0,function()
			TimerBody(updTimer)
			net.Broadcast()
		end)
	end
end

do
	local bits = maxBits

	local function sendStack(stack,type,bitsize)
		// local stack = updateStack[type]
		local count = stack._count
		local sending = false

		if count > 0 then
			sending = true
			net.WriteUInt(type,3)
			local bitcount = ceil(bits / bitsize)

			if bitcount < count then
				count = bitcount
			end

			bits = bits - bitsize * count
			net.WriteUInt(count,14)
			print("Sending Net Update count",count)
			for i = 1,count do
				local entry = stack[1]
				net.WriteUInt(entry:GetID(),NetUInt_Index)
				//print(entry:GetID(),NetUInt_Index)
				entry:WriteNet()
				entry._dirty = false
				stack._count = stack._count - 1
				remove(stack,1)
			end
		end

		return sending
	end

	TimerBody = function(timerName)
		bits = maxBits
		net.Start("ddterra.netchannel")

		if sendStack(UPDTYPE_POINT,bitsizePoint) then
			//print("EBANA ROT",bits,bitsizePoint,bitsizeCell)
			goto skip
		end

		if sendStack(UPDTYPE_CELL,bitsizeCell) then
			goto skip
		end

		timer.Remove(timerName)
		::skip::
	end

	hook.Add("OnRequestFullUpdate","ddterra.onFullUpdate",function(data)
		local ply = Entity(data.index + 1)
		if !IsValid(ply) then return end
		local tName = updTimer..data.name
		print("RequestingUpdate for",ply)
		if !timer.Exists(tName) then
			timer.Create(tName,0.25,0,function()
				if !IsValid(ply) then
					timer.Remove(tName)
					return
				end
				TimerBody(tName)
				net.Send(ply)
			end)
		end
	end)
end