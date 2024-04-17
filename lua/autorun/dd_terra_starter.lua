local function p(f) return "ddterra/" .. f .. ".lua" end
local function shared(f) f = p(f) AddCSLuaFile(f) include(f) end
local function server(f) if CLIENT then return end f = p(f) include(f) end
local function client(f) f = p(f) AddCSLuaFile(f) if SERVER then return end include(f) end

if false then return end

require("ddcord")

shared("table2d")
shared("globals")
shared("updater/sh")
server("updater/sv")
client("updater/cl")

shared("classes/point/sh")
server("classes/point/sv")
shared("classes/cell/sh")
server("classes/cell/sv")
shared("classes/chunk/sh")
server("classes/chunk/sv")

shared("world")
shared("util")
shared("brush/loader")
client("brush/menu")

if !game.SinglePlayer() and game.IsDedicated() then return end

shared("debug")