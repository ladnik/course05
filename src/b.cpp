#include "b.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void B::_bind_methods() {
	ClassDB::bind_method(D_METHOD("get_amplitude"), &B::get_amplitude);
	ClassDB::bind_method(D_METHOD("set_amplitude", "p_amplitude"), &B::set_amplitude);
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "amplitude"), "set_amplitude", "get_amplitude");
}

B::B() {
	// Initialize any variables here.
	time_passed = 0.0;
	amplitude =10.0;
}

B::~B() {
	// Add your cleanup here.
}

void B::_process(double delta) {
	time_passed += delta;

	Vector2 new_position = Vector2(
		amplitude + (amplitude * sin(time_passed * 2.0)),
		amplitude + (amplitude * cos(time_passed * 1.5))
	);

	set_position(new_position);
}

void B::set_amplitude(const double p_amplitude) {
	amplitude = p_amplitude;
}

double B::get_amplitude() const {
	return amplitude;
}
