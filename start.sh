#!/bin/bash
cd "$(dirname "$0")"
PORT=3000
# Prüfe ob Port frei ist
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
  echo "Port $PORT bereits belegt — öffne Browser direkt..."
else
  echo "Starte HTTP-Server auf Port $PORT..."
  python3 -m http.server $PORT --bind 127.0.0.1 &
  SERVER_PID=$!
  sleep 0.5
  echo "Server läuft (PID $SERVER_PID)"
  echo "Zum Beenden: kill $SERVER_PID"
fi
open "http://localhost:$PORT/index.html"
