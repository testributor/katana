var TestRunShowHeader = React.createClass({
  render: function() {
    var testRunCtas = [];

    if (this.props.test_run.is_running) {
      if (this.props.test_run.can_be_cancelled && this.props.user_can_manage_run) {
        testRunCtas.push(
          <TestRunCancelButton
            cancelUrl={ this.props.test_run.cancel_url }
            key={1}
          />
        )
      }
    }
    if (this.props.test_run.can_be_retried && this.props.user_can_manage_run) {
      testRunCtas.push(
        <TestRunRetryButton
          retryUrl={ this.props.test_run.retry_url }
          key={2}
        />
      )
    }

    var setupError = function (){
      if (setupError.length > 0){
        return(
          <div className="alert alert-danger">
            <span>An error occured on setup step:</span>
            <span> { this.props.test_run.setup_error } </span>
          </div>
        )
      } else {
        return(null)
      }
    }.bind(this)

    return (
      <div className='col-sm-12'>
        { setupError() }
        <div className='row'>
          <div className='col-sm-6'>
            <a href={ this.props.test_runs_link }>
              <i className="fa fa-arrow-left" />
              <span> Back to builds </span>
            </a>
          </div>
          <div className='col-sm-6 text-right'>
            <div className="togglebutton show-all-area" style={{ marginTop: '0px' }}>
              <label>
                <input type="checkbox" name="show_all" id="show_all" value="1"/>
                Toggle all logs
              </label>
            </div>
          </div>
        </div>

        <div className='row'>
          <div className="col-sm-8">
            <div className="row">
              <div className="col-xs-12">
                <h3 className='test-run-header'>
                  <div className={ this.props.test_run.status_css_class }>
                    <span className='m-r-5'>Build #{ this.props.test_run.run_index }</span>
                    <span className='m-r-5'> | </span>
                    <span>{this.props.test_run.status_text }</span>
                  </div>
                </h3>
                <ViewCommit provider={ this.props.test_run.repository_provider }
                            source_logo={ this.props.test_run.commit_source_logo }
                            commit_url={ this.props.test_run.commit_url } />
              </div>
            </div>
          </div>
          <div className="col-sm-4">
            <div className="row">
              <div className="col-sm-12 text-right">
                <div style={{ marginTop: '-5px'}}>
                  { testRunCtas }
                </div>
              </div>
            </div>
          </div>
        </div>
        <div className="row m-t-5">
          <div className='col-xs-12'>
            <TestRunShowCommit commit={ this.props.test_run.commit_info }
                             provider={ this.props.test_run.repository_provider } />
          </div>
        </div>
      </div>
    )
  }
})
