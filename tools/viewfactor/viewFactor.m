function [F_AB, varargout] = viewFactor(TRI_A, TRI_B, varargin)
%viewFactor  Radiation view factors between two arbitrary 3D triangles.
% 
%   viewFactor(TRI_A, TRI_B) analytically computes the view factor from
%   TRI_A to TRI_B. Input arguments are in the form of 2x3 or 3x3 arrays,  
%   where each row corresponds to a vertex of the triangle, the the columns 
%   refer to the X,Y,Z coordinates of the vertices. If Z coordinates are
%   omitted, they are assumed to be zero.
% 
%   viewFactor(TRI_A, TRI_B) also analytically computes view factors
%   between aribtrary polygons, so long as these conditions are met:
% 
%    1) polygons are planar (all vertices lie in the same plane)
%    2) polygons are simple (no self-intersecting polygons)
%    3) polygons are convex (in theory, concave polygons should work, but
%       this remains untested)
% 
%   In the above case, inputs TRI_A and TRI_B have dimensions 3xN and 3xM
%   respectively, where N and M are the number of vertices of each polygon.
%   Additionally, the vertices must be provided in order, either clockwise 
%   or counterclockwise around the polygon, to ensure the polygons are
%   simple. 
% 
%   viewFactor(... OPT) specifies addtional functionality when OPT is
%   a character vector. When OPT = 'PLOT', the polygons are plotted in the
%   XYZ plane along with their surface normal vectors. When OPT = 'MC', a
%   Monte-Carlo ray tracing algorithm is substituted for the analytical
%   caluclation. Both of these options may be included in one function
%   call.
% 
%   When invoked with left-hand arguments,
% 
%       [F_AB, F_BA] = viewFactor(TRI_A, TRI_B)
%   returns both the view factor from TRI_A to TRI_B, and the view factor
%   from TRI_B to TRI_A, respectively.
% 
%       [F_AB, F_BA, data] = viewFactor(TRI_A, TRI_B)
%   returns both view factors and a data structure containing other
%   relevant information about the computation, such as the polygon areas 
%   and processing time.
%
%   No additional MATLAB toolboxes are needed to use this function.
%

%   Author: Jacob Kerkhoff
%   University of Wisconsin-Madison, Solar Energy Laboratory
% 
%   Version 1.5, last updated 10/07/2020
%   
%   Analytical solution derivation:
%   Narayanaswamy, Arvind. "An analytic expression for radiation view 
%   factor between two arbitrarily oriented planar polygons." International
%   Journal of Heat and Mass Transfer 91 (2015): 841-847.
%

% INITIALIZATION
tStart = cputime;
global almostZero
almostZero = 1e-7;

plotPolygons = false;
monteCarlo = false;

if nargin > 2
    for i=3:nargin
        if (ischar(varargin{i-2})) & (length(varargin{i-2}) == 4) ...
                & ((varargin{i-2} == 'plot') ...
                | (varargin{i-2} == 'PLOT') ...
                | (varargin{i-2} == 'Plot'))
            
            plotPolygons = true;
%             break;
        end
        
        if (ischar(varargin{i-2})) & (length(varargin{i-2}) == 2) ...
                & ((varargin{i-2} == 'mc') ...
                | (varargin{i-2} == 'MC') ...
                | (varargin{i-2} == 'Mc'))
            
            monteCarlo = true;
%             break;
        end
        
        if (ischar(varargin{i-2})) & (length(varargin{i-2}) == 10) ...
                & ((varargin{i-2} == 'monteCarlo') ...
                | (varargin{i-2} == 'MONTECARLO') ...
                | (varargin{i-2} == 'montecarlo') ...
                | (varargin{i-2} == 'MonteCarlo'))
            
            monteCarlo = true;
%             break;
        end
    end
end





% CONFIRM CORRECT INPUTS AND FIND AREA: polygon A
% also calculates unit normal vector to polygon
if nargout > 3
    error('Too many output arguments.');
end
dim_A = size(TRI_A);
N = dim_A(1);  % number of vertices in polygon A
% test for cartesian coordinates
if dim_A(2) == 2
    TRI_A = [TRI_A, zeros(N,1)];
