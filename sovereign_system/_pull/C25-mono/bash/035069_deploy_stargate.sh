#!/bin/bash

echo "Unzipping AiKre8tive-Stargate.zip..."
unzip -o AiKre8tive-Stargate.zip

echo "Changing into project directory..."
cd AiKre8tive-Stargate || { echo "Failed to enter directory"; exit 1; }

echo "Starting Vercel deployment..."
vercel --prod
