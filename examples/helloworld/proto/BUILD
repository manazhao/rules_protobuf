package(default_visibility = ["//visibility:public"])

load("//bzl:cpp/rules.bzl", "cc_proto_library")
load("//bzl:go/rules.bzl", "go_proto_library")
load("//bzl:java/rules.bzl", "java_proto_library")
load("//bzl:proto_compile.bzl", "proto_compile")

filegroup(
    name = "protos",
    srcs = ["helloworld.proto"],
)

# proto_compile(
#     name = "bufs",
#     protos = [":protos"],
#     deps = ["//examples/proto:bufs"],
#     langs = [
#         "//bzl/ruby",
#         "//bzl/java",
#         "//bzl/python",
#         "//bzl/cpp",
#     ],
# )

go_proto_library(
    name = "go",
    proto_deps = [
        "//examples/proto:go_default_library",
    ],
    protos = [":protos"],
    verbose = 1,
    with_grpc = True,
)

cc_proto_library(
    name = "cpp",
    proto_deps = [
        "//examples/proto:cpp",
    ],
    protos = [":protos"],
    verbose = 0,
    with_grpc = True,
)

java_proto_library(
    name = "java",
    output_to_workspace = False,
    proto_deps = [
        "//examples/proto:java",
    ],
    protos = [":protos"],
    with_grpc = True,
)

# proto_compile(
#     name = "closure",
#     langs = [
#         "//bzl/js:closure"
#     ],
#     deps = [
#         "//examples/proto:closure",
#     ],
#     protos = [":protos"],
#     verbose = 1,
# )

proto_compile(
    name = "py",
    langs = ["//bzl/python"],
    output_to_workspace = False,
    protos = [":protos"],
    with_grpc = False,
)

proto_compile(
    name = "ruby",
    langs = ["//bzl/ruby"],
    output_to_workspace = False,
    protos = [":protos"],
    with_grpc = False,
)
