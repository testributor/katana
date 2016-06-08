var ViewCommit = React.createClass({
  render: function () {
    var source_logo = this.props.source_logo
    var viewOnProvider = "View on " + this.props.provider
    var viewCommitButton = function() {
      if (this.props.provider != 'bare_repo') {
        return (
          <div className='source-button'>
            <a className='source-link btn btn-default btn-md' href={ this.props.commit_url } target="_blank">
              <img className='source-logo' alt={ viewOnProvider } src={ source_logo } />
              View commit
            </a>
          </div>
        )
      } else {
        return null;
      }
    }.bind(this)

    return (
      <div>
        { viewCommitButton() }
      </div>
    )
  }
});
