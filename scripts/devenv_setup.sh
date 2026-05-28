#!/bin/bash

# This file replaces .bashrc in our Docker compose development environments
# It performs basic actions needed to set up a correctly working development environment.

# Set CONAN_DEFAULT_PROFILE_PATH to avoid ABI issues
# We can't do this statically in compose.yml because we file differs per architecture
# For compatibility, check if $(pwd)/.docker/linux_$(uname -m).profile exists first
# Also check if a profile already exists to avoid overwriting it with a default one
if [ -f "$(pwd)/.conan/linux_$(uname -m).profile" ] && [ ! -f "/root/.conan2/profiles/default" ]; then
    mkdir -p /root/.conan2/profiles
    cp "$(pwd)/.conan/linux_$(uname -m).profile" /root/.conan2/profiles/default
fi

# Set history file to a location inside the container workspace, to keep it persistent across sessions.
export HISTFILE="$(pwd)/.docker/.bash_history"

# Source the regular bashrc to keep usual settings
. ~/.bashrc