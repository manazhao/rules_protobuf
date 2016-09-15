load("//bzl:base/rules.bzl", "proto_library")
load("//bzl:cpp/class.bzl", CPP = "CLASS")
load("//bzl:protoc.bzl", "implement")

SPEC = [CPP]

cc_proto_compile = implement(SPEC)

def cc_proto_library(name, **kwargs):
  proto_library(name,
                proto_compile = cc_proto_compile,
                spec = SPEC,
                **kwargs)

def cpp_proto_library(name,
                      protos = [],
                      imports = [],
                      proto_deps = [],
                      protoc = None,
                      pb_plugin = None,
                      pb_options = [],
                      lang = ["//bzl/cpp"],
                      srcs = [],
                      deps = [],
                      **kwargs):

  proto_library(name,
                proto_compile = cc_proto_compile,
                spec = SPEC,
                **kwargs)
