module("ddterra",package.seeall)

do
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
		if len <= 0 || !func then return end
		local count = net.ReadUInt(14)
		//print("Receiving Net Update",type,count,len)

		for i = 1,count do
			func()
		end
	end)
end

hook.Add("OnRequestFullUpdate","ddterra.fixBounds",function(data)
	local chunks = Chunks

	for i = 0,chunks._count - 1 do
		local chunk = chunks[i]
		if !chunk:IsEntityValid() then continue end
		chunk.Entity:InitBounds()
	end
end)

function RequestBrushChange(brushtype)
	net.Start("ddterra.netchannel")
	net.WriteUInt(REQUEST_BRUSHCHANGE,3)
	net.WriteString(brushtype)
	net.SendToServer()
end

function RequestBrushSettingsChange(settings)
	net.Start("ddterra.netchannel")
	net.WriteUInt(REQUEST_BRUSHSETTINGS,3)
	net.WriteTable(settings)
	net.SendToServer()
end