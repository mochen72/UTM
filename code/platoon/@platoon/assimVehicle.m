function assimVehicle(obj, vehicle)
% function assimVehicle(obj, vehicle)
% (as opposed to addVehicle, be careful!)
%
% Assimilates a vehicle that is trying to merge into the platoon. After
% this function is called, vehicle will be added to the platoon at position
% vehicle.idx
%
% Inputs:   obj     - platoon object
%           vehicle - vehicle object to be assimilated
%
% Mo Chen, 2015-06-21

% Check if the platoon is already full
if obj.n >= obj.nmax
    printf('Platoon is already full!')
    return
end

% Check if the vehicle is a leader or free
if ~strcmp(vehicle.q, 'Free') && ~strcmp(vehicle.q, 'Leader')
    printf('Vehicle must be in free or leader mode!')
    return
end

% Check to see if the vehicle is within highway width
[~, dist] = obj.hw.highwayPos(vehicle.x(vehicle.pdim));
if dist > obj.hw.width
    printf('Vehicle is too far from the highway!')
    return
end

% Check to see if the vehicle is close to the phantom position
% (This only checks position... may want to check all states including
% velocity)
xPh = obj.phantomPosition(vehicle.idx);
dtol = 2;                                  % Tolerance
if norm(xPh - vehicle.x(vehicle.pdim)) >= dtol
    printf('Vehicle is too far from its phantom position!')
    return
end

% Add to platoon
obj.updateProps1(vehicle);
end