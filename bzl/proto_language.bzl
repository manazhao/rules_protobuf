def _proto_language_impl(ctx):
    return struct(
        proto_language = struct(
            name = ctx.label.name,
            extends = ctx.attr.extends,
            output_to_workspace = ctx.attr.output_to_workspace,
            output_to_jar = ctx.attr.output_to_jar,
            supports_pb = ctx.attr.supports_pb,
            pb_file_extensions = ctx.attr.pb_file_extensions,
            pb_options = ctx.attr.pb_options,
            pb_imports = ctx.attr.pb_imports,
            pb_inputs = ctx.attr.pb_inputs,
            pb_plugin_name = ctx.attr.pb_plugin_name,
            pb_plugin = ctx.executable.pb_plugin,
            pb_compile_deps = ctx.files.pb_compile_deps,
            pb_runtime_deps = ctx.files.pb_runtime_deps,
            supports_grpc = ctx.attr.supports_grpc,
            grpc_file_extensions = ctx.attr.grpc_file_extensions,
            grpc_options = ctx.attr.grpc_options,
            grpc_imports = ctx.attr.grpc_imports,
            grpc_inputs = ctx.attr.grpc_inputs,
            grpc_plugin_name = ctx.attr.grpc_plugin_name,
            grpc_plugin = ctx.executable.grpc_plugin,
            grpc_compile_deps = ctx.files.grpc_compile_deps,
            grpc_runtime_deps = ctx.files.grpc_runtime_deps,
        ),
    )


proto_language_attrs = {
    "extends": attr.string(default = "generic"),
    "filename": attr.string(),
    "output_to_workspace": attr.bool(),
    "output_to_jar": attr.bool(),
    "build_generated_files": attr.string(),

    "supports_pb": attr.bool(default = True),
    "pb_file_extensions": attr.string_list(),
    "pb_options": attr.string_list(),
    "pb_inputs": attr.label_list(),
    "pb_imports": attr.string_list(),
    "pb_plugin_name": attr.string(),
    "pb_plugin": attr.label(
        executable = True,
        cfg = "host",
    ),
    "pb_compile_deps": attr.label_list(),
    "pb_runtime_deps": attr.label_list(),

    "supports_grpc": attr.bool(default = False),
    "grpc_file_extensions": attr.string_list(),
    "grpc_options": attr.string_list(),
    "grpc_imports": attr.string_list(),
    "grpc_inputs": attr.label_list(),
    "grpc_plugin_name": attr.string(),
    "grpc_plugin": attr.label(
        executable = True,
        cfg = "host",
    ),
    "grpc_compile_deps": attr.label_list(),
    "grpc_runtime_deps": attr.label_list(),
}


proto_language = rule(
    implementation = _proto_language_impl,
    attrs = proto_language_attrs,
)
