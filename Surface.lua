require "class"
require "Utils"

Surface = class:new()

function Surface:init(world, platformLength, numPlatforms, 
	maxPlatformAngle, startY, minY, maxY)
	
	self.platforms = {}
	
	local angle = 0
	local x, y = 0, startY
	local vx, vy
	
	for i = 1, numPlatforms do
		angle = maxPlatformAngle * (i/numPlatforms) * unitRandom()
		vx = platformLength * math.cos(angle)
		vy = platformLength * math.sin(angle)
		
		-- Outside vertical limit?
		if y + vy > maxY or y + vy < minY then
			vy = -vy
		end
		
		self:createPlatform(world, x, y, vx, vy)
		
		x = x + vx
		y = y + vy
	end
	
	self.length = x
end

function Surface:createPlatform(world, x, y, vx, vy)
	local platform = {}
	
	self.platforms[#self.platforms + 1] = platform
	
	platform.body = love.physics.newBody(world, x + vx/2, y + vy/2)
	platform.shape = love.physics.newEdgeShape(-vx/2, -vy/2, vx/2, vy/2)
	platform.fixture = love.physics.newFixture(platform.body, platform.shape)
	platform.fixture:setUserData("platform")
end

function Surface:drawPlatform(platform)
	local x, y = platform.body:getPosition()
	local x1, y1, x2, y2 = platform.shape:getPoints()
	
	love.graphics.line(x + x1, y + y1, x + x2, y + y2)
end

function Surface:draw()
	love.graphics.setColor(255, 100, 100)
	love.graphics.setLineWidth(4)
	
	for i = 1, #self.platforms do
		self:drawPlatform(self.platforms[i])
	end
	
	love.graphics.setLineWidth(1)
	love.graphics.setColor(255, 255, 255)
end
