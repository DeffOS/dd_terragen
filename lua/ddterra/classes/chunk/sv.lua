module("ddterra",package.seeall)

function CHUNK:CreateEntity()
	if IsValid(self.Entity) then
		self.Entity:Remove()
	end

	local ent = ents.Create("ddterra_chunk")
	// ent:SetPos(Vector((self.X + .5) * ChunkVolume - WorldOffset,(self.Y + .5) * ChunkVolume - WorldOffset))
	ent:SetPos(Vector())
	ent:SetChunkIndex(self:GetID())
	ent:Spawn()
	self.Entity = ent
end