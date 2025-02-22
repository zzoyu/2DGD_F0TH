Collision Reaction/Correction
------------------------------

When you are sure, via any algorithm, that a collision has occurred, you now have to decide how to react to such collision. You may want to destroy the player or the target, or you may want to correct the behaviour, thus avoiding items getting inside walls.

### HitBoxes vs HurtBoxes

First of all, we need to explain the difference between a "HurtBox" and a "HitBox".

Such difference can be more or less important, depending on the game that is coded, and sometimes the two concepts can be confused.

A **HitBox** is a shape (usually a rectangle, see [Collision Between Two Axis-Aligned Rectangles (AABB)]) that is used to identify where a certain entity can *hit* another entity. For the player a "hitbox" could encase their sword while attacking.

A **HurtBox** is instead a shape that is used to identify where a certain entity can *get hurt* by another entity. For the player a "hurtbox" could be their body.

![Example of a hitbox (red) and a hurtbox (blue)](./images/collision_detection/hithurt.png){width=40%}

### Collision Reaction Methods

It has happened: a collision occurred and now the two objects are overlapping.

How do we react to this event in a convincing (not necessarily "realistic") and efficient manner? There are a lot of methods to react to collisions and below we will show some of the most used, along with some interesting ones.

We will use the following image as reference for each collision reaction:

![Images used as a reference for collision reaction](./images/collision_detection/reaction_reference.svg){width=40%}

We will study each case separately, at the time the collision is detected (so the two objects are already interpenetrating), and each case will be a piece of this reference image.

#### A naive approach

This is the simplest method we can think of: as soon as the object gets inside of a wall, you push it back to one of the edges of the block, while keeping an eye on the direction it's moving.

##### How it works

This works when you treat the `x` and `y` axis separately, updating one, checking the collisions that come up from it, update the other axis and check for new collisions.

```{src='collisiondetection/naive_reaction' caption='Code for the naive collision reaction'}
```

##### Analysis

Let's see how this method reacts in each situation.

When we are trying to slam against the wall, this method works as follows:

![How the naive method reacts to collisions against a wall](./images/collision_detection/naive_reaction_1.svg){width=80%}

1. We separate our position vector in its $x$ and $y$ components.
2. We check for collisions, and if so, we react on the $x$ axis in a direction opposite to the $x$ component of the velocity.
3. We check for collisions again, if there are any, we react on the $y$ axis, in a direction opposite to the $y$ component of the velocity.

##### Problems

Problems arise when we try to use the same method to react to a collision on a horizontal plane. In that case reacting on the x axis first will bring some unexpected surprises.

![How the naive method reacts to collisions against the ground](./images/collision_detection/naive_reaction_2.svg){width=80%}

We need to find a way to decide which axis we should correct first.

#### Shallow-axis based reaction method

This method works in a similar fashion to the naive method, but prioritizes reactions on the axis that shows the shallowest overlap.

This requires measuring how much the objects overlap on each axis, which can be a little more involved, but not really expensive.

![Example of shallow-axis based reaction on a horizontal plane](./images/collision_detection/shallow_axis_1.svg){width=90%}

In the previous picture, we can see how the algorithm chooses to solve the collision on the $y$ axis first and only on the x axis after; but since solving the $y$ axis solves the collision, no reaction is performed on the $x$ axis.

![Example of shallow-axis based reaction on a vertical plane](./images/collision_detection/shallow_axis_2.svg){width=60%}

In this new situation, the algorithm chooses to solve the collision on the $x$ axis first; but since solving the $x$ axis solves the collision, no reaction is performed on the $y$ axis.

```{src='collisiondetection/shallow_axis_resolution' caption='Possible implementation for a shallow axis collision reaction'}
```

#### Interleaving single-axis movement and collision detection

This is a method quite simple to understand: you split the movement in its $x$ and $y$ components, move on the first component, check and react, move on the other component, check and react again.

##### How it works

This works by treating the $x$ and $y$ axes separately, updating one, checking the collisions that come up from it, update the other axis and check for new collisions.

```{src='collisiondetection/interleaved_movement_collision' caption='Code for interleaving movement and collision reaction'}
```

##### Analysis

Let's see how this method reacts in each situation.

When we are trying to fall on the ground, this method works as follows:

![How the the interleaving method reacts to collisions on a horizontal plane](./images/collision_detection/interleaving_reference.svg){width=80%}

1. We divide the movement vector in its $x$ and $y$ components.
2. We move along the $x$ axis and check for collisions, in this case there are none.
3. We move along the $y$ axis, after checking for collisions we find that we are colliding on the ground.
4. We react to the collision by moving the sprite on top of the ground.

#### The "Snapshot" Method

This method is a bit more involved, but allows for a finer control over how you go through or collide with certain obstacles.

The secret to this method is taking a snapshot of the object's position before its update phase and do a series of comparisons with the position after the update.

```{src='collisiondetection/snapshot_reaction' caption='Example of the "snapshot" collision reaction method'}
```

This method solves the problem given by platforms that can be crossed one-way.

{{placeholder}}

<!-- TODO: Snapshot before and after updating, react accordingly, allows for more advanced stuff -->

### When two moving items collide

So far we've seen methods that involve a moving object colliding with a stationary one, but what if we wanted to react to a collision between two moving objects?

Some more math will be needed but it's not extremely difficult to pull off.

First of all, we need to find the "collision vector" (we'll call that $u_{coll}$), which is simply a vector that is calculated using the difference of the objects' positions. We'll need just the direction, so we will normalize it too (so it will become $\hat{u}_{coll}$).

Let's imagine two objects, with the following positions: $A(x_1, y_1)$ and $B(x_2, y_2)$

$$
u_{coll} = (x_2 - x_1, y_2 - y_1)
$$
$$
\hat{u}_{coll} = \frac{u}{||u||}
$$

Now we need to know how the objects are moving in relation to each other, this will allow us to see if and how we need to react. Let's calculate the "relative velocity" of the objects.

$$
v_{rel} = (v_{x2} - v_{x1}, v_{y2} - v_{y1})
$$

Now we need to see how the relative velocity affects the collision, which means we need to project such velocity onto the collision vector. Sounds like a job for the dot product.

$$
s = \hat{u}_{coll} \cdot v_{rel}
$$
$s$ can be called "the speed of collision" (it's a scalar number, not a vector) and tells us what we need to know: if $s < 0$ then the objects are moving away from each other already and we don't need to do anything. If $s > 0$ then the objects are moving towards each other

To react to objects that are moving towards each other, we just need to change their velocity by a factor of $s \cdot \hat{u}_{coll}$.

{{placeholder}}

<!-- TODO: Code to demonstrate how to deal with collisions between moving objects -->
