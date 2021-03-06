# `rules_protobuf` (αlpha) [![Build Status](https://travis-ci.org/pubref/rules_protobuf.svg?branch=master)](https://travis-ci.org/pubref/rules_protobuf)

---

Bazel skylark rules for building [protocol buffers][protobuf-home]
with +/- gRPC support on (osx, linux).

| ![Bazel][bazel_image] | ![Protobuf][wtfcat_image] | ![gRPC][grpc_image] |
| --- | --- | --- |
Bazel | rules_protobuf | gRPC |

---

| Language                 | Compile (1) | Build (2) | gRPC (3) |
| -----------------------: | -----------: | ----------: | -------- |
| [C++][cpp]               | [cc_proto_compile][cpp] | [cc_proto_library][cpp] | yes |
| [C#](bzl/csharp)         | [csharp_proto_compile][csharp] (4) |             |          |
| [Go][go]                 | [go_proto_compile][go] | [go_proto_library][go] | yes |
| [Java][java]             | [java_proto_compile][java] | [java_proto_library][java] | yes |
| [JavaNano][javanano]     | [android_proto_compile][javanano] | [android_proto_library][javanano] | yes |
| [Javascript](bzl/js)     | [js_proto_compile][js] |             |          |
| [Objective-C](bzl/objc)  |              |             |          |
| [Python](bzl/python)     | [py_proto_compile][python]  |             |          |
| [Ruby](bzl/ruby)         | [ruby_proto_compile][ruby]  |             |          |
| [gRPC gateway][grpc-gateway-home] | [grpc_gateway_proto_compile][grpc_gateway] | [grpc_gateway_proto_library][grpc_gateway] | yes |

1. Support for generation of protobuf classes via the `protoc` tool.
2. Support for generation + compilation of outputs with protobuf dependencies.
3. gRPC support.
4. Highly experimental.

---

# Requirements

These are build rules for [bazel][bazel-home].  If you have not already
installed `bazel` on your workstation, follow the
[bazel instructions][bazel-install].  Here's one way (osx):


> Note about protoc and related tools: bazel and rules_protobuf will
> download or build-from-source all required dependencies, including
> the `protoc` tool and required plugins.  If you do already have
> these tools installed, bazel will not use them.

```sh
$ curl -O -J -L https://github.com/bazelbuild/bazel/releases/download/0.3.1/bazel-0.3.1-installer-darwin-x86_64.sh
$ shasum -a256 bazel-0.3.1-installer-darwin-x86_64.sh
8d035de9c137bde4f709e3666271af01d1ef6bed6921e1a676d6a6dc0186395c  bazel-0.3.1-installer-darwin-x86_64.sh
$ chmod +x bazel-0.3.1-installer-darwin-x86_64.sh
$ ./bazel-0.3.1-installer-darwin-x86_64.sh
$ bazel version
Build label: 0.3.1
...
```

# Quick Start

## 1. Add rules_go to your WORKSPACE

Note about golang: this project uses [rules-go][rules_go] for
`go_library`, `go_binary`, and `go_test`.  **Even if you're not >
using go support in rules_protobuf, it is a current requirement for >
your WORKSPACE file** (see issue >
https://github.com/pubref/rules_protobuf/issues/10).

```python
git_repository(
    name = "io_bazel_rules_go",
    tag = "0.0.4",
    remote = "https://github.com/bazelbuild/rules_go.git",
)

load("@io_bazel_rules_go//go:def.bzl", "go_repositories")

go_repositories()
```

## 2. Add rules_protobuf your WORKSPACE

Specify the language(s) you'd like support for:

```python
git_repository(
  name = "org_pubref_rules_protobuf",
  remote = "https://github.com/pubref/rules_protobuf",
  tag = "v0.5.1",
)

load("@org_pubref_rules_protobuf//bzl:rules.bzl", "protobuf_repositories")

protobuf_repositories(
   with_go = True,
   with_java = True,
   with_cpp = True,
)
```

> Refer to [bzl/repositories.bzl][repositories.bzl] file for
> the set of external dependencies that will be available to your
> project.

## 3. Add protobuf rules to your BUILD file

TO build a java-based gRPC library:

```python
load("@org_pubref_rules_protobuf//bzl:java/rules.bzl", "java_proto_library")

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


# Overriding Dependencies

To load alternate versions of dependencies, pass in a
[dict][skylark-dict] having the same overall structure of the
[repositories.bzl][repositories.bzl] file.  Entries having a matching
key will override those found in the file.  For example, to load a
different version of https://github.com/golang/protobuf, provide a
different commit ID:

```
load("@org_pubref_rules_protobuf//bzl:rules.bzl", "protobuf_repositories")
protobuf_repositories(
   with_go = True,
   overrides = {
     "com_github_golang_protobuf": {
       "commit": "2c1988e8c18d14b142c0b472624f71647cf39adb", # Aug 8, 2016
     }
   },
)
```

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

[cpp]: bzl/cpp
[csharp]: bzl/csharp
[go]: bzl/go
[java]: bzl/java
[javanano]: bzl/javanano
[js]: bzl/js
[python]: bzl/python
[ruby]: bzl/ruby
[grpc_gateway]: bzl/grpc_gateway
[repositories.bzl]: bzl/repositories.bzl

[skylark-dict]: https://www.bazel.io/docs/skylark/lib/dict.html "Skylark Documentation for dict"
[skylark-string]: https://www.bazel.io/docs/skylark/lib/attr.html#string "Skylark string attribute"
[skylark-string_list]: https://www.bazel.io/docs/skylark/lib/attr.html#string_list "Skylark string_list attribute"
[skylark-string_list_dict]: https://www.bazel.io/docs/skylark/lib/attr.html#string_list_dict "Skylark string_list_dict attribute"
