$(".point").on("click", event => {
  let $comment = $(event.target)
  let pointIndex = $comment.data("pointIndex")
  $(".point-comments").hide()
  let $pointComments = $(`.point-comments:eq(${pointIndex})`)
  let offset = $comment.offset().top
  $("#comments").offset({top: offset})
  $pointComments.show()
});
