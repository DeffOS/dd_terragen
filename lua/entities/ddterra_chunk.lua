AddCSLuaFile()
ENT.Base = "base_anim"
ENT.ddterra_chunk = true

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"ChunkIndex")
end

do

	function ENT:CanTool()
		return false
	end

	function ENT:CanProperty()
		return false
	end
	// Credit to PrikolMen for that pseudo world catch
	// ULib support ( I really don't like this )
	if file.Exists("ulib/shared/hook.lua","LUA") then
		include("ulib/shared/hook.lua")
	end

	local GetWorld = game.GetWorld
	local hookRun = hook.Run

	hook.Add("CanTool","ddterra.ChunkAsWorld",function(ply,trace,...)
		local ent = trace.Entity

		if IsValid(ent) && ent.ddterra_chunk then
			trace.Entity = GetWorld()

			return hookRun("CanTool",ply,trace,...)
		end
	end,PRE_HOOK_RETURN || HOOK_MONITOR_HIGH)

	hook.Add("PhysgunPickup","ddterra.hellno",function(_,ent)
		if ent.ddterra_chunk then return false end
	end)
end

ENT.Initialize = SERVER && function(self)
	self:SetUnFreezable(true)
	self:InitChunkData()
	self:UpdateMesh()
end || function(self)
	self:InitChunkData()
	self:InitBounds()
	self:UpdateMesh()
	self.isInitialized = true
end

ENT.UpdateMesh = SERVER && function(self)
	self:InitCollision()
end || function(self)
	self:InitCollision()
	self:InitMesh()
end

function ENT:InitChunkData()
	local chunk = ddterra.Chunks[self:GetChunkIndex()]
	chunk.Entity = self
	self.Chunk = chunk
end

function ENT:InitCollision()
	if !self:PhysicsFromMesh(self.Chunk.Triangles,"dirt") then return end
	self:SetMoveType(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	phys:EnableMotion(false)
	phys:AddGameFlag(FVPHYSICS_CONSTRAINT_STATIC)
	phys:SetContents(ALL_VISIBLE_CONTENTS)
	self:EnableCustomCollisions()
end

if SERVER then return end

function ENT:InitBounds()
	self:SetRenderBoundsWS(self.Chunk:GetBounds())
end

hook.Add( "NotifyShouldTransmit", "ddterra.chunkfix", function( entity, shouldTransmit )
	if !shouldTransmit || !entity.ddterra_chunk then return end
	//entity:InitChunkData()
	entity:InitBounds()
	// self:InitCollision()
end )

// Clientside PVS AntiDeletion mesure for chunks
function ENT:Think()
	if self:IsDormant() then return end
	local physobj = self:GetPhysicsObject()

	if IsValid(physobj) then
		physobj:SetPos(self:GetPos())
		physobj:SetAngles(self:GetAngles())
	end
end

local mat = Material("dev/dev_blendmeasure")
local boundCol = Color(255,153,0,1)

function ENT:InitMesh()
	local imesh = Mesh(mat)
	imesh:BuildFromTriangles(self.Chunk.Triangles)

	local renderMesh = {
		Material = mat,
		Mesh = imesh
	}

	self.GetRenderMesh = function() return renderMesh end
end

local lgh = CreateMaterial("detail/detaildirt001a","UnlitGeneric",{
	["$basetexture"] = "detail/detaildirt001a"
}):GetTexture("$basetexture")

function ENT:Draw(mode)
	render.GetColorModulation(.5,.5,.5)
	render.SetLightmapTexture(lgh)
	self:DrawModel(mode)
	render.GetColorModulation(1,1,1)
	//local min,max = self:GetRenderBounds()
	//render.DrawWireframeBox(self:GetPos(),self:GetAngles(),min,max,boundCol,false)
end