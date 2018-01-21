local pi2 = math.pi*2
local sin = math.sin
local cos = math.cos

function split(s,c)
	local t = {}
	local x0 = 1
	local x1 = string.find(s,c)
	while x1 ~= nil do
		t[#t+1] = string.sub(s,x0,x1-1)
		x0 = x1+#c
		x1 = string.find(s,c,x0+#c)
	end
	t[#t+1] = string.sub(s,x0)
	return t
end

--[[ From: https://gist.github.com/MihailJP/3931841#file-d_copy-lua ]]--
function clone (t) -- deep-copy a table
	if type(t) ~= "table" then return t end
	local meta = getmetatable(t)
	local target = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			target[k] = clone(v)
		else
			target[k] = v
		end
	end
	setmetatable(target, meta)
	return target
end

--[[ based on: https://love2d.org/forums/viewtopic.php?t=80476 ]]--
function polyregular(n, x, y, w, h)
	local out = {}
	local i = 1
	for j = 0, n do
		local a = j/n*pi2
		out[i] = x+sin(a)*w/2
		out[i + 1] = y-cos(a)*h/2
		i = i + 2
	end
	return out
end

