load("//bzl:proto_compile.bzl", "proto_compile")
load("//bzl:proto_language.bzl", "proto_language_deps")
load("//bzl:proto_repositories.bzl", "proto_repositories")
load("@io_bazel_rules_closure//closure:defs.bzl", "closure_js_library")

def js_proto_repositories(
    lang_requires = [],
    **kwargs):
  proto_repositories(lang_requires = lang_requires, **kwargs)


def js_proto_library(
    name,
    langs = ["//bzl/js:closure"],
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
