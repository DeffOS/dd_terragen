function _Load(path,shared)
	path = "dd_terragen/server/"..path..".lua"
	include(path)
end

_Load("globals")
_Load("classes")