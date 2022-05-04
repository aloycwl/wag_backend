pragma solidity^0.8.13;//SPDX-License-Identifier:None
contract util{
    /*
    Get the card final number
    Jack, Queen and King = 10 
    */
    function getCardVal(uint256 a)private pure returns(uint256 c){
        c=a%13;
        c=c==0||c>9?10:c;
    }
}