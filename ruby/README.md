# `rules_protobuf` Ruby Support

Generate ruby outputs as follows:

```python
load("//protobuf:rules.bzl", "proto_compile")

proto_compile(
    name = "rb",
    langs = [
        "@org_pubref_rules_protobuf//ruby",
    ],
)

```
