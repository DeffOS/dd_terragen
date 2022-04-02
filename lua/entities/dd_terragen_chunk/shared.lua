ENT.Author = "Default_OS"
ENT.Type = "anim"

local _CellSize = TERRA_CELL_SIZE
local _ChunkSize = TERRA_CHUNK_SIZE
function ENT:UpdateCollision()
	local collision = self["Data"]:GenerateCollision()
	//print(#collision)
	//PrintTable(collision)
	//self:SetCollisionBounds(Vector(),Vector(_ChunkSize*_CellSize,_ChunkSize*_CellSize,4096))
	//self:AddEFlags(EFL_NO_GAME_PHYSICS_SIMULATION)
	//self:AddFlags(FL_WORLDBRUSH)
	self:PhysicsInitStatic(SOLID_VPHYSICS)
	self:PhysicsFromMesh(collision)
	self:SetMoveType(SOLID_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	//self:SetCollisionGroup(COLLISION_GROUP_PUSHAWAY)
    self:EnableCustomCollisions(true)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
		phys:AddGameFlag(FVPHYSICS_CONSTRAINT_STATIC)
		phys:SetContents(bit.bor(CONTENTS_OPAQUE,CONTENTS_SOLID))
		//phys:SetPos(self:GetPos())
	end
end

//function ENT:Think()
//	local phys = self:GetPhysicsObject()
//	if IsValid(phys) then
//		print(phys:GetVelocity())
//	end
//end