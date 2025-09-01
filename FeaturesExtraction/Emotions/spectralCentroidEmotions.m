% 1. Definir la ruta de la carpeta de audio y el CSV
baseDir = 'C:\Users\Ainho\OneDrive\Escritorio\TFG\Matlab\Tools\TFG_Ainhoa_AudioToolbox\Dataset\Osfstorage-emotions'; % Ruta de los audios
csvFile = fullfile(baseDir, 'mean_ratings_set2.csv'); % Ruta del CSV
audioDir = fullfile(baseDir, 'Set2', 'set2');

% 2. Leer el archivo CSV
dataTable = readtable(csvFile);

% 3. Inicializar variables para almacenar características y etiquetas
data = [];       % Para almacenar las características MFCC
labels = {};     % Para almacenar las etiquetas (emociones)

% Definir índices de las bandas seleccionadas
numCoeffs = 14; % Número de coeficientes seleccionados
selectedBands = round(linspace(1, 64, numCoeffs)); % Índices uniformemente distribuidos entre las bandas


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

        centroidVals = spectralCentroid(audioData, fs);

        %Obtenemos en total 2992 coeffs, para simplificarlos calculamos varias estadísticas 
        % (promedio, desviación estándar, mínimo y máximo) para representar mejor la variabilidad 
        % y la distribución de esta característica a lo largo del tiempo. 
        % Esto permite capturar más detalles sobre cómo cambia el contenido espectral del audio, 
        % lo que puede mejorar el rendimiento de los clasificadores al proporcionar información 
        % más rica.
        centroidMean = mean(centroidVals);
        centroidStd = std(centroidVals);
        centroidMin = min(centroidVals);
        centroidMax = max(centroidVals);

        % Guardar las características y la etiqueta
        featureMeans = [centroidMean, centroidStd, centroidMin, centroidMax]; % Guardar las características estadísticas

        % Guardar las características y la etiqueta
        data = [data;  featureMeans]; % Agregar los coeficientes seleccionados al dataset
        labels = [labels; dataTable.TARGET{i}]; % Añadir la etiqueta correspondiente (emocion)

        %GRAFICAR
%          % Crear figura para graficar
%         figure('Name', ['Audio - ', fileNameCompleted, ' | Emoción: ', emotion], ...
%             'Position', get(0, 'ScreenSize'));
% 
%         % Definir el tiempo para el gráfico
%         T = 1/fs;
%         t = 0:T:(length(audioData)*T) - T;
%         
%         % Graficar la señal de audio en el tiempo
%         subplot(2, 1, 1);
%         plot(t, audioData);
%         axis tight;
%         xlabel('Tiempo (s)');
%         ylabel('Amplitud');
%         title(['Audio: ', fileNameCompleted, ' | Emoción: ', emotion]);
%        grid on;

%         subplot(2, 1, 2);   ----> Cambiar para representacion grafica del
%         SpectralCentroid
%         imagesc(coeffs'); %mel spectrogram
%         axis tight;
%         xlabel('Tiempo (frames)');
%         ylabel('Coeficientes Mel Spectrogram');
%         title('Mel Spectrogram');
%         colorbar;
%         grid on;

         % Pausar para visualizar los gráficos y permitir la reproducción
%         pause(length(audioData) / fs + 2); % Pausa para la duración del audio + 2 segundos adicionales

    else
        disp(['Archivo no encontrado: ', fileName]);
    end
end
%% 
% 5.  Crear una tabla con las características seleccionadas y etiquetas
featureNames = {'centroidMean', 'centroidStd', 'centroidMin', 'centroidMax'};
specCTable = array2table(data, 'VariableNames', featureNames);
specCTable.Emotion = labels;

%% 
% 6. Guardar la tabla para usarla en clasificadores
% Definir la ruta completa al directorio
targetDir = 'C:\Users\Ainho\OneDrive\Escritorio\TFG\Matlab\Tools\TFG_Ainhoa_AudioToolbox\Features\FeaturesExtration\Emotions'; 

% Guardar el archivo .mat en el directorio especificado
save(fullfile(targetDir, 'specCableEmotions.mat'), 'specCTable');

disp('Características spectral Centroid extraídas y almacenadas.');