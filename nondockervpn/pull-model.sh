#!/bin/bash

MODEL=$1
if [ -z "$MODEL" ]; then
echo "Usage: $0 <modelname> (models can be found @ https://ollama.com/library )"
exit 1
fi

# read -p "Enter the name of the model to pull (e.g., mistral, llama3, phi3): " MODEL

# if [ -z "$MODEL" ]; then
#   echo "❌ No model name entered. Exiting."
#   exit 1
# fi

echo "📥 Pulling model: $MODEL"
docker exec -it open-webui ollama pull "$MODEL"
