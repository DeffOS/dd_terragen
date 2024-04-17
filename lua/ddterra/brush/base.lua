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

function BRUSH:StartStroke(trc)
end

function BRUSH:UpdateStroke(trc)
end

function BRUSH:EndStroke(trc)
end

// Clientside - Used for 3d preview of brush
function BRUSH:Preview(trc)
end

return BRUSH