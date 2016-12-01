require "Car"
require "Utils"

-- Mutation constants
local WheelRadiusMutRange = 6
local WheelShapeIndexMutRange = 2 -- wheel's position
local BodySideMutRange = 10

-- These parameters are not mutable!
local BodyNumSides = 10
local BodyDensity = 4
local BodySideMin = 25
local BodySideMax = 80
local WheelDensity = 1
local WheelRadiusMin = 22
local WheelRadiusMax = 48

function createFirstCarPrototype(world, x, y)
	local wheel1Radius = math.random(WheelRadiusMin, WheelRadiusMax)
	local wheel2Radius = math.random(WheelRadiusMin, WheelRadiusMax)
	local wheel1ShapeIndex = math.random(1, BodyNumSides-1)
	local wheel2ShapeIndex = math.random(1, BodyNumSides-1)
	
	local bodySides = {}
	
	for i = 1, BodyNumSides do
		bodySides[i] = math.random(BodySideMin, BodySideMax)
	end
	-- Copy the first element to the last position
	bodySides[BodyNumSides + 1] = bodySides[1]
	
	return Car:new(world, x, y, 
		BodyDensity, WheelDensity, bodySides,
		wheel1ShapeIndex, wheel1Radius,
		wheel2ShapeIndex, wheel2Radius)
end

local function mutateWheelRadius(radius)
	local range = WheelRadiusMutRange/2
	return setWithinRange(radius + math.random(-range, range),
		WheelRadiusMin, WheelRadiusMax)
end

local function mutateShapeIndex(shapeIndex)
	local range = WheelShapeIndexMutRange/2
	return setWithinRange(shapeIndex + 
		math.random(-range, range), 1, BodyNumSides)
end

local function mutateBodySides(bodySides)
	local range = BodySideMutRange/2
	
	for i = 1, BodyNumSides do
		bodySides[i] = setWithinRange(bodySides[i] + 
			math.random(-range, range), BodySideMin, BodySideMax)
	end
	-- Do not forget to copy the first side to the last position
	bodySides[BodyNumSides + 1] = bodySides[1]
	
	return bodySides
end

-- Create a new car with mutated parameters of given car
function createMutatedCar(car, world, x, y)
	local wheel1Radius = mutateWheelRadius(car:getWheelRadius("wheel1"))
	local wheel2Radius = mutateWheelRadius(car:getWheelRadius("wheel2"))
	local wheel1ShapeIndex = mutateShapeIndex(car:getWheelShapeIndex("wheel1"))
	local wheel2ShapeIndex = mutateShapeIndex(car:getWheelShapeIndex("wheel2"))
	local bodySides = mutateBodySides(clone(car.bodySides))
	
	return Car:new(world, x, y,
		BodyDensity, WheelDensity, bodySides,
		wheel1ShapeIndex, wheel1Radius,
		wheel2ShapeIndex, wheel2Radius)
end