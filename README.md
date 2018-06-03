# Roblox Component System

## Overview

This is an experiment in introducing an entity component system into
Roblox. In our model:

- The "entity" is Roblox Instances.
- The "component" is Lua objects.
- The "system" is not formalized.

This library allows you to tie Lua objects to Instances in an intuitive
fashion. Instance tagging is used to figure out which instances should
have which objects.

One of the key concepts with this system is that components can get
handles to other components and call methods on them. This allows for a
great deal of abstraction and separation of concerns without having to
resort to awkward constructs like BindableEvents.

## Installation

The source for the library is in the `lib` directory. Everything you
need is there. The library has no dependencies. You can add it to your
project using Rojo like so:

```js
"EntitySystem": {
	"path": "EntitySystem/lib/", // Assumes you're using it as a submodule, but anything works.
	"target": "ReplicatedStorage.EntitySystem" // Wherever you like.
},
```

## How to use

We'll start by creating a component type. We'll use a death brick for
this example.

```lua
local EntitySystem = require(script.Parent.EntitySystem)

local DeathBrick = EntitySystem.Component:extend("DeathBrick")

function DeathBrick:added()
	self.maid.touchConn = self.instance.Touched:Connect(function(part)
		part:BreakJoints()
	end)
end

return DeathBrick
```

On its own, this snippet won't do anything. Create a folder for all your
components (you'll see why you want to do this in a moment), and add
this as a `ModuleScript` (this part's important as well).

In order to make the components work, we have to create a `Core` and
register the components with it. The components we define with snippets
such as the one above are simple data holders, they don't do anything on
their own.

You'll want to create a `Core` on both the client and server, most
likely.

```lua
local EntitySystem = require(script.Parent.EntitySystem)

-- The array we pass here is a list of arguments. This is where we'll
-- pass plugins and other data.
local core = EntitySystem.Core.new({})

-- The folder from earlier.
local componentsFolder = script.Parent.Components
-- We put them all together so that we don't have to manually list them here.
for _,module in pairs(componentsFolder:GetChildren()) do
	-- registerComponent() takes a component description, which is what we created earlier in that snippet.
	core:registerComponent(require(module))
end
```

Why don't we define components in standalone scripts or localscripts? The reason for this is that components can actually look up references to each other using their descriptor. For example:

```lua
local EntitySystem = require(script.Parent.EntitySystem)
local DeathBrick = require(script.Parent.DeathBrick)

local MyComponent = EntitySystem.Component:extend("MyComponent")

function MyComponent:added()
	-- If MyComponent and DeathBrick are both attached to the same object, this will return a reference to it.
	local deathBrick = self:getComponent(DeathBrick)
	-- We didn't actually define any methods or properties on DeathBrick so let's make some up.
	deathBrick.someValue = 4
	deathBrick:callSomeMethod()
end

return MyComponent
```

## API Reference

### EntitySystem.Core

#### `Core Core.new(args: table)`

Constructs a new core using the given parameters. `args` is formattted like so:

```lua
{
	plugins = {
		-- Array of plugins, e.g. EntitySystem.SteppedPlugin.
	},
	-- NetworkPlugin arguments
	isServer: bool,
	remoteEvent: RemoteEvent,
}
```

#### `void Core:registerComponent(component: EntitySystem.Component)`

Registers a description of a component and begins instantiating it for all of the instances that need it. It will throw if you try to register two components with the same `className`.

#### `Object Core:getComponentFromInstance(component: EntitySystem.Component, instance: Instance)`

Returns the Lua object associated with the given component/instance pair.

#### `Object Core:addComponentToInstance(component: EntitySystem.Component, instance: Instance)`

The same as above, but it will create the object if it doesn't already exist.

### EntitySystem.Component

#### `EntitySystem.Component Component:extend(className: string, defaultProps: optional dictionary)`

Creates a new component description. The `className` is used to know which CollectionService tag this component corresponds to.

#### `Instance Component.instance`

A reference to the instance this component is attached to.

#### `Maid Component.maid`

A Maid pattern is embedded into every component. The basic idea is that you can hand things to the maid and it will automatically clean them up.

Types of objects it can clean up:

- `Instance`: Calls `Destroy()`.
- `RBXScriptConnection`: Calls `Disconnect()`.
- `table`: Tries to call `destroy()`.
- `function`: Calls it.

To provide things to the maid, you can either set it as a key, or you can use the `:give()` method.

Setting the same key twice will clean up the previous thing that was in the slot.

Anything may be used as a key as long as it wouldn't shadow a method on the Maid class itself.

#### `string Component.className`

The class name of the component, as passed to `extend()`.

#### `virtual void Component:added()`

Called when the component is instantiated. Note that components can be in a state where they've been created but have not have `added()` called yet, when calling `getComponent` from `added()` (because of ordering).

#### `virtual void Component:removed()`

Called when the component is removed from the instance.

#### `Component getComponent(componentDesc: EntitySystem.Component)`

Locate a component attached to the same instance.

#### `Component getComponentInParent(componentDesc: EntitySystem.Component)`

Locate a component attached to the instance's parent.

#### `array<Component> getComponentsInDescendants(componentDesc: EntitySystem.Component)`

Locate all of the components of that type attached to any of the instance's descendants.

## Plugin

This repository includes a plugin for manipulating components. It shows
a properties panel where the properties can be edited.

## Library Design

There's four classes that are relevant to the library's design.

- `Core`: This is where all of the real state manipulation happens.
- `ComponentDesc`: This is how we define/describe components at a high level. These are created using `EntitySystem.Component:extend()`
- `Component`: This is the instantiation of a component attached to an instance.
- `ComponentManager`: This handles CollectionService tags and creates/manages `Component`s. They are created when you call `registerComponent`.

The reason why we don't simply have `ComponentDesc` alone and have it do all the IO is for a couple of key reasons:

- It keeps the code cleaner and easier to understand.
- It makes it so that we don't have to do hacks to make Play Solo work.

## Plugins

To enable these, pass them into the `plugins` array argument to `Core.new()`, like so:

```lua
local core = EntitySystem.Core.new({
	plugins = {
		EntitySystem.NetworkPlugin,
		EntitySystem.SteppedPlugin,
	}
})
```

### NetworkPlugin

This plugin implements client-server communication between remote analogues of the same component.

In order for it to work, you must pass a RemoteEvent and inform it whether it's acting as a client or a server. We can't just use `RunService:IsServer()` because of play solo.

#### API

All of the functions in the API communicate with the remote end of the network connection, with a component of the same name attached to the same object. Note, only the `className` has to be the same. They do not have to be the same component.

##### `void Component:sendClient(player: Player, ...)`

Server only. Sends a message to a specific player's client.

##### `void Component:sendBroadcast(...)`

Server only. Sends a message to all clients.

##### `virtual void Component:onServerEvent(player: Player, ...)`

Server only. Invoked when receiving a message corresponding to a `sendServer()`.

##### `void Component:sendServer(...)`

Client only. Sends a message to the server.

##### `virtual void Component:onClientEvent(...)`

Client only. Invoked when receiving a message corresponding to a `sendClient()`/`sendBroadcast()`.

### SteppedPlugin

This plugin allows you to easily run code during RenderStep or Heartbeat without having to manually manage RunService connections.

#### API

##### `virtual void Component:heartbeat(dt: number)`

Invoked every Heartbeat if it is defined.

##### `virtual void Component:stepped(dt: number)`

Invoked every RenderStep if it is defined.
