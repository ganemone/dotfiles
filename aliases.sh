alias cl="clear"
alias stash="git stash save"
alias ag="rg"
alias vim="nvim"
alias sshJenkins="boxer aws ssh --region us-east-2 i-05525ddd045d90ab2"
alias vbash="nvim ~/bash"
alias sbash="source ~/.zshrc"
alias gst="git status"
alias gd="git diff"
alias patch="npm version patch && git push origin master --follow-tags"
alias minor="npm version minor && git push origin master --follow-tags"
alias major="npm version major && git push origin master --follow-tags"
alias copygit="git remote get-url origin | pbcopy"
alias ga="git add"
alias gc="git commit -m "
alias gco="git checkout"
alias gbr="git branch"
alias gac="ga . && gc"
alias gs="git stash"
alias vrc="nvim ~/.config/nvim/init.vim"
alias tcpu="top -o cpu"
alias ammend="ga . && git commit --amend --no-edit"
alias copylast="git log -1 --pretty=%B | pbcopy"
alias prs="fusion-orchestrate reviews"
alias ntest="yarn build-test --skip-coverage && node dist-tests/node.js"
alias btest="yarn build-test --skip-coverage && unitest --browser=dist-tests/browser.js"
alias ndebug="yarn build-test && node --inspect-brk dist-tests/node.js"
alias bdebug="yarn build-test && devtool dist-tests/browser.js" 
alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
# alias mprs="fusion-orchestrate mergeAccepted"
alias pingroom="osascript ~/dev/bash/applescripts/ping-review-room.applescript"
# export
gpr() {
  pushf
  local commitMessage=`git log -1 --pretty=%B`
  echo $commitMessage > tmp.txt
  if [ "$1" == "--reuse" ]; then
    gh is >> tmp.txt
    vim tmp.txt;
    hub pull-request -F tmp.txt | tail -1 | xargs open
  else
    vim tmp.txt;
    hub issue create -f tmp.txt | xargs node -e 'console.log("Fixes #" + process.argv.find(a => a.includes("github.com")).split("/").pop())' > tmp-issue.txt
    echo "$commitMessage\n" > tmp.txt
    cat tmp-issue.txt >> tmp.txt
    vim tmp.txt
    hub pull-request -F tmp.txt | tail -1 | xargs open
    rm tmp-issue.txt
  fi
  rm tmp.txt
}

scriptGpr() {
  pushf
  local commitMessage=`git log -1 --pretty=%B`
  echo $commitMessage > tmp.txt
  hub issue create -f tmp.txt | xargs node -e 'console.log("Fixes #" + process.argv.find(a => a.includes("github.com")).split("/").pop())' > tmp-issue.txt
  echo "$commitMessage\n" > tmp.txt
  cat tmp-issue.txt >> tmp.txt
  hub pull-request -F tmp.txt | tail -1 | xargs open
  rm tmp-issue.txt
  rm tmp.txt
}

waitThenSync() {
  while ! git status | grep -q '(use "git pull" to merge the remote branch into yours)'
  do
    git remote update
    sleep 1
  done
  glanded
}

mprs() {
  # folders=`fusion-orchestrate reviews --accepted | grep 'github.com' | xargs node -e '
  #   process.argv.filter(l => l.includes("github.com")).forEach(link => {
  #     console.log(link.split("/")[4]);
  #   })
  # '`
  # fusion-orchestrate mergeAccepted
  # prefix="/Users/giancarloanemone/dev"
  # while read -r line
  # do
  #   folder="$prefix/$line"
  #   if [ -d $folder ]; then
  #     echo "Merging $folder";
  #     cd $folder
  #     waitThenSync
  #   else
  #     echo "Could not find folder: $folder"
  #   fi
  # done <<< "$folders"
}

quickdeploy() {
  udeploy-client deploy -dt parallel -g origin/master -d production $1
  udeploy-client interactive $1
}

vpr() {
  pushf
  local commitMessage=`git log -1 --pretty=%B`
  hub pull-request -m "$commitMessage" | tail -1 | xargs open
}

version() {
  npm version $1 --no-git
  local v=`jq -r .version package.json`
  gac "Release v$v"
}

push() {
  git push origin $(git rev-parse --abbrev-ref HEAD)
}

pull() {
  git pull origin $(git rev-parse --abbrev-ref HEAD)
}

