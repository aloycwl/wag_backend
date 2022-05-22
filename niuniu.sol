/* DEPLOYMENT: JOIN & DEAL to external */
pragma solidity>0.8.0;//SPDX-License-Identifier:None
interface IWAC{
    function BURN(address,uint)external;
    function MINT(address,uint)external;
} 
contract niuniu{
    struct Player{
        uint[5]cards;
        uint[3]niu;
        uint points;
        uint room;
        uint balance;
    }
    struct Room{
        address[]players; //First player automatically is host
        uint betSize;
        uint balance;
        uint playerCount;
    }
    address private iwac;
    address private _owner;
    mapping(uint=>Room)public room;
    mapping(address=>Player)public player;
    constructor(address a){unchecked{
        iwac=a;
        _owner=msg.sender;
        /* TESTING */
        player[msg.sender].balance=100;
        player[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2].balance=
        player[0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db].balance=
        player[0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB].balance=
        player[0x617F2E2fD72FD9D5503197092aC168c91465E7f2].balance=100;
        JOIN(1,10);
        DEAL(1);
    }}
    function DEPOSIT(uint a)external{unchecked{
        player[msg.sender].balance+=a;
        IWAC(iwac).BURN(msg.sender,a);
    }}
    function WITHDRAW(uint a)external{unchecked{
        require(player[msg.sender].balance>=a);
        player[msg.sender].balance-=a;
        IWAC(iwac).MINT(msg.sender,a);
    }}
    function JOIN(uint a,uint b)public{unchecked{
        if(room[a].players.length<1){ //Initiate the room
            require(b>9); //Bet size must be more than 0
            room[a].betSize=b; //Set the room bet size
        }
        require(player[msg.sender].balance>=room[a].betSize); //Have money to bet
        require(room[a].playerCount<5); //Not full
        require(player[msg.sender].room!=a); //Not same room
        require(a>0); //Not reserved room
        room[a].players.push(msg.sender); //Add a player
        (room[a].playerCount++,player[msg.sender].room=a); //In case player disconnect
    }}
    function LEAVE(uint a,address b)public{unchecked{
        require(player[msg.sender].room==a||msg.sender==_owner);
        player[b].room=0;
        if(room[a].players.length==1)delete room[a]; //Delete room if no more player
        else{
            uint c; //Move players up
            for(uint i=0;i<room[a].players.length;i++)if(room[a].players[i]==b)c=i;
            (room[a].players[c]=room[a].players[room[a].players.length-1],room[a].playerCount--);
            room[a].players.pop();
        }
    }}
    function DEAL(uint a)public{unchecked{
        require(room[a].balance==0); //Not in progress
        require(msg.sender==room[a].players[0]); //Host only
        (uint[52]memory table,uint hash,uint count,uint bs)=(
        [uint(3),39,19,36,6,24,46,16,29,34,47,1,7,13,15,44,25,18,37,21,
        28,31,41,12,42,14,4,32,23,9,17,51,2,5,43,33,20,40,8,49,52,30,22,27,38,35,45,50,26,48,10,11],
        uint(keccak256(abi.encodePacked(block.timestamp))),51,room[a].betSize);
        uint i;uint j;uint ran;address rp;
        for(i=0;i<room[a].players.length;i++){ //Number of active players in the room
            rp=room[a].players[i];
            if(player[msg.sender].balance>=bs){ //Player with enough money
                (player[rp].balance-=bs,room[a].balance+=bs); //Generate pool amount
                for(j=0;j<5;j++){ //Only distribute 5 cards
                    ran=hash%count;
                    (player[rp].cards[j],table[ran])=(table[ran],table[count]); // Card selection -1
                    (hash/=count,count--); //Create different random & Take away the last position
                }
            }
        }
    }}
    function CHECK(uint a)external{unchecked{
        (uint rb,address[]memory rp,uint rs,uint rl)=
        (room[a].balance,room[a].players,room[a].betSize,room[a].players.length);
        require(msg.sender==rp[0]); //Host check only
        require(rb>0); //Dealt
        uint highest;uint winnerCount;uint i;uint j;
        for(i=0;i<rl;i++){ //Number of active players in the room
            Player memory pi=player[rp[i]];
            if(pi.cards[0]>0){ //If player has cards
                uint count=0;
                for(j=0;j<5;j++){ //Go through every cards
                    count+=cV(pi.cards[j]); 
                    player[rp[i]].cards[j]=0;
                }
                count%=10; //Remove the front number
                count=count==0?10:count;
                (player[rp[i]].points,highest)=(count,count>=highest?count:highest); //10 being highest
            }
        }
        for(i=0;i<rl;i++)if(player[rp[i]].points==highest)winnerCount++; //Getting number of winners
        player[rp[0]].balance+=(rb*5/100); //5% for host (Maybe safemath issue)
        winnerCount=rb*9/10/winnerCount; //Minus 5% for admin and divide winnings
        for(i=0;i<rl;i++){ //Distribute tokens
            if(player[rp[i]].points==highest)player[rp[i]].balance+=winnerCount;
            if(player[rp[i]].balance<rs)LEAVE(a,rp[i]);
        }
        room[a].balance=0;
    }}
    function getRoomInfo(uint a)external view returns(address[]memory b,uint[25]memory c){unchecked{
        b=room[a].players; //Only get cards if there is a player
        uint i;uint j;uint k;
        for(i=0;i<b.length;i++)for(j=0;j<5;j++)(c[k]=player[b[i]].cards[j],k++);
    }}
    function getNiu(address a)public view returns(uint c,uint d,uint e,uint f){unchecked{
        c=99;
        uint[5]memory ca=player[a].cards;
        uint i;uint j;uint k;uint l;uint c1;
        for(i=0;i<5;i++)for(j=0;j<5;j++)for(k=0;k<5;k++){ //Loop cards 3 times
            c1=(cV(ca[i])+cV(ca[j])+cV(ca[k]))%10; //Add together multiple of 10
            if(c1==0&&i!=j&&j!=k&&i!=k){ //No repeated card
                for(l=0;l<5;l++)if(l!=i&&l!=j&&l!=k)c1+=cV(ca[l]); //Remaining 2 cards
                (c1%=10,c1=c1==0?cV(ca[0])==0&&cV(ca[1])==0&&cV(ca[2])==0&&cV(ca[3])==0&&cV(ca[4])==0?11:10:c1);
                return(c1,i,j,k); //Super Niu
            }
        }
    }}
    function cV(uint a)private pure returns(uint){unchecked{
        a=a%13;
        if(a>9)a=0;
        return a;
    }}
}