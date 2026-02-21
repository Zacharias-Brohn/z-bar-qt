from dataclasses import dataclass
from materialyoucolor.hct.hct import Hct
from typing import Mapping


@dataclass(frozen=True)
class SeedPalette:
    primary: Hct
    secondary: Hct
    tertiary: Hct
    neutral: Hct
    neutral_variant: Hct
    error: Hct | None = None


def hex_to_hct(hex_: str) -> Hct:
    return Hct.from_int(int(f"0xFF{hex_}", 16))


CATPPUCCIN_MACCHIATO = SeedPalette(
    primary=hex_to_hct("C6A0F6"),
    secondary=hex_to_hct("7DC4E4"),
    tertiary=hex_to_hct("F5BDE6"),
    neutral=hex_to_hct("24273A"),
    neutral_variant=hex_to_hct("363A4F"),
)

PRESETS: Mapping[str, SeedPalette] = {
    "catppuccin:macchiato": CATPPUCCIN_MACCHIATO,
}
