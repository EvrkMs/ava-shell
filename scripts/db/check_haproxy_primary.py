#!/usr/bin/env python3
import os
import socket
import time

port = int(os.environ.get("MOCK_PROXY_PORT", "15433"))
target = ("127.0.0.1", port)
last = None

for _ in range(30):
    try:
        s = socket.create_connection(target, timeout=1.0)
        data = s.recv(64).decode("utf-8").strip()
        s.close()
        last = data
        if data == "primary":
            print("HAProxy routed to primary as expected")
            raise SystemExit(0)
    except Exception as ex:
        last = str(ex)
    time.sleep(1)

raise SystemExit(f"Expected 'primary' from backend, got: {last}")
