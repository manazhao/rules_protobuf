java_test(
    name = "netty_test",
    size = "small",
    srcs = ["HelloWorldClientTest.java"],
    test_class = "org.pubref.rules_protobuf.examples.helloworld.client.HelloWorldClientTest",
    runtime_deps = [
        "//bzl/java:netty_runtime",
    ],
    deps = [
        ":client",
        "//examples/helloworld/java/org/pubref/rules_protobuf/examples/helloworld/server",
        "@junit_junit_4//jar",
    ],
)

java_binary(
    name = "netty",
    main_class = "org.pubref.rules_protobuf.examples.helloworld.client.HelloWorldClient",
    runtime_deps = [
        ":client",
        "//bzl/java:netty_runtime",
    ],
)

java_library(
    name = "client",
    srcs = ["HelloWorldClient.java"],
    deps = [
        "//examples/helloworld/proto:java",
        "//bzl/java:grpc_compiletime",
    ],
)
