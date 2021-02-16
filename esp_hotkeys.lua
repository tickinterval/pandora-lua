local width, height = render.get_screen()
ui.add_label("[ESP] Hotkeys")
local active = ui.add_checkbox("Hotkeys list")
local color_picker = ui.add_colorpicker("Hotkeys list color")
local gradient = ui.add_checkbox("Gradient bar")
local xs = ui.add_slider("X offset", 0, width)
local ys = ui.add_slider("Y offset", 0, height)

local font = render.create_font("Verdana", 12, 400, font_flags.antialias | font_flags.dropshadow)

if color_picker:get():r() == 255 and color_picker:get():g() == 255 and color_picker:get():b() == 255 then
	color_picker:set(color.new(89, 119, 239, 165))
end

local GLOBAL_ALPHA = 0
local MAX_WIDTH = 100
local CUR_WIDTH = 100

local menu_key = {
	get = function()
	return ui.is_open()
end
}

local double_tap = ui.get("Rage", "Aimbot", "Exploit settings", "Double tap key", "Pistols")
local hide_shots = ui.get("Rage", "Aimbot", "Exploit settings", "Hide shots key", "Pistols")
local safe_points = ui.get("Rage", "Aimbot", "General settings", "Force safe point key", "Pistols")
local damage_override = ui.get("Rage", "Aimbot", "General settings", "Minimum dmg override key", "Pistols")
local body_aim = ui.get("Rage", "Aimbot", "Accuracy settings", "Force bodyaim key", "Pistols")
local inverter = ui.get("Rage", "Anti-aim", "Fake anti-aim", "Invert key")
local freestand = ui.get("Rage", "Anti-aim", "Real anti-aim", "Freestanding key")
local fake_duck = ui.get("Rage", "Anti-aim", "Fake anti-aim", "Fake duck key")
local slow_motion = ui.get("Rage", "Anti-aim", "Fake anti-aim", "Slow motion key")
local auto_peek = ui.get("Rage", "Other", "Misc", "Auto peek key")
local edge_jump = ui.get("Misc", "General", "Movement", "Edge jump key")

local items_list = {
["Menu key"] = { active = false, alpha = 0, reference = menu_key, status = "[~]" },
["Double tap"] = { active = false, alpha = 0, reference = double_tap, status = "[toggled]" },
["On shot anti-aim"] = { active = false, alpha = 0, reference = hide_shots, status = "[toggled]" },
["Force safe points"] = { active = false, alpha = 0, reference = safe_points, status = "[holding]" },
["Damage override"] = { active = false, alpha = 0, reference = damage_override, status = "[holding]" },
["Force body aim"] = { active = false, alpha = 0, reference = body_aim, status = "[holding]" },
["Anti-aim inverter"] = { active = false, alpha = 0, reference = inverter, status = "[toggled]" },
["Freestanding"] = { active = false, alpha = 0, reference = freestand, status = "[toggled]" },
["Duck peek assist"] = { active = false, alpha = 0, reference = fake_duck, status = "[holding]" },
["Slow motion"] = { active = false, alpha = 0, reference = slow_motion, status = "[holding]" },
["Auto peek assist"] = { active = false, alpha = 0, reference = auto_peek, status = "[holding]" },
["Edge jump"] = { active = false, alpha = 0, reference = edge_jump, status = "[holding]" },
}

local active_list = { }

local function table_find(tab,elem)
for index, value in pairs(tab) do
	if value == elem then
		return index
	end
end
end

local function contains(tab, val)
for index, value in ipairs(tab) do
	if value == val then
		return true
	end
end

return false
end

local function handle_items()
if next(active_list) == nil then
	MAX_WIDTH = 100
end
local t = global_vars.frametime * 8 * 255
for k,v in pairs(items_list) do
	if v.reference:get() then
		v.active = true
		local textw, texth = font:get_size(k)
		if textw + 80 > MAX_WIDTH then
			MAX_WIDTH = textw + 80
		end
		if v.alpha < 255 then
			v.alpha = math.min(255, v.alpha + t)
		end
		if not contains(active_list, k) then
			table.insert(active_list, k)
		end
	else
		if v.alpha > 0 then
			v.alpha = math.max(0, v.alpha - t)
		else
			v.active = false
			local index = table_find(active_list, k)
			if index ~= nil then
				table.remove(active_list, index)
				if next(active_list) ~= nil then
					MAX_WIDTH = 100
				end
			end
		end
	end
end
end

local function hotkeys_handler()
handle_items()
local v = global_vars.frametime * 8 * 255
local bool = #active_list == 1 and not items_list[active_list[1]].reference:get()
if next(active_list) == nil or bool then
	if GLOBAL_ALPHA > 0 then
		GLOBAL_ALPHA = math.max(0, GLOBAL_ALPHA - v)
	end
else
	if GLOBAL_ALPHA < 255 then
		GLOBAL_ALPHA = math.min(255, GLOBAL_ALPHA + v)
	end
end

if CUR_WIDTH > MAX_WIDTH then
	CUR_WIDTH = math.max(CUR_WIDTH - v / 2, CUR_WIDTH - (CUR_WIDTH - MAX_WIDTH))
end
if CUR_WIDTH < MAX_WIDTH then
	CUR_WIDTH = math.min(CUR_WIDTH + v / 2, CUR_WIDTH + (MAX_WIDTH - CUR_WIDTH))
end
end

local function a(alpha)
return math.min(GLOBAL_ALPHA, alpha)
end

local function on_paint()
if not active:get() then
	return
end
local color = color_picker:get()
local x, y = xs:get(), ys:get()
local w = CUR_WIDTH
local offset = 1
hotkeys_handler()
render.rectangle_filled(x, y - 3, w, 17, color.new(20, 20, 20, a(math.max(color:a() + 50, 120))))
if gradient:get() then
	render.gradient(x, y - 3, math.floor(w/2)+1, 1, color.new(0, 200, 255,  a(255)), color.new(220, 60, 220, a(255)), true)
	render.gradient(x+w/2, y - 3, math.floor(w/2), 1, color.new(220, 60, 220,  a(255)), color.new(180, 255, 0, a(255)), true)

	render.gradient(x, y - 2, math.floor(w/2)+1, 1, color.new(0, 150, 200,  a(255)), color.new(180, 50, 180, a(255)), true)
	render.gradient(x+w/2, y - 2, math.floor(w/2), 1, color.new(180, 50, 180,  a(255)), color.new(150, 200, 0, a(255)), true)
else
	render.rectangle_filled(x, y - 3, w, 2, color.new(color:r(), color:g(), color:b(), a(255)))
	render.rectangle_filled(x, y - 2, w, 1, color.new(0, 0, 0, a(100)))
end
font:text(x + w / 2 - 27, y, color.new(255, 255, 255, a(220)), "hotkey list")
for k,f in pairs(active_list) do
	local v = items_list[f]
	if v.active then
		render.rectangle_filled(x, y - 3 + 17*offset, w, 17, color.new(20, 20, 20, a(math.min(v.alpha, color:a()))))
		font:text(x + 4, y - 2 + 17*offset, color.new(255, 255, 255, a(v.alpha)), f)
		local tw, th = font:get_size(v.status)
		font:text(x + w - tw - 4, y - 2 + 17*offset, color.new(255, 255, 255, a(v.alpha)), v.status)
		offset = offset + 1
	end
end
end

callbacks.register("paint", on_paint)
