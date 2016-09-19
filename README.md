# `rules_protobuf` (αlpha) [![Build Status](https://travis-ci.org/pubref/rules_protobuf.svg?branch=master)](https://travis-ci.org/pubref/rules_protobuf)

---

Bazel skylark rules for building [protocol buffers][protobuf-home]
with +/- gRPC support on (osx, linux).

| ![Bazel][bazel_image] | ![Protobuf][wtfcat_image] | ![gRPC][grpc_image] |
| --- | --- | --- |
Bazel | rules_protobuf | gRPC |

---

| Language                     | Compile<sup>1</sup>  | Build<sup>2</sup> | gRPC<sup>3</sup> |
| ---------------------------: | -----------: | --------: | -------- |
| [C++](cpp)                   | [cc_proto_compile](cpp) | [cc_proto_library](cpp) | yes |
| [Go](go)                     | [go_proto_compile](go) | [go_proto_library](go) | yes |
| [Java](java)                 | [java_proto_compile](java) | [java_proto_library](java) | yes |
| [Android](java)              | yes          | [android_proto_library](android) | yes |
| [Javascript](js)             | [closure_proto_compile](js)<br/>[commonjs_proto_compile](js) | [closure_proto_library](js)<br/>[commonjs_proto_library](js)          |          |
| [Python](python)             | [py_proto_compile](python)         |           |          |
| [Ruby](ruby)                 | [ruby_proto_compile](ruby)          |           |          |
| [gRPC gateway](grpc_gateway) | [grpc_gateway_proto_compile](grpc_gateway)   | [grpc_gateway_proto_library](grpc_gateway)<br/>[grpc_gateway_binary](grpc_gateway) | yes |
| [gRPC swagger](grpc_gateway) | [grpc_gateway_swagger_compile](grpc_gateway) |           | yes |
| [Objective-C](objc) (4)      | [objc_proto_compile](objc) | [objc_proto_compile](objc)  |        |
| <span style="color:red"><a href="csharp">csharp</a></span><sup>4</sup> | [csharp_proto_compile](csharp)      | [csharp_proto_library](csharp) |          |

1. Support for generation of protoc outputs via `proto_compile()` rule.

2. Support for generation + compilation of outputs with protobuf dependencies.

3. gRPC support.

4. Highly experimental (not even functional yet). These rules are a
   WIP for those interested in contributing further work.

---

# Requirements

These are build rules for [bazel][bazel-home].  If you have not already
installed `bazel` on your workstation, follow the
[bazel instructions][bazel-install].

> Note about protoc and related tools: bazel and rules_protobuf will
> download or build-from-source all required dependencies, including
> the `protoc` tool and required plugins.  If you do already have
> these tools installed, bazel will not use them.

# Quick Start

## 1. Add rules_protobuf your WORKSPACE

Specify the language(s) you'd like support by loading the
language-specific `*_proto_repositories` rule:

```python
git_repository(
  name = "org_pubref_rules_protobuf",
  remote = "https://github.com/pubref/rules_protobuf",
  tag = "v0.5.1",
)

load("@org_pubref_rules_protobuf//java:rules.bzl", "java_proto_repositories")
java_proto_repositories()

load("@org_pubref_rules_protobuf//cpp:rules.bzl", "cpp_proto_repositories")
cpp_proto_repositories()

load("@org_pubref_rules_protobuf//java:rules.bzl", "go_proto_repositories")
go_proto_repositories()
```

Several languages have other `rules_*` dependencies that you'll need
to load before the `*_proto_repositories()` function is invoked:

