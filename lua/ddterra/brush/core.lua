module("ddterra.brushes",package.seeall)

if CLIENT then return end

function PlayerRequestedType(ply,type)
	local tool = ply:GetWeapon("ddterra_sculpt")
	if !IsValid(tool) then return end
	tool:SetBrushType(type)
end
function PlayerRequestedSettings(ply,tab)
	local tool = ply:GetWeapon("ddterra_sculpt")
	if !IsValid(tool) then return end
	tool:SetBrushSettings(util.TableToJSON(tab))
end