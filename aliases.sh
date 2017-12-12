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
alias gcm="git commit -m "
alias gco="git checkout"
alias gbr="git branch"
alias gc="ga . && gcm"
alias vrc="nvim ~/.config/nvim/init.vim"
alias tcpu="top -o cpu"
alias ammend="ga . && git commit --amend --no-edit"
alias copylast="git log -1 --pretty=%B | pbcopy"
alias prs="fusion-orchestrate reviews"
alias mprs="fusion-orchestrate mergeAccepted"
alias pingroom="osascript ~/dev/bash/applescripts/ping-review-room.applescript"
# export
gpr() {
  pushf
  local commitMessage=`git log -1 --pretty=%B`
  echo $commitMessage > tmp.txt
  vim tmp.txt
  hub issue create -f tmp.txt | xargs node -e 'console.log("Fixes #" + process.argv.find(a => a.includes("github.com")).split("/").pop())' > tmp-issue.txt
  echo "$commitMessage\n" > tmp.txt
  cat tmp-issue.txt >> tmp.txt
  vim tmp.txt
  hub pull-request -F tmp.txt
  rm tmp.txt
  rm tmp-issue.txt
}

vpr() {
  pushf
  local commitMessage=`git log -1 --pretty=%B`
  hub pull-request -m "$commitMessage"
}

version() {
  npm version $1 --no-git
  local v=`jq -r .version package.json`
  gc "Release v$v"
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
