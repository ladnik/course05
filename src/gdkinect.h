#ifndef GDKINECT_H
#define GDKINECT_H

#include <godot_cpp/classes/resource.hpp>
#include "libfreenect/libfreenect.hpp"

namespace godot {

class GDKinect : public Resource {
    GDCLASS(GDKinect, Resource)

    public:
    GDKinect();
    ~GDKinect();

    protected:
    static void _bind_methods();

    private:
    Freenect::Freenect freenect;
};

}

#endif
