% Leer nombres de las hojas
clear;clc;
[~, sheetNames] = xlsfinfo('Profundidad.xlsx');
numVars = length(sheetNames);  % Número de variables

% Leer la primera hoja como celda para obtener etiquetas de tiempo reales
raw = readcell('Profundidad.xlsx', 'Sheet', sheetNames{1});
timeLabels = raw(1, 2:end);           % Encabezado (fechas como texto: '2003Q2', etc.)
horizons = cell2mat(raw(2:end,1));    % Columna de horizonte (números)

H = length(horizons);
T = length(timeLabels);

% Crear malla (Tiempo en X, Horizonte en Y)
[Tgrid, Hgrid] = meshgrid(1:T, horizons);

% Leer y almacenar todas las IRFs
IRFs = zeros(H, T, numVars);
for i = 1:numVars
    data = readmatrix('Profundidad.xlsx', 'Sheet', sheetNames{i});
    IRFs(:,:,i) = data(:,2:end);  % Solo los valores (sin columna de horizonte)
end

% Graficar cada IRF
for i = 1:numVars
    figure;
    surf(Tgrid, Hgrid, IRFs(:,:,i));  % Tiempo en X, Horizonte en Y
    set(gca, 'FontSize', 18);  % Puedes usar 16 o 18 si lo quieres aún más grande

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
    
    filename_out = [sheetNames{i} '.png'];
    exportgraphics(gcf, filename_out, 'Resolution', 300);
end