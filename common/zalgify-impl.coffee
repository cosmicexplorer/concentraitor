Zalgify = require 'zalgify'
ReplaceTextNodes = require 'replace-all-text-nodes'

escapeRegexp = (str) -> str.replace /[-\/\\^$*+?.()|[\]{}]/g, '\\$&'

shouldZalgo = (hosts, url) ->
  hosts.some (host) ->
    escaped = "^https?://(www\\.)?" + escapeRegexp host
    console.log escaped
    url.match new RegExp escaped, "gi"

zalgifyPage = (freq, intensity) ->
  console.log freq, intensity
  replaceFn = (txt) -> if txt and not Zalgify.isZalgified txt
      Zalgify.zalgify txt, freq, intensity
    else txt
  obsv = ReplaceTextNodes.replaceAllInPage replaceFn,
    timeouts: [500, 1000, 2000]
    futureNodesToo: yes
  setTimeout (-> obsv.observe document,
      childList: on
      subtree: on
      characterData: on),
    2000

# do exponential growth so zalgification appears linear
# begin at 0, end at 6 (so y-intercept is 0)
# ab^x - 1, where a = 0.4264, b = 16.41
# these values were chosen arbitrarily because they look nice
MaxNumMinutes = 5
getZalgifyFreqIntensity = (numMinutes) ->
  ratio = numMinutes / MaxNumMinutes
  ratio = 1 if ratio > 1
  Math.pow(.4264 * 16.41, ratio) - 1

module.exports =
  shouldZalgo: shouldZalgo
  zalgifyPage: zalgifyPage
  getZalgifyFreqIntensity: getZalgifyFreqIntensity
