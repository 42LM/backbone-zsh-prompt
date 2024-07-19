# BB - BackBone zsh prompt -- A bare 🦴 minimum backbone prompt -- git
# Maintainer:   Lukas Moeller <github.com/lmllrjr/backbone-zsh-prompt>
# Version:      0.1.0
#
# ℹ️  Get more Information:
#   https://zsh.sourceforge.io/Doc/Release/User-Contributions.html#Version-Control-Information
#
# 📃 Blueprint:
#   https://github.com/zsh-users/zsh/blob/master/Misc/vcs_info-examples

### Defining variables
# use ansi escape codes for terminal colors
# default colors picked with solarized theme
! [ -v BB_PROMPT_DIR ] && BB_PROMPT_DIR="13"
! [ -v BB_PROMPT_GIT ] && BB_PROMPT_GIT="10"
! [ -v BB_PROMPT_BRANCH ] && BB_PROMPT_BRANCH="1"
! [ -v BB_PROMPT_ACTION ] && BB_PROMPT_ACTION="3"
! [ -v BB_PROMPT_AHEAD_BEHIND ] && BB_PROMPT_AHEAD_BEHIND="4"
! [ -v BB_PROMPT_TAG ] && BB_PROMPT_TAG="14"
! [ -v BB_PROMPT_COUNT ] && BB_PROMPT_COUNT="14"

! [ -v BB_PROMPT_PROJECTS_PATH ] && BB_PROMPT_PROJECTS_PATH="${HOME}/code"
# disable checking only in the subtree of BB_PROMPT_PROJECTS_PATH
# by setting BB_PROMPT_PROJECTS to false
! [ -v BB_PROMPT_PROJECTS ] && BB_PROMPT_PROJECTS=true
! [ -v BB_PROMPT_SHOW_TAG ] && BB_PROMPT_SHOW_TAG=false
! [ -v BB_PROMPT_SIGN ] && BB_PROMPT_SIGN="%%"

## vim:ft=zsh

### Running vcs_info ######################################################### {{{

# Mark vcs_info for autoloading first
autoload -Uz vcs_info
autoload -Uz add-zsh-hook

# Allow substitutions and expansions in the prompt, necessary for
# using a single-quoted $vcs_info_msg_0_ in PS1, RPOMPT (as used here) and
# similar. Other ways of using the information are described above.
setopt promptsubst

# Default to running vcs_info. If possible we prevent running it later for
# speed reasons. If set to a non empty value vcs_info is run.
FORCE_RUN_VCS_INFO=1

# Only run vcs_info when necessary to speed up the prompt and make using
# check-for-changes bearable in bigger repositories. This setup was originally
# inspired by Bart Trojanowski
# (http://jukie.net/~bart/blog/pimping-out-zsh-prompt).
# Furthermore tweaked again by Seth House and Simon Ruderich
# (https://github.com/zsh-users/zsh/blob/master/Misc/vcs_info-examples)
#
# This setup is by no means perfect. It can only detect changes done
# through the VCS's commands run by the current shell. If you use your
# editor to commit changes to the VCS or if you run them in another shell
# this setup won't detect them. To fix this just run "cd ." which causes
# vcs_info to run and update the information. If you use aliases to run
# the VCS commands update the case check below.
zstyle ':vcs_info:*+pre-get-data:*' hooks pre-get-data
+vi-pre-get-data() {
    # Only Git and Mercurial support need caching.
    # For simplicity only Git support for caching is enabled.
    # Abort if any other VCS except Git is used.
    [[ "$vcs" != git ]] && return

    # If the shell just started up or we changed directories (or for other
    # custom reasons) we must run vcs_info.
    if [[ -n $FORCE_RUN_VCS_INFO ]]; then
        FORCE_RUN_VCS_INFO=
        return
    fi

    # If we got to this point, running vcs_info was not forced, so now we
    # default to not running it and selectively choose when we want to run
    # it (ret=0 means run it, ret=1 means don't).
    ret=1
    # If a git command was run then run vcs_info as the status might
    # need to be updated.
    case "$(fc -ln $((HISTCMD-1)))" in
        git*)
            ret=0
            ;;
    esac
}

### Helper for prompt_precmd
# Check if shell is running in WarpTerminal
warp_term_program() {
    if [[ ${TERM_PROGRAM} = "WarpTerminal" ]]; then
        echo true
        return
    fi

    echo false
}

# Call vcs_info as precmd before every prompt.
prompt_precmd() {
    # first run the system so everything is setup correctly.
    vcs_info

    # Only populate PS1 with vcs_info when the vcs_info_msg'es length is not zero
    if [[ -z ${vcs_info_msg_0_} ]]; then
        PS1=$'\n''%B%F{${BB_PROMPT_DIR}}%~%f'$'\n''%(?.%F{2}${BB_PROMPT_SIGN}.%F{9}${BB_PROMPT_SIGN})%f%b '
    else
        PS1=$'\n''%B%F{${BB_PROMPT_DIR}}%~%f ${vcs_info_msg_0_}'$'\n''%(?.%F{2}${BB_PROMPT_SIGN}.%F{9}${BB_PROMPT_SIGN})%f%b '
    fi
}
add-zsh-hook precmd prompt_precmd

