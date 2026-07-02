# build
docker build -t bitcoin .

# run
mkdir data && docker run -d --rm --name bitcoin -p 8332:8332 -v ./data:/root bitcoin
