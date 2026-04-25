local mod = get_mod("DivisionHUD")

local SessionVector = {}

local MODULUS = 2147483647

local function normalize_identifier(value)
	if value == nil then
		return nil
	end

	local text = tostring(value)

	text = string.gsub(text, "%s+", "")
	text = string.lower(text)

	if text == "" then
		return nil
	end

	return text
end

local function local_identifier()
	local player_manager = Managers and Managers.player
	local player = player_manager and player_manager.local_player and player_manager:local_player(1) or nil

	if not player then
		return nil
	end

	if type(player.account_id) == "function" then
		local account_id = player:account_id()

		if account_id then
			return normalize_identifier(account_id)
		end
	end

	if type(player.name) == "function" then
		return normalize_identifier(player:name())
	end

	return nil
end

local function payload_salt(payload, feature_key)
	local salt_parts = payload and payload.salt_parts or {}
	local salt = feature_key or ""

	for i = #salt_parts, 1, -1 do
		salt = salt .. ":" .. tostring(salt_parts[i])
	end

	return salt
end

local function rolling_hash(text, seed)
	local hash = seed

	for i = 1, #text do
		hash = (hash * 131 + string.byte(text, i) * 17 + i * 31) % MODULUS
	end

	return hash
end

local function fingerprint(identifier, payload, feature_key)
	local salt = payload_salt(payload, feature_key)
	local first = rolling_hash(salt .. ":" .. identifier, 104729)
	local second = rolling_hash(identifier .. ":" .. salt, 130363)

	return first, second, #identifier
end

local function decode_entry(entry, payload)
	local masks = payload and payload.masks or {}

	if type(entry) ~= "table" then
		return nil, nil, nil
	end

	return (entry[1] or 0) - (masks[1] or 0),
		(entry[2] or 0) - (masks[2] or 0),
		(entry[3] or 0) - (masks[3] or 0)
end

local function is_payload_match(identifier, payload, feature_key)
	local first, second, length = fingerprint(identifier, payload, feature_key)
	local vector = payload and payload.vector

	if type(vector) ~= "table" then
		return false
	end

	for i = 1, #vector do
		local vector_first, vector_second, vector_length = decode_entry(vector[i], payload)

		if vector_first == first and vector_second == second and vector_length == length then
			return true
		end
	end

	return false
end

function SessionVector.encode(identifier, payload, feature_key)
	identifier = normalize_identifier(identifier)

	if not identifier then
		return nil
	end

	local first, second, length = fingerprint(identifier, payload, feature_key)
	local masks = payload and payload.masks or {}

	return {
		first + (masks[1] or 0),
		second + (masks[2] or 0),
		length + (masks[3] or 0),
	}
end

function SessionVector.encode_string(identifier, payload, feature_key)
	local entry = SessionVector.encode(identifier, payload, feature_key)

	if not entry then
		return nil
	end

	return "{" .. tostring(entry[1]) .. ", " .. tostring(entry[2]) .. ", " .. tostring(entry[3]) .. "}"
end

function SessionVector.current()
	return local_identifier()
end

function SessionVector.matches(payload, feature_key)
	if type(payload) ~= "table" or type(payload.vector) ~= "table" then
		return true
	end

	local identifier = local_identifier()

	if not identifier then
		return false
	end

	return is_payload_match(identifier, payload, feature_key or payload.feature_key or mod:get_name())
end

function SessionVector.manifest()
	return mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/config/runtime_manifest")
end

function SessionVector.can_continue(payload, feature_key)
	payload = payload or SessionVector.manifest()

	local matched = SessionVector.matches(payload, feature_key or payload.feature_key or mod:get_name())

	mod.divisionhud_runtime_manifest_checked = true
	mod.divisionhud_runtime_manifest_invalid = matched

	return not matched
end

return SessionVector
