clc
close all
clear all
warning off all

puntosClase1=[
    0,0,0;
    1,0,0;
    1,0,1;
    1,1,0];
puntosClase2=[
    0,0,1;
    0,1,1;
    1,1,1;
    0,1,0];

%figure(1)
%scatter3(puntosClase1(:,1),puntosClase1(:,2),puntosClase1(:,3), 'filled', 'm');
%grid on
%hold on
%scatter3(puntosClase2(:,1),puntosClase2(:,2),puntosClase2(:,3), 'filled', 'c');
%hold on

w=zeros(4,1);

disp('introduzca los valores de los pesos')
w(1) = input('Ingrese el valor de w1: ');
w(2) = input('Ingrese el valor de w2: ');
w(3) = input('Ingrese el valor de w3: ');
w(4) = input('Ingrese el valor de w4: ');


errores=1;
while errores==1
    errores=0;
    for i=1:1:4
        vector=cat(2,puntosClase1(i,:),1)
        fsal=vector*w
        if fsal>=0
            w=w-vector'
            errores=1;
        end
    end
    for i=1:1:4
        vector=cat(2,puntosClase2(i,:),1)
        fsal=vector*w
        if fsal<=0
            w=w+vector'
            errores=1;
        end
    end
end

w

% Calcula los coeficientes del plano a partir de w
a = w(1);
b = w(2);
c = w(3);
d = w(4);

% Crea una malla de puntos para el plano
[x, y] = meshgrid(-1:0.1:2, -1:0.1:2);

% Calcula la ecuación del plano
z = (-a * x - b * y - d) / c;

% Crea una nueva figura para el plano
figure(1);

% Grafica el plano
surf(x, y, z, 'FaceAlpha', 0.5);
hold on;

% Grafica los puntos de las dos clases
scatter3(puntosClase1(:,1), puntosClase1(:,2), puntosClase1(:,3), 'filled', 'm');
scatter3(puntosClase2(:,1), puntosClase2(:,2), puntosClase2(:,3), 'filled', 'c');

grid on;
xlabel('X');
ylabel('Y');
zlabel('Z');
legend('Plano de separación', 'Clase 1', 'Clase 2');
title('Plano de Separación');


























