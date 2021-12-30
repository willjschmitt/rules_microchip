load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def microchip_repositories():
    native.new_local_repository(
        name = "xc32",
        path = "/home/will/xc32_package",
        build_file_content = """
package(default_visibility = ['//visibility:public'])

filegroup(
  name = "all",
  srcs = glob(["**/*"]),
)
"""
    )

def dfp_repositories():
    http_archive(
        name = "pic32mk_gp_dfp",
        url = "https://packs.download.microchip.com/Microchip.PIC32MK-GP_DFP.1.6.144.atpack",
        type = "zip",
        build_file_content = """
package(default_visibility=["//visibility:public"])

cc_library(
    name = "xc_headers",
    hdrs = [
        "include/xc.h",
        "include/xc-pic32m.h",
    ] + glob(["include/proc/*.h"]),
    strip_include_prefix = "include/",
)
""",
        sha256 = "2ed8fe9fb07a44f32cc257df21316d6ace0bd9eb2e36fb62786a07a916051b10",
    )