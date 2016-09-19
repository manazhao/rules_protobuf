# Java Rules

| Rule | Description |
| ---  | --- |
| `java_proto_library` | Generates and compiles protobuf source files. |
| `java_proto_language_deps` | Aggregate deps from java-based `proto_language` rules. |

## Installation

Enable java support by loading the set of java dependencies in your workspace.

```python
load("@org_pubref_rules_protobuf//java:rules.bzl", "java_proto_repositories")
java_protobuf_repositories()
```

## Usage of `java_proto_library`

Load the rule in your `BUILD` file:

```python
load("@org_pubref_rules_protobuf//java:rules.bzl", "java_proto_library")
```

Invoke the rule.  Pass the set of protobuf source files to the
`protos` attribute.

```python
java_proto_library(
  name = "protolib",
  protos = ["my.proto"],
  with_grpc = True,
)
```

```sh
$ bazel build :protolib
```

When using the compiled library in other rules, you'll may need the
compile-time or runtime dependencies.  You can access these from
the `proto_language_deps` rules defined in the
`@org_pubref_rules_protobuf//java` BUILD file:

```python
java_library(
  name = "mylib",
  srcs = ['MyApp.java'],
  deps = [
    ":protolib",
    "@org_pubref_rules_protobuf//java:grpc_compiletime_deps",
  ]
)
```

```python
java_binary(
  name = "myapp",
  main_class = "example.MyApp",
  runtime_deps = [
    ":mylib",
    "@org_pubref_rules_protobuf//java:netty_runtime_deps",
  ]
)
```

```sh
# Run your app
$ bazel run :myapp

# Build a self-contained executable jar
$ bazel build :myapp_deploy.jar
```

Consult source files in the `examples/helloworld/java/` directory for additional information.
