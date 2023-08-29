# The minimum backbone 🦴 zsh prompt

# ℹ️  Get more Information:
#   https://zsh.sourceforge.io/Doc/Release/User-Contributions.html#Version-Control-Information
#
# 📃 Blueprint:
#   https://github.com/zsh-users/zsh/blob/master/Misc/vcs_info-examples

### Defining variables
! [ -v BB_PROMPT_DIR ] && BB_PROMPT_DIR="#6c71c4"
! [ -v BB_PROMPT_GIT ] && BB_PROMPT_GIT="#586e75"
! [ -v BB_PROMPT_BRANCH ] && BB_PROMPT_BRANCH="#dc322f"
! [ -v BB_PROMPT_ACTION ] && BB_PROMPT_ACTION="#b58900"
! [ -v BB_PROMPT_AHEAD_BEHIND ] && BB_PROMPT_AHEAD_BEHIND="#2aa198"
! [ -v BB_PROMPT_TAG ] && BB_PROMPT_TAG="#93a1a1"
! [ -v BB_PROMPT_COUNT ] && BB_PROMPT_COUNT="#93a1a1"
# TODO: one missing var for delimiter in ahead behind

## vim:ft=zsh

### Running vcs_info #########################################################

# Mark vcs_info for autoloading first
autoload -Uz vcs_info

# Allow substitutions and expansions in the prompt, necessary for
# using a single-quoted $vcs_info_msg_0_ in PS1, RPOMPT (as used here) and
# similar. Other ways of using the information are described above.
setopt promptsubst

# Default to running vcs_info. If possible we prevent running it later for
# speed reasons. If set to a non empty value vcs_info is run.
FORCE_RUN_VCS_INFO=1

# Only run vcs_info when necessary to speed up the prompt and make using
# check-for-changes bearable in bigger repositories. This setup was
# inspired by Bart Trojanowski
# (http://jukie.net/~bart/blog/pimping-out-zsh-prompt).
#
# This setup is by no means perfect. It can only detect changes done
# through the VCS's commands run by the current shell. If you use your
# editor to commit changes to the VCS or if you run them in another shell
# this setup won't detect them. To fix this just run "cd ." which causes
# vcs_info to run and update the information. If you use aliases to run
# the VCS commands update the case check below.
zstyle ':vcs_info:*+pre-get-data:*' hooks pre-get-data
+vi-pre-get-data() {
    # Only Git and Mercurial support and need caching. Abort if any other
    # VCS is used.
    [[ "$vcs" != git && "$vcs" != hg ]] && return

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
    # If a git/hg command was run then run vcs_info as the status might
    # need to be updated.
    case "$(fc -ln $(($HISTCMD-1)))" in
        git*)
            ret=0
            ;;
        hg*)
            ret=0
            ;;
    esac
}

### Helper for prompt_precmd
# Check if shell is running in WarpTerminal
function warp_term_program() {
    if [ "$TERM_PROGRAM" = "WarpTerminal" ]; then
        echo true
        return
    fi

    echo false
}

# Call vcs_info as precmd before every prompt.
prompt_precmd() {
    # As always first run the system so everything is setup correctly.
    vcs_info
    # And then just set PS1, RPS1 and whatever you want to. This $PS1
    # is (as with the other examples above too) just an example of a very
    # basic single-line prompt. See "man zshmisc" for details on how to
    # make this less readable. :-)
    if [[ -z ${vcs_info_msg_0_} ]]; then
        # Oh hey, nothing from vcs_info, so we got more space.
        # Let's print a longer part of $PWD...
        if $(warp_term_program); then
            PS1="%B%F{${BB_PROMPT_DIR}}%~%f"
        else
            PS1=$'\n''%B%F{${BB_PROMPT_DIR}}%~%f'$'\n'$'\U0001F9B4''%f%b '
        fi
    else
        # vcs_info found something, that needs space. So a shorter $PWD
        # makes sense.

        if $(warp_term_program); then
            PS1="%B%F{${BB_PROMPT_DIR}}%~%f ${vcs_info_msg_0_}%b"
        else
            PS1=$'\n''%B%F{${BB_PROMPT_DIR}}%~%f ${vcs_info_msg_0_}'$'\n'$'\U0001F9B4''%f%b '
        fi
    fi
}
add-zsh-hook precmd prompt_precmd

