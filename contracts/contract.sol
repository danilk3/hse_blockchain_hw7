// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract HW7 {
    enum Phase {
        WaitingForFirstPlayer,
        WaitingForSecondPlayer,
        AllPlayersJoined,
        FirstPlayerCommited,
        SecondPlayerCommited,
        FirstPlayerRevealed,
        SecondPlayerRevealed
    }

    enum Move {
        None,
        Rock,
        Paper,
        Scissors
    }

    event WinnerChanged(address winner);

    struct PlayerMove {
        Move move;
        bytes32 commitHash;
        address playerAddress;        
    }

    struct Game {
        PlayerMove player1;
        PlayerMove player2;
    }

    Game public game;

    Phase public phase;

    function setPhase(Phase newPhase) private {
        phase = newPhase;
    }

    function joinPlayer() public {
        if(phase == Phase.WaitingForFirstPlayer) {
            game.player1.playerAddress = msg.sender;
            setPhase(Phase.WaitingForSecondPlayer);
        }
        else if(phase == Phase.WaitingForSecondPlayer) {
            game.player2.playerAddress = msg.sender;
            setPhase(Phase.AllPlayersJoined);
        }
        else {
            revert("Game is already started");
        }
    }

    function commitMove(bytes32 hash) external {
        if(game.player1.playerAddress == msg.sender) {
            game.player1.commitHash = hash;
            setPhase(Phase.FirstPlayerCommited);
        }
        else if(game.player2.playerAddress == msg.sender) {
            game.player2.commitHash = hash;
            setPhase(Phase.SecondPlayerCommited);
        }
        else {
            revert("The address is underfined.");
        }
    }
    
    bytes32 public hash;

    function revealMove(uint256 moveId, string memory salt) external {
        hash = keccak256(abi.encodePacked(moveId, salt));
        if(game.player1.playerAddress == msg.sender) {
            require(game.player1.commitHash == hash, "hash is broken");
            game.player1.move = Move(moveId);
            setPhase(Phase.FirstPlayerRevealed);
        }
        else if(game.player2.playerAddress == msg.sender) {
            require(game.player2.commitHash == hash, "hash is broken");
            game.player2.move = Move(moveId);
            setPhase(Phase.SecondPlayerRevealed);
        }
        else {
            revert("The address is underfined");
        }
    }

    function getWinner() external {
        require(game.player1.move == Move.None || game.player2.move == Move.None, "The game is not over yet");
        if(game.player1.move == game.player2.move) {
            emit WinnerChanged(address(0));
        }
        else if(getFightResult()) {
            emit WinnerChanged(game.player1.playerAddress);
        } 
        else {
            emit WinnerChanged(game.player2.playerAddress);
        }
        clearMoves();
    }

    function getFightResult() private {
        return ((game.player1.move == Move.Rock && game.player1.move == Move.Scissors) 
            ||
            (game.player1.move == Move.Paper && game.player1.move == Move.Rock) 
            ||
            (game.player1.move == Move.Scissors && game.player1.move == Move.Paper));
    }

    function clearMoves() private {
        setPhase(Phase.WaitingForFirstPlayer);
        game.player1.move = Move.None;
        game.player2.move = Move.None;
    }
}