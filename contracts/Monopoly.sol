pragma solidity ^0.4.18;

contract Monopoly {
 
  enum GameState { Created, Playing, Finished }
 
  struct Player{
    address adress;
    string name;
    uint balance;
    uint index;
    uint boardIndex;
    uint[] propertiesIndex;
  }

  struct Game{
    GameState gameState;
    address currentPlayer;
    uint houseIndex;
    uint hotelIndex;
    address owner;
    address[] playerIndex;
    uint[] playingOrder;
    mapping(address => Player) players;
  }

  uint constant maxPlayers = 8;
  uint constant minPlayers = 2;
  mapping(bytes32 => Game) public games;
  mapping(address => bytes32[]) playerGames;
  
  event GameInitialized(bytes32 gameId, uint pot);
  event PlayerJoined(bytes32 gameId, address player);
  event BoardBuilt();
  
  constructor () {
  }
  
  function createGame(uint8 numPlayers, string _name) public payable returns(bytes32) {
    bytes32 gameId = sha3(msg.sender, block.number);
    games[gameId] = Game(
        GameState.Created,
        0, // placeholder until game starts
        0, // 0 houses used so far
        0, // 0 hotels used so far
        msg.sender,
        new address[](0),
        new uint[](0)
    );
    registerPlayer(gameId, msg.sender, _name);
    
    emit GameInitialized(gameId, msg.value);
    return gameId;
  }
  
  function getGame(bytes32 gameId) public returns(GameState, address, uint, uint, address[], address){
    Game memory g = games[gameId];
    
    return (g.gameState, g.currentPlayer, g.houseIndex, g.hotelIndex, g.playerIndex, g.owner);
  }
  
  function registerPlayer(bytes32 gameId, address _address, string _name) private{
      games[gameId].players[msg.sender] = Player(
        msg.sender,
        _name,
        1500,
        games[gameId].playerIndex.length,
        0,
        new uint[](0)
    );
    games[gameId].playerIndex.push(msg.sender);
    playerGames[_address].push(gameId);
  }
  
  function joinGame(bytes32 gameId, string _name) public{
      require(games[gameId].gameState == GameState.Created); 
      require(games[gameId].playerIndex.length < maxPlayers); //check if max players reached
      require(games[gameId].playerIndex[games[gameId].players[msg.sender].index] == msg.sender); // check if player already joined
      registerPlayer(gameId, msg.sender, _name);
  }
  
  function startGame(bytes32 gameId, uint[] _playingOrder) public{
      require(games[gameId].owner == msg.sender);
      require(games[gameId].gameState == GameState.Created);
      
      //randomize order of players
      
      //randomize order of chance/community
      
      //pay players tokens
      games[gameId].playingOrder = _playingOrder;
      games[gameId].gameState = GameState.Playing;
  }
  
  function getPlayingOrder(bytes32 gameId) public{
      //pick random number to begin
      //uint number = fill_in_the_blank()
      //games[gameId].currentPlayer = number
  }
  
  function takeTurn(bytes32 gameId) public{
      //two random numbers 1-6;
      //go to position on board
      //take proper action
  }
  
}