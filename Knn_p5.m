close all
clear all
clc
warning off all

rutaSeleccion = 'C:\Users\Susan\OneDrive\Documentos\MATLAB\VISION'; %especificamos la ruta de las imagenes
%muestra un cuadro de dialogo
[imagen, ruta] = uigetfile({'*.jpg;*.png;*.bmp', 'Archivos de imagen (*.jpg, *.png, *.bmp)'}, 'Selecciona una imagen', rutaSeleccion);

colores = {'yellow', 'magenta', 'green', 'red', 'cyan', 'blue'};

NoClases = input("Ingresa el numero de clases: ");
Representantes = input("Ingresa el numero de representantes por clase: ");
Dispersion = input("¿Cuanta dispersión requieres en los puntos de la clase?: ");
msgbox("Da click en la pantalla para seleccionar los centros de cada clase", "non-modal");
figure(1)
imshow(imagen)
hold on

% Almacenamos las coordenadas de los centros de cada clase en una matriz
[x, y] = ginput(NoClases);

x_representantes = cell(1, NoClases);
y_representantes = cell(1, NoClases);

for i = 1 : NoClases
    cenX = x(i);
    cenY = y(i);
    
   
    % Generar puntos aleatorios alrededor del centro con la dispersión dada
    x_rand = (rand(1, Representantes) * 2 - 1) * Dispersion + cenX;
    y_rand = (rand(1, Representantes) * 2 - 1) * Dispersion + cenY;
    
    % Asegurarse de que las coordenadas generadas estén dentro de los límites de la imagen
    x_rand(x_rand < 1) = 1;
    x_rand(x_rand > size(imagen, 2)) = size(imagen, 2);
    y_rand(y_rand < 1) = 1;
    y_rand(y_rand > size(imagen, 1)) = size(imagen, 1);
    
    x_representantes{i} = x_rand;
    y_representantes{i} = y_rand;

    % Plotea los puntos alrededor del centro
    scatter(x_representantes{i}, y_representantes{i}, 'filled', 'MarkerFaceColor', colores{i});
    hold on

end 

% Obtenemos el valor de los pixeles en los puntos
valoresPuntos = cell(1, NoClases);
for i = 1:NoClases
    valoresPuntos{i} = impixel(imagen, x_representantes{i}, y_representantes{i});
end 
valoresCentros = impixel(imagen, x, y);

NoIteraciones = 20;
PorcentajeEntrenamiento = 0.5;