elseif dim_A(2) ~= 3
    error('Input 1: Matrix dimensions incorrect.');
end
% test for coplanar vertices
if N == 3    % test satisfied automatically
    n_A = cross((TRI_A(2,:) - TRI_A(1,:)), (TRI_A(3,:) - TRI_A(1,:)));
    nHat_A = n_A/norm(n_A);
    area_A = norm(n_A)/2;   % area for triangles
elseif N < 3 % not a polygon
    error('Input 1: Not enough coordinates to specify a polygon.');
else
    n_A = cross((TRI_A(2,:) - TRI_A(1,:)), (TRI_A(3,:) - TRI_A(1,:)));
    nHat_A = n_A/norm(n_A);
    for i=4:N
        % the triple product of any combination of vertices must be zero
        %  for the polygon to be planar
        volume = abs(dot(n_A, (TRI_A(i,:) - TRI_A(1,:))));
        if volume > almostZero
            error('Input 1: Polygon vertices are not coplanar.');
        end
    end
    if N == 4   % area for arbitrary quadrilateral
        area_A = norm(cross((TRI_A(3,:) - TRI_A(1,:)), (TRI_A(4,:) - TRI_A(2,:))))/2;
    else        % area for higher order polygons
        % http://geomalgorithms.com/a01-_area.html
        TRI_A_looped = [TRI_A ; TRI_A(1,:)];
        toSum = [0 0 0];
        for i=1:N
            toSum = toSum + cross(TRI_A_looped(i,:), TRI_A_looped(i+1,:));
        end
        area_A = dot(nHat_A, toSum)/2;
    end
end





% CONFIRM CORRECT INPUTS AND FIND AREA: polygon B
% also calculates unit normal vector to polygon
dim_B = size(TRI_B);
M = dim_B(1);  % number of vertices in polygon B
% test for cartesian coordinates
if dim_B(2) == 2
    TRI_B = [TRI_B, zeros(M,1)];
elseif dim_B(2) ~= 3
    error('Input 2: Matrix dimensions incorrect.');
end
% test for coplanar vertices
if M == 3    % test satisfied automatically
    n_B = cross((TRI_B(2,:) - TRI_B(1,:)), (TRI_B(3,:) - TRI_B(1,:)));
    nHat_B = n_B/norm(n_B);
    area_B = norm(n_B)/2;   % area for triangles
elseif M < 3 % not a polygon
    error('Input 2: Not enough coordinates to specify a polygon.');
else
    n_B = cross((TRI_B(2,:) - TRI_B(1,:)), (TRI_B(3,:) - TRI_B(1,:)));
    nHat_B = n_B/norm(n_B);
    for i=4:M
        % the triple product of any combination of vertices must be zero
        %  for the polygon to be planar
        volume = abs(dot(n_B, (TRI_B(i,:) - TRI_B(1,:))));
        if volume > almostZero
            error('Input 2: Polygon vertices are not coplanar.');
        end
    end
    if M == 4   % area for arbitrary quadrilateral
        area_B = norm(cross((TRI_B(3,:) - TRI_B(1,:)), (TRI_B(4,:) - TRI_B(2,:))))/2;
    else        % area for higher order polygons
        % http://geomalgorithms.com/a01-_area.html
        TRI_B_looped = [TRI_B ; TRI_B(1,:)];
        toSum = [0 0 0];
        for i=1:M
            toSum = toSum + cross(TRI_B_looped(i,:), TRI_B_looped(i+1,:));
        end
        area_B = dot(nHat_B, toSum)/2;
    end
end




