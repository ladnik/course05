#include "gdkinect.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <stdexcept>


using namespace godot;


HandPos::HandPos()
    : x(-1),
    y(-1),
    avg(LOWEST_DEPTH) {}


GDKinect::GDKinect()
    : rgbMatrix(cv::Size(KINECT_WIDTH, KINECT_HEIGHT), CV_8UC3, cv::Scalar(0)),
    depthMatrix(cv::Size(KINECT_WIDTH, KINECT_HEIGHT), CV_16UC1),
    depthf(cv::Size(KINECT_WIDTH, KINECT_HEIGHT), CV_8UC1) {

    try {
	depthDat = std::make_unique<uint16_t[]>(KINECT_HEIGHT * KINECT_WIDTH * sizeof(uint16_t));
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
    if (kinect_device && kinect_device->get().getDepth(depthDat.get())) {
	depthMatrix.data = (uchar*) depthDat.get();
        depthMatrix.convertTo(depthf, CV_8UC1, 255.0/2048.0);
    }

    return depthf;
}

Ref<Texture> GDKinect::get_texture() {
    cv::Mat dst;
    cv::cvtColor(get_depth_matrix(), dst, cv::COLOR_BGR2RGB);
    int sizear = dst.cols * dst.rows * dst.channels();

    std::optional<HandPos> h = get_hand_pos();
    UtilityFunctions::print(h ? h->x : -1);
    UtilityFunctions::print(h ? h->y : -1);
    UtilityFunctions::print(h ? h->avg : -1);

    PackedByteArray bytes;
    bytes.resize(sizear);
    memcpy(bytes.ptrw(), dst.data, sizear);

    Ref<Image> image = Image::create_from_data(dst.cols, dst.rows, false,
				Image::Format::FORMAT_RGB8, bytes);
    return ImageTexture::create_from_image(image);
}

void GDKinect::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_texture"), &GDKinect::get_texture);
}

std::optional<HandPos> GDKinect::get_hand_pos() {
    int avg;
    HandPos best;
    int lowest_depth{LOWEST_DEPTH};
    uint16_t *depthMat = depthDat.get();

    if (SQUARE_SIZE < KINECT_HEIGHT && SQUARE_SIZE < KINECT_WIDTH) {
	int count;
	uint16_t dat;

	// optimization: only search in surroundings of previous position
	if (!hand_pos) {
	    for (int i{SQUARE_SIZE/2}; i < KINECT_HEIGHT - SQUARE_SIZE / 2; i += 4) {
		for (int j{SQUARE_SIZE/2}; j < KINECT_WIDTH - SQUARE_SIZE / 2; j += 4) {
		    count = 0;
		    avg = 0;

		    for (int ri{i - SQUARE_SIZE / 2}; ri <= i + SQUARE_SIZE / 2; ri++) {
			for (int rj{j - SQUARE_SIZE / 2}; rj <= j + SQUARE_SIZE / 2; rj++) {
			    dat = depthMat[KINECT_WIDTH * ri + rj];

			    if (dat >= 500 && dat <=1500) {
				avg += static_cast<int>(dat);
				count++;
			    }
			}
		    }

		    // if (count >= (SQUARE_SIZE) * (SQUARE_SIZE)) {
		    if (count > 0) {
			avg /= count;

			if (avg < lowest_depth) {
			    // consider what to do when avg=lowest_depth
			    lowest_depth = avg;
			    best.x = j;
			    best.y = i;
			    best.avg = avg;
			}
		    }
		}
	    }
	} else {
	    for (int i{std::max(SQUARE_SIZE / 2, hand_pos->y - SEARCH_RADIUS)}; i < hand_pos->y + SEARCH_RADIUS && i < KINECT_HEIGHT - SQUARE_SIZE / 2; i += 4) {
		for (int j{std::max(SQUARE_SIZE / 2, hand_pos->x - SEARCH_RADIUS)}; j < hand_pos->x + SEARCH_RADIUS && KINECT_WIDTH - SQUARE_SIZE / 2; j += 4) {
		    count = 0;
		    avg = 0;

		    for (int ri{i - SQUARE_SIZE / 2}; ri <= i + SQUARE_SIZE / 2; ri++) {
			for (int rj{j - SQUARE_SIZE / 2}; rj <= j + SQUARE_SIZE / 2; rj++) {
			    dat = depthMat[KINECT_WIDTH * ri + rj];

			    if (dat >= 500 && dat <=1500) {
				avg += static_cast<int>(dat);
				count++;
			    }
			}
		    }

		    // if (count >= (SQUARE_SIZE + 1) * (SQUARE_SIZE + 1) * 0.98) {
		    if (count > 0) {
			avg /= count;

			if (avg < lowest_depth) {
			    // consider what to do when avg=lowest_depth
			    lowest_depth = avg;
			    best.x = j;
			    best.y = i;
			    best.avg = avg;
			}
		    }
		}
	    }
	}
    }

    if (best.x == -1) hand_pos = {};
    else hand_pos = best;
    return hand_pos;
}

