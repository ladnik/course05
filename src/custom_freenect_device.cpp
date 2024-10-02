#include "custom_freenect_device.h"
#include <cstdint>
#include <godot_cpp/variant/utility_functions.hpp>

#define LOWEST_DEPTH 5000
#define KINECT_WIDTH 640
#define KINECT_HEIGHT 480
#define SQUARE_SIZE 30
#define SEARCH_RADIUS 15

using namespace godot;

CustomFreenectDevice::CustomFreenectDevice(freenect_context *_ctx, int _index)
    : Freenect::FreenectDevice(_ctx, _index),
    m_buffer_depth(FREENECT_DEPTH_11BIT),
    m_buffer_rgb(FREENECT_VIDEO_RGB),
    m_gamma(2048),
    m_new_rgb_frame(false),
    m_new_depth_frame(false),
    rgbMat(cv::Size(640, 480), CV_8UC3, cv::Scalar(0)),
    ownMat(cv::Size(640, 480), CV_8UC3, cv::Scalar(0)) {

    for (unsigned int i{0}; i < 2048; i++) {
	float v = i/2048.0;
	v = std::pow(v, 3) * 6;
	m_gamma[i] = v*6*256;
    }
}

void CustomFreenectDevice::VideoCallback(void* _rgb, uint32_t timestamp) {
    std::unique_lock lock{m_rgb_mutex};
    uint8_t* rgb = static_cast<uint8_t*>(_rgb);
    rgbMat.data = rgb;
    m_new_rgb_frame = true;
}

void CustomFreenectDevice::DepthCallback(void* _depth, uint32_t timestamp) {
    std::unique_lock lock{m_depth_mutex};
    uint16_t *depth = static_cast<uint16_t*>(_depth);
    depthMat = static_cast<uint16_t*>(_depth);
    m_new_depth_frame = true;
}

bool CustomFreenectDevice::getVideo(cv::Mat& output) {
    std::unique_lock lock{m_rgb_mutex};

    if (m_new_rgb_frame) {
	cv::cvtColor(rgbMat, output, cv::COLOR_RGB2BGR);
	m_new_rgb_frame = false;
	return true;
    }

    return false;
}

bool CustomFreenectDevice::getDepth(uint16_t *output) {
    std::unique_lock lock{m_depth_mutex};

    if(m_new_depth_frame) {
	std::memcpy(output, depthMat, KINECT_WIDTH * KINECT_HEIGHT * sizeof(uint16_t));
	m_new_depth_frame = false;
	return true;
    }

    return false;
}