if ~monteCarlo
    % VIEW FACTOR ANALYICAL CALCULATION
    
    sumTerms = zeros(N,M);  % terms to sum to yield conductance
    skewPairs = zeros(N,M); % tracks which terms come from parallel edges (for debugging)
    for p = 1:M      % loop through vertices of polygon B
        for i = 1:N  % loop through vertices of polygon A
            r_i = TRI_A(i,:);
            r_p = TRI_B(p,:);

            % loop pairings of vertices to cycle through edges
            if i < N
                r_j = TRI_A(i+1,:);
            else % loop
                r_j = TRI_A(1,:);
            end
            if p < M
                r_q = TRI_B(p+1,:);
            else % loop
                r_q = TRI_B(1,:);
            end

            % check for coincident vertices - nudge polygon B vertices if found
            if (r_i == r_p) | (r_j == r_p)
                r_p = r_p + almostZero;
            elseif (r_i == r_q) | (r_j == r_q)
                r_q = r_q + almostZero;
            end

            % determine parameterized coordinates for each edge, and minimum
            %  distance between edge rays (edges extended infinitely into space)
            [dMin, sOrigin, sHat, lHat, lOrigin, skew] = edgePairParameters(r_i, r_j, r_p, r_q);

            if skew  % if these edges are NOT parallel...
                % locate each vertex in the parameterized coordinate system
                s_i = dot((r_i - sOrigin), sHat);
                s_j = dot((r_j - sOrigin), sHat);
                l_p = dot((r_p - lOrigin), lHat);
                l_q = dot((r_q - lOrigin), lHat);

                skewPairs(i,p) = 1;
                cosAlpha = dot(sHat, lHat);
                alpha = acos(cosAlpha);
                sinAlpha = sin(alpha);

                % Eq.(22a) from paper - calculate final terms that yield the 
                %  view factor when summed and divided by (4*pi*area)
                sumTerms(i,p) = cosAlpha*(f(s_j, l_q, alpha, cosAlpha, sinAlpha, dMin) ...
                    - f(s_i, l_q, alpha, cosAlpha, sinAlpha, dMin) ...
                    - f(s_j, l_p, alpha, cosAlpha, sinAlpha, dMin) ...
                    + f(s_i, l_p, alpha, cosAlpha, sinAlpha, dMin));
            else     % alternate expression for when alpha approaches zero  
                lHat = sHat; % this is important for the parallel case
                % locate each vertex in the parameterized coordinate system
                s_i = dot((r_i - sOrigin), sHat);
                s_j = dot((r_j - sOrigin), sHat);
                l_p = dot((r_p - lOrigin), lHat);
                l_q = dot((r_q - lOrigin), lHat);

                skewPairs(i,p) = 0;
                sumTerms(i,p) = dot(sHat, lHat)*(fParallel(s_j, l_q, dMin) ...
                    - fParallel(s_i, l_q, dMin) - fParallel(s_j, l_p, dMin) ...
                    + fParallel(s_i, l_p, dMin));
            end
        end
    end

    % "radiation conductance" : radUA = area_A*F_AB = area_B*F_BA
    radUA = abs(sum(sumTerms, 'all'))/(4*pi);
    

    
    
    
    
    
