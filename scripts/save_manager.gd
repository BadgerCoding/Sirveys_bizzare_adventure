extends Node
# Local, offline-first storage under user:// plus the pending-sync queue.

const DOC_DIR := "user://documents"
const SYNC_FILE := "user://sync_queue.json"

func _ready() -> void:
    DirAccess.make_dir_recursive_absolute(DOC_DIR)

func save_json(path: String, data) -> void:
    var f := FileAccess.open(path, FileAccess.WRITE)
    if f == null:
        push_error("Cannot write %s (error %d)" % [path, FileAccess.get_open_error()])
        return
    f.store_string(JSON.stringify(data, "  "))

func load_json(path: String, fallback = {}):
    if not FileAccess.file_exists(path):
        return fallback
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
    return parsed if parsed != null else fallback

func delete_file(path: String) -> void:
    if FileAccess.file_exists(path):
        DirAccess.remove_absolute(path)

func list_documents() -> Array:
    var out: Array = []
    var dir := DirAccess.open(DOC_DIR)
    if dir == null:
        return out
    for file_name in dir.get_files():
        if file_name.ends_with(".json"):
            var doc = load_json("%s/%s" % [DOC_DIR, file_name], null)
            if doc is Dictionary and doc.has("id") and doc.has("questions"):
                out.append(doc)
    out.sort_custom(func(a, b): return int(a.get("created", 0)) > int(b.get("created", 0)))
    return out

func save_document(doc: Dictionary) -> void:
    save_json("%s/%s.json" % [DOC_DIR, doc["id"]], doc)

func delete_document(id: String) -> void:
    delete_file("%s/%s.json" % [DOC_DIR, id])

# Offline-first: every change worth syncing is queued here. SyncService (not built yet)
# will push this queue to the online database when wifi is available, then clear it.
func queue_sync(kind: String, payload: Dictionary) -> void:
    var q = load_json(SYNC_FILE, [])
    if not (q is Array):
        q = []
    q.append({"kind": kind, "payload": payload, "time": int(Time.get_unix_time_from_system())})
    save_json(SYNC_FILE, q)
