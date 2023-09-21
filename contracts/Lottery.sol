// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6 <0.8.8;

/// @title 랜덤함수 게임 기본
/// @author DasSoo
/*  @notice
//게임 규칙 
1) 0.01이더로만 참여 가능
2) 0.01이더초과 또는 0.01이더 미만일 시 트랜잭션 실패가 발생해 게임 참여 불가
3) 한회당 중복 참여 불가 
4) 하나의 계정으로 여러번 게임에 참여해 이득을 취할 수 있으므로 
중복 참여 불가. 우승자가 나오기 전까지 같은 회에서는 
같은 계정의 주소로 게임참여 불가
5) 난수를 갖고 있는 WinnerNumber번째 사람이 우승한다.
6) 매회 변수  WinnerNumber는 무작위로 바뀌며 
WinnerNumber의 값=번째에 참여한 사람이 우승한다.
7) 배포자만 WinnerNumber를 확인할 수 있다. 
8) 일반 참여자가 변수 WinnerNumber를 보고 우승할 수 있으므로 
배포자만 확인할 수 있게한다.(private )
*/


contract Random {
    /// @notice 참여자 순서(playNumber) 값이 randomNumber()를 통해 생성한 WinnerNumber와 같은면 우승자 and 이더를 받는다
    /// @dev 부가적 기능은 아래 함수에 구현했고 배포자만 관리할 수 있는것은 modifier 구현
    address public owner;
    uint private winnerNumber = 0;
    string private key1;
    uint private key2;
    uint public round = 1;
    uint public playNumber = 0;

    mapping(uint => mapping(address => bool)) public paidAddressList;

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not Owner");
        _;
    }


    event PaidAddress(address indexed sender, uint256 payment);
    event WinnerAddress(address indexed winner);

    constructor(string memory _key1, uint _key2) {
        owner = msg.sender;
        key1 = _key1;
        key2 = _key2;
        winnerNumber = randomNumber();
    }

    /// @notice 참가자로부터 조건에 맞는 이더(0.01)를 받고 중복참여여부를 확인한 후 랜덤숫자 비교하여 우승자 추출 및 이벤트 생성
    receive() external payable {
        require(msg.value == 10**16, "Must be 0.01Ether");
        require(paidAddressList[round][msg.sender] == false, "must be the first time");
        paidAddressList[round][msg.sender] = true;
        playNumber++;

        if(playNumber == winnerNumber) {
            (bool success,) =msg.sender.call{value: address(this).balance}("");
            require(success, "Failed");
            playNumber = 0;
            ++round;

            winnerNumber = randomNumber();
            emit WinnerAddress(msg.sender);
        } else {
            emit PaidAddress(msg.sender, msg.value);
        }
    }

    /// @notice 랜덤숫자 생성하는 함수
    function randomNumber() private view returns(uint) {
        uint num = uint(keccak256(abi.encode(key1))) + key2 + (block.timestamp) + (block.number);
        return 2;
    }

    /// @notice 비밀키 설정(랜덤함수 만드는데 쓰임) -- 관리자용
    function setSecretKey(string memory _key1, uint _key2) public onlyOwner() {
        key1 = _key1;
        key2 = _key2;
    }

    /// @notice 비밀키 확인 -- 관리자용
    function getSecretKey() public view onlyOwner() returns(string memory, uint){
        return(key1,key2);
    }

    /// @notice 우승숫자 확인 -- 관리자용
    function getWinnerNumber() public view onlyOwner() returns(uint256){
        return winnerNumber;
    }

    /// @notice 라운드 확인
     function getRound() public view returns(uint256){
        return round;
    }

    /// @notice 축적된 상금 확인
    function getbalance() public view returns(uint256){
        return address(this).balance;
    } 
}

