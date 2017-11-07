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

function git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

function git_last_message() {
    git log -1 --pretty=%B
}

function main() {

    local branch='release'
    local message='(maven-release)'

    if [[ ! $(git_branch) =~ "$branch" ]]; then
        echo "Not on release branch, aborting!" >&2
        return -1
    fi

    if [[ $(git_last_message) =~ "$message" ]]; then
        echo "No changes since previous release, aborting!"
        echo "(Use --force to override and release anyway.)"
        return 0
    fi

    if [[ ! $(maven_evaluate project.version) =~ -SNAPSHOT$ ]]; then
        echo "Not on SNAPSHOT version, aborting!" >&2
        return -1
    fi

    echo "Setting the project version ..."
    maven_set_version $(get_date_version)

    echo "Building the project with the following command:"
    echo mvn $@

    mvn $@

    echo "Committing, tagging, and pushing ..."
    git commit -a -m "$message Preparing to release $(maven_evaluate project.groupId):$(maven_evaluate project.artifactId):$(maven_evaluate project.version)"
    git tag $(maven_evaluate project.version)
    git push
    git push --tags
}

set -e
main $*
exit $?
