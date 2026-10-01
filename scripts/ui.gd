class_name UI
extends RefCounted
# Small helpers so every screen can be built from code (no hand-written .tscn files).

const BG := Color(0.10, 0.09, 0.16)
const AVATAR_COLORS = [Color("e74c3c"), Color("e67e22"), Color("f1c40f"), Color("2ecc71"), Color("1abc9c"), Color("3498db"), Color("9b59b6"), Color("95a5a6")]

static func button(text: String, min_size := Vector2(0, 120), font_size := 40) -> Button:
    var b := Button.new()
    b.text = text
    b.custom_minimum_size = min_size
    b.add_theme_font_size_override("font_size", font_size)
    return b

static func label(text: String, font_size := 36, align := HORIZONTAL_ALIGNMENT_CENTER) -> Label:
    var l := Label.new()
    l.text = text
    l.horizontal_alignment = align
    l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    l.add_theme_font_size_override("font_size", font_size)
    return l

static func background(parent: Control, color := BG) -> void:
    var r := ColorRect.new()
    r.color = color
    r.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    parent.add_child(r)

static func margin(parent: Control, m := 40) -> VBoxContainer:
    var mc := MarginContainer.new()
    mc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    for side in ["left", "right", "top", "bottom"]:
        mc.add_theme_constant_override("margin_" + side, m)
    parent.add_child(mc)
    var v := VBoxContainer.new()
    v.add_theme_constant_override("separation", 24)
    mc.add_child(v)
    return v

static func bar(color: Color) -> ProgressBar:
    var p := ProgressBar.new()
    p.show_percentage = false
    p.custom_minimum_size = Vector2(0, 28)
    var fill := StyleBoxFlat.new()
    fill.bg_color = color
    p.add_theme_stylebox_override("fill", fill)
    return p

static func centered(text: String, font_size := 60) -> Control:
    var c := CenterContainer.new()
    c.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var l := label(text, font_size)
    l.custom_minimum_size = Vector2(900, 0)
    c.add_child(l)
    return c

# Uses res://assets/avatars/avatar_N.png if present, otherwise a coloured square.
static func avatar(index: int, size := 120) -> Control:
    var path := "res://assets/avatars/avatar_%d.png" % index
    if ResourceLoader.exists(path):
        var t := TextureRect.new()
        t.texture = load(path)
        t.custom_minimum_size = Vector2(size, size)
        t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        t.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        return t
    var r := ColorRect.new()
    r.color = AVATAR_COLORS[index % AVATAR_COLORS.size()]
    r.custom_minimum_size = Vector2(size, size)
    return r

# Sprite from a texture path if it exists, otherwise a labelled coloured box.
static func sprite(path: String, color: Color, caption: String) -> Control:
    if ResourceLoader.exists(path):
        var t := TextureRect.new()
        t.texture = load(path)
        t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        t.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        return t
    var r := ColorRect.new()
    r.color = color
    var l := label(caption, 40)
    l.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    r.add_child(l)
    return r

# options: [[button_text, Callable], ...]. Use Callable() for "just close".
static func dialog(parent: Control, text: String, options: Array) -> void:
    var dim := ColorRect.new()
    dim.color = Color(0, 0, 0, 0.75)
    dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    parent.add_child(dim)
    var center := CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    dim.add_child(center)
    var panel := PanelContainer.new()
    center.add_child(panel)
    var v := VBoxContainer.new()
    v.add_theme_constant_override("separation", 28)
    panel.add_child(v)
    var l := label(text, 36)
    l.custom_minimum_size = Vector2(700, 0)
    v.add_child(l)
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 20)
    v.add_child(row)
    for opt in options:
        var b := button(opt[0], Vector2(0, 100), 40)
        b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        var cb: Callable = opt[1]
        var handler := func() -> void:
            dim.queue_free()
            if cb.is_valid():
                cb.call()
        b.pressed.connect(handler)
        row.add_child(b)

static func alert(parent: Control, text: String) -> void:
    dialog(parent, text, [["OK", Callable()]])
