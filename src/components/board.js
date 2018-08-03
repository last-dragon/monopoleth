import React, { Component } from 'react'

import Properties from '../rules/properties'

class Board extends Component {
  constructor(props) {
    super(props)

    this.properties = Properties.properties

    this.state = {
      gameState: 'created',
      players: [],
      locations: [],
      gameId: '',
      currentPlayer: '',
      currentPlayerName: '',
      diceAreRolled: false,
      die1: '-',
      die2: '-',
      turn: 0,
    }
  }

  joinGame(e){
    e.preventDefault()
    this.props.monopolyContract.joinGame(this.props.currentGame.gameId, this.state.currentPlayerName, {from: this.props.account})
    .then(result => {
      this.getPlayers()
      console.log(result)
    })
    .catch(err => {
      console.log(err)
    })
  }

  startGame(){
    this.props.monopolyContract.startGame(this.props.currentGameId, {from: this.props.account})
    .then(res => {
      this.setState({gameState: 'Playing'})
    })
    .catch(err => {
      console.log(err)
    })
  }

  takeTurn(){
    let newLocation = 0;
    console.log('rolled', this.state.die1, this.state.die2)
    if (this.state.diceAreRolled) {
      let roll = this.state.die1 + this.state.die2;
      console.log(this.properties[roll])

      //to do: handle turn logic

      if (this.state.die1 === this.state.die2){
        console.log('snake eyes')
      } else{
        // this.resetDice()  
      }
    }
  }

  rollDice() {
    console.log('rolling')

    var die1 = Math.floor(Math.random() * 6) + 1;
    var die2 = Math.floor(Math.random() * 6) + 1;
    this.setState({
      die1: die1,
      die2: die2,
      diceAreRolled: true
    }, this.takeTurn)

  };

  resetDice() {
    this.setState({
      diceAreRolled: false,
      die1: '-',
      die2: '-'
    })
  };

  getPlayers(){
    this.props.monopolyContract.getPlayers(this.props.currentGameId, {from: this.props.account})
    .then(result => {
      console.log(result)
      this.setState({players: result})
    })
  }

  componentDidMount() {
    console.log(this.props)

    this.getPlayers()

    // var localState = localStorage.getItem('state');

    // if (localState) {
    //   this.setState(JSON.parse(localState))
    // } else {
    //   this.setStorageState()
    // }
  }

  componentDidUpdate(){
    this.setStorageState()
    // console.log(localStorage)
  }

  isOwner(){
    return this.props.account === this.props.currentGame.owner
  }

  handleNameChange(e){
    this.setState({currentPlayerName: e.target.value})
  }

  setStorageState(){
    localStorage.setItem('state', JSON.stringify(this.state))
  }

  render() {
    let gameState = this.props.currentGame.gameState
    let {name, gameId, numPlayers} = this.props.currentGame

    let playerPage = this.state.players.includes(this.state.account) ? (
        <form onSubmit={this.joinGame.bind(this)}>   
          <label>Name:<input type="text" name="name" onChange={this.handleNameChange.bind(this)} /></label>
          <input type="submit" value="Submit" /> 
        </form>
      ) : (
        this.state.players.map( playerId => <div>{playerId}</div>)
      );

    return (
      <div className="Board">
        { gameState === "1" ? (
          <div>
            <div>This is the board</div>
            <div>
              Here are the die:
                <div> Die1: {this.state.die1} </div>
                <div> Die2: {this.state.die2} </div>
                <button onClick={this.rollDice.bind(this)}>Roll</button>
            </div>
          </div>
        ) : (
          <div>
            <h2>{name}</h2>
            <h4>{gameId}</h4>
            <h4>Banker: {this.props.currentGame.owner}</h4>
            {this.isOwner() ? (
              <button onClick={this.startGame.bind(this)}>Start Game</button> 
              ) : (
               <div>Waiting for banker to start game..</div>
              )
            }
            { <div> <div><h4>Players:</h4></div>{playerPage} </div>}
            
          </div>
        )}
      </div>
    );
  }
}

export default Board
