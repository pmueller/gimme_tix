// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
import socket from "./socket"

let updateUIFromDataState = function() {
  const uuid = dataEl.data("uuid")
  let searchParams = new URLSearchParams(window.location.search)
  if (!searchParams.get("user")) {
    window.location.search = `user=${uuid}`
    return
  }

  const currentUserId = dataEl.data("current-user")
  const posInQueue = dataEl.data("pos-in-queue")
  const baseUrl = dataEl.data("url")
  const diff = posInQueue - currentUserId

  $("#magic_url").text(`${baseUrl}?user=${uuid}`)
  $("#user_id").text(uuid)
  $("#position").text(diff)

  if (diff < 0) {
    $('#controls').attr('hidden', 'hidden')
    $("#line").attr('hidden', 'hidden')
    $("#thanks").removeAttr('hidden')
  } else {
    if (currentUserId == posInQueue) {
      $("#line").attr('hidden', 'hidden')
      $('#controls').removeAttr('hidden')
    }
  }
}

let dataEl = $('#data')
const eventId = dataEl.data('event-id')
if (!!eventId) {
  let connectParams = {}
  let searchParams = new URLSearchParams(window.location.search)
  if (!!searchParams.get("user")) {
    connectParams['uuid'] = searchParams.get("user")
  }
  let channel = socket.channel(`event_queue:${eventId}`, connectParams)
  channel.join()
    .receive("ok", resp => {
      dataEl.data("uuid", resp['uuid'])
      dataEl.data("current-user", resp['current_user'])
      dataEl.data("pos-in-queue", resp['pos_in_queue'])
      updateUIFromDataState()
    })
    .receive("error", resp => { console.log("Unable to join", resp) })

  channel.on('new_current_user', function(resp) {
    dataEl.data("current-user", resp['current_user'])
    updateUIFromDataState()
  });

  $("#buy").click(function(e) {
    e.preventDefault()
    const uuid = dataEl.data('uuid')
    channel.push('buy', {"uuid": uuid})
  })

  $("#skip").click(function(e) {
    e.preventDefault()
    channel.push('skip')
  })

  $("#pass").click(function(e) {
    e.preventDefault()
    const uuid = dataEl.data('uuid')
    channel.push('pass', {"uuid": uuid})
  })
}
