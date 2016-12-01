require "class"
require "Utils"

local IdleTime = 5
local WheelRotationVelocity = 1000

-- Car's minimum velocity to not to be considerate idle
local CarMinVelocity = 20

Car = class:new()

function Car:init(world, x, y,
	bodyDensity, wheelDensity, bodySides,
	wheel1ShapeIndex, wheel1Radius,
	wheel2ShapeIndex, wheel2Radius)
	
	self:createBody(world, x, y, bodySides, bodyDensity)
	self:createWheel("wheel1", world, wheel1ShapeIndex, wheel1Radius, wheelDensity)
	self:createWheel("wheel2", world, wheel2ShapeIndex, wheel2Radius, wheelDensity)
	self:generateColor()
	
	self.idleTimer = IdleTime
end

function Car:destroy()
	self.body:destroy()
	self.wheel1.body:destroy()
	self.wheel2.body:destroy()
end

function Car:createBody(world, x, y, bodySides, bodyDensity)
	self.body = love.physics.newBody(world, x, y, "dynamic")
	
	self.shapes = {}
	self.fixtures = {}
	
	local numSides = #bodySides - 1
	
	local angle = 0
	local angleStep = (2*math.pi) / numSides
	
	-- Each car consist from X triangles connected in one vertex
	for i = 1, numSides do
		self.shapes[i] = love.physics.newPolygonShape( 
			bodySides[i] * math.cos(angle), 
			bodySides[i] * math.sin(angle),
			bodySides[i+1] * math.cos(angle+angleStep), 
			bodySides[i+1] * math.sin(angle+angleStep),
			0, 0)
			
		self.fixtures[i] = love.physics.newFixture(
			self.body, self.shapes[i], bodyDensity)
		
		self.fixtures[i]:setUserData("car")
		
		angle = angle + angleStep
	end
	
	-- Store the the triangle sides as well
	self.bodySides = bodySides
end

-- @wheel ... either wheel1 (x)or wheel2
function Car:createWheel(wheel, world, shapeIndex, radius, wheelDensity)
	self[wheel] = {}
	
	self[wheel].shapeIndex = shapeIndex
	
	-- Local coordinates
	local x, y
	local c = {}
	c[1], c[2], c[3], c[4], c[5], c[6] = self.shapes[shapeIndex]:getPoints()

	-- Take first non-center vertex
	for i = 1, 6, 2 do
		if c[i] ~= 0 and c[i+1] ~= 0 then
			x, y = c[i], c[i+1]
			break
		end
	end
	
	-- World coordinates
	local wheelPosX = self.body:getX() + x
	local wheelPosY = self.body:getY() + y
	
	-- Body
	self[wheel].body = love.physics.newBody(world,
		wheelPosX, wheelPosY, "dynamic")
	
	-- Shape
	self[wheel].shape = love.physics.newCircleShape(radius)
	
	-- Fixture
	self[wheel].fixture = love.physics.newFixture(self[wheel].body, 
		self[wheel].shape, wheelDensity)
		
	self[wheel].fixture:setUserData("wheel")
	
	-- Joint between car's body and wheel's body
	self[wheel].joint = love.physics.newRevoluteJoint(
		self.body, self[wheel].body, wheelPosX, wheelPosY)
end

function Car:update(deltaTime)
	-- Timer
	if self:getVelocity() <= CarMinVelocity then
		self.idleTimer = self.idleTimer - deltaTime
	else
		self.idleTimer = self.idleTimer + deltaTime
		
		if self.idleTimer > IdleTime then
			self.idleTimer = IdleTime
		end
	end
			
	-- Update angular velocity of wheels
	local vel = WheelRotationVelocity * deltaTime
	self.wheel1.body:setAngularVelocity(vel)
	self.wheel2.body:setAngularVelocity(vel)
end

function Car:getX()
	return self.body:getX()
end

function Car:isIdle()
	return self.idleTimer <= 0
end

local function randomColor()
	return math.random(0, 255)
end

function Car:generateColor()
	self.color = {
		r = randomColor(),
		g = randomColor(),
		b = randomColor(),
	}
end

-- @wheel = either "wheel1" or "wheel2" 
function Car:getWheelRadius(wheel)
	return self[wheel].shape:getRadius()
end

-- @return index of shape where wheel is connected, 
-- eg. {1..CarBodyNumTriangles}
function Car:getWheelShapeIndex(wheel)
	return self[wheel].shapeIndex
end

function Car:getWheelDensity(wheel)
	return self[wheel].fixture:getDensity()
end

function Car:getBodyDensity()
	-- Density is same for each part of the body
	return self.fixtures[1]:getDensity()
end

function Car:getVelocity()
	local x, y = self.body:getLinearVelocity()
	return math.sqrt(x^2 + y^2)
end

local CircleNumSegments = 50
local ArcAngleOffset = math.pi/20

function Car:drawWheel(wheel)
	local x = self[wheel].body:getX()
	local y = self[wheel].body:getY()
	local radius = self:getWheelRadius(wheel)
	local angle = self[wheel].body:getAngle()
	
	-- Body
	love.graphics.setColor(100, 100, 100)
	love.graphics.circle("fill", x, y, radius, CircleNumSegments)
	
	-- Wheel's rotating indicator
	love.graphics.setColor(0, 0, 0)
	love.graphics.arc("fill", x, y, radius, angle, angle + ArcAngleOffset,
		math.floor(CircleNumSegments * (ArcAngleOffset / (2*math.pi))))
	
	-- Borders
	love.graphics.setLineWidth(2)
	love.graphics.circle("line", x, y, radius, CircleNumSegments)
	
	love.graphics.setLineWidth(1)	
	love.graphics.setColor(255, 255, 255)
end

function Car:draw()
	love.graphics.push()
	love.graphics.translate(self.body:getX(), self.body:getY())
	love.graphics.rotate(self.body:getAngle())
	
	-- Triangle (body part) vertices
	local x1, y1, x2, y2, x3, y3
	
	-- Draw body
	for i = 1, #self.bodySides-1 do
		x1, y1, x2, y2, x3, y3 = self.shapes[i]:getPoints()
		
		-- Body
		love.graphics.setColor(self.color.r, self.color.g, self.color.b)
		love.graphics.polygon("fill", x1, y1, x2, y2, x3, y3)
		
		-- Borders
		love.graphics.setLineWidth(2)
		love.graphics.setColor(0, 0, 0)
		love.graphics.polygon("line", x1, y1, x2, y2, x3, y3)
		love.graphics.setLineWidth(1)
	end
	
	love.graphics.setColor(255, 255, 255)
	love.graphics.pop()
	
	-- Draw wheels
	self:drawWheel("wheel1")
	self:drawWheel("wheel2")
end

function Car:drawPositionLine(winHeight)
	love.graphics.setColor(100, 255, 100)
	love.graphics.line(self:getX(), 0, self:getX(), winHeight)
	love.graphics.setColor(255, 255, 255)
end

-- Create precise clone of the car but with different world's position
function Car:clone(world, x, y)
	return Car:new(world, x, y,
		self:getBodyDensity(), self:getWheelDensity("wheel1"), clone(self.bodySides),
		self:getWheelShapeIndex("wheel1"), self:getWheelRadius("wheel1"),
		self:getWheelShapeIndex("wheel2"), self:getWheelRadius("wheel2"))
end