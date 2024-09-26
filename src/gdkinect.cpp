#include "gdkinect.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;


GDKinect::GDKinect() {
    UtilityFunctions::print("Constructed GDKinect");
}

GDKinect::~GDKinect() {
    UtilityFunctions::print("Destructed GDKinect");
}

void GDKinect::_bind_methods() {
}
