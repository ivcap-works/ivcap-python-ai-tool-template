import os
import sys
import math
from pydantic import BaseModel, Field
from fastapi import FastAPI
from signal import signal, SIGTERM
from pydantic import BaseModel, ConfigDict

from ivcap_fastapi import getLogger, logging_init
from ivcap_ai_tool import start_tool_server, add_tool_api_route, ToolOptions

logging_init()
logger = getLogger("app")

# shutdown pod cracefully
signal(SIGTERM, lambda _1, _2: sys.exit(0))

title="AI tool to check for prime numbers"
description = """
AI tool to help determining if a number is a prime number.
"""

app = FastAPI(
    title=title,
    description=description,
    version=os.environ.get("VERSION", "???"),
    contact={
        "name": "Max Ott",
        "email": "max.ott@data61.csiro.au",
    },
    license_info={
        "name": "MIT",
        "url": "https://opensource.org/license/MIT",
    },
    docs_url="/api",
    root_path=os.environ.get("IVCAP_ROOT_PATH", "")
)

class Request(BaseModel):
    jschema: str = Field("urn:sd:schema.is-prime.request.1", alias="$schema")
    number: int = Field(description="the number to check if prime")

    model_config = ConfigDict(json_schema_extra={
        "example": {
            "$schema": "urn:sd:schema.is-prime.request.1",
            "number": 997
        }
    })

class Result(BaseModel):
    jschema: str = Field("urn:sd:schema.is-prime.1", alias="$schema")
    number: int = Field(description="the number to check if prime")
    is_prime: bool = Field(description="true if number is prime, false otherwise")

    model_config = ConfigDict(json_schema_extra={
        "example": {
            "$schema": "urn:sd:schema.is-prime.1",
            "number": 997,
            "is_prime": True
        }
    })

def is_prime(req: Request) -> Result:
    """
    Checks if a number is prime.
    """
    number = req.number
    is_prime = True
    if number <= 1:
        is_prime = False
    elif number <= 3:
        is_prime = True
    elif number % 2 == 0 or number % 3 == 0:
        is_prime = False
    else:
        for i in range(5, int(math.sqrt(number)) + 1, 6):
            if number % i == 0 or number % (i + 2) == 0:
                is_prime = False
                break

    return Result(number=number, is_prime=is_prime)

add_tool_api_route(app, "/", is_prime, opts=ToolOptions(tags=["Prime Checker"]))

if __name__ == "__main__":
    start_tool_server(app, is_prime)
