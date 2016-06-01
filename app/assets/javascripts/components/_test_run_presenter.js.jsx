var TestRunPresenter = React.createClass({
  getInitialState: function () {
    return { testRuns: this.props.testRuns }
  },

  handleUpdate: function (msg) {
    var testRuns = this.state.testRuns;
    if (msg.test_run) {
      existedRun =  _.find(this.state.testRuns, function(testRun) {
        return testRun.id == msg.test_run.id;
      })

      if (existedRun) {
        testRuns.splice(testRuns.indexOf(existedRun), 1, msg.test_run)
        this.setState({ testRuns: testRuns })
      } else {
        if (msg.test_run.branch_id == this.props.currentBranchId ||
          (this.props.currentBranchId == null)) {
          testRuns.unshift(msg.test_run)
          this.setState({ testRuns: testRuns })
          Testributor.Widgets.LiveUpdates(
            { "TestRun": { "ids": [msg.test_run.id] } }, this.handleUpdate)
        } else {
          null
        };
      }
    }
  },

  subscribe: function (testRunIds) {
    var _this = this;
    var subscriptions = {
      "TestRun": {
        'ids': testRunIds,
        'actions': ['create'],
        'project_id': this.props.projectId
      }
    }

    Testributor.Widgets.LiveUpdates(subscriptions, _this.handleUpdate)
  },

  componentDidMount: function() {
    var _this = this;
    var testRunIds = _this.props.testRuns.map(function(testRun, index){
      return testRun.id;
    });
    _this.subscribe(testRunIds)
  },

  render: function () {
     return (
       <TestRunList testRuns={ this.state.testRuns } userCanManageRun={ this.props.userCanManageRun } />
     )
  }
})
