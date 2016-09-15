load("@io_bazel_rules_go//go:def.bzl", "go_library")
load("//bzl:base/class.bzl", BASE = "CLASS")
#load("//bzl:proto_compile.bzl", "invokesuper")
load("//bzl:util.bzl", "invokesuper")


def implement_compile_attributes(lang, self):
    """Override attributes for the X_proto_compile rule"""
    invokesuper("implement_compile_attributes", lang, self)

    attrs = self["attrs"]

    # go_prefix is necessary for protoc-gen-go import mapping of dependent protos.
    attrs["go_prefix"] = attr.label(
        providers = ["go_prefix"],
        default = Label(
            "//:go_prefix",
            relative_to_caller_repository = True,
        ),
        allow_files = False,
        cfg = HOST_CFG,
    )

    attrs["go_import_map"] = attr.string_dict()


def build_package_prefix(lang, self):
    ctx = self["ctx"]
    self["prefix"] = ctx.attr.go_prefix.go_prefix
    print("PREFIX: " + self["prefix"])


def get_mappings_for(files, label, prefix):
    """For a set of files that belong the the given context label, create a mapping to the given prefix."""
    mappings = {}
    for file in files:
        src = file.short_path
        # File in an external repo looks like:
        # '../WORKSPACE/SHORT_PATH'.  We want just the SHORT_PATH.
        if src.startswith("../"):
            parts = src.split("/")
            src = "/".join(parts[2:])
        dst = [prefix, label.package]
        name_parts = label.name.split(".")
        # special case to elide last part if the name is
        # 'go_default_library.pb'
        if name_parts[0] != "go_default_library":
            dst.append(name_parts[0])
        mappings[src] = "/".join(dst)

    return mappings


def build_protobuf_out(cls, run, builder):
    """Override behavior to add plugin options before building the --go_out option"""
    ctx = run.ctx
    go_prefix = run.lang.go_prefix

    opts = []
    # Add in the 'plugins=grpc' option to the protoc-gen-go plugin if
    # the user wants grpc.
    if run.with_grpc:
        opts.append("plugins=grpc")

    # Build the list of import mappings.  Start with any configured on
    # the rule by attributes.
    mappings = run.lang.go_importmap
    mappings += get_mappings_for(run.data.protos, run.data.label, go_prefix)

    # Then add in the transitive set from dependent rules. TODO: just
    # pass the import map transitively rather than recomputing it.
    for unit in run.data.transitive_units:
        # Map to this go_prefix if within same workspace, otherwise use theirs.
        prefix = go_prefix if unit.data.workspace_name == run.data.workspace_name else unit.data.prefix
        mappings += get_mappings_for(unit.data.protos, unit.data.label, prefix)

    if run.data.verbose > 1:
        print("go_importmap: %s" % mappings)

    for k, v in mappings.items():
        opts += ["M%s=%s" % (k, v)]

    builder["pb_options"] += opts
    invokesuper(cls, "build_protobuf_out", run, builder)


def build_grpc_out(cls, run, builder):
    """Override behavior to skip the --grpc_out option (protoc-gen-go does not use it)"""
    print("skip grpc out")
    pass


CLASS = struct(
    parent = BASE,
    name = "go",

    protobuf = struct(
        name = 'protoc-gen-go',
        file_extensions = [".pb.go"],
        executable = "@com_github_golang_protobuf//:protoc_gen_go",
        default_options = [],
        requires = [
            "com_github_golang_protobuf",
        ],
        compile_deps = [
            "@com_github_golang_protobuf//:proto",
        ],
    ),

    grpc = struct(
        name = 'grpc',
        default_options = [],
        requires = [
            "com_github_golang_glog",
            "org_golang_google_grpc",
            "org_golang_x_net",
        ],
        compile_deps = [
            "@com_github_golang_protobuf//:proto",
            "@com_github_golang_glog//:go_default_library",
            "@org_golang_google_grpc//:go_default_library",
            "@org_golang_x_net//:context",
        ],
    ),

    build_grpc_out = build_grpc_out,
    build_protobuf_out = build_protobuf_out,
    build_package_prefix = build_package_prefix,
    implement_compile_attributes = implement_compile_attributes,
    library = go_library,
)
