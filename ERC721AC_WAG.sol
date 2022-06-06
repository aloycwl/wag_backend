pragma solidity>0.8.0;//SPDX-License-Identifier:None
import"https://github.com/aloycwl/ERC_AC/blob/main/ERC721AC/ERC721AC.sol";
interface IERC20AC{
    function REGISTER(address,address)external;
    function MINT(address,uint,uint)external;
}
contract ERC721_LSG is ERC721AC{
    uint public count;
    IERC20AC private ierc20ac;
    constructor(address a){
        ierc20ac=IERC20AC(a);
    }
    function name()external pure override returns(string memory){
        return"We Are Gamblers NFT";
    }
    function symbol()external pure override returns(string memory){
        return"WAGN";
    }
    function tokenURI(uint)public pure override returns(string memory){
        return"https://kongz.herokuapp.com/api/metadata/1";
    }
    function MINT(address a,address b)external{unchecked{
        (count++,_balances[a]+=1,_owners[count]=a);
        ierc20ac.REGISTER(a,b);
        ierc20ac.MINT(a,5e22,0);
        emit Transfer(address(0),a,count);
    }}
}