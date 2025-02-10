%% Three-Dimensional Representation of Traffic Flow


% =========================================================================
% Author:         Yinjie Luo (<firstname>.<lastname>@nyu.edu)
% Affiliation：   Tandon School of Engineering, New York University
% Date:           2025-02-09
% Version:        1.0

% Description:    
%   This script could help teachers(students) from traffic/transportation
%   engineering to teach(understand) the three-dimensional representation
%   of traffic flow in an intuitive way, where X-axis is for time, Y-axis 
%   is for space, and Z-axis is for traffic count N(x,t). It allows users 
%   to customize the vehicle trajectories and the temporal and spatial 
%   domain where the observer is standing.

% References:
% [1] Makigami, Y., Newell, G. F., & Rothery, R. (1971). Three-dimensional 
%     representation of traffic flow. Transportation Science, 5(3), 302-313.
% [2] Ni, D. (2015). Traffic flow theory: Characteristics, experimental 
%     methods, and numerical techniques. Butterworth-Heinemann. 
%     (See Chapter-3---Traffic-Flow-Characteristics-II)

% P.S.: Feel free to contact me if you have any questions!
% =========================================================================


close all;
clear;
clc;
dbstop if error;


% Vechicles departing from time (X-) and space (Y-) axes
vehNum_onTime = 10;              % `vehNum_onTime` vehicles from X-axis (time)
vehNum_onSpace = 10;             % `vehNum_onSpace` vehicles from T-axis (space)
firstVeh_Pos_onSpace = 10;      % first vechicle from (0, firstVeh_Pos_onSpace)
laxtVeh_pos_onTime = 10;        % last vehicle from (laxtVeh_pos_onTime, 0)
t_starts = [zeros(1, vehNum_onSpace+1), 0, linspace(0, laxtVeh_pos_onTime, vehNum_onTime+1)];
x_starts = [linspace(firstVeh_Pos_onSpace, 0, vehNum_onSpace+1), 0, zeros(1, vehNum_onTime+1)];
t_starts([vehNum_onSpace+1, vehNum_onSpace+2]) = [];
x_starts([vehNum_onSpace+1, vehNum_onSpace+2]) = [];

% Number of vehicles/trajectories 
% = vehicles on time axis + vehicles on space axis + vehicle from (0,0)
num_vehicles = vehNum_onTime + vehNum_onSpace + 1;

% Ranges of X, Y, Z axes
axes_range_extension = 2.0;
x_max = firstVeh_Pos_onSpace + axes_range_extension;
t_max = laxtVeh_pos_onTime + axes_range_extension;
N_max = num_vehicles + axes_range_extension;

% Time step
delta_t = 0.50;

% Speed range
v_min = 0.6;
v_max = 1.8;

% Noises for trajectories
noise_level = 0.18;

% Choose one of the following color profiles for trajectories
%   colors = parula(num_vehicles);              % gradient color
%   colors = jet(num_vehicles);                 % gradient color
%   colors = ones(num_vehicles, 1) * [0 0 0];   % pure color
colors = ones(num_vehicles, 1) * [0 0 0];

% Trajectory visualization
figure('Name','3D Vehicle Trajectories','Position',[500 500 626 548]);
hold on;

Traj(num_vehicles).x = [];      % record each trajectory infomation in a struct

