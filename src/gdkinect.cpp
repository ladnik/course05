#include "gdkinect.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <stdexcept>

#define LOWEST_DEPTH 5000
#define KINECT_WIDTH 640
#define KINECT_HEIGHT 480
#define SQUARE_SIZE 30
#define SEARCH_RADIUS 30
#define SCREEN_WIDTH 1920.0
#define SCREEN_HEIGHT 1080.0

using namespace godot;


HandPos::HandPos()
    : x(-1),
    y(-1),
    depth(LOWEST_DEPTH) {}


GDKinect::GDKinect() {
    try {
	depthMat = std::make_unique<uint16_t[]>(KINECT_HEIGHT * KINECT_WIDTH * sizeof(uint16_t));
	kinect_device = freenect.createDevice<CustomFreenectDevice>(0);
	kinect_device->get().startDepth();
	UtilityFunctions::print("Started Kinect RGB and depth video");
    } catch (std::runtime_error &e) {
	UtilityFunctions::print(e.what());
    }
}

GDKinect::~GDKinect() {
    if (kinect_device) {
	kinect_device->get().stopDepth();
    }
    UtilityFunctions::print("Stopped Kinect RGB and depth video");
}

Vector2 GDKinect::get_position() {
    std::optional<HandPos> h = get_hand_pos();
    if(!h) {
	return Vector2(0, 0);
    }
    return Vector2(SCREEN_WIDTH - h->x * (SCREEN_WIDTH / KINECT_WIDTH), h->y * (SCREEN_HEIGHT / KINECT_HEIGHT));
}

void GDKinect::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_position"), &GDKinect::get_position);
    ClassDB::bind_method(D_METHOD("connected"), &GDKinect::connected);
}

void GDKinect::analyze_square(int i, int j, HandPos& best_pos) {
    int count{0};
    int avg{0};
    uint16_t dat;

    for (int ri{i - SQUARE_SIZE / 2}; ri <= i + SQUARE_SIZE / 2; ri++) {
        for (int rj{j - SQUARE_SIZE / 2}; rj <= j + SQUARE_SIZE / 2; rj++) {
	    dat = depthMat[KINECT_WIDTH * ri + rj];

	    if (dat >= 500 && dat <=1500) {
		avg += static_cast<int>(dat);
		count++;
	    }
	}
    }

    if (count > 0) {
	avg /= count;

	if (avg < best_pos.depth) {
	    // consider what to do when avg=lowest_depth
	    best_pos.x = j;
	    best_pos.y = i;
	    best_pos.depth = avg;
	}
    }

}

std::optional<HandPos> GDKinect::get_hand_pos() {
    kinect_device->get().get_depth(depthMat.get());

    int avg;
    HandPos best;
    int lowest_depth{LOWEST_DEPTH};

    if (SQUARE_SIZE < KINECT_HEIGHT && SQUARE_SIZE < KINECT_WIDTH) {
	int count;
	uint16_t dat;

	// optimization: only search in surroundings of previous position
	if (!hand_pos) {
	    for (int i{SQUARE_SIZE/2}; i < KINECT_HEIGHT - SQUARE_SIZE / 2; i += 4) {
		for (int j{SQUARE_SIZE/2}; j < KINECT_WIDTH - SQUARE_SIZE / 2; j += 4) {
		    analyze_square(i, j, best);
		}
	    }
	} else {
	    for (int i{std::max(SQUARE_SIZE / 2, hand_pos->y - SEARCH_RADIUS)}; i < hand_pos->y + SEARCH_RADIUS && i < KINECT_HEIGHT - SQUARE_SIZE / 2; i += 4) {
		for (int j{std::max(SQUARE_SIZE / 2, hand_pos->x - SEARCH_RADIUS)}; j < hand_pos->x + SEARCH_RADIUS && KINECT_WIDTH - SQUARE_SIZE / 2; j += 4) {
		    analyze_square(i, j, best);
		}
	    }
	}
    }

    if (best.x == -1) hand_pos = {};
    else hand_pos = best;
    return hand_pos;
}

bool GDKinect::connected() {
    return !!kinect_device;
}

