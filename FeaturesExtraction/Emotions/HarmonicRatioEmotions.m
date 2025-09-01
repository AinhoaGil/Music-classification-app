% 1. Definir la ruta de la carpeta de audio y el CSV
baseDir = 'C:\Users\Ainho\OneDrive\Escritorio\TFG\Matlab\Tools\AudioToolbox\Dataset\Osfstorage-emotions'; % Ruta de los audios
csvFile = fullfile(baseDir, 'mean_ratings_set2.csv'); % Ruta del CSV
audioDir = fullfile(baseDir, 'Set2', 'set2');

% 2. Leer el archivo CSV
dataTable = readtable(csvFile);

% 3. Inicializar variables para almacenar características y etiquetas
data = [];       % Para almacenar las características MFCC
labels = {};     % Para almacenar las etiquetas (emociones)

% % Crear figura para graficar
% figure('Name', ['Audio - ', fileNameCompleted, ' | Emoción: ', emotion], ...
%     'Position', get(0, 'ScreenSize'));  % Maximiza la ventana

% 4. Procesar cada archivo de audio
for i = 1:height(dataTable)
    % Obtener el nombre del archivo y la etiqueta
    fileName = sprintf('%03d.mp3', dataTable.Number(i)); % Nombre como 001.mp3, 002.mp3, etc.
    fileNameCompleted = dataTable.soundtrack{i}; % Nombre del archivo de audio
    emotion = dataTable.TARGET{i}; % Emoción correspondiente

    filePath = fullfile(audioDir, fileName); % Ruta completa al archivo
    
    if isfile(filePath)
        % Leer el archivo de audio
        [audioData, fs] = audioread(filePath);
        disp(['Procesando archivo: ', fileName, ' - Emoción: ', emotion]);

        %Reproducir el archivo de audio
%         soundsc(audioData, fs); % Reproduce el audio

        % Convertir a mono
        audioData = mean(audioData, 2);

        % EXTRAER EL Harmonic Ratio
        hrValues = harmonicRatio(audioData,fs, ...
                   Window=hann(round(fs.*0.05),"periodic"), ...  % Ventana de 50 ms
                   OverlapLength=round(fs.*0.025));              % Superposición del 90%

            % Calcular el valor promedio, la desviación estándar, el valor máximo y el valor mínimo del HR
            HRmean = mean(hrValues);  % Promedio
            HRstd = std(hrValues);    % Desviación estándar
            HRmax = max(hrValues);    % Valor máximo
            HRmin = min(hrValues);    % Valor mínimo

             % Guardar las características y la etiqueta
            featureMeans = [HRmean, HRstd, HRmax, HRmin]; % Guardar las características estadísticas

            % Guardar las características y la etiqueta
            data = [data;  featureMeans]; % Agregar los coeficientes seleccionados al dataset
            labels = [labels; dataTable.TARGET{i}]; % Añadir la etiqueta correspondiente (emocion)

%         %GRAFICAR
            % Definir el tiempo para el gráfico
                T = 1/fs;
                t = 0:T:(length(audioData)*T) - T;


%             clf(hFig); % Limpiar la figura antes de cada nuevo plot
% 
  
    %         % Graficar la señal de audio en el tiempo
    %         subplot(2, 1, 1);
    %         plot(t, audioData);
    %         axis tight;
    %         xlabel('Tiempo (s)');
    %         ylabel('Amplitud');
    %         title(['Audio: ', fileNameCompleted, ' | Emoción: ', emotion]);
%             grid on;
% 
%             % Graficar los valores del HR
%             subplot(2, 1, 2);
%             plot(hrValues);
%             xlabel('Tiempo (s)');
%             ylabel('Harmonic Ratio');
%             title('Harmonic Ratio');
%             grid on;

         % Pausar para visualizar los gráficos y permitir la reproducción
%         pause(length(audioData) / fs + 2); % Pausa para la duración del audio + 2 segundos adicionales

    else
        disp(['Archivo no encontrado: ', fileName]);
    end
end
%% 
% 5. Crear una tabla con las características y las etiquetas
featureNames = {'HRmean', 'HRstd', 'HRmax', 'HRmin'};
HRTable = array2table(data, 'VariableNames', featureNames);
HRTable.Genre = labels;

%% 
% 6. Guardar la tabla para usarla en clasificadores
% Definir la ruta completa al directorio
targetDir = 'C:\Users\Ainho\OneDrive\Escritorio\TFG\Matlab\Tools\AudioToolbox\Features\FeaturesExtration\Emotions'; 

% Guardar el archivo .mat en el directorio especificado
save(fullfile(targetDir, 'HRTableEmotions.mat'), 'HRTable');

disp('Características extraídas y almacenadas.');