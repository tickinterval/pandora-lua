local width, height = render.get_screen()
ui.add_label("[O] Fake lag controller")
local active = ui.add_checkbox("Enable")
local color_picker = ui.add_colorpicker("LC color")
local gradient = ui.add_checkbox("Gradient bar")
local xs = ui.add_slider("X offset", 0, width)
local ys = ui.add_slider("Y offset", 0, height)
local conditions = ui.add_multi_dropdown("Fake lag triggers", { "On accelerate", "On threat", "On fire", "On unduck", "On weapon activity", "While jumping", "While ducking", "While walking", "While standing" })
local send_limit = ui.add_slider("Send limit", 0, 15)
local trigger_limit = ui.add_slider("Trigger send limit", 0, 15)
local variance = ui.add_slider("Variance", 0, 100)

local ref_fl_active = ui.get("Rage", "Anti-aim", "Fake-lag", "Enabled")
local ref_fl_conditions = ui.get("Rage", "Anti-aim", "Fake-lag", "Conditions")
local ref_fl_triggers = ui.get("Rage", "Anti-aim", "Fake-lag", "Trigger conditions")
local ref_fl_limit = ui.get("Rage", "Anti-aim", "Fake-lag", "Limit")
local ref_fl_triggers_limit = ui.get("Rage", "Anti-aim", "Fake-lag", "Trigger limit")
local ref_fl_variance = ui.get("Rage", "Anti-aim", "Fake-lag", "Variance")
local ref_slowmotion = ui.get("Rage", "Anti-aim", "Fake anti-aim", "Slow motion key")

local function default_values()
	ref_fl_active:set(true)
	ref_fl_conditions:set("Standing", true)
	ref_fl_conditions:set("Moving", true)
	ref_fl_conditions:set("In air", true)
	ref_fl_triggers:set("On unduck", false)
	ref_fl_triggers:set("On land", false)
	ref_fl_triggers:set("On weapon activity", false)
	ref_fl_triggers:set("On shot", false)
	ref_fl_limit:set(0)
	ref_fl_triggers_limit:set(0)
	ref_fl_variance:set(variance:get())
end

local player = {
	weapon_fired = false,
	last_weapon_fire = global_vars.tickcount,
	velocity = 0,
	old_velocity = 0,
	trigger_active = false,
	chokedcommands = 0,
	chokedcommands_prev = 0,
	chokedcommands_prev_cmd = 0,
	chokedcommands_max = 0,
	tickcount = 0,
	tickcount_prev = 0,
	last_origin = vector.new(0, 0, 0),
	last_origin_sqr = 0,
	breaking_lc = false,
	lc_delta = 0,
}

local function get_speed(lp)
	local vel_nv = lp:get_prop("DT_BasePlayer", "m_vecVelocity[0]")
	local vel = vel_nv:get_vector()
	if vel.x ~= nil then
		return math.sqrt(vel.x*vel.x + vel.y*vel.y)
	end
end

local function g_move_handler(cmd)
	if not active:get() then
		return
	end

	default_values()
	local lp = entity_list.get_client_entity(engine.get_local_player())
	local velocity = get_speed(lp)
	if velocity ~= nil then
		player.old_velocity = player.velocity
		player.velocity = velocity
	end

	player.chokedcommands_prev = player.chokedcommands
	player.chokedcommands = client.choked_commands()
	if player.chokedcommands_max == nil or player.chokedcommands > player.chokedcommands_max then
		player.chokedcommands_max = player.chokedcommands
	elseif player.chokedcommands == 0 and player.chokedcommands_prev ~= 0 then
		player.chokedcommands_max = player.chokedcommands_prev
	elseif player.chokedcommands == 0 and player.chokedcommands_prev_cmd == 0 then
		player.chokedcommands_max = 0
	end

	player.tickcount = global_vars.tickcount
	if player.tickcount ~= player.tickcount_prev then
		player.chokedcommands_prev_cmd = player.chokedcommands_prev
		player.tickcount_prev = player.tickcount
	end
	if client.choked_commands() == 0 then
		local origin = lp:get_prop("DT_BasePlayer", "m_vecOrigin"):get_vector()
		if player.last_origin ~= origin then
			player.last_origin_sqr = player.last_origin.x * player.last_origin.x + player.last_origin.y * player.last_origin.y
			local origin_sqr = origin.x * origin.x + origin.y * origin.y
			player.breaking_lc = false
			if math.abs(player.last_origin_sqr - origin_sqr) > 4096 then
				player.breaking_lc = true
				player.lc_delta = math.abs(player.last_origin_sqr - origin_sqr)
			end
			player.last_origin = origin
		end
	end

	local limit = send_limit:get()

	local flags = lp:get_prop("DT_BasePlayer", "m_fFlags"):get_int()

	player.trigger_active = false

	if conditions:get("On accelerate") and player.old_velocity < player.velocity and player.velocity < 200 and player.velocity > 4 then
		player.trigger_active = true
	elseif conditions:get("On threat") and penetration.damage() > 10 and player.velocity > 4 then
		player.trigger_active = true
	elseif conditions:get("On fire") and player.last_weapon_fire + trigger_limit:get() > global_vars.tickcount then
		player.weapon_fired = false
		player.trigger_active = true
	elseif conditions:get("On unduck") then
		ref_fl_triggers:set("On unduck", true)
		ref_fl_triggers_limit:set(trigger_limit:get())
		player.trigger_active = true
	elseif conditions:get("On weapon activity") then
		ref_fl_triggers:set("On weapon activity", true)
		ref_fl_triggers_limit:set(trigger_limit:get())
		player.trigger_active = true
	elseif conditions:get("While jumping") and flags == 256 then
		player.trigger_active = true
	elseif conditions:get("While ducking") and cmd:has_flag(command.in_duck) then
		player.trigger_active = true
	elseif conditions:get("While walking") and ref_slowmotion:get() then
		player.trigger_active = true
	elseif conditions:get("While standing") and player.velocity < 2 then
		player.trigger_active = true
	end

	if player.trigger_active then
		ref_fl_limit:set(trigger_limit:get())
	else
		ref_fl_limit:set(send_limit:get())
	end
