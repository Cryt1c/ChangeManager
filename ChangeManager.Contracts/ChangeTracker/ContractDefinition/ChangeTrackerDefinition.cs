using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Numerics;
using Nethereum.Hex.HexTypes;
using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Web3;
using Nethereum.RPC.Eth.DTOs;
using Nethereum.Contracts.CQS;
using Nethereum.Contracts;
using System.Threading;
namespace ChangeManager.Contracts.ChangeTracker.ContractDefinition
{
    
    
    public partial class ChangeTrackerDeployment:ChangeTrackerDeploymentBase
    {
        public ChangeTrackerDeployment():base(BYTECODE) { }
        
        public ChangeTrackerDeployment(string byteCode):base(byteCode) { }
    }

    public class ChangeTrackerDeploymentBase:ContractDeploymentMessage
    {
        
        public static string BYTECODE = "6080604052348015600f57600080fd5b50603580601d6000396000f3006080604052600080fd00a165627a7a72305820c269d08b5e3f96eb16d6f1b52dac93297bb6a8f81ec448ec64d1cf5d06dd48db0029";
        
        public ChangeTrackerDeploymentBase():base(BYTECODE) { }
        
        public ChangeTrackerDeploymentBase(string byteCode):base(byteCode) { }
        

    }    
    
    public partial class NewChangeRequestEventDTO:NewChangeRequestEventDTOBase{}

    [Event("NewChangeRequest")]
    public class NewChangeRequestEventDTOBase: IEventDTO
    {
        [Parameter("bytes20", "_gitHash", 1, true )]
        public virtual byte[] GitHash {get; set;}
        [Parameter("string", "_additionalInformation", 2, false )]
        public virtual string AdditionalInformation {get; set;}
        [Parameter("uint256", "_costs", 3, false )]
        public virtual BigInteger Costs {get; set;}
        [Parameter("uint256", "_estimation", 4, false )]
        public virtual BigInteger Estimation {get; set;}
    }    
    
    public partial class NewVoteEventDTO:NewVoteEventDTOBase{}

    [Event("NewVote")]
    public class NewVoteEventDTOBase: IEventDTO
    {
        [Parameter("bytes20", "_gitHash", 1, true )]
        public virtual byte[] GitHash {get; set;}
        [Parameter("address", "_voter", 2, false )]
        public virtual string Voter {get; set;}
        [Parameter("bool", "_vote", 3, false )]
        public virtual bool Vote {get; set;}
        [Parameter("uint8", "_currentState", 4, false )]
        public virtual byte CurrentState {get; set;}
        [Parameter("string", "_voteInfo", 5, false )]
        public virtual string VoteInfo {get; set;}
        [Parameter("uint256", "_votesLeft", 6, false )]
        public virtual BigInteger VotesLeft {get; set;}
    }
}
