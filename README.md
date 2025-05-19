# shortcake
2D platform fighting game with floaty physics

## Collision Masking

🧱 Collision Layers and Masks
| Layer | Name             | Used By               | Purpose / Notes                                   |
| ----- | ---------------- | --------------------- | ------------------------------------------------- |
| 1     | `Player`         | Player bodies         | Characters’ physical bodies (no mutual collision) |
| 2     | `SolidPlatform`  | Main platform         | Solid ground — cannot fall through                |
| 3     | `OneWayPlatform` | Top platforms         | One-way pass-through platforms                    |
| 4     | `OverlapArea`    | Area2D inside players | Soft collision detection between players          |

✅ Collision Mask Configuration
| Node Type              | Layer(s) | Mask(s) | Description                                     |
| ---------------------- | -------- | ------- | ----------------------------------------------- |
| `Player`               | 1        | 2, 3    | Collides with ground and one-way platforms only |
| `OverlapArea` (Area2D) | 4        | 1       | Detects overlap with other players              |
| `SolidPlatform`        | 2        | —       | Standard ground — blocks movement               |
| `OneWayPlatform`       | 3        | —       | One-way platform — supports drop-through        |

🔄 Special Logic
- When player falls through:
	set_collision_mask_value(3, false) (disable one-way platform collision)

- On landing:
	set_collision_mask_value(3, true) (restore platform collision)

# TODO

Attacks:
- Front kick
- Down spike

Game state:
- Lives/stock counting
- Respawn delay + animation
- Temporary invincibility after respawn

Jumping:
- Wall jumping
