require "Car"
require "Mutations"
require "Surface"
require "Population"
require "Mapbar"

local WinWidth = 800
local WinHeight = 600

local RandomSeed = os.time()

local Gravity = 9.81*64

local MapbarHeight = WinHeight/10

local NumberOfCarsInPopulation = 7
local CarInitPositionX = 200
local CarInitPositionY = 200

local CameraSpeed = 1000

-- Surface
local PlatformLength = 50
local NumberOfPlatforms = 200
local PlatformAngleDif = math.pi/3
local PlatformStartHeight = WinHeight * 0.7

local camera = 0
local cameraLeaderLock = false

local world
local surface
local population
local mapbar

local function createWorld()
	world = love.physics.newWorld(0, Gravity)
	
	world:setCallbacks(
		function() end, -- begincontact  
		function() end, -- endcontact
		function(a, b, col) -- presolve
			if (a:getUserData() == "car" or a:getUserData() == "wheel") and
				(b:getUserData() == "car" or b:getUserData() == "wheel") then
				col:setEnabled(false)
			end
		end,
		function() end -- postsolve
	)
	
	surface = Surface:new(world, PlatformLength, NumberOfPlatforms, 
		PlatformAngleDif, PlatformStartHeight, CarInitPositionY, WinHeight)
end

function love.load()
	math.randomseed(RandomSeed)
	--love.window.setMode(WinWidth, WinHeight)
	love.graphics.setBackgroundColor(255, 255, 255)
	
	createWorld()
	
	-- Initial population
	population = Population:new(NumberOfCarsInPopulation, world, 
		CarInitPositionX, CarInitPositionY)
		
	mapbar = Mapbar:new(WinWidth, MapbarHeight, surface.length)
end

function love.keypressed(k, isRep)
	if k == "escape" then
		love.event.quit()
	elseif k == "space" then
		cameraLeaderLock = not cameraLeaderLock
	end
end

local function setCameraIntoWorld()
	camera = setWithinRange(camera, 0, surface.length - WinWidth)
end

-- If the mouse button is down and inside mapbar
-- then set the new camera position according to the mouse cursor
local function setCameraPositionMapbar()
	if love.mouse.isDown(1, 2, 3) then
		local x, y = love.mouse.getPosition()
		local newCamera = mapbar:getCameraPosition(x, y)
		
		if newCamera ~= nil then
			-- Valid camera
			camera = newCamera
		end
	end
end

local function updateCameraMovement(deltaTime)
	if cameraLeaderLock then
		camera = population:getCurrentLeaderPosition() - WinWidth/2
	else
		if love.keyboard.isDown("d") then
			camera = camera + CameraSpeed * deltaTime
		end
		if love.keyboard.isDown("a") then
			camera = camera - CameraSpeed * deltaTime
		end
		
		setCameraPositionMapbar()
	end
	
	setCameraIntoWorld()
end

function love.update(deltaTime)
	world:update(deltaTime)
	population:update(deltaTime)
	updateCameraMovement(deltaTime)
end

function drawText()
	-- Stats
	love.graphics.setColor(0, 0, 0)
	love.graphics.print("Population number: " .. 
		population.populationNumber, 10, WinHeight - 70)
	love.graphics.print("Overall leader best distance: " .. 
		math.floor(population.overallLeaderDistance), 10, WinHeight - 55)
	love.graphics.print("Current leader position: " .. 
		math.floor(population:getCurrentLeaderPosition()), 10, WinHeight - 40)
	love.graphics.print("Camera: " .. 
		math.floor(camera/(surface.length-WinWidth) * 100) .. " %",
		10, WinHeight - 25)
	
	-- Info
	love.graphics.print("Camera leader lock (SPACE): " ..
		(cameraLeaderLock and "true" or "false"), 
		WinWidth - 250, WinHeight - 25)
	
	love.graphics.setColor(255, 255, 255)
end

function love.draw()
	love.graphics.translate(-camera, 0)
	population:draw(WinHeight)
	surface:draw()
	love.graphics.translate(camera, 0)
	
	mapbar:draw(camera, population)
	drawText()
end