for vehId = 1:num_vehicles
    % initial [x,t] for each vehicle
    x_start = x_starts(vehId);
    t_start = t_starts(vehId);

    % rand speed for each vehicle
    if vehId == 1
        v_speed = v_min + (v_max - v_min) * rand();     % the first car's speed
    else
        v_speed = max(v_min, v_speed - 0.02 * rand());  % be slower than the front vehicle
    end

    % Times, as x-axis
    t_vehicle = t_start + 0:delta_t:t_max;
    if t_vehicle(end) < t_max
        t_vehicle = [t_vehicle, t_max];
    end
    
    % Positions, as y-axis
    x_vehicle = x_start + v_speed * (t_vehicle - t_start) + ...
        [0, noise_level * rand(1, length((t_vehicle-t_start))-1)];

    ii = find(x_vehicle>x_max, 1);
    if ~isempty(ii)
        x_vehicle = x_vehicle(1:ii);
        v_actual_speed = (x_vehicle(ii)-x_vehicle(ii-1)) / (t_vehicle(ii)-t_vehicle(ii-1));
        x_vehicle(ii) = x_max;
        t_vehicle = t_vehicle(1:ii);
        t_vehicle(ii) = t_vehicle(ii-1) + (x_vehicle(ii) - x_vehicle(ii-1)) / v_actual_speed;
    end

    % Traffic count N(x,t), as z-axis
    N_vehicle = vehId * ones(size(x_vehicle));

    % Record trajectory information
    Traj(vehId).x = x_vehicle;
    Traj(vehId).t = t_vehicle;
    Traj(vehId).N = N_vehicle;
    Traj(vehId).speed = v_speed;

    % Draw trajectory
    plot3(t_vehicle, x_vehicle, N_vehicle, 'Color', colors(vehId, :), 'LineWidth', 1);
end


% Draw the traffic count stairs (optional)
showAuxiliaryCountLines = 0;    % perpendicular lines from each stair to Z aixs (optional)
DrawCountStairs(Traj, t_max, x_max, colors, showAuxiliaryCountLines);


% Axes settings
set(gca,'xlim', [0, t_max], 'ylim',[0, x_max], 'zlim', [0, N_max]);
xlabel('Time: t', 'Color', 'k', 'FontSize', 12);
ylabel('Space: x', 'Color', 'k', 'FontSize', 12);
zlabel('Cumulative number: N(x, t)', 'Color', 'k', 'FontSize', 12);

% View settings
% camproj('perspective');             % use perspective view
% view(0,90);                         % 2D bird's eye vie
view(-65, 24);                      % 3D view
grid on;
grid minor;
box on;



%% (1) Observe from the time domain (optional)
t_obsv = 4.0;                       % in (0, t_max), observe at t = t_obsv
color = [1 0 0];                    % mark color
ObserveFromTimeDomain(t_obsv, color, Traj, x_max);
% view(-90, 0);                       % view x-N plane (optional)


% E.g., Multiple observations (optional)
% t_obsv = 8.0;                      % in (0, t_max), observe at t = t_obsv
% color = [1 0 0];                    % mark color
% ObserveFromTimeDomain(t_obsv, color, Traj, x_max);
% % view(-90, 0);                       % view x-N plane (optional)



%% (2) Observe from the space domain (optional)
x_obsv = 4.0;                       % in (0, x_max), observe at x = x_obsv
color = [0 0 1];                    % mark color
ObserveFromSpaceDomain(x_obsv, color, Traj, t_max);
% view(0, 0);                         % view v-N plane (optional)

% E.g., Multiple observations (optional)
% x_obsv = 8.0;                       % in (0, x_max), observe at x = x_obsv
% color = [0 0 1];                    % mark color
% ObserveFromSpaceDomain(x_obsv, color, Traj, t_max);
% % view(0, 0);                         % view v-N plane (optional)





%% ========================================================
% Local functions


function DrawCountStairs(Traj, t_max, x_max, colors, showAuxiliaryCountLines)

num_vehicles = length(Traj);

