from pywa.types import CallbackData
from dataclasses import dataclass

@dataclass(frozen=True)
class OTPCode(CallbackData):
  code: str
