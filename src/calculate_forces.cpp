#include "calculate_forces.h"
#include <random>

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/packed_vector2_array.hpp>
#include <godot_cpp/variant/vector2.hpp>
#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/resource_loader.hpp>
#include <godot_cpp/classes/mesh_instance2d.hpp>
#include <godot_cpp/variant/dictionary.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/mesh_instance2d.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void Simulator::_bind_methods() {
	ClassDB::bind_method(D_METHOD("update"), &Simulator::update);
	ClassDB::bind_method(D_METHOD("get_particle_positions"), &Simulator::get_particle_positions);
	ClassDB::bind_method(D_METHOD("get_particle_velocities"), &Simulator::get_particle_velocities);
	ClassDB::bind_method(D_METHOD("get_particle_forces"), &Simulator::get_particle_forces);
	ClassDB::bind_method(D_METHOD("_init", "constants", "pos_x", "dis_x", "pos_y", "dis_y"), &Simulator::_init);
	ClassDB::bind_method(D_METHOD("delete_particle", "index"), &Simulator::delete_particle);
	ClassDB::bind_method(D_METHOD("set_mesh_generator", "mesh_instance"), &Simulator::set_mesh_generator);

}

Simulator::Simulator() {
	grid = Dictionary();
	neighborsToCheck = PackedVector2Array();
	neighborsToCheck.push_back(Vector2(-1, 1));
	neighborsToCheck.push_back(Vector2(0, 1));
	neighborsToCheck.push_back(Vector2(1, 1));
	neighborsToCheck.push_back(Vector2(1, 0));
	current_positions = PackedVector2Array();
	previous_positions = PackedVector2Array();
	velocities = PackedVector2Array();
	forces = PackedVector2Array();
	particle_valid = Array();
	mesh_generator = nullptr;
}

Simulator::~Simulator() {
	// Add your cleanup here.
}

// Function to update the simulation
void Simulator::update(float delta) {

    // this is how you print it out UtilityFunctions::print("test");
	//reset_forces();
	//calculate_interaction_forces();
	integration_step(delta);
	double_density_relaxation(delta);
	calculate_next_velocity(delta);
	bounce_from_border();
	check_oneway_coupling();
}

// Function to retrieve the positions of valid particles
PackedVector2Array Simulator::get_particle_positions() {
    PackedVector2Array particles;
    for (int i = 0; i < current_positions.size(); ++i) {
        if (particle_valid[i].operator bool()) {
            particles.push_back(current_positions[i]);
        }
    }
    return particles;
}

// Function to retrieve the velocities of valid particles
PackedVector2Array Simulator::get_particle_velocities() {
	PackedVector2Array particles;
	for (int i = 0; i < velocities.size(); ++i) {
		if (particle_valid[i].operator bool()) {
			particles.push_back(velocities[i]);
		}
	}
	return particles;
}

// Function to retrieve the forces of valid particles
PackedVector2Array Simulator::get_particle_forces() {
	PackedVector2Array particles;
	for (int i = 0; i < forces.size(); ++i) {
		if (particle_valid[i].operator bool()) {
			particles.push_back(forces[i]);
		}
	}
	return particles;
}

void Simulator::_init(Dictionary constants, float pos_x, float dis_x, float pos_y, float dis_y) {
    this->constants = constants;
    random_spawn(pos_x, dis_x, pos_y, dis_y);
    gravity_vector = Vector2(0, (int) constants["GRAVITY"]);
}

Vector2 Simulator::world_to_grid(Vector2 pos) {
	float grid_size = (double) constants["GRID_SIZE"];
	return Vector2(Math::floor(pos.x / grid_size), Math::floor(pos.y / grid_size));
}

void Simulator::build_grid() {
	grid.clear();
	for (int i = 0; i < current_positions.size(); i++) {
		Vector2 grid_pos = world_to_grid(current_positions[i]);
		if (grid.has(grid_pos)) {
			Array arr = grid[grid_pos];
			arr.append(i);
			grid[grid_pos] = arr;
		} else {
			Array new_arr;
			new_arr.append(i);
			grid[grid_pos] = new_arr;
		}
	}
}

