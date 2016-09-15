load("//bzl:classlist.bzl", "CLASSES")

PROTOC = Label("//external:protoc")
MAX_INVOKE_DEPTH = range(4)

def _emit_params_file_action(ctx, path, mnemonic, cmds):
  """Helper function that writes a potentially long command list to a file.
  Args:
    ctx (struct): The ctx object.
    path (string): the file path where the params file should be written.
    mnemonic (string): the action mnemomic.
    cmds (list<string>): the command list.
  Returns:
    (File): an executable file that runs the command set.
  """
  filename = "%s.%sFile.params" % (path, mnemonic)
  f = ctx.new_file(ctx.configuration.bin_dir, filename)
  ctx.file_action(output = f,
                  content = "\n".join(["set -e"] + cmds),
                  executable = True)
  return f


def invokeall(cls, name, run, builder):
  """Invoke the all methods found on the class chain"""
  current = cls
  result = None
  for i in MAX_INVOKE_DEPTH:
    if current == None:
      return result
    if hasattr(current, name):
      method = getattr(current, name)
      result = method(cls, run, builder)
      if not hasattr(current, "parent"):
        return result
      current = current.parent
  return result


def invokesuper(cls, name, run, builder):
  """Invoke the first method found on the superclass chain"""
  current = getattr(cls, "parent", None)
  result = None
  for i in MAX_INVOKE_DEPTH:
    if current == None:
      return result
    if hasattr(current, name):
      method = getattr(current, name)
      return method(cls, run, builder)
    if not hasattr(current, "parent"):
      return result
    current = current.parent
  return result


def invoke(cls, name, run, builder):
  """Invoke the first method found on the class chain"""
  current = cls
  result = None
  for i in MAX_INVOKE_DEPTH:
    if current == None:
      return result
    if hasattr(current, name):
      method = getattr(current, name)
      return method(cls, run, builder)
    if not hasattr(current, "parent"):
      return result
    current = current.parent
  return result


def get_offset_path(root, path):
  """Adjust path relative to offset"""

  if path.startswith("/"):
    fail("path argument must not be absolute: %s" % path)

  if not root:
    return path

  if root == ".":
    return path

  # "external/foobar/file.proto" --> "file.proto"
  if path.startswith(root):
    start = len(root)
    if not root.endswith('/'):
      start += 1
      return path[start:]

  depth = root.count('/') + 1
  return "../" * depth + path


def get_outdir(ctx, lang, execdir):
  if ctx.attr.output_to_workspace:
    outdir = "."
  else:
    outdir = ctx.var["GENDIR"]
  return get_offset_path(execdir, outdir)


def get_execdir(ctx):

  # Proto root is by default the bazel execution root for this
  # workspace.
  root = "."

  # Compte set of "external workspace roots" that the proto
  # sourcefiles belong to.
  external_roots = []
  for file in ctx.files.protos:
    path = file.path.split('/')
    if path[0] == 'external':
      external_roots += ["/".join(path[0:2])]

  # This set size must be 0 or 1. (all source files must exist in this
  # workspace or the same external workspace).
  roots = set(external_roots)
  if len(roots) > 1:
    fail(
"""
You are attempting simultaneous compilation of protobuf source files that span multiple workspaces (%s).
Decompose your library rules into smaller units having filesets that belong to only a single workspace at a time.
Note that it is OK to *import* across multiple workspaces, but not compile them as file inputs to protoc.
""" % roots
    )

  # If all protos sources are in an external workspace, set the
  # proto_root to this dir (the location we'll cd into when calling
  # protoc)
  if (len(roots)) == 1:
    root = list(roots)[0]

  # User can augment the execution dir (a postive offset) with the
  # proto_root.
  if ctx.attr.root:
    # Fail if user tries to use relative path segments
    proto_path = ctx.attr.root.split("/")
    if ("" in proto_path) or ("." in proto_path) or (".." in proto_path):
      fail("Proto root cannot contain empty segments, '.', or '..': %s" % proto_path)
    root = "/".join([root] + proto_path)

  return root


def _protoc(ctx, unit):

  execdir = unit.data.execdir

  protoc = get_offset_path(execdir, unit.compiler.path)
  imports = ["--proto_path=" + get_offset_path(execdir, i) for i in unit.imports]
  srcs = [get_offset_path(execdir, p.path) for p in unit.data.protos]
  protoc_cmd = [protoc] + list(unit.args) + imports + srcs
  manifest = [f.short_path for f in unit.outputs]

  inputs = list(unit.inputs)
  outputs = list(unit.outputs)

  cmds = [" ".join(protoc_cmd)]
  if execdir != ".":
    cmds.insert(0, "cd %s" % execdir)

  if unit.data.output_to_workspace:
    print(
"""
>**************************************************************************
* - Generating files into the workspace...  This is potentially           *
*   dangerous (may overwrite existing files) and violates bazel's         *
*   sandbox policy.                                                       *
* - Disregard "ERROR: output 'foo.pb.*' was not created." messages.       *
* - Build will halt following the "not all outputs were created" message. *
* - Output manifest is printed below.                                     *
**************************************************************************<
%s
>*************************************************************************<
""" % "\n".join(manifest)
    )

  if unit.data.verbose:
    print(
"""
************************************************************
cd $(bazel info execution_root)%s && \
%s
************************************************************
%s
************************************************************
""" % (
  "" if execdir == "." else "/" + execdir,
  " \\ \n".join(protoc_cmd),
  "\n".join(manifest))
    )

  if unit.data.verbose > 2:
    for i in range(len(protoc_cmd)):
      print(" > cmd%s: %s" % (i, protoc_cmd[i]))
    for i in range(len(inputs)):
      print(" > input%s: %s" % (i, inputs[i]))
    for i in range(len(outputs)):
      print(" > output%s: %s" % (i, outputs[i]))

  ctx.action(
    mnemonic = "ProtoCompile",
    command = " && ".join(cmds),
    inputs = inputs,
    outputs = outputs,
  )


