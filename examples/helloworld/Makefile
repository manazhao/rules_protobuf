BAZEL_BIN := $(shell bazel info bazel-bin)
JAVA_SOURCE_PATH := "java/org/pubref/rules_protobuf/examples/helloworld"
GO_SOURCE_PATH := "go"

# The java examples could also be run with 'bazel run ...', but the
# point is to demonstrate how to run it as an executable jar.
java_server:
	bazel build $(JAVA_SOURCE_PATH)/server:netty_deploy.jar && \
	java -jar $(BAZEL_BIN)/examples/helloworld/$(JAVA_SOURCE_PATH)/server/netty_deploy.jar

java_client:
	bazel build $(JAVA_SOURCE_PATH)/client:netty_deploy.jar && \
	java -jar $(BAZEL_BIN)/examples/helloworld/$(JAVA_SOURCE_PATH)/client/netty_deploy.jar

go_client:
	bazel run go/client

go_server:
	bazel build go/server && $(BAZEL_BIN)/examples/helloworld/go/server/server

cpp_server:
	bazel build cpp/server && $(BAZEL_BIN)/examples/helloworld/cpp/server

cpp_client:
	bazel run cpp/client

grpc_gateway:
	bazel build go/gateway:greeter && $(BAZEL_BIN)/examples/helloworld/go/gateway/greeter

curl_gateway:
	curl -X POST -k http://localhost:8080/v1/helloworld/sayhello -d '{"name": "gRPC-gateway!"}'
