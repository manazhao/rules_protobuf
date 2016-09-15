package(default_visibility = ["//visibility:public"])

load("//bzl:proto_language.bzl", "proto_language")

proto_language(
    name = "java",
    pb_file_extensions = [],
    output_to_jar = True,
    supports_grpc = True,
    grpc_plugin = "//third_party/protoc_gen_grpc_java:protoc_gen_grpc_java_bin",
    pb_compile_deps = [
        "@com_google_guava_guava//jar",
        "@com_google_protobuf_protobuf_java//jar",
    ],
    grpc_compile_deps = [
        "@io_grpc_grpc_core//jar",
        "@io_grpc_grpc_protobuf//jar",
        "@io_grpc_grpc_stub//jar",
    ],
)

# load("//bzl:protoc.bzl", "proto_language")

# proto_language(
#     name = "java",
#     extends = "base",
#     templates = [
#         "//bzl:proto_compile.tpl",
#     ],
#     pb_file_extensions = [".srcjar"],
#     output_to_jar = True,
#     supports_pb = True,
#     pb_compile_deps = [
#         "@com_google_guava_guava//jar",
#         "@com_google_protobuf_protobuf_java//jar",
#     ],
#     supports_grpc = True,
#     grpc_plugin = "//third_party/protoc_gen_grpc_java:protoc_gen_grpc_java_bin",
#     grpc_compile_deps = [
#         "@com_google_guava_guava//jar",
#         "@com_google_protobuf_protobuf_java//jar",
#         "@io_grpc_grpc_core//jar",
#         "@io_grpc_grpc_protobuf//jar",
#         "@io_grpc_grpc_stub//jar",
#     ],
#     grpc_runtime_deps = [
#         "@io_grpc_grpc_netty//jar",
#         "@io_grpc_grpc_protobuf_lite//jar",
#         "@io_netty_netty_buffer//jar",
#         "@io_netty_netty_codec//jar",
#         "@io_netty_netty_codec_http2//jar",
#         "@io_netty_netty_common//jar",
#         "@io_netty_netty_handler//jar",
#         "@io_netty_netty_resolver//jar",
#         "@io_netty_netty_transport//jar",
#     ],

#     build_generated_files =
# """
#    pass
# """
# )
