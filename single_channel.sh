#!/bin/sh

# find address of orderer and peers in your network
ORDERER_IP=`perl -e 'use Socket; $a = inet_ntoa(inet_aton("orderer")); print "$a\n";'`
PEER0_IP=`perl -e 'use Socket; $a = inet_ntoa(inet_aton("peer0")); print "$a\n";'`
PEER1_IP=`perl -e 'use Socket; $a = inet_ntoa(inet_aton("peer1")); print "$a\n";'`
PEER2_IP=`perl -e 'use Socket; $a = inet_ntoa(inet_aton("peer2")); print "$a\n";'`

echo "-----------------------------------------"
echo "Ordere IP $ORDERER_IP"
echo "PEER0 IP $PEER0_IP"
echo "PEER1 IP $PEER1_IP"
echo "PEER2 IP $PEER2_IP"
echo "-----------------------------------------"

CORE_PEER_GOSSIP_IGNORESECURITY=true
CORE_PEER_COMMITTER_LEDGER_ORDERER=$ORDERER_IP:7050
CORE_PEER_ADDRESS=$PEER0_IP:7051

###TODO: Add checks for the results
peer channel create -c myc1 -f channelTx>log.txt 2>&1 
cat log.txt
echo "===================== channel \"myc1\" is created successfully ===================== "
echo
peer channel join -b myc1.block >log.txt 2>&1
cat log.txt
echo "===================== peer0 joined on the channel \"myc1\" ===================== "

peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_sample >log.txt 2>&1
cat log.txt
echo "===================== Chaincode is installed on remote peer PEER0 ===================== "

#CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/chaincode_sample/crypto/peer/peer0/localMspConfig 
peer chaincode instantiate -C myc1 -n mycc -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_sample -c '{"Args":[""]}' -P "AND('MspOrg0.member')" >log.txt 2>&1
cat log.txt
echo "===================== Instantiated chaincode on PEER0 ===================== "
sleep 15

#CORE_PEER_COMMITTER_LEDGER_ORDERER=$ORDERER_IP:7050 CORE_PEER_ADDRESS=$PEER0_IP:7051 
peer chaincode invoke -C myc1 -n mycc -c '{"function":"invoke","Args":["put","a","yugfoiuehyorye87y4yiushdofhjfjdsfjshdfsdkfsdifsdpiupisupoirusoiuou"]}' >log.txt 2>&1
cat log.txt
echo "===================== Invoke transaction on chaincode===================== "
sleep 15

#CORE_PEER_COMMITTER_LEDGER_ORDERER=$ORDERER_IP:7050 CORE_PEER_ADDRESS=$PEER0_IP:7051 
peer chaincode query -C myc1 -n mycc -c '{"function":"invoke","Args":["get","a"]}' >log.txt 2>&1
cat log.txt
grep -q "yugfoiuehyorye87y4yiushdofhjfjdsfjshdfsdkfsdifsdpiupisupoirusoiuou" log.txt
if [ $? -ne 0 ]; then
   echo "Error !!! Query on chaincode on PEER0 is FAILED ===================== "
   exit 1
fi

echo "===================== Query on chaincode on PEER0 is successful ===================== "
echo "===================== Single Channel Test execution completed ===================== "
exit 0
