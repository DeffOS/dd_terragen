module("ddterra",package.seeall)

concommand.Add("ddterra.dbg.createtest",function()
	local cleanup = false
	for _, ent in ipairs(ents.FindByClass("ddterra_testchunk")) do
		ent:Remove()
		cleanup = true
	end

	if cleanup then return end

	local ent = ents.Create("ddterra_testchunk")
	ent:SetPos(Vector())
	ent:Spawn()
end)