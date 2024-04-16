local rawget = rawget
local TypeAssert = ddcord.TypeAssert
local META = {}
META.__index = META
META.__name = "Table2D"

function Table2D(sizex,sizey)
	TypeAssert(1,sizex,"number")

	if !isnumber(sizey) then
		sizey = sizex
	end

	return setmetatable({
		_getindex = function(x,y) return x * sizex + y end,
		_sizex = sizex,
		_sizey = sizey,
		_count = sizex * sizey
	},META)
end

function META:Get(x,y)
	return rawget(self,self._getindex(x,y))
end

function META:GetSafe(x,y)
	if x < 0 or x >= self._sizex or y < 0 or y >= self._sizey then return end
	return rawget(self,self._getindex(x,y))
end

function META:Set(x,y,v)
	self[self._getindex(x,y)] = v
end

function META:__len()
	return self._count
end

do
	local function iterator(t,i)
		i = i + 1
		if i < t._count then return i,rawget(t,i) end
		return nil
	end

	function META:ForEachIndex()
		return iterator,self,-1
	end
end

do
	local function iterator(state)
		local t = state.self
		local i = state.i + 1

		if i < t._count then
			state.i = i
			local y = i % t._sizex
			local x = (i - y) / t._sizex

			return x,y,rawget(t,i)
		end

		return nil
	end

	function META:ForEachCoord()
		return iterator,{
			self = self,
			i = -1,
		}
	end
end

function META:GetRawClone()
	local count = self._count
	local res = {
		_count = count
	}
	for i = 0, count - 1 do
		res[i+1] = self[i]
	end
	return res
end

if false then
	if CLIENT then return end
	local testy = Table2D(16)

	for i,val in testy:ForEachIndex() do
		print(i,val)
	end

	for x,y,val in testy:ForEachCoord() do
		print(x,y,val)
	end
end