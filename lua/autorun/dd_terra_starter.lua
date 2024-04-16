local function p(f) return "ddterra/" .. f .. ".lua" end
local function shared(f) f = p(f) AddCSLuaFile(f) include(f) end
local function server(f) if CLIENT then return end f = p(f) include(f) end

if false then return end

require("ddcord")

shared("table2d")
shared("globals")
shared("updater/sh")
server("updater/sv")

shared("classes/point/sh")
server("classes/point/sv")
shared("classes/cell/sh")
server("classes/cell/sv")
shared("classes/chunk/sh")
server("classes/chunk/sv")

shared("world")
shared("util")
shared("brush/loader")

if !game.SinglePlayer() and game.IsDedicated() then return end

shared("debug")