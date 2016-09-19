package(default_visibility = ["//visibility:public"])

load("//bzl:proto_compile.bzl", "proto_compile")
load("//bzl:cpp/rules.bzl", "cc_proto_library")

#load("//bzl:csharp/rules.bzl", "csharp_proto_library")
load("//bzl:go/rules.bzl", "go_proto_library")
load("//bzl:java/rules.bzl", "java_proto_library")
load("//bzl:objc/rules.bzl", "objc_proto_library")
load("//bzl:js/rules.bzl", "js_proto_library")
load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar", "pkg_deb")

filegroup(
    name = "protos",
    srcs = [
        "common.proto",
    ],
)

go_proto_library(
    name = "go_default_library",
    protos = [":protos"],
    verbose = 1,
)

# proto_compile(
#     name = "bufs",
#     protos = [":protos"],
#     langs = [
#         "//bzl/ruby",
#         "//bzl/java",
#         "//bzl/java:nano",
#         "//bzl/python",
#         "//bzl/cpp",
#         "//bzl/objc",
#         "//bzl/js:closure",
#         "//bzl/js:commonjs",
#         "//bzl/grpc_gateway:pb_gateway",
#     ],
#     verbose = 2,
#     with_grpc = True,
# )

cc_proto_library(
    name = "cpp",
    protos = [":protos"],
)

java_proto_library(
    name = "java",
    protos = [":protos"],
    verbose = 0,
)

java_proto_library(
    name = "grpc-java",
    langs = ["//bzl/java:grpc-java"],
    protos = [":protos"],
    verbose = 2,
    with_grpc = True,
)

# objc_proto_library(
#     name = "objc",
#     protos = [":protos"],
#     verbose = 0,
# )

# proto_compile(
#     name = "closure",
#     langs = ["//bzl/js:closure"],
#     protos = [":protos"],
#     verbose = 0,
# )

# proto_compile(
#     name = "closurelib",
#     langs = ["//bzl/js:closure"],
#     protos = [":protos"],
#     verbose = 0,
# )

# proto_compile(
#     name = "commonjs",
#     langs = ["//bzl/js:commonjs"],
#     protos = [":protos"],
#     verbose = 0,
# )

# proto_compile(
#     name = "browser",
#     langs = ["//bzl/js:browser"],
#     protos = [":protos"],
#     verbose = 2,
# )

# proto_compile(
#     name = "objcc",
#     langs = ["//bzl/objc"],
#     protos = [":protos"],
#     verbose = 1,
# )

# proto_compile(
#     name = "csharp",
#     langs = ["//bzl/csharp"],
#     protos = [":protos"],
#     verbose = 1,
# )

proto_compile(
    name = "rb",
    langs = ["//bzl/ruby"],
    protos = [":protos"],
    verbose = 0,
)

# pkg_tar(
#     name = "js_tar",
#     files = [
#         ":closurelib",
#     ],
# )

# csharp_proto_library(
#     name = "cs",
#     protos = [":protos"],
#     verbose = 1,
# )
