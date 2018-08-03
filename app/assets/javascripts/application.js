'use strict'

document.onreadystatechange = function () {
  var csrf = document.querySelector('meta[name="csrf-token"]').content
  if (document.readyState === 'interactive') {
    var basePath = document.getElementById('base-path-id')
    var documentTitle = document.getElementById('document-title-id')
    var pathArray = document.location.pathname.split('/')
    var documentId = pathArray[2]
    var url = '/documents/' + documentId + '/generate-path'
    documentTitle.onblur = function () {
      if (!documentTitle.value) {
        basePath.innerHTML = "You haven’t entered a title yet."
        return
      }
      window.fetch(url, {
        method: 'POST',
        credentials: 'include',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-CSRF-Token': csrf
        },
        body: JSON.stringify({ title: documentTitle.value })
      }).then(function(response) {
        response.json().then(function (result) {
          if (result.reserved) {
            basePath.innerHTML = 'www.gov.uk' + result['base_path']
          } else {
            basePath.innerHTML = 'Path is taken, please edit the title.'
          }
        })
      })
    }
  }
}
