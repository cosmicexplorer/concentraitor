Replace = require '../common/replace-all'

chrome.runtime.sendMessage 'get-activation-state', (activationState) ->
  if activationState
    # run zalgify
