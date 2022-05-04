/* DEPLOYMENT: JOIN & DEAL to external */
pragma solidity^0.8.13;//SPDX-License-Identifier:None
interface IWAC{
    function BURN(address a,uint256 m)external;
    function MINT(address a,uint256 m)external;
} 
contract niuniu{
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
    constructor(){
        _owner=msg.sender;
        /* TESTING */
        player[msg.sender].balance=100;
        JOIN(1,10);
        DEAL(1);
    }
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
    function JOIN(uint256 a,uint256 b)public{unchecked{
        address m=msg.sender;
        require(room[a].playerCount<5&&player[m].room!=a&&a!=0);
        //Available room && not same room && not reserved room
        if(room[a].players.length==0){ //Initiate the room
            require(b>=10); //Bet size must be more than 0
            room[a].betSize=b; //Set the room bet size
        }
        require(player[m].balance>=room[a].betSize);
        (player[m].playing,player[m].room)=(true,a); //In case player disconnect
        room[a].players.push(m); //Add a player
        room[a].playerCount++;
    }}
    function LEAVE(uint256 a,address b)public{unchecked{
        require(player[msg.sender].room==a||msg.sender==_owner);
        player[b].room=0;
        if(room[a].players.length==1)delete room[a]; //Delete room if no more player
        else{
            uint256 c; //Move players up
            for(uint256 i=0;i<room[a].players.length;i++)if(room[a].players[i]==b)c=i;
            room[a].players[c]=room[a].players[room[a].players.length-1];
            room[a].players.pop();
            room[a].playerCount--;
        }
    }}
    function DEAL(uint256 a)public{unchecked{
        Room memory ra=room[a];
        require(msg.sender==ra.players[0]&&ra.balance==0);
        //Only host can deal and game is not being dealt yet
        (uint256[52]memory table,uint256 hash,uint256 count,uint256 bs)=(
            [uint256(3),39,19,36,6,24,46,16,29,34,47,1,7,13,15,44,25,18,37,21,
            28,31,41,12,42,14,4,32,23,9,17,51,2,5,43,33,20,40,8,49,52,30,22,27,38,35,45,50,26,48,10,11],
            uint256(keccak256(abi.encodePacked(block.timestamp))),51,ra.betSize);
        uint256 i;
        uint256 j;
        uint256 ran;
        address rp;
        for(i=0;i<ra.players.length;i++){ //Number of active players in the room
            rp=ra.players[i];
            if(player[rp].playing&&player[msg.sender].balance>=bs){
            //Player is set to play and have enough money    
                player[rp].balance-=bs; //Generate pool amount
                room[a].balance+=bs;
                //Only when they are choose to play the round and have enough tokens
                for(j=0;j<5;j++){ //Only distribute 5 cards
                    (ran,player[rp].cards[j],table[ran])=(hash%count,table[ran],table[count]);
                    //Pick the remaining cards & move the last position to replace the current position
                    hash/=count; //Create different random
                    count--; //Take away the last position
                }
            }
        }
    }}
    function CHECK(uint256 a)external{unchecked{
        Room memory r=room[a];
        (uint256 rb,address[]memory rp,uint256 rs)=(r.balance,r.players,r.betSize);
        uint256 rl=rp.length;
        require(msg.sender==rp[0]&&rb>0); //Only host can check & have dealt
        uint256 highest;
        uint256 i;
        uint256 j;
        uint256 count;
        uint256 winnerCount;
        Player memory pi;
        for(i=0;i<rl;i++){ //Number of active players in the room
            pi=player[rp[i]];
            if(pi.cards[0]>0){ //If player has cards
                count=0;
                for(j=0;j<5;j++){ //Go through every cards
                    count+=cardVal(pi.cards[j]); //Calculate single card value
                    player[rp[i]].cards[j]=0;
                }
                count%=10; //Remove the front number
                count=count==0?10:count;
                (player[rp[i]].points,highest)=(count,count>=highest?count:highest); //10 being highest
            }
        }
        for(i=0;i<rl;i++){ //Getting number of winners
            pi=player[rp[i]];
            if(pi.points==highest)winnerCount++;
            player[rp[0]].balance+=(rb*5/100); //5% for host (Maybe safemath issue)
            winnerCount=rb*9/10/winnerCount; //Minus 5% for admin and divide winnings
            for(i=0;i<rl;i++){ //Distribute tokens
                if(player[rp[i]].points==highest)pi.balance+=winnerCount;
                if(player[rp[i]].balance<rs)LEAVE(a,rp[i]);
            }
        }
        room[a].balance=0;
    }}
    function getRoomInfo(uint256 a)external view returns(address[]memory b,uint256[5]memory c
        ,uint256[5]memory d,uint256[5]memory e,uint256[5]memory f,uint256[5]memory g){
        Room memory r=room[a];
        b=r.players; //Only get cards if there is a player
        (uint256 h,address[]memory rp)=(b.length,r.players);
        if(h>0)c=player[rp[0]].cards;
        if(h>1)d=player[rp[1]].cards;
        if(h>2)e=player[rp[2]].cards;
        if(h>3)f=player[rp[3]].cards;
        if(h>4)g=player[rp[4]].cards;
    }
    function getNiu(address a)public view returns(uint256 c,uint256 d,uint256 e,uint256 f){unchecked{
        c=99;
        uint256[5]memory ca=player[a].cards;
        uint256 c1;
        uint256 i;
        uint256 j;
        uint256 k;
        uint256 l;
        for(i=0;i<5;i++)for(j=0;j<5;j++)for(k=0;k<5;k++){ //Loop cards 3 times
            c1=(cardVal(ca[i])+cardVal(ca[j])+cardVal(ca[k]))%10; //Add together multiple of 10
            if(c1==0&&i!=j&&j!=k&&i!=k){ //No repeated card
                for(l=0;l<5;l++) //Find the addition of the remaining 2 cards value
                if(l!=i&&l!=j&&l!=k)c1+=cardVal(ca[l]);
                return(c1%10,i,j,k);
            }
        }
    }}
    function cardVal(uint256 a)private pure returns(uint256 c){
        c=a%13;
        c=c==0||c>9?10:c;
    }
    function getPlayerVal()external view returns(uint256[5]memory b){
        for(uint256 i=0;i<5;i++)b[i]=cardVal(player[msg.sender].cards[i]);
    }
}