void Simulator::random_spawn(float pos_x, float dis_x, float pos_y, float dis_y) {
	std::random_device rd;
	std::mt19937 gen(rd());
	std::uniform_real_distribution<> dis(0, 1);
	for (int i = 0; i < (int) constants["NUMBER_PARTICLES"]; i++) {
		Vector2 spawn_position = Vector2(dis(gen) * dis_x + pos_x, dis(gen) * dis_y + pos_y);
		current_positions.push_back(spawn_position);
		previous_positions.push_back(spawn_position);
		velocities.push_back(Vector2(0, 0));
		forces.push_back(Vector2(0, 0));
		particle_valid.push_back(true);
	}
}

// Function to calculate interaction force between two particles
Vector2 Simulator::interaction_force(const Vector2 &position1, const Vector2 &position2) {
    Vector2 r = position2 - position1;
    
    if (r.length() > 2 * (int) constants["INTERACTION_RADIUS"]) {
        return Vector2(0, 0);
    }

    Vector2 overlap = 2 * (int) constants["INTERACTION_RADIUS"] * r.normalized() - r;

    float forceX = overlap.x;
    float forceY = overlap.y;

    Vector2 force = (int) constants["SPRING_CONSTANT"] * Vector2(forceX, forceY);

    return force;
}


// Function to apply force between two particles
void Simulator::apply_force(int index1, int index2) {
    Vector2 force = interaction_force(current_positions[index1], current_positions[index2]);
    forces[index1] = forces[index1] - force;
    forces[index2] = forces[index2] + force;
}

// Function to reset forces for all particles
void Simulator::reset_forces() {
    for (int i = 0; i < forces.size(); ++i) {
        forces[i] = Vector2(0, 0);
    }
}

// Function to calculate interaction forces between particles
void Simulator::calculate_interaction_forces() {
    if (!(bool) constants["USE_GRID"]) {
        for (int i = 0; i < current_positions.size(); ++i) {
            for (int j = i + 1; j < current_positions.size(); ++j) {
                apply_force(i, j);
            }
        }
    } else {
        build_grid();
		Array keys = grid.keys();
		for (int i = 0; i < keys.size(); ++i)
		{
			Vector2 cell_key = keys[i].operator Vector2();
			Array cell = grid[cell_key];
            
            // Apply forces within the cell
            for (int i = 0; i < cell.size(); ++i) {
                for (int j = i + 1; j < cell.size(); ++j) {
                    apply_force(cell[i], cell[j]);
                }
            }

            // Apply forces to neighboring cells
            for (int i = 0; i < neighborsToCheck.size(); ++i) {
                Vector2 neighbor_cell_key = cell_key + neighborsToCheck[i].operator Vector2();

                if (grid.has(neighbor_cell_key)) {
                    Array neighbor_cell = grid[neighbor_cell_key];
                    for (int i = 0; i < cell.size(); ++i) {
                        for (int j = 0; j < neighbor_cell.size(); ++j) {
                            apply_force(cell[i], neighbor_cell[j]);
                        }
                    }
                }
            }
		}
	}
}

// Function to delete a particle by marking it as invalid
void Simulator::delete_particle(int index) {
    int valid_index = 0;
    for (int i = 0; i < current_positions.size(); ++i) {
        if (particle_valid[i].operator bool()) {
            if (valid_index == index) {
                particle_valid[i] = false;
                return;
            }
            valid_index++;
        }
    }
}

void Simulator::integration_step(float delta) {
	for (int i = 0; i < current_positions.size(); i++) {
		Vector2 force = gravity_vector + forces[i];
		previous_positions[i] = current_positions[i];
		velocities[i] += delta * force;
		current_positions[i] += delta * velocities[i];
	}
}

void Simulator::calculate_next_velocity(float delta) {
	for (int i = 0; i < current_positions.size(); i++) {
		Vector2 velocity = (current_positions[i] - previous_positions[i]) / delta;

        // max velocity for going upwards
		if (velocity.y < -200) {
			velocity.y = -200;
		}
		velocities[i] = velocity;
	}
}

