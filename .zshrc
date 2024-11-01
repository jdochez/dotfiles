# If you come from bash you might have to change your $PATH.
export OS_NAME=`uname | tr "[:upper:]" "[:lower:]"`
if [ $OS_NAME = "darwin" ]
then
  export JAVA_HOME=$HOME/src/studio-main/prebuilts/studio/jdk/jdk17/mac-arm64/Contents/Home
  export OS_LABEL="mac_arm"
else
  export JAVA_HOME=$HOME/src/studio-main/prebuilts/studio/jdk/jdk17/$OS_NAME
  export OS_LABEL=$OS_NAME
fi
export PATH=$HOME/bin:$JAVA_HOME/bin:$PATH:/opt/homebrew/bin:$HOME/.cargo/bin:$HOME/tools/cli/diff-so-fancy

# PATH to site functions
export FPATH=$FPATH:/opt/homebrew/share/zsh/site-functions

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?ins
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git z colored-man-pages gradle repo colorize zsh-autosuggestions zsh-syntax-highlighting bgnotify dirhistory)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#
alias python="python3"
alias vi="nvim"

prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
#    prompt_segment black default "%(!.%{%F{yellow}%}.)$USER"
  fi
}

# old desktop settings.
#
# export GDK_SCALE=1
# export GDK_DPI_SCALE=1
# export QT_AUTO_SCREEN_SCALE_FACTOR=1

# 
# NNN plugins
#
export NNN_FIFO=/tmp/nnn.fifo
export NNN_PLUG='f:finder;o:fzopen;d:diffs;t:nmount;v:imgview;p:preview-tui'

#
# F Z F Options
#
export FZF_DEFAULT_OPTS="--height=40% --preview='cat {}' --preview-window=right:60%:wrap"
if [ $OS_NAME = "linux" ]
then
  source /usr/share/doc/fzf/examples/completion.zsh
else
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi

#
# V A R I O U S   CLI UTILS
#
eval $(thefuck --alias fix) 

#
# G E N E R A L related functions
#
function notify-send {
if [ $OS_NAME = "Darwin" ]
then
  osascript -e 'display notification "Command Finished" with title "Terminal"'
else
  /usr/bin/notify-send $*
fi
}

#
# C R D specific settings
#
# export CHROME_REMOTE_DESKTOP_DEFAULT_DESKTOP_SIZES="3456x2160,3840x2160"

#
# AGP Related functions
# 
function build_test {
   $WORKSPACE_LOCATION/tools/gradlew $*
}

function debug_build_test {
$WORKSPACE_LOCATION/tools/gradlew --no-daemon -Dorg.gradle.debug=true $*
}

function clean_up_ssd {
    rm -rf $WORKSPACE_LOCATION/out/build/base/build-system/integration-test/application/build/GRADLE_USER_HOME
    rm -rf $WORKSPACE_LOCATION/out/build/base/build-system/integration-test/native/build/GRADLE_USER_HOME

}

