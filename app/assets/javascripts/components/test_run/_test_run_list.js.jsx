var TestRunList = React.createClass({
  render: function () {
    var maxIndexRun = _.max(this.props.testRuns, function(testRun){ return testRun.run_index; });
    var testRunNodes = this.props.testRuns.map(function ( testRun ) {
      return <TestRun testRun={ testRun } key={ testRun.id } maxIndexRunId={ maxIndexRun.id } userCanManageRun={ this.props.userCanManageRun} />
  }.bind(this));

    return (
      <div>
        <ReactCSSTransitionGroup
          transitionName="build-react-style"
          transitionAppear={true}
          transitionAppearTimeout={500}
          transitionEnterTimeout={500}
          transitionLeaveTimeout={500}>
          { testRunNodes }
        </ReactCSSTransitionGroup>
      </div>
    )
  }
});