| Language | Requires |
| ---:     | :---     |
| go_proto_repositories | [rules_go](https://github.com/bazelbuild/rules_go) |
| js_proto_repositories | [rules_closure](https://github.com/bazelbuild/rules_go) |
| csharp_proto_repositories | [rules_dotnet](https://github.com/bazelbuild/rules_dotnet) |

If you're only interested in the `proto_compile` rule and not any
language-specific rules, load the generic `proto_repositories` rule.
This provides the minimal set of dependencies (only the protoc tool).

```python
load("@org_pubref_rules_protobuf//protobuf:rules.bzl", "proto_repositories")
proto_repositories()
```

## 2. Add protobuf rules to your BUILD file

To build a java-based gRPC library:

```python
load("@org_pubref_rules_protobuf//java:rules.bzl", "java_proto_library")

java_proto_library(
  name = "protolib",
  protos = [
    "my.proto"
  ],
  with_grpc = True,
  verbose = 1, # 0=no output, 1=show protoc command, 2+ more...
)
```

# Examples

To run the examples & tests in this repository, clone it to your
workstation.

```sh
# Clone this repo
$ git clone https://github.com/pubref/rules_protobuf

# Go to examples/helloworld directory
$ cd rules_protobuf/examples/helloworld

# Run all tests
$ bazel test examples/...

# Build a server
$ bazel build cpp/server

# Run a server from the command-line
$ $(bazel info bazel-bin)/examples/helloworld/cpp/server

# Run a client
$ bazel run go/client
$ bazel run cpp/client
$ bazel run java/org/pubref/rules_closure/examples/helloworld/client:netty
```

# Overriding or Excluding WORKSPACE Dependencies

To load alternate versions of dependencies, pass in a
[dict][skylark-dict] having the same overall structure of the
[repositories.bzl][repositories.bzl] file.  Entries having a matching
key will override those found in the file.  For example, to load a
different version of https://github.com/golang/protobuf, provide a
different commit ID:

```python
load("@org_pubref_rules_protobuf//go:rules.bzl", "go_proto_repositories")
go_proto_repositories(
  overrides = {
    "com_github_golang_protobuf": {
      "commit": "2c1988e8c18d14b142c0b472624f71647cf39adb", # Aug 8, 2016
    }
  },
)
```

You may already have some external dependencies already present in
your workspace that rules_protobuf will attempt to load, causing a
collision.  To prevent rules_protobuf from loading specific external
workspaces, name them in the `excludes` list:

```python
go_proto_repositories(
  excludes = [
    "com_github_golang_glog",
  ]
)
```

# Using the `proto_compile` rule

The `proto_compile` rule invokes the `protoc` tool for a given
`proto_language` specification.  Here's an example that generates
protoc outputs for multiple languages simultaneously:

```python
load("@org_pubref_rules_protobuf//protobuf:rules.bzl", "proto_compile")

proto_compile(
   name = "proto_all",
   langs = [
     "@org_pubref_rules_protobuf//python",
     "@org_pubref_rules_protobuf//java",
     "@org_pubref_rules_protobuf//java:nano",
     "@org_pubref_rules_protobuf//cpp",
     "@org_pubref_rules_protobuf//objc",
     "@org_pubref_rules_protobuf//js:closure",
     "@org_pubref_rules_protobuf//js:commonjs",
     "@org_pubref_rules_protobuf//go",
   ],
   with_grpc = True,
)
```

# Using the `proto_language` rule

A `proto_language` rule encapsulates the metadata about how to invoke
the `protoc` tool for a particular protocol buffer plugin.  You can
use your own `proto_language` definitions in conjunction with the
`proto_compile` rule to generate custom protoc outputs.  Here's a
hypothetical example to generate php outputs:

```python
load("@org_pubref_rules_protobuf//protobuf:rules.bzl", "proto_language", "proto_compile")

proto_language(
   name = "php",
   # The plugin binary
   pb_plugin = "//external/protoc-gen-php",
   # File extensions that the plugin generates
   pb_file_extensions = ["_pb.php"],
   # Optional default plugin options
   pb_options = [],
   # Optional default imports
   pb_imports = [],
)

proto_compile(
   name = "php_protos",
   # Pass in a list of proto_language rules
   langs = [":php"],
)
```

The same pattern applies to the `*_proto_library` rules, meaning you
can pass in alternative/custom language specifications to these rules
to generate custom library outputs.

# Proto B --> Proto A dependencies

Use the `proto_deps` attribute to name proto rule dependencies. The
implementation of the dependent rule `B` should match that of the
dependee `A`.  This relationship is shown in the examples folder of
this repo.  Use of `proto_deps` implies you're using imports, so read
on...

## Imports

In all cases, these rules will include a `--proto_path=.` argument.
This is functionally equivalent to `--proto_path=$(bazel info
execution_root)`.  Therefore, when the protoc tool is invoked, it will
'see' whatever directory struture exists at the bazel execution root
for your workspace.  To better learn what this looks like, `cd $(bazel
info execution_root)` and look around.  In general, it contains all
your sourcefiles as they appear in your workspace, with an additional
`external/WORKSPACE_NAME` directory for all dependencies used.

This has implications for import statements in your protobuf
sourcefiles, if you use them.  The two cases to consider are imports
*within* your workspace (referred to here as *'internal' imports*),
and imports of other protobuf files in an external workspace
(*external imports*).

If you need them (see below), use the `imports` attribute (a
[string_list][skylark-string_list]).  This passes arguments directly
to protoc (normalized to the rootdir where the protoc command runs).


### Internal Imports

Internal imports should require no additional parameters if your
import statements follow the same directory structure of your
workspace.  For example, the
`examples/helloworld/proto/helloworld.proto` file imports the
`examples/proto/common.proto` file.  Since this matches the workspace
directory structure, `protoc` can find it, and no additional arguments
to a `cc_proto_library` are required for protoc code generation step.

Obviously, importing a file does not mean that code will be generated
for it.  Therefore, *use of the imports attribute implies that the
generated files for the imported message or service already exist
somewhere that can be used as a dependency some other library rule*
(such as `srcs` for `java_library`).

Rather than using `imports`, it often make more sense to declare a
dependency on another proto_library rule via the `proto_deps`
attribute.  This makes the import available to the calling rule and
performs code generation.  For example, the `cc_proto_library` rule in
`examples/helloworld/proto:cpp` names the `//examples/proto:cpp`'s
`cc_proto_library` rule in its `proto_deps` attribute to accomplish
both code generation and compilation of object files for the proto
chain.

### External Imports

The same logic applied to external imports.  The two questions to
answer are:

1. *Can protoc "see" the imported file?* In order to satisfy this
   requirement, pass in the full path of the required file(s) relative
   to the execution root where protoc will be run.  For example, the
   the well-known descriptor proto could be made visible to protoc via
   something like...

```python
java_proto_library(
  name = 'fooprotos',
  protos = 'foo.proto`,
  imports = [
    "external/com_github_google_protobuf/src/",
  ],
)
```

...if imported as `import "google/protobuf/descriptor.proto"` given
that the file
`@com_github_google_protobuf/src/google/protobuf/descriptor.proto` is
in the package `google.protobuf`.

2. *Can the `cc_proto_library` rule "see" the generated protobuf
   files*? (in this case `descriptor.pb.{h,cc}`.  Just because the
   file was imported does not imply that protoc will generate outputs
   for it, so somewhere in the `cc_library` rule dependency chain
   these files must be present.  This could be via another
   `cc_proto_library` rule defined elswhere, or a some other filegroup
   or label list.  If the source is another `cc_proto_library` rule,
   specify that in the `proto_deps` attribute to the calling
   `cc_proto_library` rule.  Otherwise, pass a label that includes the
   (pregenerated) protobuf files to the `deps` attribute, just as you
   would any typical `cc_library` rule.  Hopefully that made sense.
   It's a bit tricky.


# Contributing

Contributions welcome; please create Issues or GitHub pull requests.


# Credits

* [@yugui][yugui]: Primary source for the go support from [grpc-gateway](https://github.com/grpc-ecosystem/grpc-gateway/blob/e958c5db30f7b99e1870db42dd5624322f112d0c/examples/bzl/BUILD).

* [@mzhaom][mzhaom]: Primary source for the skylark rule (from
  <https://github.com/mzhaom/trunk/blob/master/third_party/grpc/grpc_proto.bzl>).

* [@jart][jart]: Overall repository structure and bazel code layout
  (based on [rules_closure]).

* [@korfuri][korfuri]: Prior research on travis-ci integration.

* Much thanks to all the members of the bazel, protobuf, and gRPC teams.

---

[yugui]: http://github.com/yugui "Yuki Yugui Sonoda"
[jart]: http://github.com/jart "Justine Tunney"
[mzhaom]: http://github.com/mzhaom "Ming Zhao"
[korfuri]: http://github.com/korfuri "Uriel Korfa"

[protobuf-home]: https://developers.google.com/protocol-buffers/ "Protocol Buffers Developer Documentation"
[bazel-home]: http://bazel.io "Bazel Homepage"
[bazel-install]: http://bazel.io/docs/install.html "Bazel Installation"
[rules_closure]: http://github.com/bazelbuild/rules_closure "Rules Closure"
[rules_go]: http://github.com/bazelbuild/rules_go "Rules Go"
[grpc-gateway-home]:https://github.com/grpc-ecosystem/grpc-gateway

[bazel_image]: https://github.com/pubref/rules_protobuf/blob/master/images/bazel.png
[wtfcat_image]: https://github.com/pubref/rules_protobuf/blob/master/images/wtfcat.png
[grpc_image]: https://github.com/pubref/rules_protobuf/blob/master/images/gRPC.png

[repositories.bzl]: protobuf/internal/repositories.bzl

[skylark-dict]: https://www.bazel.io/docs/skylark/lib/dict.html "Skylark Documentation for dict"
[skylark-string]: https://www.bazel.io/docs/skylark/lib/attr.html#string "Skylark string attribute"
[skylark-string_list]: https://www.bazel.io/docs/skylark/lib/attr.html#string_list "Skylark string_list attribute"
[skylark-string_list_dict]: https://www.bazel.io/docs/skylark/lib/attr.html#string_list_dict "Skylark string_list_dict attribute"
