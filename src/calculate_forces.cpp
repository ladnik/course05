#include "calculate_forces.h"
#include "simulation_constants.h"
#include <random>

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/packed_vector2_array.hpp>
#include <godot_cpp/variant/vector2.hpp>
#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/resource_loader.hpp>
#include <godot_cpp/classes/mesh_instance2d.hpp>
#include <godot_cpp/variant/dictionary.hpp>
#include <godot_cpp/core/class_db.hpp>


using namespace godot;




void Simulator::_bind_methods() {
	ClassDB::bind_method(D_METHOD("get_particle_positions"), &Simulator::get_particle_positions);
	ClassDB::bind_method(D_METHOD("get_particle_velocities"), &Simulator::get_particle_velocities);
	ClassDB::bind_method(D_METHOD("get_particle_forces"), &Simulator::get_particle_forces);
	ClassDB::bind_method(D_METHOD("delete_particle"), &Simulator::delete_particle);
	ClassDB::bind_method(D_METHOD("update"), &Simulator::update);
	ClassDB::bind_method(D_METHOD("_init"), &Simulator::_init);
}

Simulator::Simulator() {
	grid = Dictionary();
	neighborsToCheck = Array();
	gravity_vector = Vector2(0, SimulationConstants::GRAVITY);
	current_positions = PackedVector2Array();
	previous_positions = PackedVector2Array();
	velocities = PackedVector2Array();
	forces = PackedVector2Array();
	particle_valid = Array();
}

Simulator::~Simulator() {
	// Add your cleanup here.
}

void Simulator::_init(float pos_x, float dis_x, float pos_y, float dis_y) {
        random_spawn(pos_x, dis_x, pos_y, dis_y);
}

Vector2 world_to_grid(Vector2 pos) {
	float grid_size = SimulationConstants::GRID_SIZE;
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
	for (int i = 0; i < SimulationConstants::NUMBER_PARTICLES; i++) {
		Vector2 spawn_position = Vector2(dis(gen) * dis_x + pos_x, dis(gen) * dis_y + pos_y);
		current_positions.push_back(spawn_position);
		previous_positions.push_back(spawn_position);
		velocities.push_back(Vector2(0, 0));
		forces.push_back(Vector2(0, 0));
		particle_valid.push_back(true);
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
		velocities[i] = velocity;
	}
}

// Function to calculate interaction force between two particles
Vector2 Simulator::interaction_force(const Vector2 &position1, const Vector2 &position2) {
    Vector2 r = position2 - position1;
    
    if (r.length() > 2 * SimulationConstants::INTERACTION_RADIUS) {
        return Vector2(0, 0);
    }

    Vector2 overlap = 2 * SimulationConstants::INTERACTION_RADIUS * r.normalized() - r;

    float forceX = overlap.x;
    float forceY = overlap.y;

    Vector2 force = SimulationConstants::SPRING_CONSTANT * Vector2(forceX, forceY);

    return force;
}

// Function to calculate interaction forces between particles
void Simulator::calculate_interaction_forces(PackedVector2Array &current_positions, PackedVector2Array &forces, Dictionary &grid, Array &neighborsToCheck) {
    if (!SimulationConstants::USE_GRID) {
        for (int i = 0; i < current_positions.size(); ++i) {
            for (int j = i + 1; j < current_positions.size(); ++j) {
                apply_force(i, j, current_positions, forces);
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
                    apply_force(cell[i], cell[j], current_positions, forces);
                }
            }

            // Apply forces to neighboring cells
            for (int i = 0; i < neighborsToCheck.size(); ++i) {
                Vector2 neighbor_cell_key = cell_key + neighborsToCheck[i].operator Vector2();

                if (grid.has(neighbor_cell_key)) {
                    Array neighbor_cell = grid[neighbor_cell_key];
                    for (int i = 0; i < cell.size(); ++i) {
                        for (int j = 0; j < neighbor_cell.size(); ++j) {
                            apply_force(cell[i], neighbor_cell[j], current_positions, forces);
                        }
                    }
                }
            }
		}
	}
}

// Function to apply force between two particles
void Simulator::apply_force(int index1, int index2, PackedVector2Array &current_positions, PackedVector2Array &forces) {
    Vector2 force = interaction_force(current_positions[index1], current_positions[index2]);
    forces[index1] = forces[index1] - force;
    forces[index2] = forces[index2] + force;
}

