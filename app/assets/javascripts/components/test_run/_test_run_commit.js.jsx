var TestRunCommit = React.createClass({
  render: function () {
    var photo_url = this.props.commit.photo_url
    var build_url = this.props.commit.build_url
    var source_logo = this.props.commit.source_logo

    var commitMessage = function() {
      if (this.props.commit.timestamp) {
        return (
          <i>
            { this.props.commit.author } committed <span title={ this.props.commit.timestamp }>
              { this.props.commit.time_ago } ago.
            </span>
          </i>
        )
      } else {
        return (
          <i>Commit information unavailable until setup is successfully completed.</i>
        )
      }
    }.bind(this);

    return (
      <div className='commit-info'>
        <img className='photo' align='left' src={ photo_url }/>
        <a href={ build_url } className='build-link' title='View build page'>
          <div className='text'>
            <span className='message' >{ this.props.commit.message }</span>
            <br></br>
            { commitMessage() }
          </div>
        </a>
      </div>
    )
  }
});
