#include "calculate_forces.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/packed_vector2_array.hpp>
#include <godot_cpp/variant/vector2.hpp>
#include <iostream>

using namespace godot;

void Simulator::_bind_methods() {
	ClassDB::bind_method(D_METHOD("update"), &Simulator::update);
}

Simulator::Simulator() {

}

Simulator::~Simulator() {
	// Add your cleanup here.
}

PackedVector2Array Simulator::update(double delta, PackedVector2Array positions) {

	for (int i = 0; i < positions.size(); i++) {
		Vector2 pos = positions[i];
		pos.x += 1;
		positions.set(i, pos);
	}
	return positions;
}
