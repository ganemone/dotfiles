
publish() {
  jq '. | with_entries(select(.key != "private"))' package.json &> package.tmp.json
  mv package.tmp.json package.json
  npm publish
  git checkout .
}

# Open diffs + file paths on your machine
diffs() {
  echo '{
    "authors":["'$PHID'"],
    "status":"status-open",
    "limit":200
  }' | arc call-conduit differential.query | jq '.response | map(.uri, .title, .sourcePath)'
}

tests() {
    # "commitHashes": [["gtcm", "'$(git rev-parse HEAD)'"]],
  echo '{
    "limit":1,
	"ids": ["727977"]
  }' | arc call-conduit differential.query | jq '.response'
}

updateRevision() {
  echo '{
    "id": 727977,
    "diffid": 2451787,
    "fields": {
      "title": "[Auto Diff] Bump bedrock to get analytics updates. Please commandeer, verify, and land"
    },
    "message": "[Auto Diff] Bump bedrock to get analytics updates. Please commandeer, verify, and land"
  }' | arc call-conduit differential.updaterevision
}


# Accepted diffs + file paths on your machine
lands() {
  echo '{
    "authors":["'$PHID'"],
    "status":"status-accepted",
    "limit":5
  }' | arc call-conduit differential.query | jq '.response | map(.uri, .title, .sourcePath)'
}

# Diffs you need to review
reviews() {
  reviewStatus=${1:-"status-needs-review"}
  responseLimit=${2:-25}
  echo '{
    "reviewers":["'$PHID'"],
    "status": "'$reviewStatus'",
    "limit":'$responseLimit'
  }' | arc call-conduit differential.query | jq '.response |
    map(.uri, .title, .statusName)'
}

# Tasks created in the last week assigned to you
recentTasks() {
  echo '{
    "constraints": {
      "assigned":["'$PHID'"],
      "createdStart": '`date -v-1w +%s`',
      "statuses":["open"]
    }
  }' | arc call-conduit maniphest.search | jq -r '.response | reduce .data[] as $item ({"phids": []}; .phids |= . + [$item.phid])' |
  arc call-conduit maniphest.query | jq '.response | to_entries | map({"uri": .value.uri, "title": .value.title, "id": .value.phid})'
}

# grabs tasks where you are a subscriber that has updated recently
updatedTasks() {
  echo '{
    "constraints": {
      "subscribers":["'$PHID'"],
      "createdStart": '`date -v-3w +%s`',
      "statuses":["open"]
    }
  }' | arc call-conduit maniphest.search | jq -r '.response | reduce .data[] as $item ({"phids": []}; .phids |= . + [$item.phid])' |
  arc call-conduit maniphest.query | jq '.response | to_entries | map({"uri": .value.uri, "title": .value.title, "id": .value.phid})'
}


