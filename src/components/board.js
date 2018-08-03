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
    console.log(this.props.currentGame.gameId, this.state.currentPlayerName)
    this.props.monopolyContract.joinGame(this.props.currentGame.gameId, this.state.currentPlayerName, {from: this.props.account})
    .then(result => {
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

      //here is the logic to handle what to do 

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

  componentDidMount() {
    console.log(this.props)

    // var localState = localStorage.getItem('state');

    // if (localState) {
    //   this.setState(JSON.parse(localState))
    // } else {
    //   this.setStorageState()
    // }
  }

  componentDidUpdate(){
    this.setStorageState()
    console.log(localStorage)
  }

  isOwner(){
    return this.state.account === this.props.currentGame.owner
  }

  handleNameChange(e){
    this.setState({currentPlayerName: e.target.value})
  }

  setStorageState(){
    localStorage.setItem('state', JSON.stringify(this.state))
  }

  render() {
    let gameState = this.props.currentGame.gameState
    console.log(gameState, gameState === "1")
    let {name, gameId, numPlayers} = this.props.currentGame
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
            <h4>{numPlayers}</h4>
            {this.isOwner() ? (
              <button onClick={this.startGame.bind(this)}>Start Game</button> 
              ) : (
              <form onSubmit={this.joinGame.bind(this)}>   
                <label>Name:<input type="text" name="name" onChange={this.handleNameChange.bind(this)} /></label>
                <input type="submit" value="Submit" /> 
              </form>
              )
            }
            
          </div>
        )}
      </div>
    );
  }
}

export default Board
