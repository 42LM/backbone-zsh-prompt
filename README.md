<p align="center"><img src="https://i.imgur.com/2faISPH.png" width="800"></p>
<p align="right"><sub>* screenshot taken in <a href="https://github.com/warpdotdev/Warp">warp</a> terminal</sub></p> 
<h1 align="center">BB 🦴 -- backbone zsh prompt</h1>
<p align="center">A bare minimum single file prompt, fast as a roadrunner MEEP! MEEP! 💨 ...</p>

<br><br>

BackBone is a prompt with the bare minimum needed for a working zsh prompt that tracks git changes.  
BB[^1] is ~a blazingly fast~ the roadrunner of the prompts! Be prepared for some [Meep! Meep! Moments](https://youtu.be/Hd2JgADY9d8).

I was in need of a super simple minimal prompt that fulfills my needs. It has to be fast, easy to setup, a single file and have git support with minimal features. Furthermore i ended up building this one.

If you are like me and just looking for a prompt that is _"not more than the bare minimum needed"_  
**-- Stop looking!**

🚧 Please keep in mind: While this prompt is already battle tested it is still work in progress 🚧

## Table of Contents
* [Install](#install)
* [Explanation of elements](#explanation-of-elements)
* [Colorization options](#colorization-options)
* [Todo](#todo)

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
  curl -LJo ~/.zsh/backbone-zsh-prompt/prompt.zsh --create-dirs \
  https://github.com/lmllrjr/backbone-zsh-prompt/prompt.zsh
  ```
* Download to `~/.config/zsh`:
  ```zsh
  curl -LJo ~/.config/zsh/backbone-zsh-prompt/prompt.zsh --create-dirs \
  https://github.com/lmllrjr/backbone-zsh-prompt/prompt.zsh
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

## Explanation of elements
![](https://i.imgur.com/rR2qmX3.png)

## Colorization options
| Option                  | Description                              | Default value    |
|-------------------------|------------------------------------------|------------------|
| BB_PROMPT_DIR           | The working directory                    | `"#6c71c4"`      |
| BB_PROMPT_GIT           | The shown VCS in use (`git:()`)          | `"#586e75"`      |
| BB_PROMPT_BRANCH        | The git branch name                      | `"#dc322f"`      |
| BB_PROMPT_ACTION        | The git actions rebase/merge             | `"#b58900"`      |
| BB_PROMPT_AHEAD_BEHIND  | The ahead and behind arrows + counters   | `"#2aa198"`      |
| BB_PROMPT_TAG           | The git tag                              | `"#93a1a1"`      |
| BB_PROMPT_COUNT         | Changed file count on branch             | `"#93a1a1"`      |
|                         |                                          |                  |
| BB_PROMPT_PROJECTS_PATH | The path of the project folder           | `"${HOME}/code"` |
| BB_PROMPT_PROJECTS      | Turn the project folder option on or off | `true`           |

Just set the variables in your `.zshrc` file:
>**Warning**:  
>Make sure to set the vars before actually loading the prompt!

```zsh
export BB_PROMPT_DIR=6
export BB_PROMPT_GIT="#EEEEEE"
export BB_PROMPT_TAG="blue"
export BB_PROMPT_PROJECTS_PATH="${HOME}/my/projects/path"
export BB_PROMPT_PROJECTS=false
```

>**Note**:  
>If you want a fully-fledged prompt you should use one of the more sophisticated projects around github.  
>E.g. [Pure](https://github.com/sindresorhus/pure) ❤️.

## Todo
- [x] better screenshots (do not forget ahead and behind)
  - now has a better and more appealing picture that explains the elements of the prompt
- [x] adjust color of slash in between ahead and behind
  - now has the color of `BB_PROMPT_GIT`
- [x] option to turn off estyle-cfc / only checking for changes in `~/code/...`
  - furthermore there is another option to set the directory of the projects folder
- [ ] option for showing git tag!?
- [ ] adjust VARs (more/rmv?)
- [ ] remove more unused code!?


[^1]: BackBone zsh prompt
