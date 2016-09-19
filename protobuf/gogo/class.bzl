load("//bzl:base/class.bzl", BASE = "CLASS")
load("//bzl:go/class.bzl",   GO = "CLASS")

CLASS = struct(
    parent = BASE,
    name = "gogo",

    protobuf = struct(
        name = 'protoc-gen-gogo',
        file_extensions = GO.protobuf.file_extensions,
        executable = "@com_github_gogo_protobuf//protoc-gen-gogo:protoc-gen-gogo",
        default_options = [],
        requires = [
            "com_github_gogo_protobuf",
        ],
        compile_deps = [
            "@com_github_gogo_protobuf//proto:go_default_library",
        ],
    ),

    grpc = struct(
        name = 'grpc',
        default_options = [],
        requires = [
            "com_github_gogo_protobuf",
            "org_golang_google_grpc",
            "org_golang_x_net",
        ],
        compile_deps = [
            "@com_github_golang_glog//:go_default_library",
            "@org_golang_google_grpc//:go_default_library",
            "@org_golang_x_net//:context",
            "@com_github_gogo_protobuf//proto:go_default_library",
        ],
    ),

    build_grpc_out = GO.build_grpc_out,
    build_protobuf_out = GO.build_protobuf_out,
    build_package_prefix = GO.build_package_prefix,
    implement_compile_attributes = GO.implement_compile_attributes,
    library = GO.library,
)

# go_binary rule @com_github_gogo_protobuf//protoc-min-version:protoc-min-version
# go_binary rule @com_github_gogo_protobuf//protoc-gen-gostring:protoc-gen-gostring
# go_binary rule @com_github_gogo_protobuf//protoc-gen-gogotypes:protoc-gen-gogotypes
# go_binary rule @com_github_gogo_protobuf//protoc-gen-gogoslick:protoc-gen-gogoslick
# go_binary rule @com_github_gogo_protobuf//protoc-gen-gogofaster:protoc-gen-gogofaster
# go_binary rule @com_github_gogo_protobuf//protoc-gen-gogofast:protoc-gen-gogofast
# go_binary rule @com_github_gogo_protobuf//protoc-gen-gogo:protoc-gen-gogo
# go_binary rule @com_github_gogo_protobuf//protoc-gen-gofast:protoc-gen-gofast
# go_library rule @com_github_gogo_protobuf//vanity/command:go_default_library
# go_library rule @com_github_gogo_protobuf//protoc-gen-gogo/grpc:go_default_library
# go_binary rule @com_github_gogo_protobuf//protoc-gen-combo:protoc-gen-combo
# go_library rule @com_github_gogo_protobuf//version:go_default_library
# go_library rule @com_github_gogo_protobuf//plugin/unmarshal:go_default_library
# go_library rule @com_github_gogo_protobuf//plugin/union:go_default_library
# go_library rule @com_github_gogo_protobuf//plugin/stringer:go_default_library
# go_library rule @com_github_gogo_protobuf//plugin/size:go_default_library
# go_library rule @com_github_gogo_protobuf//plugin/populate:go_default_library
# go_library rule @com_github_gogo_protobuf//plugin/oneofcheck:go_default_library
# go_library rule @com_github_gogo_protobuf//plugin/marshalto:go_default_library
# go_library rule @com_github_gogo_protobuf//plugin/gostring:go_default_library
# go_library rule @com_github_gogo_protobuf//plugin/face:go_default_library
# go_library rule @com_github_gogo_protobuf//plugin/equal:go_default_library
# go_library rule @com_github_gogo_protobuf//plugin/enumstringer:go_default_library
# go_library rule @com_github_gogo_protobuf//plugin/embedcheck:go_default_library
# go_library rule @com_github_gogo_protobuf//plugin/description:go_default_library
# go_library rule @com_github_gogo_protobuf//plugin/defaultcheck:go_default_library
# go_library rule @com_github_gogo_protobuf//plugin/compare:go_default_library
# go_library rule @com_github_gogo_protobuf//vanity:go_default_library
# go_library rule @com_github_gogo_protobuf//protoc-gen-gogo/generator:go_default_library
# go_library rule @com_github_gogo_protobuf//protoc-gen-gogo/plugin:go_default_library
# go_library rule @com_github_gogo_protobuf//proto/proto3_proto:go_default_library
# go_library rule @com_github_gogo_protobuf//types:go_default_library
# go_library rule @com_github_gogo_protobuf//jsonpb:go_default_library
# go_library rule @com_github_gogo_protobuf//io:go_default_library
# go_binary rule @com_github_gogo_protobuf//gogoreplace:gogoreplace
# go_library rule @com_github_gogo_protobuf//sortkeys:go_default_library
# go_library rule @com_github_gogo_protobuf//gogoproto:go_default_library
# go_library rule @com_github_gogo_protobuf//protoc-gen-gogo/descriptor:go_default_library
# go_library rule @com_github_gogo_protobuf//codec:go_default_library
# go_library rule @com_github_gogo_protobuf//proto:go_default_library
# _go_prefix_rule rule @com_github_gogo_protobuf//:go_prefix
