#include "gdkinect.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <stdexcept>

#define KINECT_WIDTH 640
#define KINECT_HEIGHT 480

using namespace godot;


GDKinect::GDKinect()
    : rgbMatrix(cv::Size(KINECT_WIDTH, KINECT_HEIGHT), CV_8UC3, cv::Scalar(0)),
    depthMatrix(cv::Size(KINECT_WIDTH, KINECT_HEIGHT), CV_16UC1),
    depthf(cv::Size(KINECT_WIDTH, KINECT_HEIGHT), CV_8UC1) {

    try {
	kinect_device = freenect.createDevice<CustomFreenectDevice>(0);
	kinect_device->get().startVideo();
	kinect_device->get().startDepth();
	UtilityFunctions::print("Started Kinect RGB and depth video");
    } catch (std::runtime_error &e) {
	UtilityFunctions::print(e.what());
    }
}

GDKinect::~GDKinect() {
    if (kinect_device) {
	kinect_device->get().stopVideo();
	kinect_device->get().stopDepth();
    }
    UtilityFunctions::print("Stopped Kinect RGB and depth video");
}

cv::Mat& GDKinect::get_rgb_matrix() {
    if (kinect_device) kinect_device->get().getVideo(rgbMatrix);
    return rgbMatrix;
}

cv::Mat& GDKinect::get_depth_matrix() {
    if (kinect_device && kinect_device->get().getDepth(depthMatrix)) {
        depthMatrix.convertTo(depthf, CV_8UC1, 255.0/2048.0);
    }

    return depthf;
}

Ref<Texture> GDKinect::get_texture() {
    cv::Mat rgbMatCopy;
    cv::cvtColor(get_rgb_matrix(), rgbMatCopy, cv::COLOR_BGR2RGB);
    int sizear = rgbMatCopy.cols * rgbMatCopy.rows * rgbMatCopy.channels();

    PackedByteArray bytes;
    bytes.resize(sizear);
    memcpy(bytes.ptrw(), rgbMatCopy.data, sizear);

    Ref<Image> image = Image::create_from_data(rgbMatCopy.cols, rgbMatCopy.rows, false,
				Image::Format::FORMAT_RGB8, bytes);
    return ImageTexture::create_from_image(image);
}

void GDKinect::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_texture"), &GDKinect::get_texture);
}
