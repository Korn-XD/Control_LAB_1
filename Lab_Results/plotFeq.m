clc; close all;

%% 1. ตั้งค่าชื่อไฟล์และสี
file_list    = {'Feq200.mat',  'Feq2000.mat', 'Feq20000.mat'};
legend_names = {'Freq 200 Hz', 'Freq 2000 Hz', 'Freq 20000 Hz'};
line_colors  = {'c', 'm', 'y'}; % ฟ้า, ม่วง, เหลือง

%% 2. สร้างกราฟ
fig = figure('Name', 'Frequency Comparison', 'Color', 'k', 'Position', [100 100 1000 600]);
hold on;

fprintf('กำลังโหลดและพล็อตกราฟ...\n');

for i = 1:length(file_list)
    filename = file_list{i};
    
    if ~exist(filename, 'file')
        warning('❌ ไม่พบไฟล์: %s (ข้าม)', filename);
        continue;
    end
    
    % โหลดข้อมูล
    data_struct = load(filename);
    
    t_plot = [];
    y_plot = [];
    found = false;
    
    % --- LOGIC ใหม่: ค้นหาข้อมูลแบบครอบจักรวาล ---
    
    % 1. เช็คหาชื่อ 'data' ก่อนเลย (ตามรูปที่คุณส่งมา)
    if isfield(data_struct, 'data') && isa(data_struct.data, 'timeseries')
        t_plot = data_struct.data.Time;
        y_plot = data_struct.data.Data;
        found = true;
        fprintf('   -> เจอตัวแปรชื่อ "data" ในไฟล์ %s\n', filename);
        
    else
        % 2. ถ้าไม่ใช่ชื่อ data ให้วนลูปหาตัวแปรไหนก็ได้ที่เป็น TimeSeries
        field_names = fieldnames(data_struct);
        for k = 1:length(field_names)
            var_name = field_names{k};
            obj = data_struct.(var_name);
            
            % ถ้าเป็น TimeSeries เอาอันนี้แหละ!
            if isa(obj, 'timeseries')
                t_plot = obj.Time;
                y_plot = obj.Data;
                found = true;
                fprintf('   -> เจอตัวแปรชื่อ "%s" ในไฟล์ %s\n', var_name, filename);
                break; 
            end
        end
    end
    
    % --- พล็อต ---
    if found && ~isempty(t_plot)
        plot(t_plot, y_plot, 'Color', line_colors{i}, 'LineWidth', 1.5, ...
             'DisplayName', legend_names{i});
    else
        warning('⚠️ เปิดไฟล์ %s ได้ แต่ข้างในไม่มีข้อมูล TimeSeries เลย', filename);
    end
end

%% 3. ตกแต่ง
hold off; grid on;
set(gca, 'Color', 'k', 'XColor', 'w', 'YColor', 'w', 'GridColor', 'w', 'GridAlpha', 0.3);
xlabel('Time (s)', 'Color', 'w', 'FontSize', 12);
ylabel('Speed (rad/s)', 'Color', 'w', 'FontSize', 12);
title('Comparison of Different Frequencies', 'Color', 'w', 'FontSize', 14);
legend('show', 'TextColor', 'w', 'Color', 'none', 'EdgeColor', 'w', 'Location', 'best');

fprintf('เสร็จสิ้น!\n');