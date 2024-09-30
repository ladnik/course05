#ifndef CALCULATE_FORCES_H
#define CALCULATE_FORCES_H

#include <godot_cpp/classes/node2d.hpp>

namespace godot {

class Simulator : public Node2D {
	GDCLASS(Simulator, Node2D)

public:
	Simulator();
	~Simulator();

	protected:
		static void _bind_methods();

	PackedVector2Array update(double delta, PackedVector2Array positions);

};
}

#endif
