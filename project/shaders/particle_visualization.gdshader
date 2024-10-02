shader_type canvas_item;
render_mode skip_vertex_transform;

uniform float x_size = 1;
uniform float y_size = 1;

uniform vec2 particle_positions[2048];
uniform int num_particles = 0;
uniform float kernel_radius = 80.;

varying vec2 world_pos;

void vertex() {
	VERTEX = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	world_pos = VERTEX;
}


void fragment() {
	
	vec2 sample_pos = world_pos / vec2(x_size, y_size);
	sample_pos = UV;
	if (texture(TEXTURE, sample_pos).r > .5) {
		COLOR = vec4(1., 1, 0., 1.);
	}
	else {
		float acc = 0.;
		int near_particles = 0;
		for (int i = 0; i < num_particles; i++) {
			vec2 delta = particle_positions[i] - world_pos;
			float distance = length(delta);
			float kernel_val = pow(clamp(1. - distance / kernel_radius, 0., 1.), 3); 
			acc += kernel_val;
		}
		
		if(acc > .2){
			COLOR = vec4(1, 0, 0, 1);
		}
		else {
			COLOR = vec4(0, 0, 0, 0);			
		}
	}

	//COLOR = vec4(1., .5, 0, 1.);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
