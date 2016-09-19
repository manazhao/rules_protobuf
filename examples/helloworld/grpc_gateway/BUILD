package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_test")

# load(
#     "//bzl:grpc_gateway/class.bzl",
#     GRPC_GATEWAY = "CLASS",
#     GRPC_SWAGGER = "SWAGGER",
# )

load("//bzl:proto_compile.bzl", "proto_compile")
load(
    "//bzl:grpc_gateway/rules.bzl",
    "grpc_gateway_library",
    "grpc_gateway_binary",
    "GRPC_GATEWAY_DEPS",
)

# grpc_gateway_library(
#     name = "grpc_gateway",
#     protos = ["helloworld.proto"],
#     verbose = 2,
# )

# grpc_gateway_proto_library(
#     name = "gateway",
#     output_to_workspace = False,
#     protos = ["helloworld.proto"],
#     verbose = 1,
# )

# grpc_gateway_swagger_compile(
#     name = "swagger",
#     output_to_workspace = False,
#     protos = ["helloworld.proto"],
#     verbose = 1,
# )

grpc_gateway_binary(
    name = "greeter",
    srcs = ["greeter.go"],
    proto_label = "gateway",
    protos = ["helloworld.proto"],
    verbose = 2,
)

go_test(
    name = "greeter_test",
    size = "small",
    srcs = [
        "greeter.go",
        "greeter_test.go",
    ],
    deps = [
        ":gateway",
        "//examples/helloworld/go/server:greeter",
        "//examples/helloworld/proto:go",
        "@com_github_golang_protobuf//:jsonpb",
    ] + GRPC_GATEWAY_DEPS,
)
