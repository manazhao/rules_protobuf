package(default_visibility = ["//visibility:public"])

java_test(
    name = "netty_test",
    size = "small",
    srcs = ["HelloWorldServerTest.java"],
    tags = ["exclusive"],  # Address already in use if another server being tested has same port
    test_class = "org.pubref.rules_protobuf.examples.helloworld.server.HelloWorldServerTest",
    runtime_deps = [
        "//bzl/java:netty_runtime",
    ],
    deps = [
        ":server",
        "@junit_junit_4//jar",
    ],
)

java_binary(
    name = "netty",
    main_class = "org.pubref.rules_protobuf.examples.helloworld.server.HelloWorldServer",
    runtime_deps = [
        ":server",
        "//bzl/java:netty_runtime",
    ],
)

java_library(
    name = "server",
    srcs = ["HelloWorldServer.java"],
    deps = [
        "//bzl/java:grpc_compiletime",
        "//examples/helloworld/proto:java",
    ],
)
