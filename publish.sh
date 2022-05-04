#!/bin/sh

COLOR_RED='\033[0;31m'          # Red
COLOR_GREEN='\033[0;32m'        # Green
COLOR_YELLOW='\033[0;33m'       # Yellow
COLOR_BLUE='\033[0;94m'         # Blue
COLOR_PURPLE='\033[0;35m'       # Purple
COLOR_OFF='\033[0m'             # Reset

print() {
    printf '%b' "$*"
}

echo() {
    printf '%b\n' "$*"
}

info() {
    printf '%b\n' "💠  $*"
}

note() {
    printf '%b\n' "${COLOR_YELLOW}🔔  $*${COLOR_OFF}" >&2
}

warn() {
    printf '%b\n' "${COLOR_YELLOW}🔥  $*${COLOR_OFF}" >&2
}

success() {
    printf '%b\n' "${COLOR_GREEN}[✔] $*${COLOR_OFF}"
}

error() {
    printf '%b\n' "${COLOR_RED}💔  $*${COLOR_OFF}" >&2
}

die() {
    printf '%b\n' "${COLOR_RED}💔  $*${COLOR_OFF}" >&2
    exit 1
}

# check if file exists
# $1 FILEPATH
file_exists() {
    [ -n "$1" ] && [ -e "$1" ]
}

# check if command exists in filesystem
# $1 command name or path
command_exists_in_filesystem() {
    case $1 in
        */*) executable "$1" ;;
        *)   command -v "$1" > /dev/null
    esac
}

executable() {
    file_exists "$1" && [ -x "$1" ]
}

die_if_file_is_not_exist() {
    file_exists "$1" || die "$1 is not exists."
}

die_if_not_executable() {
    executable "$1" || die "$1 is not executable."
}

step() {
    STEP_NUM=$(expr ${STEP_NUM-0} + 1)
    STEP_MESSAGE="$@"
    echo
    echo "${COLOR_PURPLE}=>> STEP ${STEP_NUM} : ${STEP_MESSAGE} ${COLOR_OFF}"
}

run() {
    echo "$COLOR_PURPLE==>$COLOR_OFF $COLOR_GREEN$@$COLOR_OFF"
    eval "$*"
}

sed_in_place() {
    if command -v gsed > /dev/null ; then
        unset SED_IN_PLACE_ACTION
        SED_IN_PLACE_ACTION="$1"
        shift
        # contains ' but not contains \'
        if printf "$SED_IN_PLACE_ACTION" | hexdump -v -e '1/1 "%02X" " "' | grep -q 27 && ! printf "$SED_IN_PLACE_ACTION" | hexdump -v -e '1/1 "%02X" ""' | grep -q '5C 27' ; then
            run gsed -i "\"$SED_IN_PLACE_ACTION\"" $@
        else
            run gsed -i "'$SED_IN_PLACE_ACTION'" $@
        fi
    elif command -v sed  > /dev/null ; then
        if sed -i 's/a/b/g' $(mktemp) 2> /dev/null ; then
            unset SED_IN_PLACE_ACTION
            SED_IN_PLACE_ACTION="$1"
            shift
            if printf "$SED_IN_PLACE_ACTION" | hexdump -v -e '1/1 "%02X" " "' | grep -q 27 && ! printf "$SED_IN_PLACE_ACTION" | hexdump -v -e '1/1 "%02X" ""' | grep -q '5C 27' ; then
                run sed -i "\"$SED_IN_PLACE_ACTION\"" $@
            else
                run sed -i "'$SED_IN_PLACE_ACTION'" $@
            fi
        else
            unset SED_IN_PLACE_ACTION
            SED_IN_PLACE_ACTION="$1"
            shift
            if printf "$SED_IN_PLACE_ACTION" | hexdump -v -e '1/1 "%02X" " "' | grep -q 27 && ! printf "$SED_IN_PLACE_ACTION" | hexdump -v -e '1/1 "%02X" ""' | grep -q '5C 27' ; then
                run sed -i '""' "\"$SED_IN_PLACE_ACTION\"" $@
            else
                run sed -i '""' "'$SED_IN_PLACE_ACTION'" $@
            fi
        fi
    else
        die "please install sed utility."
    fi
}

#examples:
# printf ss | sha256sum
# cat FILE  | sha256sum
# sha256sum < FILE
sha256sum() {
    if [ $# -eq 0 ] ; then
        if echo | command sha256sum > /dev/null 2>&1 ; then
             command sha256sum | cut -d ' ' -f1
        elif command -v openssl > /dev/null ; then
             openssl sha256 | rev | cut -d ' ' -f1 | rev
        else
            return 1
        fi
    else
        die_if_file_is_not_exist "$1"
        if command -v openssl > /dev/null ; then
             openssl sha256    "$1" | cut -d ' ' -f2
        elif echo | command sha256sum > /dev/null 2>&1 ; then
             command sha256sum "$1" | cut -d ' ' -f1
        else
            die "please install openssl or GNU CoreUtils."
        fi
    fi
}

die_if_command_not_found() {
    for item in $@
    do
        command_exists_in_filesystem $item || die "$item command not found."
    done
}

main() {
    for arg in $@
    do
        case $arg in
            -x) set -x ; break
        esac
    done

    set -e

    die_if_command_not_found tar gzip git gh

    while [ -n "$1" ]
    do
        case $1 in
            -x) ;;
            *) die "unrecognized argument: $1"
        esac
        shift
    done

    unset RELEASE_VERSION
    RELEASE_VERSION=$(bin/walle --version)

    RELEASE_DIR="walle-cli-$RELEASE_VERSION"
    RELEASE_FILE_NAME="$RELEASE_DIR.tar.gz"

    _on_exit() {
        if [ -d    "$RELEASE_DIR" ] ; then
            rm -rf "$RELEASE_DIR"
        fi
        if [ -f "$RELEASE_FILE_NAME" ] ; then
            rm  "$RELEASE_FILE_NAME"
        fi
    }

    trap _on_exit EXIT

    ln -sf . "$RELEASE_DIR"

    run tar zvcf "$RELEASE_FILE_NAME" "$RELEASE_DIR/bin/walle" "$RELEASE_DIR/lib/walle-cli-all.jar" "$RELEASE_DIR/zsh-completion/_walle"

    unset RELEASE_FILE_SHA256SUM
    RELEASE_FILE_SHA256SUM=$(sha256sum "$RELEASE_FILE_NAME")

    success "sha256sum($RELEASE_FILE_NAME)=$RELEASE_FILE_SHA256SUM"

    run gh release create v"$RELEASE_VERSION" "$RELEASE_FILE_NAME" --notes "'release $RELEASE_VERSION'"

    run git clone git@github.com:leleliu008/homebrew-fpliu.git

    run cd homebrew-fpliu

    sed_in_place "/sha256   /c \  sha256   \"$RELEASE_FILE_SHA256SUM\"" Formula/walle-cli.rb
    sed_in_place "s@[0-9]\+\.[0-9]\+\.[0-9]\+@$RELEASE_VERSION@g"       Formula/walle-cli.rb

    run git add Formula/walle-cli.rb
    run git commit -m "'publish new version walle-cli $RELEASE_VERSION'"
    run git push origin master

    run cd ..

    run rm -rf homebrew-fpliu
    run rm "$RELEASE_FILE_NAME"
}

CURRENT_SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd) || exit 1

main $@