pushf() {
  git push fork $(git rev-parse --abbrev-ref HEAD) --force
}

pullf() {
  git pull fork $(git rev-parse --abbrev-ref HEAD)
}

glanded() {
  git fetch origin master;
  git reset --hard origin/master
  git push fork master --force
}

cpu() {
  ps aux | sort -nrk 3,3
}

replace() {
  git ls-files | grep '\.*.js' | xargs sed -i '' "s/$1/$2/g"
  # git ls-files | grep '\.*.js' | xargs sed -i '' 's/runServerTest/runTest/g'
}

sshow() {
  git stash show stash^{/$*} -p;
}

sapply() {
  git stash apply stash^{/$*};
}

killitwithfire() {
 ps aux | grep $1 | grep -v grep | awk '{print $2}' | xargs kill -9
}

killport() {
  kill -9 `lsof -i:$1 -t`
}

port() {
  lsof -i:$1
}

fastnpmls() {
  find node_modules -type f -name "package.json" | xargs ag $1 -l
}

rmrf() {
  dir=`mktemp -d`;
  echo "Created temp directory $dir";
  for var in "$@"
  do
    echo "Deleting $var"
    mv $var $dir
  done
  rm -rf $dir &;
}

bindkey "^R" history-incremental-search-backward

# Fancy control z for switching between vim
fancy-ctrl-z () {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}

zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

cdglobals() {
  cd $(dirname $(dirname $(which node)))/lib/node_modules
}

if [ -n "$BASH_VERSION" ]; then
    command_not_found_handle() {
        proxy_not_found $*
        return $?
    }
elif [ -n "$ZSH_VERSION" ]; then
    command_not_found_handler() {
        proxy_not_found $*
        return $?
    }
fi

proxy_not_found() {
  local cmd="$1"
  if [ -f ./node_modules/.bin/$1 ]; then
    ./node_modules/.bin/$@
  elif [ -f ./package.json ]; then
    npm run $cmd
  else
    echo "Command not found"
  fi
}

run() {
  $HOME/dev/run.sh
}

eachPar() {
  parallel "cd {} && $@" ::: $HOME/dev/fusion-plugin-*
  parallel "cd {} && $@" ::: $HOME/dev/uber/fusion-plugin-*
}

eachGithubPar() {
  parallel "cd {} && $@" ::: $HOME/dev/fusion-plugin-*
}

eachUberPar() {
  parallel "cd {} && $@" ::: $HOME/dev/uber/fusion-plugin-*
}

eachG() {
  for repo in $HOME/dev/fusion-plugin-*; do
  if [ -d $repo ] && [ -d "$repo/.git" ]
  then
    cd $repo
    $@
    cd ../
  fi
  done
}

eachU() {
  for repo in $HOME/dev/uber/fusion-plugin-*; do
  if [ -d $repo ] && [ -d "$repo/.git" ]
  then
    cd $repo
    $@
    cd ../
  fi
  done
}

each() {
  eachG $@
  eachU $@
}

alias releaseG="eachG doGithubReleases"
doGithubReleases() {
    local commitMessage=`git log -1 --pretty=%B`
    if [[ $commitMessage =~ ^Release\.v[0-9]\.*$ ]]
    then
      # echo "IS RELEASE $commitMessage - ignoring"
    else 
      jq .name package.json
      tmp=""
      vared -p 'Publish a version? (patch | minor | major | skip): ' -c tmp
      if [[ "$tmp" == "patch" || "$tmp" == "minor" || "$tmp" == "major" ]]
      then
        echo "Publishing $tmp"
        version $tmp
        vpr
      else 
        echo "Skipping..."
      fi
    fi
}


# check for git changes
# if [[ `git status --porcelain` ]]; then
#   # Changes
# else
#   # No changes
# fi

# Landing arc prs
alias releaseU="eachU doPhabReleases"
doPhabReleases() {
  jq .name package.json
  if arc which | grep -q 'No revisions match.'
  then
    echo "No revisions"
  else
    if arc land; then
      git pull origin master;
      npm version patch;
      git push origin master --follow-tags;
    else
      echo "Land failed"
    fi
  fi
}

# Searching in if statement
# if grep -q @uber package.json; then
#   echo $repo
#   mv $repo ../uber/
# fi

# creating an issue
# folder=`basename $repo`
# echo $folder
# hub issue create -m "Migrate $folder to DI"
