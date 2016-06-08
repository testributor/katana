var TestJobList = React.createClass({
  render: function () {
    var testJobNodes = this.props.test_jobs.map(function (test_job) {
      if (typeof(test_job.id) != 'undefined') {
        return (<TestJob
                  test_job={ test_job }
                  admin_user={ this.props.admin_user}
                  user_can_manage_run={ this.props.user_can_manage_run }
                  key={ test_job.id } />
        )
      }
    }.bind(this));

    return (
      <div>
        <ReactCSSTransitionGroup
          transitionName="build-react-style"
          transitionAppear={true}
          transitionAppearTimeout={500}
          transitionEnterTimeout={500}
          transitionLeaveTimeout={500}>
          { testJobNodes }
        </ReactCSSTransitionGroup>
      </div>
    )
  }
});
