shader_type canvas_item;

render_mode blend_sub;

void fragment() {
	if (distance(UV, vec2(0.5)) > 0.5) {
		COLOR.a = 0.0;
	}
}

