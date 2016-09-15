#load("//bzl:base/rules.bzl", "proto_library")
load("//bzl:proto_compile.bzl", "proto_compile")
load("//bzl:cpp/class.bzl", CPP = "CLASS", "PB_COMPILE_DEPS", "GRPC_COMPILE_DEPS")
#load("//bzl:protoc.bzl", "implement")

# SPEC = [CPP]

# cc_proto_compile = implement(SPEC)

# def cc_proto_library(name, **kwargs):
#   proto_library(name,
#                 proto_compile = cc_proto_compile,
#                 spec = SPEC,
#                 **kwargs)

def cc_proto_library(name,
                      lang = ["//bzl/cpp"],
                      protos = [],
                      imports = [],
                      inputs = [],
                      proto_deps = [],
                      protoc = None,

                      pb_plugin = None,
                      pb_options = [],

                      grpc_plugin = None,
                      grpc_options = [],

                      proto_compile_args = {},
                      with_grpc = True,
                      srcs = [],
                      deps = [],
                      verbose = 0,
                      **kwargs):

  if with_grpc:
    compile_deps = GRPC_COMPILE_DEPS
  else:
    compile_deps = PB_COMPILE_DEPS

  proto_compile_args += {
    "name": name + ".pb",
    "protos": protos,
    "deps": [dep + ".pb" for dep in proto_deps],
    "lang": lang,
    "imports": imports,
    "inputs": inputs,
    "pb_options": pb_options,
    "grpc_options": grpc_options,
    "verbose": verbose,
  }

  if protoc:
    proto_compile_args["protoc"] = protoc
  if pb_plugin:
    proto_compile_args["pb_plugin"] = pb_plugin
  if grpc_plugin:
    proto_compile_args["grpc_plugin"] = pb_plugin

  proto_compile(**proto_compile_args)

  native.cc_library(
    name = name,
    srcs = srcs + [name + ".pb"],
    deps = list(set(deps + proto_deps + compile_deps)),
    **kwargs)
