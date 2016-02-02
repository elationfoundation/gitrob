#!/usr/bin/env bash

#!/usr/bin/env bash
#
# This file is part of rss-keyword-collector, a package that reads rss feeds and extracts keywords from them..
# Copyright © 2016 seamus tuohy, <s2e at seamustuohy.com>
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the included LICENSE file for details.

# Setup

#Bash should terminate in case a command or chain of command finishes with a non-zero exit status.
#Terminate the script in case an uninitialized variable is accessed.
#See: https://github.com/azet/community_bash_style_guide#style-conventions
set -e
set -u

# TODO remove DEBUGGING
set -x

# Read Only variables

#readonly PROG_DIR=$(readlink -m $(dirname $0))
#readonly readonly PROGNAME=$(basename )
#readonly PROGDIR=$(readlink -m $(dirname ))

readonly testing_user=vagrant
readonly testing_group=rsskeyword
readonly nltk_data_dir='/usr/lib/nltk_data'


main() {
    base_setup
    dependencies
    set_environment_vars
}

set_environment_vars() {
    # Store testing systems config values in the environment
    echo "RKC_DB_NAME=$RKC_DB_NAME" >> /etc/environment
    echo "RKC_DB_USER=$RKC_DB_USER" >> /etc/environment
    echo "RKC_DB_PASS=$RKC_DB_PASS" >> /etc/environment
    echo "RKC_DB_HOST=$RKC_DB_HOST" >> /etc/environment
    echo "RKC_DB_PORT=$RKC_DB_PORT" >> /etc/environment
}


base_setup() {
    apt-get update
}

dependencies() {
    apt_install "git"
    apt_install "ruby"
    apt_install "ruby-dev"
    apt_install "rubygems"
}

# Installation helpers

apt_install(){
    local package="${1}"
    local installed=$(dpkg --get-selections \
                               | grep -v deinstall \
                               | grep -E "^${package}\s+install"\
                               | grep -o "${package}")
    if [[ "${installed}" = ""  ]]; then
        echo "Installing ${package} via apt-get"
        sudo apt-get -y install "${package}"
        echo "Installation of ${package} completed."
    else
        echo "${package} already installed. Skipping...."
    fi
}

get_git_package() {
    local package_dir="${1}"
    local repo="${2}"
    if [[ ! -e $package_dir ]]; then
        git clone "$repo"  "$package_dir"
    else # Update to the latest version for good measure.
        git --git-dir="$package_dir"/.git --work-tree="$package_dir"  pull
    fi
}

main
