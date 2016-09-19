load("@io_bazel_rules_closure//closure:defs.bzl", "closure_js_library")
load("//protobuf:rules.bzl",
     "proto_compile",
     "proto_language_deps",
     "proto_repositories")

def js_proto_repositories(
    lang_requires = [

    ],
    **kwargs):
  proto_repositories(lang_requires = lang_requires, **kwargs)

def closure_proto_compile(langs = ["//js:closure"], **kwargs):
  proto_compile(langs = langs, **kwargs)

def commonjs_proto_compile(langs = ["//js:commonjs"], **kwargs):
  proto_compile(langs = langs, **kwargs)

def closure_proto_library(
    name,
    langs = ["//js:closure"],
    protos = [],
    imports = [],
    inputs = [],
    output_to_workspace = False,
    proto_deps = [
      "@io_bazel_rules_closure//closure/protobuf:jspb",
    ],
    protoc = None,
    pb_plugin = None,
    pb_options = [],
    proto_compile_args = {},
    srcs = [],
    deps = [],
    verbose = 0,
    **kwargs):

  proto_compile_args += {
    "name": name + ".pb",
    "protos": protos,
    "deps": [dep + ".pb" for dep in proto_deps],
    "langs": langs,
    "imports": imports,
    "inputs": inputs,
    "pb_options": pb_options,
    "output_to_workspace": output_to_workspace,
    "verbose": verbose,
  }

  if protoc:
    proto_compile_args["protoc"] = protoc
  if pb_plugin:
    proto_compile_args["pb_plugin"] = pb_plugin

  proto_compile(**proto_compile_args)

  proto_language_deps(
    name = name + "_compile_deps",
    langs = langs,
    file_extensions = [".js"],
  )

  closure_js_library(
    name = name,
    proto_descriptor_set2 = [name + ".pb.descriptor_set"],
    srcs = srcs + [name + ".pb"] + [name + "_compile_deps"],
    deps = list(set(deps + proto_deps)),
    **kwargs)

def commonjs_proto_library(langs = [""], **kwargs):
  js_proto_library(langs = langs, **kwargs)
