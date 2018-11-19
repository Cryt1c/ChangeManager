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
using ChangeManager.Contracts.ChangeManager.ContractDefinition;
namespace ChangeManager.Contracts.ChangeManager
{

    public partial class ChangeManagerService
    {
    
        public static Task<TransactionReceipt> DeployContractAndWaitForReceiptAsync(Nethereum.Web3.Web3 web3, ChangeManagerDeployment changeManagerDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            return web3.Eth.GetContractDeploymentHandler<ChangeManagerDeployment>().SendRequestAndWaitForReceiptAsync(changeManagerDeployment, cancellationTokenSource);
        }
        public static Task<string> DeployContractAsync(Nethereum.Web3.Web3 web3, ChangeManagerDeployment changeManagerDeployment)
        {
            return web3.Eth.GetContractDeploymentHandler<ChangeManagerDeployment>().SendRequestAsync(changeManagerDeployment);
        }
        public static async Task<ChangeManagerService> DeployContractAndGetServiceAsync(Nethereum.Web3.Web3 web3, ChangeManagerDeployment changeManagerDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            var receipt = await DeployContractAndWaitForReceiptAsync(web3, changeManagerDeployment, cancellationTokenSource);
            return new ChangeManagerService(web3, receipt.ContractAddress);
        }
    
        protected Nethereum.Web3.Web3 Web3{ get; }
        
        public ContractHandler ContractHandler { get; }
        
        public ChangeManagerService(Nethereum.Web3.Web3 web3, string contractAddress)
        {
            Web3 = web3;
            ContractHandler = web3.Eth.GetContractHandler(contractAddress);
        }
    
        public Task<ViewChangeOutputDTO> ViewChangeQueryAsync(ViewChangeFunction viewChangeFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryDeserializingToObjectAsync<ViewChangeFunction, ViewChangeOutputDTO>(viewChangeFunction, blockParameter);
        }

        
        public Task<ViewChangeOutputDTO> ViewChangeQueryAsync(byte[] gitHash, BlockParameter blockParameter = null)
        {
            var viewChangeFunction = new ViewChangeFunction();
                viewChangeFunction.GitHash = gitHash;
            
            return ContractHandler.QueryDeserializingToObjectAsync<ViewChangeFunction, ViewChangeOutputDTO>(viewChangeFunction, blockParameter);
        }



        public Task<ViewStateOutputDTO> ViewStateQueryAsync(ViewStateFunction viewStateFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryDeserializingToObjectAsync<ViewStateFunction, ViewStateOutputDTO>(viewStateFunction, blockParameter);
        }

        
        public Task<ViewStateOutputDTO> ViewStateQueryAsync(byte[] gitHash, BlockParameter blockParameter = null)
        {
            var viewStateFunction = new ViewStateFunction();
                viewStateFunction.GitHash = gitHash;
            
            return ContractHandler.QueryDeserializingToObjectAsync<ViewStateFunction, ViewStateOutputDTO>(viewStateFunction, blockParameter);
        }



        public Task<string> ReleaseChangeRequestAsync(ReleaseChangeFunction releaseChangeFunction)
        {
             return ContractHandler.SendRequestAsync(releaseChangeFunction);
        }

        public Task<TransactionReceipt> ReleaseChangeRequestAndWaitForReceiptAsync(ReleaseChangeFunction releaseChangeFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(releaseChangeFunction, cancellationToken);
        }

        public Task<string> ReleaseChangeRequestAsync(byte[] gitHash)
        {
            var releaseChangeFunction = new ReleaseChangeFunction();
                releaseChangeFunction.GitHash = gitHash;
            
             return ContractHandler.SendRequestAsync(releaseChangeFunction);
        }

        public Task<TransactionReceipt> ReleaseChangeRequestAndWaitForReceiptAsync(byte[] gitHash, CancellationTokenSource cancellationToken = null)
        {
            var releaseChangeFunction = new ReleaseChangeFunction();
                releaseChangeFunction.GitHash = gitHash;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(releaseChangeFunction, cancellationToken);
        }

        public Task<string> CreateNewChangeRequestRequestAsync(CreateNewChangeRequestFunction createNewChangeRequestFunction)
        {
             return ContractHandler.SendRequestAsync(createNewChangeRequestFunction);
        }

