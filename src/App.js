import React, { Component } from 'react'
// import SimpleStorageContract from '../build/contracts/SimpleStorage.json'
import MonopolyContract from '../build/contracts/Monopoly.json'
import getWeb3 from './utils/getWeb3'
import Board from './components/board'
import CreateGame from './components/createGame'

import './css/oswald.css'
import './css/open-sans.css'
import './css/pure-min.css'
import './App.css'

class App extends Component {
  constructor(props) {
    super(props)

    this.state = {
      storageValue: 0,
      web3: null,
      monopolyContract: null,
      account: null
    }
  }

  createGame(numPlayers, name){
    console.log(numPlayers, name)
    var input = JSON.stringify({ numPlayers, name})
console.log(this.state.account)
    this.state.monopolyContract.createGame(numPlayers, name, {from: this.state.account})
    .then( result => {
      console.log(result)
      return result
    })
  }

  componentWillMount() {
    // Get network provider and web3 instance.
    // See utils/getWeb3 for more info.

    getWeb3
    .then(results => {
      this.setState({
        web3: results.web3
      })

      // Instantiate contract once web3 provided.
      this.instantiateContract()
    })
    .catch(() => {
      console.log('Error finding web3.')
    })
  }

  instantiateContract() {
    /*
     * SMART CONTRACT EXAMPLE
     *
     * Normally these functions would be called in the context of a
     * state management library, but for convenience I've placed them here.
     */


    const contract = require('truffle-contract')
    // const simpleStorage = contract(SimpleStorageContract)
    // simpleStorage.setProvider(this.state.web3.currentProvider)

    const monopoly = contract(MonopolyContract)
    monopoly.setProvider(this.state.web3.currentProvider)

    // Declaring this for later so we can chain functions on SimpleStorage.
    var monopolyInstance

    // Get accounts.
    this.state.web3.eth.getAccounts((error, accounts) => {
      monopoly.deployed().then(instance => {
        monopolyInstance = instance
        this.monopolyInstance = instance
        return this.setState({monopolyContract: monopolyInstance, account: accounts[0]})
      })
    })
  }

  render() {

    return (
      <div className="App">
        <nav className="navbar pure-menu pure-menu-horizontal">
            <a href="#" className="pure-menu-heading pure-menu-link">Truffle Box</a>
        </nav>

        <main className="container">

        </main>

        <Board />
        <CreateGame creating={this.state.creatingGame} createGame={this.createGame.bind(this)} />
      </div>
    );
  }
}

export default App
