class_name Room
extends Node2D

## The TileMapLayer bridges get stamped into. Its tile (0, 0) must be the
## room's top-left corner, and it must hold the walls (so bridges can replace them).
@export var tiles: TileMapLayer
