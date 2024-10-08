#!/usr/bin/env python
import os

def normalize_path(val, env):
    return val if os.path.isabs(val) else os.path.join(env.Dir("#").abspath, val)

def validate_parent_dir(key, val, env):
    if not os.path.isdir(normalize_path(os.path.dirname(val), env)):
        raise ValueError("'%s' is not a directory: %s" % (key, os.path.dirname(val)))

libnames = ["liba", "libb", "libpartsim"] # add additional libraries here
projectdir = "project"

localEnv = Environment(tools=["default"], PLATFORM="")

customs = ["custom.py"]
customs = [os.path.abspath(path) for path in customs]

opts = Variables(customs, ARGUMENTS)
opts.Add(
    BoolVariable(
        key="compiledb",
        help="Generate compilation DB (`compile_commands.json`) for external tools",
        default=localEnv.get("compiledb", False),
    )
)
opts.Add(
    PathVariable(
        key="compiledb_file",
        help="Path to a custom `compile_commands.json` file",
        default=localEnv.get("compiledb_file", "compile_commands.json"),
        validator=validate_parent_dir,
    )
)
opts.Update(localEnv)
Help(opts.GenerateHelpText(localEnv))

env = localEnv.Clone()
env["compiledb"] = False

env.Tool("compilation_db")
compilation_db = env.CompilationDatabase(
    normalize_path(localEnv["compiledb_file"], localEnv)
)
env.Alias("compiledb", compilation_db)

env = SConscript("godot-cpp/SConstruct", {"env": env, "customs": customs})

env.Append(CPPPATH=["src/"])
sources = Glob("src/*.cpp")

targetPath = "{}/bin/".format(projectdir)

for libname in libnames:
    file = "{}{}{}".format(libname, env["suffix"], env["SHLIBSUFFIX"])
    print(f"Building file {file}")

    libraryfile = "{}/{}".format(targetPath, file)
    library = env.SharedLibrary(
        libraryfile,
        source=sources,
    )
    print(f"Installing as {projectdir}/bin/lib{file}")
    copy = env.InstallAs("{}/bin/lib{}".format(projectdir, file), library)

    default_args = [library, copy]
    if localEnv.get("compiledb", False):
        default_args += [compilation_db]
    Default(*default_args)
