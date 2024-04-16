local round = math.Round
local floor = math.floor
local ceil = math.ceil
local insert = table.insert

local function clamp(v,min,max)
	return v < min && min || (v > max && max || v)
end

module("ddterra",package.seeall)

function SnapPosToPoint(pos)
	local point = Points:Get(PosToIndex(pos))
	if point then return point.pos end

	return pos
end

function PosToIndex(pos,method)
	method = method == nil && round || (method && floor || ceil)

	return method(pos[1] / CellSize) + WorldCellOffset,method(pos[2] / CellSize) + WorldCellOffset
end

function GetPointsInRadius(x,y,rad,tab,copy)
	local minx,maxx = x - rad,x + rad
	local miny,maxy = y - rad,y + rad
	tab = tab || {}
	local index = 0

	for cx = minx,maxx do
		for cy = miny,maxy do
			index = index + 1
			tab[index] = Points:Get(cx,cy)
		end
	end

	tab._count = index

	return tab
end

function PosPointToChunk(x,y)
	return floor(x / ChunkSize),floor(y / ChunkSize)
end

function GetPointChunks(point)
	local x,y = point.X,point.Y
	local cx,cy = PosPointToChunk(x,y)
	local lx,ly = x - cx * ChunkSize,y - cy * ChunkSize
	local res = {}
	local count = 0
	count = count + 1
	res[count] = Chunks:Get(cx,cy)

	if lx == 0 then
		local c = Chunks:GetSafe(cx - 1,cy)

		if c then
			count = count + 1
			res[count] = c
		end
	end

	if ly == 0 then
		local c = Chunks:GetSafe(cx,cy - 1)

		if c then
			count = count + 1
			res[count] = c
		end
	end

	if lx == 0 && ly == 0 then
		local c = Chunks:GetSafe(cx - 1,cy - 1)

		if c then
			count = count + 1
			res[count] = c
		end
	end

	res._count = count

	return res
end

local mxchnk = WorldChunkCount - 1

function GetPointAreaChunks(sx,sy,ex,ey)
	local res = {}
	local count = 0
	sx,sy = PosPointToChunk(sx,sy)
	sx,sy = sx - 1,sy - 1
	ex,ey = PosPointToChunk(ex,ey)
	sx,sy = clamp(sx,0,mxchnk),clamp(sy,0,mxchnk)
	ex,ey = clamp(ex,0,mxchnk),clamp(ey,0,mxchnk)

	for x = sx,ex do
		for y = sy,ey do
			count = count + 1
			res[count] = Chunks:Get(x,y)
		end
	end

	res._count = count

	return res
end