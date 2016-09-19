package(default_visibility = ["//visibility:public"])

load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar", "pkg_deb")
load("//protobuf:rules.bzl", "proto_compile")
load("//cpp:rules.bzl", "cc_proto_library")

load("//csharp:rules.bzl", "csharp_proto_compile", "csharp_proto_library")
load("//go:rules.bzl", "go_proto_library")
load("//java:rules.bzl", "java_proto_library")
load("//objc:rules.bzl", "objc_proto_library")
load("//js:rules.bzl", "closure_proto_library")

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
#         "//ruby",
#         "//java",
#         "//java:nano",
#         "//python",
#         "//cpp",
#         "//objc",
#         "//js:closure",
#         "//js:commonjs",
#         "//grpc_gateway:pb_gateway",
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
    langs = ["//java:grpc-java"],
    protos = [":protos"],
    verbose = 2,
    with_grpc = True,
)

objc_proto_library(
     name = "objc",
     protos = [":protos"],
     verbose = 0,
)

# proto_compile(
#     name = "closure",
#     langs = ["//js:closure"],
#     protos = [":protos"],
#     verbose = 0,
# )

# proto_compile(
#     name = "closurelib",
#     langs = ["//js:closure"],
#     protos = [":protos"],
#     verbose = 0,
# )

# proto_compile(
#     name = "commonjs",
#     langs = ["//js:commonjs"],
#     protos = [":protos"],
#     verbose = 0,
# )

# proto_compile(
#     name = "browser",
#     langs = ["//js:browser"],
#     protos = [":protos"],
#     verbose = 2,
# )

# proto_compile(
#     name = "objcc",
#     langs = ["//objc"],
#     protos = [":protos"],
#     verbose = 1,
# )

# proto_compile(
#     name = "csharp",
#     langs = ["//csharp"],
#     protos = [":protos"],
#     verbose = 1,
# )

proto_compile(
    name = "rb",
    langs = ["//ruby"],
    protos = [":protos"],
    verbose = 0,
)

# pkg_tar(
#     name = "js_tar",
#     files = [
#         ":closurelib",
#     ],
# )

csharp_proto_compile(
    name = "cs",
    protos = [":protos"],
    verbose = 2,
)

csharp_proto_library(
    name = "cslib",
    protos = [":protos"],
    verbose = 2,
)
