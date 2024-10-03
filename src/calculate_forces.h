#ifndef CALCULATE_FORCES_H
#define CALCULATE_FORCES_H

#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/mesh_instance2d.hpp>

#include <map>
#include <vector>

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
		void _init(Dictionary constants);
		void delete_particles(PackedInt32Array indices);
		void set_mesh_generator(MeshInstance2D *mesh_instance) { mesh_generator = mesh_instance; }
		void set_water_source(float pos_x, float dis_x, float pos_y, float dis_y, float vel_x, float vel_y, int mass_flow);

	private:
    	PackedVector2Array current_positions;
    	PackedVector2Array previous_positions;
    	PackedVector2Array velocities;
    	PackedVector2Array forces;
    	std::vector<bool> particle_valid;
    	Vector2 gravity_vector;
    	std::map<Vector2, std::vector<int>> grid;
    	std::vector<Vector2> neighborsToCheck;
		MeshInstance2D *mesh_generator;
		
		// spawn positions
		int pos_x;
		int dis_x;
		int pos_y;
		int dis_y;
		int vel_x;
		int vel_y;
		int mass_flow;
		float spawn_interval;
		float spawn_timer;


		// constants
		bool use_double_density;
		int width;
		int height;
		int number_particles;
		int gravity;
		int interaction_radius;
		int grid_size;
		bool use_grid;
		int particle_radius;

		// double density
		int knormal;
		float density_zero;
		int knear;

		// spring
		int spring_constant;

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
		std::vector<int> get_all_neighbour_particles(Vector2 cell_key);
		Array collision_checker(int i);
		void check_oneway_coupling();
		Vector2 get_random_spawn_position();
		void water_source_spawn(float delta);

	protected:
		static void _bind_methods();


};

}

#endif
