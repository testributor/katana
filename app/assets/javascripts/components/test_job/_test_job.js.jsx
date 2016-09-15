var TestJob = React.createClass({
  render: function (){

    var displayAdminAttrs = function () {
      if (this.props.admin_user) {
        return (
          <div className='col-xs-12 admin-bar'>
            <div className="col-xs-4 chunk_index">
              chunk_index: { this.props.test_job.chunk_index }
            </div>
            <div className="col-xs-4 cost_prediction">
              cost_prediction: { this.props.test_job.avg_worker_command_run_seconds }
            </div>
            <div className="col-xs-4">
              worker_command_run_seconds: { this.props.test_job.worker_command_run_seconds }
            </div>
          </div>
        )
      } else {
        return (null)
      }
    }.bind(this)

    var displayRetryAction = function () {
      var withDots = function(text) {
        newText = (text + "<span class='dot'></span><span class='dot'></span><span class='dot'></span>")
        return newText
      }
      if (this.props.user_can_manage_run && this.props.test_job.status_is_terminal) {
        return (
          <a href={ this.props.test_job.retry_url }
            className="btn btn-raised btn-primary btn-sm js-remote-submission"
            data-remote='true'
            style={{ marginTop: '-4px' }}
            data-disable-with={ withDots('Retrying') }
            rel="nofollow" data-method="put">

            <i className="fa fa-refresh"></i>
            <span>Retry</span>
          </a>
        )
      } else {
        return (null)
      }
    }.bind(this)

    var sentAt = function() {
      if (this.props.test_job.sent_at) {
        return (
          <div className='col-xs-3'>
            <i className='fa fa-calendar-plus-o'/>
            { this.props.test_job.sent_at }
          </div>
        )
      } else {
        return null
      }
    }.bind(this)

    var totalRunningTime = function() {
      if (this.props.test_job.sent_at) {
        return (
          <div className='col-xs-4'>
            <i className='fa fa-clock-o'/>
            { this.props.test_job.total_running_time }
          </div>
        )
      } else {
        return null
      }
    }.bind(this)

    var workerId = function() {
      if (this.props.test_job.sent_at) {
        return (
          <div className='col-xs-4'>
            <i className='fa fa-cog'/>
            { this.props.test_job.worker_uuid_short }
          </div>
        )
      } else {
        return null
      }
    }.bind(this)

    var displayToggleLink = function() {
      if (this.props.test_job.result) {
        return(
          <a href={ errorElement }
            data-toggle="collapse"
            aria-expanded="false"
            className='js-toggle-collapse'>
            <i className="m-l-5 m-r-5 fa fa-chevron-right rotate js-toggle-collapse"></i>
            { this.props.test_job.job_name }
          </a>
        )
      } else {
        return(
          <a role='button'
            href={ errorElement }
            data-toggle="collapse"
            aria-expanded="false"
            className='js-toggle-collapse'
            disabled='true'>
            <i className="m-l-5 m-r-5 fa fa-chevron-right rotate js-toggle-collapse"></i>
            { this.props.test_job.job_name }
          </a>
        )
      }
    }.bind(this)


    var errorId = 'error-' + this.props.test_job.id
    var errorElement = '#error-' + this.props.test_job.id
    var testJobId = 'test-job-' + this.props.test_job.id

    return(
      <div id={ testJobId } className='row test-job'>
        <div className='row'>
          <div className='col-lg-7 col-xs-12'>
            <div className='col-xs-7 job-name m-b-10'>
              { displayToggleLink() }
            </div>
            <div className="col-xs-2">
              <span className={ this.props.test_job.status_css_class }> { this.props.test_job.status_text }</span>
            </div>
            { sentAt() }
          </div>
          <div className='col-lg-5 col-md-12 col-xs-12'>
            { totalRunningTime() }
            { workerId() }
            <div className='col-sm-4 text-right col-xs-12'>{ displayRetryAction() } </div>
          </div>
        </div>
        { displayAdminAttrs() }
        <div className='col-xs-12'>
          <TestJobError errorId={ errorId } result={ this.props.test_job.result } command={ this.props.test_job.command } testJobId={testJobId} />
        </div>
      </div>
    )
  }
});
