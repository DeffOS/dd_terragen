util.AddNetworkString("DD_TERRA_CL_SendTerrain")

concommand.Add("dd_terra_test",function(ply)
	TERRA.DeleteAllTerrains()
	local terrain = TERRA.CreateTerrain(6,Vector(-4,-4))
	timer.Simple(0.1,function() terrain:Send() end)
end)