function build_agp {
  if [ $# -eq 0 ]
  then
    bazel //build/tools/gmaven
  else
    bazel --config=$1 //build/tools/gmaven
  fi
}

#
# G R A D L E related functions
#

function integ_tests {
  gradle :base:build-system:integration-test:application:test
  clean_up_ssd
  notify-send "Gradle integration tests finished"
}

function integ_test {
  echo testing $*
  gradle :base:build-system:integration-test:application:test --tests $*
}

function debug_integ_test {
  gradle :base:build-system:integration-test:application:test --tests $* --debug-jvm
}

function databinding_test {
  echo testing $argv
  gradle :base:build-system:integration-test:databinding:test --tests $*
}

function databinding_tests {
  gradle :base:build-system:integration-test:databinding:test
}

function debug_databinding_test {
  echo testing $argv
  gradle :base:build-system:integration-test:databinding:test --tests $* --debug-jvm
}

function native_tests {
  gradle :base:build-system:integration-test:native:test
  clean_up_ssd
  notify-send "Gradle Native integration tests finished"
}

function grd {
gradle -Dorg.gradle.debug=true $*
}

function go_to_test {
  if [ $# -eq 0 ]
  then
    cd $WORKSPACE_LOCATION/out/build/base/build-system/integration-test/application/build/tests
  else
    cd $WORKSPACE_LOCATION/out/build/base/build\-system/integration-test/application/build/tests/$1
  fi
}

function gct {
  gradle :base:build-system:gradle-core:test
}

function gat {
  gradle :base:gradle-api:test :base:gradle-api:metalavaTest :base:gradle-api:updateDeprecatedApi
}

#
# B A Z E L related functions.
#
function bct {
	bazel test //tools/base/build-system/gradle-core:tests
}

function bazel_databinding_tests {
  bazel test //tools/base/build-system/integration-test/databinding:tests
}

function bazel_databinding_test {
  bazel test //tools/base/build-system/integration-test/databinding:tests  --nocache_test_results --strategy=TestRunner=standalone --sandbox_debug=true --test_sharding_strategy=disabled --test_filter=$*
}

function bazel_integ_test {
  echo testing $*
  bazel test //tools/base/build-system/integration-test/application:tests --test_sharding_strategy=disabled --test_filter=$*
}

function bazel_integ_tests {
  bazel test //tools/base/build-system/integration-test/application:tests
  notify-send "Bazel integration tests finished"
}

function bazel_unit_tests {
  bazel test -- //tools/base/build-system/... -//tools/base/build-system/integration-test/...
  notify-send "Bazel unit tests finished"
}

#
# G E N E R A L functions
#
function build_studio {
bazel build //tools/adt/idea/studio:android-studio
pushd $HOME/tools
if [ $OS_NAME = "darwin" ]
then
  export STUDIO_DIR_NAME="Android Studio Preview.app"
else 
  export STUDIO_DIR_NAME="android-studio"
fi
rm -rf $STUDIO_DIR_NAME
unzip -q $WORKSPACE_LOCATION/bazel-bin/tools/adt/idea/studio/android-studio.$OS_LABEL.zip
echo "Android Studio ready at $HOME/tools/$STUDIO_DIR_NAME"
popd
}

function ws {
if [ $# -eq 0 ]
  then
workspace="studio-main"
else
workspace=$1
fi
cd $HOME/src/$workspace/tools/base
export WORKSPACE_LOCATION=$HOME/src/$workspace
export CUSTOM_REPO=$HOME/src/$workspace/out/repo:$HOME/src/$workspace/prebuilts/tools/common/m2/repository
export STUDIO_CUSTOM_REPO=$HOME/src/$workspace/out/repo
export ANDROID_HOME=$WORKSPACE_LOCATION/prebuilts/studio/sdk/$OS_NAME
export ANDROID_NDK_HOME=$ANDROID_HOME/ndk-bundle
echo "CUSTOM_REPO and STUDIO_CUSTOM_REPO set to $CUSTOM_REPO"
rm ~/bin/bazel
ln -s $HOME/src/$workspace/tools/base/bazel/bazel ~/bin/bazel
rm ~/bin/adb
ln -s $HOME/src/$workspace/prebuilts/studio/sdk/$OS_NAME/platform-tools/adb ~/bin/adb
chmod a+x ~/bin/bazel
}

function create_branch {
  if [ $# -eq 0 ] 
  then
    echo "error: branch name not provided"
    exit 1
  fi
  current_branch=`git rev-parse --abbrev-ref HEAD`
  echo "creating branch $1 on top of $current_branch"
  repo start $1 .
  git reset --hard $current_branch
}

function rebase_from {
  if [ $# -eq 0 ]
  then
    echo "error: branch name not provided"
    exit 1
  fi
  current_branch=`git rev-parse --abbrev-ref HEAD`
  echo "rebasing branch $current_branch from $1 ?"
  read REPLY
  case "$REPLY" in
    y)
    git rebase --onto $1 HEAD^
    ;;
  esac
}

function prepare_api_release {
        pushd  $WS_ROOT/out/apiTests
        find . -name "build" | grep -v src | xargs rm -rf
        find . -name "build.gradle.kts" | grep buildSrc | xargs sed -i '5,9d'
        find . -maxdepth 2 -mindepth 2 -type d | xargs -I{} sh -c 'pushd {}; $WS_ROOT/tools/gradlew -Dorg.gradle.jvmargs=-Xmx2G assDeb ; popd'
        find . -name "build" | grep -v src | xargs rm -rf
        find . -name ".gradle" | xargs rm -rf
        popd
        cp -r $WS_ROOT/out/apiTests/* ~/src/gradle-recipes
}

alias weather='curl wttr.in/Portland\?m'
alias gs='git status'
alias gr='gradle'
alias batz='fzf | xargs bat'
alias catz='fzf | xargs cat'
alias br="google-chrome"
alias copybara='/google/bin/releases/copybara/public/copybara/copybara'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

#
# Configuration git repo
#
alias config='/usr/bin/git --git-dir=$HOME/src/config/ --work-tree=$HOME'
if [ $OS_NAME = "linux" ]
then
  echo Welcome to `hostname` gLinux `whoami`
  alias linux_config='/usr/bin/git --git-dir=$HOME/src/linux_cfg/ --work-tree=$HOME'

  source /etc/bash_completion.d/hgd
  function setzoom() {
    gsettings set org.gnome.desktop.interface text-scaling-factor "$@";
  }
  alias bat='batcat'
fi
if [ $OS_NAME = "darwin" ]
then
  echo Welcome to OSX `whoami`

  # man-preview - open a specified man page in Preview
  # copied from corresponding oh-my-zsh plugin
  man-preview () {
    man -t "$@" | open -f -a Preview
  }

  function repo() {
    command python3 ~/bin/repo $@
  }
fi

function localchanges {
  gs -s | awk -F ' ' '{print $2}'
}

function recipeconverter {
  pushd -q $WORKSPACE_LOCATION/tools/gradle-recipes
  java -jar $WORKSPACE_LOCATION/tools/gradle-recipes/convert-tool/app/build/libs/recipes-converter-all.jar --action convert --source $WORKSPACE_LOCATION/tools/gradle-recipes/recipes/$1 --destination /tmp/$1 --agpVersion 8.1.0-rc01 --gradleVersion 8.1 --gradlePath $WORKSPACE_LOCATION/tools/external/gradle/gradle-8.1-bin.zip --overwrite
  popd -q
}

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/jedo/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/jedo/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/jedo/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/jedo/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

# Fix ssh-agent issues with remoting
fixup_ssh_auth_sock() {
  if [[ -n ${SSH_AUTH_SOCK} && ! -e ${SSH_AUTH_SOCK} ]]
  then
    local new_sock=$(echo /tmp/ssh-*/agent.*(=UNom[1]))
     if [[ -n ${new_sock} ]]
     then
       export SSH_AUTH_SOCK=${new_sock}
     fi
  fi
}
if [[ -n ${SSH_AUTH_SOCK} ]]
then
  autoload -U add-zsh-hook
  add-zsh-hook preexec fixup_ssh_auth_sock
fi

export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket" 
