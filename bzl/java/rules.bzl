load("//bzl:proto_compile.bzl", "proto_compile")

def _java_proto_language_compile_jars_impl(ctx):
  files = []

  for dep in ctx.attr.lang:
    lang = dep.proto_language
    files += lang.pb_compile_deps
    if lang.supports_grpc and ctx.attr.with_grpc:
      files += lang.grpc_compile_deps

  jars = [file for file in files if file.path.endswith(".jar")]

  return struct(
    files = set(jars),
  )

java_proto_language_compile_jars = rule(
  implementation = _java_proto_language_compile_jars_impl,
  attrs = {
    "lang": attr.label_list(
      providers = ["proto_language"],
      mandatory = True,
    ),
    "with_grpc": attr.bool(default = True),
  }
)
"""Aggregates the jar files named in pb_ and grpc_ proto_languages.
"""

def java_proto_library(
    name,
    lang = ["//bzl/java"],
    protos = [],
    imports = [],
    inputs = [],
    output_to_workspace = False,
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

  proto_compile_args += {
    "name": name + ".pb",
    "protos": protos,
    "deps": [dep + ".pb" for dep in proto_deps],
    "lang": lang,
    "imports": imports,
    "inputs": inputs,
    "pb_options": pb_options,
    "grpc_options": grpc_options,
    "output_to_workspace": output_to_workspace,
    "verbose": verbose,
  }

  if protoc:
    proto_compile_args["protoc"] = protoc
  if pb_plugin:
    proto_compile_args["pb_plugin"] = pb_plugin
  if grpc_plugin:
    proto_compile_args["grpc_plugin"] = pb_plugin

  proto_compile(**proto_compile_args)

  java_proto_language_compile_jars(
    name = name + "_compile_jars",
    lang = lang,
    with_grpc = with_grpc,
  )

  native.java_import(
    name = name + "_compile_imports",
    jars = [name + "_compile_jars"],
  )

  native.java_library(
    name = name,
    srcs = srcs + [name + ".pb"],
    deps = list(set(deps + proto_deps + [name + "_compile_imports"])),
    **kwargs)
