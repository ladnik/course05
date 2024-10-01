#ifndef CALCULATE_FORCES_H
#define CALCULATE_FORCES_H

#include <godot_cpp/classes/node2d.hpp>

namespace godot {

class Simulator : public Node2D {
	GDCLASS(Simulator, Node2D)

	public:
		Simulator();
		~Simulator();
		void update(float delta);
		PackedVector2Array get_particle_positions();
		PackedVector2Array get_particle_velocities();
		PackedVector2Array get_particle_forces();
		void _init(float pos_x, float dis_x, float pos_y, float dis_y);
		void delete_particle(int index);

	private:
    	PackedVector2Array current_positions;
    	PackedVector2Array previous_positions;
    	PackedVector2Array velocities;
    	PackedVector2Array forces;
    	Array particle_valid;
    	Vector2 gravity_vector;
    	Dictionary grid;
    	Array neighborsToCheck;
		void random_spawn(float pos_x, float dis_x, float pos_y, float dis_y);
		void build_grid();
		Vector2 world_to_grid(Vector2 position);
		void apply_force(int index1, int index2);
		void reset_forces();
		Vector2 interaction_force(const Vector2 &position1, const Vector2 &position2);
		void calculate_interaction_forces();
		void integration_step(float delta);
		void calculate_next_velocity(float delta);
		void bounce_from_border();
		void double_density_relaxation(float delta);

	protected:
		static void _bind_methods();


};

}

#endif
