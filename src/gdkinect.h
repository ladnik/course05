#ifndef GDKINECT_H
#define GDKINECT_H

#include "custom_freenect_device.h"
#include <functional>
#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/classes/texture.hpp>
#include <godot_cpp/classes/image.hpp>
#include <godot_cpp/classes/image_texture.hpp>
#include "libfreenect.hpp"
#include <opencv2/opencv.hpp>
#include <functional>
#include <optional>


namespace godot {

struct HandPos {
    int x;
    int y;
    int depth;

    HandPos();
};

class GDKinect : public Resource {
    GDCLASS(GDKinect, Resource)

    public:
    GDKinect();
    ~GDKinect();

    Vector2 get_position();
    bool connected();

    protected:
    static void _bind_methods();

    private:
    void analyze_square(int i, int j, HandPos& best_pos);
    std::optional<HandPos> get_hand_pos();

    Freenect::Freenect freenect;
    std::optional<std::reference_wrapper<CustomFreenectDevice>> kinect_device;
    std::unique_ptr<uint16_t[]> depthMat;
    std::optional<HandPos> hand_pos;
};

}

#endif

