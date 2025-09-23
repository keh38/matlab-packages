function zlimits = zaxis(zmin, zmax)
%ZAXIS - Reset limits of Z axis
%usage: zaxis(zmin, zmax)

limits = axis;
if length(limits) < 6, error('Not a 3-D axis'); end
if nargin == 0,
	zlimits = limits(5:6);
else
    limits(5:6) = [zmin zmax];
    axis(limits);
end