bandera = 1;
while bandera == 1
    disp("1. Distancia Euclidiana");
    disp("2. Distancia Maharanobi");
    disp("3. Maxima probabilidad");
    metodo = input("Elige un metodo para clasificar los puntos ");
    if metodo == 1
        disp("EUCLIDIANA Cross Validation (20 iteraciones, 50-50):");
        MatrizConfusionCross = CrossValidation (NoIteraciones, valoresPuntos, valoresCentros, NoClases, Representantes, PorcentajeEntrenamiento, @Dist_euclidiana)
        Accuracy = AccuracyF(MatrizConfusionCross)
                
        disp("EUCLIDIANA Resustitución:");    
        MatrizConfusion = Dist_euclidiana(valoresPuntos, valoresCentros, NoClases, Representantes) %restitución
        Accuracy = AccuracyF(MatrizConfusion)
    
        disp("EUCLIDIANA Leave One Out:");
        MatrizConfusionLeaveOneOut = LeaveOneOut(NoIteraciones, valoresPuntos, valoresCentros, NoClases, Representantes, @Dist_euclidiana)
        Accuracy = AccuracyF(MatrizConfusionLeaveOneOut)       
    elseif metodo == 2
        
        disp("MAHARANOBI Cross Validation (20 iteraciones, 50-50):");        
        MatrizConfusionCross = CrossValidation (NoIteraciones, valoresPuntos, valoresCentros, NoClases, Representantes, PorcentajeEntrenamiento, @Dist_maharanobi)
        Accuracy = AccuracyF(MatrizConfusionCross)        
        
        disp("MAHARANOBI Resustitución:");        
        MatrizConfusion = Dist_maharanobi(valoresPuntos, valoresCentros, NoClases, Representantes) %restitución
        Accuracy = AccuracyF(MatrizConfusion)

        disp("MAHARANOBI Leave One Out:");
        MatrizConfusionLeaveOneOut = LeaveOneOut(NoIteraciones, valoresPuntos, valoresCentros, NoClases, Representantes, @Dist_maharanobi)
        Accuracy = AccuracyF(MatrizConfusionLeaveOneOut)
    elseif metodo == 3
        
        disp("MAHARANOBI Cross Validation (20 iteraciones, 50-50):");      
        MatrizConfusionCross = CrossValidation (NoIteraciones, valoresPuntos, valoresCentros, NoClases, Representantes, PorcentajeEntrenamiento, @MaximaProbabilidad)
        Accuracy = AccuracyF(MatrizConfusionCross)

        disp("Resustitución:");        
        MatrizConfusion = MaximaProbabilidad(valoresPuntos, valoresCentros, NoClases, Representantes) %restitución       
        Accuracy = AccuracyF(MatrizConfusion)

        disp("Leave One Out:");
        MatrizConfusionLeaveOneOut = LeaveOneOut(NoIteraciones, valoresPuntos, valoresCentros, NoClases, Representantes, @MaximaProbabilidad)
        Accuracy = AccuracyF(MatrizConfusionLeaveOneOut)

    else 
        disp("Opción no valida");
    end
   
    salir = input("¿Deseas utilizar otro metodo?", 's');
    if strcmp(salir, 'n') %strcmp compara caracteres
        disp("Hasta pronto c:");
        bandera = 0;
    end           
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Distancia Euclidiana %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MatrizConfusionEuclidiana = Dist_euclidiana(valoresPuntos, valoresCentros, NoClases, Representantes)
%craemos una matriz auxiliar para trabajar con los datos y poder acceder de
%forma mas facil
MatrizAuxiliar = zeros(Representantes, 3);  
ClasificacionDistancia = zeros(Representantes, NoClases); %esta matriz guarda la clase a la que pertenece cada punto segun la distancia euclidiana
MatrizConfusionEuclidiana = zeros(NoClases, NoClases);
   %Accedemos a la primera parte de la celda
   for i=1: NoClases
      MatrizAuxiliar = valoresPuntos{i}; %copiamos los valores de la clase i a una matriz auxiliar
      for k=1: Representantes %recorre representante a representante
          DistanciaMin = 0;
          bandera = 0;
          clasePerteneciente = 0;
          for j=1 : NoClases              
              DistanciaMinAux = sqrt((MatrizAuxiliar(k, 1)-valoresCentros(j, 1))^2 +...
                                    (MatrizAuxiliar(k, 2)-valoresCentros(j, 2))^2 + ...
                                    (MatrizAuxiliar(k, 3)-valoresCentros(j, 3))^2);
              if DistanciaMin == 0 && bandera==0 %indica el inicio de las comparaciones
                  DistanciaMin = DistanciaMinAux;
                  clasePerteneciente = j;  % se guarda el valor actualizado de la clase osea la 1ra clase
                  bandera == 1; %bandera = 1 indica que ya no es el inicio
              elseif DistanciaMin > DistanciaMinAux
                  DistanciaMin = DistanciaMinAux; % el valor de la distancia minima se actualiza
                  clasePerteneciente = j; % se guarda el valor actualizado de la clase
              elseif DistanciaMinAux == 0 %si la distancia minima es 0 se actualiza el valor
                  DistanciaMin = DistanciaMinAux;
                  clasePerteneciente = j;
                  break; %sale del ciclo si la distancia es 0 porque es el menor valor
              end
          end 
          ClasificacionDistancia(k, i) = clasePerteneciente;
          MatrizConfusionEuclidiana(i,clasePerteneciente)= MatrizConfusionEuclidiana(i,clasePerteneciente)+1;
      end
   end
%ClasificacionDistancia %muestra la matriz con las clases correspondientes
%MatrizConfusionEuclidiana %matriz de confusion
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Maharanobi %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%se va a recibir la matriz con todas las clases, el vector que se evaluará
%y el número de clases, por lo que solo regresará un arreglo de 1x3, asi
%que se tiene que usar múltiles veces para crear la matriz de confusión
function [mahalanobi, MatrizCovarianza] = Mahalanobi(valoresPuntos, vectorEvaluar, NoClases)
    %se obtienen las medias
    MatricesMedia = cell(1,NoClases);
    for i=1:NoClases
        MatricesMedia{i} = mean(valoresPuntos{i});
    end
    %vectores - media
    XmenosM = cell(1,NoClases);
    for i=1:NoClases
        XmenosM{i} = vectorEvaluar - MatricesMedia{i};
    end
    %transpuesta
    Xtrans = cell(1,NoClases);
    for i=1:NoClases
         aux = XmenosM{i};
         Xtrans{i} = aux';
    end
    %matriz de covarianza, junto con la inversa
    MatrizCovarianza = cell(1, NoClases);
    MatrizCovInv = cell(1, NoClases);
    for i=1:NoClases
        aux = valoresPuntos{i};
        a = cov(aux);
        MatrizCovarianza{i} = a;
        b = pinv(a);
        MatrizCovInv{i} = b;
    end
    %calculo de mahalanobi
    mahalanobi = cell(1, NoClases);
    for i=1:NoClases
        mahalanobi{i} = sqrt(XmenosM{i} * MatrizCovInv{i} * Xtrans{i});
    end
end

