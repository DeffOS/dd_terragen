local insert = table.insert
local format = string.format
local inherit = table.Inherit
local rawget = rawget
local type = type
module("ddterra",package.seeall)
AddCSLuaFile("base.lua")
local baseBrush = include("base.lua")
Brushes = Brushes || {}

local function LoadBrushes()
	local brushes = {
		_list = {
			base = baseBrush
		}
	}

	do
		local path = "ddterra/brush/tools/"
		local files,_ = file.Find(path .. "*.lua","LUA")

		for _,name in ipairs(files) do
			local filepath = path .. name
			AddCSLuaFile(filepath)
			local brush = include(filepath)
			brush.__index = brush
			local className = name:lower():sub(0,-5)
			brush.ClassName = className
			brushes._list[className] = brush
			insert(brushes,brush)
		end
	end

	for _,brush in ipairs(brushes) do
		local base = brush.Base
		assert(base,format("Brush (%s) has no base brush!",brush.ClassName))
		base = brushes._list[base]
		assert(base,format("Brush (%s) has non-existant base brush (%s)!",brush.ClassName,brush.Base))
		brush.BaseClass = base
		if brush.Abstract then continue end
		Brushes[brush.ClassName] = brush
	end
end

LoadBrushes()

local function solveParent(tab,parent,anti)
	if anti[parent] then return end
	anti[parent] = true
	inherit(tab,parent)

	if parent.BaseClass then
		solveParent(tab,parent.BaseClass,anti)
	end
end

function GetNewBrush(class,old)
	local brush = Brushes[class:lower()]
	assert(brush,format("Brush (%s) doesnt exist!",class))
	local meta = {}
	solveParent(meta,brush,{})
	old = old || {}
	local new = {}

	for _,prop in ipairs(meta.Properties) do
		local name,val = prop[1],prop[3]
		local oldval = rawget(old,name)

		if oldval && type(oldval) == type(val) then
			val = oldval
		end

		new[name] = val
	end

	return setmetatable(new,meta)
end

AddCSLuaFile("menu.lua")
if SERVER then return end
include("menu.lua")