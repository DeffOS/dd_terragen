module("ddterra",package.seeall)
CHUNK = CHUNK || {}
CHUNK.__index = CHUNK

function CreateChunk(x,y,cells)
	local class = setmetatable({
		_dirty = false,
		X = x,
		Y = y,
		Cells = cells,
		Triangles = {},
		Entity = NULL,
	},CHUNK)

	class:BuildTriangles()

	return class
end

function CHUNK:UpdateEntity()
	local ent = self.Entity
	if !IsValid(ent) then return end
	print("Updating mesh")
	ent:UpdateMesh()
end

function CHUNK:MarkAsDirty()
	if self._dirty then return end
	self._dirty = true
	RequestChunkUpdate(self)
end

function CHUNK:IsEntityValid()
	return IsValid(self.Entity)
end

function CHUNK:GetID()
	return self.X * WorldChunkCount + self.Y
end

function CHUNK:BuildTriangles()
	local result = {}
	local cells = self.Cells

	for i = 1,ChunkSize * ChunkSize do
		cells[i]:PushQuad(result)
	end

	self.Triangles = result
end

function CHUNK:GetBounds()
	return Vector(self.X * ChunkVolume - WorldOffset,self.Y * ChunkVolume - WorldOffset,-1024),Vector((self.X + 1) * ChunkVolume - WorldOffset,(self.Y + 1) * ChunkVolume - WorldOffset,4096)
end

if SERVER then return end