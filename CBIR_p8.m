close all
clear all
warning off all
clc

%cargamos las imagenes ya guardadas de la practica anterior (imagenes ya clasificadas
%"color_labeled_images", "Objetos_Imagen", "num_objects"
load("ImagenesClasificadas.mat");

%los datos en Objetos_Imagen estan organizados en una matriz de no_imagen x 5:
% Rodanas | Colas de pato | Armellas |Tornillos | Llaves

%leemos las imagenes
folder_path1 = 'C:\Users\Susan\OneDrive\Documentos\MATLAB\VISION\Fotos';
file_list = dir(fullfile(folder_path1, '*.bmp')); % Selecciona solo los archivos .bmp


% Permitir que el usuario seleccione una imagen desde un archivo
[filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp;*.gif', 'Archivos de imagen (*.jpg, *.png, *.bmp, *.gif)'}, 'Selecciona una imagen');

% Comprobar si el usuario canceló la selección
if isequal(filename, 0) || isequal(pathname, 0)
    disp('Selección de imagen cancelada.');
else
    % Construir la ruta completa al archivo seleccionado
    selectedImagePath = fullfile(pathname, filename);

    % Leer la imagen seleccionada
    selectedImage = imread(selectedImagePath);

    % Mostrar la imagen en una nueva figura
    %figure;
    %imshow(selectedImage);
    %title('Imagen Seleccionada');
end

gray_image = im2gray(selectedImage); % Convierte la imagen a escala de grises 
binary_image1 = imbinarize(gray_image); % Binariza la imagen en escala de grises
min_object_size = 1; % Define el tamaño mínimo del objeto para mantener
binary_image2 = bwareaopen(binary_image1, min_object_size);
se = strel('disk', 3); % Elemento estructurante para la dilatación
binary_image = imdilate(binary_image2, se); % Aplica operación de dilatación
ban = 1;

%%%%%%%%%%%%%%%%% SE PROCESA LA IMAGEN SI ES DE UN CONJUNTO DIFERENTE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Suponiendo que tienes una imagen binaria llamada 'binary_image'
esFondoBlanco = binary_image(1, 1) == 1;

% Si el fondo es blanco, invertir toda la imagen y mostrarla
if esFondoBlanco
    % Invertir la imagen binaria
    ban = 0;
    imagenInvertida = 1 - binary_image;           
    min_object_size = 100; % Define el tamaño mínimo del objeto para mantener
    imagenInvertida = bwareaopen(imagenInvertida, min_object_size);
    se = strel('disk', 7); % Elemento estructurante para la dilatación
    imagenInvertida = imdilate(imagenInvertida, se); % Aplica operación de dilatación
    imagenConsulta = imagenInvertida;
else
    imagenConsulta = binary_image;
end

%imshow(imagenConsulta)

%%%%%%%%%%%%%%%%%%% CARACTERISTICAS DE LA IMAGEN DE CONSULTA %%%%%%%%%%%
% Etiqueta los objetos en la imagen binaria utilizando el algoritmo Flood-Fill
labeled_image = zeros(size(binary_image)); % Crea una matriz de etiquetas inicializada en cero
label = 1; % Inicializa la etiqueta en 1
for x = 1:size(imagenConsulta, 1)
    for y = 1:size(binary_image, 2)
        if imagenConsulta(x, y) == 1 && labeled_image(x, y) == 0 % Si el píxel es blanco y no ha sido etiquetado
            labeled_image = flood_fill(x, y, imagenConsulta, labeled_image, label); % Etiqueta el objeto utilizando Flood-Fill
            label = label + 1; % Incrementa la etiqueta
        end
    end
end

num_objects_consulta = label - 1; % Almacena el número de objetos en la imagen       
Objetos_Imagen_Consulta = zeros(1,5);
colors = zeros(num_objects_consulta, 3);
%Etiquetar objetos en la imagen por lo que son
Aux_Etiqueta = zeros(10);
% Muestra el número de objetos encontrados
%fprintf('La imagen tiene %d objetos.\n', num_objects_consulta);

 propiedades = regionprops(labeled_image, 'Circularity', 'Solidity');
%se inician los contadores de obtejos
No_Rondana = 0;
No_LLave = 0;
No_Tornillo = 0;
No_Armella = 0;
No_Zapatas = 0;

for j = 1:length(propiedades)    
    Circularidad = propiedades(j).Circularity;
    Solidity = propiedades(j).Solidity;
    %%%%%%%%%%%%%%%%%%%%%%%%%% CLASIFICACION  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if Circularidad >= 0.95
        No_Rondana = No_Rondana + 1;                        
        Aux_Etiqueta(j)= 1;
    elseif Circularidad <= 0.26 && Solidity > 0.50 && Solidity < 0.6
        No_LLave = No_LLave + 1;     
        Aux_Etiqueta(j)= 5;
    elseif Circularidad > 0.7 && Circularidad < 0.75 || Solidity > 0.85 && Solidity < 0.9
        No_Zapatas = No_Zapatas + 1;       
        Aux_Etiqueta(j)= 2;
    elseif Circularidad > 0.35 && Circularidad < 0.45 || Solidity > 0.40 && Solidity < 0.5
        No_Armella = No_Armella + 1;        
        Aux_Etiqueta(j)= 3;
    elseif Circularidad > 0.50 && Circularidad < 0.56 || Solidity > 0.8 && Solidity < 0.85
        No_Tornillo = No_Tornillo + 1;       
        Aux_Etiqueta(j)= 4;
    end

end
%fprintf('\tRondanas: %d\n \tZapatas: %d\n \tArmellas: %d \n \tTornillos: %d \n \tLlaves: %d \n',No_Rondana, No_Zapatas, No_Armella, No_Tornillo, No_LLave);
Objetos_Imagen_Consulta (1)= No_Rondana;
Objetos_Imagen_Consulta (2)= No_Zapatas;
Objetos_Imagen_Consulta (3)= No_Armella;
Objetos_Imagen_Consulta (4)= No_Tornillo;
Objetos_Imagen_Consulta (5)= No_LLave;
%pause(1)

% Etiqueta cada objeto con un color diferente según su tipo
for j = 1:num_objects_consulta
    if Aux_Etiqueta(j) == 1 % Rondana
        colors(j, :) = [1, 0, 0]; % Rojo
    elseif Aux_Etiqueta(j) == 2 % zapata
        colors(j, :) = [0, 1, 0]; % Verde
    elseif Aux_Etiqueta(j) == 3 % Armella
        colors(j, :) = [0, 0, 1]; 
    elseif Aux_Etiqueta(j) == 4 % Tornillo
        colors(j, :) = [1, 0, 1]; 
    elseif Aux_Etiqueta(j) == 5 % Llave
        colors(j, :) = [0, 1, 1]; 
    end
end
 % Etiqueta cada objeto con un color diferente
color_labeled_image = label2rgb(labeled_image, colors, 'k');
% Muestra la imagen etiquetada
%imshow(color_labeled_image);

%%%%%%%%%%%%%%%%%%%%% CBIR %%%%%%%%%%%%%%%%%%%%%%%%%
filasDatosEnUnaColumna = [20,1];

% Encuentra las columnas que no tienen valores nulos
columnasNoNulas = find(Objetos_Imagen_Consulta ~= 0)
k=0;
for i=1: length(num_objects)
    for j=1 : length(columnasNoNulas)
        if Objetos_Imagen(i, columnasNoNulas(j)) ~= 0
            k = k +1;
            filasDatosEnUnaColumna(k) = i;
        end
    end    
end
% Verifica si hay al menos una fila con datos en las mismas columnas
if ~isempty(filasDatosEnUnaColumna) && ban ==0
    % Inicializa la variable para almacenar las distancias euclidianas
    distanciasEuclidianas = zeros(size(filasDatosEnUnaColumna));

    % Calcula la distancia euclidiana entre cada fila seleccionada y Objetos_Imagen_Consulta
    for j = 1:length(filasDatosEnUnaColumna)
        filaActual = filasDatosEnUnaColumna(j);
        distanciasEuclidianas(j) = sqrt(sum((Objetos_Imagen(filaActual, :) - Objetos_Imagen_Consulta).^2));
    end

    % Encuentra la fila con la menor distancia euclidiana
    [~, indiceFilaMinima] = min(distanciasEuclidianas);

    % Muestra el resultado
    fprintf('La fila con la menor distancia euclidiana es la fila %d con distancia %.4f\n', filasDatosEnUnaColumna(indiceFilaMinima), distanciasEuclidianas(indiceFilaMinima));
    indiceFilaMinima1= filasDatosEnUnaColumna(indiceFilaMinima);

elseif ban == 1
    % Encuentra la fila exactamente igual a Objetos_Imagen_Consulta
    indiceFilaMinima1 = find(arrayfun(@(row) isequal(Objetos_Imagen(row, :), Objetos_Imagen_Consulta), 1:size(Objetos_Imagen, 1)))
else
    disp('No hay resultados de la busqueda.');
end

% Mostrar ambas imágenes en una figura
file_name = file_list(indiceFilaMinima1).name;
file_path = fullfile(folder_path1, file_name);
image = imread(file_path);

figure;
subplot(1, 2, 1);
imshow(selectedImage);
title('Imagen Seleccionada');

subplot(1, 2, 2);
imshow(image);
title('Resultado busqueda');


function [labeled_image, updated_label] = flood_fill(x, y, binary_image, labeled_image, label)
    % Etiqueta el píxel actual
    labeled_image(x, y) = label;

    % Define las posibles posiciones de los píxeles adyacentes
    positions = [-1, 0; 0, -1; 0, 1; 1, 0];

    % Recorre las posiciones adyacentes al píxel actual
    for i = 1:size(positions, 1)
        x_new = x + positions(i, 1);
        y_new = y + positions(i, 2);
        % Comprueba si la nueva posición está dentro de los límites de la imagen
        if x_new >= 1 && x_new <= size(binary_image, 1) && y_new >= 1 && y_new <= size(binary_image, 2)
            % Comprueba si el píxel adyacente es blanco y no ha sido etiquetado
            if binary_image(x_new, y_new) == 1 && labeled_image(x_new, y_new) == 0
                % Etiqueta el píxel adyacente y los píxeles adyacentes a este
                [labeled_image, updated_label] = flood_fill(x_new, y_new, binary_image, labeled_image, label);
            end
        end
    end

    % Devuelve la imagen etiquetada y la etiqueta actualizada
    updated_label = label + 1;
end


