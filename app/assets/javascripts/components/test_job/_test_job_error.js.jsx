var TestJobError = React.createClass({
  render: function () {
    if (this.props.result) {
      return (
        <div className='row'>
          <div className='display-error col-xs-12'>
            <div id={ this.props.errorId } className="danger collapse well console">{ this.props.result }</div>
          </div>
        </div>
      )
    } else {
      return (<div className='row' />)
    }
  }
});
