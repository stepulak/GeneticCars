require "Mutations"
require "Car"

Population = class:new()

function Population:init(numCars, world, initPosX, initPosY)
	self.numCars = numCars
	self.cars = {}
	self.world = world
	self.initPosX = initPosX
	self.initPosY = initPosY
	
	self:createFirstPopulation()
	self.populationNumber = 1
	
	-- Set leader
	self.currentLeader = self.cars[1]
	self.overallLeader = self.overallLeader
	self.overallLeaderDistance = 0
end

function Population:createNewPopulation()
	-- Destory the old population
	for i = 1, self.numCars do
		if self.cars[i] ~= self.overallLeader then
			self.cars[i]:destroy()
		end
	end
	
	-- Clone overallLeader (best leader)
	self.cars[1] = self.overallLeader:clone(
		self.world, self.initPosX, self.initPosY)
	
	-- Destroy the old one
	self.overallLeader:destroy()
	
	-- Select new one - he is part of the population now
	self.overallLeader = self.cars[1]
	self.currentLeader = self.overallLeader
	
	-- Create and mutate the rest
	for i = 2, self.numCars do
		self.cars[i] = createMutatedCar(self.overallLeader,
			self.world, self.initPosX, self.initPosY)
	end
end

function Population:createFirstPopulation()
	for i = 1, self.numCars do
		self.cars[i] = createFirstCarPrototype(
			self.world, self.initPosX, self.initPosY)
	end
end

function Population:getCurrentLeaderPosition()
	return self.currentLeader:getX()
end

function Population:getICar(i)
	return self.cars[i]
end

function Population:update(deltaTime)
	local numActives = self.numCars
	
	for i = 1, self.numCars do
		if self.cars[i]:isIdle() then
			numActives = numActives - 1
		else
			self.cars[i]:update(deltaTime)
		end
		
		-- Select new current (active) leader if possible
		if self.cars[i]:getX() > self.currentLeader:getX() then
			self.currentLeader = self.cars[i]
		end
	end
	
	-- Is the currentLeader new overallLeader?
	if self.currentLeader:getX() > self.overallLeaderDistance then
		self.overallLeader = self.currentLeader
		self.overallLeaderDistance =  self.currentLeader:getX()
	end
	
	if numActives == 0 then
		-- Create new population based on overallLeader
		self:createNewPopulation()
		self.populationNumber = self.populationNumber + 1
	end
end

function Population:draw(winHeight)
	for i = 1, self.numCars do
		if self.cars[i]:isIdle() == false then
			self.cars[i]:draw()
		else
			self.cars[i]:drawPositionLine(winHeight)
		end
	end
	
	-- Overall leader position (best score yet)
	love.graphics.setColor(100, 100, 255)
	love.graphics.line(self.overallLeaderDistance, 0, 
		self.overallLeaderDistance, winHeight)
	love.graphics.setColor(255, 255, 255)
end