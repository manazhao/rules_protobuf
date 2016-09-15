load("//bzl:util.bzl", "get_offset_path")



def build_output_jar(cls, run, builder):
    """Build a jar file for protoc to dump java classes into."""
    ctx = run.ctx
    execdir = run.data.execdir
    name = run.lang.name
    protojar = ctx.new_file("%s_%s.jar" % (run.data.label.name, name))
    builder["outputs"] += [protojar]
    builder[name + "_jar"] = protojar
    builder[name + "_outdir"] = get_offset_path(execdir, protojar.path)


def build_output_srcjar(cls, run, builder):
    ctx = run.ctx
    name = run.lang.name
    protojar = builder[name + "_jar"]
    srcjar_name = "%s_%s.srcjar" % (run.data.label.name, name)
    srcjar = ctx.new_file("%s_%s.srcjar" % (run.data.label.name, name))
    # srcjar = None
    # for file in ctx.outputs.outs:
    #     if file.basename == srcjar_name:
    #         srcjar = file
    #         break
    # if not srcjar:
    #     fail("Output list must contain a file named '%'" % srcjar_name, "outs")
    run.ctx.action(
        mnemonic = "FixProtoSrcJar",
        inputs = [protojar],
        outputs = [srcjar],
        arguments = [protojar.path, srcjar.path],
        command = "cp $1 $2",
    )

    # Remove protojar from the list of provided outputs
    builder["outputs"] = [e for e in builder["outputs"] if e != protojar]
    builder["outputs"] += [srcjar]

    if run.data.verbose > 2:
        print("Copied jar %s srcjar to %s" % (protojar.path, srcjar.path))


def build_output_files(cls, run, builder):
    """Build a list of files we expect to be generated."""

    protos = run.data.protos
    if not protos:
        fail("Empty proto input list.", "protos")

    exts = run.lang.pb_file_extensions + run.lang.grpc_file_extensions

    for file in protos:
        base = file.basename[:-len(".proto")]
        for ext in exts:
            pbfile = run.ctx.new_file(base + ext)
            builder["outputs"] += [pbfile]


def build_plugin_invocation(name, plugin, execdir, builder):
    """Add a '--plugin=NAME=PATH' argument if the language descriptor
    requires one.
    """
    tool = get_offset_path(execdir, plugin.path)
    builder["inputs"] += [plugin]
    builder["args"] += ["--plugin=protoc-gen-%s=%s" % (name, tool)]


def build_protobuf_invocation(cls, run, builder):
    """Build a --plugin option if required for basic protobuf generation.
    Args:
      cls (struct): the class object.
      run (struct): the compilation run object.
      builder (dict): the compilation builder data.
    Built-in language don't need this.
    """
    lang = run.lang
    if not lang.pb_plugin:
        return
    name = lang.pb_plugin_name or lang.name
    build_plugin_invocation(name,
                            lang.pb_plugin,
                            run.data.execdir,
                            builder)


def build_grpc_invocation(cls, run, builder):
    """Build a --plugin option if required for grpc service generation
    Args:
      cls (struct): the class object.
      run (struct): the compilation run object.
      builder (dict): the compilation builder data.
    Built-in language don't need this.
    """
    lang = run.lang
    if not lang.grpc_plugin:
        return
    name = lang.grpc_plugin_name or "grpc-" + lang.name
    build_plugin_invocation(name,
                            lang.grpc_plugin,
                            run.data.execdir,
                            builder)


def build_plugin_out(name, outdir, options, builder):
    """Build the --{lang}_out argument for a given plugin."""
    arg = outdir
    if options:
        arg = ",".join(options) + ":" + arg
    builder["args"] += ["--%s_out=%s" % (name, arg)]


def build_protobuf_out(cls, run, builder):
    """Build the --{lang}_out option"""
    lang = run.lang
    name = lang.pb_plugin_name or lang.name
    outdir = builder.get(lang.name + "_outdir", run.outdir)
    options = builder["pb_options"]

    build_plugin_out(name, outdir, options, builder)


