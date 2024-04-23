SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.ViewModel = "models/weapons/c_toolgun.mdl"
SWEP.UseHands = true

SWEP.Primary = {
	Ammo = "none",
	ClipSize = -1,
	DefaultClip = -1,
	Automatic = false,
}

SWEP.Secondary = SWEP.Primary
SWEP.PrimaryAttack = function() end
SWEP.SecondaryAttack = SWEP.PrimaryAttack

function SWEP:SetupDataTables()
	self:NetworkVar("String",0,"BrushType")
	self:NetworkVar("String",1,"BrushSettings")
	self:NetworkVarNotify("BrushType",self.OnBrushTypeChanged)
	self:NetworkVarNotify("BrushSettings",self.OnBrushSettingsChanged)
end

SWEP.Brush = {}

function SWEP:Initialize()
	self.Brush = setmetatable({},ddterra.brushes.BaseBrush)
	if SERVER then return end
	ddterra.RequestBrushChange("base_brush")
end

function SWEP:OnReloaded()
	if SERVER then return end
	ddterra.RequestBrushChange("base_brush")
end

function SWEP:OnBrushTypeChanged(_,old,new)
	print("Setting new brush",new)
	local brush = ddterra.brushes.GetNewBrush(new,self.Brush)
	if !brush then return end
	rawset(brush,"e_toolwep",self)
	self.Brush = brush
	if SERVER then return end
	ddterra.brushes.SetMenuBrush(self.Brush)
end

function SWEP:OnBrushSettingsChanged(_,old,new)
	print("Setting new brush settings",new)
	local brush = self.Brush
	local settings = util.JSONToTable(new)
	assert(settings,"Failed to load brush settings!")

	for _,prop in ipairs(brush.Properties) do
		local varname = prop[1]
		local var = settings[varname]

		if var then
			rawset(brush,varname,var)
		end
	end
	if SERVER then return end
	ddterra.brushes.UpdateMenuProperties()
end

if SERVER then
	include("server.lua")

	return
end

SWEP.Category = "DD Terrain"

SWEP.f_ReloadLastFrame = 0

function SWEP:Reload()
	if FrameNumber() < self.f_ReloadLastFrame + 4 then
		self.f_ReloadLastFrame = FrameNumber()
		return
	end
	ddterra.brushes.SetMenuBrush(self.Brush)
	ddterra.brushes.ToggleMenu()
	self.f_ReloadLastFrame = FrameNumber()
end

function SWEP:DrawHUD()
	local brush = self.Brush
	local owner = self:GetOwner()
	local trc = owner:GetEyeTrace()
	cam.Start3D()
	render.SetColorMaterial()
	//PrintTable(getmetatable(brush))
	brush:Preview(trc)
	cam.End3D()
end