        public Task<TransactionReceipt> CreateNewChangeRequestRequestAndWaitForReceiptAsync(CreateNewChangeRequestFunction createNewChangeRequestFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createNewChangeRequestFunction, cancellationToken);
        }

        public Task<string> CreateNewChangeRequestRequestAsync(byte[] gitHash, string additionalInformation, BigInteger costs, BigInteger estimation)
        {
            var createNewChangeRequestFunction = new CreateNewChangeRequestFunction();
                createNewChangeRequestFunction.GitHash = gitHash;
                createNewChangeRequestFunction.AdditionalInformation = additionalInformation;
                createNewChangeRequestFunction.Costs = costs;
                createNewChangeRequestFunction.Estimation = estimation;
            
             return ContractHandler.SendRequestAsync(createNewChangeRequestFunction);
        }

        public Task<TransactionReceipt> CreateNewChangeRequestRequestAndWaitForReceiptAsync(byte[] gitHash, string additionalInformation, BigInteger costs, BigInteger estimation, CancellationTokenSource cancellationToken = null)
        {
            var createNewChangeRequestFunction = new CreateNewChangeRequestFunction();
                createNewChangeRequestFunction.GitHash = gitHash;
                createNewChangeRequestFunction.AdditionalInformation = additionalInformation;
                createNewChangeRequestFunction.Costs = costs;
                createNewChangeRequestFunction.Estimation = estimation;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createNewChangeRequestFunction, cancellationToken);
        }

        public Task<string> ResponsibleVoteRequestAsync(ResponsibleVoteFunction responsibleVoteFunction)
        {
             return ContractHandler.SendRequestAsync(responsibleVoteFunction);
        }

        public Task<TransactionReceipt> ResponsibleVoteRequestAndWaitForReceiptAsync(ResponsibleVoteFunction responsibleVoteFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(responsibleVoteFunction, cancellationToken);
        }

        public Task<string> ResponsibleVoteRequestAsync(byte[] gitHash, bool acceptChange, string voteInfo)
        {
            var responsibleVoteFunction = new ResponsibleVoteFunction();
                responsibleVoteFunction.GitHash = gitHash;
                responsibleVoteFunction.AcceptChange = acceptChange;
                responsibleVoteFunction.VoteInfo = voteInfo;
            
             return ContractHandler.SendRequestAsync(responsibleVoteFunction);
        }

        public Task<TransactionReceipt> ResponsibleVoteRequestAndWaitForReceiptAsync(byte[] gitHash, bool acceptChange, string voteInfo, CancellationTokenSource cancellationToken = null)
        {
            var responsibleVoteFunction = new ResponsibleVoteFunction();
                responsibleVoteFunction.GitHash = gitHash;
                responsibleVoteFunction.AcceptChange = acceptChange;
                responsibleVoteFunction.VoteInfo = voteInfo;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(responsibleVoteFunction, cancellationToken);
        }

        public Task<string> ManagementVoteRequestAsync(ManagementVoteFunction managementVoteFunction)
        {
             return ContractHandler.SendRequestAsync(managementVoteFunction);
        }

        public Task<TransactionReceipt> ManagementVoteRequestAndWaitForReceiptAsync(ManagementVoteFunction managementVoteFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(managementVoteFunction, cancellationToken);
        }

        public Task<string> ManagementVoteRequestAsync(byte[] gitHash, bool acceptChange, List<string> responsibleParties, string voteInfo)
        {
            var managementVoteFunction = new ManagementVoteFunction();
                managementVoteFunction.GitHash = gitHash;
                managementVoteFunction.AcceptChange = acceptChange;
                managementVoteFunction.ResponsibleParties = responsibleParties;
                managementVoteFunction.VoteInfo = voteInfo;
            
             return ContractHandler.SendRequestAsync(managementVoteFunction);
        }

        public Task<TransactionReceipt> ManagementVoteRequestAndWaitForReceiptAsync(byte[] gitHash, bool acceptChange, List<string> responsibleParties, string voteInfo, CancellationTokenSource cancellationToken = null)
        {
            var managementVoteFunction = new ManagementVoteFunction();
                managementVoteFunction.GitHash = gitHash;
                managementVoteFunction.AcceptChange = acceptChange;
                managementVoteFunction.ResponsibleParties = responsibleParties;
                managementVoteFunction.VoteInfo = voteInfo;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(managementVoteFunction, cancellationToken);
        }
    }
}
