$(".point").on("click", event => {
  $(".point").removeClass("selected")
  let $comment = $(event.target)
  $comment.addClass("selected")
  let pointIndex = $comment.data("pointIndex")
  $(".point-comments").hide()
  $(".point-comments").removeClass("selected")
  let $pointComments = $(`.point-comments:eq(${pointIndex})`)
  $pointComments.addClass("selected")
  let offset = $comment.offset().top
  $("#comments").offset({top: offset})
  $pointComments.show()
});
