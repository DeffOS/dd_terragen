do
	local TERRATERRAIN = {}
	TERRATERRAIN["__index"] = TERRATERRAIN
	debug.getregistry()["DD_TerraTerrain"] = TERRATERRAIN
	function TERRATERRAIN:GetPosition() return self["Position"] end
	function TERRATERRAIN:GetSurfacePosition(x,y)

	end
	function TERRATERRAIN:GetVertex(x,y) return self["__verts"][x][y] end
	function TERRATERRAIN:SafeGetVertex(x,y)
		if x<1 or x>self["_vertlen"][1] or y<1 or y>self["_vertlen"][2] then
			return
		else
			return self["__verts"][x][y]
		end
	end
end

do
	local TERRACHUNK = {}
	TERRACHUNK["__index"] = TERRACHUNK
	debug.getregistry()["DD_TerraChunk"] = TERRACHUNK
	function TERRACHUNK:GetListIndex(x,y) return (x-1)*self["Size"][2]+y end

	function TERRACHUNK:GetTerrain() return self["Terrain"] end
	function TERRACHUNK:GetPosition() return self["Position"] end
	function TERRACHUNK:GetVertex(x,y) return self["__verts"][x][y] end
	function TERRACHUNK:GetPatch(x,y) return self["__patches"][x][y] end

	local ChunkVerts = TERRA_CHUNK_VERTS
	local FlipOrder = TERRA_FLIPORDER
	function TERRACHUNK:GenerateCollision()
		local VertTable = {}
		local PolyTable = {}
		for x,sy in ipairs(ChunkVerts) do
			VertTable[x] = {}
			for y,vert in ipairs(sy) do
				VertTable[x][y] = {pos=Vector(vert[1],vert[2],self:GetVertex(x,y):GetPosition()[3])}
			end
		end
		for x=1,TERRA_CHUNK_SIZE,1 do
			for y=1,TERRA_CHUNK_SIZE,1 do
				//print(x,y)
				if !self:GetPatch(x,y):IsSolid() then continue end
				local v1,v2,v3,v4 = VertTable[x+1][y],VertTable[x][y],VertTable[x][y+1],VertTable[x+1][y+1]
				if FlipOrder[x][y] then
					table.insert(PolyTable,v3)
					table.insert(PolyTable,v2)
					table.insert(PolyTable,v1)
					table.insert(PolyTable,v1)
					table.insert(PolyTable,v4)
					table.insert(PolyTable,v3)
				else
					table.insert(PolyTable,v4)
					table.insert(PolyTable,v2)
					table.insert(PolyTable,v1)
					table.insert(PolyTable,v3)
					table.insert(PolyTable,v2)
					table.insert(PolyTable,v4)
				end
			end
		end
		return PolyTable
	end
end

do
	local TERRAPATCH = {}
	TERRAPATCH["__index"] = TERRAPATCH
	debug.getregistry()["DD_TerraPatch"] = TERRAPATCH

	function TERRAPATCH:IsSolid() return self["Solid"] end
	function TERRAPATCH:IsInverted() return self["Invert"] end
	function TERRAPATCH:SetInverted(var) self["Invert"] = var end
end

do
	local TERRAVERT = {}
	TERRAVERT["__index"] = TERRAVERT
	debug.getregistry()["DD_TerraVertex"] = TERRAVERT

	function TERRAVERT:GetPosition() return self["Position"] end

	function TERRAVERT:GetAlpha() return self["Alpha"] end
	function TERRAVERT:SetAlpha(var) self["Alpha"] = var end
end