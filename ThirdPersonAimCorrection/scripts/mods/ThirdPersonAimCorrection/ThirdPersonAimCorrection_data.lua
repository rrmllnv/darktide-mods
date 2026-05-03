local mod = get_mod("ThirdPersonAimCorrection")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "general_group",
				type = "group",
				sub_widgets = {
					{
						setting_id = "enable_mod",
						type = "checkbox",
						default_value = true,
					},
					{
						setting_id = "only_third_person",
						type = "checkbox",
						default_value = true,
					},
					{
						setting_id = "debug_enabled",
						type = "checkbox",
						default_value = false,
					},
				},
			},
			{
				setting_id = "correction_group",
				type = "group",
				sub_widgets = {
					{
						setting_id = "max_distance",
						type = "numeric",
						default_value = 100,
						range = { 10, 150 },
						decimals_number = 0,
						unit = "m",
					},
					{
						setting_id = "correction_method",
						type = "dropdown",
						default_value = "method_4_enemy_aim_target_node",
						options = {
							{ text = "correction_method_1_camera_hit_position", value = "method_1_camera_hit_position" },
							{ text = "correction_method_2_validated_shooting_ray", value = "method_2_validated_shooting_ray" },
							{ text = "correction_method_3_hit_zone_center", value = "method_3_hit_zone_center" },
							{ text = "correction_method_4_enemy_aim_target_node", value = "method_4_enemy_aim_target_node" },
							{ text = "correction_method_5_prepare_shooting", value = "method_5_prepare_shooting" },
							{ text = "correction_method_6_shoot_hook", value = "method_6_shoot_hook" },
						{ text = "correction_method_7_hits_injection", value = "method_7_hits_injection" },
						},
					},
				},
			},
		},
	},
}
