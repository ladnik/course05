#ifndef GDKINECT_H
#define GDKINECT_H

#include "custom_freenect_device.h"
#include <functional>
#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/classes/texture.hpp>
#include <godot_cpp/classes/image.hpp>
#include <godot_cpp/classes/image_texture.hpp>
#include "libfreenect/libfreenect.hpp"
#include <opencv2/opencv.hpp>
#include <functional>
#include <optional>

namespace godot {

class GDKinect : public Resource {
    GDCLASS(GDKinect, Resource)

    public:
    GDKinect();
    ~GDKinect();

    Ref<Texture> get_texture();

    protected:
    static void _bind_methods();

    private:
    cv::Mat& get_rgb_matrix();
    cv::Mat& get_depth_matrix();

    Freenect::Freenect freenect;
    std::optional<std::reference_wrapper<CustomFreenectDevice>> kinect_device;
    cv::Mat rgbMatrix;
    cv::Mat depthMatrix;
    cv::Mat depthf;
};

}

#endif

