local BRUSH = {}
BRUSH.Base = "base"
BRUSH.Abstract = true
BRUSH.Name = "Base brush"
BRUSH.Icon = ""
BRUSH.Category = "misc"

// Properties Types: int,float,string,vec2di
BRUSH.Properties = {
	{"Radius","int",3},
	{"Force","float",32},
}

function BRUSH:GetTool()
	return self.e_toolwep
end

function BRUSH:GetOwner()
	return self.e_toolwep:GetOwner()
end

function BRUSH:StartStroke(x,y)
end

function BRUSH:UpdateStroke(x,y)
end

function BRUSH:EndStroke(x,y)
end

// Clientside - Used for 3d preview of brush
function BRUSH:Preview(pos)
end

return BRUSH