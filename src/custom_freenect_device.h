#ifndef CUSOTM_FREENECT_DEVICE_H
#define CUSOTM_FREENECT_DEVICE_H

#include <libfreenect.hpp>
#include <opencv2/opencv.hpp>
#include <vector>
#include <mutex>
#include <optional>

namespace godot {


class CustomFreenectDevice : public Freenect::FreenectDevice {
    public:
    CustomFreenectDevice(freenect_context* _ctx, int _index);

    void VideoCallback(void* _rgb, uint32_t /* timestamp */);
    void DepthCallback(void* _depth, uint32_t /* timestamp */);

    bool get_depth(uint16_t *otuput);

    private:
    uint16_t *depthMat;

    bool m_new_depth_frame;
    std::mutex m_depth_mutex;
};

}

#endif

