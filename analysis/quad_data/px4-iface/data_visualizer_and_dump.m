clear all;
close all;

libPath = '../px4-lib';
logPath = '../px4-logs';

dirName = 'tf3'; % {tf1, tf2}
 
addpath(libPath);
addpath(logPath);

ldata = read_log_data(logPath,dirName);
ld = add_precalcs(ldata);


%% PRELIMINARY COORDINATE TRANSOFRMATIONS ANS SENSORY ANALYSIS 
% for IJCNN PAPER 
%TRACKER (GT)
t       = ld.rb.hrt.t;
roll    = -ld.rb.roll;
pitch   = ld.rb.pitch;
yaw     = -ld.rb.yaw;
T       = ld.imu.hrt.t;

% interpolate data to imu hrt timeline
troll    = interp1(t,  roll,     ld.imu.hrt.t);
tpitch   = interp1(t,  pitch,    ld.imu.hrt.t);
troll(isnan(troll)) = 0.0;
tpitch(isnan(tpitch)) = 0.0;

% % ACCELEROMETER
figure; 
mfa = 50;
subplot(3,2,1); plot(ld.acc.rot.roll_lrn, -(mfa*sort(ld.acc.a_rot_f(2,:)./(- ld.g))),'.g'); 
subplot(3,2,3); plot(T, (troll)); hold on; plot(T, (ld.acc.rot.roll)); 
subplot(3,2,5); plot(sort(troll),sort(ld.acc.rot.roll)); 
subplot(3,2,2); plot(ld.acc.rot.pitch_lrn, (mfa*sort(ld.acc.a_rot_f(1,:)./(- ld.g))),'.b');
subplot(3,2,4); plot(T, (tpitch)); hold on; plot(T, (ld.acc.rot.pitch)); 
subplot(3,2,6); plot(sort(tpitch),sort(ld.acc.rot.pitch)); 

%  MAGNETOMETER

%TRACKER (GT)
t       = ld.rb.hrt.t;
roll    = ld.rb.roll;
pitch   = -ld.rb.pitch;
yaw     = -ld.rb.yaw;
T       = ld.imu.hrt.t;

% interpolate data to imu hrt timeline
troll    = interp1(t,  roll,     ld.imu.hrt.t);
tpitch   = interp1(t,  pitch,    ld.imu.hrt.t);
tyaw     = interp1(t,  yaw,      ld.imu.hrt.t);

troll(isnan(troll)) = 0.0;
tpitch(isnan(tpitch)) = 0.0;
tyaw(isnan(tyaw)) = 0.0;

figure; 
mfm = 0.01;
subplot(3,1,1); plot(ld.mag.yaw_lrn, (mfm*sort(ld.mag.b_hat(2,:)./ld.mag.b_hat(1,:))),'.m'); 
subplot(3,1,2); plot(T, (tyaw)); hold on; plot(T, (ld.mag.yaw_off - ld.mag.yaw)); 
subplot(3,1,3); plot(sort(tyaw),sort(ld.mag.yaw_off - ld.mag.yaw)); 

% collect data to dump in a different structure 
% tracker (ground truth)
ddump.gt.roll = sort(troll);
ddump.gt.pitch = sort(tpitch);
ddump.gt.yaw = sort(tyaw);
ddump.gt.t   = T;
% accelerometer 
ddump.acc.roll.disp = sort(ld.acc.rot.roll); ddump.acc.roll.disp(isnan(ddump.acc.roll.disp)) = 0;
ddump.acc.roll.lrn = ld.acc.rot.roll_lrn; ddump.acc.roll.lrn(isnan(ddump.acc.roll.lrn)) = 0;
ddump.acc.roll.inf = -(mfa*sort(ld.acc.a_rot_f(2,:)./(- ld.g))); ddump.acc.roll.inf(isnan(ddump.acc.roll.inf)) = 0;
ddump.acc.pitch.disp = sort(ld.acc.rot.pitch); ddump.acc.pitch.disp(isnan(ddump.acc.pitch.disp)) = 0;
ddump.acc.pitch.lrn = ld.acc.rot.pitch_lrn; ddump.acc.pitch.lrn(isnan(ddump.acc.pitch.lrn)) = 0;
ddump.acc.pitch.inf = (mfa*sort(ld.acc.a_rot_f(1,:)./(- ld.g)));  ddump.acc.pitch.inf(isnan(ddump.acc.pitch.inf)) = 0;
% magneto
ddump.mag.yaw.disp = sort(ld.mag.yaw_off - ld.mag.yaw); ddump.mag.yaw.disp(isnan(ddump.mag.yaw.disp))=0;
ddump.mag.yaw.lrn  = ld.mag.yaw_lrn; ddump.mag.yaw.lrn(isnan(ddump.mag.yaw.lrn)) = 0;
ddump.mag.bfield = (mfm*sort(ld.mag.b_hat(2,:)./ld.mag.b_hat(1,:)));  ddump.mag.bfield(isnan(ddump.mag.bfield)) = 0;

% dump in a binary file 
data_dump = fopen('accrolllrn_accrollinf.dat','wb');

data_pts = length(ddump.acc.roll.lrn);
fwrite(data_dump, data_pts, 'int');
for id = 1:length(ddump.acc.roll.lrn)
   fwrite(data_dump, ddump.acc.roll.lrn(id), 'double'); 
