# V32 NPC interaction update

Based on V31 faction-list-scroll.

## Changes
- Added an interaction button beside each non-player character in the current faction roster.
- Added a seven-person NPC roster for the unaffiliated `散修` state, so free cultivators can also interact with NPCs.
- Added NPC interaction panels with conversation, gift-giving, friendly sparring, and cultivation advice.
- NPC affinity and interaction history are stored under `GameState.flags["npc_relations"]`, which is already included in save serialization; older saves remain compatible because the field is optional.
- Added relation labels: stranger, acquaintance, friendly, close friend, sworn friend, and hostile.
- Added a working return path from the NPC panel back to the faction roster.

## Validation
- Confirmed the updated project files and archive structure.
- Godot executable was not available in this environment, so an engine parse/runtime test could not be performed.
