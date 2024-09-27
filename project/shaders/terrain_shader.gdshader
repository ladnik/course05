shader_type canvas_item;
render_mode skip_vertex_transform;

uniform float x_size = 160;
uniform float y_size = 90;

uniform sampler2D grid;
varying vec2 world_pos;

void vertex() {
	VERTEX = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	world_pos = VERTEX;
}

void fragment() {
	vec2 sample_pos = world_pos / vec2(x_size, y_size);
	if (texture(grid, sample_pos).r > .5) {
		COLOR = vec4(1., 1., 1., 1.);
	}
	else {
		COLOR = vec4(0., 0., 0., 0.);
	}
	COLOR = vec4(1., 1., 1., 1.);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
