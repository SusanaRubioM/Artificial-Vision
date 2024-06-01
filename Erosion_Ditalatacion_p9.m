clc
close all
clear all
% Obtener la lista de archivos en la carpeta
carpeta = 'C:/Users/Susan/OneDrive/Documentos/MATLAB/VISION/Fotos';
[filename, pathname] = uigetfile({'.jpg;.png;.bmp;.gif;.jpeg', 'Archivos de imagen (.jpg, .png, *.bmp, *.gif,.jpeg)'}, 'Selecciona una imagen');
% Verificar si hay imágenes en la carpeta
if isempty(filename)
    error('No se seleccionó ninguna imagen.');
end
% Leer la imagen seleccionada
I = imread(fullfile(pathname, filename));
% Check if the image is RGB and convert to grayscale if necessary
if size(I, 3) == 3
    I = rgb2gray(I);
end
% Elección del tipo de elemento estructurante
disp('Seleccione el tipo de elemento estructurante:');
disp('1. Cuadrado');
disp('2. Octágono');
disp('3. Diamante');
disp('4. Rectángulo');
opcion = input('Ingrese el número correspondiente al tipo de elemento estructurante: ');
switch opcion
    case 1
        se = strel('square', 20); % Cuadrado de 20x20
    case 2
        se = strel('octagon', 15); % Octágono de radio 15
    case 3
        se = strel('diamond',12); % Diamante de radio 12
    case 4
        se = strel('rectangle', [12,3]); % Rectangulo de 12 x 3
    otherwise
        error('Opción no válida.');
end
%%% OPERACIONES MORFOLÓGICAS %%%
% EROSIÓN
E = imerode(I, se);
% DILATACIÓN
D = imdilate(I, se);
figure,
    subplot(2,3,2), imshow(I),  title('Original')
    subplot(1,3,1), imshow(E),  title('Erosión')
    subplot(1,3,3), imshow(D),  title('Dilatación')