for vehId = 1:num_vehicles
    % perpendicular lines to Z axis
    if showAuxiliaryCountLines
        if Traj(vehId).t(1) == 0      % from the start point to Z axis
            plot3([Traj(vehId).t(1), Traj(vehId).t(1)], ...
                [Traj(vehId).x(1), 0], ...
                [Traj(vehId).N(1), Traj(vehId).N(1)], ...
                'Color', colors(vehId, :), 'LineWidth', 1, 'LineStyle','--');
            plot3([Traj(vehId).t(1), t_max], ...
                [0, 0], ...
                [Traj(vehId).N(1), Traj(vehId).N(1)], ...
                'Color', colors(vehId, :), 'LineWidth', 1, 'LineStyle','--');
        else
            plot3([Traj(vehId).t(1), t_max], ...
                [Traj(vehId).x(1), Traj(vehId).x(1)], ...
                [Traj(vehId).N(1), Traj(vehId).N(1)], ...
                'Color', colors(vehId, :), 'LineWidth', 1, 'LineStyle','--');
        end

        if Traj(vehId).x(end) == x_max        % from the end point to Z axis
            plot3([Traj(vehId).t(end), t_max], ...
                [Traj(vehId).x(end), Traj(vehId).x(end)], ...
                [Traj(vehId).N(end), Traj(vehId).N(end)], ...
                'Color', colors(vehId, :), 'LineWidth', 1, 'LineStyle','--');
            plot3([t_max, t_max], ...
                [Traj(vehId).x(end), 0], ...
                [Traj(vehId).N(end), Traj(vehId).N(end)], ...
                'Color', colors(vehId, :), 'LineWidth', 1, 'LineStyle','--');
        else
            plot3([Traj(vehId).t(end), Traj(vehId).t(end)], ...
                [Traj(vehId).x(end), 0], ...
                [Traj(vehId).N(end), Traj(vehId).N(end)], ...
                'Color', colors(vehId, :), 'LineWidth', 1, 'LineStyle','--');
        end
    end

    % copy Traj(id) to Traj(id).N-1
    plot3(Traj(vehId).t, Traj(vehId).x, Traj(vehId).N-1, ...
        'Color', colors(vehId, :), 'LineWidth', 1, 'LineStyle','--');
    
    % connect the first points
    txN_n = [Traj(vehId).t(1), Traj(vehId).x(1), Traj(vehId).N(1)];
    if vehId == 1
        txN_n_1 = [0, x_max, 0];
    else
        txN_n_1 = [Traj(vehId-1).t(1), Traj(vehId-1).x(1), Traj(vehId-1).N(1)];
    end
    Connect_N_to_N_1(txN_n, txN_n_1, colors(vehId,:), colors(vehId,:));

    % connect the last points
    txN_n = [Traj(vehId).t(end), Traj(vehId).x(end), Traj(vehId).N(end)];
    if vehId == 1
        txN_n_1 = [0, x_max, 0];
    else
        txN_n_1 = [Traj(vehId-1).t(end), Traj(vehId-1).x(end), Traj(vehId-1).N(end)];
    end
    Connect_N_to_N_1(txN_n, txN_n_1, colors(vehId,:), colors(vehId,:));
end
% the lowest stair (connect to [0, x_max])
plot3([Traj(end).t(1), t_max], [Traj(end).x(1), 0], [Traj(end).N(1), Traj(end).N(1)], ...
    'Color', colors(vehId,:), 'LineWidth', 1, 'LineStyle','-');
% the highest stair (connect to [t_max, 0])
plot3([Traj(end).t(end), t_max], [Traj(end).x(end), 0], [Traj(end).N(end), Traj(end).N(end)], ...
    'Color', colors(vehId,:), 'LineWidth', 1, 'LineStyle','-');
end



function Connect_N_to_N_1(txN_n, txN_n_1, color_n, color_n_1)
% connect Traj(id) to Traj(id).N-1
plot3([txN_n(1), txN_n(1)], [txN_n(2), txN_n(2)], [txN_n(3), txN_n(3)-1], ...
    'Color', color_n, 'LineWidth', 1, 'LineStyle','-');

% connect Traj(id).N-1 to Traj(id-1)
plot3([txN_n(1), txN_n_1(1)], [txN_n(2), txN_n_1(2)], [txN_n(3)-1, txN_n_1(3)], ...
    'Color', color_n_1, 'LineWidth', 1, 'LineStyle','-');
end



