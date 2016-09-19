load("@io_bazel_rules_dotnet//dotnet:csharp.bzl", "nuget_package", "csharp_library")
load("//protobuf:rules.bzl", "proto_compile", "proto_repositories")


def csharp_proto_repositories(
    lang_requires = [],
    **kwargs):

  proto_repositories(lang_requires = lang_requires, **kwargs)

  nuget_package(
    name = "nuget_google_protobuf",
    package = "Google.Protobuf",
    version = "3.0.0",
  )

PB_COMPILE_DEPS = [
  "@nuget_google_protobuf//:nuget_google_protobuf",
]


def csharp_proto_library(
    name,
    langs = ["//csharp"],
    protos = [],
    imports = [],
    inputs = [],
    output_to_workspace = False,
    proto_deps = [
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

  csharp_library(
    name = name,
    srcs = srcs + [name + ".pb"],
    deps = list(set(deps + proto_deps + PB_COMPILE_DEPS)),
    **kwargs)
