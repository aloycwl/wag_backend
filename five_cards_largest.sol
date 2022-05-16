pragma solidity>0.8.0;//SPDX-License-Identifier:None
interface IWAC{
    function BURN(address,uint256)external;
    function MINT(address,uint256)external;
} 
contract five_cards_largest{
    struct Room{
        address[]players; //First player automatically is host
        uint256 betSize;
        uint256 balance;
        uint256 playerCount;
        bool hidden;
    }
    struct Player{
        uint256[5]cards;
        uint256 points;
        bool playing;
        uint256 room;
        uint256 balance;
    }
    IWAC private iWAC;
    address private _owner;
    mapping(uint256=>Room)public room;
    mapping(address=>Player)public player;
    constructor(){_owner=msg.sender;}
    function tokenAddress(address a)external{
        require(_owner==msg.sender);
        iWAC=IWAC(a);
    }
    function DEPOSIT(uint256 a)external{
        iWAC.BURN(msg.sender,a);
        player[msg.sender].balance+=a;
    }
    function WITHDRAW(uint256 a)external{
        require(player[msg.sender].balance>=a);
        player[msg.sender].balance-=a;
        iWAC.MINT(msg.sender,a);
    }
    function JOIN(uint256 a,uint256 b)external{unchecked{
        require(room[a].playerCount<5&&player[msg.sender].room!=a&&a!=0);
        //Available room && not same room && not reserved room
        if(room[a].players.length==0){ //Initiate the room
            require(b>=10); //Bet size must be more than 0
            room[a].betSize=b; //Set the room bet size
        }
        require(player[msg.sender].balance>=room[a].betSize);
        player[msg.sender].playing=true;
        player[msg.sender].room=a; //In case player disconnect
        room[a].players.push(msg.sender); //Add a player
        room[a].playerCount++;
    }}
    function LEAVE(uint256 a,address b)public{unchecked{
        require(player[msg.sender].room==a||msg.sender==_owner);
        player[b].room=0;
        if(room[a].players.length==1)delete room[a]; //Delete room if no more player
        else{
            uint256 c; //Move players up
            for(uint256 i=0;i<room[a].players.length;i++)if(room[a].players[i]==msg.sender)c=i;
            room[a].players[c]=room[a].players[room[a].players.length-1];
            room[a].players.pop();
            room[a].playerCount--;
        }
    }}
    function DEAL(uint256 a)external{unchecked{
        require(msg.sender==room[a].players[0]&&room[a].balance==0);
        //Only host can deal and game is not being dealt yet
        uint256[52]memory table=[uint256(3),39,19,36,6,24,46,16,29,34,47,1,7,13,15,44,25,18,37,21,
        28,31,41,12,42,14,4,32,23,9,17,51,2,5,43,33,20,40,8,49,52,30,22,27,38,35,45,50,26,48,10,11];
        uint256 hash=uint256(keccak256(abi.encodePacked(block.timestamp))); //Generate random long number
        uint256 count=51; //Length of cards remaining
        for(uint256 i=0;i<room[a].players.length;i++) //Number of active players in the room
        if(player[room[a].players[i]].playing&&player[msg.sender].balance>=room[a].betSize){
            player[room[a].players[i]].balance-=room[a].betSize; //Generate pool amount
            room[a].balance+=room[a].betSize;
            //Only when they are choose to play the round and have enough tokens
            for(uint256 j=0;j<5;j++){ //Only distribute 5 cards
                uint256 ran=hash%count; //Pick the remaining cards
                player[room[a].players[i]].cards[j]=table[ran]; //Set the cards
                table[ran]=table[count]; //Move the last position to replace the current position
                hash/=count; //Create different random
                count--; //Take away the last position
            }
        }
    }}
    function CHECK(uint256 a)external{unchecked{
        require(msg.sender==room[a].players[0]&&room[a].balance>0); //Only host can check & have dealt
        uint256 highest;
        for(uint256 i=0;i<room[a].players.length;i++) //Number of active players in the room
        if(player[room[a].players[i]].cards[0]>0){ //If player is playing with more than 1 card
            uint256 count;
            for(uint256 j=0;j<5;j++){ //Go through every cards
                uint256 c=player[room[a].players[i]].cards[j]%13; //Calculate single card value
                c==0||c>9?10:c;
                count+=c;
                player[room[a].players[i]].cards[j]=0;
            }
            count%=10; //Remove the front number
            count=count==0?10:count;
            player[room[a].players[i]].points=count; //10 being highest
            highest=count>=highest?count:highest;
        }
        uint256 winnerCount; //Getting number of winners
        for(uint256 i=0;i<room[a].players.length;i++)
        if(player[room[a].players[i]].points==highest)winnerCount++;
        player[room[a].players[0]].balance+=(room[a].balance*5/100); //5% for host (Maybe safemath issue)
        winnerCount=room[a].balance=room[a].balance*9/10/winnerCount; //Minus 5% for admin and divide winnings
        for(uint256 i=0;i<room[a].players.length;i++){ //Distribute tokens
            if(player[room[a].players[i]].points==highest)player[room[a].players[i]].balance+=winnerCount;
            if(player[room[a].players[i]].balance<room[a].betSize)LEAVE(a,room[a].players[i]);
        }
        room[a].balance=0;
    }}
    function getRoomInfo(uint256 a)external view returns(address[]memory b,
    uint256[5]memory c,uint256[5]memory d,uint256[5]memory e,uint256[5]memory f,uint256[5]memory g){
        b=room[a].players; //Only get cards if there is a player
        if(room[a].players.length>0)c=player[room[a].players[0]].cards;
        if(room[a].players.length>1)d=player[room[a].players[1]].cards;
        if(room[a].players.length>2)e=player[room[a].players[2]].cards;
        if(room[a].players.length>3)f=player[room[a].players[3]].cards;
        if(room[a].players.length>4)g=player[room[a].players[4]].cards;
    }
}