SetupUrls = require '../common/setup-urls'
ZalgifyLib = require '../common/zalgify-impl'

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

StartTime = null

refreshStartTime = ->
  if doReplacement
    chrome.tabs.query {}, (tabs) ->
      console.log "refreshed"
      if (tabs.map((t) -> t.url).some (url) -> ZalgifyLib.shouldZalgo urls, url)
        StartTime = new Date unless StartTime?
      else
        StartTime = null

# this is throwing an exception for no conceivable reason, but the code seems to
# be running, so whatever
chrome.webNavigation.onCompleted.addListener refreshStartTime
chrome.tabs.onRemoved.addListener refreshStartTime

chrome.runtime.onMessage.addListener (req, sender, sendResponse) ->
  switch req
    when 'get-do-replacement' then sendResponse doReplacement
    when 'get-urls-obj'
      StartTime = new Date unless StartTime?
      diffms = new Date - StartTime
      diffMins = Math.round diffms % 86400000 % 3600000 / 60000
      console.log
        diffms: diffms
        diffMins: diffMins
      freqIntensity = ZalgifyLib.getZalgifyFreqIntensity diffMins
      sendResponse
        hosts: urls
        freq: freqIntensity
        intensity: freqIntensity
    when 'setup-urls'
      # removing cache here doesn't actually work either, but whatever
      chrome.browsingData.removeCache {}, setupUrls

setupUrls()
