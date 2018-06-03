Click To Steer
==============

This is a Factorio mod that lets you steer a car or tank with the mouse, sort 
of. Because of game limitations, it's not possible to follow the mouse cursor
itself. Instead, this mod adds a "Steering Remote". Click the steering remote
on the ground and your car will turn in that direction. (This is different to
turning to face that spot, because it won't adjust the direction as you drive
past the spot you clicked.)

I've tried to be conscious of efficiency - for example, this mod needs to use
the on_tick event, but the event is only registered when it's needed and then
unregistered right after - but I'm new to Factorio modding so I may have done
something inefficient accidentally. Please feel free to submit a pull request
if you have an improvement, or a Github issue if you find any bugs or issues!