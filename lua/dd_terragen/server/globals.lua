util.AddNetworkString("DD_TERRA_CL_SendTerrain")

TERRA_SENDBUS_START = 1
TERRA_SENDBUS_VERTEX = 2
TERRA_SENDBUS_PATCH = 3
TERRA_SENDBUS_END = 4

concommand.Add("dd_terra_test",function(ply,_,args)
	TERRA.DeleteAllTerrains()
	local terrain = TERRA.CreateTerrain(args[1] and tonumber(args[1]) or 16,Vector(-8,-8))
	timer.Simple(0.1,function() terrain:SendAsync() end)
end)