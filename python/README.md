# `rules_protobuf` Python Support

Generate python outputs as follows:

```python
load("//protobuf:rules.bzl", "proto_compile")

proto_compile(
    name = "py",
    langs = [
        "@org_pubref_rules_protobuf//python",
    ],
)

```

Support for a library rule is dependent on loading the workspace
dependencies for the py_library rule which has not been implemented
yet.
