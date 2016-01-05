$(document).ready(function() {
  $("#sign-in-link").on("click", e => {
    e.preventDefault()
    $("#session #actions").hide()
    $("#session #sign-in").show()
    $("#session_name").focus()
  })
  $("#sign-up-link").on("click", e => {
    e.preventDefault()
    $("#session #actions").hide()
    $("#session #sign-up").show()
    $("#user_name").focus()
  })
  $("#sign-in").submit(function(e) {
    addReturner(e.target)
  })
  $("#sign-up").submit(function(e) {
    addReturner(e.target)
  })
  $("#sign-out").on("click", e => {
    // if we let this submit via the default action, the returner gets lost
    e.preventDefault()
    addReturner(e.target)
    e.target.closest("form").submit()
  })
  let addReturner = function(selector) {
    let form = selector.closest("form")
    $(form).append("<input type='hidden' name='returner' value='" + window.location.pathname + "' />")
  }
})
