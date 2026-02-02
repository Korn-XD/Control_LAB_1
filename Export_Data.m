% --- Post-Processing Script: Export .MAT & Plot (Auto Folder Generation) ---
clc; close all;

% =========================================================================
% 1. รับค่าโหมดจากผู้ใช้
% =========================================================================
mode_idx = input('กรุณาใส่เลขโหมดที่เพิ่งรันเสร็จ (1-5): ');
mode_names = {'Step', 'Ramp', 'Sine', 'Stair', 'Chirp'};

if isempty(mode_idx) || mode_idx < 1 || mode_idx > 5
    my_mode_name = 'Unknown'; 
    mode_idx = 0;
else
    my_mode_name = mode_names{mode_idx};
end

% =========================================================================
% 2. ดึงข้อมูลจาก Workspace
% =========================================================================
fprintf('กำลังดึงข้อมูลจาก To Workspace...\n');
try
    if exist('out', 'var')
        % ดึงค่าจากตัวแปร out (Standard)
        sig_volt = out.sim_volt;
        sig_speed = out.sim_speed;
    else
        % กรณีไม่ได้ติ๊ก Single simulation output
        sig_volt = sim_volt;
        sig_speed = sim_speed;
    end
    fprintf('✅ พบข้อมูลถูกต้อง! (sim_volt, sim_speed)\n');
catch
    fprintf('\n❌ Error: หาตัวแปรไม่เจอ!\n');
    fprintf('วิธีแก้: เช็คว่าตั้งชื่อ Variable name ใน To Workspace ว่า "sim_volt" และ "sim_speed" หรือยัง?\n');
    error('Variable not found');
end

% =========================================================================
% 3. สร้าง Folder ใหม่ (กันชื่อซ้ำด้วย Timestamp)
% =========================================================================
% สร้าง Main Folder ถ้ายังไม่มี
if ~exist('Lab_Results', 'dir')
    mkdir('Lab_Results');
end

% สร้างชื่อ Sub-Folder ตามวันและเวลา (เช่น 2023-10-25_14-30-05_Step)
timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
folder_name = sprintf('%s_%s', timestamp, my_mode_name);
save_path = fullfile('Lab_Results', folder_name);

% สร้าง Folder จริง
mkdir(save_path);
fprintf('สร้าง Folder เก็บข้อมูลใหม่: %s\n', save_path);

% =========================================================================
% 4. พลอตกราฟ (Dark Mode Style)
% =========================================================================
fig = figure('Name', ['Result: ' my_mode_name], 'Color', 'k'); % พื้นหลังดำ
tiledlayout(2,1);

% --- กราฟบน: Voltage ---
nexttile;
plot(sig_volt.Time, squeeze(sig_volt.Data), 'c-', 'LineWidth', 1.5); % สีฟ้า Cyan (ชัดบนดำ)
title(['Input Voltage: ' my_mode_name], 'Color', 'w');
ylabel('Voltage (V)', 'Color', 'w');
grid on;
ylim([-1, 13]);
% ปรับแกนเป็นสีขาวให้อ่านง่ายบนพื้นดำ
set(gca, 'Color', 'k', 'XColor', 'w', 'YColor', 'w', 'GridColor', 'w', 'GridAlpha', 0.3);

% --- กราฟล่าง: Speed ---
nexttile;
plot(sig_speed.Time, squeeze(sig_speed.Data), 'm-', 'LineWidth', 1.5); % สีม่วง Magenta (ชัดบนดำ)
title(['Motor Speed: ' my_mode_name], 'Color', 'w');
ylabel('Speed (rad/s)', 'Color', 'w');
xlabel('Time (s)', 'Color', 'w');
grid on;
set(gca, 'Color', 'k', 'XColor', 'w', 'YColor', 'w', 'GridColor', 'w', 'GridAlpha', 0.3);

% =========================================================================
% 5. บันทึกไฟล์ (Image & .MAT)
% =========================================================================

% 5.1 บันทึกรูปกราฟ (Image)
img_filename = fullfile(save_path, 'Graph_Result.png');
set(fig, 'InvertHardcopy', 'off'); % สั่งให้พื้นหลังดำตอนเซฟ (ไม่เปลี่ยนเป็นขาว)
saveas(fig, img_filename);
fprintf('   -> บันทึกรูปภาพแล้ว: Graph_Result.png\n');

% 5.2 บันทึกข้อมูลดิบ (.MAT)
mat_filename = fullfile(save_path, 'Raw_Data.mat');
% บันทึกเฉพาะตัวแปรที่จำเป็น
save(mat_filename, 'sig_volt', 'sig_speed', 'my_mode_name', 'timestamp');
fprintf('   -> บันทึกข้อมูลดิบแล้ว: Raw_Data.mat\n');

fprintf('--------------------------------------------------\n');
fprintf('✅ เสร็จสิ้น! ข้อมูลทั้งหมดอยู่ใน: %s\n', save_path);
fprintf('--------------------------------------------------\n');