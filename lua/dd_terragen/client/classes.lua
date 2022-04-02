local TERRATERRAIN = debug.getregistry()["DD_TerraTerrain"]
local TERRACHUNK = debug.getregistry()["DD_TerraChunk"]
local TERRAPATCH = debug.getregistry()["DD_TerraPatch"]
local TERRAVERT = debug.getregistry()["DD_TerraVertex"]

local CellSize = TERRA_CELL_SIZE
local ChunkSize = TERRA_CHUNK_SIZE
local ChunkVolume = TERRA_CHUNK_SIZE*TERRA_CHUNK_SIZE
local ChunkVertCount = TERRA_CHUNK_SIZE+1
local FlipOrder = TERRA_FLIPORDER
local LightmapSize = 4096

net.Receive("DD_TERRA_CL_SendTerrain",function()
	print("Receiving")
	local world = net.ReadTerraTerrain()
	//PrintTable(world)
end)

do
	local function CreateLightMap(x,y)
		return GetRenderTargetEx("TerraTerrainLightMap",x,y,
		RT_SIZE_LITERAL,MATERIAL_RT_DEPTH_NONE,
		1,0,IMAGE_FORMAT_RGB565)
	end
	function net.ReadTerraTerrain()
		local pos = net.ReadVector()
		local sx,sy = net.ReadUInt(10),net.ReadUInt(10)
		local verts = {}
		local chunks = {}
		local isx,isy = sx*ChunkSize*TERRA_TEXEL_PER_PATCH,sy*ChunkSize*TERRA_TEXEL_PER_PATCH
		print("Lightmap Pixel Ocupation",isx,isy)
		local class = setmetatable({
			["Lightmap"] = CreateLightMap(LightmapSize,LightmapSize),
			["Position"] = pos,
			["Size"] = {sx,sy},
			["__verts"] = verts,
			["__chunks"] = chunks,
		},TERRATERRAIN)
		for x=1,ChunkSize*sx+1,1 do
			verts[x] = {}
			for y=1,ChunkSize*sy+1,1 do
				verts[x][y] = net.ReadTerraVertex(class,x,y)
			end
		end
		for x=1,sx,1 do
			chunks[x] = {}
			for y=1,sy,1 do
				chunks[x][y] = net.ReadTerraChunk(class,x,y)
			end
		end
		render.PushRenderTarget( class["Lightmap"] )
		cam.Start2D()
			draw.NoTexture()
			surface.SetDrawColor( Color(192,192,192,255) )
			surface.DrawRect(0,0,isx,isy)
			surface.SetDrawColor( Color(164,164,164,255) )
			for x=1,isx,1 do
				if x%2==0 then
					surface.DrawLine(x,0,x,isy)
				end
			end
		cam.End2D()
		render.PopRenderTarget()

		return class
	end
	function TERRATERRAIN:GetLightmap() return self["Lightmap"] end
	function TERRATERRAIN:GetLightmapUVStep() return self["LightmapUVStep"] end
	function TERRATERRAIN:RegenerateLightmap()
		local lightmap = self:GetLightmap()
		for x,sy in ipairs(self["__chunks"]) do
			for y,chunk in ipairs(sy) do
				chunk:UpdateLightmap(lightmap)
			end
		end
	end
end

