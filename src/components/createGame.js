import React, { Component } from 'react'

class CreateGame extends Component {
  constructor(props) {
    super(props)
    this.state = {
      creatingGame: false,
      name: 'enter a name',
      game: 'gameId',
      numberOfPlayers: 2
    }
  }

  componentWillMount() {

  }

  createGameForm() {
    this.setState({creatingGame: true})
  }

  handleGameSubmit(e){
    e.preventDefault()
    this.props.createGame(this.state.numberOfPlayers, this.state.name)
  }

  handleGameIdSearch(e){
    e.preventDefault()
    this.props.findGame(this.state.game)
  }

  handleSelectChange(e){
    this.setState({numberOfPlayers: e.target.value})
  }

  handleNameChange(e){
    this.setState({name: e.target.value})
  }

  handleGameChange(e){
    this.setState({game: e.target.value})
  }

  handleGameSelect(gameId){
    this.props.findGame(gameId)
  }

  render() {

    let playerGames;

    if (this.props.playerGames) {
      playerGames = this.props.playerGames.map(game => <div><button onClick={() => this.handleGameSelect(game.gameId)}> {game.name}({game.gameId})</button></div>)
    }

    if (this.state.creatingGame) {
      return(      
      <div className="CreateGame">
        <form onSubmit={this.handleGameSubmit.bind(this)}>   
          <label>Name:<input type="text" name="name" onChange={this.handleNameChange.bind(this)} /></label>
          <label> Number of players: 
            <select name="numberOfPlayers" onChange={this.handleSelectChange.bind(this)}>        
              <option value="2">2</option>
              <option value="3">3</option>
              <option value="4">4</option>
              <option value="5">5</option>
              <option value="6">6</option>
              <option value="7">7</option>
              <option value="8">8</option>
            </select>
          </label>
          <input type="submit" value="Submit" /> 
        </form>
      </div>)
    } else {
      return(
      <div className="CreateGame"> 
        <button onClick={this.createGameForm.bind(this)}>Create Game!</button>
        
        <div> or  </div>
        
        <button onClick={this.props.findGames.bind(this)}>Find previous games!</button>
        {playerGames}
        <div> or  </div>

        <form onSubmit={this.handleGameIdSearch.bind(this)}>
          <label>Join specific game from invite:<input type="text" name="game" onChange={this.handleGameChange.bind(this)} /></label>

          <input type="submit" value="Submit" /> 

        </form>
      </div>
      )
    }
  }
}

export default CreateGame
