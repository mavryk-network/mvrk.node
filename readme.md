## mvrk.node
Mavryk Node Package

*Supports node, baker and vdf mode*

### Setup

1. If not already installed, install ami:
```sh
wget -q https://raw.githubusercontent.com/mavryk-network/ami/master/install.sh -O /tmp/install.sh && sh /tmp/install.sh
```
2. Create a directory for your application. It should not be part of user home folder structure. For example, you can use `/mns/mvrk1`.
3. Create app.json or app.hjson with the configuration you prefer, based on the mode you want to use: node, baker, or vdf. Here are examples for each: 

Node:
```hjson
{
    id: node
	type: mvrk.node
    configuration: {
        "CONFIG_FILE": { 
            "p2p": {
                "bootstrap-peers": [ "boot.mavryk.network" ],
                "listen-addr": "[::]:9732" 
            }
        }
    }
	user: mvrknode
}
```
Baker:
```hjson
{
    id: baker
	type: mvrk.node
    configuration: {
        NODE_TYPE: baker
    }
	user: mvrkbaker
}
```
VDF:
```hjson
{
    id: vdf
	type: mvrk.node
    configuration: {
        NODE_TYPE: vdf
    }
	user: mvrkvdf
}
```
The above examples are for different node types. Depending on the mode, you'll need to adjust the `NODE_TYPE` fields accordingly. `CONFIG_FILE` is content of node configuration and is respected in all modes.

4. Run `ami --path=<your app path> setup`, for example, `ami --path=/mns/mvrk1 setup`. 
	- run `ami --path=<your app path> --help` to see available commands.
5. Start your node with `ami --path=<your app path> start`.
6. Check the node's info with `ami --path=<your app path> info`.

### Configuration Change

1. Stop the app: `ami --path=<your app path> stop`.
2. Change `app.json` or `app.hjson` as required.
3. Reconfigure the setup: `ami --path=<your app path> setup --configure`.
4. Restart the app: `ami --path=<your app path> start`.

### Removing the App

1. Stop the app: `ami --path=<your app path> stop`.
2. Remove the app: `ami --path=<your app path> remove --all`.

### Reset node

1. Stop the app: `ami --path=<your app path> stop`.
2. Remove the app: `ami --path=<your app path> remove --chain`.
3. (optional) bootstrap the app with `ami --path=<your app path> bootstrap <url> <block hash>`
4. Restart the app: `ami --path=<your app path> start`.

### Troubleshooting

To enable trace level printout, run `ami` with `-ll=trace`. For example: `ami --path=/mns/mvrk1 -ll=trace setup`.

Remember to adjust the path according to your app's location.


### Updating sources

Sources can be updated with:
`eli src/__mvrk/update-sources.lua https://gitlab.com/mavryk-network/mavryk-protocol/-/packages/45650499 PtAtLas PtBoreas`