def _proto_compile_impl(ctx):

  if ctx.attr.verbose > 1:
    print("proto_compile %s:%s"  % (ctx.build_file_path, ctx.label.name))

  # Get proto root.  I think we are using this for side effect only.
  execdir = get_execdir(ctx)
  execdir = "." # test this with/without

  # Propogate proto deps compilation units.
  transitive_units = []
  for dep in ctx.attr.deps:
    for unit in dep.proto_compile_result.transitive_units:
        transitive_units.append(unit)

  # Immutable global state for this compiler run.
  data = struct(
    label = ctx.label,
    prefix = ":".join([ctx.label.package, ctx.label.name]),
    execdir = execdir,
    protos = ctx.files.protos,
    pb_options = ctx.attr.pb_options,
    grpc_options = ctx.attr.grpc_options,
    verbose = ctx.attr.verbose or 2,
    with_grpc = ctx.attr.with_grpc,
    transitive_units = transitive_units,
    output_to_workspace = ctx.attr.output_to_workspace,
  )

  # Mutable global state to be populated by the classes.
  builder = {
    "args": [], # list of string
    "pb_options": data.pb_options,
    "grpc_options": data.grpc_options,
    "imports": ctx.attr.imports + [execdir],
    "inputs": ctx.files.protos,
    "outputs": [],
  }

  # Build a list of structs that will be processed in this compiler
  # run.
  runs = []
  for l in ctx.attr.lang:
    lang = l.proto_language
    cls = CLASSES.get(lang.extends)
    if not cls:
      fail("Unknown class: %s" % lang.extends, "extends")
    runs.append(struct(
      ctx = ctx,
      cls = cls,
      outdir = get_outdir(ctx, lang, execdir),
      lang = lang,
      data = data,
      exts = lang.pb_file_extensions + lang.grpc_file_extensions,
      output_to_jar = lang.output_to_jar,
    ))

    builder["imports"] += lang.pb_imports + lang.grpc_imports
    builder["inputs"] += lang.pb_inputs + lang.grpc_inputs
    builder["pb_options"] += lang.pb_options
    builder["grpc_options"] += lang.pb_options

  for run in runs:
    cls = run.cls
    if run.lang.output_to_jar:
      invoke(cls, "build_output_jar", run, builder)
    else:
      invoke(cls, "build_output_files", run, builder)
    invoke(cls, "build_imports", run, builder)
    if run.lang.supports_pb:
      invoke(cls, "build_protobuf_invocation", run, builder)
      invoke(cls, "build_protobuf_out", run, builder)

    if data.with_grpc and run.lang.supports_grpc:
      invoke(cls, "build_grpc_invocation", run, builder)
      invoke(cls, "build_grpc_out", run, builder)
  #     if ctx.attr.verbose > 2:
  #       print("gen_" + cls.name + "_grpc = yes")
  #   invoke("build_inputs", cls, self)

  # Build final immutable for rule and transitive beyond
  unit = struct(
    compiler = ctx.executable.protoc,
    workspace_name = ctx.workspace_name,
    data = data,
    args = set(builder["args"]),
    imports = set(builder["imports"]),
    inputs = set(builder["inputs"]),
    outputs = set(builder["outputs"] + ctx.outputs.outs),
  )

  # Run protoc
  _protoc(ctx, unit)

  for run in runs:
    cls = run.cls
    if run.lang.output_to_jar:
      invoke(cls, "build_output_srcjar", run, builder)

  # # Postprocessing for all requested languages.
  # for l in ctx.attr.lang:
  #   lang = l.proto_language
  #   cls = CLASSES.get(lang.extends)
  #   self["lang"] = lang
  #   invoke("post_execute", cls, self)

  files = set(builder["outputs"])
  return struct(
    files = files,
    proto_compile_result = struct(
      unit = unit,
      transitive_units = transitive_units + [unit],
    ),
  )

proto_compile = rule(
  implementation = _proto_compile_impl,
  attrs = {
    "lang": attr.label_list(
      providers = ["proto_language"],
      mandatory = True,
    ),
    "protos": attr.label_list(
      allow_files = FileType([".proto"]),
    ),
    "deps": attr.label_list(
      providers = ["proto_compile_result"] # change this to not squat
    ),
    "protoc": attr.label(
      default = Label("//external:protoc"),
      cfg = "host",
      executable = True,
    ),
    "root": attr.string(),
    "imports": attr.string_list(),
    "inputs": attr.label_list(), # additional required files
    "pb_options": attr.string_list(),
    "grpc_options": attr.string_list(),
    "output_to_workspace": attr.bool(),
    "verbose": attr.int(),
    "with_grpc": attr.bool(default = True),
    "outs": attr.output_list(),
  },
  output_to_genfiles = True, # this needs to be set for cc-rules.
)
