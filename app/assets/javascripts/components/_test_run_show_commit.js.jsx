var TestRunShowCommit = React.createClass({
  render: function () {
    var photo_url = this.props.commit.photo_url
    var build_url = this.props.commit.build_url
    var source_logo = this.props.commit.source_logo

    return (
      <div>
        <div className='commit-info'>
          <img className='photo' align='left' src={ photo_url }/>
          <div className='text'>
            <span className='message'>{ this.props.commit.message }</span>
            <br></br>
            <i>
              { this.props.commit.author } committed <span title={ this.props.commit.timestamp }> { this.props.commit.time_ago } ago
              </span>
            </i>
          </div>
        </div>
        <div className='source-button'>
          <a className='source-link btn btn-default btn-xs' href={ this.props.commit.commit_url } target="_blank">
            <img className='source-logo' alt='View on Github' src={ source_logo } />
            View commit
          </a>
        </div>
      </div>
    )
  }
});