# Must run vcs_info when changing directories.
prompt_chpwd() {
    FORCE_RUN_VCS_INFO=1
}
add-zsh-hook chpwd prompt_chpwd

### check-for-changes just in some places ####################################

# Some backends (git and mercurial at the time of writing) can tell you
# whether there are local changes in the current repository. While that's
# nice, the actions needed to obtain the information can be potentially
# expensive. So if you're working on something the size of the linux kernel
# or some corporate code monstrosity you may want to think twice about
# enabling the `check-for-changes' style unconditionally.
#
# Zsh's zstyle configuration system let's you do some magic to enable styles
# only depending on some code you're running.
#
# So, what I'm doing is this: I'm keeping my own projects in `~/code'.
# There are the projects I want the information for most. They are also
# a lot smaller than the linux kernel so the information can be retrieved
# instantaneously - even on my old laptop at 600MHz. And the following code
# enables `check-for-changes' only in that subtree:

zstyle -e ':vcs_info:git:*' \
    check-for-changes 'estyle-cfc && reply=( true ) || reply=( false )'

function estyle-cfc() {
    local d
    local -a cfc_dirs
    cfc_dirs=(
        ${HOME}/code/*(/)
    )

    for d in ${cfc_dirs}; do
        d=${d%/##}
        [[ $PWD == $d(|/*) ]] && return 0
    done
    return 1
}

### Hooks ####################################################################

# Debugging is off by default - of course.
# zstyle ':vcs_info:*+*:*' debug true

# Check the repository for changes so they can be used in %u/%c (see
# below). This comes with a speed penalty for bigger repositories.
# ⚠️ function estyle-cfc() already sets check-for-changes for my directory ⚠️
# zstyle ':vcs_info:*' check-for-changes true
# zstyle ':vcs_info:*' get-revision true

# Alternatively, the following would set only %c, but is faster:
# zstyle ':vcs_info:*' check-for-changes false
zstyle ':vcs_info:*' check-for-staged-changes true

# This string will be used in the %c escape if there are staged changes in the repository.
zstyle ':vcs_info:git*' stagedstr '∗'
zstyle ':vcs_info:git*' unstagedstr '+'

zstyle ':vcs_info:git*' formats "%F{${BB_PROMPT_GIT}}%s:(%f%F{${BB_PROMPT_BRANCH}}%b%c%u%f%F{${BB_PROMPT_GIT}})%f%m"

zstyle ':vcs_info:git*' patch-format "%n/%c %p " # <- the space here is for a possible (±1≡7) after the rebase/merge information
# zstyle ':vcs_info:git*' nopatch-format ""
zstyle ':vcs_info:git*' actionformats "%F{${BB_PROMPT_GIT}}%s:(%f%F{${BB_PROMPT_BRANCH}}%b%c%u%f%F{${BB_PROMPT_GIT}})%f%F{${BB_PROMPT_ACTION}} %a %m%f"

### ORDER HERE MATTERS

# original
zstyle ':vcs_info:git*+set-message:*' hooks git-st git-count git-branch git-stash

# activate git-tag
# zstyle ':vcs_info:git*+set-message:*' hooks git-st git-count git-tag git-branch git-stash

# for debug purposes activate this instead: check out the keys of the hook_com var
# zstyle ':vcs_info:git*+set-message:*' hooks git-st git-count git-branch git-stash show-hook-keys

# Further down, every function that uses a `+vi-*' prefix uses a hook.

# git:

### SHOW hook_com keys <- debug purposes
# zstyle ':vcs_info:hg*+set-message:*' hooks hg-fullglobalrev

# Output the key value pairs of hook_com
function +vi-show-hook-keys() {
    # Check for key names
    for key val in "${(@kv)hook_com}"; do
        echo "$key -> $val"
    done
}

### Truncate Long Hashes

### Truncate a long hash to 12 characters (which is usually unique enough)
# Use zformat syntax (remember %i is the hash): %12.12i

### Fetch the full 40-character Mercurial revision id
# There is no great way to obtain branch, local rev, and untracked changes in
# addition to the full 40-character global rev id with a single invocation of
# Mercurial. This hook obtains the full global rev id using xxd(1) (in the
# same way the use-simple flag does) while retaining all the other vcs_info
# default functionality and information.
# zstyle ':vcs_info:hg*+set-message:*' hooks hg-fullglobalrev

# Output the full 40-char global rev id
function +vi-hg-fullglobalrev() {
    local dirstatefile="${hook_com[base]}/.hg/dirstate"
    local grevid="$(xxd -p -l 20 < ${dirstatefile})"
    # Omit %h from your hgrevformat since it will be included below
    hook_com[revision]="${hook_com[revision]} ${grevid}"
}

### Put a space between the branchname and the staged/unstaged sign
### when one of staged or unstaged is set
### %b%c%u -> %b %c%u

### git: Show marker (*) if git branch is dirty
### git: Show marker (+) if git branch has unstaged changes
# zstyle ':vcs_info:git*+set-message:*' hooks git-branch

# Make sure you have added staged to your 'formats':  %c
function +vi-git-branch(){
    if [[ ${hook_com[staged]} != '' ]] ||
        [[ ${hook_com[unstaged]} != '' ]]; then
        hook_com[branch]+=' '
    fi
}

### Fetch the git tag for branch

### git: show (v.0.11.0) behind branchname if branch has tag
# zstyle ':vcs_info:hg*+set-message:*' hooks hg-fullglobalrev

# Make sure you have added branch to your formats: %b
+vi-git-tag(){
    local tag=$(git name-rev --name-only --no-undefined --always HEAD)
    [[ -n ${tag} ]] && [[ ${tag} =~ [0-9] ]] && hook_com[branch]+="%F{${BB_PROMPT_GIT}}/%f%F{${BB_PROMPT_TAG}}${tag[6, -1]}%f%F{${BB_PROMPT_BRANCH}}"
}

### Display changed file count on branch

### git: Show marker (±N) if count exists
# zstyle ':vcs_info:git*+set-message:*' hooks git-count

# Make sure you have added misc to your 'formats':  %m
function +vi-git-count() {
    local -a changedFileCount

    # only display changed file count on branch when action is empty
    if [[ ${hook_com[action]} == '' ]]; then
        changedFileCount=$(git status -sb | wc -l)
        changedFileCount="$(($changedFileCount - 1))"
        if [[ ${changedFileCount} != 0 ]]; then
            # (%F{}) will set the default foreground color
            hook_com[misc]+="%F{${BB_PROMPT_COUNT}}±${changedFileCount}%f"
        fi
    fi
}

### Display count of stash

### git: Show marker (≡N) if stash exists
# zstyle ':vcs_info:git*+set-message:*' hooks git-stash

# Make sure you have added misc to your 'formats':  %m
function +vi-git-stash() {
    local -a stash
    local -a changedFileCount

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
# Make sure you have added misc to your 'formats':  %m
# zstyle ':vcs_info:git*+set-message:*' hooks git-st
function +vi-git-st() {
    local ahead behind
    local -a gitstatus

    # Exit early in case the worktree is on a detached HEAD
    git rev-parse ${hook_com[branch]}@{upstream} >/dev/null 2>&1 || return 0

    local -a ahead_and_behind=(
        $(git rev-list --left-right --count HEAD...${hook_com[branch]}@{upstream} 2>/dev/null)
    )

    ahead=${ahead_and_behind[1]}
    behind=${ahead_and_behind[2]}

    (( $ahead )) && gitstatus+=( "%F{${BB_PROMPT_AHEAD_BEHIND}}⇡${ahead}%f" )
    (( $behind )) && gitstatus+=( "%F{${BB_PROMPT_AHEAD_BEHIND}}⇣${behind}%f" )

    hook_com[misc]+=${(j:%F{9}/%f:)gitstatus}
}


### Show information about patch series
# This is used with with hg mq, quilt, and git rebases and conflicts.
#
# All these cases have a notion of a "series of patches/commits" that is being
# applied.  The following shows the information about the most recent patch to
# have been applied:
zstyle ':vcs_info:*+gen-applied-string:*' hooks gen-applied-string
function +vi-gen-applied-string() {
    local conflictedFileCount=$(git ls-files --unmerged | cut -f2 | sort -u | wc -l | Xargs)
    hook_com[applied-string]+="±${conflictedFileCount}"
    ret=1
}
