module("ddterra",package.seeall)

function POINT:MarkAsDirty()
	if self._dirty then return end
	self._dirty = true
	ReportUpdate(UPDTYPE_POINT,self)
end

function POINT:SetHeight(amount)
	amount = math.floor(amount)
	if amount == self.pos[3] then return end
	self.pos[3] = amount
	self:MarkAsDirty()
end

function POINT:SetAlpha(amount)
	amount = math.Clamp(math.floor(amount),0,255)
	if amount == self.color.a then return end
	self.color.a = amount
	self:MarkAsDirty()
end

function POINT:GetChangeableValues()
	return self:GetHeight(),self:GetAlpha()
end

function POINT:ApplyChanges(hgt,alp)
	self:SetHeight(hgt)
	self:SetAlpha(alp)
	self:Update()
end