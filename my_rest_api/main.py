from __future__ import annotations

from flask import Flask
import time
from typing import TypedDict

import my_library


app = Flask("my_rest_api")


class CurrentTimeResponse(TypedDict):
    current_time: float


@app.route("/current-time")
def current_time() -> CurrentTimeResponse:
    return {"current_time": time.time()}


class GreetingResponse(TypedDict):
    message: str


@app.route("/greeting")
def greeting() -> GreetingResponse:
    return {"message": my_library.hello_world()}
