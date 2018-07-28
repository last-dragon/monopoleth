pragma solidity ^0.4.2;

contract BattleShip {

    enum GameState { Created, SettingUp, Playing, Finished }

    struct Game {
        address player1;
        address player2;
        string player1Name;
        string player2Name;
        address currentPlayer;
        address winner;
        GameState gameState;
        uint pot;
        uint availablePot;
        mapping(address => int8[10][10]) playerGrids;
        mapping(address => bool[4]) playerShips;
    }

    mapping(address => string) public playerNames;
    mapping(bytes32 => bool) public playerNameExists;
    mapping(bytes32 => Game) public games;
    mapping(address => bytes32[]) playerGames;

    uint8 public maxBoatLength;
    uint8 public minBoatLength;

    // otherPlayerBoard
    int8[10][10] otherPlayerBoard;

    event PlayerSetName(address player, string name);

    event GameInitialized(bytes32 gameId, address player1, bool player1GoesFirst, uint pot);
    event GameJoined(bytes32 gameId, address player2);
    event ShipPlaced(bytes32 gameId, address player, uint8 startX, uint8 endX, uint8 startY, uint8 endY);
    event StateChanged(bytes32 gameId, GameState newState, string newStateString);

    event MadeMove(bytes32 gameId, address currentPlayer, uint8 x, uint8 y);
    event HitBattleShip(bytes32 gameId, address currentPlayer, uint8 x, uint8 y, int8 pieceHit);
    event WonChallenged(bytes32 gameId, address player);
    event GameEnded(bytes32 gameId, address winner);
    
    event WinningsWithdrawn(bytes32 gameId, address player);
    event WithdrawFailed(bytes32 gameId, address player, string reason);

    event IsStateCalled(bytes32 gameId, GameState currentState, GameState comparingState, bool equal);
    event IsPlayerCalled(bytes32 gameId, address player);
    event LogCurrentState(bytes32 gameId, GameState state);

    function stringToBytes32(string memory source) returns (bytes32 result) {
        assembly {
            result := mload(add(source, 32))
        }
    }

    modifier hasName() {
        if(stringToBytes32(playerNames[msg.sender]) != bytes32(0x0)) _;
    }

    modifier isPlayer(bytes32 gameId) {
        IsPlayerCalled(gameId,msg.sender);

        if(msg.sender == games[gameId].player1 || msg.sender == games[gameId].player2) _;
    }

    modifier isCurrentPlayer(bytes32 gameId) {
        if(msg.sender == games[gameId].currentPlayer) _;
    }

    modifier isState(bytes32 gameId, GameState state){
        IsStateCalled(gameId,state, games[gameId].gameState, state == games[gameId].gameState);
        if(state == games[gameId].gameState) _;
    }

    function abs(int number) internal constant returns(uint unumber) {
        if(number < 0) return uint(-1 * number);
        return uint(number);
    }


    function initialiseBoard(bytes32 gameId, address player) isState(gameId, GameState.Created) internal {
        for(uint8 i = 0; i < 10; i++) {
            for(uint8 j = 0; j < 10; j++) {
                games[gameId].playerGrids[player][i][j] = 0;
            }
        }
    }

    function findOtherPlayer(bytes32 gameId,address player) internal constant returns(address) {
        if(player == games[gameId].player1) return games[gameId].player2;
        return games[gameId].player1;
    }

    function BattleShip() {
        maxBoatLength = 5;
        minBoatLength = 2;
    }

    function setName(string name){
        require(bytes(name).length <= 30);
        bytes32 bytesname = stringToBytes32(name);
        require(!playerNameExists[bytesname]);
        playerNames[msg.sender] = name;
        playerNameExists[bytesname] = true;
        PlayerSetName(msg.sender,name);
    }

    function findPot(bytes32 gameId) constant returns(uint){
        return games[gameId].pot;
    }

    function newGame(bool goFirst) hasName payable returns(bytes32){
        require(msg.value > 0);
        // Generate game id based on player's addresses and current block number
        bytes32 gameId = sha3(msg.sender, block.number);
        playerGames[msg.sender].push(gameId);
        games[gameId] = Game(
            msg.sender, // address player1;
            address(0), // address player2;
            playerNames[msg.sender], //     string player1Name;
            "",  // string player2Name;
            address(0), // address currentPlayer;
            address(0), // address winner;
            GameState.Created, // GameState gameState;
            msg.value * 2, // uint pot;
            msg.value * 2 // uint availablePot;
        );
        if(goFirst){
            games[gameId].currentPlayer = msg.sender;
        }
        GameInitialized(gameId,msg.sender,goFirst,msg.value * 2);
        initialiseBoard(gameId,msg.sender);
        return gameId;
    }

    function joinGame(bytes32 gameId) hasName isState(gameId, GameState.Created) payable {
        require(games[gameId].player2 == address(0));
        require(msg.value == games[gameId].pot / 2);
        games[gameId].player2 = msg.sender;
        games[gameId].player2Name = playerNames[msg.sender];
        playerGames[msg.sender].push(gameId);
        if(games[gameId].currentPlayer == address(0)){
            games[gameId].currentPlayer = msg.sender;
        }
        initialiseBoard(gameId,msg.sender);
        GameJoined(gameId,msg.sender);
        games[gameId].gameState = GameState.SettingUp;
        StateChanged(gameId,GameState.SettingUp,"SettingUp");
    }

    function showBoard(bytes32 gameId) isPlayer(gameId) constant returns(int8[10][10] board) {
        return games[gameId].playerGrids[msg.sender];
    }

    function showOtherPlayerBoard(bytes32 gameId) isPlayer(gameId) constant returns(int8[10][10]){
        require(games[gameId].gameState == GameState.Playing || games[gameId].gameState == GameState.Finished);
        address otherPlayer = findOtherPlayer(gameId,msg.sender);
        int8[10][10] otherGrid = games[gameId].playerGrids[otherPlayer];
        for(uint8 i = 0; i < 10; i++) {
            for(uint j = 0; j < 10; j++) {
                if(otherGrid[i][j] > 0 && otherGrid[i][j] < int(maxBoatLength + 1)){
                    otherPlayerBoard[i][j] = 0;
                }else{
                    otherPlayerBoard[i][j] = otherGrid[i][j];
                }
            }
        }
        return otherPlayerBoard;
    }
    
    function placeShip(bytes32 gameId, uint8 startX, uint8 endX, uint8 startY, uint8 endY) isPlayer(gameId) isState(gameId,GameState.SettingUp) {
        
        require(startX == endX || startY == endY);
        require(startX < endX || startY < endY);
        require(startX  < 10 && startX  >= 0 &&
                endX    < 10 && endX    >= 0 &&
                startY  < 10 && startY  >= 0 &&
                endY    < 10 && endY    >= 0);
        for(uint8 x = startX; x <= endX; x++) {
            for(uint8 y = startY; y <= endY; y++) {
                require(games[gameId].playerGrids[msg.sender][x][y] == 0);
            }   
        }
        uint8 boatLength = 1;
        if(startX == endX) {
            boatLength += uint8(abs(int(startY) - int(endY)));
        }else if(startY == endY) {
            boatLength += uint8(abs(int(startX) - int(endX)));
        }
        require(boatLength <= maxBoatLength && boatLength >= minBoatLength);
        require(!(games[gameId].playerShips[msg.sender][boatLength - minBoatLength]));

        games[gameId].playerShips[msg.sender][boatLength - minBoatLength] = true;

        LogCurrentState(gameId,games[gameId].gameState);

        for(x = startX; x <= endX; x++) {
            for(y = startY; y <= endY; y++) {
                games[gameId].playerGrids[msg.sender][x][y] = int8(boatLength);
            }   
        }

        ShipPlaced(gameId, msg.sender, startX, endX, startY, endY);
    }

    function finishPlacing(bytes32 gameId) isPlayer(gameId) isState(gameId,GameState.SettingUp) {
        bool ready = true;
        for(uint8 i = 0; i <= maxBoatLength - minBoatLength; i++) {
            if(!games[gameId].playerShips[games[gameId].player1][i] || !games[gameId].playerShips[games[gameId].player2][i]) {
                ready = false;
                break;
            }
        }
        require(ready);
        games[gameId].gameState = GameState.Playing;
        StateChanged(gameId,GameState.Playing,"Playing");
    }

    function makeMove(bytes32 gameId, uint8 x, uint8 y) isState(gameId,GameState.Playing) isCurrentPlayer(gameId) {
        address otherPlayer = findOtherPlayer(gameId,msg.sender);
        require(games[gameId].playerGrids[otherPlayer][x][y] >= 0);
        if(games[gameId].playerGrids[otherPlayer][x][y] > 0 && games[gameId].playerGrids[otherPlayer][x][y] < int(maxBoatLength + 1)) {
            HitBattleShip(gameId,msg.sender,x,y,games[gameId].playerGrids[otherPlayer][x][y]);
            games[gameId].playerGrids[otherPlayer][x][y] = -1 * games[gameId].playerGrids[otherPlayer][x][y];
        }else{
            games[gameId].playerGrids[otherPlayer][x][y] = int8(maxBoatLength + 1);
        }
        games[gameId].currentPlayer = otherPlayer;
        MadeMove(gameId,msg.sender,x,y);
    }

    function sayWon(bytes32 gameId) isPlayer(gameId) isState(gameId,GameState.Playing) {
        WonChallenged(gameId,msg.sender);
        address otherPlayer = findOtherPlayer(gameId,msg.sender);
        uint8 requiredToWin = 0;
        for(uint8 i = minBoatLength; i <= maxBoatLength; i++){
            requiredToWin += i;
        }
        int8[10][10] otherPlayerGrid = games[gameId].playerGrids[otherPlayer];
        uint8 numberHit = 0;
        for(i = 0;  i < 10; i++) {
            for(uint j = 0;  j < 10; j++) {
                if(otherPlayerGrid[i][j] < 0){
                    numberHit += 1;
                }
            }    
        }
        if(numberHit >= requiredToWin){
            games[gameId].gameState = GameState.Finished;
            StateChanged(gameId,GameState.Finished,"Finished");
            games[gameId].winner = msg.sender;
            GameEnded(gameId,msg.sender);
        }
    }

    function withdraw(bytes32 gameId) {
        if(games[gameId].gameState != GameState.Finished){
            WithdrawFailed(gameId,msg.sender,'This game isnt over yet');
        }else{
            uint amount = games[gameId].availablePot;
            if(amount > 0){
                if(msg.sender == games[gameId].winner){
                    games[gameId].availablePot = 0;
                    msg.sender.transfer(amount);
                    WinningsWithdrawn(gameId, msg.sender);
                }else{
                    WithdrawFailed(gameId,msg.sender,'This player hasnt won the game');
                }
            }else{
                WithdrawFailed(gameId,msg.sender,'No more funds in the contract for this game');
            }
        }

    }
    
    /* This unnamed function is called whenever someone tries to send ether to the contract */
    function () {
        throw; // Prevents accidental sending of ether
    }
}