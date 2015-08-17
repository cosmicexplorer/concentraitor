ZalgifyLib = require '../common/zalgify-impl'

chrome.runtime.sendMessage 'get-do-replacement', (doReplacement) ->
  if doReplacement
    chrome.runtime.sendMessage 'get-urls-obj', (urlsObj) ->
      {hosts, freq, intensity} = urlsObj
      if ZalgifyLib.shouldZalgo hosts, location.href
        ZalgifyLib.zalgifyPage freq, intensity
