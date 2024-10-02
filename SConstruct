#!/usr/bin/env python
import os
import sys
import subprocess

env = SConscript("godot-cpp/SConstruct")

# For reference:
# - CCFLAGS are compilation flags shared between C and C++
# - CFLAGS are for C-specific compilation flags
# - CXXFLAGS are for C++-specific compilation flags
# - CPPFLAGS are for pre-processor flags
# - CPPDEFINES are for pre-processor defines
# - LINKFLAGS are for linking flags

opencv_libraries = ["opencv_core", "opencv_imgproc"]

env.Append(CPPPATH=["src/", "/usr/include/libusb-1.0", "/usr/include/opencv4", "/usr/local/include/opencv4", "/usr/local/opencv4", "libfreenect/include", "libfreenect/wrappers/cpp", "opencv/include"])
env.Append(CPPFLAGS=["-fexceptions"])
env.Append(LIBS=["freenect"] + opencv_libraries)
env.Append(LIBPATH=["project/bin"])
sources = Glob("src/*.cpp")

if env["platform"] == "macos":
    library = env.SharedLibrary(
        "project/bin/libgdkinect.{}.{}.framework/libgdkinect.{}.{}".format(
            env["platform"], env["target"], env["platform"], env["target"]
        ),
        source=sources,
    )
elif env["platform"] == "ios":
    if env["ios_simulator"]:
        library = env.StaticLibrary(
            "project/bin/libgdkinect.{}.{}.simulator.a".format(env["platform"], env["target"]),
            source=sources,
        )
    else:
        library = env.StaticLibrary(
            "project/bin/libgdkinect.{}.{}.a".format(env["platform"], env["target"]),
            source=sources,
        )
else:
    library = env.SharedLibrary(
        "project/bin/libgdkinect{}{}".format(env["suffix"], env["SHLIBSUFFIX"]),
        source=sources,
    )

Default(library)
