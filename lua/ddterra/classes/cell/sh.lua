local insert = table.insert
module("ddterra",package.seeall)
CELL = CELL || {}
CELL.__index = CELL

// P1--P2  Y+
//	|\ |   ^
//	| \|   |
// P4--P3  |_____> X+
//
// [+y,-x],[+y,+x],[-y,+x],[-y,-x]
function CreateCell(x,y,p1,p2,p3,p4)
	return setmetatable({
		_dirty = false,
		_flip = (x + y) % 2 == 0,
		X = x,
		Y = y,
		P1 = p1,
		P2 = p2,
		P3 = p3,
		P4 = p4,
		MatID = 1,
		Invert = false,
		Solid = true,
	},CELL)
end

function CELL:Update()

end

function CELL:GetID()
	return self.X * WorldCellCount + self.Y
end

function CELL:PushQuad(stack)
	local p1,p2,p3,p4 = self.P1,self.P2,self.P3,self.P4

	if self._flip then
		insert(stack,p1)
		insert(stack,p2)
		insert(stack,p4)

		insert(stack,p2)
		insert(stack,p3)
		insert(stack,p4)
	else
		insert(stack,p1)
		insert(stack,p2)
		insert(stack,p3)

		insert(stack,p1)
		insert(stack,p3)
		insert(stack,p4)
	end
end

function CELL:WriteNet()
	net.WriteUInt(self.MatID,4)
	net.WriteBool(self.Invert)
	net.WriteBool(self.Solid)
end

function CELL:ReadNet()
	self.MatID = net.ReadUInt(4)
	self.Invert = net.ReadBool()
	self.Solid = net.ReadBool()
end