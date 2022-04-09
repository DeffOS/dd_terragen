ENT.Author = "Default_OS"
ENT.Type = "anim"

local _CellSize = TERRA_CELL_SIZE
local _ChunkSize = TERRA_CHUNK_SIZE
function ENT:UpdateCollision()
	local collision = self["Data"]:GenerateCollision()
	self:PhysicsFromMesh(collision)
	self:SetMoveType(SOLID_NONE)
	self:SetSolid(SOLID_VPHYSICS)
    self:EnableCustomCollisions(true)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
		phys:AddGameFlag(FVPHYSICS_CONSTRAINT_STATIC)
		phys:SetContents(bit.bor(CONTENTS_OPAQUE,CONTENTS_SOLID))
	end
end