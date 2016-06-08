var TestRunCancelButton = React.createClass({
  render: function () {
    var withDots = function(text) {
      new_text = (text + "<span class='dot'></span><span class='dot'></span><span class='dot'></span>")
      return new_text
    }

    return (
      <a className="btn btn-danger test-run-action btn-md js-remote-submission" rel="nofollow" data-method="put" data-disable-with={ withDots('Canceling')} data-remote="true" href={ this.props.cancelUrl }>
        <i className="fa fa-times" />
        <span> Cancel</span>
      </a>
    )
  }
})
