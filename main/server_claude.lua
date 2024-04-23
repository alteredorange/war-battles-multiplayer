--#IF HEADLESS
local can_run = true
--#ELSE
local can_run = false
--#ENDIF

local mp = require("utils.MessagePack")
require("utils.message_splitter")

local players = {}

function init(self)

	if not can_run then
		go.delete()
	end 

	udp_port = 5555
	udp = socket.udp()
	udp:setsockname("*", udp_port)
	udp:settimeout(0)
	print("Server started on port " .. udp_port)

end

function final(self)

end

function update(self, dt)
	-- print(dt)

end

function fixed_update(self, dt)
	while true do
		local data, ip, port = udp:receivefrom()
		if data then
			local client_steps = mp.unpack(data)
	
	end
end
end 

function on_message(self, message_id, message, sender)
	-- Add message-handling code here
	-- Learn more: https://defold.com/manuals/message-passing/
	-- Remove this function if not needed
end

function on_input(self, action_id, action)
	-- Add input-handling code here. The game object this script is attached to
	-- must have acquired input focus:
	--
	--    msg.post(".", "acquire_input_focus")
	--
	-- All mapped input bindings will be received. Mouse and touch input will
	-- be received regardless of where on the screen it happened.
	-- Learn more: https://defold.com/manuals/input/
	-- Remove this function if not needed
end

function on_reload(self)
	-- Add reload-handling code here
	-- Learn more: https://defold.com/manuals/hot-reload/
	-- Remove this function if not needed
end