# Must run vcs_info when changing directories.
prompt_chpwd() {
    FORCE_RUN_VCS_INFO=1
}
add-zsh-hook chpwd prompt_chpwd

############################################################################## }}}

### check-for-changes just in some places #################################### {{{

# For more information about the method of enabling `check-for-changes` only in a certain subtree:
#
# https://github.com/zsh-users/zsh/blob/c006d7609703afcfb2162c36d4f745125df45879/Misc/vcs_info-examples#L72-L105
#
# only enable the `check-for-changes` in `BB_PROMPT_PROJECTS_PATH`
# when `BB_PROMPT_PROJECTS` is set to true
if ${BB_PROMPT_PROJECTS}; then
    zstyle -e ':vcs_info:git:*' \
        check-for-changes 'estyle-cfc && reply=( true ) || reply=( false )'
else
    # activate checking for changes in general
    # using `check-for-staged-changes` is faster here
    # https://zsh.sourceforge.io/Doc/Release/User-Contributions.html#Version-Control-Information:~:text=disabled%20by%20default.-,check%2Dfor%2Dstaged%2Dchanges,-This%20style%20is
    zstyle ':vcs_info:git:*' check-for-changes true
fi

estyle-cfc() {
    local d
    local -a cfc_dirs
    cfc_dirs=(
        ${BB_PROMPT_PROJECTS_PATH}/*(/)
    )

    for d in ${cfc_dirs}; do
        d=${d%/##}
        [[ $PWD == $d(|/*) ]] && return 0
    done
    return 1
}

############################################################################## }}}

### Hooks #################################################################### {{{

# Debugging is off by default - of course.
# zstyle ':vcs_info:*+*:*' debug true

# Check the repository for changes so they can be used in %u/%c (see
# below). This comes with a speed penalty for bigger repositories.
# ⚠️ function estyle-cfc() already sets check-for-changes for my directory ⚠️
# check if projects option is enabled
# zstyle ':vcs_info:*' check-for-changes true
# zstyle ':vcs_info:*' get-revision true

# Alternatively, the following would set only %c, but is faster:
# zstyle ':vcs_info:*' check-for-changes false
# zstyle ':vcs_info:*' check-for-staged-changes true

# This string will be used in the %c escape if there are staged changes in the repository.
zstyle ':vcs_info:git*' stagedstr '∗'
# This string will be used in the %u escape if there are unstaged changes in the repository.
zstyle ':vcs_info:git*' unstagedstr '+'

zstyle ':vcs_info:git*' formats "%F{${BB_PROMPT_GIT}}%s:(%f%F{${BB_PROMPT_BRANCH}}%b%c%u%f%F{${BB_PROMPT_GIT}})%f%m"

zstyle ':vcs_info:git*' patch-format "%n/%c %p " # <- the space here is for a possible (±1≡7) after the rebase/merge information
# zstyle ':vcs_info:git*' nopatch-format ""
zstyle ':vcs_info:git*' actionformats "%F{${BB_PROMPT_GIT}}%s:(%f%F{${BB_PROMPT_BRANCH}}%b%c%u%f%F{${BB_PROMPT_GIT}})%f%F{${BB_PROMPT_ACTION}} %a %m%f"

### ORDER HERE MATTERS

if ${BB_PROMPT_SHOW_TAG}; then
    zstyle ':vcs_info:git*+set-message:*' hooks git-st git-count git-tag git-branch git-stash
else
    zstyle ':vcs_info:git*+set-message:*' hooks git-st git-count git-branch git-stash
fi

# original
# zstyle ':vcs_info:git*+set-message:*' hooks git-st git-count git-branch git-stash

# activate git-tag
# zstyle ':vcs_info:git*+set-message:*' hooks git-st git-count git-tag git-branch git-stash

# for debug purposes activate this instead: check out the keys of the hook_com var
# zstyle ':vcs_info:git*+set-message:*' hooks git-st git-count git-tag git-branch git-stash show-hook-keys

# Further down, every function that uses a `+vi-*' prefix uses a hook.

# git:

### SHOW hook_com keys <- debug purposes
#
# Output the key value pairs of hook_com
# zstyle ':vcs_info:git*+set-message:*' hooks show-hooks-keys
+vi-show-hook-keys() {
    # Check for key names
    for key val in "${(@kv)hook_com}"; do
        echo "$key -> $val"
    done
}

### Put a space between the branchname and the staged/unstaged sign
### when one of staged or unstaged is set
### %b%c%u -> %b %c%u
### git: Show marker (*) if git branch is dirty
### git: Show marker (+) if git branch has unstaged changes

# Make sure you have added staged to your 'formats':  %c
# zstyle ':vcs_info:git*+set-message:*' hooks git-branch
+vi-git-branch(){
    if [[ ${hook_com[staged]} != '' ]] ||
        [[ ${hook_com[unstaged]} != '' ]]; then
        hook_com[branch]+=' '
    fi
}

### Fetch the git tag for branch
### git: show (v.0.11.0) behind branchname if branch has tag
#
# Make sure you have added branch to your formats:  %b
# zstyle ':vcs_info:git*+set-message:*' hooks git-tag
+vi-git-tag(){
    local tag=$(git name-rev --name-only --no-undefined --always HEAD)
    if [[ -n ${tag} ]] && [[ ${tag} =~ [0-9] ]] && [[ ${tag[@]:0:4} == "tags" ]]; then
        hook_com[branch]+="%F{${BB_PROMPT_GIT}}/%f%F{${BB_PROMPT_TAG}}${tag[6, -1]}%f%F{${BB_PROMPT_BRANCH}}"
    else
        # due to unexpected behaviour when not finding a tag
        # the hook_com branch will be set to empty string value
        hook_com[branch]+=""
    fi
}

### Display changed file count on branch
### git: Show marker (±N) if count exists
#
# Make sure you have added misc to your 'formats':  %m
# zstyle ':vcs_info:git*+set-message:*' hooks git-count
+vi-git-count() {
    local -a changed_file_count

    # only display changed file count on branch when action is empty
    if [[ ${hook_com[action]} == '' ]]; then
        changed_file_count=$(git status -sb | wc -l)
        changed_file_count="$(($changed_file_count - 1))"
        if [[ ${changed_file_count} != 0 ]]; then
            # (%F{}) will set the default foreground color
            hook_com[misc]+="%F{${BB_PROMPT_COUNT}}±${changed_file_count}%f"
        fi
    fi
}

### Display count of stash
### git: Show marker (≡N) if stash exists
#
# Make sure you have added misc to your 'formats':  %m
# zstyle ':vcs_info:git*+set-message:*' hooks git-stash
+vi-git-stash() {
    local -a stash

    # only display changed file count on branch when action is empty
    if [[ ${hook_com[action]} == '' ]]; then
        if [[ -s ${hook_com[base]}/.git/refs/stash ]] ; then
            stash=$(git stash list 2>/dev/null | wc -l | xargs)
            n=${stash}
            if [[ -n ${stash} ]]; then
                stash='≡'
            fi
            hook_com[misc]+="%F{${BB_PROMPT_COUNT}}${stash}${n}%f"
        fi
    fi
}

### Compare local changes to remote changes
### git: Show ⇡N/⇣N when your local branch is ahead-of or behind remote HEAD.
#
# Make sure you have added misc to your 'formats':  %m
# zstyle ':vcs_info:git*+set-message:*' hooks git-st
+vi-git-st() {
    local ahead behind
    local -a gitstatus

    # only display changed file count on branch when action is empty
    if [[ ${hook_com[action]} == '' ]]; then
        # Exit early in case the worktree is on a detached HEAD
        git rev-parse ${hook_com[branch]}@{upstream} >/dev/null 2>&1 || return 0

        local -a ahead_and_behind=(
            $(git rev-list --left-right --count HEAD...${hook_com[branch]}@{upstream} 2>/dev/null)
        )

        ahead=${ahead_and_behind[1]}
        behind=${ahead_and_behind[2]}


        if (( $ahead )) && (( $behind )); then
            gitstatus+=( "%F{${BB_PROMPT_AHEAD_BEHIND}}⇡${ahead}%f%F{${BB_PROMPT_GIT}}/%f" )
            gitstatus+=( "%F{${BB_PROMPT_AHEAD_BEHIND}}⇣${behind}%f" )
        else
            (( $ahead )) && gitstatus+=( "%F{${BB_PROMPT_AHEAD_BEHIND}}⇡${ahead}%f" )
            (( $behind )) && gitstatus+=( "%F{${BB_PROMPT_AHEAD_BEHIND}}⇣${behind}%f" )
        fi

        hook_com[misc]+=${(j::)gitstatus}
    fi
}

### Show information about patch series
### git: show 2/4 (number of applied patches/number of unapplied patches)
#
# This is used with with git rebases and conflicts.
#
# All these cases have a notion of a "series of patches/commits" that is being
# applied.  The following shows the information about the most recent patch to
# have been applied:
# Make sure you have added the name of the top-most applied patch to your 'formats':  %p
zstyle ':vcs_info:*+gen-applied-string:*' hooks gen-applied-string
+vi-gen-applied-string() {
    local conflicted_file_count=$(git ls-files --unmerged | cut -f2 | sort -u | wc -l | Xargs)
    hook_com[applied-string]+="±${conflicted_file_count}"
    ret=1
}

############################################################################## }}}

# vim: set foldmethod=marker foldlevel=0:
