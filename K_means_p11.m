% Solicitar al usuario que seleccione un archivo de imagen
[file, path] = uigetfile({'*.jpg;*.png;*.bmp', 'Archivos de imagen (*.jpg, *.png, *.bmp)'}, 'Seleccione una imagen');

% Verificar si el usuario canceló la selección
if isequal(file, 0)
    disp('Selección cancelada.');
    return;
end

% Construir la ruta completa del archivo de imagen
fullPath = fullfile(path, file);

% Leer la imagen desde el archivo
imagen = imread(fullPath);

% Obtener el tamaño de la imagen para escalar el gráfico de dispersión
[alto, ancho, ~] = size(imagen);
colores = {'yellow', 'magenta', 'green', 'red', 'cyan', 'blue'};


% Escalar las coordenadas x e y según el tamaño de la imagen
N_puntos = input("Ingresa el número de puntos: ");
N_centros = input("Ingresa la cantidad de centros");

% Generar puntos aleatorios distribuidos en toda la imagen
x = rand(1, N_puntos) * ancho;
y = rand(1, N_puntos) * alto;

% Crear una figura
figure;
imshow(imagen);
hold on
scatter(x, y, "filled");
hold on

% Generar centros aleatorios iniciales
centros_x = rand(1, N_centros) * ancho;
centros_y = rand(1, N_centros) * alto;

scatter(centros_x, centros_y, 100, 'k', 'filled'); % Mostrar los centros iniciales en negro

% Crear una figura
figure;
imshow(imagen);
hold on
scatter(x, y, "filled");
hold on
scatter(centros_x, centros_y, 100, 'k', 'filled'); % Mostrar los centros iniciales en negro

% Obtenemos el valor de los pixeles en los puntos
valoresPuntos = cell(1, NoClases);
for i = 1:NoClases
    valoresPuntos{i} = impixel(imagen, x{i}, y{i});
end 
valoresCentros = impixel(imagen, x, y);

% Número máximo de iteraciones (puedes ajustarlo según sea necesario)
max_iteraciones = 10;

% Colores para cada clase
colores_clases = hsv(N_centros);

for iteracion = 1:max_iteraciones
     % Calcular las distancias euclidianas en el espacio RGB entre cada punto y cada centro
    distancias = zeros(N_puntos, N_centros);
    for k = 1:N_centros
        distancias(:, k) = sqrt(sum((rgb_puntos - rgb_centros(k, :)).^2, 2));
    end
    % Asignar cada punto al centro más cercano
    [~, asignaciones] = min(distancias, [], 2);
    
    % Actualizar los centros como el promedio de los puntos asignados
    for i = 1:N_centros
        puntos_asignados = find(asignaciones == i);
        if ~isempty(puntos_asignados)
            centros_x(i) = sum(x(puntos_asignados)) / length(puntos_asignados);
            centros_y(i) = sum(y(puntos_asignados)) / length(puntos_asignados);
        else
            % No hay puntos asignados, mantener el centro actual
        end
    end
    
    % Actualizar el gráfico
    clf; % Borrar el gráfico anterior
    imshow(imagen);
    hold on
    
    % Mostrar los puntos con colores según su clase
    for i = 1:N_centros
        puntos_asignados = find(asignaciones == i);
        scatter(x(puntos_asignados), y(puntos_asignados), 50, colores_clases(i, :), "filled");
        hold on
        scatter(centros_x(i), centros_y(i), 100, 'k', 'filled'); % Mostrar los centros actualizados en negro
    end
    
    pause(1); % Pausa para visualizar cada iteración
end