else
    % VIEW FACTOR MONTE-CARLO CALCULATION
    
    nRays = 1000000; % number of rays to trace from polygon A to polygon B
    trials = 10;    % average results over this many trials
    F = zeros(1,trials);
    
    cent_A = sum(TRI_A)./N;  % polygon centerpoint
    cent_B = sum(TRI_B)./M;
    xHat_A = (TRI_A(1,:) - cent_A)/norm(TRI_A(1,:) - cent_A);
    xHat_B = (TRI_B(1,:) - cent_B)/norm(TRI_B(1,:) - cent_B);
    yHat_A = cross(nHat_A, xHat_A);  % define coordinate axes for 
    %                                  representing each polygon in a 2D 
    %                                  plane

    [TRI_A_XY, TRI_A_RP] = to2D(TRI_A, cent_A, nHat_A, xHat_A);
    [TRI_B_XY, ~] = to2D(TRI_B, cent_B, nHat_B, xHat_B);
        % redefine polygons in individual planar coordinate systems

    for k = 1:trials

        maxRadius = max(TRI_A_RP(:,1));
        maxArea = pi*maxRadius^2;
        nPoss = round(nRays*(maxArea/area_A)*2);
        genesis_XY = zeros(nRays,2);
        radPoss = maxRadius*sqrt(rand(nPoss,1));
        phiPoss = 2*pi*rand(nPoss,1);
        % create a circle of uniformly distributed random points that
        % circumscribes the polygon - genesis points of rays will be chosen
        % from these points that are within the polygon boundary

        genCount = 0;
        i = 1;
        while genCount < nRays % loop until ray goal is met
            X = radPoss(i)*cos(phiPoss(i));
            Y = radPoss(i)*sin(phiPoss(i));
            if inpolygon(X, Y, TRI_A_XY(:,1), TRI_A_XY(:,2))
                % if the point is within the polygon, add to the genesis array
                genCount = genCount + 1;
                genesis_XY(genCount,:) = [X, Y];
            end
            i = i + 1;
        end
        
        % ^^^ there is probably a much more efficient way to do this

        % figure;  % this plots the chosen genesis to show that they are
        % %          evenly distributed in the polygon
        % fill(TRI_A_XY(:,1), TRI_A_XY(:,2), 'w'); hold on;
        % plot(genesis(:,1), genesis(:,2), '.');
        % axis equal;

        genesis = to3D(genesis_XY, cent_A, nHat_A, xHat_A);
         % map points back to 3D space
        death = zeros(nRays,3);    % initialize death arrays (pun intended)
        death_XY = zeros(nRays,2); % these store the intersection of each 
        %                            ray with the plane of polygon B

        thetaDir = asin(sqrt(rand(nRays,1)));
        phiDir = 2*pi*rand(nRays,1); % shooting angles in spherical CS
        hits = 0;

        for j = 1:nRays
            ray = xHat_A*sin(thetaDir(j))*cos(phiDir(j)) ...
                + yHat_A*sin(thetaDir(j))*sin(phiDir(j)) ...
                + nHat_A*cos(thetaDir(j));
            ray = ray/norm(ray);
            
            % find intersection of each ray with the plane of polygon B
            den = dot(ray, nHat_B);
            if abs(den) > almostZero
                AtoB = dot((cent_B - genesis(j,:)), nHat_B)/den;
                death(j,:) = genesis(j,:) + AtoB*ray;
                [death_XY(j,:), ~] = to2D(death(j,:), cent_B, nHat_B, xHat_B);

                if inpolygon(death_XY(j,1), death_XY(j,2), TRI_B_XY(:,1), TRI_B_XY(:,2))
                    % if the intersection is within polygon B, count as a hit
                    hits = hits + 1;
                end
            end
        end

        F(k) = hits/nRays; % percentage of diffuse light from A that reaches B

    end
    
    % "radiation conductance" : radUA = area_A*F_AB = area_B*F_BA
    radUA = area_A*mean(F);
end
    




% FINAL CALCULATION
if isnan(radUA)
    error('Unknown error occured.');
else
    F_AB = radUA/area_A;
    F_BA = radUA/area_B;
end

tEnd = cputime;




% OUTPUT ASSIGNMENT
if nargout == 2
    varargout{1} = F_BA;
end
if nargout > 3  
    error('Too many output arguments.');
elseif nargout == 3 % output computation data if specified
    varargout{1} = F_BA;
    data.F = [F_AB ; F_BA];
    data.area = [area_A ; area_B];
    data.nSides = [N ; M];
    
    if ~monteCarlo
        data.sumTerms = sumTerms/(4*pi);
        data.pairs = skewPairs;
        data.computeTime = tEnd - tStart;
    else
        data.allTrials = F;
        data.SD = std(F);
        data.computeTime = tEnd - tStart;
    end
    
    varargout{2} = data;
end





% OPTIONAL PLOTTING
if plotPolygons
    font = 14;
    blue = [127 172 235]/255;
    green = [97 171 138]/255;
        
    centA = sum(TRI_A)./N;
    centB = sum(TRI_B)./M;
    % this just makes the normals face each other for plotting purposes
    if dot(nHat_A, (centB - centA)) < 0
        nHat_A = -nHat_A;
    end
    if dot(nHat_B, (centA - centB)) < 0
        nHat_B = -nHat_B;
    end
    scale = norm(centA - centB)/3;
    labelA = centA + nHat_A*scale;
    labelB = centB + nHat_B*scale;
    
    f1 = figure(1);
    fill3(TRI_A(:,1), TRI_A(:,2), TRI_A(:,3), blue, 'linewidth', 3);
    hold on; axis equal; grid on;
    fill3(TRI_B(:,1), TRI_B(:,2), TRI_B(:,3), green, 'linewidth', 3);
    quiver3(centA(1), centA(2), centA(3), nHat_A(1), nHat_A(2), nHat_A(3), scale, 'k', 'linewidth', 1.5, 'MaxHeadSize', 0.8);
    quiver3(centB(1), centB(2), centB(3), nHat_B(1), nHat_B(2), nHat_B(3), scale, 'k', 'linewidth', 1.5, 'MaxHeadSize', 0.8);
    xlabel('X'); ylabel('Y'); zlabel('Z');
    text(labelA(1), labelA(2), labelA(3), '  A', 'fontsize', font+5);
    text(labelB(1), labelB(2), labelB(3), '  B', 'fontsize', font+5);
    title(sprintf('View factor from polygon A to polygon B: %1.7f\nView factor from polygon B to polygon A: %1.7f', F_AB, F_BA));
    set(gca,'FontSize',font);
    set(f1,'Position',[100 100 700 600]);
