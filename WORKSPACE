workspace(name = "org_pubref_rules_protobuf")

# ================================================================
# Go support requires rules_go
# ================================================================

git_repository(
    name = "io_bazel_rules_go",
    commit = "2090e4246b9caea43a5e1e9e7ecfda6c5fcc7516", # +gazelle
    remote = "https://github.com/bazelbuild/rules_go.git",
)

load("@io_bazel_rules_go//go:def.bzl", "go_repositories")

go_repositories()

# ================================================================
# Load self
# ================================================================

load("//bzl:rules.bzl", "protobuf_repositories")

protobuf_repositories(
    # For demonstration purposes of how to override dependencies.
    overrides = {
        "com_github_golang_protobuf": {
            "commit": "2c1988e8c18d14b142c0b472624f71647cf39adb",  # Aug 8, 2016
        },
    },
    verbose = 0,
    with_cpp = True,
    with_go = True,
    with_gogo = True,
    with_grpc_gateway = True,
    with_java = True,
    with_javanano = True,
    with_js = True,
    # with_python = True,
    # with_ruby = True,
)