%función para obtener la matriz de confusión
function MatrizConfusionMaharanobi = Dist_maharanobi(valoresPuntos, valoresCentros, NoClases, Representantes);
    %matriz de confusión
    MatrizConfusionMaharanobi = zeros(NoClases, NoClases);
    for i=1:NoClases
        puntoclase = valoresPuntos{i};
        for j=1:Representantes
            %distancia mahalanobi a cada clase
            [mahalanobi, MatrizCovarianza] = Mahalanobi(valoresPuntos, puntoclase(j,:), NoClases);
            indice_minimo=0;
            valor_minimo=Inf;
            for k=1:NoClases
                if mahalanobi{k}<valor_minimo
                    valor_minimo=mahalanobi{k};
                    indice_minimo=k;
                end
            end
            MatrizConfusionMaharanobi(i, indice_minimo)=(MatrizConfusionMaharanobi(i, indice_minimo)+1 );
        end
    end
    %MatrizConfusionMaharanobi
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Maxima Probabilidad %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function MatrizConfusionMaximaProbabilidad = MaximaProbabilidad(valoresPuntos, valoresCentros, NoClases, Representantes)
    MatrizConfusionMaximaProbabilidad = zeros(NoClases, NoClases);

    for i = 1:NoClases
        for j = 1:Representantes
            Distancias = zeros(1, NoClases);

            for k = 1:NoClases
                Distancias(k) = norm(valoresPuntos{i}(j, :) - valoresCentros(k, :));
            end

            [~, clasePerteneciente] = min(Distancias);
            MatrizConfusionMaximaProbabilidad(i, clasePerteneciente) = MatrizConfusionMaximaProbabilidad(i, clasePerteneciente) + 1;
            
            % Llamada a la función MaximaProbabilidad
            %MatrizConfusionMaximaProbabilidad = MaximaProbabilidad(valoresPuntos, valoresCentros, NoClases, Representantes);
        end
    end
    %MatrizConfusionMaximaProbabilidad
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Accuracy %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Accuracy = AccuracyF (matrizConfusion);
    [rows, cols] = size(matrizConfusion);
    Total_Predicciones = 0;
    prediccionesCorrectas=0;
    for i=1 : rows
        for j = 1: cols
            contador = matrizConfusion(i, j);
            Total_Predicciones = Total_Predicciones + contador;
            if i==j
                prediccionesCorrectas = prediccionesCorrectas + matrizConfusion(i, j);
            end
        end
    end
    Accuracy = prediccionesCorrectas / Total_Predicciones;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Cross validation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%
function MatrizConfusionCross = CrossValidation(NoIteraciones, valoresPuntos, valoresCentros, NoClases, Representantes, porcentajeEntrenamiento, funcion)
    porcentajePrueba = 1 - porcentajeEntrenamiento;
    n = round(Representantes * porcentajeEntrenamiento); % Redondeamos el número de representantes para entrenamiento
    nuevosValoresPuntos = cell(n, NoClases); % Inicializamos la matriz de nuevos valores
    promedioMatrices = zeros(NoClases, NoClases);

    for i = 1:NoIteraciones
        for k = 1:NoClases
            MatrizAuxiliar = valoresPuntos{k}; % Obtener la matriz auxiliar correspondiente a la iteración i
            indicesAleatorios = randi(Representantes, 1, n); % Generar índices aleatorios para seleccionar filas
            
            % Guardar las filas seleccionadas en nuevosValoresPuntos
            nuevosValoresPuntos{k} = MatrizAuxiliar(indicesAleatorios, :);
        end
        MatrizConfusionAux = funcion(nuevosValoresPuntos, valoresCentros, NoClases, n); % Llama a la función para sacar la matriz de confusión con los nuevos valores aleatorios
        promedioMatrices = MatrizConfusionAux + promedioMatrices;
    end
    MatrizConfusionCross = round(promedioMatrices / NoIteraciones);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Leave One Out %%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MatrizConfusionLeaveOneOut = LeaveOneOut(NoIteraciones, valoresPuntos, valoresCentros, NoClases, Representantes, funcion)
    MatrizConfusionLeaveOneOut = zeros(NoClases, NoClases);
    promedioMatrices = zeros(NoClases, NoClases);
   
        for elemento = 1:Representantes
            nuevosValoresPuntos = cell(1, NoClases);
            for k = 1:NoClases
                MatrizAuxiliar = valoresPuntos{k}; % Obtener la matriz auxiliar correspondiente a la clase k
                indicesEntrenamiento = setdiff(1:Representantes, elemento); % Deja fuera un elemento
                nuevosValoresPuntos{k} = MatrizAuxiliar(indicesEntrenamiento, :);
            end

            MatrizConfusionAux = funcion(nuevosValoresPuntos, valoresCentros, NoClases, Representantes-1); % Llama a la función para sacar la matriz de confusión con los nuevos valores aleatorios
            promedioMatrices = MatrizConfusionAux + promedioMatrices;
        end
    MatrizConfusionLeaveOneOut=round(promedioMatrices/(Representantes));
    %MatrizConfusionLeaveOneOut = round(MatrizConfusionLeaveOneOut / totalElementos);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% knn %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Knn = KNearestNeighbors(valores,funcion)

end