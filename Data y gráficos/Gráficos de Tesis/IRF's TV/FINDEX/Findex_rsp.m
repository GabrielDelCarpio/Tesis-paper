% Leer nombres de las hojas
clear;clc;
pwd = "C:\Users\gabri\OneDrive\Desktop\Cato\Tesis\Tesis-paper\Data y gráficos\Gráficos de Tesis\IRF's TV\FINDEX"
% [~, sheetNames] = xlsfinfo('Resp. findex 4k.xlsx');
% [~, sheetNames] = xlsfinfo('Resp. findex 8k 1lag.xlsx'); % findex 8k 1lag
% [~, sheetNames] = xlsfinfo('Resp. findex 8k 2lag.xlsx'); % findex 8k 2lag
[~, sheetNames] = xlsfinfo('Resp. findex 10k 4lag.xlsx'); % findex 8k 2lag
numVars = length(sheetNames);  % Número de variables

% Leer la primera hoja como celda para obtener etiquetas de tiempo reales
raw = readcell('Resp. findex 10k 4lag.xlsx', 'Sheet', sheetNames{1});
timeLabels = raw(1, 2:end);           % Encabezado (fechas como texto: '2003Q2', etc.)
horizons = cell2mat(raw(2:end,1));    % Columna de horizonte (números)

H = length(horizons);
T = length(timeLabels);

% Crear malla (Tiempo en X, Horizonte en Y)
[Tgrid, Hgrid] = meshgrid(1:T, horizons);

% Leer y almacenar todas las IRFs
IRFs = zeros(H, T, numVars);
for i = 1:numVars
    data = readmatrix('Resp. findex 10k 4lag.xlsx', 'Sheet', sheetNames{i});
    IRFs(:,:,i) = data(:,2:end);  % Solo los valores (sin columna de horizonte)
end

% Graficar cada IRF
for i = 1:numVars
    figure;
    surf(Tgrid, Hgrid, flipud(IRFs(:,:,i))); % Tiempo en X, Horizonte en Y
    
    yticks_filtered = 0:5:max(horizons);  % Asume que horizons va de 0 a 20

    % Invertir el orden para que coincida con flipud
    yticks(yticks_filtered);
    yticklabels(string(flipud(yticks_filtered(:))));

    % Hacer las etiquetas horizontales
    set(gca, 'TickLabelInterpreter','none', 'YTickLabelRotation', 0);
    set(gca, 'FontSize', 30);  % Puedes usar 16 o 18 si lo quieres aún más grande

    % Definir ticks más espaciados en el eje Z (respuesta de las IRFs)
    zmin = floor(min(IRFs(:,:,i), [], 'all')*10)/10;  % redondear hacia abajo
    zmax = ceil(max(IRFs(:,:,i), [], 'all')*10)/10;   % redondear hacia arriba

    interval_z = 0.1;  % Puedes ajustar: 0.1, 0.2, etc., para espaciar más
    zticks(zmin:interval_z:zmax);
    shading interp;

    % Quitar barra de color
    colorbar off;

    % Quitar títulos
    xlabel('');
    ylabel('');
    zlabel('');
    title('');

    % Mostrar solo etiquetas de tiempo cada 12 trimestres (~3 años)
    interval = 20;
    shown_ticks = 1:interval:T;
    xticks(shown_ticks);
    xticklabels(extractBetween(timeLabels(shown_ticks), 1, 4));
    % xtickangle(45);  % Opcional: rotar etiquetas
    
    % outputDir = fullfile(pwd, '4K');  % Carpeta 4k
    % outputDir = fullfile(pwd, '8K_1lag');  % Carpeta 8k 1 lag
    % outputDir = fullfile(pwd, '8K_2lag');  % Carpeta 4k
    outputDir = fullfile(pwd, '10k');  % Carpeta 4k

    % if ~exist(outputDir, 'dir')  % Verificar si la carpeta existe
    %     mkdir(outputDir);  % Crear la carpeta si no existe
    % end
    % filename_out = fullfile(outputDir, [sheetNames{i} '.png']);  % Ruta completa del archivo
    % exportgraphics(gcf, filename_out, 'Resolution', 300);
end
