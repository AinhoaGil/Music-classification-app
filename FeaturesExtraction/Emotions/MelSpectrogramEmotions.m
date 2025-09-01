% 1. Definir la ruta de la carpeta de audio y el CSV
baseDir = 'C:\Users\Ainho\OneDrive\Escritorio\TFG\Matlab\Tools\AudioToolbox\Dataset\Osfstorage-emotions'; % Ruta de los audios
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

        % EXTRAER LOS Mel Spectrograms
        coeffs = melSpectrogram(audioData,fs, ...
               'Window',hann(2048,'periodic'), ...
               'OverlapLength',1024, ...
               'FFTLength',4096, ...
               'NumBands',64, ...
               'FrequencyRange',[62.5,8e3]);

        %Se extrae una matriz de coefficientes en 64 bandas de frecuencia
        %(64x605), por ello vamos a extraer coeficientes representativos del Mel Spectrogram 
        % distribuidos uniformemente entre las bandas de frecuencia

        % Seleccionar 14 coeficientes de bandas representativas
        selectedFeatures = coeffs(selectedBands, :); % Extraer las bandas seleccionadas
        featureMeans = mean(selectedFeatures, 2)';   % Promediar cada banda a lo largo del tiempo

        % Guardar las características y la etiqueta
        data = [data;  featureMeans]; % Agregar los coeficientes seleccionados al dataset
        labels = [labels; dataTable.TARGET{i}]; % Añadir la etiqueta correspondiente (emocion)

%         %GRAFICAR
        % Crear figura para graficar
        figure('Name', ['Audio - ', fileNameCompleted, ' | Emoción: ', emotion], ...
            'Position', get(0, 'ScreenSize'));  % Maximiza la ventana
        
         % Definir el tiempo para el gráfico
        T = 1/fs;
        t = 0:T:(length(audioData)*T) - T;

        % 1. Graficar la señal de audio en el dominio del tiempo
        subplot(2, 1, 1);
        plot(t, audioData);
        axis tight;
        xlabel('Tiempo (s)', 'FontSize', 12);
        ylabel('Amplitud', 'FontSize', 12);
        title(['Audio: ', fileNameCompleted, ' | Emoción: ', emotion], 'FontSize', 14);
        grid on;
                
        % Normalizar los coeficientes del Mel Spectrogram para que estén entre 0 y 1
        normalizedFeatures = (selectedFeatures - min(selectedFeatures(:))) / (max(selectedFeatures(:)) - min(selectedFeatures(:)));
        
        % Graficar el Mel Spectrogram normalizado
        subplot(2, 1, 2);
        imagesc(normalizedFeatures);  % Visualizar los coeficientes normalizados
        axis tight;
        xlabel('Tiempo (frames)', 'FontSize', 12);
        ylabel('Bandas seleccionadas', 'FontSize', 12);
        title('Mel Spectrogram Normalizado (Bandas Seleccionadas)', 'FontSize', 14);
        
        % Añadir la barra de color
        colorbar;
        
        % Ajustar las etiquetas del eje Y
        set(gca, 'YTick', 1:numCoeffs, 'YTickLabel', selectedBands);  % Mostrar las bandas seleccionadas en Y
        
        % Mejorar el contraste con un colormap más adecuado
        colormap('hot');  % Puedes cambiar 'hot' por otros esquemas de color como 'parula', 'jet', etc.
        grid on;
         % Pausar para visualizar los gráficos y permitir la reproducción
%         pause(length(audioData) / fs + 2); % Pausa para la duración del audio + 2 segundos adicionales

    else
        disp(['Archivo no encontrado: ', fileName]);
    end
end
%% 

% 5.  Crear una tabla con las características seleccionadas y etiquetas
melFeatureNames = arrayfun(@(x) sprintf('Mel_f%d', x), selectedBands, 'UniformOutput', false);
melTable = array2table(data, 'VariableNames', melFeatureNames);
melTable.Emotion = labels;

%% 
% 6. Guardar la tabla para usarla en clasificadores
% Definir la ruta completa al directorio
targetDir = 'C:\Users\Ainho\OneDrive\Escritorio\TFG\Matlab\Tools\AudioToolbox\Features\FeaturesExtration\Emotions'; 

% Guardar el archivo .mat en el directorio especificado
save(fullfile(targetDir, 'melTableEmotions.mat'), 'melTable');

disp('Características MelSpectrogram extraídas y almacenadas.');