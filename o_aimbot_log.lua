ui.add_label("[O] Aimbot logs")
local active = ui.add_checkbox("Screen logs")

local font = render.create_font("Lucida Console", 10, 400, font_flags.dropshadow)

local hitbox = { 'generic', 'head', 'chest', 'stomach', 'left arm', 'right arm', 'left leg', 'right leg', 'neck', '?', 'gear' }
local weapon_to_verb = { knife = 'Knifed', hegrenade = 'Naded', inferno = 'Burned' }

local shots = { }

local shot = 0

function length(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

local function shots_handler()
	local t = global_vars.frametime * 4 * 255
	if length(shots) > 6 then
		table.remove(shots, 1)
	end
	for k,v in pairs(shots) do
		if v.time + 6 < global_vars.curtime then
			v.alpha = math.max(0, v.alpha - t)
			if v.alpha == 0 then
				table.remove(shots, k)
			end
		end
	end
end

local function on_paint()
	if not active then
		return
	end

	shots_handler()
	for k,v in pairs(shots) do
		font:text(3, 4 + 13 * (k-1), color.new(255, 255, 255, v.alpha), v.text)
	end
end

callbacks.register("paint", on_paint)

callbacks.register("shot_miss", function(e)
local pinfo = engine.get_player_info(e.target_index)
local reason = e.reason
if reason == "occlusion" then
	reason = "prediction error"
elseif reason == "desync" then
	reason = "correction"
end
local log = string.format("[%d] Missed at %s's %s (%d%%;%d) due to %s", shot, string.lower(pinfo.name), hitbox[e.hitgroup+1], e.hitchance, e.damage, reason)
table.insert(shots, { text = log, time = global_vars.curtime, alpha = 255 })
client.log(log, color.new(220, 220, 220), "", false)
shot = shot + 1
end)

callbacks.register("shot_hit", function(e)
local pinfo = engine.get_player_info(e.target_index)
local ent = entity_list.get_client_entity(e.target_index)
local health = ent:get_prop("DT_BasePlayer", "m_iHealth"):get_int()
local log = string.format("[%d] Hit %s's %s for %d | hc=%d%% (%d remaining)", shot, string.lower(pinfo.name), hitbox[e.hitgroup+1], e.damage, e.hitchance, health)
table.insert(shots, { text = log, time = global_vars.curtime, alpha = 255 })
client.log(log, color.new(220, 220, 220), "", false)
shot = shot + 1
end)
