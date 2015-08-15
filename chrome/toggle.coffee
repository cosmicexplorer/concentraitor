act = chrome.browserAction

activationState = on

act.onClicked.addListener (tab) ->
  activationState = not activationState
  act.setIcon path: (if activationState then onIcon else offIcon)
  console.log (if activationState then "activated" else "deactivated")

chrome.runtime.onMessage.addListener (req, sender, sendResponse) ->
  switch req
    when 'get-activation-state' then sendResponse activationState
