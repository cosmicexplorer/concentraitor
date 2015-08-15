Zalgify = require 'zalgify'
ReplaceTextNodes = require 'replace-all-text-nodes'

escapeRegexp = (str) -> str.replace /[-\/\\^$*+?.()|[\]{}]/g, '\\$&'

shouldZalgo = (hosts) ->
  hosts.some (host) -> location.hostname.match new RegExp escapeRegexp host

zalgifyPage = (freq, intensity) ->
  replaceFn = (txt) -> Zalgify txt, freq, intensity if txt
  obsv = ReplaceTextNodes.replaceAllInPage replaceFn,
    timeouts: [500, 1000, 2000]
    futureNodesToo: yes
  setTimeout (-> obsv.observe document,
      childList: on
      subtree: on
      characterData: on),
    2000

module.exports =
  shouldZalgo: shouldZalgo
  zalgifyPage: zalgifyPage
