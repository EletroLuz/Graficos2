-- Define patterns for interactive object names (adjust as needed)
local interactive_patterns = { "usz_reward", "usz_rewardGizmo_" }

-- Table to store detected objects' positions
local detected_objects = {}

-- Function to check if the object's name matches any interaction patterns
local function matchesAnyPattern(name)
    for _, pattern in ipairs(interactive_patterns) do
        if name:match(pattern) then
            return true
        end
    end
    return false
end

-- Function to draw circles around interactive objects
on_render(function()
    local local_player = get_local_player()
    if not local_player then
        return
    end

    -- Get the player's position
    local player_position = local_player:get_position()
    
    -- Define colors
    local color_blue = color.new(0, 0, 255)
    local color_green = color.new(0, 255, 0)
    
    -- Define the thickness of the line
    local thickness = 3.0
    
    -- Function to find the closest circle to the player
    local function find_closest_circle(player_pos, circles_list)
        local closest_circle = nil
        local closest_distance = math.huge
        for _, circle in ipairs(circles_list) do
            local dist = player_pos:squared_dist_to(circle.position)
            if dist < closest_distance then
                closest_distance = dist
                closest_circle = circle
            end
        end
        return closest_circle
    end

    -- Get all objects
    local objects = actors_manager.get_ally_actors()

    for _, obj in ipairs(objects) do
        if obj then
            local obj_name = obj:get_skin_name()
            if obj_name and matchesAnyPattern(obj_name) then
                local obj_position = obj:get_position()
                -- Store the detected object's position if not already stored
                local already_detected = false
                for _, detected in ipairs(detected_objects) do
                    if detected.position == obj_position then
                        already_detected = true
                        break
                    end
                end
                if not already_detected then
                    table.insert(detected_objects, {position = obj_position, radius = 500, color = color_blue})
                end
            end
        end
    end

    -- Find the closest circle to the player
    local closest_circle = find_closest_circle(player_position, detected_objects)

    -- Draw the circles and set pins
    for _, circle in ipairs(detected_objects) do
        if graphics.circle_2d then
            graphics.circle_2d(circle.position, circle.radius, circle.color)
        end
    end
    
    -- Draw the line from the player's position to each circle's position
    if graphics.line then
        for _, circle in ipairs(detected_objects) do
            graphics.line(player_position, circle.position, circle.color, thickness)
        end
    end

    -- Set a pin only on the closest circle
    if utility.set_map_pin and closest_circle then
        local success = utility.set_map_pin(closest_circle.position)
        if not success then
            -- Handle pin placement failure if needed
        end
    end

    -- Update the pin if the player reaches the closest circle
    if closest_circle and player_position:dist_to(closest_circle.position) < closest_circle.radius then
        -- Find the next closest circle
        local next_closest_circle = find_closest_circle(player_position, detected_objects)
        if next_closest_circle ~= closest_circle then
            -- Set a pin on the next closest circle
            if utility.set_map_pin and next_closest_circle then
                local success = utility.set_map_pin(next_closest_circle.position)
                if not success then
                    -- Handle pin placement failure if needed
                end
            end
        end
    end
end)

console.print(">> Open Helltide Chests Loaded <<")