do
	TERRA.Chunks = TERRA.Chunks or {["__await"] = {}}
	function net.ReadTerraChunk(terrain,gx,gy)
		local verts = {}
		local patches = {}
		local entid = net.ReadUInt(16)
		local ent = Entity(entid)
		local res = setmetatable({
			["Terrain"] = terrain,
			["Position"] = {gx,gy},
			["Entity"] = ent,
			["__verts"] = verts,
			["__patches"] = patches,
		},TERRACHUNK)
		do
			local gvx,gvy = (gx-1)*ChunkSize,(gy-1)*ChunkSize
			for x=1,ChunkVertCount,1 do
				verts[x] = {}
				for y=1,ChunkVertCount,1 do
					verts[x][y] = terrain:GetVertex(gvx+x,gvy+y)
				end
			end
		end

		for x=1,ChunkSize,1 do
			patches[x] = {}
			for y=1,ChunkSize,1 do
				patches[x][y] = net.ReadTerraPatch(res,x,y)
			end
		end
		if !IsValid(ent) then
			TERRA.Chunks["__await"][entid] = res
		else
			ent:SetupData(res)
		end
		return res
	end

	local Begin = mesh.Begin
	local End = mesh.End
	function TERRACHUNK:BuildMesh(_Mesh)
		_Mesh = _Mesh or Mesh()
		local patches = self["__patches"]
		Begin(_Mesh,MATERIAL_QUADS,ChunkVolume)
			for x=1,ChunkSize,1 do
				for y=1,ChunkSize,1 do
					patches[x][y]:Mesh()
				end
			end
		End()
		return _Mesh
	end
end

do
	function net.ReadTerraPatch(chunk,x,y)
		return setmetatable({
			x = x,
			y = y,
			v1 = chunk:GetVertex(x+1,y),
			v2 = chunk:GetVertex(x,y),
			v3 = chunk:GetVertex(x,y+1),
			v4 = chunk:GetVertex(x+1,y+1),
			Solid = net.ReadBool(),
			MatID = net.ReadUInt(3)+1,
			Invert = net.ReadBool(),
		},TERRAPATCH)
	end
	//print("AAAAA",TERRAPATCH)
	function TERRAPATCH:Mesh()
		local invert = self:IsInverted()
		if FlipOrder[self["x"]][self["y"]] then
			self["v1"]:Mesh(invert)
			self["v2"]:Mesh(invert)
			self["v3"]:Mesh(invert)
			self["v4"]:Mesh(invert)
		else
			self["v2"]:Mesh(invert)
			self["v3"]:Mesh(invert)
			self["v4"]:Mesh(invert)
			self["v1"]:Mesh(invert)
		end
	end
end

do
	function net.ReadTerraVertex(terrain,x,y)
		return setmetatable({
			["Terrain"] = terrain,
			["x"] = x-1,
			["y"] = y-1,
			["Position"] = Vector((x-1)*CellSize,(y-1)*CellSize,net.ReadFloat()),
			["Alpha"] = net.ReadUInt(8),
		},TERRAVERT)
	end
	function TERRAVERT:GetUVs() local pos = self:GetPosition() return pos[1]/128,pos[2]/128 end
	local _uvstep = 1/LightmapSize*TERRA_TEXEL_PER_PATCH
	function TERRAVERT:GetLightUV() return _uvstep*self["x"],_uvstep*self["y"] end
	function TERRAVERT:CalculateNormal() // FIXME: Переписать это дерьмище чтобы генерировать нормальные нормали
		local terrain = self["Terrain"]
		local pos = self:GetPosition()
		local x,y = self["x"],self["y"]
		local nx,px,ny,py =
		(terrain:SafeGetVertex(x-1,y) or Vector(0,0,8000)):GetPosition()-pos,(terrain:SafeGetVertex(x+1,y) or Vector(0,0,8000)):GetPosition()-pos,
		(terrain:SafeGetVertex(y-1,y) or Vector(0,0,8000)):GetPosition()-pos,(terrain:SafeGetVertex(y+1,y) or Vector(0,0,8000)):GetPosition()-pos
		return (nx:Cross(py)+px:Cross(ny)):GetNormalized()
	end
	local _nCap = Vector(0,0,1)
	local Position = mesh.Position
	local Normal = mesh.Normal
	local TexCoord = mesh.TexCoord
	local Color = mesh.Color
	local AdvanceVertex = mesh.AdvanceVertex
	function TERRAVERT:Mesh(invert)
		Position(self:GetPosition())
		Normal(_nCap)
		TexCoord(0,self:GetUVs())
		TexCoord(1,self:GetLightUV())
		//print(self:GetLightUV())
		//TexCoord(2,0,0)
		Color(255,255,255,invert and 255-self:GetAlpha() or self:GetAlpha())
		AdvanceVertex()
	end
end