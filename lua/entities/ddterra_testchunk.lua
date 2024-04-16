AddCSLuaFile()
ENT.Base = "ddterra_chunk"

function ENT:InitChunkData()
	local chunk
	do
		local points = Table2D(ddterra.ChunkSize + 1)
		do
			local count = ddterra.ChunkSize + 1
			local x = 0; while (x < count) do
				local y = 0; while (y < count) do
					points:Set(x,y,ddterra.CreatePoint(x,y))
					y = y + 1;
				end
				x = x + 1;
			end
		end
		local cells = Table2D(ddterra.ChunkSize)
		do
			local count = ddterra.ChunkSize
			local x = 0; while (x <= count) do
				local y = 0; while (y <= count) do
					cells:Set(x,y,ddterra.CreateCell(x,y,
						points:Get(x,y+1),points:Get(x+1,y+1),
						points:Get(x+1,y),points:Get(x,y))
					)
					y = y + 1;
				end
				x = x + 1;
			end
		end
		local chunkcells = {}
		for i,v in cells:ForEachIndex() do
			chunkcells[i+1] = v
		end

		chunk = ddterra.CreateChunk(0,0,chunkcells)

		-- PrintTable(points)
		-- PrintTable(cells)
	end
	do
		local test = {}
		for k ,v in ipairs(chunk.Triangles) do
			local count = test[v] or 0
			test[v] = count + 1
		end
		for k ,v in pairs(test) do
			print(k,v)
		end
	end
	-- PrintTable(chunk.Triangles)
	chunk.Entity = self
	self.Chunk = chunk
end