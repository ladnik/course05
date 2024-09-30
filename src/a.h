#ifndef A_H
#define A_H

#include <godot_cpp/classes/sprite2d.hpp>

namespace godot {

class A : public Sprite2D {
	GDCLASS(A, Sprite2D)

private:
	double time_passed;
	double amplitude;

protected:
	static void _bind_methods();

public:
	A();
	~A();

	void _process(double delta) override;
	void set_amplitude(const double p_amplitude);
	double get_amplitude() const;

};
}

#endif
