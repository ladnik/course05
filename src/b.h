#ifndef B_H
#define B_H

#include <godot_cpp/classes/sprite2d.hpp>

namespace godot {

class B : public Sprite2D {
	GDCLASS(B, Sprite2D)

private:
	double time_passed;
	double amplitude;

protected:
	static void _bind_methods();

public:
	B();
	~B();

	void _process(double delta) override;
	void set_amplitude(const double p_amplitude);
	double get_amplitude() const;

};
}

#endif
