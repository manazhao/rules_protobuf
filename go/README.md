# Go Rules

| Rule | Description |
| ---  | --- |
| `go_proto_repositories` | Load WORKSPACE dependencies. |
| `go_proto_library` | Generates and compiles protobuf source files. |

## Installation

Enable GO support by loading the dependencies in your workspace.  This
should occur after loading [rules_go](https://github.com/bazelbuild/rules_go).

```python
load("@org_pubref_rules_protobuf//go:rules.bzl", "go_proto_repositories")
go_protobuf_repositories()
```

## Usage of `go_proto_library`

Load the rule in your `BUILD` file:

```python
load("@org_pubref_rules_protobuf//go:rules.bzl", "go_proto_library")
```

Invoke the rule.  Pass the set of protobuf source files to the
`protos` attribute.

```python
go_proto_library(
  name = "protolib",
  protos = ["my.proto"],
  with_grpc = True,
)
```

```sh
$ bazel build :protolib
```

For other rules that use gRPC or protobuf related classes, you can
access the list of dependencies in the rules.bzl file:


```python
load("@org_pubref_rules_protobuf//go:rules.bzl", "GRPC_COMPILE_DEPS")
```

```python
go_binary(
  name = "myapp",
  srcs = ["main.go"],
  deps = [
    ":protolib"
  ] + GRPC_COMPILE_DEPS,
)
```

```sh
# Run your app
$ bazel run :myapp
```

Consult source files in the `examples/helloworld/go/` directory for additional information.

## Import paths

To use the generated code in other libraries, you'll need to know the
correct `import` path.  This import path has three parts (2 and 3 are
related to the target pattern used to identify the rule):

1. The go_prefix
2. The path to the BUILD file
3. The name of the target in the BUILD file.

First, set the namespace of your code in the root `BUILD` file via the
`go_prefix` directive from `rules_go`:

```python
go_prefix("github.com/my_organization_name")
```

```python
# //go/app_1/BUILD
go_proto_library(
  name = "protolib",
  protos = ["my.proto"],
  with_grpc = True,
)
```

To use this in `go/app_2`, the import path would be:

```go
import (
    pb "github.com/my_organization_name/go/app_1/protolib"
        1.............................. 2....... 3.......
)
```

And its classes referred to via the `pb` identifier:

```go
func main() {
	conn, err := grpc.Dial(address, grpc.WithInsecure())
	if err != nil {
		log.Fatalf("did not connect: %v", err)
	}
	defer conn.Close()
	c := pb.NewGreeterClient(conn)
    ...
}
```

An alternative strategy is to use the magic token `go_default_library`
for the protobuf library rule name, in which case part 3 is not
needed.
