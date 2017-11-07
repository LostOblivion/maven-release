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
        -D newVersion=$1 \
        -D generateBackupPoms=false
}

function get_date_version() {
    date '+%Y%m%d%H%M%S'
}

function git_last_message() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

function git_branch() {
    git log -1 --pretty=%B
}

function main() {

    if [[ ! $(git_last_message) =~ ^release$ ]]; then
        echo "Not on release branch, aborting!" >&2
        return -1
    fi

    if [[ ! $(maven_evaluate project.version) =~ -SNAPSHOT$ ]]; then
        echo "Not on SNAPSHOT version, aborting!" >&2
        return -1
    fi

    if [[ $(git_last_message) =~ \(maven-release\) ]]; then
        echo "No changes since previous release, aborting!"
        echo "(Use --force to override and release anyway.)"
        return 0
    fi

    maven_set_version $(get_date_version)

    mvn clean deploy -B -P release-profile

    git commit -a -m "(maven-release) Preparing to release $(maven_evaluate project.groupId):$(maven_evaluate project.artifactId):$(maven_evaluate project.version)"
}

set -e
main
exit $?
