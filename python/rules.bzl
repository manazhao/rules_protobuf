load("//protobuf:rules.bzl", "proto_compile")

def py_proto_compile(langs = ["//python"], **kwargs):
  proto_compile(langs = langs, **kwargs)
