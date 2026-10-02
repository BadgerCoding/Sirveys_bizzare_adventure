class_name AppTheme
extends RefCounted
# One shared look for the whole app: warm brown pixel UI (chunky dark outlines, raised plank buttons,
# dark inner panels). Change the palette below and every screen follows.
# Optional pixel font: put a .ttf at res://assets/fonts/pixel.ttf (see README for import settings).

const DARK := Color("2b1a12")       # outlines
const BG := Color("5a4132")         # screen background
const PANEL_IN := Color("4a352a")   # dark inner panel
const BROWN := Color("9c5a2c")      # buttons / frames
const BROWN_HI := Color("b86d3a")   # hover
const BROWN_LO := Color("74421f")   # pressed
const OFF := Color("5f4a3c")        # disabled
const TAN := Color("e9a85d")        # highlights, headings
const CREAM := Color("f6dcaa")      # body text
const MUTED := Color("9a7b63")      # disabled text, placeholders
const FONT_PATH := "res://assets/fonts/pixel.ttf"

static func _box(bg: Color, border: Color, bw: int, bottom: int, pad_x: int, pad_y: int, top_shift := 0) -> StyleBoxFlat:
    var s := StyleBoxFlat.new()
    s.bg_color = bg
    s.border_color = border
    s.border_width_left = bw
    s.border_width_right = bw
    s.border_width_top = bw
    s.border_width_bottom = bottom
    s.set_corner_radius_all(4)
    s.corner_detail = 1
    s.anti_aliasing = false
    s.content_margin_left = pad_x
    s.content_margin_right = pad_x
    s.content_margin_top = pad_y + top_shift
    s.content_margin_bottom = pad_y
    return s

static func build() -> Theme:
    var t := Theme.new()
    t.default_font_size = 32
    if ResourceLoader.exists(FONT_PATH):
        t.default_font = load(FONT_PATH)

    # Buttons: raised plank with a thick bottom edge; pressed = pushed in.
    t.set_stylebox("normal", "Button", _box(BROWN, DARK, 5, 11, 16, 8))
    t.set_stylebox("hover", "Button", _box(BROWN_HI, DARK, 5, 11, 16, 8))
    t.set_stylebox("pressed", "Button", _box(BROWN_LO, DARK, 5, 5, 16, 8, 6))
    t.set_stylebox("disabled", "Button", _box(OFF, DARK, 5, 11, 16, 8))
    t.set_stylebox("focus", "Button", StyleBoxEmpty.new())
    t.set_color("font_color", "Button", CREAM)
    t.set_color("font_hover_color", "Button", Color.WHITE)
    t.set_color("font_pressed_color", "Button", TAN)
    t.set_color("font_disabled_color", "Button", MUTED)
    t.set_color("font_outline_color", "Button", DARK)
    t.set_constant("outline_size", "Button", 6)

    # Panels and dialogs: dark inside, brown frame.
    t.set_stylebox("panel", "PanelContainer", _box(PANEL_IN, BROWN, 8, 8, 20, 16))
    t.set_stylebox("panel", "Panel", _box(PANEL_IN, BROWN, 8, 8, 8, 8))

    # Text inputs
    for kind in ["LineEdit", "TextEdit"]:
        t.set_stylebox("normal", kind, _box(DARK, BROWN, 4, 4, 14, 10))
        t.set_stylebox("focus", kind, _box(DARK, TAN, 4, 4, 14, 10))
        t.set_color("font_color", kind, CREAM)
        t.set_color("font_placeholder_color", kind, MUTED)
        t.set_color("caret_color", kind, TAN)

    # Bars (UI.bar() sets the fill colour per bar)
    t.set_stylebox("background", "ProgressBar", _box(DARK, BROWN_LO, 3, 3, 0, 0))
    t.set_stylebox("fill", "ProgressBar", _box(TAN, TAN, 0, 0, 0, 0))

    # Toggles and sliders: keep Godot's icons, recolour the text.
    for kind in ["CheckButton", "CheckBox"]:
        t.set_color("font_color", kind, CREAM)
        t.set_color("font_hover_color", kind, Color.WHITE)
        t.set_color("font_pressed_color", kind, TAN)
        t.set_color("font_hover_pressed_color", kind, TAN)
    t.set_color("font_color", "Label", CREAM)
    return t
