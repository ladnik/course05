#include "custom_freenect_device.h"
#include <godot_cpp/variant/utility_functions.hpp>

#define LOWEST_DEPTH 5000
#define KINECT_WIDTH 640
#define KINECT_HEIGHT 480
#define SQUARE_SIZE 30
#define SEARCH_RADIUS 15

using namespace godot;

CustomFreenectDevice::CustomFreenectDevice(freenect_context *_ctx, int _index)
    : Freenect::FreenectDevice(_ctx, _index),
    m_new_depth_frame(false) {}

void CustomFreenectDevice::VideoCallback(void* _rgb, uint32_t timestamp) {
    // we don't use the video so do nothing
}

void CustomFreenectDevice::DepthCallback(void* _depth, uint32_t timestamp) {
    std::unique_lock lock{m_depth_mutex};
    uint16_t *depth = static_cast<uint16_t*>(_depth);
    depthMat = static_cast<uint16_t*>(_depth);
    m_new_depth_frame = true;
}

bool CustomFreenectDevice::get_depth(uint16_t *output) {
    std::unique_lock lock{m_depth_mutex};

    if(m_new_depth_frame) {
	std::memcpy(output, depthMat, KINECT_WIDTH * KINECT_HEIGHT * sizeof(uint16_t));
	m_new_depth_frame = false;
	return true;
    }

    return false;
}

