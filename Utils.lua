-- Based on https://gist.github.com/MihailJP/3931841
-- Clone the table, it's also possible to clone the table's elements
-- via recursion if deepClone is enabled.
function clone(t, deepClone)
    if type(t) ~= "table" then 
		return t
	end
	
    local meta = getmetatable(t)
    local target = {}
	
    for k, v in pairs(t) do
        if type(v) == "table" and deepClone then
            target[k] = clone(v, true)
        else
            target[k] = v
        end
    end
	
    setmetatable(target, meta)
    
	return target
end

function setWithinRange(value, min, max)
	if value < min then
		return min
	elseif value > max then
		return max
	else
		return value
	end
end

function pointInRect(x, y, rectX, rectY, rectW, rectH)
	return x >= rectX and y >= rectY 
		and x <= rectX+rectW and y <= rectY+rectH
end


-- @return value from interval (-1,1)
function unitRandom()
	return math.random() * (math.random() < 0.5 and -1 or 1)
end