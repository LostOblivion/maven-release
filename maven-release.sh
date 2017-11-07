#!/usr/bin/env bash

function maven_evaluate() {
    mvn org.codehaus.mojo:exec-maven-plugin:1.6.0:exec \
        --quiet \
        --non-recursive \
        -D exec.executable="echo" \
        -D exec.args="'\${$1}'"
}

function maven_set_version() {
    mvn org.codehaus.mojo:versions-maven-plugin:2.5:set \
        -D newVersion=$1
}

function get_date_version() {
    date '+%Y%m%d%H%M%S'
}

function parse_git_branch() {
     git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

function main() {

    if [[ ! $(parse_git_branch) =~ release ]]; then
        echo "Not on release branch, aborting!" >&2
        return -1
    fi

    if [[ ! $(maven_evaluate project.version) =~ -SNAPSHOT$ ]]; then
        echo "Not on SNAPSHOT version, aborting!" >&2
        return -1
    fi

    maven_set_version $(get_date_version)
}

main
exit $?
