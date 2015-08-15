SetupUrls = require '../common/setup-urls'

act = chrome.browserAction
doReplacement = no
urls = null

iconOn = 'res/imposter19.png'
iconOff = 'res/imposter19off.png'

act.onClicked.addListener (tab) ->
  if urls?
    doReplacement = not doReplacement
    if doReplacement
      iconPath = iconOn
    else
      iconPath = iconOff
    act.setIcon path: iconPath
    console.log "set concentraitor replacement to #{doReplacement}"

setup = ->
  act.setIcon path: iconOff
  urls = null

success = (resp) ->
  if resp
    urls = resp
    act.setIcon path: iconOn
    doReplacement = yes

failure = (resp) ->
  if resp
    urls = resp
    act.setIcon path: iconOn
    doReplacement = yes

setupUrls = -> SetupUrls setup, success, failure

chrome.runtime.onMessage.addListener (req, sender, sendResponse) ->
  switch req
    when 'get-do-replacement' then sendResponse doReplacement
    when 'get-urls-obj' then sendResponse
      hosts: urls
      freq: .5
      intensity: 6
    when 'setup-urls'
      # removing cache here doesn't actually work either, but whatever
      chrome.browsingData.removeCache {}, setupUrls

setupUrls()
