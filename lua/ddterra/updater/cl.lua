module("ddterra",package.seeall)

netchannel.SetCallback("sv.UpdatePoints",function(_,ply)
	local count = net.ReadUInt(14)
	for i = 1,count do
		local point = Points[net.ReadUInt(NetUInt_WorldIndex)]
		point:ReadNet()
		point:Update()
	end
end)

netchannel.SetCallback("sv.UpdateCells",function(_,ply)
	local count = net.ReadUInt(14)
	for i = 1,count do
		Cells[net.ReadUInt(NetUInt_WorldIndex)]:ReadNet()
	end
end)

function RequestBrushChange(brushtype)
	netchannel.Start("cl.BrushTypeChange")
	net.WriteString(brushtype)
	net.SendToServer()
end

function RequestBrushSettingsChange(settings)
	netchannel.Start("cl.BrushSettingsChange")
	net.WriteTable(settings)
	net.SendToServer()
end

//FIXME: This shit aint working for some ungodly reason, gotta love those client PVS cleanups
hook.Add("OnRequestFullUpdate","ddterra.fixBounds",function(data)
	local chunks = Chunks

	for i = 0,chunks._count - 1 do
		local chunk = chunks[i]
		if !chunk:IsEntityValid() then continue end
		chunk.Entity:InitBounds()
	end
end)