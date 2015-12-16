function simulateIntruder(save_figures)
% simulateFormPlatoon()
%
% Simulates 5 quadrotors forming a single platoon on a highway

addpath('..')

if nargin < 1
  save_figures = false;
end

%% TFM
tfm = TFM;
tfm.computeRS('qr_rel_target_V');
tfm.computeRS('qr_abs_target_V');
tfm.computeRS('qr_qr_safe_V');
tfm.ipsd = 10;
%% Highways
theta = 2*pi*rand;
hw_length = 300;
z0 = hw_length*[-0.1 0];
z1 = hw_length*[1 0];

% Highway 1
z0 = rotate2D(z0, theta);
z1 = rotate2D(z1, theta);
hw = Highway(z0, z1, tfm.hw_speed);
tfm.addHighway(hw);

% plot
figure;
hw.lpPlot;
hold on

%% Quadrotors
% Platoon 1 (4 vehicles)
x0 = 0;
xs = x0: -tfm.ipsd: x0 - 3*tfm.ipsd;
ys = zeros(size(xs));
xs_ys = rotate2D([xs; ys], theta);
xs = xs_ys(1,:);
ys = xs_ys(2,:);
vq = [10 0];
vq = rotate2D(vq, theta);
for j = 1:length(xs)
  q = Quadrotor([xs(j) vq(1) ys(j) vq(2)]);
  tfm.regVehicle(q);
  if j == 1
    p = Platoon(q, hw, tfm);
  else
    p.insertVehicle(q, j);
  end
end

% Intruder
pin = [250 50];
vin = [10 0];
vin = rotate2D(vin, 9*pi/8);
pin = rotate2D(pin, theta);
vin = rotate2D(vin, theta);
intruder = Quadrotor([pin(1) vin(1) pin(2) vin(2)]);
tfm.regVehicle(intruder);

for j = 1:length(tfm.aas)
  tfm.aas{j}.plotPosition;
end
title('t=0')
axis equal
drawnow

if save_figures
  fig_dir = [fileparts(mfilename('fullpath')) '/' mfilename '_figs'];
  if ~exist(fig_dir, 'dir')
    cmd = ['mkdir -p ' fig_dir];
    system(cmd)
  end
  export_fig([fig_dir '/0'], '-png', '-m2')
end


%% Integration
tMax = 25;
t = 0:tfm.dt:tMax;

u = cell(size(tfm.aas));
for i = 1:length(t)
  [safe, uSafe] = tfm.checkAASafety;

  safe(5) = 1;
  for j = 1:length(tfm.aas)
    if safe(j)
      u{j} = controlLogic(tfm, tfm.aas{j});

    else
      
      u{j} = uSafe{j};
    end
    
    tfm.aas{j}.updateState(u{j}, tfm.dt);
    tfm.aas{j}.plotPosition;
  end
  title(['t=' num2str(t(i))])
  drawnow

  if save_figures
    export_fig([fig_dir '/' num2str(i)], '-png', '-m2')
  end
end

tfm.printBreadthFirst;
end

function u = controlLogic(tfm, veh)
if strcmp(veh.q, 'Free')
  u = [0; 0];
  return
end

if strcmp(veh.q, 'Leader')
  u = veh.followPath(veh.p.hw);
  return
end

% If already in the platoon, simply follow it
u = veh.followPlatoon(tfm);
end