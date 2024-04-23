AddCSLuaFile()
local BRUSH = {}
BRUSH.Base = "base"
BRUSH.Abstract = true
BRUSH.Name = "Base brush"
BRUSH.Icon = ""
BRUSH.Category = "misc"

// Properties Types: int,float,string,vec2di
BRUSH.Properties = {
	{"Radius","int",3,min = 0,max = 128},
	{"Force","float",32,min = -16000,max = 16000},
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

function BRUSH:Cancel()

end

// Clientside - Used for 3d preview of brush
function BRUSH:Preview(trc)
end

return BRUSH