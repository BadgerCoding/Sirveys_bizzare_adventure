extends Node
# Local profile, settings and balance tables. All numbers here are placeholders: tune freely.

const PROFILE_FILE := "user://profile.json"
const SETTINGS_FILE := "user://settings.json"
const CYO_SAVE_FILE := "user://cyo_save.json"
const STORY_SAVE_FILE := "user://story_save.json"
const MAX_LEVEL := 100

# Only Shop = level 10 was specified. The others are placeholders set to 1.
const UNLOCK_LEVELS := {"quest": 1, "achievement": 1, "ranking": 1, "shop": 10}

# win_ratio: fraction of the questions you must answer correctly to defeat the wizard.
const DIFFICULTIES := {
    "easy": {"label": "Easy", "player_hp": 100, "player_dmg": 5, "enemy_dmg": 5, "win_ratio": 0.6, "timer": 15, "xp_per_correct": 8},
    "normal": {"label": "Normal", "player_hp": 100, "player_dmg": 5, "enemy_dmg": 10, "win_ratio": 0.75, "timer": 10, "xp_per_correct": 10},
    "hard": {"label": "Hard", "player_hp": 100, "player_dmg": 5, "enemy_dmg": 15, "win_ratio": 0.9, "timer": 8, "xp_per_correct": 14},
}

var profile: Dictionary = {}
var settings: Dictionary = {"animation": true, "sound": true, "api_key": "", "model": "gemini-2.5-flash-lite"}

func _ready() -> void:
    profile = SaveManager.load_json(PROFILE_FILE, {})
    for k in ["level", "xp", "avatar"]:
        if profile.has(k):
            profile[k] = int(profile[k])
    var s = SaveManager.load_json(SETTINGS_FILE, {})
    if s is Dictionary:
        settings.merge(s, true)

func has_profile() -> bool:
    return profile.has("username")

func create_profile(username: String, avatar: int) -> void:
    profile = {"username": username, "avatar": avatar, "level": 1, "xp": 0}
    save_profile()

func save_profile() -> void:
    SaveManager.save_json(PROFILE_FILE, profile)
    SaveManager.queue_sync("profile", profile)

func save_settings() -> void:
    SaveManager.save_json(SETTINGS_FILE, settings)

func level() -> int:
    return int(profile.get("level", 1))

func xp() -> int:
    return int(profile.get("xp", 0))

func xp_needed(lvl: int) -> int:
    return 50 + lvl * 25

# Returns true if the player levelled up.
func add_xp(amount: int) -> bool:
    var leveled := false
    profile["xp"] = xp() + amount
    while level() < MAX_LEVEL and xp() >= xp_needed(level()):
        profile["xp"] = xp() - xp_needed(level())
        profile["level"] = level() + 1
        leveled = true
    if level() >= MAX_LEVEL:
        profile["xp"] = 0
    save_profile()
    return leveled

func is_unlocked(feature: String) -> bool:
    return level() >= int(UNLOCK_LEVELS.get(feature, 1))

func logout() -> void:
    SaveManager.delete_file(PROFILE_FILE)
    SaveManager.delete_file(CYO_SAVE_FILE)
    SaveManager.delete_file(STORY_SAVE_FILE)
    profile = {}
