#!/bin/bash
set -e
# Downloads, installs, and packages XC32 into a tar to be uploaded somewhere
# centrally to be used as a source of compilers for Bazel builds. This script is
# not completely headless, since the XC installation process requires human
# input. It additionally requires root privileges, even when installing to a
# local directory rather than system-wide.
# Usage: ./install_and_package_xc32.sh <version>
# Example: ./install_and_package_xc32.sh 3.01

if [ $# -eq 0 ]; then
  >&2 echo "XC32 compiler version must be provided as a positional argument."
  exit -1
fi
XC32_VERSION=${1}

# Download the installer from Microchip's site.
# This link was composed based on observing how installer download links are
# found on:
# https://www.microchip.com/en-us/tools-resources/develop/mplab-xc-compilers#tabs
# If this changes, this logic will need to change below.
TEMP_INSTALLER=$(mktemp -t xc32-v${XC32_VERSION}-installer.run-XXXXXXXXXXXXXXXX)
wget https://ww1.microchip.com/downloads/en/DeviceDoc/xc32-v${XC32_VERSION}-full-install-linux-installer.run \
  --output-document ${TEMP_INSTALLER}
chmod a+x ${TEMP_INSTALLER}

# This installs as much as possible without human input, but you'll need
# to accept the license agreement, and accept a few prefilled answers.
# Everything should be pre-populated to accept as-is. Don't buy or trial the pro
# license. Those prompts default to yes, so keep an eye out.
TEMP_INSTALL_DIRECTORY=$(mktemp -d -t xc32-v${XC32_VERSION}-XXXXXXXXXXXXXXXX)
sudo ${TEMP_INSTALLER} \
  --mode text \
  --unattendedmodeui minimal \
  --prefix ${TEMP_INSTALL_DIRECTORY} \
  --LicenseType FreeMode \
  --Add\ to\ PATH 0

# Change ownership, since the installer output is installed as root.
# TODO(willjschmitt): Another user or random user id is probably better than
#  using our user name.
sudo chown -R ${USER}:${USER} ${TEMP_INSTALL_DIRECTORY}

# Package the resultant output into a tar archive.
>&2 echo "Packaging compilers into tar..."
OUTPUT_TAR=xc32-v${XC32_VERSION}.tar.gz
tar -czf ${OUTPUT_TAR} -C ${TEMP_INSTALL_DIRECTORY} .
>&2 echo "Successfully installed and packaged XC32 into ${OUTPUT_TAR}."