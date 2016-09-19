load("//bzl:util.bzl", "get_offset_path")

def get_import_mappings_for(files, prefix, label):
    """For a set of files that belong the the given context label, create a mapping to the given prefix."""
    # Go-specific code crept in here.
    # if run.lang.prefix and run.lang.prefix.go_prefix:
    #     options += get_go_importmap_options(run, builder)

    print("label: %s" % label)
    mappings = {}
    for file in files:
        src = file.short_path
        # File in an external repo looks like:
        # '../WORKSPACE/SHORT_PATH'.  We want just the SHORT_PATH.
        if src.startswith("../"):
            parts = src.split("/")
            src = "/".join(parts[2:])
        dst = [prefix, label.package]
        name_parts = label.name.split(".")
        # special case to elide last part if the name is
        # 'go_default_library.pb'
        if name_parts[0] != "go_default_library":
            dst.append(name_parts[0])
        mappings[src] = "/".join(dst)

    return mappings


def get_go_importmap_options(run, builder):
    """Override behavior to add plugin options before building the --go_out option"""

    lang = run.lang
    go_prefix = lang.prefix.go_prefix
    mappings = lang.import_map
    mappings += get_import_mappings_for(run.data.protos,go_prefix, run.data.label)

    # Then add in the transitive set from dependent rules.
    for unit in run.data.transitive_units:
        # Map to this go_prefix if within same workspace, otherwise
        # use theirs.
        prefix = go_prefix
        if unit.workspace_name != run.data.workspace_name:
            prefix = unit.prefix
        print("protos %s, prefix %s, label: %s" % (unit.data.protos, prefix, unit.data.label))
        mappings += get_import_mappings_for(unit.data.protos, prefix, unit.data.label)

    if run.data.verbose > 1:
        print("go_import_map: %s" % mappings)

    opts = ["M%s=%s" % (k, v) for k, v in mappings.items()]
    return opts


def build_output_jar(cls, run, builder):
    """Build a jar file for protoc to dump java classes into."""
    ctx = run.ctx
    execdir = run.data.execdir
    name = run.lang.name
    protojar = ctx.new_file("%s_%s.jar" % (run.data.label.name, name))
    builder["outputs"] += [protojar]
    builder[name + "_jar"] = protojar
    builder[name + "_outdir"] = get_offset_path(execdir, protojar.path)


def build_output_library(cls, run, builder):
    """Build a library.js file for protoc to dump java classes into."""
    ctx = run.ctx
    execdir = run.data.execdir
    name = run.lang.name
    jslib = ctx.new_file(run.data.label.name + run.lang.pb_file_extensions[0])
    builder["jslib"] = [jslib]
    builder["outputs"] += [jslib]
    #builder[name + "_outdir"] = get_offset_path(execdir, protojar.path)

    parts = jslib.short_path.rpartition("/")
    filename = "/".join([parts[0], run.data.label.name])
    library_path = get_offset_path(run.data.execdir, filename)
    builder[name + "_pb_options"] = ["library=" + library_path]


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


def get_mappings(files, label, prefix):
    """For a set of files that belong the the given context label, create a mapping to the given prefix."""
    mappings = {}
    for file in files:
        src = file.short_path
        # File in an external repo looks like:
        # '../WORKSPACE/SHORT_PATH'.  We want just the SHORT_PATH.
        if src.startswith("../"):
            parts = src.split("/")
            src = "/".join(parts[2:])
        dst = [prefix, label.package]
        name_parts = label.name.split(".")
        # special case to elide last part if the name is
        # 'go_default_library.pb'
        if name_parts[0] != "go_default_library":
            dst.append(name_parts[0])
        mappings[src] = "/".join(dst)

    return mappings

def build_importmappings(cls, run, builder):
    """Override behavior to add plugin options before building the --go_out option"""
    ctx = run.ctx
    go_prefix = run.lang.prefix

    opts = []
    # Add in the 'plugins=grpc' option to the protoc-gen-go plugin if
    # the user wants grpc.
    if run.data.with_grpc:
        opts.append("plugins=grpc")

    # Build the list of import mappings.  Start with any configured on
    # the rule by attributes.
    mappings = run.lang.importmap + run.data.importmap
    mappings += get_mappings(run.data.protos, run.data.label, go_prefix)

    # Then add in the transitive set from dependent rules. TODO: just
    # pass the import map transitively rather than recomputing it.
    for unit in run.data.transitive_units:
        # Map to this go_prefix if within same workspace, otherwise use theirs.
        prefix = go_prefix if unit.data.workspace_name == run.data.workspace_name else unit.data.prefix
        mappings += get_mappings(unit.data.protos, unit.data.label, prefix)

    if run.data.verbose > 1:
        print("go_importmap: %s" % mappings)

    for k, v in mappings.items():
        opts += ["M%s=%s" % (k, v)]

    builder[run.lang.name + "_pb_options"] = opts


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
    options += builder.get(lang.name + "_pb_options", [])

    build_plugin_out(name, outdir, options, builder)


def build_grpc_out(cls, run, builder):
    """Build the --{lang}_out grpc option"""
    lang = run.lang
    name = lang.grpc_plugin_name or "grpc-" + lang.name
    outdir = builder.get(lang.name + "_outdir", run.outdir)
    options = builder["grpc_options"]
    options += builder.get(lang.name + "_grpc_options", [])

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
    build_output_library = build_output_library,
    build_output_srcjar = build_output_srcjar,
    build_grpc_invocation = build_grpc_invocation,
    build_grpc_out = build_grpc_out,
    build_package_prefix = build_package_prefix,
    build_protobuf_invocation = build_protobuf_invocation,
    build_protobuf_out = build_protobuf_out,
    get_primary_output_suffix = get_primary_output_suffix,
    build_importmappings = build_importmappings,
    implement_compile_attributes = implement_compile_attributes,
    implement_compile_outputs = implement_compile_outputs,
    implement_compile_output_to_genfiles = implement_compile_output_to_genfiles,
    post_execute = post_execute,
)