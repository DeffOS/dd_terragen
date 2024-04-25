module("ddterra",package.seeall)

function CELL:MarkAsDirty()
	if self._dirty then return end
	self._dirty = true
	ReportUpdate("cells",self)
end

function CELL:SetMatID(trg)
	self.MatID = math.Clamp(math.floor(trg),0,15)
	self:MarkAsDirty()
end

function CELL:SetInvert(trg)
	self.Invert = trg
	self:MarkAsDirty()
end

function CELL:SetSolid(trg)
	self.Solid = trg
	self:MarkAsDirty()
end