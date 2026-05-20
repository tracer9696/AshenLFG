# Ashen LFG

Ashen LFG is an in-game group finder addon for forming dungeon groups and filling missing roles.

## Installation

Place the addon in:

```text
Interface/AddOns/AshenLFG
```

The addon folder must contain `AshenLFG.toc`. Fully restart the client after installing or updating.

## What it does

- Lets players queue for available dungeons.
- Shows current queue status from the minimap button.
- Helps leaders find more members for an existing group.
- Runs role checks for tank, healer, and damage roles.
- Shows a ready check when a group is formed.
- Tracks dungeon objectives during a run.

## What it does not do

Ashen LFG does not teleport players into dungeons or automate dungeon travel.

## Features

### Minimap Button

Opens the main addon frame and shows queue status while queued.

### Solo Queue

Players can queue for up to five dungeons at a time.

### Find More

Group leaders can look for missing members while preserving the expected group role composition.

### Role Check

When filling a group, the addon prompts members to confirm their role.

### Group Formed

When a group is ready, the addon displays a ready check and shows each member's status.

### Dungeon Status

After everyone is ready, the addon can show dungeon objectives. Objective windows can be moved, collapsed, or closed.

## Notes

Addon communication uses the `LFG` chat channel. Leave that channel enabled for group-finder messages to work correctly.
