# War Battles MULTIPLAYER

This is an addition to the single player War Battles Tutorial (https://github.com/defold/tutorial-war-battles). It's highly recommended you start there if you're knew to Defold, so you know the basics of the scene. So far this update uses a headless server control a simple multiplayer experience. Only position syncing works at the moment.

## Getting started

Download this project from github, extract the zip folder, and open the project file in Defold. You'll need to make two bundles. If you're on Windows for example, you would go to Project -> Bundle -> Windows Application and select teh "Headless" variant. Then you would make another bundle with the "Debug" variant (make sure you choose a different folder for the headless and non-headless bundles or you'll overwrite your build). Then start the headless .exe first, and then start two (or more) of the debug .exe's.

Right now only level 1 is working, so click "Level 1" on both windows, and you should get two characters spawned in different locations (after the 5 second wait for waiting for other players). You can now run around in each window, and the other client's positions and animations should sync to the other window(s).

## Basic Setup

The game has clients that send relevent events to the server (the headless defold build). The scripts recognize if they're running on headless or "normal" mode (thanks to https://github.com/defold/extension-lua-preprocessor/archive/refs/tags/1.1.3.zip). The important client (player) scripts are in `/scripts/client` and the important server scripts are in `/scripts/server`. 

All the main levels and menu are held in the `loader.collection` which dynamically loads the menu and picked level. The `client_handler.script` then lets the server know which level the player wants to load, and the `server_handler.script` will load in all waiting players and pass along any player movement updates.

## Todo

- [x] Send player movement to server via UDP packets
- [x] Sync other player movement to other clients
- [ ] Refine synced player movement (still jittery)
- [ ] Sync rockets
- [ ] Add and Sync tank movement
- [ ] Some sort of auth example/server key
- [ ] Add and Sync Scoreboard/Leaderboard

I'm very new to Defold, so pull requests and comments/help would be greatly appreciated! Hopefully we can get this to a point where it's a great jumping off point for people wanting to create multiplayer games with Defold!