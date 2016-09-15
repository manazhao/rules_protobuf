load("//bzl:base/rules.bzl", "proto_library")
load("//bzl:java/class.bzl", JAVA = "CLASS")
load("//bzl:protoc.bzl", "implement")
load("//bzl:proto_compile.bzl", "proto_compile")

SPEC = [JAVA]

java_proto_compile = implement(SPEC)

def java_proto_library(name, **kwargs):
  proto_library(name,
                proto_compile = java_proto_compile,
                spec = SPEC,
                **kwargs)

# def java_proto_library2(name,
#                       lang = ["//bzl/cpp"],
#                       protos = [],
#                       imports = [],
#                       inputs = [],
#                       proto_deps = [],
#                       protoc = None,

#                       pb_plugin = None,
#                       pb_options = [],

#                       grpc_plugin = None,
#                       grpc_options = [],

#                       proto_compile_args = {},
#                       with_grpc = True,
#                       srcs = [],
#                       deps = [],
#                       **kwargs):

#   compile_deps = JAVA.pb_compile_deps
#   if with_grpc:
#     compile_deps += JAVA.grpc_compile_deps

#   proto_compile_args += {
#     "name": name + ".pb",
#     "protos": protos,
#     "deps": proto_deps,
#     "lang": lang,
#     "imports": imports,
#     "inputs": inputs,
#     "pb_options": pb_options,
#     "grpc_options": grpc_options,
#   }

#   if protoc:
#     proto_compile_args["protoc"] = protoc
#   if pb_plugin:
#     proto_compile_args["pb_plugin"] = pb_plugin
#   if grpc_plugin:
#     proto_compile_args["grpc_plugin"] = pb_plugin

#   proto_compile(**proto_compile_args)

#   native.cc_library(
#     name = name,
#     srcs = srcs + [name + ".pb"],
#     deps = list(set(deps + compile_deps)),
#     **kwargs)
