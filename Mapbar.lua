require "class"
require "Utils"
require "Population"

-- Car's identifier's width on mapbar
local CarRectWidth = 4

Mapbar = class:new()

function Mapbar:init(winWidth, barHeight, surfaceLength)
	self.width = winWidth
	self.height = barHeight
	self.surfaceLength = surfaceLength
end

-- Get camera position by mouse click to mapbar.
-- If the mouse is not inside mapbar, then return nil.
function Mapbar:getCameraPosition(x, y)
	if pointInRect(x, y, 0, 0, self.width, self.height) then
		return x/self.width * (self.surfaceLength-self.width)
	else
		return nil
	end
end

-- @x = distance of the car in the real world
function Mapbar:getCarPosition(x)
	return x/self.surfaceLength * self.width - CarRectWidth/2
end

function Mapbar:draw(camera, population)
	-- Background
	love.graphics.setColor(100, 200, 100, 100)
	love.graphics.rectangle("fill", 0, 0, self.width, self.height)
	
	-- Border
	love.graphics.setColor(0, 200, 0, 255)
	love.graphics.setLineWidth(2)
	love.graphics.rectangle("line", 0, 0, self.width, self.height)
	
	-- Active cars
	love.graphics.setColor(200, 50, 50)
	love.graphics.setLineWidth(1)
	
	for i = 1, population.numCars do
		local x = self:getCarPosition(population:getICar(i):getX())
		love.graphics.rectangle("fill", x, 0, CarRectWidth, self.height)
	end
	
	-- Current leader
	love.graphics.setColor(50, 50, 50)
	love.graphics.setColor(50, 50, 200)
	love.graphics.rectangle("fill", 
		self:getCarPosition(population:getCurrentLeaderPosition()),
		0, CarRectWidth, self.height)
	
	-- Overall leader
	love.graphics.setColor(50, 50, 200)
	love.graphics.rectangle("fill", 
		self:getCarPosition(population.overallLeaderDistance),
		0, CarRectWidth, self.height)
	
	-- Camera position
	local camMapbarPos = camera/self.surfaceLength * self.width
	local camMapbarWidth = self.width/self.surfaceLength * self.width
	
	love.graphics.setColor(100, 200, 200, 100)
	love.graphics.rectangle("fill", camMapbarPos, 0,
		camMapbarWidth, self.height)
		
	love.graphics.setColor(255, 255, 255, 255)
end