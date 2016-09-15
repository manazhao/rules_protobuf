load("//bzl:base/rules.bzl", "proto_library")
load("//bzl:go/class.bzl", GO = "CLASS")
load("//bzl:protoc.bzl", "implement")
#load("//bzl:proto_language.bzl", "proto_language_attrs")

SPEC = [GO]

go_proto_compile = implement(SPEC)

def go_proto_library(name, go_import_map = {}, proto_compile_args = {}, **kwargs):
  proto_library(name,
                proto_compile = go_proto_compile,
                proto_compile_args = {
                  "go_import_map": go_import_map,
                } + proto_compile_args,
                spec = SPEC,
                **kwargs)

      # if lang.supports_grpc and run.with_grpc:
      #   opts.append("plugins=grpc")


# def _go_proto_language_impl(ctx):
#   return struct(
#     proto_language = struct(
#       # These are currenty go-specific only.
#       prefix = ctx.attr.prefix.go_prefix,
#       import_map = ctx.attr.import_map,
#     ),
#   )

# def _go_proto_language_impl(ctx):
#   return struct(
#     proto_language = struct(
#       name = ctx.label.name,
#       extends = ctx.attr.extends,
#       output_to_workspace = ctx.attr.output_to_workspace,
#       output_to_jar = ctx.attr.output_to_jar,
#       supports_pb = ctx.attr.supports_pb,
#       pb_file_extensions = ctx.attr.pb_file_extensions,
#       pb_options = ctx.attr.pb_options,
#       pb_imports = ctx.attr.pb_imports,
#       pb_inputs = ctx.attr.pb_inputs,
#       pb_plugin_name = ctx.attr.pb_plugin_name,
#       pb_plugin = ctx.executable.pb_plugin,
#       pb_compile_deps = ctx.files.pb_compile_deps,
#       pb_runtime_deps = ctx.files.pb_runtime_deps,
#       supports_grpc = ctx.attr.supports_grpc,
#       grpc_file_extensions = ctx.attr.grpc_file_extensions,
#       grpc_options = ctx.attr.grpc_options,
#       grpc_imports = ctx.attr.grpc_imports,
#       grpc_inputs = ctx.attr.grpc_inputs,
#       grpc_plugin_name = ctx.attr.grpc_plugin_name,
#       grpc_plugin = ctx.executable.grpc_plugin,
#       grpc_compile_deps = ctx.files.grpc_compile_deps,
#       grpc_runtime_deps = ctx.files.grpc_runtime_deps,

#       go_prefix = ctx.attr.go_prefix.go_prefix,
#       go_importmap = ctx.attr.go_importmap,
#     ),
#   )


# _go_proto_language_attrs = proto_language_attrs + {
#   "go_prefix": attr.label(
#     providers = ["go_prefix"],
#     default = Label(
#       "//:go_prefix",
#       relative_to_caller_repository = True,
#     ),
#     allow_files = False,
#     cfg = "host",
#   ),
#   "go_importmap": attr.string_dict(),
# }


# go_proto_language = rule(
#     implementation = _go_proto_language_impl,
#     attrs = _go_proto_language_attrs,
# )
