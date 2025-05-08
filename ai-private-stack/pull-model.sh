#!/bin/bash

read -p "Enter the name of the model to pull (e.g., mistral, llama3, phi3): " MODEL

if [ -z "$MODEL" ]; then
  echo "❌ No model name entered. Exiting."
  exit 1
fi

echo "📥 Pulling model: $MODEL"
docker exec -it open-webui ollama pull "$MODEL"
