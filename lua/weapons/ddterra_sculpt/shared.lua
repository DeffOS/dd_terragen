SWEP.Spawnable = true
SWEP.ViewModel = "models/weapons/c_toolgun.mdl"
SWEP.UseHands = true

SWEP.Primary = {
	Ammo = "none",
	ClipSize = -1,
	DefaultClip = -1,
	Automatic = true,
}

SWEP.Secondary = SWEP.Primary
SWEP.PrimaryAttack = function() end
SWEP.SecondaryAttack = SWEP.PrimaryAttack

function SWEP:SetupDataTables()
	self:NetworkVar( "String", 0, "BrushType" )
	self:NetworkVar( "Int", 0, "Radius" )
	self:NetworkVar( "Int", 1, "Force" )

	if SERVER then
		self:SetBrushType("radial")
		self:SetRadius(4)
		self:SetForce(128)
	end

	self:NetworkVarNotify( "BrushType", self.OnBrushTypeChanged )
end

SWEP.Brush = {}

function SWEP:Initialize()
	self.Brush = {}
	self:OnBrushTypeChanged(nil,nil,"radial")
end

function SWEP:OnBrushTypeChanged(_,old,new)
	local meta = ddterra.GetBrush(new)
	if !meta then return end
	local brush = self.Brush
	setmetatable(brush,meta)
	brush:Setup(self:GetRadius(),self:GetForce())
end

if SERVER then
	include("server.lua")

	return
end

SWEP.Category = "DD Terrain"
local pointCol = Color(64,0,0)
local pointNewCol = Color(255,0,0)
local centerCol = Color(0,255,0)
local ang = Angle()
local min,max = Vector(-8,-8,-8),Vector(8,8,8)
local cmin,cmax = Vector(-10,-10,-10),Vector(10,10,10)
local points = {}

function SWEP:Reload()
	ddterra.OpenBrushMenu(self)
end

function SWEP:DrawHUD()
	local owner = self:GetOwner()
	local tr = owner:GetEyeTrace()
	local x,y = ddterra.PosToIndex(tr.HitPos)
	local rad = self:GetRadius()
	points = ddterra.GetPointsInRadius(x,y,rad,points)
	local center = ddterra.Points:Get(x,y)
	local brush = self.Brush
	cam.Start3D()
	render.SetColorMaterial()
	brush:StartStroke(center)

	for i = 1,points._count do
		local point = points[i]
		if !point then continue end
		local pos = Vector(point.pos)
		pos[3] = brush:Process(point,owner:KeyDown( IN_SPEED ))
		render.DrawWireframeBox(point.pos,ang,min,max,pointCol,false)
		render.DrawWireframeBox(pos,ang,min,max,pointNewCol,false)
	end

	if center then
		render.DrawWireframeBox(center.pos,ang,cmin,cmax,centerCol,false)
	end

	cam.End3D()
end