function MarkObervation(marPts, color)
%% Use frame only
% for i = 2:size(marPts,1)
%     plot3([marPts(i-1,1),marPts(i,1)], [marPts(i-1,2),marPts(i,2)], [marPts(i-1,3),marPts(i,3)], ...
%         'Color', color, 'LineWidth', 1, 'LineStyle','-')
% end

%% Use patch
X = marPts(:,1)';
Y = marPts(:,2)';
Z = marPts(:,3)';
fill3(X, Y, Z, color, 'FaceAlpha', 0.2, 'EdgeColor', color);
end



function ObserveFromTimeDomain(t_obsv, color, Traj, x_max)
num_vehicles = length(Traj);
txN(num_vehicles).t = [];           % t, x, N of each vehicle
isFirst = 1;
lastVehId = 0;
txN_markPts = [];
for vehId = 1:num_vehicles
    if t_obsv <= Traj(vehId).t(1) || t_obsv >= Traj(vehId).t(end)
        continue;
    end
    id = find(Traj(vehId).t>t_obsv, 1);
    txN(vehId).t = t_obsv;
    speed = (Traj(vehId).x(id) - Traj(vehId).x(id-1)) / (Traj(vehId).t(id) - Traj(vehId).t(id-1));
    txN(vehId).x = Traj(vehId).x(id-1) + speed * (t_obsv-Traj(vehId).t(id-1));
    txN(vehId).N= Traj(vehId).N(id);

    if isFirst
        txN_markPts = [txN_markPts;
            [t_obsv, x_max, 0];
            [t_obsv, x_max, txN(vehId).N-1];
            [txN(vehId).t, txN(vehId).x, txN(vehId).N-1];
            [txN(vehId).t, txN(vehId).x, txN(vehId).N]];
    else
        txN_markPts = [txN_markPts;
            [txN(vehId).t, txN(vehId).x, txN(vehId).N-1];
            [txN(vehId).t, txN(vehId).x, txN(vehId).N]];
    end

    isFirst = 0;
    lastVehId = vehId;
end
txN_markPts = [txN_markPts;
            [txN(lastVehId).t, 0, txN(lastVehId).N];
            [txN(lastVehId).t, 0, 0]];

MarkObervation(txN_markPts, color);
end



function ObserveFromSpaceDomain(x_obsv, color, Traj, t_max)
num_vehicles = length(Traj);
txN(num_vehicles).t = [];           % t, x, N of each vehicle
isFirst = 1;
lastVehId = 0;
txN_markPts = [];
for vehId = 1:num_vehicles
    if x_obsv <= Traj(vehId).x(1) || x_obsv >= Traj(vehId).x(end)
        continue;
    end
    id = find(Traj(vehId).x>x_obsv, 1);
    txN(vehId).x = x_obsv;
    speed = (Traj(vehId).x(id) - Traj(vehId).x(id-1)) / (Traj(vehId).t(id) - Traj(vehId).t(id-1));
    txN(vehId).t = Traj(vehId).t(id-1) + (x_obsv - Traj(vehId).x(id-1)) / speed;
    txN(vehId).N= Traj(vehId).N(id);

    if isFirst
        txN_markPts = [txN_markPts;
            [0, x_obsv, 0];
            [0, x_obsv, txN(vehId).N-1];
            [txN(vehId).t, txN(vehId).x, txN(vehId).N-1];
            [txN(vehId).t, txN(vehId).x, txN(vehId).N]];
    else
        txN_markPts = [txN_markPts;
            [txN(vehId).t, txN(vehId).x, txN(vehId).N-1];
            [txN(vehId).t, txN(vehId).x, txN(vehId).N]];
    end

    isFirst = 0;
    lastVehId = vehId;
end
txN_markPts = [txN_markPts;
            [t_max, txN(lastVehId).x, txN(lastVehId).N];
            [t_max, txN(lastVehId).x, 0]];

MarkObervation(txN_markPts, color);

end
