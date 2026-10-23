#!/usr/bin/env bats

. src/workflowHandler.sh

@test "addResult: omit empty uid" {
  addResult "" "arg" "title" "subtitle" "icon"
  [[ "${RESULTS[0]}" != *"uid="* ]]
}

@test "addResult: include uid" {
  addResult "id" "arg" "title" "subtitle" "icon"
  [[ "${RESULTS[0]}" == "<item uid='id' arg='arg'"* ]]
}
