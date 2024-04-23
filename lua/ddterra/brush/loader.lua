local insert = table.insert
local format = string.format
local inherit = table.Inherit
local rawget = rawget
local type = type
module("ddterra.brushes",package.seeall)
BaseBrush = include("base_brush.lua")
BaseBrush.__index = BaseBrush
Brushes = Brushes || {}

local function LoadBrushes()
	local brushes = {
		_list = {
			base = BaseBrush
		}
	}

	do
		local path = "ddterra/brush/tools/"
		local files,_ = file.Find(path .. "*.lua","LUA")

		for _,name in ipairs(files) do
			local filepath = path .. name
			AddCSLuaFile(filepath)
			local brush = include(filepath)
			local className = name:lower():sub(0,-5)
			brush.ClassName = className
			brushes._list[className] = brush
			insert(brushes,brush)
		end
	end

	for _,brush in ipairs(brushes) do
		local base = brush.Base || "base"
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

	if !brush then
		brush = BaseBrush
		MsgC(Color(255,0,0),format("Brush (%s) doesnt exist!\n",class))
	end

	local meta = {}
	solveParent(meta,brush,{})
	meta.__index = meta
	meta.Abstract = nil
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

function GetBrushSettings(brush)
	local res = {}

	for _,prop in ipairs(brush.Properties) do
		local propname = prop[1]
		res[propname] = brush[propname] || prop[3]
	end

	return res
end