var ProgressBars = React.createClass({
  render: function () {
    var ProgressBar = ReactBootstrap.ProgressBar;
    var OverlayTrigger = ReactBootstrap.OverlayTrigger;
    var Popover = ReactBootstrap.Popover;

    var isActive = (this.props.total > ( this.props.statuses.pink + this.props.statuses.danger + this.props.statuses.success))

    var progressBarWidth =  function (value, length) {
      width = (value / length) * 100
      return width
    }

    var popoverContent = function(text, number) {
      content = "<span>" + text + number + "</span>"

      return content
    }.bind(this)

    var progresBar = function() {
      if (this.props.display_stats) {
        return (
          <div>
            <div className='text-right progress-stats'>
              <span className='m-r-5'>
                <i className='fa fa-check' style={{ color: 'green' }}></i>
                 <span> Passed: </span><span className='success' >{ this.props.statuses.success }</span>
              </span>

              <span className='m-r-5'>
                <i className='fa fa-warning' style={{ color: 'pink' }}></i>
                 <span> Errors: </span><span className='pink' >{ this.props.statuses.pink }</span>
              </span>

              <span className='m-r-5'>
                <i className='fa fa-times' style={{ color: 'crimson' }}></i>
                 <span> Failed: </span><span className='danger' >{ this.props.statuses.danger }</span>
              </span>
            </div>
            <ProgressBar>
              <ProgressBar
                active={ isActive }
                bsStyle="success"
                now={ progressBarWidth(this.props.statuses.success, this.props.total) }
                key={1}
              />
              <ProgressBar
                active={ isActive }
                bsStyle="danger"
                now={ progressBarWidth(this.props.statuses.danger, this.props.total) }
                key={2}
              />
              <ProgressBar
                active={ isActive }
                className='progress-bar-pink'
                now={ progressBarWidth(this.props.statuses.pink, this.props.total) }
                key={3}
              />
            </ProgressBar>
          </div>

        )
      } else {
        return (
          <ProgressBar>
            <ProgressBar
              data-toggle="popover"
              data-placement="top"
              data-trigger="hover"
              data-container="body"
              data-content={
                popoverContent("<i class='fa fa-check' style='color: green;'></i><span> Passed: </span><span class='success'>",
                  this.props.statuses.success) }
              data-html="true"
              active={ isActive }
              bsStyle="success"
              now={ progressBarWidth(this.props.statuses.success, this.props.total) }
              key={1}
            />
            <ProgressBar
              data-toggle="popover"
              data-placement="top"
              data-trigger="hover"
              data-container="body"
              data-content={
                popoverContent("<i class='fa fa-times' style='color: crimson;'></i><span> Failed: </span><span class='danger'>",
                  this.props.statuses.danger) }
              data-html="true"
              active={ isActive }
              bsStyle="danger"
              now={ progressBarWidth(this.props.statuses.danger, this.props.total) }
              key={2}
            />

            <ProgressBar
              data-toggle="popover"
              data-placement="top"
              data-container="body"
              data-trigger="hover"
              data-content={
                popoverContent("<i class='fa fa-warning' style='color: pink;'></i><span> Errors: </span><span class='pink'>",
                  this.props.statuses.pink) }
              data-html="true"
              active={ isActive }
              className='progress-bar-pink'
              now={ progressBarWidth(this.props.statuses.pink, this.props.total) }
              key={3}
            />
          </ProgressBar>
        )
      }
    }.bind(this)

    return ( progresBar() )
  }
})