def build_grpc_out(cls, run, builder):
    """Build the --{lang}_out grpc option"""
    lang = run.lang
    name = lang.grpc_plugin_name or "grpc-" + lang.name
    outdir = builder.get(lang.name + "_outdir", run.outdir)
    options = builder["grpc_options"]

    build_plugin_out(name, outdir, options, builder)

# ****************************************************************
# ****************************************************************
# ****************************************************************

def implement_compile_attributes(cls, self):
    """Add per-clsuage attributes for the proto_compile rule"""

    attrs = self["attrs"]
    name = cls.name
    genlang = "gen_" + name

    # An attribute that enables/disables processing for this
    # language.
    attrs[genlang] = attr.bool(default = True)

    # Additional per-language options to the protobuf generator.  This
    # can either be implemented by the a plugin or protoc itself.
    attrs[genlang + "_protobuf_options"] = attr.string_list()

    # Allows the user to override the label that points to the plugin
    # binary, if configured on the language descriptor.
    if hasattr(cls, "protobuf") and hasattr(cls.protobuf, "executable"):
        attrs["gen_" + name + "_protobuf_plugin"] = attr.label(
            default = Label(cls.protobuf.executable),
            cfg = HOST_CFG,
            executable = True,
        )

    if hasattr(cls, "grpc"):
        # If this clsuage supports gRPC, add this boolean flag in to
        # enable it.
        attrs[genlang + "_grpc"] = attr.bool()

        # If this language uses a separate plugin for the grpc part,
        # add an attribute that makes it configurable
        if hasattr(cls.grpc, "executable"):
            attrs[genlang + "_grpc_plugin"] = attr.label(
                default = Label(cls.grpc.executable),
                cfg = HOST_CFG,
                executable = True,
            )

        # Additional options to the grpc plugin.
        attrs[genlang + "_grpc_options"] = attr.string_list()


def implement_compile_outputs(cls, self):
    """
    Add customizable outputs for the proto_compile rule.  At this point
    only used by java.
    """
    if hasattr(cls, "protobuf") and hasattr(cls.protobuf, "outputs"):
        self["outputs"] += cls.protobuf.outputs
    if hasattr(cls, "grpc") and hasattr(cls.grpc, "outputs"):
        self["outputs"] += cls.grpc.outputs


def implement_compile_output_to_genfiles(cls, self):
    """
    Configures the genfiles output location.
    """
    self["output_to_genfiles"] = getattr(cls, "output_to_genfiles", self["output_to_genfiles"])


def build_package_prefix(cls, self):
    """The package prefix.  This is only used by go"""
    pass


# def build_inputs(cls, self):
#     """Build a list of inputs to the ctx.action protoc"""
#     self["inputs"] += self["protos"]


def post_execute(cls, self):
    """No default post-execute actions"""
    pass


def get_primary_output_suffix(cls, self):
    """The name of the implicit target that names the generated pb source files."""
    return ".pb"


CLASS = struct(
    # name = "base",

    # protobuf = struct(
    #     requires = [
    #         "protobuf",
    #         "external_protoc",
    #         "third_party_protoc",
    #     ]
    # ),

    build_output_files = build_output_files,
    build_output_jar = build_output_jar,
    build_output_srcjar = build_output_srcjar,
    build_grpc_invocation = build_grpc_invocation,
    build_grpc_out = build_grpc_out,
    build_package_prefix = build_package_prefix,
    build_protobuf_invocation = build_protobuf_invocation,
    build_protobuf_out = build_protobuf_out,
    get_primary_output_suffix = get_primary_output_suffix,

    implement_compile_attributes = implement_compile_attributes,
    implement_compile_outputs = implement_compile_outputs,
    implement_compile_output_to_genfiles = implement_compile_output_to_genfiles,
    post_execute = post_execute,
)
