# 🦴 BackBone zsh prompt
BackBone is a prompt with the bare minimum needed for a working zsh prompt that tracks git changes.  
BB[^1] is ~a blazingly fast~ the roadrunner of the prompts! Be prepared for some [Meep! Meep! Moments](https://youtu.be/Hd2JgADY9d8).

I was in need of a super simple minimal prompt that fulfills my needs:
* fast
* easy setup
* single file
* git support
* minimal features

... furthermore i ended up building this one.

If you are like me and just looking for a prompt that is _"not more than the bare minimum needed"_  
**-- Stop looking!**

🚧 Please keep in mind: While this prompt is already battle tested it is still work in progress 🚧

## Install
### Clone the repository:
* Clone into `~/.zsh`
  ```zsh
  git clone git@github.com:lmllrjr/backbone-zsh-prompt.git ~/.zsh/backbone-zsh-prompt
  ```
* Clone into `~/.config/zsh`
  ```zsh
  git clone git@github.com:lmllrjr/backbone-zsh-prompt.git ~/.config/zsh/backbone-zsh-prompt
  ```

### For the purists, download the only relevant file `prompt.zsh`:
* Download to `~/.zsh`:
  ```zsh
  curl -JO https://github.com/lmllrjr/backbone-zsh-prompt/prompt.zsh --create-dirs --output-dir ~/.zsh/backbone-zsh-prompt
  ```
* Download to `~/.config/zsh`:
  ```zsh
  curl -JO https://github.com/lmllrjr/backbone-zsh-prompt/prompt.zsh --create-dirs --output-dir ~/.config/zsh/backbone-zsh-prompt
  ```

### Load the prompt in your `.zshrc` file:
* Load from `~/.zsh`:
  ```zsh
  # only load prompt if the `prompt.zsh` file exists
  [ -f $HOME/.zsh/backbone-zsh-prompt/prompt.zsh ] && \
  source $HOME/.zsh/backbone-zsh-prompt/prompt.zsh
  ```
* Load from `~/.config/zsh`:
  ```zsh
  # only load prompt if the `prompt.zsh` file exists
  [ -f $HOME/.config/zsh/backbone-zsh-prompt/prompt.zsh ] && \
  source $HOME/.config/zsh/backbone-zsh-prompt/prompt.zsh
  ```

## Screenshots
### formats
![formats](/screenshots/formats.png)
### actionformats
![actionformat](/screenshots/actionformats.png)

## Colorization options
| Option                 | Description                            | Default value |
|------------------------|----------------------------------------|---------------|
| BB_PROMPT_DIR          | The working directory                  | `#6c71c4`     |
| BB_PROMPT_GIT          | The shown VCS in use (`git:()`)        | `#586e75`     |
| BB_PROMPT_BRANCH       | The git branch name                    | `#dc322f`     |
| BB_PROMPT_ACTION       | The git actions rebase/merge           | `#b58900`     |
| BB_PROMPT_AHEAD_BEHIND | The ahead and behind arrows + counters | `#2aa198`     |
| BB_PROMPT_TAG          | The git tag                            | `#93a1a1`     |
| BB_PROMPT_COUNT        | Changed file count on branch           | `#93a1a1`     |

Just set the variables in your `.zshrc` file:
```zsh
export BB_PROMPT_DIR=6
export BB_PROMPT_GIT="#EEEEEE"
export BB_PROMPT_TAG="blue"
```

>**Note**:  
>If you want a fully-fledged prompt you should use one of the more sophisticated projects around github.  
>E.g. [Pure](https://github.com/sindresorhus/pure) ❤️.

## Todo
- [ ] better screenshots (do not forget ahead and behind)
- [ ] adjust color of slash in between ahead and behind
- [ ] adjust VARs (more/rmv?)


[^1]: BackBone zsh prompt
