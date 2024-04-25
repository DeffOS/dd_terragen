-- local format = string.format
-- local insert = table.insert
local perftest = ddcord.perftest
module("ddterra",package.seeall)

-- if Points and Cells and Chunks then return end

Points = Points or Table2D(WorldCellCount + 1)
Cells = Cells or Table2D(WorldCellCount)
Chunks = Chunks or Table2D(WorldChunkCount)
-- function index(x,y) return format("%i|%i",x,y) end
-- function index(x,y) return x * WorldCellCount + y end

function Initialize()
	perftest.Start()
	for x = 0,Points._sizex - 1 do
		for y = 0,Points._sizey - 1 do
			Points:Set(x,y,CreatePoint(x,y))
		end
	end
	perftest.Spew("Created Points")
	for x = 0,Cells._sizex - 1 do
		for y = 0,Cells._sizey - 1 do
			Cells:Set(x,y,CreateCell(x,y,
				Points:Get(x  ,y+1),Points:Get(x+1,y+1),
				Points:Get(x+1,y  ),Points:Get(x  ,y  )
			))
		end
	end
	perftest.Spew("Created Cells")
	for x = 0,Chunks._sizex - 1 do
		for y = 0,Chunks._sizey - 1 do
			local cells = {}
			do
				local minx,maxx = x * ChunkSize,(x + 1) * ChunkSize - 1
				local miny,maxy = y * ChunkSize,(y + 1) * ChunkSize - 1
				local index = 0
				for cx = minx,maxx do
					for cy = miny,maxy do
						index = index + 1
						cells[index] = Cells:Get(cx,cy)
					end
				end
				-- print("AAAA",index,ChunkSize * ChunkSize)
			end
			Chunks:Set(x,y,CreateChunk(x,y,cells))
		end
	end
	perftest.End("Created Chunks")
end
Initialize()
concommand.Add("ddterra.initialize",function()
	for _,ent in ipairs(ents.FindByClass("ddterra_chunk")) do
		ent:Remove()
	end
	for _,chunk in Chunks:ForEachIndex() do
		chunk:CreateEntity()
	end
end)

if CLIENT then return end

hook.Add("PostCleanupMap", "ddterra.cleanup", function()
	for _,chunk in Chunks:ForEachIndex() do
		chunk:CreateEntity()
	end
end)