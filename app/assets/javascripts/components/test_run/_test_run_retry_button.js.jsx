var TestRunRetryButton = React.createClass({
  render: function () {
    var withDots = function(text) {
      new_text = (text + "<span class='dot'></span><span class='dot'></span><span class='dot'></span>")
      return new_text
    }

    return (
      <a className="btn  test-run-action btn-raised btn-primary js-remote-submission" rel="nofollow" data-disable-with={ withDots('Retrying') } data-method="post" data-remote="true" href={ this.props.retryUrl }>
        <i className="fa fa-refresh" />
        <span> Retry</span>
      </a>
    )
  }
})