end

local font = render.create_font("Verdana", 12, 400, font_flags.antialias | font_flags.dropshadow)

local interp_delta = 0
local interp_width = 0

local function g_paint_handler()
	local text = string.format("LC | choked: %d | adaptive: %s", player.chokedcommands_max, player.trigger_active and "true " or "false", tostring(player.breaking_lc))
	if player.breaking_lc and player.chokedcommands_max > 4 then
		text = string.format("%s | dst:          ", text)
	end
	local tw, th = font:get_size(text)
	local color = color_picker:get()
	local x, y = xs:get(), ys:get()

	if interp_width < tw then
		interp_width = interp_width + global_vars.frametime * 255
	elseif interp_width > tw then
		if interp_width - global_vars.frametime * 255 < tw then
			interp_width = tw
		else
			interp_width = interp_width - global_vars.frametime * 255
		end
	end

	render.rectangle_filled(x-3, y - 3, interp_width+6, 17, color.new(20, 20, 20, color:a()))
	if gradient:get() then
		render.gradient(x-3, y - 3, math.floor(interp_width/2)+4, 1, color.new(0, 200, 255, 255), color.new(220, 60, 220, 255), true)
		render.gradient(x+interp_width/2, y - 3, math.floor(interp_width/2)+3, 1, color.new(220, 60, 220, 255), color.new(180, 255, 0, 255), true)

		render.gradient(x-3, y - 2, math.floor(interp_width/2)+4, 1, color.new(0, 150, 200, 255), color.new(180, 50, 180, 255), true)
		render.gradient(x+interp_width/2, y - 2, math.floor(interp_width/2)+3, 1, color.new(180, 50, 180, 255), color.new(150, 200, 0, 255), true)
	else
		render.rectangle_filled(x, y - 3, interp_width, 2, color.new(color:r(), color:g(), color:b(), 255))
		render.rectangle_filled(x, y - 2, interp_width, 1, color.new(0, 0, 0, 100))
	end
	font:text(x, y, color.new(255, 255, 255, 255), text)

	if interp_delta < math.min(20, player.lc_delta / 4096) then
		interp_delta = interp_delta + global_vars.frametime * 80
	elseif interp_delta > math.min(20, player.lc_delta / 4096) then
		interp_delta = interp_delta - global_vars.frametime * 80
	end

	if player.breaking_lc and player.chokedcommands_max > 4 then
		render.rectangle_filled(x + font:get_size(string.format("LC | choked: %d | adaptive: %s | dst: ", player.chokedcommands_max, player.trigger_active and "true " or "false", tostring(player.breaking_lc))), y + 4, interp_delta, 6, color.new(color:r(), color:g(), color:b(), 255))
	end
end

callbacks.register("post_move", g_move_handler)
callbacks.register("weapon_fire", function(e)
if engine.get_player_for_user_id(e:get_int("userid")) == engine.get_local_player() then
	player.weapon_fired = true
	player.last_weapon_fire = global_vars.tickcount
end
end)

callbacks.register("paint", g_paint_handler)
