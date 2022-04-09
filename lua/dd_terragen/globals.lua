TERRA_CELL_SIZE = 128
TERRA_CHUNK_SIZE = 16
TERRA_TEXEL_PER_PATCH = 4
TERRA_VERTEX_SEND_MAX = 2000
TERRA_CHUNK_SEND_MAX = 50

do
	local verts = {}
	for x=1,TERRA_CHUNK_SIZE+1,1 do
		verts[x] = {}
		for y=1,TERRA_CHUNK_SIZE+1,1 do
			verts[x][y] = Vector((x-1)*TERRA_CELL_SIZE,(y-1)*TERRA_CELL_SIZE)
		end
	end
	TERRA_CHUNK_VERTS = verts
end

do
	local FlipOrder = {}
	for x=1,TERRA_CHUNK_SIZE,1 do
		FlipOrder[x] = {}
		local xf = x%2==0
		for y=1,TERRA_CHUNK_SIZE,1 do
			local yf = y%2==0
			FlipOrder[x][y] = Either(yf,xf,!xf)
		end
	end
	TERRA_FLIPORDER = FlipOrder
end