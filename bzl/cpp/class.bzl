load("//bzl:base/class.bzl", BASE = "CLASS")

PB_COMPILE_DEPS = [
    "//external:protobuf_clib",
]

GRPC_COMPILE_DEPS = PB_COMPILE_DEPS + [
    "@com_github_grpc_grpc//:grpc++",
]

CLASS = struct(
    parent = BASE,
    name = "cpp",

    # cc_*.pb.* outputs need to output to genfiles (not binfiles)
    # for some reason.  Mentioned in
    # http://bazel.io/docs/skylark/lib/globals.html#rule.output_to_genfiles.
    output_to_genfiles = True,

    protobuf = struct(
        file_extensions = [".pb.h", ".pb.cc"],
        compile_deps = [
            "//external:protobuf_clib",
        ],

        # gtest not a protobuf dependency but needed for our
        # internal tests.  Clean this up.
        requires = [
            "protobuf",
            "external_protobuf_clib",
            "gtest",
        ],
    ),

    grpc = struct(
        executable = "//external:protoc_gen_grpc_cpp",
        name = "protoc-gen-grpc",
        file_extensions = [".grpc.pb.h", ".grpc.pb.cc"],
        requires = [
            "grpc",
            "zlib",
            "external_zlib",
            "nanopb",
            "external_nanopb",
            "boringssl",
            "libssl",
            "external_protobuf_compiler",
            "third_party_protoc",
            "external_protoc_gen_grpc_cpp",
        ],
        compile_deps = [
            "//external:protobuf_clib",
            '@com_github_grpc_grpc//:grpc++',
        ],
    ),

    library = native.cc_library,
)