// Function to check if particles collide with borders and apply bounce effects
void Simulator::bounce_from_border() {
    for (int i = 0; i < current_positions.size(); ++i) {
        if (current_positions[i].x - (int) constants["PARTICLE_RADIUS"] < 0) {
            current_positions[i].x = (int) constants["PARTICLE_RADIUS"];
            velocities[i].x *= -0.5;
        }
        if (current_positions[i].x + (int) constants["PARTICLE_RADIUS"] > (int) constants["WIDTH"]) {
            current_positions[i].x = (int) constants["WIDTH"] - (int) constants["PARTICLE_RADIUS"];
            velocities[i].x *= -0.5;
        }
        if (current_positions[i].y + (int) constants["PARTICLE_RADIUS"] > (int) constants["HEIGHT"]) {
            current_positions[i].y = (int) constants["HEIGHT"] - (int) constants["PARTICLE_RADIUS"];
            velocities[i].y *= -0.5;
        }
    }
}

// Function for double-density relaxation
void Simulator::double_density_relaxation(float delta) {
	build_grid();
	Array keys = grid.keys();
    //UtilityFunctions::print(constants["INTERACTION_RADIUS"]);
    for (int i = 0; i < keys.size(); ++i)
    {
        Vector2 cell_key = keys[i].operator Vector2();
        Array cell = grid[cell_key];

        Array neighbors = get_all_neighbour_particles(cell_key);
        for (int k = 0; k < cell.size(); ++k) {
            int particle_k = cell[k];
            double density = 0;
            double density_near = 0;
            // Compute density and near density
            for (int j = 0; j < neighbors.size(); ++j) {
                int particle_j = neighbors[j];
                if (particle_k == particle_j) continue;

                Vector2 rij = current_positions[particle_j] - current_positions[particle_k];
                double q = rij.length() / (int) constants["INTERACTION_RADIUS"];

                if (q < 1) {
                    density += pow(1 - q, 2);
                    density_near += pow(1 - q, 3);
                }
            }

            // Compute pressure and pressure near
            double pressure = (int) constants["K"] * (density - (float) constants["DENSITY_ZERO"]);
            double pressure_near = (int) constants["KNEAR"] * density_near;
            Vector2 pos_displacement_A(0, 0);

            // Apply displacements
            for (int j = 0; j < neighbors.size(); ++j) {
                int particle_j = neighbors[j];
                if (particle_k == particle_j) continue;

                Vector2 rij = current_positions[particle_j] - current_positions[particle_k];
                double q = rij.length() / (int) constants["INTERACTION_RADIUS"];

                if (q < 1) {
                    rij = rij.normalized();
                    Vector2 displacement_term = pow(delta, 2) * (pressure * (1 - q) + pressure_near * (1 - q)) * rij;
                    current_positions[particle_j] = current_positions[particle_j] + displacement_term / 2;
                    pos_displacement_A -= displacement_term / 2;
                }
            }
            current_positions[particle_k] = current_positions[particle_k] + pos_displacement_A;
        }
    }
}

PackedInt32Array Simulator::get_all_neighbour_particles(Vector2 cell_key) {
	PackedInt32Array neighbors = PackedInt32Array();
	for (int i = -1; i <= 1; i++) {
		for (int j = -1; j <= 1; j++) {
			Vector2 neighbor_cell_key = cell_key + Vector2(i, j);
			if (grid.has(neighbor_cell_key)) {
				Array neighbor_cell = grid[neighbor_cell_key];
				for (int k = 0; k < neighbor_cell.size(); k++) {
                    if (particle_valid[neighbor_cell[k]].operator bool()) {
					    neighbors.push_back(neighbor_cell[k]);
                    }
				}
			}
		}
	}
	return neighbors;
}

// Function to check for collisions for a particle

Array Simulator::collision_checker(int i)
{
	return mesh_generator->call<Vector2, Vector2>("continuous_collision", previous_positions[i], current_positions[i]);
}

// Function to check one-way coupling between particles and objects
void Simulator::check_oneway_coupling() {
    for (int i = 0; i < current_positions.size(); ++i) {
        Array collision_object = collision_checker(i);
        if (collision_object[0].operator bool() == true) {
            current_positions[i] = current_positions[i] + collision_object[2].operator Vector2().normalized() * 5.0;
			velocities[i] = velocities[i] - velocities[i].dot(collision_object[2].operator Vector2().normalized()) * collision_object[2].operator Vector2().normalized();
            if (collision_checker(i)[0].operator bool() == true) {
                current_positions[i] = previous_positions[i];
            }
        }
    }
}