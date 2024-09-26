shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}
uniform float lod: hint_range(0.0, 5) = 2.0;

void fragment() {
	// Called for every pixel the material is visible on.
	COLOR = texture(TEXTURE, UV, lod); // Read from texture again. //set blue channel to 1.0
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
