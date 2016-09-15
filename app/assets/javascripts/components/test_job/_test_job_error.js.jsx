var TestJobError = React.createClass({
  render: function () {
    if (this.props.result) {
      return (
        <div className='row'>
          <div className='display-error col-xs-12'>
            <div id={ this.props.errorId } className="danger collapse console">
              <span className='command'>Command: { this.props.command }</span><br/><br/>
              <span className='js-html-to-ansi'>
                { this.props.result }
              </span>
            </div>
          </div>
        </div>
      )
    } else {
      return (<div className='row' />)
    }
  }
});
