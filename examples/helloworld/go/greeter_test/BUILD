package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_go//go:def.bzl", "go_test")
load(
    "//bzl:go/class.bzl",
    GO = "CLASS",
)

go_test(
    name = "greeter_test",
    size = "small",
    srcs = ["greeter_test.go"],
    deps = [
        "//examples/helloworld/proto:go",
        "//examples/helloworld/go/server:greeter",
    ] + GO.grpc.compile_deps,
)
