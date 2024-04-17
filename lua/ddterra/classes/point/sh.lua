module("ddterra",package.seeall)
POINT = POINT || {}
POINT.__index = POINT

function CreatePoint(x,y)
	return setmetatable({
		_dirty = false,
		X = x,
		Y = y,
		pos = Vector(x * CellSize - WorldOffset,y * CellSize - WorldOffset,0),
		color = Color(255,255,255,255),
	},POINT)
end

// Get Functions
do
	local WorldPointCount = WorldCellCount + 1

	function POINT:GetID()
		return self.X * WorldPointCount + self.Y
	end

	function POINT:GetHeight()
		return self.pos[3]
	end

	function POINT:GetAlpha()
		return self.color.a
	end
end

// Net Related
do
	function POINT:Update()
		local chunks = GetPointChunks(self)
		local chunk

		for i = 1,chunks._count do
			chunk = chunks[i]

			if chunk then
				chunk:MarkAsDirty()
			end
		end
	end

	function POINT:WriteNet()
		net.WriteInt(self.pos[3],14)
		net.WriteUInt(self.color.a,8)
	end

	function POINT:ReadNet()
		self.pos[3] = net.ReadInt(14)
		self.color.a = net.ReadUInt(8)
	end
end

if SERVER then return end

do
	local sh_Create = CreatePoint

	function CreatePoint(x,y)
		local class = sh_Create(x,y)
		class.normal = Vector(0,0,1)
		class:CalculateUVs()

		return class
	end
end

do
	local sh_Update = POINT.Update

	function POINT:Update()
		sh_Update(self)
		local x,y = self.X,self.Y
		self:CalculateNormal((Points:GetSafe(x,y + 1) || self).pos,(Points:GetSafe(x + 1,y) || self).pos,(Points:GetSafe(x,y - 1) || self).pos,(Points:GetSafe(x - 1,y) || self).pos)
	end
end

function POINT:CalculateUVs()
	local ts,ls = UVTextureScale,UVLightmapScale
	local x,y = self.X,-self.Y
	self.u = x * ts
	self.v = y * ts
	self.u1 = x * ls
	self.v1 = y * ls
end

do
	// Calculates normal from clockwise-fed 4 vectors
	local VECTOR = FindMetaTable("Vector")
	local Cross = VECTOR.Cross
	local Nrm = VECTOR.Normalize
	local Add = VECTOR.Add
	local Div = VECTOR.Div
	local Set = VECTOR.Set

	function POINT:CalculateNormal(v1,v2,v3,v4)
		local org = self.pos
		v1,v2,v3,v4 = v1 - org,v2 - org,v3 - org,v4 - org
		Nrm(v1)
		Nrm(v2)
		Nrm(v3)
		Nrm(v4)
		local cr1,cr2 = Cross(v2,v1),Cross(v4,v3)
		Add(cr1,cr2)
		Div(cr1,2)
		Nrm(cr1)
		Set(self.normal,cr1)
	end
end