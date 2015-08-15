setupUrls = (setup, success, failure, xhrObj) ->
  setup()
  if xhrObj
    xhr = new xhrObj.XMLHttpRequest
  else
    xhr = new XMLHttpRequest
  xhr.onreadystatechange = ->
    if xhr.readyState is 4 and xhr.status is 200
      resp = JSON.parse xhr.response
      success resp
      console.log
        loaded: 'urls'
        resp: resp
      localStorage.setItem 'concentraitors-urls',
        JSON.stringify resp
  xhr.onerror = ->
    console.error "failure"
    resp = JSON.parse localStorage.getItem 'concentraitors-urls'
    failure resp
    console.error
      loaded: 'urls-from-storage'
      resp: resp
  xhr.open 'get',
    'https://raw.githubusercontent.com/cosmicexplorer/concentraitor/master/' +
      'sites.json'
    yes
  xhr.send()

module.exports = setupUrls
