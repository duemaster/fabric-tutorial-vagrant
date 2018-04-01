#!/bin/bash 
# cd to composer-playground folder

# clear playground
# echo "y" | ./playground.sh down; 

# timeout 60s echo "y" | ./playground.sh; 

# echo "y" | ./playground.sh

# Create CA
docker exec -it ca.org1.example.com fabric-ca-client enroll -M registrar -u http://admin:adminpw@localhost:7054;

# Register user
PASSWORD=$(docker exec -it ca.org1.example.com fabric-ca-client register -M registrar -u http://localhost:7054 --id.name admin1 --id.affiliation org1 --id.attrs '"hf.Registrar.Roles=client"' --id.type user);

# Extract Password
PASSWORD=${PASSWORD##*"Password: "};

# Trim password (remove whitespace characters)
PASSWORD="$(echo -e "${PASSWORD}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')";

# Write password into .txt
echo $PASSWORD > myPassword.txt

PASSWORD=$(cat myPassword.txt);
echo $PASSWORD;

docker exec cli composer network deploy --archiveFile /mnt/air-chain.bna -A admin1 -c PeerAdmin@hlfv1 -S $PASSWORD;

docker exec cli composer card import -f admin1@air-chain.card;

echo "Creating default Airline Company: Airline1"
docker exec cli composer transaction submit --card admin1@air-chain -d '{"$class": "org.hyperledger.composer.system.AddAsset","registryType": "Asset","registryId": "org.airline.airChain.AirlineCompany", "targetRegistry" : "resource:org.hyperledger.composer.system.AssetRegistry#org.airline.airChain.AirlineCompany", "resources": [{"$class": "org.airline.airChain.AirlineCompany","id": "Airline1","name": "MyAirline1"}]}';

echo "Creating default Cargo Company: Cargo1"
docker exec cli composer transaction submit --card admin1@air-chain -d '{"$class": "org.hyperledger.composer.system.AddAsset","registryType": "Asset","registryId": "org.airline.airChain.CargoCompany", "targetRegistry" : "resource:org.hyperledger.composer.system.AssetRegistry#org.airline.airChain.CargoCompany", "resources": [{"$class": "org.airline.airChain.CargoCompany","id": "Cargo1","name": "MyCargo1"}]}';

echo "Creating default GHA Company: GHA1"
docker exec cli composer transaction submit --card admin1@air-chain -d '{"$class": "org.hyperledger.composer.system.AddAsset","registryType": "Asset","registryId": "org.airline.airChain.GHACompany", "targetRegistry" : "resource:org.hyperledger.composer.system.AssetRegistry#org.airline.airChain.GHACompany", "resources": [{"$class": "org.airline.airChain.GHACompany","id": "GHA1","name": "MyGHA1"}]}';

echo "Start REST Server at Port: 3000"
docker exec cli composer-rest-server -c admin1@air-chain -p 3000;