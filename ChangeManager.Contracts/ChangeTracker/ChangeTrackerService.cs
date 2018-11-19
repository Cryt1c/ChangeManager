using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Numerics;
using Nethereum.Hex.HexTypes;
using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Web3;
using Nethereum.RPC.Eth.DTOs;
using Nethereum.Contracts.CQS;
using Nethereum.Contracts.ContractHandlers;
using Nethereum.Contracts;
using System.Threading;
using ChangeManager.Contracts.ChangeTracker.ContractDefinition;
namespace ChangeManager.Contracts.ChangeTracker
{

    public partial class ChangeTrackerService
    {
    
        public static Task<TransactionReceipt> DeployContractAndWaitForReceiptAsync(Nethereum.Web3.Web3 web3, ChangeTrackerDeployment changeTrackerDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            return web3.Eth.GetContractDeploymentHandler<ChangeTrackerDeployment>().SendRequestAndWaitForReceiptAsync(changeTrackerDeployment, cancellationTokenSource);
        }
        public static Task<string> DeployContractAsync(Nethereum.Web3.Web3 web3, ChangeTrackerDeployment changeTrackerDeployment)
        {
            return web3.Eth.GetContractDeploymentHandler<ChangeTrackerDeployment>().SendRequestAsync(changeTrackerDeployment);
        }
        public static async Task<ChangeTrackerService> DeployContractAndGetServiceAsync(Nethereum.Web3.Web3 web3, ChangeTrackerDeployment changeTrackerDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            var receipt = await DeployContractAndWaitForReceiptAsync(web3, changeTrackerDeployment, cancellationTokenSource);
            return new ChangeTrackerService(web3, receipt.ContractAddress);
        }
    
        protected Nethereum.Web3.Web3 Web3{ get; }
        
        public ContractHandler ContractHandler { get; }
        
        public ChangeTrackerService(Nethereum.Web3.Web3 web3, string contractAddress)
        {
            Web3 = web3;
            ContractHandler = web3.Eth.GetContractHandler(contractAddress);
        }
    

    }
}
