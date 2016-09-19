# C++ Rules

| Rule | Description |
| ---  | --- |
| `cpp_proto_repositories` | Load WORKSPACE dependencies. |
| `{cc|cpp}_proto_library` | Generates and compiles protobuf source files. |

## Installation

Enable C++ support by loading the dependencies in your workspace.

```python
load("@org_pubref_rules_protobuf//cpp:rules.bzl", "cpp_proto_repositories")
cpp_protobuf_repositories()
```

## Usage of `cc_proto_library`

Load the rule in your `BUILD` file:

```python
load("@org_pubref_rules_protobuf//cpp:rules.bzl", "cc_proto_library")
```

Invoke the rule.  Pass the set of protobuf source files to the
`protos` attribute.

```python
cc_proto_library(
  name = "protolib",
  protos = ["my.proto"],
  with_grpc = True,
)
```

```sh
$ bazel build :protolib
$ bazel build --spawn_strategy=standalone :protolib
```

> Note: there are some remaining issues with grpc++ compiling on linux
> that may require disabling the sandbox via the
> `--spawn_strategy=standalone` build option. See
> https://github.com/pubref/rules_protobuf/issues/7


When using the compiled library in other rules, `#include` the
generated files relative to the `WORKSPACE` root.  For example, the
`//examples/helloworld/proto/helloworld.proto` functions can be loaded
via:


```cpp
#include <grpc++/grpc++.h>

#include "examples/helloworld/proto/helloworld.pb.h"
#include "examples/helloworld/proto/helloworld.grpc.pb.h"
```

To get the list of required compile-time dependencies in other
contexts for grpc-related code, load the list from the rules.bzl file:

```python
load("@org_pubref_rules_protobuf//cpp:rules.bzl", "GRPC_COMPILE_DEPS")

cc_library(
  name = "mylib",
  srcs = ['MyApp.cpp'],
  deps = [
    ":protolib"
  ] + GRPC_COMPILE_DEPS,
)
```

Consult source files in the `examples/helloworld/cpp/` directory for
additional information.
