ZalgifyLib = require '../common/zalgify-impl'

chrome.runtime.sendMessage 'get-do-replacement', (doReplacement) ->
  if doReplacement
    chrome.runtime.sendMessage 'get-urls-obj', (urlsObj) ->
      {hosts, freq, intensity} = urls
      ZalgifyLib.zalgifyPage freq, intensity if ZalgifyLib.shouldZalgo hosts
