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
namespace ChangeManager.Contracts.Migrations.ContractDefinition
{
    
    
    public partial class MigrationsDeployment:MigrationsDeploymentBase
    {
        public MigrationsDeployment():base(BYTECODE) { }
        
        public MigrationsDeployment(string byteCode):base(byteCode) { }
    }

    public class MigrationsDeploymentBase:ContractDeploymentMessage
    {
        
        public static string BYTECODE = "608060405234801561001057600080fd5b5060008054600160a060020a0319163317905561023c806100326000396000f3006080604052600436106100615763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416630900f0108114610066578063445df0ac146100965780638da5cb5b146100bd578063fdacd576146100fb575b600080fd5b34801561007257600080fd5b5061009473ffffffffffffffffffffffffffffffffffffffff60043516610113565b005b3480156100a257600080fd5b506100ab6101c5565b60408051918252519081900360200190f35b3480156100c957600080fd5b506100d26101cb565b6040805173ffffffffffffffffffffffffffffffffffffffff9092168252519081900360200190f35b34801561010757600080fd5b506100946004356101e7565b6000805473ffffffffffffffffffffffffffffffffffffffff163314156101c1578190508073ffffffffffffffffffffffffffffffffffffffff1663fdacd5766001546040518263ffffffff167c010000000000000000000000000000000000000000000000000000000002815260040180828152602001915050600060405180830381600087803b1580156101a857600080fd5b505af11580156101bc573d6000803e3d6000fd5b505050505b5050565b60015481565b60005473ffffffffffffffffffffffffffffffffffffffff1681565b60005473ffffffffffffffffffffffffffffffffffffffff1633141561020d5760018190555b505600a165627a7a723058203b6c64cec9d516b6e3a4847e15ca172cfe6c2dc766991b8df3f2580f83d606740029";
        
        public MigrationsDeploymentBase():base(BYTECODE) { }
        
        public MigrationsDeploymentBase(string byteCode):base(byteCode) { }
        

    }    
    
    public partial class UpgradeFunction:UpgradeFunctionBase{}

    [Function("upgrade")]
    public class UpgradeFunctionBase:FunctionMessage
    {
        [Parameter("address", "new_address", 1)]
        public virtual string New_address {get; set;}
    }    
    
    public partial class Last_completed_migrationFunction:Last_completed_migrationFunctionBase{}

    [Function("last_completed_migration", "uint256")]
    public class Last_completed_migrationFunctionBase:FunctionMessage
    {

    }    
    
    public partial class OwnerFunction:OwnerFunctionBase{}

    [Function("owner", "address")]
    public class OwnerFunctionBase:FunctionMessage
    {

    }    
    
    public partial class SetCompletedFunction:SetCompletedFunctionBase{}

    [Function("setCompleted")]
    public class SetCompletedFunctionBase:FunctionMessage
    {
        [Parameter("uint256", "completed", 1)]
        public virtual BigInteger Completed {get; set;}
    }    
    
    
    
    public partial class Last_completed_migrationOutputDTO:Last_completed_migrationOutputDTOBase{}

    [FunctionOutput]
    public class Last_completed_migrationOutputDTOBase :IFunctionOutputDTO 
    {
        [Parameter("uint256", "", 1)]
        public virtual BigInteger ReturnValue1 {get; set;}
    }    
    
    public partial class OwnerOutputDTO:OwnerOutputDTOBase{}

    [FunctionOutput]
    public class OwnerOutputDTOBase :IFunctionOutputDTO 
    {
        [Parameter("address", "", 1)]
        public virtual string ReturnValue1 {get; set;}
    }    
    

}
