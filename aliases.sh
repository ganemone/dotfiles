export PATH="$HOME/dev/uber/scratch/bin:$PATH"
alias jz="jazelle"
alias cl="clear"
alias stash="git stash save"
alias ag="rg --ignore-file=/users/giancarloanemone/.gitignore"
alias vim="nvim"
alias sshJenkins="boxer aws ssh --region us-east-2 i-05525ddd045d90ab2"
alias vbash="nvim ~/dev/bash"
alias sbash="source ~/.zshrc"
alias gst="git status"
alias gd="git diff"
alias patch="npm version patch && git push origin master --follow-tags"
alias minor="npm version minor && git push origin master --follow-tags"
alias major="npm version major && git push origin master --follow-tags"
alias copygit="git remote get-url origin | pbcopy"
alias grom="git reset --hard origin/master"
alias ga="git add"
alias gc="git commit -m "
alias gco="git checkout"
alias gcob="git checkout -b"
alias gbr="git branch"
alias gac="ga . && gc"
alias gs="git stash"
alias gsp="git stash pop"
alias gas="ga . && gs"
alias grm="git fetch origin master && git rebase origin/master"
alias grc="git rebase --continue"
alias vrc="nvim ~/.config/nvim/init.vim"
alias tcpu="top -o cpu"
alias amend="ga . && git commit --amend --no-edit"
alias copylast="git log -1 --pretty=%B | pbcopy"
alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
alias pingroom="osascript ~/dev/bash/applescripts/ping-review-room.applescript"
alias adiff="arc diff --no-unit --no-lint --excuse=jenkins --verbatim --reviewers=#web_platform"
alias sdiff="arc diff HEAD^ --verbatim --reviewers=#web_platform"
alias dca="ssh adhoc02-dca1"
alias sjc="ssh adhoc05-sjc1"
alias branchDiffs="arc branch --output json | jq -r 'to_entries[] | select(.value.status == \"Needs Review\") | .value.desc' | sed 's/://g'"
alias repoDiffs="arc list | grep '* Needs Review' | sed 's/\* Needs Review   //g' | pbcopy"
alias jfusion="cd /Users/giancarloanemone/dev/fusionjs"
alias jufusion="cd /Users/giancarloanemone/dev/uber/fusionjs"
# alias diffs="arc list | grep 'Needs Review' | sed 's/\* Needs Review //g' | sed 's/  Needs Review //g' | pbcopy"
alias lint="git diff-index --name-only --diff-filter=d HEAD | ag '.*\.js$' | xargs yarn eslint --fix"
alias tnew="tmux new -s "
alias tjoin="tmux attach-session -t"
alias recentBranches="git branch --sort=-committerdate"
alias replace="node ~/dev/uber/scratch/replace.js"
alias dedupe="node ~/dev/uber/scratch/dedupe.js"
alias project="cat manifest.json | jq -r '.projects | .[]' | fzf"
alias gp="cd ~/dev/uber/web-code; cd \$(project)"

trace() {
  # docker stop $(docker ps -aq);
  docker container restart jaeger;
  # docker run -d --name jaeger \
  #   -e COLLECTOR_ZIPKIN_HTTP_PORT=9411 \
  #   -p 5775:5775/udp \
  #   -p 6831:6831/udp \
  #   -p 6832:6832/udp \
  #   -p 5778:5778 \
  #   -p 16686:16686 \
  #   -p 14268:14268 \
  #   -p 9411:9411 \
  #   jaegertracing/all-in-one:1.8
}

useplugin() {
  cwd=`pwd`;
  jufusion;
  if [ -d private/$1 ]; then;
    cd private/$1;
    npm run build --if-present;
    npm run transpile --if-present;
    cp -R dist/ $cwd/node_modules/@uber/$1/dist/;
    2;
  elif [ -d public/$1 ]; then;
    cd public/$1;
    npm run build --if-present;
    npm run transpile --if-present;
    cp -R dist/ $cwd/node_modules/$1/dist/;
    2;
  else
    echo "Could not find $1";
    1;
  fi
}

jcode() {
  j $1;
  code .;
  1;
}

