AddCSLuaFile()
ENT.Base = "base_anim"
ENT.ddterra_chunk = true
function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "ChunkIndex" )
end

do
	-- TODO: Заполнить список
	local whitelist = {

	}
	function ENT:CanTool( ply, trace, mode, tool, button )
		return whitelist[mode]
	end
	function ENT:CanProperty( ply, prop)
		return false
	end
	hook.Add("PhysgunPickup","ddterra.hellno",function(_,ent)
		if ent.ddterra_chunk then return false end
	end)
end

ENT.Initialize = SERVER and function(self)
	self:SetUnFreezable(true)
	self:InitChunkData()
	self:UpdateMesh()
end or function(self)
	self:InitChunkData()
	self:InitBounds()
	self:UpdateMesh()
	self.isInitialized = true
end

ENT.UpdateMesh = SERVER and function(self)
	self:InitCollision()
end or function(self)
	self:InitCollision()
	self:InitMesh()
end

ENT.Think = CLIENT and function(self,phys)
	local physobj = self:GetPhysicsObject()

	if IsValid( physobj ) then
		physobj:SetPos( self:GetPos() )
		physobj:SetAngles( self:GetAngles() )
	end
end or function() end

function ENT:InitChunkData()
	local chunk = ddterra.Chunks[self:GetChunkIndex()]
	chunk.Entity = self
	self.Chunk = chunk
end

function ENT:InitCollision()
	if !self:PhysicsFromMesh( self.Chunk.Triangles, "dirt") then return end
	self:SetMoveType(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	phys:EnableMotion(false)
	phys:AddGameFlag(FVPHYSICS_CONSTRAINT_STATIC)
	phys:SetContents(ALL_VISIBLE_CONTENTS)
	self:EnableCustomCollisions()
end

if SERVER then return end
ENT.isInitialized = false

function ENT:InitBounds()
	self:SetRenderBoundsWS(self.Chunk:GetBounds())
end

hook.Add("NotifyShouldTransmit","ddterra.cunt",function(ent,trs)
	if !ent.ddterra_chunk then return end
	ent:InitChunkData()
	ent:InitBounds()
	--ent:InitCollision()
	--ent.isInitialized = true
end)

local mat = Material("dev/dev_blendmeasure")
--local mat = Material("metal2")
local boundCol = Color(255,153,0,1)
function ENT:InitMesh()
	local imesh = Mesh(mat)
	imesh:BuildFromTriangles(self.Chunk.Triangles)
	local renderMesh = {Material = mat,Mesh = imesh}
	self.GetRenderMesh = function() return renderMesh end
end

local lgh = CreateMaterial("detail/detaildirt001a","UnlitGeneric",{["$basetexture"] = "detail/detaildirt001a"}):GetTexture("$basetexture")

function ENT:Draw(mode)
	render.GetColorModulation(.5,.5,.5)
	render.SetLightmapTexture(lgh)
	self:DrawModel(mode)
	render.GetColorModulation(1,1,1)
	//local min,max = self:GetRenderBounds()
	//render.DrawWireframeBox(self:GetPos(),self:GetAngles(),min,max,boundCol,false)
end