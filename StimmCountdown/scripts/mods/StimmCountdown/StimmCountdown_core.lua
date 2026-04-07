local StimmCountdownCore = {}

StimmCountdownCore.STIMM_BUFF_NAME = "syringe_broker_buff"
StimmCountdownCore.STIMM_ABILITY_TYPE = "pocketable_ability"

function StimmCountdownCore.is_broker_class(player)
	if not player then
		return false
	end

	local archetype_name = player:archetype_name()

	return archetype_name == "broker"
end

function StimmCountdownCore.get_buff_remaining_time(buff_extension, buff_template_name)
	if not buff_extension then
		return 0
	end

	local buffs_by_index = buff_extension._buffs_by_index

	if not buffs_by_index then
		return 0
	end

	local timer = 0

	for _, buff in pairs(buffs_by_index) do
		if buff then
			local template = buff:template()

			if template and template.name == buff_template_name then
				local remaining = buff:duration_progress() or 1
				local duration = buff:duration() or 15

				timer = math.max(timer, duration * remaining)
			end
		end
	end

	return timer
end

function StimmCountdownCore.compute_broker_syringe_timer_state(player_unit, settings)
	local result = {
		visible = false,
		text = "",
		phase = "none",
		has_broker_syringe = false,
		has_active_buff = false,
		has_cooldown = false,
		is_ready = false,
	}

	if not player_unit then
		return result
	end

	local player = Managers.player and Managers.player:local_player(1)

	if not player or not player:unit_is_alive() then
		return result
	end

	if player.player_unit ~= player_unit then
		return result
	end

	if not StimmCountdownCore.is_broker_class(player) then
		return result
	end

	local buff_extension = ScriptUnit.has_extension(player_unit, "buff_system")

	if not buff_extension then
		return result
	end

	local ability_extension = ScriptUnit.has_extension(player_unit, "ability_system")
	local equipped_abilities = ability_extension and ability_extension:equipped_abilities()
	local pocketable_ability = equipped_abilities and equipped_abilities[StimmCountdownCore.STIMM_ABILITY_TYPE]
	local has_broker_syringe = pocketable_ability and pocketable_ability.ability_group == "broker_syringe"

	result.has_broker_syringe = not not has_broker_syringe

	if not has_broker_syringe then
		return result
	end

	local remaining_cooldown = ability_extension and ability_extension:remaining_ability_cooldown(StimmCountdownCore.STIMM_ABILITY_TYPE)
	local has_cooldown = remaining_cooldown and remaining_cooldown >= 0.05

	result.has_cooldown = not not has_cooldown

	local remaining_buff_time = StimmCountdownCore.get_buff_remaining_time(buff_extension, StimmCountdownCore.STIMM_BUFF_NAME)
	local has_active_buff = remaining_buff_time and remaining_buff_time >= 0.05

	result.has_active_buff = not not has_active_buff

	local is_ready = has_broker_syringe and not has_active_buff and not has_cooldown

	result.is_ready = not not is_ready

	local show_decimals = not settings or settings.show_decimals ~= false
	local show_active = not settings or settings.show_active ~= false
	local show_cooldown = not settings or settings.show_cooldown ~= false

	if show_active and has_active_buff then
		if show_decimals then
			result.text = string.format("%.1f", remaining_buff_time)
		else
			result.text = string.format("%.0f", math.ceil(remaining_buff_time))
		end

		result.visible = true
		result.phase = "active"
	elseif is_ready then
		result.visible = false
		result.phase = "none"
	elseif show_cooldown and has_cooldown then
		if show_decimals then
			result.text = string.format("%.1f", remaining_cooldown)
		else
			result.text = string.format("%.0f", math.ceil(remaining_cooldown))
		end

		result.visible = true
		result.phase = "cooldown"
	end

	return result
end

return StimmCountdownCore