openpr() {
  open $(hub pr list -h $(git rev-parse --abbrev-ref HEAD) -f "%U")
}

sland() {
  git fetch origin master
  git rebase origin/master;
  git checkout $(git rev-list --topo-order origin/master..HEAD | tail -1)
  arc diff --message="Rebase"
  read -q "REPLY? Land?"
  arc land --keep-branch;
	# git rebase -i master
	# arc land --keep-branch --revision=`git log -1 --pretty=%b | grep Revision | tail -c 8` 
	# git rebase --continue
	# git rebase master
}

sdiffold() {
  arc branch >> tmp.txt
  vim tmp.txt
  local result=$(<tmp.txt)
  rm tmp.txt
  local regex="([\s]*?)"
  if [ "$result" == "" ]; then
    echo "Failed to vim"
  else
    if [[ $result =~ "([a-zA-Z0-9-]+)" ]]; then
      local branchName="${match[1]}" 
      echo "$branchName"
      arc diff $baseBranch --verbatim --reviewers=#web_platform
    fi
  fi
}

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
  # dir=`mktemp -d`;
  # echo "Created temp directory $dir";
  for var in "$@"
  do
    echo "Deleting $var"
   # mv $var $dir
  done
  # rm -rf $dir &;
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
  parallel "cd {} && $@" ::: $HOME/dev/fusion-*
  parallel "cd {} && $@" ::: $HOME/dev/uber/fusion-*
}

eachGithubPar() {
  parallel "cd {} && $@" ::: $HOME/dev/fusion-*
}

eachUberPar() {
  parallel "cd {} && $@" ::: $HOME/dev/uber/fusion-*
}

eachG() {
  for repo in $HOME/dev/fusion-*; do
    if [ -d $repo ] && [ -d "$repo/.git" ]
    then
      cd $repo
      $@
      cd ../
    fi
  done
}

eachU() {
  for repo in $HOME/dev/uber/fusion-*; do
    if [ -d $repo ] && [ -d "$repo/.git" ]
    then
      cd $repo
      $@
      cd ../
    fi
  done
}


eachApp() {
  for repo in $HOME/dev/uber/fusion-apps/*; do
    if [ -d $repo ] && [ -d "$repo/.git" ]
    then
      cd $repo
      $@
      cd ../
    fi
  done
}

_each() {
  for repo in *; do
    if [ -d $repo ]; then
      cd $repo
      $@
      cd ../
    fi
  done
}

commitByFolder() {
  for folder in *; do
    if [ -d $folder ]; then
      cd $folder
      git add .;
      git commit -m "[$folder] $1"
      cd ../
    fi
  done
}

alias releaseG="eachG doGithubReleases"
doGithubReleases() {
  local commitMessage=`git log -1 --pretty=%B`
  if [[ $commitMessage =~ ^Release\.v[0-9]\.*$ ]]
  then
    # echo "IS RELEASE $commitMessage - ignoring"
  else
    jq .name package.json
    tmp="patch"
    # vared -p 'Publish a version? (patch | minor | major | skip): ' -c tmp
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

gbrowse() {
  open "https://github.com/fusionjs/$1"
}

uyarn() {
  mv ~/.npmrc-backup ~/.npmrc
  yarn $@
  mv ~/.npmrc ~/.npmrc-backup
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

jplug() {
  if [ -d ~/dev/fusion-plugin-$1 ]; then
    cd ~/dev/fusion-plugin-$1
  elif [ -d ~/dev/uber/fusion-plugin-$1 ]; then
    cd ~/dev/uber/fusion-plugin-$1
  elif [ -d ~/dev/fusion-$1 ]; then
    cd ~/dev/fusion-$1;
  else
    echo "Error: could not find plugin for $1"
    return 1;
  fi
}

# critical code-review-master function
function pr-checkout() {
  hub pr list | fzf | awk '{print substr($1,2)}' | xargs hub pr checkout
}

landBranchDiffs() {
  local branches=$(arc branch --output json | jq -r 'to_entries[] | select(.value.status == "Accepted") | .key')
  while read -r line
  do
    git checkout $line
    arc land
  done <<< "$branches"
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
