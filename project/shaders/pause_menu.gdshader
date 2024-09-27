shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}
uniform float lod = 2.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	// Called for every pixel the material is visible on.
	COLOR = textureLod(SCREEN_TEXTURE, SCREEN_UV, lod); // Read from texture again. //set blue channel to 1.0
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
