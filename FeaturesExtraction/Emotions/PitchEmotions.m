% 1. Definir la ruta de la carpeta de audio y el CSV
baseDir = 'C:\Users\Ainho\OneDrive\Escritorio\TFG\Matlab\Tools\AudioToolbox\Dataset\Osfstorage-emotions'; % Ruta de los audios
csvFile = fullfile(baseDir, 'mean_ratings_set2.csv'); % Ruta del CSV
audioDir = fullfile(baseDir, 'Set2', 'set2');

% 2. Leer el archivo CSV
dataTable = readtable(csvFile);

% 3. Inicializar variables para almacenar características y etiquetas
data = [];       % Para almacenar las características MFCC
labels = {};     % Para almacenar las etiquetas (emociones)

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

        % EXTRAER EL PITCH
        [pitchVals, locs] = pitch(audioData, fs, ...
            'Method', 'SRH', ...               % Método SRH para mayor precisión en música
            'WindowLength', round(0.05 * fs), ... % Ventana de 50 ms
            'OverlapLength', round(0.045 * fs));  % Superposición del 90%

        pitchFeature = mean(pitchVals); % Calcular el promedio del pitch
%         subplot(2, 1, 2);
%         plot(locs / fs, pitchVals, '-');
%         xlabel('Tiempo (s)');
%         ylabel('Pitch (Hz)');
%         title('Estimación de Pitch');
%         ylim([min(pitchVals)-20, max(pitchVals)+20]); % Ajuste de límites para claridad
%         grid on;

        % Guardar las características y la etiqueta
        data = [data; pitchFeature]; % Guardar solo el promedio para cada archivo
        labels = [labels; emotion]; % Añadir la etiqueta correspondiente

         % Pausar para visualizar los gráficos y permitir la reproducción
%         pause(length(audioData) / fs + 2); % Pausa para la duración del audio + 2 segundos adicionales

    else
        disp(['Archivo no encontrado: ', fileName]);
    end
end
%% 

% 5. Crear una tabla con las características y las etiquetas
pitchTable = array2table(data, 'VariableNames', {'Pitch_Mean'});
pitchTable.Emotion = labels;

% 6. Guardar la tabla para usarla en clasificadores
disp('Características de Pitch extraídas y almacenadas.');

%% 

% Definir la ruta completa al directorio
targetDir = 'C:\Users\Ainho\OneDrive\Escritorio\TFG\Matlab\Tools\AudioToolbox\Features\FeaturesExtration\Emotions'; 

% Guardar el archivo .mat en el directorio especificado
save(fullfile(targetDir, 'pitchTableEmotions.mat'), 'pitchTable');
