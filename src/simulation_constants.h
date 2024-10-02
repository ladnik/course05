#ifndef CONSTANTS_H
#define CONSTANTS_H

namespace SimulationConstants {
    constexpr bool DEBUG = false;
    constexpr bool DISPLAY_VELOCITY = false;
    constexpr bool DISPLAY_FORCE = true;

    constexpr int WIDTH = 1920;
    constexpr int HEIGHT = 1080;

    // set to -1 to use the water_source
    constexpr int NUMBER_PARTICLES = 500;

    constexpr int GRAVITY = 1000;

    constexpr double INTERACTION_RADIUS = 20.0;
    constexpr double SPRING_CONSTANT = 3000 / INTERACTION_RADIUS;

    constexpr double GRID_SIZE = 2 * INTERACTION_RADIUS;
    constexpr bool USE_GRID = true;
    constexpr double DENSITY_ZERO = 0.5;
    constexpr double K = 2000.0;
    constexpr double K_NEAR = 20000.0;
}

#endif
