load("//bzl:base/rules.bzl", "proto_library")
load("//bzl:gogo/class.bzl", GOGO = "CLASS")
load("//bzl:protoc.bzl", "implement")

SPEC = [GOGO]

gogo_proto_compile = implement(SPEC)

def gogo_proto_library(name, go_import_map = {}, proto_compile_args = {}, **kwargs):
  proto_library(name,
                proto_compile = gogo_proto_compile,
                proto_compile_args = {
                  "go_import_map": go_import_map,
                } + proto_compile_args,
                spec = SPEC,
                **kwargs)
