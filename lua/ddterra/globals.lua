module("ddterra",package.seeall)
local CELLSIZE = 7
local CHUNKSIZE = 4
CellSize = 2 ^ CELLSIZE
ChunkSize = 2 ^ CHUNKSIZE
ChunkVolume = CellSize * ChunkSize
WorldCellCount = 2 ^ (15 - CELLSIZE)
WorldChunkCount = 2 ^ (15 - (CELLSIZE + CHUNKSIZE))
WorldOffset = 2 ^ 14
WorldCenterChunk = WorldChunkCount / 2
WorldCellOffset = WorldCellCount / 2
LightmapSize = 2 ^ 11 // 11 = 2048
UVTextureScale = .5
UVLightmapScale = LightmapSize / (2 ^ 15) / WorldChunkCount