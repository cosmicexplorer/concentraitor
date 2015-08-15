Zalgify = require 'zalgify'
ReplaceText = require 'replace-all-text-nodes'

shouldZalgo = (hosts) ->
  hosts.some (host) -> host is location.hostname

zalgifyPage = (freq, intensity) ->
  obsv = ReplaceTextNodes.replaceAllInPage ((txt) ->
    Zalgify txt, freq, intensity),
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