end

data_pts = length(ddump.acc.roll.lrn);
fwrite(data_dump, data_pts, 'int');
for id = 1:length(ddump.acc.roll.lrn)
   fwrite(data_dump, ddump.acc.roll.inf(id), 'double'); 
end

fclose(data_dump);
% ----------------------------------------------------

data_dump = fopen('gtroll_accrolldisp.dat','wb');

data_pts = length(ddump.gt.t);
fwrite(data_dump, data_pts, 'int');
for id = 1:length(ddump.gt.t)
   fwrite(data_dump, ddump.gt.roll(id), 'double'); 
end

data_pts = length(ddump.gt.t);
fwrite(data_dump, data_pts, 'int');
for id = 1:length(ddump.gt.t)
   fwrite(data_dump, ddump.acc.roll.disp(id), 'double'); 
end

fclose(data_dump);
%-----------------------------------------------------

data_dump = fopen('accpitchlrn_accpitchinf.dat','wb');
data_pts = length(ddump.acc.pitch.lrn);
fwrite(data_dump, data_pts, 'int');
for id = 1:length(ddump.acc.pitch.lrn)
   fwrite(data_dump, ddump.acc.pitch.lrn(id), 'double'); 
end

data_pts = length(ddump.acc.pitch.lrn);
fwrite(data_dump, data_pts, 'int');
for id = 1:length(ddump.acc.pitch.lrn)
   fwrite(data_dump, ddump.acc.pitch.inf(id), 'double'); 
end

fclose(data_dump);
%----------------------------------------------------

data_dump = fopen('gtpitch_accpitchdisp.dat','wb');
data_pts = length(ddump.gt.t);
fwrite(data_dump, data_pts, 'int');
for id = 1:length(ddump.gt.t)
   fwrite(data_dump, ddump.gt.pitch(id), 'double'); 
end

data_pts = length(ddump.gt.t);
fwrite(data_dump, data_pts, 'int');
for id = 1:length(ddump.gt.t)
   fwrite(data_dump, ddump.acc.pitch.disp(id), 'double'); 
end

fclose(data_dump);
%----------------------------------------------------

data_dump = fopen('magyawlrn_magbfield.dat','wb');
data_pts = length(ddump.mag.yaw.lrn);
fwrite(data_dump, data_pts, 'int');
for id = 1:length(ddump.mag.yaw.lrn)
   fwrite(data_dump, ddump.mag.yaw.lrn(id), 'double'); 
end

data_pts = length(ddump.mag.yaw.lrn);
fwrite(data_dump, data_pts, 'int');
for id = 1:length(ddump.mag.yaw.lrn)
   fwrite(data_dump, ddump.mag.bfield(id), 'double'); 
end

fclose(data_dump);
%-----------------------------------------------------

data_dump = fopen('gtyaw_magyawdisp.dat','wb');
data_pts = length(ddump.gt.t);
fwrite(data_dump, data_pts, 'int');
for id = 1:length(ddump.gt.t)
   fwrite(data_dump, ddump.gt.yaw(id), 'double'); 
end

data_pts = length(ddump.gt.t);
fwrite(data_dump, data_pts, 'int');
for id = 1:length(ddump.gt.t)
   fwrite(data_dump, ddump.mag.yaw.disp(id), 'double'); 
end

fclose(data_dump);
%----------------------------------------------------

%%
% figure
% plot_servo_output_raw(ld.sor);

% figure
% plot_manual_control(ld.mc);

% 
% figure
% plot_sys_status(ld.ss);

% figure
% plot_highres_imu(ld.imu, ld.tsmin);


% figure
% plot_attitude(ld.att, ld.tsmin);

% figure
% plot_optical_flow(ld.of, ld.tsmin);

% figure
% plot_rigidBody(ld.rb, ld.tsmin);

% figure
% plot_rigidBody_lin_trans(ld);

% figure
% plot_of_weighted(ld);
% 
% figure
% plot_of_v_lin(ld);

% figure
% plot_acc_filtered(ld); 

% figure
% plot_acc_angle_vel(ld);

% figure
% plot_acc_LPF_and_FT(ld);
% 
% 
% figure
% plot_acc_a_lin(ld);
% 
% figure
% plot_acc_a_rot(ld);

% figure
% plot_mag_b(ld);

% 
% figure
% plot_rpy(ld);

% 
% figure
% plot_rpy_gyro(ld);
%   
% figure
% plot_rpy_acc(ld);
% 
% 
% figure
% plot_rpy_mag(ld);


% figure
% plot_KF_roll(ld);



% figure
% plot_time_analysis(ld);



% figure
% plot_roll_spectrogram(ld);



% figure
% plot(ld.imu.hrt.t,ld.imu.xgyro)
% grid on
% hold on
% plot(ld.imu.hrt.t,ld.gyro.vr_f,'r')
% 
% 
% 
% figure
% plot(ld.imu.hrt.t,ld.imu.xmag)
% grid on
% hold on
% plot(ld.imu.hrt.t,ld.mag.bx_f,'r')
% 
% 
% 
% figure
% plot(ld.imu.hrt.t,ld.imu.ymag)
% grid on
% hold on
% plot(ld.imu.hrt.t,ld.mag.by_f,'r')
