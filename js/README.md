# Go Rules

| Rule | Description |
| ---  | --- |
| `js_proto_repositories` | Load WORKSPACE dependencies. |
| `js_proto_library` | Generates and compiles protobuf source files. |

## Installation

Enable javascript support by loading the dependencies in your
workspace.  This should occur after loading
[rules_closure](https://github.com/bazelbuild/rules_closure).

```python
load("@org_pubref_rules_protobuf//js:rules.bzl", "js_proto_repositories")
js_protobuf_repositories()
```

## Usage of `js_proto_library`

Load the rule in your `BUILD` file:

```python
load("@org_pubref_rules_protobuf//js:rules.bzl", "js_proto_library")
```

Invoke the rule.  Pass the set of protobuf source files to the
`protos` attribute.  The default proto_language is
`@org_pubref_rules_protobuf//js:closure`.

```python
js_proto_library(
  name = "protolib",
  protos = ["my.proto"],
)
```

```sh
$ bazel build :protolib
```

Note that `closure_js_proto_library` is implemented in
[rules_closure](https://github.com/bazelbuild/rules_closure#closure_js_proto_library).
This is rule is definitely a viable option but does not at the time of
this writing support imports and proto::proto dependencies.
