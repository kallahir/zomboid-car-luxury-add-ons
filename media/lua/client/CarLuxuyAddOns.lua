local MOD_NAME = "Car Luxuy Add-Ons"
local MOD_AUTHOR = "kallahir"
local MOD_VERSION = "1.00"

-- Function to log mod details for troubleshooting purposes
local function info()
    print("Mod Loaded: " .. MOD_NAME .. " v." .. MOD_VERSION .. " by " .. MOD_AUTHOR)
end 

Events.OnGameBoot.Add(info)

local data = {
    vehicle = nil,
    stopStart = false
}

-- Function to auto lock all vehicle doors
local function autoLockDoors()
    local doorParts = {"DoorFrontLeft", "DoorFrontRight", "DoorRearLeft", "DoorRearRight"}
    
    for _, partID in ipairs(doorParts) do
        local part = data.vehicle:getPartById(partID)
        if part then
            print("[autoLockDoors]" .. partID .. " is present on the vehicle.")
            local lock = part:getDoor()
            if lock then
                lock:setLocked(true)
                print("[autoLockDoors]" .. partID .. " is now locked.")
            end
        end
    end
end

-- On player update if the player is inside a vehicle we are going to track its speed
-- and if the speed breaches a certain threshold all the door will be automatically locked 
local function onPlayerUpdate(player)
    if player == nil then
        print("[onPlayerUpdated] Error: player is nil")
        return
    end

    if data.vehicle ~= nil then
        local speed = data.vehicle:getCurrentSpeedKmHour()
        if speed == nil then
            print("[onPlayerUpdated] Vehicle speed couldn't be retrieved")
            return
        end

        -- If the vehicle speed gets too low we shut-down the vehicle to save petrol 
        if speed <= 1 and data.vehicle:isEngineRunning() and not data.stopStart then
            print("[onPlayerUpdated] Stop/Start activated")
            data.vehicle:engineDoShuttingDown()
            data.stopStart = true
        elseif speed > 1 and data.stopStart then
            print("[onPlayerUpdated] Stop/Start de-activated")
            data.stopStart = false
        -- If the vehicle speed gets above 25km/h we are going to automatically lock all doors 
        elseif speed > 25 then
            print("[onPlayerUpdated] Vehicle Speed > 25km/h")
            autoLockDoors()
        end
    end
end

-- On entering vehicle we are going to save it on shared data structure
-- and register the OnPlayerUpdate event with our custom method
local function onEnterVehicle(player)
    if player == nil then
        print("[onEnterVehicle] Error: player is nil")
        return
    end

    print("[onEnterVehicle] Player " .. player:getDisplayName() .. " has entered a vehicle")

    local vehicle = player:getVehicle()
    if vehicle == nil then
        print("[onEnterVehicle] Error: vehicle is nil")
        return
    end

    print("[onEnterVehicle] Player " .. player:getDisplayName() .. " has entered " .. vehicle:getId())

    data.vehicle = vehicle
    Events.OnPlayerUpdate.Add(onPlayerUpdate)
end

-- On leaving vehicle we are going to clear the vehicle form our shared data structure
-- and de-register the OnPlayerUpdate event with our custom method
local function onExitVehicle(player)
    if player == nil then
        print("[onExitVehicle] Error: player is nil")
        return
    end

    print("[onEnterVehicle] Player " .. player:getDisplayName() .. " has left a vehicle")

    Events.OnPlayerUpdate.Remove(onPlayerUpdate)
    data.vehicle = nil
    data.stopStart = false
end

Events.OnEnterVehicle.Add(onEnterVehicle)
Events.OnExitVehicle.Add(onExitVehicle)

local function onKeyStartPressed(key)
    if key == Keyboard.KEY_W or key == Keyboard.KEY_S then
        if data.vehicle ~= nil then
            print("[onKeyStartPressed] Player is within a vehicle")
            if data.stopStart then
                print("[onKeyStartPressed] Player started driving the vehicle")
                data.vehicle:engineDoRunning()
            end
        end
    end
end

Events.OnKeyStartPressed.Add(onKeyStartPressed)