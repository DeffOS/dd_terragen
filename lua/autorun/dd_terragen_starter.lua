TERRA = TERRA or {}
function _Load(path,shared)
	if shared then
		path = "dd_terragen/"..path..".lua"
		AddCSLuaFile(path)
		include(path)
	else
		path = "dd_terragen/client/"..path..".lua"
		AddCSLuaFile(path)
		if CLIENT then include(path) end
	end
end

_Load("globals",true)
_Load("classes",true)
_Load("classes")