var TestRunShowCommit = React.createClass({
  render: function () {
    var photo_url = this.props.commit.photo_url
    var build_url = this.props.commit.build_url

    var commit_timestamp_info = function() {
      if(this.props.commit.timestamp) {
        return (
            <i>
              { this.props.commit.author } committed <span title={ this.props.commit.timestamp }>
              { this.props.commit.time_ago } ago </span> </i>
        )
      } else {
        return null
      }
    }.bind(this)

    return (
      <div>
        <div className='commit-info'>
          <img className='photo' align='left' src={ photo_url }/>
          <div className='text'>
            <span className='message'>{ this.props.commit.message }</span>
            <br></br>
            { commit_timestamp_info() }
          </div>
        </div>
      </div>
    )
  }
});
