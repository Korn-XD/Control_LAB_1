clc; close all;

%% =========================================================================
%  PART 1: รับค่าโหมดจากผู้ใช้ (เพื่อตั้งชื่อ Folder)
%  =========================================================================
mode_idx = input('กรุณาใส่เลขโหมดของ "ข้อมูลจริง" (Measured Data) (1-5): ');
mode_names = {'Step', 'Ramp', 'Sine', 'Stair', 'Chirp'};
if isempty(mode_idx) || mode_idx < 1 || mode_idx > 5
    my_mode_name = 'Comparison_Unknown'; 
else
    my_mode_name = ['Comparison_' mode_names{mode_idx}]; 
end

%% =========================================================================
%  PART 2: เตรียมข้อมูล (แก้ไขให้รองรับทั้งแบบมี out และไม่มี out)
%  =========================================================================
fprintf('กำลังประมวลผลข้อมูล...\n');

% --- 2.1 ข้อมูลจริง (Measured) แบบยืดหยุ่น ---
try
    if exist('out', 'var') && isfield(out, 'sim_speed')
        % กรณีมี out และมี sim_speed ข้างใน
        raw_meas = out.sim_speed;
    elseif exist('sim_speed', 'var')
        % กรณีไม่มี out แต่มี sim_speed ลอยอยู่ใน Workspace
        raw_meas = sim_speed;
    else
        error('VariableNotFound');
    end
    
    % แปลงข้อมูลเป็น Time/Data
    if isa(raw_meas, 'timeseries')
        t_meas = raw_meas.Time;
        y_meas = raw_meas.Data;
    elseif isstruct(raw_meas)
        t_meas = raw_meas.time;
        y_meas = raw_meas.signals.values;
    else
        % กรณีเป็น Array ธรรมดา (เผื่อไว้)
        t_meas = raw_meas(:,1); 
        y_meas = raw_meas(:,2);
    end
    fprintf('✅ พบข้อมูลจริง: sim_speed\n');
    
catch
    error('❌ หาตัวแปร sim_speed ไม่เจอ! กรุณาเช็ค To Workspace หรือรัน Sim ก่อน');
end

% --- 2.2 ข้อมูล Sim ที่จะนำมาเทียบ ---
sim_results = struct();
% หมายเหตุ: ต้องแก้ชื่อตัวแปรฝั่งขวาให้ตรงกับที่คุณตั้งใน Simulink
try
    % พยายามดึงจาก out ก่อน ถ้าไม่มีดึงจาก Workspace ตรงๆ
    if exist('out', 'var') && isfield(out, 'sim_speed_sim_Chirp_Param')
        sim_results.Chirp = out.sim_speed_sim_Chirp_Param;
        sim_results.Ramp = out.sim_speed_sim_Ramp_Param;
        sim_results.Sin2Pi = out.sim_speed_sim_Sin2Pi_Param;
        sim_results.SinPi_2 = out.sim_speed_sim_SinPi_2_Param;
        sim_results.SinPi = out.sim_speed_sim_SinPi_Param;
        sim_results.Stair = out.sim_speed_sim_Stair_Param;
    else
        % กรณีตัวแปรลอยอยู่ข้างนอก (แก้ชื่อตัวแปรตรงนี้ถ้าไม่ตรง)
        if exist('sim_speed_sim_Chirp_Param', 'var'), sim_results.Chirp = sim_speed_sim_Chirp_Param; end
        if exist('sim_speed_sim_Ramp_Param', 'var'), sim_results.Ramp = sim_speed_sim_Ramp_Param; end
        if exist('sim_speed_sim_Sin2Pi_Param', 'var'), sim_results.Sin2Pi = sim_speed_sim_Sin2Pi_Param; end
        if exist('sim_speed_sim_SinPi_2_Param', 'var'), sim_results.SinPi_2 = sim_speed_sim_SinPi_2_Param; end
        if exist('sim_speed_sim_SinPi_Param', 'var'), sim_results.SinPi = sim_speed_sim_SinPi_Param; end
        if exist('sim_speed_sim_Stair_Param', 'var'), sim_results.Stair = sim_speed_sim_Stair_Param; end
    end
catch
    warning('บางตัวแปร Sim อาจจะโหลดมาไม่ครบ');