// Function to reset forces for all particles
void Simulator::reset_forces(PackedVector2Array &forces) {
    for (int i = 0; i < forces.size(); ++i) {
        forces[i] = Vector2(0, 0);
    }
}

// Function to check for collisions for a particle
/**
Array collision_checker(int i, PackedVector2Array &previous_positions, PackedVector2Array &current_positions, Ref<MeshInstance2D> mesh_generator) {
	throw 'Not implemented';
	
	//return mesh_generator->continuous_collision(previous_positions[i].operator Vector2(), current_positions[i].operator Vector2());
}
*/

// Function to check one-way coupling between particles and objects
/**
void check_oneway_coupling(PackedVector2Array &current_positions, PackedVector2Array &previous_positions, Ref<MeshInstance2D> mesh_generator) {
    for (int i = 0; i < current_positions.size(); ++i) {
        Array collision_object = collision_checker(i, previous_positions, current_positions, mesh_generator);
        if (collision_object[0].operator bool() == true) {
            current_positions[i] = current_positions[i] + collision_object[2].operator Vector2().normalized() * 0.5;
            if (collision_checker(i, previous_positions, current_positions, mesh_generator)[0].operator bool() == true) {
                current_positions[i] = previous_positions[i];
            }
        }
    }
}
*/

// Function for double-density relaxation
void Simulator::double_density_relaxation(float delta, PackedVector2Array &current_positions) {
    for (int i = 0; i < current_positions.size(); ++i) {
        float density = 0;
        float density_near = 0;
        Vector2 particleA = current_positions[i];
        float h = 30.0f; // Cut-off radius
        float k = 0.1f;
        float k_near = 0.2f;
        float density_zero = 10.0f;

        // Calculate densities
        for (int j = 0; j < current_positions.size(); ++j) {
            if (i == j) continue;
            Vector2 particleB = current_positions[j];
            Vector2 rij = particleB - particleA;
            float q = rij.length() / h;
            if (q < 1) {
                density += pow(1 - q, 2);
                density_near += pow(1 - q, 3);
            }
        }

        // Compute pressures
        float pressure = k * (density - density_zero);
        float pressure_near = k_near * density_near;
        Vector2 pos_displacement_A(0, 0);

        // Calculate displacements
        for (int j = 0; j < current_positions.size(); ++j) {
            if (i == j) continue;
            Vector2 particleB = current_positions[j];
            Vector2 rij = particleB - particleA;
            float q = rij.length() / h;
            if (q < 1) {
                rij = rij.normalized();
                Vector2 displacement_term = pow(delta, 2) * (pressure * (1 - q) + pressure_near * pow(1 - q, 2)) * rij;
                current_positions[j] = current_positions[j] + displacement_term / 2;
                pos_displacement_A -= displacement_term / 2;
            }
        }
        current_positions[i] = current_positions[i] + pos_displacement_A;
    }
}

// Function to check if particles collide with borders and apply bounce effects
void Simulator::bounceFromBorder(PackedVector2Array &current_positions, PackedVector2Array &velocities) {
    for (int i = 0; i < current_positions.size(); ++i) {
        if (current_positions[i].x - SimulationConstants::INTERACTION_RADIUS < 0) {
            current_positions[i].x = SimulationConstants::INTERACTION_RADIUS;
            velocities[i].x *= -0.5;
        }
        if (current_positions[i].x + SimulationConstants::INTERACTION_RADIUS > SimulationConstants::WIDTH) {
            current_positions[i].x = SimulationConstants::WIDTH - SimulationConstants::INTERACTION_RADIUS;
            velocities[i].x *= -0.5;
        }
        if (current_positions[i].y + SimulationConstants::INTERACTION_RADIUS > SimulationConstants::HEIGHT) {
            current_positions[i].y = SimulationConstants::HEIGHT - SimulationConstants::INTERACTION_RADIUS;
            velocities[i].y *= -0.5;
        }
    }
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

// Function to update the simulation
void Simulator::update(float delta) {
	reset_forces(forces);
	calculate_interaction_forces(current_positions, forces, grid, neighborsToCheck);
	integration_step(delta);
	calculate_next_velocity(delta);
	//check_oneway_coupling(current_positions, previous_positions, mesh_generator);
	//double_density_relaxation(delta, current_positions);
	bounceFromBorder(current_positions, velocities);
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