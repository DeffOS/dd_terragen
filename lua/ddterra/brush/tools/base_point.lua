local BRUSH = {}
BRUSH.Base = "base"

function BRUSH:StartStroke(trc)
	local x,y = ddterra.PosToIndex(trc.HitPos)
	self.strokeX = x
	self.strokeY = y
	self:ApplyStroke(x,y)
end

function BRUSH:UpdateStroke(trc)
	local x,y = ddterra.PosToIndex(trc.HitPos)
	if x == self.strokeX && y == self.strokeY then return end
	self.strokeX = x
	self.strokeY = y
	self:ApplyStroke(x,y)
end

function BRUSH:EndStroke(trc)
	self:ApplyStroke(ddterra.PosToIndex(trc.HitPos))
end

do
	local points

	function BRUSH:ApplyStroke(x,y)
		points = ddterra.GetPointsInRadius(x,y,self.Radius,points)
		local center = ddterra.GetPoint(x,y)

		for i = 1,points._count do
			local point = points[i]
			if !point then continue end
			point:ApplyChanges(self:Process(center,point,self:GetOwner():KeyDown(IN_SPEED)))
		end
	end
end

function BRUSH:Process(center,point,invert)
	return point:GetHeight(),point:GetAlpha()
end

local pointCol = Color(64,0,0)
local pointLnCol = Color(128,0,0)
local pointNewCol = Color(255,0,0)
local centerCol = Color(0,255,0)
local ang = Angle()
local min,max = Vector(-8,-8,-8),Vector(8,8,8)
local cmin,cmax = Vector(-10,-10,-10),Vector(10,10,10)
local points = {}

// Clientside - Used for 3d preview of brush
function BRUSH:Preview(trc)
	local x,y = ddterra.PosToIndex(trc.HitPos)
	local rad = self.Radius
	points = ddterra.GetPointsInRadius(x,y,rad,points)
	local center = ddterra.GetPoint(x,y)

	for i = 1,points._count do
		local point = points[i]
		if !point then continue end
		local pos = Vector(point.pos)
		pos[3] = self:Process(center,point,self:GetOwner():KeyDown(IN_SPEED))
		//render.DrawWireframeBox(point.pos,ang,min,max,pointCol,false)
		render.DrawLine(pos,point.pos,pointLnCol,false)
		render.DrawWireframeBox(pos,ang,min,max,pointNewCol,false)
	end

	if center then
		render.DrawWireframeBox(center.pos,ang,cmin,cmax,centerCol,false)
	end
end

return BRUSH