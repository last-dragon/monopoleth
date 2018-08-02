import React, { Component } from 'react'

import Properties from '../rules/properties'

class Board extends Component {
  constructor(props) {
    super(props)

    this.state = {

    }
  }

  componentDidMount() {

  }

  render() {
    return (
      <div className="Board">
        {this.props.name}
      </div>
    );
  }
}

export default Board
