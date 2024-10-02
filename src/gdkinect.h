#ifndef GDKINECT_H
#define GDKINECT_H

#include "custom_freenect_device.h"
#include <cstdint>
#include <functional>
#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/classes/texture.hpp>
#include <godot_cpp/classes/image.hpp>
#include <godot_cpp/classes/image_texture.hpp>
#include "libfreenect.hpp"
#include <opencv2/opencv.hpp>
#include <functional>
#include <optional>


#define LOWEST_DEPTH 5000
#define KINECT_WIDTH 640
#define KINECT_HEIGHT 480
#define SQUARE_SIZE 30
#define SEARCH_RADIUS 30


namespace godot {

struct HandPos {
    int x;
    int y;
    int avg;

    HandPos();
};

class GDKinect : public Resource {
    GDCLASS(GDKinect, Resource)

    public:
    GDKinect();
    ~GDKinect();

    Ref<Texture> get_texture();
    Vector2 get_position();

    protected:
    static void _bind_methods();

    private:
    cv::Mat& get_rgb_matrix();
    cv::Mat& get_depth_matrix();
    std::optional<HandPos> get_hand_pos();

    Freenect::Freenect freenect;
    std::optional<std::reference_wrapper<CustomFreenectDevice>> kinect_device;
    cv::Mat rgbMatrix;
    std::unique_ptr<uint16_t[]> depthDat;
    cv::Mat depthMatrix;
    cv::Mat depthf;
    std::optional<HandPos> hand_pos;
};

}

#endif

