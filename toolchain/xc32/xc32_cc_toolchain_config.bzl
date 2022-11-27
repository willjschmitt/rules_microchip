"""Provides CC toolchain implementation for the Microchip XC32 compiler.

Used for XC32 compilation for 32-bit compilation targeting PIC
micro-controllers.
"""
# TODO(willjschmitt): Support here is particularly for motor-control, so
#  configuration might be over-configured for specific micro-controllers.

load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")
load(
    "@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "feature",
    "flag_group",
    "flag_set",
    "tool_path",
)

def _impl(ctx):
    all_compile_actions = [
        ACTION_NAMES.c_compile,
        ACTION_NAMES.cpp_compile,
        ACTION_NAMES.linkstamp_compile,
        ACTION_NAMES.assemble,
        ACTION_NAMES.preprocess_assemble,
        ACTION_NAMES.cpp_header_parsing,
        ACTION_NAMES.cpp_module_compile,
        ACTION_NAMES.cpp_module_codegen,
        ACTION_NAMES.clif_match,
        ACTION_NAMES.lto_backend,
    ]

    all_link_actions = [
        ACTION_NAMES.cpp_link_executable,
        ACTION_NAMES.cpp_link_dynamic_library,
        ACTION_NAMES.cpp_link_nodeps_dynamic_library,

        # TODO(willjschmitt): Normally this would be included in link actions,
        #  but the xc32-g++ archiver doesn't seem to love some of the options
        #  below, so we will will comment this out until it can be determined
        #  how to properly include it.
        # ACTION_NAMES.cpp_link_static_library,
    ]

    all_common_actions = all_compile_actions + all_link_actions

    tool_paths = [
        tool_path(
            name = "gcc",
            path = "wrappers/xc32-g++",
        ),
        tool_path(
            name = "ld",
            path = "wrappers/xc32-ld",
        ),
        tool_path(
            name = "ar",
            path = "wrappers/xc32-ar",
        ),
        tool_path(
            name = "cpp",
            path = "wrappers/xc32-cpp",
        ),
        tool_path(
            name = "gcov",
            path = "/bin/false",
        ),
        tool_path(
            name = "nm",
            path = "wrappers/xc32-nm",
        ),
        tool_path(
            name = "objdump",
            path = "wrappers/xc32-objdump",
        ),
        tool_path(
            name = "strip",
            path = "wrappers/xc32-strip",
        ),
    ]

    features = [
        feature(
            name = "xc32_common_flags",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = all_common_actions,
                    flag_groups = ([
                        flag_group(
                            flags = [
                                # Most standard libraries from Microchip are
                                # compiled with soft-float, so we keep things
                                # consistent.
                                "-msoft-float",

                                # TODO(willjschmitt): Other standard included
                                #  compiler flags for xc32 from MPLAB, which
                                #  perhaps should not be included until they are
                                #  better understood or a strong desire to
                                #  exclude is determined (such as turning off
                                #  exceptions), but leaving for now.
                                "-g",
                                "-lstdc++",
                                "-frtti",
                                "-fexceptions",
                                "-fno-check-new",
                                "-fenforce-eh-specs",

                                # This ensures we don't need to specify absolute
                                # paths to
                                # `cc_common.create_cc_toolchain_config_info.cxx_builtin_include_directories
                                # below, which is very painful given that actual
                                # paths cannot be predicted on a host machine.
                                "-no-canonical-prefixes",
                                "-fno-canonical-system-headers",
                            ],
                        ),
                    ]),
                ),
            ],
        ),
        # TODO(willjschmitt): This is currently commented out, since the pending
        #  flags are all commented out. This means the feature is invalid with
        #  an empty flag group. Thus, we will leave it commented out in-whole
        #  for future use.
        # feature(
        #     name = "xc32_device_linking_flags",
        #     enabled = True,
        #     flag_sets = [
        #         flag_set(
        #             actions = all_link_actions,
        #             flag_groups = ([
        #                 flag_group(
        #                     flags = [
        #                         # TODO(#3): This hard-codes the path where Bazel
        #                         #  will install the device-packs on my desktop.
        #                         #  This isn't portable, so it's a critical need
        #                         #  to remove this option and make it provided as
        #                         #  a linkopt or data instead pointing at the
        #                         #  bazel reference target. As far as I can tell,
        #                         #  xc32 _requires_ the path to be absolute,
        #                         #  based on testing with all possible relative
        #                         #  paths, but the feature is not well
        #                         #  documented, so that conclusion could be wrong.
        #                         # "-mdfp=/home/will/electric_vehicle/electric-vehicle-controller/bazel-electric-vehicle-controller/external/pic32mk_gp_dfp",
        #
        #                         # TODO(willjschmitt): It is likely to become
        #                         #  necessary to include the peripheral libraries
        #                         #  at some point, so we will need to include
        #                         #  this along with some more external
        #                         #  repositories.
        #                         # "-mperipheral-libs",
        #                     ],
        #                 ),
        #             ]),
        #         ),
        #     ],
        # ),
    ]

    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        features = features,
        # Include directories from the toolchain source are not necessary when
        # using `-no-canonical-prefixes` and `-fno-canonical-system-headers`.
        cxx_builtin_include_directories = [],
        toolchain_identifier = "mcp32-toolchain",
        host_system_name = "local",
        target_system_name = "local",
        target_cpu = "mcp32",
        target_libc = "unknown",
        compiler = "xc32",
        abi_version = "unknown",
        abi_libc_version = "unknown",
        tool_paths = tool_paths,
    )

xc32_cc_toolchain_config = rule(
    implementation = _impl,
    attrs = {},
    provides = [CcToolchainConfigInfo],
)