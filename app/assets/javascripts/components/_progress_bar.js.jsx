var ProgressBars = React.createClass({
  render: function () {
    var ProgressBar = ReactBootstrap.ProgressBar;
    var OverlayTrigger = ReactBootstrap.OverlayTrigger;
    var Popover = ReactBootstrap.Popover;

    var bool = (this.props.statuses.length > ( this.props.statuses.pink + this.props.statuses.danger + this.props.statuses.success))

    progressBarWidth =  function (value, length) {
      width = (value / length) * 100
      return width
    }

    popoverContent = function(text, number) {
      content = "<span>" + text + number + "</span>"

      return content
    }.bind(this)

    return (
      <ProgressBar>
        <ProgressBar
          data-toggle="popover"
          data-placement="top"
          data-trigger="hover"
          data-content={
            popoverContent("<i class='fa fa-check' style='color: green;'></i><span> Passed: </span><span class='success'>",
              this.props.statuses.success) }
          data-html="true"
          active={ bool }
          bsStyle="success"
          now={ progressBarWidth(this.props.statuses.success, this.props.statuses.length) }
          key={1}
        />
        <ProgressBar
          data-toggle="popover"
          data-placement="top"
          data-trigger="hover"
          data-content={
            popoverContent("<i class='fa fa-times' style='color: crimson;'></i><span> Failed: </span><span class='danger'>",
              this.props.statuses.danger) }
          data-html="true"
          active={ bool }
          bsStyle="danger"
          now={ progressBarWidth(this.props.statuses.danger, this.props.statuses.length) }
          key={2}
        />

        <ProgressBar
          data-toggle="popover"
          data-placement="top"
          data-trigger="hover"
          data-content={
            popoverContent("<i class='fa fa-warning' style='color: pink;'></i><span> Errors: </span><span class='pink'>",
              this.props.statuses.pink) }
          data-html="true"
          active={ bool }
          className='progress-bar-pink'
          now={ progressBarWidth(this.props.statuses.pink, this.props.statuses.length) }
          key={3}
        />
      </ProgressBar>
    )
  }
})
