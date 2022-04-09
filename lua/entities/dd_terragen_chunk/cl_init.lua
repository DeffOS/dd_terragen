include("shared.lua")
local _RenderMaterial = Material("nature/blendrocksgrass006a")//"dev/dev_blendmeasure")
local _CellSize = TERRA_CELL_SIZE
local _ChunkSize = TERRA_CHUNK_SIZE
local _RenderSize = Vector(_ChunkSize*_CellSize,_ChunkSize*_CellSize,4096)

function ENT:Initialize()
	self:SetRenderBounds(Vector(),_RenderSize)
	local data = TERRA.Chunks["__await"][id]
	TERRA.Chunks[self:EntIndex()] = self
	if data then
		self:SetupData(data)
	end
end

function ENT:SetupData(data)
	self["Data"] = data
	TERRA.Chunks["__await"][self:EntIndex()] = nil
	self:UpdateMesh()
	self:UpdateCollision()
	self["LightMap"] = data:GetTerrain():GetLightmap()
	local mat = Matrix()
	mat:SetTranslation(data:GetTerrain():GetPosition())
	mat:SetScale( Vector(1,1,1) )
	self["ModelMatrix"] = mat
end

function ENT:UpdateMesh()
	self["Mesh"] = self["Data"]:BuildMesh(Mesh(_RenderMaterial))
end
local _Wireframe = Material("editor/wireframe")
local _lights = {
	{type = MATERIAL_LIGHT_DISABLE,pos = Vector(0,0,0),color = Vector(2555,2555,2555),range = 1024}
}
function ENT:Draw()
	//render.SetLightingMode(1)
	local _matrix = self["ModelMatrix"]
	local _mesh = self["Mesh"]
	local _lightmap = self["LightMap"]
	if IsValid(_mesh) and _matrix and _lightmap then
		render.SetMaterial(_RenderMaterial)
		render.SetLightmapTexture(_lightmap)
		//render.SetLocalModelLights(_lights) // FIXME: Свет от динам ламп не работает
		cam.PushModelMatrix(_matrix)
			_mesh:Draw()
			render.PushFlashlightMode(LocalPlayer():FlashlightIsOn()) // TODO: Рендерить только когда игрок рядом
			_mesh:Draw()
			render.PopFlashlightMode()
		cam.PopModelMatrix()
	end
	//render.SetLightingMode(0)

	render.SetColorMaterial()
	render.DrawWireframeBox(self:GetPos(),self:GetAngles(),Vector(),_RenderSize,Color(0,255,0),true)
end