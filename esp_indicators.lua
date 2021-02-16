local width, height = render.get_screen()
ui.add_label("[ESP] Indicators")
local active = ui.add_checkbox("Indicators")
local short = ui.add_checkbox("Short indicators")
local items = ui.add_multi_dropdown("Active items", {"Double tap", "Hide shots", "Safe points", "Body aim", "Inverter", "Freestanding", "Fake duck", "Slow motion", "Auto peek", "Edge jump", "Damage override"})
local font_type = ui.add_dropdown("Font family", {"Small", "Normal", "Bold"})

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

local sfont = render.create_font("Small Fonts", 9, 400, font_flags.outline)
local nfont = render.create_font("Verdana", 12, 400, font_flags.antialias | font_flags.dropshadow)
local bfont = render.create_font("Verdana", 12, 700, font_flags.antialias | font_flags.dropshadow)
local font = nfont
local offset = 1

local function draw_indicator(text, color)
	local y = 0
	if font_type:get() == 0 then
		y = 10
		font = sfont
	elseif font_type:get() == 1 then
		y = 13
		font = nfont
	elseif font_type:get() == 2 then
		y = 13
		font = bfont
	end

	local tw, th = font:get_size(text)
	local x = width / 2 - tw / 2
	font:text(x, height / 2 + offset * y + 5, color, text)
	offset = offset + 1
end

local function on_paint()
	offset = 1
	if not active:get() then
		return
	end

	if items:get("Double tap") and double_tap:get() then
		draw_indicator(short:get() and "DT" or "DOUBLE TAP", exploits.ready() and color.new(140, 200, 0, 220) or color.new(255, 60, 30, 220))
	end
	if items:get("Hide shots") and hide_shots:get() then
		draw_indicator(short:get() and "HS" or "HIDE SHOTS", color.new(80, 130, 230, 220))
	end
	if items:get("Safe points") and safe_points:get() then
		draw_indicator(short:get() and "SP" or "SAFE POINTS", color.new(80, 230, 180, 220))
	end
	if items:get("Body aim") and body_aim:get() then
		draw_indicator(short:get() and "BAIM" or "BODY AIM", color.new(230, 80, 60, 220))
	end
	if items:get("Damage override") and damage_override:get() then
		draw_indicator(short:get() and "DMG" or "DAMAGE OVERRIDE", color.new(80, 80, 230, 220))
	end
	if items:get("Inverter") and inverter:get() then
		draw_indicator(short:get() and "INV" or "INVERTER", color.new(230, 230, 230, 220))
	end
	if items:get("Freestanding") and freestand:get() then
		draw_indicator(short:get() and "FS" or "FREESTANDING", color.new(0, 230, 230, 220))
	end
	if items:get("Fake duck") and fake_duck:get() then
		draw_indicator(short:get() and "FD" or "FAKE DUCK", color.new(130, 80, 230, 220))
	end
	if items:get("Slow motion") and slow_motion:get() then
		draw_indicator(short:get() and "SM" or "SLOW MOTION", color.new(230, 100, 180, 220))
	end
	if items:get("Auto peek") and auto_peek:get() then
		draw_indicator(short:get() and "AP" or "AUTOPEEK", color.new(230, 180, 130, 220))
	end
	if items:get("Edge jump") and edge_jump:get() then
		draw_indicator(short:get() and "EJ" or "EDGE JUMP", color.new(230, 180, 60, 220))
	end
end

callbacks.register("paint", on_paint)
