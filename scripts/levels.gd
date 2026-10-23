class_name Levels
# Ported from SampleScene.unity: world positions converted to grid cells.
# Only the T and the L next to the pdam were interactable (isInteractable=1) in the original.

const ORIGIN := Vector2i(-4, -3)

const ONE := [
	"L0 S1 S1 T0* S1 S1 BS1",
	"S0 .  .  S0  .  .  .",
	"S0 .  .  HD  .  .  .",
	"S0 .  .  S0  .  .  .",
	"L1 L0* S1 L2  .  .  .",
	".  PS0 .  .  .  .  .",
]
