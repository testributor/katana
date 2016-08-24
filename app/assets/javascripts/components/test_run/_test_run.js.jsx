var TestRun = React.createClass({
  render: function () {
    var testRunCtas = [];

    if (this.props.testRun.id == this.props.maxIndexRunId || this.props.testRun.is_running) {
      if (this.props.testRun.can_be_cancelled && this.props.userCanManageRun) {
        testRunCtas.push(<TestRunCancelButton cancelUrl={ this.props.testRun.cancel_url } key={1}/>)
      }
      if (this.props.testRun.can_be_retried && this.props.userCanManageRun) {
        testRunCtas.push(<TestRunRetryButton retryUrl={ this.props.testRun.retry_url } key={2}/>)
      }
    }

    var totalRunningTime = function() {
      if ( this.props.testRun.total_running_time ) {
        return (
          <div className="col-lg-12 time-div">
            <i className="fa fa-clock-o" aria-hidden="true"></i>
            <span> { this.props.testRun.total_running_time } </span>
          </div>
        )
      }
    }.bind(this);

    return (
      <div id={ 'test-run-' + this.props.testRun.id } className='panelized row'>
        <div className="col-lg-9">
          <a href={ this.props.testRun.test_run_link }>
            <ProgressBars statuses={ this.props.testRun.statuses } total={ this.props.testRun.statuses.total } key={3} />
          </a>
          <TestRunCommit commit={ this.props.testRun.commit_info } key={5} />
        </div>

        <div className="col-lg-3">
          <div>
            <a href={ this.props.testRun.test_run_link}>
              <div className={ this.props.testRun.status_css_class }>
                <span className='m-r-5'>#{ this.props.testRun.run_index }</span>
                <span className='m-r-5'> | </span>
                <span>{this.props.testRun.status_text }</span>
              </div>
            </a>
          </div>

          { totalRunningTime() }
          <div className="time-div m-t-10">
            <i className="fa fa-calendar" aria-hidden="true"></i>
            <span> { this.props.testRun.created_at } </span>
          </div>
          <div>
            { testRunCtas }
          </div>
        </div>
      </div>
    )
  }
});
