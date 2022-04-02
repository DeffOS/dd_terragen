local TERRATERRAIN = debug.getregistry()["DD_TerraTerrain"]
local TERRACHUNK = debug.getregistry()["DD_TerraChunk"]
local TERRAPATCH = debug.getregistry()["DD_TerraPatch"]
local TERRAVERT = debug.getregistry()["DD_TerraVertex"]

local VertSize = TERRA_CELL_SIZE
local ChunkSize = TERRA_CHUNK_SIZE
local ChunkVertCount = TERRA_CHUNK_SIZE+1
local ChunkVolume = Vector(TERRA_CHUNK_SIZE*TERRA_CELL_SIZE,TERRA_CHUNK_SIZE*TERRA_CELL_SIZE,0)

do
	TERRA.Terrains = TERRA.Terrains or {}
	local Terrains = TERRA.Terrains
	function TERRA.DeleteTerrain(id)
		local Terrain = Terrains[id]
		Terrains[id] = nil
		Terrain:Dispose()
	end
	function TERRA.DeleteAllTerrains()
		for id,terr in pairs(Terrains) do
			terr:Dispose()
			Terrains[id] = nil
		end
	end
end

do
	function TERRA.CreateTerrain(size,pos)
		local _CreateChunk = TERRA.CreateChunk
		local _CreateVertex = TERRA.CreateVertex
		pos = (pos or Vector())*ChunkVolume
		size = isnumber(size) and {size,size} or size
		local sx,sy = size[1],size[2]
		local verts = {}
		local chunks = {}
		local class = setmetatable({
			["Position"] = pos,
			["Size"] = size,
			["__vertlen"] = {ChunkSize*sx+1,ChunkSize*sy+1},
			["__verts"] = verts,
			["__chunks"] = chunks,
		},TERRATERRAIN)
		table.insert(TERRA.Terrains,class)

		// Create Vertecies
		for x=1,ChunkSize*sx+1,1 do
			verts[x] = {}
			for y=1,ChunkSize*sy+1,1 do
				verts[x][y] = _CreateVertex(x,y)
			end
		end
		// Create Chunks
		for x=1,sx,1 do
			chunks[x] = {}
			for y=1,sy,1 do
				chunks[x][y] = _CreateChunk(class,x,y)
			end
		end

		return class
	end
	function TERRATERRAIN:Send()
		net.Start("DD_TERRA_CL_SendTerrain")
		local verts = self["__verts"]
		net.WriteVector(self["Position"])
		local sx,sy = self["Size"][1],self["Size"][2]
		net.WriteUInt(sx,10)
		net.WriteUInt(sy,10)
		for x=1,ChunkSize*sx+1,1 do
			for y=1,ChunkSize*sy+1,1 do
				verts[x][y]:Send()
			end
		end
		local chunks = self["__chunks"]
		for x=1,sx,1 do
			for y=1,sy,1 do
				chunks[x][y]:Send()
			end
		end
		net.Broadcast()
	end
	function TERRATERRAIN:Dispose()
		local sx,sy = self["Size"][1],self["Size"][2]
		for x=1,sx,1 do
			for y=1,sy,1 do
				local chunk = self["__chunks"][x][y]
				if chunk then chunk:Dispose() end
			end
		end
	end
end

do
	function TERRA.CreateChunk(terrain,gx,gy)
		local verts = {}
		local patches = {}
		local ent = ents.Create("dd_terragen_chunk")
		ent:SetPos(ChunkVolume*Vector(gx-1,gy-1)+terrain:GetPosition())
		ent:Spawn()
		local res = setmetatable({
			["Position"] = {gx,gy},
			["Entity"] = ent,
			["__verts"] = verts,
			["__patches"] = patches
		},TERRACHUNK)
		do
			local gvx,gvy = (gx-1)*ChunkSize,(gy-1)*ChunkSize
			for x=1,ChunkVertCount,1 do
				verts[x] = {}
				for y=1,ChunkVertCount,1 do
					//print(gvx,gvy,x,y,#terrain["__verts"],#terrain["__verts"][1])
					verts[x][y] = terrain:GetVertex(gvx+x,gvy+y)
				end
			end
		end

		for x=1,ChunkSize,1 do
			patches[x] = {}
			for y=1,ChunkSize,1 do
				patches[x][y] = TERRA.CreatePatch(res,x,y)
			end
		end

		ent["Data"] = res
		ent:UpdateCollision()

		return res
	end
	function TERRACHUNK:Send()
		net.WriteEntity(self["Entity"])
		local patches = self["__patches"]
		for x=1,ChunkSize,1 do
			for y=1,ChunkSize,1 do
				patches[x][y]:Send()
			end
		end
	end
	function TERRACHUNK:Dispose()
		print("Removing chunk",self["Entity"])
		self["Entity"]:Remove()
		print(self["Entity"])
	end
end

do
	function TERRA.CreatePatch(world,x,y)
		return setmetatable({
			x = x,
			y = y,
			v1 = world:GetVertex(x+1,y),
			v2 = world:GetVertex(x,y),
			v3 = world:GetVertex(x,y+1),
			v4 = world:GetVertex(x+1,y+1),
			Solid = true,
			MatID = 1,
			Invert = false,
		},TERRAPATCH)
	end
	function TERRAPATCH:Send()
		net.WriteBool(self["Solid"])
		net.WriteUInt(self["MatID"]-1,3)
		net.WriteBool(self["Invert"])
	end
end

do
	require("dd_noise")
	local noise = DDNoises.Simplex(.06,1)
	function TERRA.CreateVertex(x,y)
		return setmetatable({
			["Position"] = Vector((x-1)*VertSize,(y-1)*VertSize,(noise:Fractal(2,x,y)+1)*512),
			["Alpha"] = math.Clamp(-noise:Fractal(2,x,y)+0.5,0,1)*255,//255,
			//["Bright"] = net.ReadUInt(8)
		},TERRAVERT)
	end
	function TERRAVERT:Send()
		net.WriteFloat(self["Position"][3])
		net.WriteUInt(self["Alpha"],8)
		//net.WriteUInt(self["Bright"],8)
	end
end