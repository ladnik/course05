#ifndef CALCULATE_FORCES_H
#define CALCULATE_FORCES_H

#include <godot_cpp/classes/node2d.hpp>

namespace godot {

class Simulator : public Node2D {
	GDCLASS(Simulator, Node2D)

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
		Vector2 world_to_grid(Vector2 pos);
		void build_grid();



	public:
		Simulator();
		~Simulator();
		void _init(float pos_x, float dis_x, float pos_y, float dis_y);
		void integration_step(float delta);
		void calculate_next_velocity(float delta);
		Vector2 interaction_force(const Vector2 &position1, const Vector2 &position2);
		void calculate_interaction_forces(PackedVector2Array &current_positions, PackedVector2Array &forces, Dictionary &grid, Array &neighborsToCheck);
		void apply_force(int index1, int index2, PackedVector2Array &current_positions, PackedVector2Array &forces);
		void reset_forces(PackedVector2Array &forces);
		//void check_oneway_coupling(PackedVector2Array &current_positions, PackedVector2Array &previous_positions, Ref<MeshInstance2D> mesh_generator);
		//PackedVector2Array collision_checker(int i, PackedVector2Array &previous_positions, PackedVector2Array &current_positions, Ref<MeshInstance2D> mesh_generator);
		void double_density_relaxation(float delta, PackedVector2Array &current_positions);
		void bounceFromBorder(PackedVector2Array &current_positions, PackedVector2Array &velocities);
		PackedVector2Array get_particle_positions();
		PackedVector2Array get_particle_velocities();
		PackedVector2Array get_particle_forces();
		void delete_particle(int index);

		void update(float delta);

	protected:
		static void _bind_methods();

};
}
#endif