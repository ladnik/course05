#ifndef CUSOTM_FREENECT_DEVICE_H
#define CUSOTM_FREENECT_DEVICE_H

#include <libfreenect/libfreenect.hpp>
#include <opencv2/opencv.hpp>
#include <vector>
#include <mutex>

namespace godot {

class CustomFreenectDevice : public Freenect::FreenectDevice {
    public:
    CustomFreenectDevice(freenect_context* _ctx, int _index);

    void VideoCallback(void* _rgb, uint32_t /* timestamp */);
    void DepthCallback(void* _depth, uint32_t /* timestamp */);

    bool getVideo(cv::Mat& output);
    bool getDepth(cv::Mat& otuput);

    private:
    std::vector<uint8_t> m_buffer_depth;
    std::vector<uint8_t> m_buffer_rgb;
    std::vector<uint16_t> m_gamma;
    cv::Mat depthMat;
    cv::Mat rgbMat;
    cv::Mat ownMat;
    bool m_new_rgb_frame;
    bool m_new_depth_frame;
    std::mutex m_rgb_mutex;
    std::mutex m_depth_mutex;
};

}

#endif