end

end





%% SUB-FUNCTIONS
function F = f(s, l, alpha, cosAlpha, sinAlpha, d)
% Eq.(22b) from paper
s2 = s^2;
l2 = l^2;
d2 = d^2;
sinAlpha2 = sinAlpha^2;

global almostZero

wsqrt = sqrt(s2 + d2/sinAlpha2);
psqrt = sqrt(l2 + d2/sinAlpha2);
if abs(s + wsqrt) > 0
wdim = s + wsqrt;
else 
wdim = almostZero;
end    
if abs(l + psqrt) > 0
pdim = l + psqrt;
else 
pdim = almostZero;
end

F = (0.5*cosAlpha*(s2 + l2) - s*l)*log(s2 + l2 - 2*s*l*cosAlpha + d2) ...
  + s*sinAlpha*wsqrt*atan2(sqrt(s2*sinAlpha2 + d2), (l - s*cosAlpha)) ...
  + l*sinAlpha*psqrt*atan2(sqrt(l2*sinAlpha2 + d2), (s - l*cosAlpha)) + s*l ...
  + 0.5*(d2/sinAlpha)*(imagLi_2((wdim/pdim), alpha) + imagLi_2((pdim/wdim), alpha) - 2*imagLi_2((wdim - 2*s)/pdim, (pi - alpha)));

end

function F = fParallel(s, l, d)
% Eq.(23) from paper
global almostZero
if d == 0
    d = almostZero;
end

sMinusl = s - l;
sMinusl2 = sMinusl^2;
s2 = s^2;
l2 = l^2;
d2 = d^2;

F = 0.5*(sMinusl2 - d2)*log(sMinusl2 + d2) ...
  - 2*sMinusl*d*acos(sMinusl/sqrt(s2 + l2 - 2*s*l + d2)) + s*l;
end

function [D, sOrigin, sHat, lHat, lOrigin, skew] = edgePairParameters(Po, Pf, Qo, Qf)
% http://geomalgorithms.com/a07-_distance.html
% find shortest distance D between line Po+s*u and Qo+t*v for initial 
%  points Po and Qo, parameters s and t, and vectors u and v
global almostZero

u = Pf - Po;
v = Qf - Qo;
w = Po - Qo;

Plength = norm(u);
Qlength = norm(v);
u = u/Plength;  % make these unit vectors
v = v/Qlength;

a = 1; % dot(u, u)
b = dot(u, v);
c = 1; % dot(v, v)
d = dot(u, w);
e = dot(v, w);

den = a*c - b^2;

% calculate shortest distance between edge rays
if den > almostZero
    skew = true;
    s = (b*e - c*d)/den;
    l = (a*e - b*d)/den;
    D = norm(w + s*u - l*v);
else % origin is arbitrary if lines are parallel
    skew = false;
%     s = 1.5*Plength;
%     l = 1.5*Qlength;
    s = 0;
    l = e/c;
    D = norm(w - (e/c)*v);
end

% see Fig 5 in this paper:
%   Narayanaswamy, Arvind. "An analytic expression for radiation view 
%   factor between two arbitrarily oriented planar polygons." International
%   Journal of Heat and Mass Transfer 91 (2015): 841-847.
% for description of why these values are calculated in this way.

% parameter origin is location on edge ray where distance between edges has
%  its smallest value 
sOrigin = Po + u*s;
lOrigin = Qo + v*l;

