import React from "react"
import ReactDOM from "react-dom"
import {Socket} from "phoenix" // aliased in webpack.config.js

var Point = React.createClass({
  render: function() {
    return <li className={this.props.className} onClick={this.props.clickHandler} data-point-index={this.props.index}>{this.props.pointText}</li>
  }
})
var PointList = React.createClass({
  render: function() {
    let _this = this
    var createItem = function(pointText, index) {
      var className
      if (_this.props.selectedIndex == index) {
        className = "point selected"
      } else {
        className = "point"
      }
      return <Point key={"point" + index} pointText={pointText} index={index} clickHandler={_this.props.handleClick} className={className}/>
    }
    return <ul>{this.props.points.map(createItem)}</ul>
  }
})
var Comment = React.createClass({
  render: function() {
    return(
      <li>
        {this.props.commentText}
        {this.actions()}
      </li>
    )
  },
  actions: function() {
    if(this.props.childDiscourseId) {
      return this.readMoreLink()
    } else {
      if(this.props.commentsReplyable) {
        return this.replyLink()
      }
    }
  },
  readMoreLink: function() {
    return <a href={"/d/" + this.props.childDiscourseId}>read more&hellip;</a>
  },
  replyLink: function(commentIndex) {
    return <a href={"/d/new/" + this.props.discourseId + "/" + this.props.pointIndex + "/" + this.props.commentIndex}>reply</a>
  }
})
var CommentList = React.createClass({
  render: function() {
    if(this.props.comments) {
      let _this = this
      var createItem = function(comment, index) {
        return <Comment key={"comment" + index} commentText={comment[0]} discourseId={_this.props.discourseId} pointIndex={_this.props.pointIndex} commentIndex={index} commentsReplyable={_this.props.commentsReplyable} childDiscourseId={comment[2]} className="comment"/>
      }
      return <ul>{_this.props.comments.map(createItem)}</ul>
    } else {
      return null
    }
  }
})
var DiscourseApp = React.createClass({
  getInitialState: function() {
    return {
      id: this.props.id,
      points: this.props.points.p,
      comments: this.props.comments.c,
      selectedPointIndex: null,
      responseText: '',
      commentText: '',
      currentUserId: window.userId,
      chan: this.joinChannel(),
    }
  },
  onResponseChange: function(e) {
    this.setState({responseText: e.target.value})
  },
  onCommentChange: function(e) {
    this.setState({commentText: e.target.value})
  },
  handleClickPoint: function(e) {
    e.preventDefault()
    let pointIndex = e.target.dataset.pointIndex
    this.setState({selectedPointIndex: pointIndex})
  },
  handleResponseSubmit: function(e) {
    e.preventDefault()
    this.state.chan.push("new_point", {body: this.state.responseText})
    let nextItems = this.state.points.concat([this.state.responseText])
    let nextText = ''
    this.setState({points: nextItems, responseText: nextText})
  },
  handleCreateSubmit: function(e) {
    e.preventDefault()
    this.state.chan.push("new_discourse", {
      body: this.state.responseText,
      parent_discourse_id: this.props.parent_discourse_id,
      parent_point_index: this.props.parent_point_index,
      parent_comment_index: this.props.parent_comment_index
    }).receive('ok', response => {
      console.log('received')
    })
    let nextItems = this.state.points.concat([this.state.responseText])
    let nextText = ''
    this.setState({id: 'changeme', points: nextItems, responseText: nextText})
  },
  handleCommentSubmit: function(e) {
    e.preventDefault()
    this.state.chan.push("new_comment", {body: this.state.commentText, point_index: this.state.selectedPointIndex})
    let nextText = ''
    let nextComments = this.state.comments
    let pointComments = nextComments[this.state.selectedPointIndex] || []
    let nextPointComments = pointComments.concat([[this.state.commentText, this.state.currentUserId]])
    nextComments[this.state.selectedPointIndex] = nextPointComments

    this.setState({comments: nextComments, commentText: nextText})
  },
  joinChannel: function() {
    let socket = new Socket("/socket", {params: {token: window.userToken}})
    socket.connect()
    let chan = socket.channel("discourses:" + window.discourseId, {})
    chan.join()
      .receive("ok", resp => { console.log("Joined pretty successfully", resp) })
      .receive("error", resp => { console.log("Unable to join", resp) })
    return chan
  },
  render: function() {
    return (
      <div>
        <div id="discourse">
          <div className="actions">
            <a href={"/d/" + this.props.parent_discourse_id}>back</a>
          </div>
          <div id="points">
            <PointList points={this.state.points} selectedIndex={this.state.selectedPointIndex} handleClick={this.handleClickPoint} />
          </div>
          <div id="sayer" className="actions">
            {this.renderPointForm()}
          </div>
        </div>
        <div id="comments">
          <CommentList comments={this.state.comments[this.state.selectedPointIndex]} discourseId={this.state.id} pointIndex={this.state.selectedPointIndex} commentsReplyable={this.commentsReplyable()}/>
          <div className="commenter">
            {this.renderCommentForm()}
          </div>
        </div>
      </div>
    )
  },
  renderPointForm: function() {
    if(this.discourseReplyable()) {
      if(this.state.id) {
        return(
          <form onSubmit={this.handleResponseSubmit}>
            <textarea placeholder="respond&hellip;" onChange={this.onResponseChange} value={this.state.responseText} />
            <button>submit</button>
          </form>
        )
      } else {
        return(
          <form onSubmit={this.handleCreateSubmit}>
            <textarea placeholder="respond&hellip;" onChange={this.onResponseChange} value={this.state.responseText} />
            <button>submit</button>
          </form>
        )
      }
    }
  },
  renderCommentForm: function() {
    if(this.state.currentUserId && this.state.selectedPointIndex) {
      return(
        <form onSubmit={this.handleCommentSubmit}>
          <textarea placeholder="comment&hellip;" onChange={this.onCommentChange} value={this.state.commentText} />
          <button>submit</button>
        </form>
      )
    }
  },
  discourseReplyable: function() {
    return this.state.currentUserId == this.responsibleUserId(this.state.points.length + 1)
  },
  commentsReplyable: function() {
    return this.state.currentUserId == this.responsibleUserId(this.state.selectedPointIndex)
  },
  responsibleUserId: function(pointIndex) {
    if(pointIndex % 2 == 0) {
      return this.props.initiator_id
    } else {
      return this.props.replier_id
    }
  }
})

let points = JSON.parse(document.getElementById("point-data").innerHTML)
ReactDOM.render(<DiscourseApp {...points} />, document.getElementById('content'))