end

%% =========================================================================
%  PART 3: คำนวณ R-Squared และ Plot กราฟ (Dark Mode Style)
%  =========================================================================

fig = figure('Name', ['R2 Comparison: ' my_mode_name], 'Color', 'k', 'Position', [100 100 1000 600]);

% Plot ข้อมูลจริง
plot(t_meas, y_meas, 'w', 'LineWidth', 2.5); 
hold on;

legend_list = {'Measured Data'}; 
best_r2 = -inf;
best_name = 'None';
results_struct = struct(); 

fields = fieldnames(sim_results);
if isempty(fields)
    warning('ไม่พบข้อมูล Simulation เลย! กราฟจะมีแค่ข้อมูลจริง');
else
    colors = hsv(numel(fields)); 
    
    fprintf('\n=== Comparison Results ===\n');
    fprintf('%-20s | %-10s\n', 'Parameter Set', 'R-Squared');
    fprintf('--------------------------------------\n');
    
    for i = 1:numel(fields)
        name = fields{i};
        data_sim_obj = sim_results.(name);
        
        % แยก Time/Data
        if isa(data_sim_obj, 'timeseries')
            t_sim = data_sim_obj.Time;
            y_sim = data_sim_obj.Data;
        elseif isstruct(data_sim_obj)
            t_sim = data_sim_obj.time;
            y_sim = data_sim_obj.signals.values;
        else
            continue;
        end
        
        % คำนวณ R2
        try
            y_sim_interp = interp1(t_sim, y_sim, t_meas, 'linear', 'extrap');
            residuals = y_meas - y_sim_interp;
            SS_res = sum(residuals.^2);
            mean_meas = mean(y_meas);
            SS_tot = sum((y_meas - mean_meas).^2);
            r2 = 1 - (SS_res / SS_tot);
            
            results_struct.(name) = r2;
            
            % Plot
            plot(t_sim, y_sim, 'LineWidth', 1.2, 'Color', colors(i,:));
            
            legend_str = sprintf('%s (R^2=%.4f)', name, r2);
            legend_list{end+1} = legend_str;
            
            fprintf('%-20s | %.5f\n', name, r2);
            
            if r2 > best_r2
                best_r2 = r2;
                best_name = name;
            end
        catch
            fprintf('%-20s | Error calculating R2\n', name);
        end
    end
end

% ตกแต่งกราฟ
hold off;
grid on;
set(gca, 'Color', 'k', 'XColor', 'w', 'YColor', 'w', 'GridColor', 'w', 'GridAlpha', 0.3);
xlabel('Time (s)', 'Color', 'w');
ylabel('Speed (rad/s)', 'Color', 'w');
title({['Model Comparison: ' my_mode_name]; ...
       ['Winner: \color{yellow}' best_name ' (R^2 = ' num2str(best_r2, '%.4f') ')']}, ...
       'Color', 'w', 'Interpreter', 'tex');
legend(legend_list, 'Location', 'best', 'TextColor', 'w', 'Color', 'none', 'EdgeColor', 'w');

fprintf('--------------------------------------\n');
fprintf('WINNER: "%s"\n', best_name);

%% =========================================================================
%  PART 4: บันทึกไฟล์ (Auto Folder Generation)
%  =========================================================================
if ~exist('Lab_Results', 'dir'), mkdir('Lab_Results'); end
timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
folder_name = sprintf('%s_%s_Analysis', timestamp, my_mode_name);
save_path = fullfile('Lab_Results', folder_name);
mkdir(save_path);

fprintf('\nกำลังบันทึกข้อมูลลง: %s\n', save_path);

img_filename = fullfile(save_path, 'Comparison_Plot.png');
set(fig, 'InvertHardcopy', 'off'); 
saveas(fig, img_filename);
fprintf('   -> บันทึกรูปภาพแล้ว\n');

mat_filename = fullfile(save_path, 'Analysis_Data.mat');
save(mat_filename, 'results_struct', 'best_name', 'best_r2', 't_meas', 'y_meas', 'timestamp');
fprintf('   -> บันทึกผลวิเคราะห์แล้ว\n');
fprintf('--------------------------------------------------\n');
fprintf('✅ เสร็จสิ้นสมบูรณ์!\n');