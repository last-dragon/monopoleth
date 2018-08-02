pragma solidity ^0.4.18;

contract Monopoly {
 
  enum GameState { Created, Playing, Finished }
 
  struct Player{
    address adress;
    string name;
    uint balance;
    uint index;
    uint boardIndex;
  }

  struct Game{
    GameState gameState;
    string name;
    uint currentPlayer;
    uint houseIndex;
    uint hotelIndex;
    address owner;
    bytes32 gameId;
    address[] playerIndex;
    mapping(address => Player) players;
  }

  uint constant maxPlayers = 8;
  uint constant minPlayers = 2;
  
  uint256 public totalSupply;
  mapping(address => uint256) balanceOf;
  
  mapping(bytes32 => Game) public games;
  mapping(address => bytes32[]) playerGames;
  
  event GameInitialized(bytes32 gameId, uint pot);
  event PlayerJoined(bytes32 gameId, address player);
  event BoardBuilt();
  
  constructor () {
  }
  
  function createGame(uint8 numPlayers, uint8 randomNumber, string _name) public payable returns(bytes32) {
    bytes32 gameId = keccak256(msg.sender, block.number);
    games[gameId] = Game(
        GameState.Created,
        _name,
        randomNumber, 
        0, // 0 houses used so far
        0, // 0 hotels used so far
        msg.sender,
        gameId,
        new address[](0)
    );
    registerPlayer(gameId, msg.sender, _name);
    
    emit GameInitialized(gameId, msg.value);
    return gameId;
  }
  
  function takeTurn(uint num, bytes32 gameId) public{
    games[gameId].currentPlayer += 1;
    games[gameId].playerIndex[games[gameId].currentPlayer];
  }
  
  function getPlayerGames(address _address) public view returns(bytes32[]){
      bytes32[] _playerGames = playerGames[_address];
      bytes32[] memory v = new bytes32[](_playerGames.length);
      for(uint i = 0; i < v.length; i++){
        v[i] = _playerGames[i];
      }
      return v;
  }

  function getGame(bytes32 gameId) public view returns(GameState, string, uint, uint, uint, address, bytes32, address[]){
    Game memory g = games[gameId];
    
    return (g.gameState, g.name, g.currentPlayer, g.houseIndex, g.hotelIndex, g.owner, g.gameId, g.playerIndex);
  }
  
  function getPlayer(bytes32 gameId, address playerId) public view returns(string, uint, uint, uint){
      Player memory p = games[gameId].players[playerId];
      return (p.name, p.balance, p.index, p.boardIndex);
  }
  
  function registerPlayer(bytes32 gameId, address _address, string _name) private{
      totalSupply += 1500;
      games[gameId].playerIndex.push(msg.sender);
      playerGames[_address].push(gameId);
      
      games[gameId].players[msg.sender] = Player(
        msg.sender,
        _name,
        1500,
        games[gameId].playerIndex.length,
        0
    );
  }
  
  function joinGame(bytes32 gameId, string _name) public payable{
    //   require(games[gameId].gameState == GameState.Created); 
    //   require(games[gameId].playerIndex.length < maxPlayers); //check if max players reached
    //   require(games[gameId].playerIndex[games[gameId].players[msg.sender].index] == msg.sender); // check if player already joined
      registerPlayer(gameId, msg.sender, _name);
  }
  
  function startGame(bytes32 gameId) public{
      require(games[gameId].owner == msg.sender);
      require(games[gameId].gameState == GameState.Created);
      
      
      //randomize order of chance/community
      
      games[gameId].gameState = GameState.Playing;
  }
  
  
}

