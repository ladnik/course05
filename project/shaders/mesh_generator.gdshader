shader_type canvas_item;
render_mode skip_vertex_transform;

uniform float x_scale = 1000.;
uniform float y_scale = 1000.;
uniform sampler2D tex;

varying vec2 world_pos;

void vertex() {
	VERTEX = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	world_pos = VERTEX;
}

void fragment() {
	COLOR = texture(tex, world_pos / vec2(x_scale, y_scale));
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
