--#IF HEADLESS
local should_send = false
--#ELSE
local should_send = true
--#ENDIF


function dump(o)
	if type(o) == 'table' then
		local s = '{ '
		for k,v in pairs(o) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			s = s .. '['..k..'] = ' .. dump(v) .. ','
		end
		return s .. '} '
	else
		return tostring(o)
	end
end



local mp = require("utils.MessagePack")

-- local thingy = "Hello"
-- local data = {health = 100, 50, 0}
-- mpac = mp.pack(thingy)
-- print(mpac)
-- unpacked = mp.unpack(mpac)
-- print(unpacked)

-- local buffer = require("string.buffer")
local tcp_client = require "defnet.tcp_client"
local IP = "127.0.0.1" 
local PORT = 7777
local id = rnd.range(1000, 9999)
local players = {}

-- Server address and port
local server_address = "127.0.0.1"
local server_port = 5555

udp = socket.udp()
udp:settimeout(0)

-- Buffer to store inputs
local input_buffer = {}

function init(self)

	camera.acquire_focus("camera#camera")
	msg.post(".", "acquire_input_focus")            -- [2]

	self.moving = false          
	self.firing = false    		                   -- [3]
	self.input = vmath.vector3()                    -- [4]
	self.dir = vmath.vector3(0, 1, 0)               -- [5]
	self.speed = 400             

	-- correction vector
	self.correction = vmath.vector3()         

	-- create a new player instance
	local player_instance = {
		moving = self.moving,
		firing = self.firing,
		input = self.input,
		dir = self.dir,
		speed = self.speed,
		correction = self.correction
	}

	-- store the player instance with the unique id
	players[id] = player_instance


end

function final(self)                                -- [7]
	msg.post(".", "release_input_focus")   
	if self.client then
		self.client.destroy()
	end
	udp:close()
end

function update(self, dt)    
	local player = players[id]
	if player then

		-- reset correction
		player.correction = vmath.vector3()


		update_animation(self, player)                 
		if player.moving then
			local pos = go.get_position()
			pos = pos + player.dir * player.speed * dt
			go.set_position(pos)
		end

		if player.firing then
			local angle = math.atan2(player.dir.y, player.dir.x)
			local rot = vmath.quat_rotation_z(angle)
			local props = { dir = player.dir }
			factory.create("#rocketfactory", nil, rot, props)
		end

		player.input.x = 0
		player.input.y = 0

		player.moving = false
		player.firing = false

		
	end
end

function update_animation(self, player)
	local anim_dir = vmath.vector3(player.input.x, player.input.y, 0)

	if anim_dir ~= self.anim_dir then
		if self.anim_id ~= nil then
			sprite.stop_animation(self.anim_id)
			self.anim_id = nil
		end

		if vmath.length(anim_dir) > 0 then
			local anim_name
			if anim_dir.x > 0 then
				anim_name = "player-right"
			elseif anim_dir.x < 0 then
				anim_name = "player-left"
			elseif anim_dir.y > 0 then
				anim_name = "player-up"
			elseif anim_dir.y < 0 then
				anim_name = "player-down"
			else
				anim_name = "player-idle"
			end
			sprite.play_flipbook("#sprite", anim_name)
		end

		self.anim_dir = anim_dir
	end
end

function on_input(self, action_id, action) 


	local player = players[id]
	if player then

		if action_id == hash("up") then
			player.input.y = 1
		elseif action_id == hash("down") then
			player.input.y = -1
		elseif action_id == hash("left") then
			player.input.x = -1
		elseif action_id == hash("right") then
			player.input.x = 1
		elseif action_id == hash("fire") and action.pressed then
			player.firing = true
		end

		if vmath.length(player.input) > 0 then

			local x,y,z = go.get_position().x, go.get_position().y, go.get_position().z

			-- Store input in the buffer
			table.insert(input_buffer, {id, player.input.x, player.input.y, x,y,z})
			print("buffer:", dump(input_buffer))
			-- Send the movement data to the server
			-- if should_send then
			-- 	local pos = go.get_position()
			-- 	local message = id .. "*" .. player.input.x .. "*" .. player.input.y .. "*" .. pos
			-- 	udp:sendto(message, server_address, server_port)
			-- end

		
			player.moving = true                          -- [16]
			player.dir = vmath.normalize(player.input)      -- [17]
			
		end
	end
end

function fixed_update(self, dt)
	-- Send the buffered inputs to the server
	if should_send and #input_buffer > 0 then

		local input_pack = mp.pack(input_buffer)
		-- local message_bytes = {}
		-- for _, input in ipairs(input_buffer) do
		-- 	local id, x, y, pos = unpack(input)
		-- 	
		-- 	table.insert(message_bytes, buffer.encode("i4i4i4i4i4i4", id, x, y, pos.x, pos.y, pos.z))
		-- end
		udp:sendto(input_pack, server_address, server_port)
		input_buffer = {}
	end
end

function on_message(self, message_id, message, sender)
	local player = players[id]
	if player then
		-- Handle collision
		-- https://defold.com/manuals/physics-resolving-collisions/
		if message_id == hash("contact_point_response") then
			-- Get the info needed to move out of collision. We might
			-- get several contact points back and have to calculate
			-- how to move out of all of them by accumulating a
			-- correction vector for this frame:
			if message.distance > 0 then
				-- First, project the accumulated correction onto
				-- the penetration vector
				local proj = vmath.project(player.correction, message.normal * message.distance)
				if proj < 1 then
					-- Only care for projections that does not overshoot.
					local comp = (message.distance - message.distance * proj) * message.normal
					-- Apply compensation
					go.set_position(go.get_position() + comp)
					-- Accumulate correction done
					player.correction = player.correction + comp
				end
			end
		end

	end


end