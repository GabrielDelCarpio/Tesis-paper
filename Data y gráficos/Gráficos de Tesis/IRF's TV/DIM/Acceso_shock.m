% Leer nombres de las hojas
clear; clc;
pwd = "C:\Users\gabri\OneDrive\Desktop\Cato\Tesis\Tesis-paper\Data y gráficos\Gráficos de Tesis\IRF's TV\DIM"

[~, sheetNames] = xlsfinfo('Acceso 10k 4lag.xlsx');  % Nombre del archivo
numVars = length(sheetNames);  % Número de variables

% Leer etiquetas de tiempo y horizontes desde la primera hoja
raw = readcell('Acceso 10k 4lag.xlsx', 'Sheet', sheetNames{1});
timeLabels = raw(1, 2:end);           % Encabezados de columnas: fechas ('2003Q2', etc.)
horizons = cell2mat(raw(2:end,1));    % Primera columna: horizonte (0, 1, ..., 20)

H = length(horizons);
T = length(timeLabels);

% Crear una malla invertida del eje Y para que empiece en 0 y suba a 20
[Tgrid, Hgrid] = meshgrid(1:T, horizons); % Malla invertida

% Leer IRFs y voltear en la dimensión de los horizontes
IRFs = zeros(H, T, numVars);
for i = 1:numVars
    data = readmatrix('Acceso 10k 4lag.xlsx', 'Sheet', sheetNames{i});
    IRFs(:,:,i) = data(:,2:end);  % Voltear verticalmente al leer
end

% Graficar
for i = 1:numVars
    figure;
    surf(Tgrid, Hgrid, flipud(IRFs(:,:,i))); % Tiempo en X, Horizonte en Y
    
    yticks_filtered = 0:5:max(horizons);  % Asume que horizons va de 0 a 20

    % Invertir el orden para que coincida con flipud
    yticks(yticks_filtered);
    yticklabels(string(flipud(yticks_filtered(:))));

    % Hacer las etiquetas horizontales
    set(gca, 'TickLabelInterpreter','none', 'YTickLabelRotation', 0);
    set(gca, 'FontSize', 30); % Puedes usar 16 o 18 si lo quieres aún más grande

    % Definir ticks más espaciados en el eje Z (respuesta de las IRFs)
    zmin = floor(min(IRFs(:,:,i), [], 'all')*10)/10;
    zmax = ceil(max(IRFs(:,:,i), [], 'all')*10)/10;
    
    interval_z = 0.1; % Puedes ajustar: 0.1, 0.2, etc., para espaciar más
    zticks(zmin:0.1:zmax);
    shading interp;

    % Quitar barra de color
    colorbar off;

    % Quitar títulos
    xlabel('');
    ylabel('');
    zlabel('');
    title('');

    % Etiquetas de tiempo cada 20 trimestres
    interval = 20;
    shown_ticks = 1:interval:T;
    xticks(shown_ticks);
    xticklabels(extractBetween(timeLabels(shown_ticks), 1, 4));

    % Exportar si se desea
    % outputDir = fullfile(pwd, '4K');  % Carpeta 4k
    % outputDir = fullfile(pwd, '8K_1lag');  % Carpeta 8k 1 lag
    % outputDir = fullfile(pwd, '8K_2lag');  % Carpeta 8k 2 lag
    outputDir = fullfile(pwd, '10k'); % Carpeta 8k 4 lag
     
    filename_out = fullfile(outputDir, [sheetNames{i} '.png']);
    exportgraphics(gcf, filename_out, 'Resolution', 300);
end


