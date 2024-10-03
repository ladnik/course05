shader_type canvas_item;
render_mode skip_vertex_transform;
varying vec2 world_pos;

uniform float border_width = 10.;
uniform int bar_distance = 50;
uniform vec4 border_color = vec4(.8, .1, .1, .5);

void vertex() {
	VERTEX = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	world_pos = VERTEX;
}

void fragment() {
	vec2 pixel_delta = vec2(dFdx(UV.x), dFdy(UV.y));
	vec2 pixel_size = abs(vec2(1., 1.) / pixel_delta);
	vec2 pixel_pos = UV / pixel_delta;
	COLOR = vec4(.1);

	if(int(pixel_pos.x + pixel_pos.y) % bar_distance < int(border_width)){
		COLOR = border_color;
	}

	bool right_border = UV.x > 1. - border_width / pixel_size.x;
	bool left_border = UV.x < border_width / pixel_size.x;
	bool bottom_border = UV.y > 1. - border_width / pixel_size.y;
	bool top_border = UV.y < border_width / pixel_size.y;

	if(right_border || left_border || bottom_border || top_border){
		COLOR = border_color;
	}

	
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