s_toEnd = norm(Pf - sOrigin);
l_toEnd = norm(Qf - lOrigin);

% unit vectors point from parameter origin to furthest of the two vertices
if abs(s) < s_toEnd
    sHat = (Pf - sOrigin)/norm(Pf - sOrigin);
else
    sHat = (Po - sOrigin)/norm(Po - sOrigin);
end
if abs(l) < l_toEnd
    lHat = (Qf - lOrigin)/norm(Qf - lOrigin);
else
    lHat = (Qo - lOrigin)/norm(Qo - lOrigin);
end


end

% function imaginaryPart = imagLi_2_sym(mag, angle)
% % this function produces the same result as imagLi_2() but is vastly more
% %  computationally expensive, since it engages MATLAB's symbolic engine
%     imaginaryPart = imag(dilog(1-mag*exp(1i*angle)));
% end

function imaginaryPart = imagLi_2(mag, angle)
% Eq.(24) from paper

    global almostZero
    if mag > almostZero
        omega = atan2(mag*sin(angle), (1 - mag*cos(angle)));
        imaginaryPart = 0.5*Cl(2*angle) + 0.5*Cl(2*omega) - 0.5*Cl(2*omega + 2*angle) + log(mag)*omega;
    else
        imaginaryPart = mag*sin(angle);
    end
end

function ClausenIntegral = Cl(theta)
% Eq.(26) from paper

    global almostZero
    
    theta = mod(theta, 2*pi);
    chebArg = theta/pi - 1;
    b = [1.865555351433979e-1, 6.269948963579612e-2, 3.139559104552675e-4, ...
         3.916780537368088e-6, 6.499672439854756e-8, 1.238143696612060e-9, ...
         5.586505893753557e-13];
    % Chebyshev polynomials of degrees 2*n+1 (n=1:6) found using the sym command:
    % >> chebyshevT((2*(0:6)+1), sym(chebArg));
    T = [chebArg, 4*chebArg^3 - 3*chebArg, ...
         16*chebArg^5 - 20*chebArg^3 + 5*chebArg, ...
         64*chebArg^7 - 112*chebArg^5 + 56*chebArg^3 - 7*chebArg, ...
         256*chebArg^9 - 576*chebArg^7 + 432*chebArg^5 - 120*chebArg^3 + 9*chebArg, ...
         1024*chebArg^11 - 2816*chebArg^9 + 2816*chebArg^7 - 1232*chebArg^5 + 220*chebArg^3 - 11*chebArg, ...
         4096*chebArg^13 - 13312*chebArg^11 + 16640*chebArg^9 - 9984*chebArg^7 + 2912*chebArg^5 - 364*chebArg^3 + 13*chebArg];
     
     ClausenIntegral = (theta - pi)*(2 + log((pi^2)/2)) + (2*pi - theta)*log((2*pi - theta)*(1 - almostZero) + almostZero) ...
         - theta*log(theta*(1 - almostZero) + almostZero) + sum(b.*T);

end

% FOR MONTE CARLO
function [POLY_XY, POLY_RT] = to2D(POLY, origin, normal, xAxis)
    dim = size(POLY);
    N = dim(1);  % number of points to process
    nHat = normal/norm(normal);
    xHat = xAxis/norm(xAxis);
    yHat = cross(nHat, xHat);
    POLY_XY = zeros(N,2);
    POLY_RT = zeros(N,2);
    for i = 1:N
        point = POLY(i,:);
        arm = point - origin;
        radius = norm(arm);
        xComp = dot(arm, xHat);
        yComp = dot(arm, yHat);
        theta = atan2(yComp, xComp);
        if theta < 0
            theta = theta + 2*pi;
        end
        POLY_XY(i,:) = [xComp, yComp];
        POLY_RT(i,:) = [radius, theta];
    end
end

function POLY = to3D(POLY_XY, origin, normal, xAxis)
    dim = size(POLY_XY);
    N = dim(1);  % number of points to process
    nHat = normal/norm(normal);
    xHat = xAxis/norm(xAxis);
    yHat = cross(nHat, xHat);
    POLY = zeros(N,3);
    for i = 1:N
        POLY(i,:) = origin + xHat*POLY_XY(i,1) + yHat*POLY_XY(i,2);
    end
end

