local width, height = render.get_screen()
ui.add_label("[ESP] Watermark")
local active = ui.add_checkbox("Watermark")
local color_picker = ui.add_colorpicker("Watermark color")
local gradient = ui.add_checkbox("Gradient bar")
local items = ui.add_multi_dropdown("Active items", {"Nickname", "FPS", "Ping", "Tickrate", "Speed"})

local nickname = "username"
local cheat = "pandora"

local font = render.create_font("Verdana", 12, 400, font_flags.antialias | font_flags.dropshadow)
local sfont = render.create_font("Small Fonts", 9, 400, font_flags.outline)

if color_picker:get():r() == 255 and color_picker:get():g() == 255 and color_picker:get():b() == 255 then
	color_picker:set(color.new(89, 119, 239, 165))
end

local ft_prev = 0
local function get_fps()
	ft_prev = ft_prev * 0.9 + global_vars.absoluteframetime * 0.1
	return math.ceil(1 / ft_prev)
end

local function on_paint()
	if not active:get() then
		return
	end
	local lp = entity_list.get_client_entity(engine.get_local_player())
	local text = string.format("%s    ", cheat)
	if (items:get("Nickname")) then
		text = string.format("%s | %s", text, nickname)
	end
	if (items:get("FPS")) then
		text = string.format("%s | %d fps", text, get_fps())
	end
	if (items:get("Ping")) then
		local ping_nv = lp:get_prop("DT_PlayerResource", "m_iPing")
		text = string.format("%s | delay: %dms", text, math.floor(ping_nv:get_float() + 1))
	end
	if (items:get("Tickrate")) then
		text = string.format("%s | %dtick", text, 1 / global_vars.interval_per_tick)
	end
	if (items:get("Speed")) then
		local vel_nv = lp:get_prop("DT_BasePlayer", "m_vecVelocity[0]")
		local vel = vel_nv:get_vector()
		if vel.x ~= nil then
			local speed = math.sqrt(vel.x*vel.x + vel.y*vel.y)
			text = string.format("%s | %du", text, math.ceil(speed))
		end
	end
	local tw, th = font:get_size(text)
	local x = width - tw - 10
	local y = 10
	local color = color_picker:get()
	render.rectangle_filled(x - 4, y - 4, tw + 8, th + 6, color.new(17, 17, 17, color:a()))
	if gradient:get() then
		render.gradient(x - 4, y - 4, tw / 2 + 4, 1, color.new(0, 200, 255, 255), color.new(220, 60, 220, 255), true)
		render.gradient(x + tw / 2, y - 4, tw / 2 + 3, 1, color.new(220, 60, 220, 255), color.new(180, 255, 0, 255), true)

		render.gradient(x - 4, y - 3, tw / 2 + 4, 1, color.new(0, 150, 200, 255), color.new(180, 50, 180, 255), true)
		render.gradient(x + tw / 2, y - 3, tw / 2 + 3, 1, color.new(180, 50, 180, 255), color.new(150, 200, 0, 255), true)
	else
		render.rectangle_filled(x - 4, y - 4, tw + 8, 2, color.new(color:r(), color:g(), color:b(), 255))
		render.rectangle_filled(x - 4, y - 3, tw + 8, 1, color.new(0, 0, 0, 100))
	end
	font:text(x, y, color.new(255, 255, 255, 220), text)
	sfont:text(x + 74, y + 3, color.new(255, 255, 255, 150), "[R]")
end

callbacks.register("paint", on_paint)
